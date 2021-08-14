********************************************************************************
************************************* DATA *************************************
********************************************************************************
* Variable labels.
import delimited varname label using 0-labels/varlabels.csv, clear
generate command = "capture label variable " + varname + " " + label
tempfile varlabels
outfile command using `varlabels', replace noquote

* Value labels.
import delimited name value label using 0-labels/vallabels.csv, clear
forvalues i=1/`=_N' {
	label define `=name[`i']' `=value[`i']' `=label[`i']', add
}
tempfile vallabels
label save using `vallabels', replace

* Generate editorial clusters.
odbc_compress, exec("SELECT * FROM EditorBoard;") conn(`"`connstr'"')
by Journal Volume Issue Part (AuthorID), sort: generate j = _n
reshape wide AuthorID, i(Journal Volume Issue Part) j(j)
egen Editor = group(AuthorID*), missing
drop AuthorID*
tempfile cluster
save `cluster'
odbc_compress, exec("SELECT ArticleID, Journal, Volume, Issue, Part FROM Article;") conn(`"`connstr'"')
merge m:1 Journal Volume Issue Part using `cluster', keep(match) nogenerate
save `cluster', replace

* Generate article and author characteristic data.
#delimit ;
local sql "
SELECT ArticleID, Journal, FirstPage, PubDate
	FROM Article
	WHERE Journal <> 'P&P'
			AND Title NOT LIKE '%corrigendum%'
			AND Title NOT LIKE '%erratum%'
			AND Title NOT LIKE '%: a correction%'
			AND Title NOT LIKE '%: correction%';
";
#delimit cr
odbc_compress, exec("`sql';") conn(`"`connstr'"')
date_replace PubDate, mask("YMD")
label define Journal 1 "AER" 2 "ECA" 3 "JPE" 4 "QJE" 5 "P&P" 6 "RES"
encode_replace Journal
tempfile article_tmp
save `article_tmp'
odbc_compress, exec("SELECT ArticleID, AuthorID FROM Author NATURAL JOIN AuthorCorr;") conn(`"`connstr'"')
merge m:1 ArticleID using `article_tmp', assert(master match) keep(match) nogenerate
* Sort order determines how articles published in the same month are ordered.
* Articles published in the QJE and earlier in an issue assumed to be "newer"
* b/c shorter review times (Ellison, 2002).
gsort AuthorID PubDate -Journal -FirstPage
by AuthorID: generate t5 = _n
tempfile author_tmp
save `author_tmp'
#delimit ;
local sql "
SELECT ArticleID, AuthorID, Journal, FirstPage, PubDate, Female
	FROM Article
	NATURAL JOIN (SELECT ArticleID, AuthorID, CASE WHEN Sex='Female' THEN 1 ELSE 0 END AS Female FROM Author NATURAL JOIN AuthorCorr);
