********************************************
***** Display % diff. male vs. female. *****
********************************************
matrix rownames `p' = `stats_varnames'
noisily estout matrix(`p', fmt(2)), ///
	title("Percent difference, male and female scores") ///
	label ///
	mlabels(none) ///
	collabels("% Difference")
********************************************

********************************************
************* Display Table 5. *************
********************************************
local title "Gender differences in readability, author-level analysis"
#delimit ;
local note "
	Sample `e(N)' observations (`N_g' authors). Figures from first-differenced, IV estimation of~\autoref{equation1}~
	\citep{Arellano1995,Blundell1998}. Female ratio (women): contemporaneous marginal effect of a paper's female
	co-author ratio for female authors (\(\beta_1\)); female ratio (men): analogous effect for male authors
	(\(\beta_1+\beta_2\)). \textit{z}-statistics for first-	and second-order autocorrelation in the first-differenced
	errors~\citep{Arellano1991}; null hypothesis no autocorrelation. Quality controls denoted by \(\text{\ding{51}}^1\)
	include citation count and \(\text{max. }T_j\) fixed effects. Regressions weighted by \(1/N_j\); standard errors
	adjusted for two-way clustering on editor and author (in parentheses). 
";
#delimit cr
estout est_FemRatio_* using "`tex_path'/table5.tex", style(publishing-female_latex) ///
stats(ar1 ar2 Nj editor journal year jnlyr inst qual native, fmt(2) ///
	labels("\mcol{\rule{0pt}{4ex}\textit{\(z\)-test for no serial correlation}} \\\${n}Order 1" "Order 2" ///
	 	"\midrule${n}\(N_j\)" "Editor effects" "Journal effects" ///
		"Year effects" "Journal#Year effects" "Institution effects" "Quality controls" "Native speaker")) ///
varlabels(Female "Female ratio (women)" Male "Female ratio (men)" Interaction "Female ratio#male" ///
	L._stat_score "Lagged score", prefix("\mrow{4cm}{") suffix("}"))
latextable, ///
	title("`title'") ///
	cellwidth("p{4cm}S@{}S@{}S@{}S@{}S@{}") ///
	star(all) ///
	header("`latex_header'") ///
	note("`note'")
noisily estout_display est_*, style(publishing-female_smcl) ///
	stats(ar1 ar2 Nj editor journal year jnlyr inst qual native, fmt(2) ///
		labels("z Order 1" "z Order 2" "N" "Editor effects" "Journal effects" "Year effects" "Journal#Year effects" ///
			"Institution effects" "Quality controls" "Native speaker")) ///
	varlabels(Female "Female ratio (women)" Male "Female ratio (men)" Interaction "Female ratio#male" ///
		L._stat_score "Lagged score") ///
	mlabels(`table_header') ///
	title("Table 6: `title'") ///
	note("`note'") ///
	collabels(none)
********************************************
