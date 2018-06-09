********************************************
***** Display % diff. male vs. female. *****
********************************************
matrix rownames `p' = `nber_counts_varnames' `stats_varnames'
noisily estout matrix(`p', fmt(2)), ///
	title("Percent difference, male vs. female scores") ///
	label ///
	mlabels(none) ///
	collabels("Men" "Women" "Men vs. Women") ///
	varlabels(, blist(_wps_count "@hline${n}" _flesch_score "@hline${n}")) ///
	hlinechar({hline 1})
********************************************

********************************************
************* Display Table 6. *************
********************************************
local title "Textual characteristics, published papers vs. drafts"
local cells cells("b(fmt(2) pattern(1 1 0 1 1 0)) b(star fmt(3) pattern(0 0 1 0 0 1))" "se(par fmt(2) pattern(1 1 0 1 1 0)) se(par fmt(3) pattern(0 0 1 0 0 1))")
distinct ArticleID if FemRatio<0.5
local N1_m = r(ndistinct)
local N2_m = r(N)
distinct ArticleID if FemRatio>=0.5
local N1_f = r(ndistinct)
local N2_f = r(N)
#delimit ;
local note "
	Sample `N1_m' published articles authored by more than 50 percent men (`N2_m' NBER working papers); `N1_f' published
	articles authored by at least 50 percent women (`N2_f' NBER working papers). Figures are means of textual
	characteristics by sex for NBER working papers and published articles. Third and sixth columns subtract working
	paper figures (columns 1 and 4) from published article figures (columns 2 and 5) for men and women. Standard errors
	in parentheses.
";
#delimit cr
estout sum_* using "`tex_path'/table6.tex", style(publishing-female_latex) ///
	 `cells' ///
	varlabels(, prefix("\mrow{4cm}{") suffix("}") blist(_wps_count "\midrule${n}" _flesch_score "\midrule${n}"))
latextable, ///
	title("`title'") ///
	star(difference) ///
	sisetup("group-digits=false") ///
	cellwidth("p{4cm}S@{}S@{}S[round-precision=3]S@{}S@{}S[round-precision=3]") ///
	header("&\multicolumn{3}{c}{{Men}}&\multicolumn{3}{c}{{Women}}\\\cmidrule(lr){2-4}\cmidrule(lr){5-7}&{\crcell[b]{Working\\[-0.1cm]paper}}&{\crcell[b]{Published\\[-0.1cm]article}}&{Difference}&{\crcell[b]{Working\\[-0.1cm]paper}}&{\crcell[b]{Published\\[-0.1cm]article}}&{Difference}") ///
	note(`"`note'"')
noisily estout_display sum_*, style(publishing-female_smcl) ///
	`cells' ///
	mgroups("{ul:Men}" "{ul:Women}", pattern(1 0 0 1 0 0) span) ///
	mlabels("Working paper" "Published article" "Difference" "Working paper" "Published article" "Difference") ///
	collabels(none) ///
	note(`"`note'"', width(115)) ///
	title("Table 7: `title'") ///
	varlabels(, blist(_wps_count "@hline${n}" _flesch_score "@hline${n}"))
********************************************
