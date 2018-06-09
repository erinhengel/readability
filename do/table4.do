********************************************
***** Display % diff. male vs. female. *****
********************************************
matrix P=`P'
matrix rownames `P' = `stats_varnames'
matrix colnames `P' = 1 2 3 4 5 6
noisily estout matrix(`P', fmt(2)), ///
	title("Percent difference, male and female scores") ///
	label ///
	mlabels(none)
********************************************

********************************************
************* Display Table 4. *************
********************************************
local title "Gender differences in readability, article-level analysis"
#delimit ;
local note "
	`obs1' articles in (1)--(5); `obs6' articles in (6); `obs7' articles---including 561 from \textit{AER Papers \&
	Proceedings} (see~\autoref{footnote34})---in (7). Figures represent the coefficient on female ratio from an OLS
	regression on the relevant readability score. Quality controls denoted by \(\text{\ding{51}}^1\) include citation
	count and \(\text{max. }T_j\) fixed effects. Standard errors clustered on editor in parentheses.
";
#delimit cr
estout est_*_Editor using "`tex_path'/table4.tex", style(publishing-female_latex) ///
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
	note("`note'")
noisily estout_display est_*_Editor, style(publishing-female_smcl) ///
	stats(editor journal year jnlyr inst qual native jel jel3, labels("Editor effects" "Journal effects" "Year effects" ///
		"Journal#Year effects" "Institution effects" "Quality controls" "Native speaker" "JEL (primary) effects" ///
		"JEL (tertiary) effects")) ///
	mlabels(none) ///
	note(`"`note'"') ///
	title("Table 4: `title'") ///
	numbers ///
	collabels(none)
********************************************
