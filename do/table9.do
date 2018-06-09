********************************************
************* Display Table 9. *************
********************************************
local title "\(\widehat R_{i3}-\widehat R_{k3}\) (Condition 1) and \(\widehat R_{i3}-\widehat R_{i1}\) (Condition 2)"
#delimit ;
local note "
	Sample `nf' matched pairs (`nm' and `nf' distinct men and women, respectively). \(\widehat R_{it}\) and
	\(\widehat R_{kt}\) are observation-specific readability scores estimated at female ratio equal to 0 for men, 1 for
	women and \(t=3\) median values of remaining \(t\)-dependent co-variates (see~\aref{appendixmatchingbalance} and
	text for more details). Figures are weighted by the frequency observations are used in a match. Degrees-of-freedom
	corrected standard errors in parentheses.
";
#delimit cr
estout D_* using "`tex_path'/table9.tex", style(publishing-female_latex) ///
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
	note("`note'")
noisily estout_display D_*, style(publishing-female_smcl) ///
	cells(b(star fmt(3)) se(fmt(3))) ///
	mlabels(`table_header') ///
	title("Table 9: `title'") ///
	note("`note'") ///
	collabels(none) ///
	varlabels(dt_female "Cond. 2: Ȓᵢ₃-Ȓᵢ₁ (women)" dt_male "Cond. 2: Ȓk₃-Ȓk₁ (men)" dg "Cond. 1: Ȓᵢ₃-Ȓk₃")
********************************************
