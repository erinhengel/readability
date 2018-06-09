********************************************
************ Display Table C.4. ************
********************************************
local title "\autoref{table5}, male effects"
#delimit ;
local note "
	Sample `=e(N)' observations (`N_g' authors). Figures correspond to the male effects from regression results
	presented in~\autoref{table5} (first-differenced, IV estimation of~\autoref{equation1},
	~\citet{Arellano1995,Blundell1998}). Effects estimated at a female ratio of zero and observed values for other
	co-variates. Quality controls denoted by \(\text{\ding{51}}^1\) include citation count and \(\text{max. }T_j\) fixed
	effects. Regressions weighted by \(1/N_j\); standard errors adjusted for two-way clustering on editor and author (in
	parentheses).
";
#delimit cr
estout male_* using "`tex_path'/tableC4.tex", style(publishing-female_latex) ///
	cells(b(nostar fmt(3)) se(par fmt(3))) ///
	stats(Nj editor journal year jnlyr inst qual native, fmt(2) ///
		labels("\midrule${n}\(N_j\)" "Editor effects" "Journal effects" "Year effects" "Journal#Year effects" ///
			"Institution effects" "Quality controls" "Native speaker")) ///
	varlabels(_cons "Male effect", prefix("\mrow{4cm}{") suffix("}"))
latextable, ///
	title("`title'") ///
	cellwidth("p{4cm}S@{}S@{}S@{}S@{}S@{}") ///
	header("`latex_header'") ///
	note("`note'") ///
	float
********************************************
