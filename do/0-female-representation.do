********************************************
************* Correlation table. ************
********************************************
use `article', clear
binscatter asinhCiteCount _flesch_score if Year>2000 ///
	, scheme(publishing-female) ///
	legend(off) ///
	name(female, replace) ///
	color(pfblue pfblue) ///
	xtitle("Flesch Reading Ease", placement(seast)) ytitle("") title("") subtitle("Citation count (asinh)", placement(nwest) size(vsmall))

graph export "`pdf_path'/asinhCiteCount.pdf", replace
********************************************

********************************************
************* Display Figure 1. ************
********************************************
preserve
replace Fem100 = FemRatio==1
replace Fem50 = FemRatio>0.5
generate Male = FemRatio==0
collapse (mean) FemRatio Fem50 Female Fem100 Male, by(Year)
tsset Year

foreach v of varlist Fem* {
	replace `v' = `v'*100
}

keep if Year>1985
tssmooth ma maFemRatio=FemRatio, window(5)
tssmooth ma maFem50=Fem50, window(5)
tssmooth ma maFemale=Female, window(5)
tssmooth ma maFem100=Fem100, window(5)
tssmooth ma maMale=Male, window(5)
graph twoway ///
	(line maFemRatio Year, color(pfyellow) lwidth(medium)) ///
	(line maFem100 Year, color(pfpink) lwidth(medium)) ///
	(line maFem50 Year, color(pfblue) lwidth(medium)) ///
	(line maFemale Year, color(pfteal) lwidth(medium)) ///
	, xlabel(1987(4)2015) ///
	legend(position(10) ///
		order(4 "At least one female-author (% papers)" ///
		1 "% female authors (per paper)" ///
		3 "Majority female-authored (% papers)" ///
		2 "100% female-authored (% papers)") ///
		cols(1) rows(8) symxsize(2)) ///
	scheme(publishing-female) ///
	xtitle("") ///
	ytitle("") ///
	ylabel(5 "5%" 10 "10%" 15 "15%" 20 "20%" 25 "25%")
graph export "`pdf_path'/figure00.pdf", replace
restore
********************************************

********************************************
************* Meta analysis. ***************
********************************************
import delimited ~/Dropbox/Readability/dta/correlations.txt, ///
	case(preserve) ///
	clear ///
	varnames(1) ///
	encoding("utf-8")

