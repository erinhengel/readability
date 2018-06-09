********************************************
************* Display Table 12. ************
********************************************
local title "Readability of authors' \(t\)th publication (draft and final versions)"
distinct ArticleID
local an = r(ndistinct)
distinct NberID
local nn = r(ndistinct)
distinct AuthorID
#delimit ;
local note "
	Sample `r(N)' observations; `nn' and `an' distinct NBER working papers and published articles, respectively;
	`r(ndistinct)' distinct authors. Panel one displays magnitude of predicted \(R_{jP}-R_{jW}\) (the contemporaneous
	effect of peer review) for women and men over increasing publication count (\(t\)). Panel two estimates the marginal
	effect of an article's female ratio (\(\beta_1+\beta_2\)), separately for draft papers and published articles.
	Figures from FGLS estimate of~\autoref{equation14}. Quality controls denoted by \(\text{\ding{51}}^5\) include
	citation count and \(\text{max. }T_j\). Standard errors clustered by editor and robust to cross-model correlation
	in parentheses.
";
#delimit cr
estout est_* using "`tex_path'/table12.tex", style(publishing-female_latex) ///
	stats(editor journal year jnlyr qual native, labels("Editor effects" "Journal effects" "Year effects" ///
		"Journal#Year effects" "Quality controls" "Native speaker")) ///
	varlabels( ///
		women "\quad Women" ///
		men "\quad Men" ///
		diff "\textbf{Difference}" ///
		nber "\quad Draft paper" ///
		reg "\quad Published article" ///
		, blist( ///
			women "\multicolumn{6}{l}{\textbf{Predicted \(R_{jP}-R_{jW}\)}}\\\${n}" ///
			reg "\midrule\multicolumn{6}{l}{\textbf{Marginal effect of female ratio}}\\\${n}" ///
			diff "\midrule${n}")) ///
	prefoot("\midrule")
latextable, ///
	title("`title'") ///
	star(all) ///
	cellwidth("p{3cm}S@{}S@{}S@{}S@{}S@{}S@{}") ///
	header("&{\(t=1\)}&{\(t=2\)}&{\(t=3\)}&{\(t=4\text{--}5\)}&{\(t\ge6\)}") ///
	note(`"`note'"')
********************************************
