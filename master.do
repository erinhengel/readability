quietly {
	********************************************
	************** Set up Stata. ***************
	********************************************
	set seed 677275986 // French mobile number.
	// set seed 824863784 // U.K. mobile number (sans leading 7).

	global home /Users/erinhengel
	local project_path "$home/Dropbox/Readability/draft"

	clear all
	discard
	program drop _all
	if "$S_StataMP"=="" & "$S_StataSE"=="" {
		set matsize 800
	}
	else {
		set matsize 5000
		set maxvar 32767
	}
	// set emptycells drop

	/* Copy personal ado files to personal ado directory. */
	local files : dir `"`project_path'/scode/stata"' files "*"
	foreach file of local files {
		copy `"`project_path'/scode/stata/`file'"' "`: sysdir PERSONAL'", replace
	}

	capture cls
	********************************************

	********************************************
	**************** Start log. ****************
	********************************************
	capture log close last_log
	log using "`project_path'/log/last_log", replace smcl name(last_log)
	noisily display "{title:Publishing while Female: Gender Differences in Peer Review Scrutiny}"
	noisily display "Erin Hengel"
	noisily display c(current_date) ", " c(current_time)
	********************************************

	********************************************
	************** Common macros. **************
	********************************************
	* Filepaths.
	local do_path "`project_path'/do"
	local tex_path "`project_path'/tex/generated"
	local pdf_path "`project_path'/pdf"
	local lbl_path "`project_path'/labels"

	* Table headers.
	local latex_header "&{\crcell[b]{Flesch\\[-0.1cm]Reading\\[-0.1cm]Ease}}&{\crcell[b]{Flesch-\\[-0.1cm]" ///
		"Kincaid}}&{\crcell[b]{Gunning\\[-0.1cm]Fog}}&{SMOG}&{\crcell[b]{Dale-\\[-0.1cm]Chall}}"
	local table_header `""Flesch Reading Ease" "Flesch Kincaid" "Gunning Fog" "SMOG" "Dale-Chall""'
	local table_varlables `"flesch "Flesch Reading Ease" fleschkincaid "Flesch Kincaid" gunningfog "Gunning Fog" smog "SMOG" dalechall "Dale-Chall""'

	* Statistics titles
	local _flesch_title "Flesch Reading Ease"
	local _fleschkincaid_title "Flesch Kincaid"
	local _gunningfog_title "Gunning Fog"
	local _smog_title "SMOG"
	local _dalechall_title "Dale-Chall"

	* Statistic lists.
	local stats flesch fleschkincaid gunningfog smog dalechall
	local stats_varnames _flesch_score _fleschkincaid_score _gunningfog_score _smog_score _dalechall_score
	local counts char word sybl polysyblword notdalechall
	local counts_varnames _char_count _word_count _sybl_count _polysyblword_count _notdalechall_count
	local nber_counts sent char word sybl polysyblword notdalechall wps pps spw pww dww
	local nber_counts_varnames _sent_count _char_count _word_count _sybl_count _polysyblword_count _notdalechall_count _wps_count _pps_count _spw_count _pww_count _dww_count

	* Colors
	local pink "216 92 99"
	local blue "52 108 139"
	********************************************

	********************************************
	************* Variable labels. *************
	********************************************
	import delimited varname label using `lbl_path'/varlabels.csv, clear
	generate command = "capture label variable " + varname + " " + label
	tempfile varlabels
	outfile command using `varlabels', replace noquote
	********************************************

	********************************************
	*************** Value labels. **************
	********************************************
	import delimited name value label using `lbl_path'/vallabels.csv, clear
	forvalues i=1/`=_N' {
		label define `=name[`i']' `=value[`i']' `=label[`i']', add
	}
	tempfile vallabels
	label save using `vallabels', replace
	********************************************

	********************************************
	******* Generate editorial clusters. *******
	********************************************
	odbc_compress, exec("SELECT * FROM EditorBoard;") dsn(readdb)
	by Journal Volume Issue Part (AuthorID), sort: generate j = _n
	reshape wide AuthorID, i(Journal Volume Issue Part) j(j)
	egen Editor = group(AuthorID*), missing
	drop AuthorID*
	tempfile cluster
	save `cluster'
	odbc_compress, exec("SELECT ArticleID, Journal, Volume, Issue, Part FROM Article;") dsn(readdb)
	merge m:1 Journal Volume Issue Part using `cluster', keep(match) nogenerate
	save `cluster', replace
	********************************************

	********************************************
	********** Generate female ratio. **********
	********************************************
	#delimit ;
	local sql "
	SELECT ArticleID, 1-AVG(Sex) AS FemRatio
		FROM AuthorCorr
		NATURAL JOIN Author
	GROUP BY ArticleID;
	";
	#delimit cr
	odbc_compress, exec("`sql'") dsn(readdb)
	compress
	tempfile femratio
	save `femratio'
	********************************************

	********************************************
	******* Generate institutional rank. *******
	********************************************
	#delimit ;
	local sql "
	SELECT InstID, COUNT(DISTINCT(ArticleID)) AS ArticleN
	FROM Article
		NATURAL JOIN InstCorr
		WHERE Journal <> 'P&P'
	GROUP BY InstID
	ORDER BY ArticleN
	";
	#delimit cr
	odbc_compress, exec("`sql'") dsn(readdb)
	egen InstRank = cut(ArticleN), at(0, 10, 20, 30, 40, 50, 60) icodes
	replace InstRank = InstRank[_n-1]+1 if missing(InstRank)
	tempfile instrank
	save `instrank'
	odbc_compress, exec("SELECT * FROM InstCorr;") dsn(readdb)
	merge m:1 InstID using `instrank', nogenerate
	replace InstRank = 1 if missing(InstRank)
	save `instrank', replace
	collapse (max) MaxInst=InstRank, by(ArticleID)
	compress
	tempfile article_instrank
	save `article_instrank'
	use `instrank', clear
	collapse (max) InstRank, by(ArticleID AuthorID)
	compress
	tempfile author_instrank
	save `author_instrank'
	********************************************

	********************************************
	******* Generate publication counts. *******
	********************************************
	#delimit ;
	local sql "
	SELECT AuthorID, COUNT(ArticleID) AS T
		FROM AuthorCorr
		NATURAL JOIN Article
		WHERE Journal <> 'P&P'
	GROUP BY AuthorID;
	";
	#delimit cr
	odbc_compress, exec("`sql'") dsn(readdb)
	tempfile pubn
	save `pubn'
	odbc_compress, exec("SELECT * FROM AuthorCorr;") dsn(readdb)
	merge m:1 AuthorID using `pubn', assert(master match) nogenerate
	replace T = 0 if missing(T)
	collapse (max) MaxT=T, by(ArticleID)
	compress
	save `pubn', replace
	********************************************

	********************************************
	******** Generate publication order. *******
	********************************************
	odbc_compress, exec("SELECT ArticleID, Journal, Volume, Issue, FirstPage FROM Article;") dsn(readdb)
	by Journal Volume Issue (FirstPage), sort: generate PubOrder = _n
	keep ArticleID PubOrder
	compress
	tempfile order
	save `order'
	********************************************

	********************************************
	************ Generate author N. ************
	********************************************
	odbc_compress, exec("SELECT ArticleID, COUNT(AuthorID) AS N FROM AuthorCorr GROUP BY ArticleID;") dsn(readdb)
	tempfile authorN
	save `authorN'
	********************************************

	********************************************
	************* Generate Max t. **************
	********************************************
	odbc_compress, exec("SELECT ArticleID, AuthorID, Journal, PubDate, FirstPage FROM Article NATURAL JOIN AuthorCorr;")
	date_replace PubDate, mask("YMD")
	generate t = Journal!="P&P"
	gsort AuthorID PubDate -Journal -FirstPage
	by AuthorID: generate Maxt = sum(t)
	collapse (max) Maxt, by(ArticleID)
	tempfile Maxt
	save `Maxt'
	********************************************

	********************************************
	********* Generate native English. *********
	********************************************
	#delimit ;
	local sql "
		SELECT ArticleID, MAX(CASE WHEN NativeLanguage='English' THEN 1 ELSE 0 END) AS NativeEnglish
			FROM Article
			NATURAL JOIN AuthorCorr
			NATURAL JOIN Author
		GROUP BY ArticleID;
	";
	#delimit cr
	odbc_compress, exec("`sql'") dsn(readdb)
	tempfile english
	save `english'
	********************************************

	********************************************
	******** Generate primary JEL data. ********
	********************************************
	#delimit ;
	local sql "
	SELECT ArticleID, SUBSTR(JEL, 1, 1) AS JEL
		FROM JEL
		NATURAL JOIN Article
		WHERE Language = 'English'
	";
	#delimit cr
	odbc_compress, exec("`sql'") dsn(readdb)
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
	saveold "`project_path'/data/primary_jel", replace version(12)
	********************************************

	********************************************
	******** Generate tertiary JEL data. *******
	********************************************
	#delimit ;
	local sql "
	SELECT ArticleID, JEL
		FROM JEL
		NATURAL JOIN Article
		WHERE Language = 'English'
	";
	#delimit cr
	odbc_compress, exec("`sql'") dsn(readdb)
	duplicates drop
	encode_replace JEL
	distinct JEL
	forvalues i=1/`r(ndistinct)' {
		generate byte JEL3_`i' = JEL == `i'
	}
	collapse (max) JEL3_*, by(ArticleID)
	compress
	tempfile tertiary_jel
	save `tertiary_jel'
	saveold "`project_path'/data/tertiary_jel", replace version(12)
	********************************************

	********************************************
	***** Generate article-level P&P data. *****
	********************************************
	#delimit ;
	local sql "
	SELECT ArticleID, Journal, Volume, Issue, FirstPage, StatName, PubDate, CiteCount, LastPage,
	CASE WHEN (StatName='flesch_score' OR StatName LIKE '%_count') THEN StatValue ELSE -1 * StatValue END AS _,
	CAST(STRFTIME('%Y', PubDate) AS INTEGER) AS Year
		FROM Article
		NATURAL JOIN ReadStat
		WHERE Language = 'English'
	";
	#delimit cr
	odbc_compress, exec("`sql'") dsn(readdb)
	reshape wide _, i(ArticleID) j(StatName) string
	merge 1:1 ArticleID using `femratio', assert(using match) keep(match) nogenerate
	merge 1:1 ArticleID using `article_instrank', assert(using match) keep(match) nogenerate
	merge 1:1 ArticleID using `pubn', assert(using match) keep(match) nogenerate
	merge 1:1 ArticleID using `order', assert(using match) keep(match) nogenerate
	merge 1:1 ArticleID using `authorN', assert(using match) keep(match) nogenerate
	merge 1:1 ArticleID using `cluster', assert(using match) keep(match) nogenerate
	merge 1:1 ArticleID using `Maxt', assert(using match) keep(match) nogenerate
	merge 1:1 ArticleID using `english', assert(using match) keep(match) nogenerate
	egen JnlVol = group(Journal Volume)
	egen JnlVolIss = group(Journal Volume Issue)
	label define Journal 1 "AER" 2 "ECA" 3 "JPE" 4 "QJE" 5 "P&P"
	encode_replace Journal
	date_replace PubDate, mask("YMD")
	generate _wps_count = _word_count / _sent_count
	generate _pps_count = _polysyblword_count / _sent_count
	generate _spw_count = _sybl_count / _word_count
	generate _pww_count = _polysyblword_count / _word_count
	generate _dww_count = _notdalechall_count / _word_count
	generate FemSolo = .
	replace FemSolo = 1 if FemRatio==1 & N==1
	replace FemSolo = 0 if FemRatio==0 & N==1
	generate Fem100 = .
	replace Fem100 = 1 if FemRatio==1
	replace Fem100 = 0 if FemRatio==0
	generate Fem50 = .
	replace Fem50 = 1 if FemRatio>=0.5
	replace Fem50 = 0 if FemRatio==0
	generate Female = FemRatio>0
	generate asinhCiteCount = ln(CiteCount + sqrt(1+CiteCount^2))
	do `varlabels'
	compress
	tempfile article_pp
	save `article_pp'
	saveold "`project_path'/data/article_pp", replace version(12)
	********************************************

	********************************************
	******* Generate article-level data. *******
	********************************************
	* Generate article data.
	use `article_pp'
	drop if Journal==5
	tempfile article
	save `article'
	saveold "`project_path'/data/article", replace version(12)
	********************************************

	********************************************
	***** Generate article-level JEL data. *****
	********************************************
	use `article', clear
	merge 1:1 ArticleID using `primary_jel', keep(match) nogenerate
	compress
	tempfile article_primary_jel
	save `article_primary_jel'
	********************************************

	********************************************
	** Generate article-level JEL data + P&P. **
	********************************************
	use `article_pp', clear
	merge 1:1 ArticleID using `primary_jel', assert(master match) keep(match) nogenerate
	compress
	tempfile article_primary_jel_pp
	save `article_primary_jel_pp'
	********************************************

	********************************************
	******* Generate tertiary JEL data. ********
	********************************************
	use `article', clear
	merge 1:1 ArticleID using `tertiary_jel', keep(match) nogenerate
	compress
	tempfile article_tertiary_jel
	save `article_tertiary_jel'
	********************************************

	********************************************
	**** Generate tertiary JEL data + P&P. *****
	********************************************
	use `article_pp', clear
	merge 1:1 ArticleID using `tertiary_jel', assert(master match) keep(match) nogenerate
	compress
	tempfile article_tertiary_jel_pp
	save `article_tertiary_jel_pp'
	********************************************

	********************************************
	******* Generate author-level data. ********
	********************************************
	odbc_compress, exec("SELECT ArticleID, AuthorID, Sex, AuthorOrder FROM Author NATURAL JOIN AuthorCorr;") dsn(readdb)
	merge m:1 ArticleID using `article', assert(master match) keep(match) nogenerate
	merge m:1 ArticleID AuthorID using `author_instrank', assert(using match) keep(match) nogenerate
	* Downweight duplicate observations (i.e., co-authored papers).
	* Weights are inversely proportionate to the number of co-authors.
	bysort ArticleID: generate AuthorWeight = _N
	summarize AuthorWeight
	replace AuthorWeight = r(max) + 1 - AuthorWeight
	* Sort order determines how articles published in the same month are ordered.
	* Articles published in the QJE and earlier in an issue assumed to be "newer"
	* b/c shorter review times (Ellison, 2002).
	gsort AuthorID PubDate -Journal -FirstPage
	by AuthorID: generate t = _n
	by AuthorID (t), sort: egen T = max(t)
	egen AuthorEditor = group(AuthorID Editor)
	recode t (1=1)(2=2)(3/6=3)(nonmissing=4), generate(tBin)
	recode AuthorOrder (0=0)(1=1)(nonmissing=2), generate(AuthorOrderBin)
	xtset AuthorID t
	fvset base 64 Year
	fvset base 80 Editor
	fvset base 64 MaxInst
	fvset base 30 MaxT
	do `varlabels'
	do `vallabels'
	label values Sex gender
	label values tBin tbin
	compress
	tempfile author
	save `author'
	saveold "`project_path'/data/author", replace version(12)
	********************************************

	********************************************
	************** Do analysis. ****************
	********************************************
	noisily include "`do_path'/0-female-representation.do"
	/* noisily include "`do_path'/1-coverage.do"
	noisily include "`do_path'/2-article-level.do"
	noisily include "`do_path'/3-author-level.do"
	noisily include "`do_path'/4-nber.do"
	noisily include "`do_path'/5-model-consistency.do"
	noisily include "`do_path'/6-matching.do"
	noisily include "`do_path'/7-duration.do"
	noisily include "`do_path'/8-author-within-diffs.do" */
	********************************************

	log close last_log
	estimates clear
}
exit
