********************************************
************* Display Table 8. *************
********************************************
local title "Gender gap in readability at increasing \(t\)"
#delimit ;
local note "
	\(\beta_1\) from FGLS estimation of~\autoref{equation1} without lagged dependent variable. First column restricts
	sample to authors' first publication in the data (\(t=1\)), second column to their second (\(t=2\)), \textit{etc.}
	Regressions weighted by \(1/N_j\) (see~\autoref{authorlevel}). Standard errors (in parentheses) adjusted for two-way
	clustering (editor and author) and cross-model correlation. Final column estimates from an unweighted
	population-averaged regression; error correlations specified by an auto-regressive process of order one and standard
	errors (in parentheses) adjusted for one-way clustering on author. Quality controls denoted by
	\(\text{\ding{51}}^1\) include citation count and \(\text{max. }T_j\) fixed effects; \(\text{\ding{51}}^4\) includes
	citation count, only.
	";
#delimit cr
estout reg_FemRatio_* using "`tex_path'/table8.tex", style(publishing-female_latex) ///
	stats(obs Nj editor journal year jnlyr inst qual native, labels("No. observations" "\(N_j\)" "Editor effects" ///
		"Journal effects" "Year effects" "Journal#Year effects" "Institution effects" "Quality controls" ///
		"Native speaker")) ///
	prefoot("\midrule")
latextable, ///
	title("`title'") ///
	star(all) ///
	cellwidth("p{3cm}S@{}S@{}S@{}S@{}S@{}S@{}S@{}") ///
	header("&{\(t=1\)}&{\(t=2\)}&{\(t=3\)}&{\(t=4\text{--}5\)}&{\(t\ge6\)}&{All}") ///
	note(`"`note'"')
noisily estout_display reg_*, style(publishing-female_smcl) ///
	stats(obs Nj editor journal year jnlyr inst qual native, labels("No. observations" "N" "Editor effects" ///
		"Journal effects" "Year effects" "Journal#Year effects" "Institution effects" "Quality controls" ///
		"Native speaker")) ///
	title("Table 10: `title'") ///
	collabels(none) ///
	mlabels("t=1" "t=2" "t=3" "t=4–5" "t≥6" "All") ///
	note("`note'", width(125))
********************************************
