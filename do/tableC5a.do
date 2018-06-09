********************************************
************* Display Table 5. *************
********************************************
local title "\autoref{table5}, papers with at least one female author"
#delimit ;
local note "
	Sample `e(N)' observations (`N_g' authors). Figures from first-differenced, IV estimation of~\autoref{equation1}~
	\citep{Arellano1995,Blundell1998}. Female-authored (women): contemporaneous marginal effect on a dummy variable equal
	to 1 if the paper is authored by at least one woman (\(\beta_1\)); female-authored (men): analogous effect for male authors
	(\(\beta_1+\beta_2\)). \textit{z}-statistics for first-	and second-order autocorrelation in the first-differenced
	errors~\citep{Arellano1991}; null hypothesis no autocorrelation. Quality controls denoted by \(\text{\ding{51}}^1\)
	include citation count and \(\text{max. }T_j\) fixed effects. Regressions weighted by \(1/N_j\); standard errors
	adjusted for two-way clustering on editor and author (in parentheses). 
";
#delimit cr
estout est_Female_* using "`tex_path'/tableC5a.tex", style(publishing-female_latex) ///
stats(ar1 ar2 Nj editor journal year jnlyr inst qual native, fmt(2) ///
	labels("\mcol{\rule{0pt}{4ex}\textit{\(z\)-test for no serial correlation}} \\\${n}Order 1" "Order 2" ///
	 	"\midrule${n}\(N_j\)" "Editor effects" "Journal effects" ///
		"Year effects" "Journal#Year effects" "Institution effects" "Quality controls" "Native speaker")) ///
varlabels(Female "Female-authored (women)" Male "Female-authored (men)" Interaction "Female-authored#male" ///
	L._stat_score "Lagged score", prefix("\mrow{4cm}{") suffix("}"))
latextable, ///
	title("`title'") ///
	cellwidth("p{4cm}S@{}S@{}S@{}S@{}S@{}") ///
	star(all) ///
	header("`latex_header'") ///
	note("`note'")
********************************************
