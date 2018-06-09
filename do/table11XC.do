********************************************
************* Display Table 11. ************
********************************************
local title "\autoref{table11}, papers with at least 50\% female authors"
distinct ArticleID
#delimit ;
local note "
	Sample `r(ndistinct)' articles. Columns display estimates identical to those in~\autoref{table11}, except that female
	ratio has been replaced with a dummy variable equal to 1 if a weak majority (50% or more) of authors are female. (Papers with a minority—but positive—number of female authors are excluded.)
";
#delimit cr
estout est_4_none_Fem50 est_4_exclude_Fem50 est_4_nobirth_Fem50 est_4_nomom_Fem50 est_4_Fem50 est_4_90s_Fem50 est_4_jel_Fem50 using "`tex_path'/table11XC.tex", ///
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
	note("`note'") ///
	float
********************************************