";
#delimit cr
odbc_compress, exec("`sql'") conn(`"`connstr'"')
label define gender 1 "Female" 0 "Male"
label values Female gender
date_replace PubDate, mask("YMD")
encode_replace Journal
merge 1:1 ArticleID AuthorID using `author_tmp', assert(master match)
generate Errata = _merge == 1 & Journal != 5
drop _merge
* Number of top-five articles at time of publication.
by AuthorID (PubDate), sort: replace t5 = t5[_n-1] if missing(t5)
replace t5 = 0 if missing(t5)
* Lifetime top-five publication count.
by AuthorID, sort: egen T5 = max(t5)
* Author with the highest number of top-five articles at the time of publication.
by ArticleID, sort: egen Maxt = max(t5)
* Author with the highest lifetime number of top-five publications.
by ArticleID, sort: egen MaxT = max(T5)
* Number of co-authors.
by ArticleID, sort: generate N = _N
* Female ratio.
by ArticleID, sort: egen FemRatio0 = mean(Female)
generate FemRatio = FemRatio0
replace FemRatio = 0 if FemRatio<0.5
* Senior author.
generate Senior = t==Maxt
* Number of senior authors.
by ArticleID, sort: egen SeniorN = total(Senior)
* Female and male seniority.
tempvar FemSenior
generate `FemSenior' = cond(t==Maxt&Female==1, 1, 0)
by ArticleID, sort: egen FemSenior = max(`FemSenior')
drop `FemSenior'
tempvar ManSenior
generate `ManSenior' = cond(t==Maxt&Female==0, 1, 0)
by ArticleID, sort: egen ManSenior = max(`ManSenior')
drop `ManSenior'
replace FemSenior = FemSenior * FemRatio0 // Make FemSenior proportional to the ratio of female authors.
replace FemSenior = . if FemSenior>0&ManSenior>0 // Make FemSenior strict (only equal to one if woman is the only senior author).
replace FemSenior = . if FemSenior==0 & FemRatio0>0 // Omit mixed-gendered papers with a male senior author.
* Senior female among non-senior-authored papers.
generate FemJunior = FemSenior
replace FemJunior = . if t > 3
* Female solo-authored.
generate FemSolo = .
replace FemSolo = 1 if FemRatio0==1 & N==1
replace FemSolo = 0 if FemRatio0==0 & N==1
* Exclusively female authored.
generate Fem100 = .
replace Fem100 = 1 if FemRatio0==1
replace Fem100 = 0 if FemRatio0==0
* At least 50% female authors.
generate Fem50 = .
replace Fem50 = 1 if FemRatio0>=0.5
replace Fem50 = 0 if FemRatio0==0
* At least one female author.
generate Fem1 = FemRatio0>0
* Save author-level data.
drop FirstPage PubDate Journal
tempfile author_chars
save `author_chars'
save "0-data/generated/author_chars", replace
* Save article-level data.
collapse (firstnm) Maxt MaxT N FemRatio0 FemRatio SeniorN FemSenior FemJunior ManSenior FemSolo Fem100 Fem50 Fem1 Errata, by(ArticleID)
tempfile article_chars
save `article_chars'
save "0-data/generated/article_chars", replace

* Generate institutional rank.
#delimit ;
local sql "
SELECT InstID, CAST(SUBSTR(PubDate, 1, 4) AS INTEGER) AS Year, COUNT(DISTINCT(ArticleID)) AS ArticleN
FROM Article
	NATURAL JOIN InstCorr
	WHERE Journal <> 'P&P'
		AND Title NOT LIKE '%corrigendum%'
		AND Title NOT LIKE '%erratum%'
		AND Title NOT LIKE '%: a correction%'
		AND Title NOT LIKE '%: correction%'
GROUP BY InstID, Year
";
#delimit cr
odbc_compress, exec("`sql'") conn(`"`connstr'"')
xtset InstID Year
tssmooth ma maArticleN=ArticleN, window(5)
replace maArticleN = ArticleN if missing(maArticleN)
egen rankArticleN = rank(maArticleN), by(Year) field
summarize rankArticleN
egen InstRank = cut(rankArticleN), at(0(1)9, 10(10)60, `=r(max)+1')
tempfile instrank
save `instrank'
#delimit ;
local sql "
SELECT InstID, ArticleID, AuthorID, CAST(SUBSTR(PubDate, 1, 4) AS INTEGER) AS Year
	FROM InstCorr
	NATURAL JOIN Article
";
#delimit cr
odbc_compress, exec("`sql'") conn(`"`connstr'"')
merge m:m InstID Year using `instrank', assert(master match) nogenerate
replace InstRank = 60 if missing(InstRank) // P&P articles involving an unranked affiliation
save `instrank', replace
collapse (min) MaxInst=InstRank, by(ArticleID)
compress
tempfile article_instrank
save `article_instrank'
use `instrank', clear
collapse (min) InstRank, by(ArticleID AuthorID)
compress
tempfile author_instrank
save `author_instrank'

* Generate publication order.
odbc_compress, exec("SELECT ArticleID, Journal, Volume, Issue, FirstPage FROM Article;") conn(`"`connstr'"')
by Journal Volume Issue (FirstPage), sort: generate PubOrder = _n
keep ArticleID PubOrder
compress
tempfile order
save `order'

* Generate native English.
#delimit ;
local sql "
	SELECT ArticleID, MAX(CASE WHEN nativelanguage='English' THEN 1 ELSE 0 END) AS NativeEnglish
		FROM AuthorCorr
		NATURAL JOIN Author
		GROUP BY ArticleID
";
#delimit cr
odbc_compress, exec("`sql'") conn(`"`connstr'"')
tempfile english
save `english'

* Generate theory/empirical.
import delimited "0-data/fixed/JEL.csv", clear varnames(1) case(preserve) encoding("utf-8") bindquotes(strict)
drop Description
tempfile type
save `type'

odbc_compress, exec("SELECT Article.ArticleID AS ArticleID, JEL FROM Article LEFT JOIN JEL ON Article.ArticleID=JEL.ArticleID;") conn(`"`connstr'"')
merge m:1 JEL using `type', keep(master match) nogenerate
replace Type = "Other" if missing(Type)
keep ArticleID Type
duplicates drop
generate Type_ = 1
reshape wide Type_, i(ArticleID) j(Type) string
foreach var of varlist Type_* {
	replace `var' = 0 if missing(`var')
}
tempfile type
save `type'

* Generate primary JEL data.
#delimit ;
local sql "
SELECT ArticleID, SUBSTR(JEL, 1, 1) AS JEL
	FROM JEL
	NATURAL JOIN Article
	WHERE Language = 'English'
";
#delimit cr
odbc_compress, exec("`sql'") conn(`"`connstr'"')
duplicates drop
encode_replace JEL
distinct JEL
forvalues i=1/`r(ndistinct)' {
	generate JEL1_`:label (JEL) `i'' = JEL == `i'
}
collapse (max) JEL1_*, by(ArticleID)
compress
tempfile primary_jel
save `primary_jel'
save "0-data/generated/primary_jel", replace

* Generate tertiary JEL data.
#delimit ;
local sql "
SELECT ArticleID, JEL
	FROM JEL
	NATURAL JOIN Article
	WHERE Language = 'English'
";
#delimit cr
odbc_compress, exec("`sql'") conn(`"`connstr'"')
encode_replace JEL
distinct JEL
forvalues i=1/`r(ndistinct)' {
	generate byte JEL3_`i' = JEL == `i'
}
collapse (max) JEL3_*, by(ArticleID)
compress
tempfile tertiary_jel
save `tertiary_jel'
save "0-data/generated/tertiary_jel", replace

* Generate article-level P&P data.
#delimit ;
local sql "
SELECT ArticleID, Journal, Volume, Issue, FirstPage, StatName, PubDate, CiteCount, LastPage,
CASE WHEN (StatName='flesch_score' OR StatName LIKE '%_count') THEN StatValue ELSE -1 * StatValue END AS _,
CAST(STRFTIME('%Y', PubDate) AS INTEGER) AS Year
	FROM Article
	NATURAL JOIN ReadStat
	WHERE
		Language = 'English'
		AND Title NOT LIKE '%corrigendum%'
		AND Title NOT LIKE '%erratum%'
		AND Title NOT LIKE '%: a correction%'
		AND Title NOT LIKE '%: correction%';
";
#delimit cr
odbc_compress, exec("`sql'") conn(`"`connstr'"')
reshape wide _, i(ArticleID) j(StatName) string
merge 1:1 ArticleID using `article_chars', assert(using match) keep(match) nogenerate
merge 1:1 ArticleID using `article_instrank', assert(using match) keep(match) nogenerate
merge 1:1 ArticleID using `order', assert(using match) keep(match) nogenerate
merge 1:1 ArticleID using `cluster', assert(using match) keep(match) nogenerate
merge 1:1 ArticleID using `english', assert(using match) keep(match) nogenerate
merge 1:1 ArticleID using `type', assert(using match) keep(match) nogenerate
merge m:1 ArticleID using "0-data/generated/readstat", assert(using match) keep(match) nogenerate
egen JnlVol = group(Journal Volume)
egen JnlVolIss = group(Journal Volume Issue)
label define Journal 1 "AER" 2 "ECA" 3 "JPE" 4 "QJE" 5 "P&P" 6 "RES"
encode_replace Journal
date_replace PubDate, mask("YMD")
generate _wps_count = _word_count / _sent_count
generate _pps_count = _polysyblword_count / _sent_count
generate _spw_count = _sybl_count / _word_count
generate _pww_count = _polysyblword_count / _word_count
generate _dww_count = _notdalechall_count / _word_count
generate asinhCiteCount = ln(CiteCount + sqrt(1+CiteCount^2))
generate Blind = Year<=1997&(Journal==4|(PubDate>=date("1989-06-01", "YMD")&Journal==1))
do `varlabels'
compress
tempfile article_pp
save `article_pp'
save "0-data/generated/article_pp", replace

