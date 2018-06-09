********************************************
************* Display Table 4. *************
********************************************
local title "The impact of double-blind review after the internet"
distinct ArticleID if !Blind&Year>1997
local nberN = r(N)
local pubN = r(ndistinct)
#delimit ;
local note "
	Sample `nberN' NBER working papers; `pubN' published articles. Columns displays the marginal effect on female ratio
	for papers undergoing non-blinded review (\(\beta_{1P}\)) and blinded review (\(\beta_{1P}+\beta_{3P}\))
	from an OLS estimation of~\autoref{equation3a}. Standard errors clustered by year in parentheses. Quality controls denoted by
	\(\text{\ding{51}}^3\) includes \(\text{max. }t_j\), only (see~\autoref{Footnote46}).
";
#delimit cr
estout semiblind_* using "`tex_path'/tableC6a.tex", style(publishing-female_latex) ///
	stats(editor journal jnlyr qual native, fmt(2) labels("\midrule${n}Editor effects" "Journal effects" ///
		"Journal#Year effects" "Quality controls" "Native speaker")) ///
	varlabels(nonblind "Non-blind" semiblind "Blind post-internet" diff "Difference") ///
	eqlabels(none)
latextable, ///
	title("`title'") ///
	cellwidth("p{4cm}S@{}S@{}S@{}S@{}S@{}") ///
	star(all) ///
	float ///
	header("`latex_header'") ///
	note("`note'")
********************************************
