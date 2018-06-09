local fpath "~/Dropbox/Readability/draft/pdf"

preserve

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
graph export "`fpath'/read_jel.pdf", replace
	
restore
