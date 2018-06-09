********************************************
************* Display Table 11. ************
********************************************
local title "\autoref{table11}, papers with at least one female author"
distinct ArticleID
#delimit ;
local note "
	Sample `r(ndistinct)' articles. Columns display estimates identical to those in~\autoref{table11}, except that female
	ratio has been replaced with a dummy variable equal to 1 if at lease one author on a paper is female.
";
#delimit cr
estout est_4_none_Female est_4_exclude_Female est_4_nobirth_Female est_4_nomom_Female est_4_Female est_4_90s_Female est_4_jel_Female using "`tex_path'/table11XB.tex", ///
	style(publishing-female_latex) ///
	cells(b(star fmt(3)) se(fmt(3))) ///
	stats(editor year inst jel N, labels("Editor effects" "Year effects" "Institution effects" ///
		"\textit{JEL} (primary) effects" "No. observations")) ///
	drop(*.Year *.MaxInst *.Editor JEL1_*, relax) ///
	prefoot("\midrule")
latextable, ///
	title("`title'") ///
	star(all) ///
	adjustwidth(-0.085cm) ///
	sisetup("round-precision=3,table-format=3.4") ///
	cellwidth("p{2.64cm}SSSSSSS") ///
	header("&{(1)}&{(2)}&{(3)}&{(4)}&{(5)}&{(6)}&{(7)}") ///
	note("`note'")
********************************************
