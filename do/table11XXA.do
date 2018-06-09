********************************************
************* Display Table 11. ************
********************************************
local title "\autoref{table11}, submission year effects"
distinct ArticleID
#delimit ;
local note "
	Sample `r(ndistinct)' articles. Coefficients from OLS estimation of~\autoref{equation13}; (2) excludes papers
	authored only by women who gave birth (`birth_sample' articles) and/or had a child younger than five (`mom_sample'
	articles) at some point during peer review. Standard errors clustered by year in parentheses.
";
#delimit cr
estout est_4_none_FemRatio est_4_exclude_FemRatio est_4_nobirth_FemRatio est_4_nomom_FemRatio est_4_FemRatio est_4_90s_FemRatio est_4_jel_FemRatio using "`tex_path'/table11XXA.tex", ///
	style(publishing-female_latex) ///
	cells(b(star fmt(3)) se(fmt(3))) ///
	stats(editor year inst jel N, labels("Editor effects" "Submission year effects" "Institution effects" ///
		"\textit{JEL} (primary) effects" "No. observations")) ///
	drop(*.ReceivedYear *.MaxInst *.Editor JEL1_*, relax) ///
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