preserve
by TestType Source, sort: generate Study = cond(_n==1, 1, 0)
table TestType, contents(median Correlation freq sum Study) replace
rename (table*) (median corrs studies)
sort median
tempname bd
mkmat median corrs studies, matrix(`bd') rownames(TestType)
restore

graph box Correlation, ///
	over(TestType, ///
		sort(1) ///
		gap(85) ///
		relabel(1 `""Human judgement{sup}{c 134}""' 2 `""Oral reading fluency""' 3 `""Comprehension tests""' 4 `""Readability scores""' 5 `""Cloze procedure""')) ///
	scheme(publishing-female) ///
	nooutsides ///
	note("") ///
	legend(off) ///
	title("") subtitle("Correlation", placement(nwest) size(vsmall)) ytitle("") ///
	asyvars showyvars ///
	medtype(cline) medline(lcolor(white) lwidth(vthin) lpattern(solid)) cwhiskers lines(lwidth(vthin)) alsize(0) ///
	intensity(90) lintensity(90) ///
	graphregion(margin(small)) ///
	box(1, color(pfblue)) ///
	box(2, color(pfblue)) ///
	box(3, color(pfblue)) ///
	box(4, color(pfyellow)) ///
	box(5, color(pfblue)) ///
	text(`"`: display `bd'[1,1]+0.001'"' 8 `"{it: N} = `: display `bd'[1,2]'"' " " "`: display `bd'[1,3]' studies", size(vsmall) color(white)) ///
	text(`"`: display `bd'[2,1]+0.002'"' 29 `"{it: N} = `: display `bd'[2,2]'"' " " "`: display `bd'[2,3]' studies", size(vsmall) color(white)) ///
	text(`"`: display `bd'[3,1]+0.002'"' 50 `"{it: N} = `: display `bd'[3,2]'"' " " "`: display `bd'[3,3]' studies", size(vsmall) color(white)) ///
	text(`"`: display `bd'[4,1]+0.004'"' 71 `"{it: N} = `: display `bd'[4,2]'"' " " "`: display `bd'[4,3]' studies", size(vsmall) color(white)) ///
	text(`"`: display `bd'[5,1]+0.003'"' 92 `"{it: N} = `: display `bd'[5,2]'"' " " "`: display `bd'[5,3]' studies", size(vsmall) color(black))
graph export "`pdf_path'/figure0X.pdf", replace
********************************************

********************************************
************* Readability by JEL. ***************
********************************************
use `article_primary_jel', clear
keep ArticleID JEL* _flesch_score Year
reshape long JEL, i(ArticleID) j(jel) string
drop if JEL==0
drop JEL
rename jel JEL

replace JEL = regexs(1) if regexm(JEL, "1\_([A-Z])")

replace JEL = "A General" if JEL=="A"
replace JEL = "B Methodology" if JEL=="B"
replace JEL = "C Quant. methods" if JEL=="C"
replace JEL = "D Microeconomics" if JEL=="D"
replace JEL = "E Macroeconomics" if JEL=="E"
replace JEL = "F International" if JEL=="F"
replace JEL = "G Finance" if JEL=="G"
replace JEL = "H Public" if JEL=="H"
replace JEL = "I Health, welfare, edu." if JEL=="I"
replace JEL = "J Labour" if JEL=="J"
replace JEL = "K Law and econ." if JEL=="K"
replace JEL = "L Industrial org." if JEL=="L"
replace JEL = "M Marketing, accounting" if JEL=="M"
replace JEL = "N Economic history" if JEL=="N"
replace JEL = "O Development" if JEL=="O"
replace JEL = "P Economic systems" if JEL=="P"
replace JEL = "Q Agri., environment" if JEL=="Q"
replace JEL = "R Regional, transport" if JEL=="R"
replace JEL = "Y Miscellaneous" if JEL=="Y"
replace JEL = "Z Special topics" if JEL=="Z"

graph hbar (mean) _flesch_score if Year>=1987, over(JEL) ///
	name(femratio, replace) ///
	scheme(publishing-female) ///
	ytitle("") ///
	aspectratio(2, placement(left))
graph export "`pdf_path'/read_jel.pdf", replace
********************************************


********************************************
************* Gender representation by JEL. ***************
********************************************
use `article', clear
summarize FemRatio if Journal==1
local aer = round(r(mean)*100, 0.01)
summarize FemRatio if Journal==2
local eca = round(r(mean)*100, 0.01)
summarize FemRatio if Journal==3
local jpe = round(r(mean)*100, 0.01)
summarize FemRatio if Journal==4
local qje = round(r(mean)*100, 0.01)

use `author', clear
generate Fem = Sex==0
collapse (sum) Fem, by(Journal)
graph pie Fem, ///
	scheme(publishing-female) ///
	over(Journal) ///
	plabel(1 "{it:AER}" "`aer' %", size(large)) ///
	plabel(2 "{it: Econometrica}" "`eca' %", size(large)) ///
	plabel(3 "{it:JPE}" "`jpe' %", size(large)) ///
	plabel(4 "{it:QJE}" "`qje' %", size(large)) ///
	pie(1, color(pfblue)) ///
	pie(2, color(pfyellow)) ///
	pie(3, color(pfpink)) ///
	pie(4, color(pfteal)) ///
	legend(off)
graph export "`pdf_path'/journal.pdf", replace
********************************************

********************************************
************* Readability by year. ***************
********************************************
use `article', clear
collapse (mean) _flesch_score _fleschkincaid_score _gunningfog_score _smog_score _dalechall_score, by(Year)
tsset Year
keep if Year>1985
tssmooth ma ma_flesch_score=_flesch_score, window(5)
tssmooth ma ma_dalechall_score=_dalechall_score, window(5)
graph twoway ///
	(line ma_flesch_score Year, color(pfpink) lwidth(medium) yaxis(1)) ///
	(line ma_dalechall_score Year, color(pfteal) lwidth(medium) yaxis(2)) ///
	, xlabel(1990(5)2015) ///
	scheme(publishing-female) ///
	xtitle("") legend(off) ///
	ytitle("Flesch Reading Ease", axis(1)) ytitle("-1 ⨉ Dale-Chall", axis(2)) ///
	aspectratio(1.75, placement(west))
graph export "`pdf_path'/year.pdf", replace
********************************************
