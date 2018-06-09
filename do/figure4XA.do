********************************************
************* Display Figure 4. ************
********************************************
#delimit ;
local note "
	Estimates identical to those in Figure 5, except that a Mahalanobis distance is used to generate matched pairs.
	Blue bars represent (unweighted) matched pairs in which the man satisfies Conditions 1 and 2; pink bars are pairs in
	which the woman does. Estimated density functions drawn in grey, weighted by frequency observations are used in a
	match.
";

#delimit cr
local note = ustrregexra(`"{it:Notes.} `note'"', "\s+", " ")
wordwrap `"`note'"', length(42)
local note
foreach line in "`r(text)'" {
	local note `"`note' `"{fontface "Adobe Caslon Pro"}`line'"'"'
}
foreach stat in `stats' {
	summarize _`stat'_Ds1, meanonly
	local min = -1 * max(abs(`r(min)'), abs(`r(max)'))
	local width = abs(`min') / 5
	graph twoway ///
		(histogram _`stat'_Ds1 if _`stat'_D==1, start(0) width(`width') frequency color("`pink'%60") lwidth(none) ///
			yaxis(2) ylabel(,format(%4.3f))) ///
		(histogram _`stat'_Ds1 if _`stat'_D==0, start(`min') width(`width') frequency color("`blue'%60") lwidth(none) ///
			yaxis(2)) ///
		(kdensity _`stat'_Ds1 [aw=_weight1], range(`min' `=abs(`min')') color(gs6) lwidth(vthin) yaxis(1) yscale(alt)), ///
		scheme(publishing-female) ///
		title("`_`stat'_title'", size(small) color(gray)) ///
		yscale(off axis(2)) ///
		ytitle("") ///
		xtitle("") ///
		legend(off) ///
		name(`stat', replace)
}
twoway ///
	(scatteri 0.99 0.1 `"Pairs suggesting discrimination against:"', msymbol(i) mlabcolor("116 116 116")) ///
	(scatteri 0.9 0.35 `"Men"', color("`blue'%60") mlabcolor("116 116 116")) ///
	(scatteri 0.9 0.55 `"Women"', color("`pink'%60") mlabcolor("116 116 116")) ///
	(scatteri 0 0 "" 1 1 "", msymbol(i)), ///
	scheme(publishing-female) ///
	text(0.19 0.62 `note', just(left) placement(north) size(medsmall)) ///
	plotregion(lpattern(blank)) legend(off) ///
	ylabel("") ///
	xlabel("") ///
	ytitle("") ///
	xtitle("") ///
	yscale(off) ///
	xscale(off) ///
	name(blank, replace)
graph combine `stats' blank, ///
	scheme(publishing-female) ///
	commonscheme
graph export "`pdf_path'/figure4XA.pdf", replace
********************************************
