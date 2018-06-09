********************************************
************ Display Table C.2. ************
********************************************
local title "\autoref{table4}, male effects"
#delimit ;
local note "
`obs1' articles in (1)--(5); `obs6' articles in (6); `obs7' articles---including 561 from \textit{AER Papers \&
	Proceedings} (see~\autoref{footnote34})---in (7). Figures correspond to the male effects from regression results
	presented in~\autoref{table4}. Effects estimated at a female ratio of zero and observed values for other
	co-variates. Quality controls denoted by \(\text{\ding{51}}^1\) include citation count and \(\text{max. }T_j\) fixed
	effects. Standard errors clustered on editor in parentheses.
";
#delimit cr
estout man_*_Editor using "`tex_path'/tableC2.tex", style(publishing-female_latex) ///
	cells(b(nostar fmt(3)) se(par fmt(3))) ///
	stats(editor journal year jnlyr inst qual native jel jel3, fmt(2) labels("Editor effects" "Journal effects" ///
		"Year effects" "Journal#Year effects" "Institution effects" "Quality controls" "Native speaker" ///
		"\textit{JEL} (primary) effects" "\textit{JEL} (tertiary) effects")) ///
	varlabels($label_list, prefix("\mrow{3cm}{") suffix("}")) ///
	prefoot("\midrule")
latextable, ///
	title("`title'") ///
	cellwidth("p{2.64cm}S@{}S@{}S@{}S@{}S@{}S@{}S@{}") ///
	header("&{(1)}&{(2)}&{(3)}&{(4)}&{(5)}&{(6)}&{(7)}") ///
	note("`note'") ///
	float
********************************************
