********************************************
************* Display Figure 6. ************
********************************************
// preserve
svmat_rownames `b', names(col) generate(rname) rowname clear
generate version = real(regexs(1)) if regexm(rname, "^([0-9]+)")
generate female = real(regexs(1))-1 if regexm(rname, "predict#([0-9]+)")
generate t = real(regexs(1)) if regexm(rname, "at#([0-9]+)")
sort female t version
keep b version female t
reshape wide b, i(t female) j(version)
generate draft_label = "Draft" if t==2
generate final_label = "Final" if t==2
graph twoway ///
	(pcarrow b1 t b2 t if !female, color("`blue'") msize(small) lwidth(vthin) mangle(53) barbsize(vsmall) ///
		lpattern(shortdash)) ///
	(scatter b1 t if !female, color("`blue'") msize(small)) ///
	(pcarrow b1 t b2 t if female, color("`pink'") msize(small) lwidth(vthin) mangle(53) barbsize(vsmall) ///
		lpattern(shortdash) mlabel(final_label) headlabel mlabpos(12) mlabcolor(gray)) ///
	(scatter b1 t if female, color("`pink'") msize(small) mlabel(draft_label) mlabpos(6) mlabcolor(gray)) ///
	, legend(pos(5) ring(0) symxsize(1) cols(2) order(2 "Male" 4 "Female") color(gray) size(small)) ///
	title("Flesch Reading Ease", size(small) color(gray)) ///
	xtitle("{it:t} th article", color(gray) placement(seast) justification(right)) ///
	scheme(publishing-female) ///
	graphregion(margin(zero)) ///
	xlabel(1 "1" 2 "2" 3 "3" 4 "4-5" 5 "6+")
graph export "`pdf_path'/figure6.pdf", replace
// restore
exit
********************************************
