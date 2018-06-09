********************************************
************ Display Table C.17. ***********
********************************************
local title "Mean \(\widehat R_{k3}\) (men)"
#delimit ;
local note "
	Sample `nf' matched pairs (`nm' and `nf' distinct men and women, respectively). Figures correspond to the \(t=3\)
	reconstructed readability scores for men. \(\widehat R_{i3}\) weighted by frequency observations are used in a
	match; degrees-of-freedom corrected standard errors in parentheses.
";
#delimit cr
estout R_* using "`tex_path'/tableC17.tex", style(publishing-female_latex) ///
	cells(b(nostar fmt(3)) se(fmt(3))) ///
	varlabels(c1 "\(\widehat R_{k3}\) (men)")
latextable, ///
	title("`title'") ///
	cellwidth("p{3cm}S@{}S@{}S@{}S@{}S@{}") ///
	header("`latex_header'") ///
	note("`note'") ///
	float
********************************************
