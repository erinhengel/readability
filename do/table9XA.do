********************************************
************* Display Table 9. *************
********************************************
local title "\autoref{table9}, Mahalanobis Matching"
#delimit ;
local note "
	Sample `nf' matched pairs (`nm' and `nf' distinct men and women, respectively). Table displays estimates identical to those
	in~\autoref{table9}, except that a Mahalanobis distance is used to generate matched pairs.
";
#delimit cr
estout D_* using "`tex_path'/table9XA.tex", style(publishing-female_latex) ///
	cells(b(star fmt(3)) se(fmt(3))) ///
	varlabels( ///
		dg "\quad \(\widehat R_{i3}-\widehat R_{k3}\)" ///
		dt_female "\quad \(\widehat R_{i3}-\widehat R_{i1}\) (women)" ///
		dt_male "\quad \(\widehat R_{k3}-\widehat R_{k1}\) (men)" ///
		, blist( ///
			dg "\multicolumn{6}{l}{Condition 1}\\\${n}" ///
			dt_female "\midrule\multicolumn{6}{l}{Condition 2}\\\${n}"))
latextable, ///
	title("`title'") ///
	cellwidth("p{3.5cm}S@{}S@{}S@{}S@{}S@{}") ///
	star(all) ///
	sisetup("table-format=5.4,round-precision=3") ///
	header("`latex_header'") ///
	note("`note'") ///
	float
********************************************
