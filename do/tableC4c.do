********************************************
************* Display Table 4. *************
********************************************
local title "\autoref{table4}, 50\% or more female-authored"
count if Journal==5 & !missing(Fem100)
#delimit ;
local note "
	`obs1' articles in (1)--(5); `obs6' articles in (6); `obs7' articles---including `r(N)' from \textit{AER Papers \&
	Proceedings} (see~\autoref{footnote34})---in (7). Figures represent the coefficient on a binary variable equal to 1
	for papers with 50 percent (or more) female authors. Papers with less than half but more
	than one female author are excluded. Quality controls denoted by \(\text{\ding{51}}^1\) include citation
	count and \(\text{max. }T_j\) fixed effects. Standard errors clustered on editor in parentheses.
";
#delimit cr
estout est_*_Editor using "`tex_path'/tableC4c.tex", style(publishing-female_latex) ///
	stats(editor journal year jnlyr inst qual native jel jel3, fmt(2) labels("Editor effects" "Journal effects" ///
		"Year effects" "Journal#Year effects" "Institution effects" "Quality controls" "Native speaker" ///
		"\textit{JEL} (primary) effects" "\textit{JEL} (tertiary) effects")) ///
	varlabels($label_list, prefix("\mrow{3cm}{") suffix("}")) ///
	prefoot("\midrule")
latextable, ///
	title("`title'") ///
	cellwidth("p{2.64cm}S@{}S@{}S@{}S@{}S@{}S@{}S@{}") ///
	header("&{(1)}&{(2)}&{(3)}&{(4)}&{(5)}&{(6)}&{(7)}") ///
	star(all) ///
	note("`note'") ///
	float
********************************************
