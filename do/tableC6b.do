********************************************
************* Display Table 4. *************
********************************************
local title "The impact of double-blind review on the readability gap in published articles"
count if Journal==1
#delimit ;
local note "
	Sample `=_N' articles in panel one; `r(N)' articles in panel two. Figures represent the marginal effect on female ratio for blinded and non-blinded review from an OLS
	regression on the relevant readability score. Quality controls denoted by \(\text{\ding{51}}^1\) include citation
	count and \(\text{max. }T_j\) fixed effects. Standard errors clustered on editor in parentheses. Quality controls denoted by
	\(\text{\ding{51}}^3\) includes \(\text{max. }t_j\), only (see~\autoref{Footnote46}).
";
#delimit cr
estout blindfull_* using "`tex_path'/tableC6b.tex", style(publishing-female_latex) ///
	stats(editor journal jnlyr qual native, fmt(2) labels("\midrule${n}Editor effects" "Journal effects" ///
		"Journal#Year effects" "Quality controls" "Native speaker")) ///
	varlabels(nonblind "Non-blind" blind "Blind" diff "Difference") ///
	eqlabels(none)
latextable, ///
	title("`title'") ///
	cellwidth("p{4cm}S@{}S@{}S@{}S@{}S@{}") ///
	star(all) ///
	float ///
	header("`latex_header'") ///
	note("`note'")
********************************************