* Generate article-level data.
* Generate article data.
use `article_pp'
drop if Journal==5
tempfile article
save `article'
save "0-data/generated/article", replace

* Generate article-level JEL data.
use `article', clear
merge 1:1 ArticleID using `primary_jel', keep(match) nogenerate
do `varlabels'
compress
tempfile article_primary_jel
save `article_primary_jel'
save "0-data/generated/article_primary_jel", replace

* Generate article-level JEL data + P&P.
use `article_pp', clear
merge 1:1 ArticleID using `primary_jel', keep(match) nogenerate
do `varlabels'
compress
tempfile article_primary_jel_pp
save `article_primary_jel_pp'
save "0-data/generated/article_primary_jel_pp", replace

* Generate tertiary JEL data.
use `article', clear
merge 1:1 ArticleID using `tertiary_jel', keep(match) nogenerate
compress
tempfile article_tertiary_jel
save `article_tertiary_jel'
save "0-data/generated/article_tertiary_jel", replace

* Generate tertiary JEL data + P&P.
use `article_pp', clear
merge 1:1 ArticleID using `tertiary_jel', keep(match) nogenerate
compress
tempfile article_tertiary_jel_pp
save `article_tertiary_jel_pp'
save "0-data/generated/article_tertiary_jel_pp", replace

