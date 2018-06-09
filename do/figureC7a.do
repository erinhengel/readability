include master
use `nber', clear

graph twoway ///
	(histogram nber_word_count if FemRatio==0, color("`blue'%30") lwidth(vvthin)) ///
	(histogram nber_word_count if FemRatio>0, color("`pink'%30") lwidth(vvthin)), ///
	name(nber, replace) ///
	scheme(publishing-female) ///
	legend(off) ///
	ytitle("") ///
	xtitle("Draft word count")
graph twoway ///
	(histogram _word_count if FemRatio==0, color("`blue'%30") lwidth(vvthin)) ///
	(histogram _word_count if FemRatio>0, color("`pink'%30") lwidth(vvthin)), ///
	name(pub, replace) ///
	scheme(publishing-female) ///
	legend(pos(3) order(1 "Male" 2 "Female")) ///
	ytitle("") ///
	xtitle("Published word count")
graph combine nber pub, xcommon ycommon commonscheme scheme(publishing-female)
graph export "`pdf_path'/figureC7a.pdf", replace
