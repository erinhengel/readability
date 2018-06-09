********************************************
************* Display Figure 1. ************
********************************************
graph twoway ///
	(rcap ll ul jel_id if eq==1, horizontal lwidth(vthin) msize(tiny) color("`pink'")) ///
	(scatter jel_id b if eq==1, msymbol(O) msize(medium) color("`pink'")) ///
	, xline(0, lcolor(gray) lwidth(vthin) lpattern(dash)) ///
	xline(`=`A'[1,1]', lcolor("`pink'") lwidth(vthin)) ///
	xscale(lcolor(gray)) ///
	yscale(lcolor(gray)) ///
	legend(off) ///
	xlabel(, labcolor(gray) tlcolor(gray)) ///
	ylabel(1/`=_N/2', labcolor(gray) tlcolor(gray) valuelabel angle(0) nogrid) ///
	ytitle("") ///
	title("Female ratio, by {it:JEL}", size(medium) color(gray)) ///
	name(eq1)
graph twoway ///
	(rcap ll ul jel_id if eq==2, horizontal lwidth(vthin) msize(tiny) color("`pink'")) ///
	(scatter jel_id b if eq==2, msymbol(O) msize(medium) color("`pink'")) ///
	, xline(0, lcolor(gray) lwidth(vthin) lpattern(dash)) ///
	xscale(lcolor(gray)) ///
	yscale(off) ///
	legend(off) ///
	xlabel(, labcolor(gray) tlcolor(gray)) ///
	ylabel(, nogrid) ///
	title("Female ratio × {it:JEL}", size(medium) color(gray)) ///
	fxsize(55) ///
	name(eq2)
graph combine eq1 eq2, ///
	ycommon ///
	xcommon ///
	scheme(publishing-female) ///
	commonscheme ///
	b2title("-1 × Dale-Chall", bexpand color(gray) size(vsmall) justification(right)) ///
	graphregion(margin(zero))
graph export "`pdf_path'/figure1.pdf", replace
********************************************