* Generate author-level data for top four journals.
use `author_chars', clear
merge m:1 ArticleID using `article', assert(master match) keep(match) nogenerate
merge m:1 ArticleID AuthorID using `author_instrank', assert(using match) keep(match) nogenerate
* Sort order determines how articles published in the same month are ordered.
* Articles published in the QJE and earlier in an issue assumed to be "newer"
* b/c shorter review times (Ellison, 2002).
gsort AuthorID PubDate -Journal -FirstPage
by AuthorID, sort: generate t = _n
by AuthorID, sort: egen T = max(t)
* Downweight duplicate observations (i.e., co-authored papers).
* Weights are inversely proportionate to the number of co-authors.
bysort ArticleID: generate AuthorWeight = _N
summarize AuthorWeight
replace AuthorWeight = r(max) + 1 - AuthorWeight
egen AuthorEditor = group(AuthorID Editor)
recode t (1=1)(2=2)(3/6=3)(nonmissing=4), generate(tBin)
xtset AuthorID t
fvset base 64 Year
fvset base 80 Editor
fvset base 64 MaxInst
fvset base 30 MaxT
do `varlabels'
do `vallabels'
label values Female gender
label values tBin tbin
compress
tempfile author
save `author'
save "0-data/generated/author", replace

* Generate author-level data for all top five journals.
#delimit ;
local sql "
SELECT ArticleID, Journal, Volume, Issue, FirstPage, PubDate, CiteCount,
LastPage, CAST(STRFTIME('%Y', PubDate) AS INTEGER) AS Year
	FROM Article;
";
#delimit cr
odbc_compress, exec("`sql'") conn(`"`connstr'"')
merge 1:m ArticleID using `author_chars', assert(match) nogenerate
encode_replace Journal
date_replace PubDate, mask("YMD")
keep if Errata==0 & Journal!=5
drop Errata
* Downweight duplicate observations (i.e., co-authored papers).
* Weights are inversely proportionate to the number of co-authors.
bysort ArticleID: generate AuthorWeight = _N
summarize AuthorWeight
replace AuthorWeight = r(max) + 1 - AuthorWeight
xtset AuthorID t5
do `varlabels'
do `vallabels'
label values Female gender
compress
tempfile author5
save `author5'
save "0-data/generated/author5", replace

* Generate NBER data.
#delimit ;
local sql "
SELECT ArticleID, NberID, WPDate, StatName,
CASE WHEN (StatName='flesch_score' OR StatName LIKE '%_count') THEN StatValue ELSE -1 * StatValue END AS nber_
	FROM NBER
	NATURAL JOIN NBERCorr
	NATURAL JOIN NBERStat
