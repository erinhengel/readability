********************************************
*********** Display Table C.18. ************
********************************************
local title "\autoref{table11}, alternative thresholds for \(\text{mother}_j\)"
#delimit ;
local note "
	Sample `e(N)' articles. Coefficients from OLS estimation of~\autoref{equation13} at different age thresholds for
	\(\text{mother}_j\). In column one, \(\text{mother}_j\) equals one for papers authored exclusively by women with
	children younger than three; in column two, the age threshold is four; \textit{etc.} Column three corresponds to
	results presented in~\autoref{table11}. Standard errors clustered by year in parentheses.
";
#delimit cr
estout est_?_FemRatio est_??_FemRatio using "`tex_path'/tableC18.tex", style(publishing-female_latex) ///
	cells(b(star fmt(3)) se(fmt(3))) ///
	stats(editor year inst, labels("Editor effects" "Year effects" "Institution effects")) ///
	drop(*.Year *.MaxInst *.Editor) ///
	prefoot("\midrule")
latextable, ///
	title("`title'") ///
	star(all) ///
	sisetup("round-precision=3") ///
	cellwidth("p{4cm}SSSSS") ///
	header("&{\(\text{Age}<3\)}&{\(\text{Age}<4\)}&{\(\text{Age}<5\)}&{\(\text{Age}<10\)}&{\(\text{Age}<18\)}") ///
	note("`note'") ///
	float
********************************************
