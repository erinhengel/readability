********************************************
************ Display Table C.3. ************
********************************************
local title "Journal readability, comparisons to \textit{AER}"
#delimit ;
local note "
	Figures are the estimated coefficients on the journal dummy variables from (2) in~\autoref{table4}. Each contrasts
	the readability of the journals in the left-hand column with the readability of \textit{AER}. Standard errors
	clustered on editor in parentheses.
";
#delimit cr
estout reg_*_Editor using "`tex_path'/tableC3.tex", style(publishing-female_latex) ///
	keep(2.Journal 3.Journal 4.Journal) ///
	varlabels(2.Journal "Econometrica", prefix("\textit{") suffix("}"))
latextable, ///
	title("`title'") ///
	cellwidth("p{2cm}S@{}S@{}S@{}S@{}S@{}") ///
	star(all) ///
	header("`latex_header'") ///
	note("`note'") ///
	float
********************************************