";
#delimit cr
odbc_compress, exec("`sql'") conn(`"`connstr'"')
reshape wide nber_, i(ArticleID NberID) j(StatName) string
merge m:1 ArticleID using `article', keep(match) nogenerate
generate nber_wps_count = nber_word_count / nber_sent_count
generate nber_pps_count = nber_polysyblword_count / _sent_count
generate nber_spw_count = nber_sybl_count / nber_word_count
generate nber_pww_count = nber_polysyblword_count / nber_word_count
generate nber_dww_count = nber_notdalechall_count / nber_word_count
generate SemiBlind = (Journal==1&Year<2012|Journal==4&Year<2005)&Year>1997
generate BelowAbstractLen = (Journal==3)|(Journal==4)|(nber_word_count<=100&Journal==1)|(nber_word_count<=150&Journal==2)
date_replace WPDate, mask("YMD")
* Add readability data calculated using alternative program.
merge 1:1 NberID using "0-data/generated/nberstat", assert(using match) keep(match) nogenerate
merge m:1 ArticleID using "0-data/generated/readstat", assert(using match) keep(match) nogenerate
do `varlabels'
compress
tempfile nber
save `nber'
save "0-data/generated/nber", replace

* Generate data to use the change in score as a dependent variable.
use `nber', clear
reshape long @_score, i(NberID) j(stat) string
generate time = substr(stat, 1, 4)!="nber"
replace stat = substr(stat, 5, .) if !time
reshape wide _score, i(NberID time) j(stat) string
rename _score* *_score
egen id = group(NberID)
do `varlabels'
xtset id time
tempfile nber_fe
save `nber_fe'
save "0-data/generated/nber_fe", replace

* Add JEL codes to FGLS and FE data.
use `nber'
merge m:1 ArticleID using `primary_jel', keep(match) nogenerate
tempfile nber_jel
save `nber_jel'
use `nber_fe'
merge m:1 ArticleID using `primary_jel', keep(match) nogenerate
sort id time
tempfile nber_fe_jel
save `nber_fe_jel'
save "0-data/generated/nber_fe_jel", replace

* Generate review time data.
#delimit ;
local sql "
SELECT ArticleID, PubDate, AuthorCorr.AuthorID AS AuthorID,
	CAST(STRFTIME('%Y', PubDate) AS INTEGER) AS Year, Received, Accepted, CiteCount,
	CAST(STRFTIME('%Y', Received) AS INTEGER) AS ReceivedYear,
	CAST(STRFTIME('%Y', Accepted) AS INTEGER) AS AcceptedYear, FirstPage, LastPage,
	LastPage - FirstPage AS PageN, (JULIANDAY(Accepted) - JULIANDAY(Received)) / 30 AS ReviewLength,
	CASE WHEN Children.Year BETWEEN CAST(STRFTIME('%Y', Received) AS INTEGER) AND CAST(STRFTIME('%Y', Accepted) AS INTEGER) THEN 1 ELSE 0 END AS Birth,
	CAST(CASE WHEN Received-Children.Year>=0 THEN Received-Children.Year ELSE NULL END AS INTEGER) AS ChildReceived,
	CASE WHEN Accepted-Children.Year>=0 THEN Accepted-Children.Year ELSE NULL END AS ChildAccepted
		FROM Article
		NATURAL JOIN AuthorCorr
		LEFT OUTER JOIN Children ON AuthorCorr.AuthorID=Children.AuthorID
	WHERE
		Received IS NOT NULL
		AND PubDate < '2016-01-01'
		AND Title NOT LIKE '%corrigendum%'
		AND Title NOT LIKE '%erratum%'
		AND Title NOT LIKE '%: a correction%'
		AND Title NOT LIKE '%: correction%';
";
#delimit cr
odbc_compress, exec("`sql'") conn(`"`connstr'"')
merge m:1 ArticleID using `article_chars', assert(using match) keep(match) nogenerate
merge m:1 ArticleID using `article_instrank', keep(master match) nogenerate
merge m:1 ArticleID using `order', assert(using match) keep(match) nogenerate
merge m:1 ArticleID using `cluster', assert(using match) keep(match) nogenerate
merge m:1 ArticleID using `english', assert(using match) keep(match) nogenerate
merge m:1 ArticleID using `type', assert(using match) keep(match) nogenerate
generate asinhCiteCount = ln(CiteCount + sqrt(1+CiteCount^2))
date_replace PubDate, mask("YMD")
date_replace Received, mask("YMD")
date_replace Accepted, mask("YMD")
encode_replace Journal
merge m:1 ArticleID using `article', keep(master match) keepusing(_flesch_score) nogenerate
do `varlabels'
compress
tempfile duration
save `duration'
save "0-data/generated/duration", replace
********************************************************************************
