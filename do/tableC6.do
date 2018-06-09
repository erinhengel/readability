********************************************
***** Display % diff. male vs. female. *****
********************************************
tempname p
matrix `p' = J(`=colsof(`B')',`=rowsof(`B')',0)
forvalues i=1/`=rowsof(`p')' {
	forvalues j=1/`=colsof(`p')' {
		matrix `p'[`i',`j'] = 100*`B'[`j',`i']/`M'[`j',`i']
	}
}
matrix rownames `p' = `stats_varnames'
noisily estout matrix(`p', fmt(2)), ///
	title("Percent difference, male and female scores") ///
	label ///
	mlabels(none) ///
	collabels("t=1" "t=2" "t=3" "t=4–5" "t≥6" "All")
********************************************

********************************************
************ Display Table C.6. ************
********************************************
local title "\autoref{table8}, equality test statistics"
#delimit ;
local note "
	\(\chi^2\) test statistics from Wald tests of \(\beta_1\) (\autoref{equation1}) equality across estimation results
	in~\autoref{table8}.
	";
#delimit cr
estout matrix(`Chi', fmt(3)) using "`tex_path'/tableC6.tex", style(tex) ///
	mlabels(none) ///
	label ///
	collabels(none) ///
	replace
latextable, ///
	title("`title'") ///
	sisetup("round-precision=3") ///
	cellwidth("p{3cm}S@{}S@{}S@{}S@{}S@{}S@{}") ///
	header("&{\(t=1\) vs. 2}&{\(t=1\) vs. 3}&{\(t=1\) vs. 4--5}&{\(t=1\) vs. \(\ge6\)}&{\(t=2\) vs. 3}") ///
	note(`"`note'"') ///
	float
********************************************
