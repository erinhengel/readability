********************************************
************* Display Table 3. *************
********************************************
local title "Textual characteristics per sentence, by gender"
local cells cells("b(fmt(2) pattern(1 1 0)) b(star fmt(2) pattern(0 0 1))" "se(par fmt(2) pattern(1 1 0)) se(par fmt(2) pattern(0 0 1))")
#delimit ;
local note "
	Sample `e(N)' articles. Figures from an OLS regression of female ratio on each characteristic divided by sentence
	count. Male effects estimated at a ratio of zero; female effects estimated at a ratio of one. Robust standard errors
	in parentheses.
";
#delimit cr
estout sum_* using "`tex_path'/table3.tex", style(publishing-female_latex) `cells' ///
	varlabels($label_list, prefix("\mrow{4cm}{") suffix("}"))
latextable using "`r(fn)'", ///
	title("`title'") ///
	star(difference) ///
	cellwidth("p{4cm}S@{}S@{}S@{}") ///
	header("&{Men}&{Women}&{Difference}") ///
	note(`"`note'"')
noisily estout_display sum_*, style(publishing-female_smcl) `cells' ///
	title("Table 3: `title'") ///
	collabels(none) ///
	note("`note'", width(65)) ///
	mlabels("Men" "Women" "Difference")
********************************************
