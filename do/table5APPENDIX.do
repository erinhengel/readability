********************************************
************* Display Table 5. *************
********************************************
local title "Gender differences in readability, author-level analysis"
#delimit ;
local note "
	Sample `e(N)' observations (`e(N_g)' authors). Figures are identical to those in~\autoref{table5} except that
	that the readability scores were calculated using the R ``readability'' package.
";
#delimit cr
estout ALT_* using "`tex_path'/table5APPENDIX1.tex", style(publishing-female_latex) ///
stats(ar1 ar2 Nj editor journal year jnlyr inst qual native, fmt(2) ///
	labels("\mcol{\rule{0pt}{4ex}\textit{\(z\)-test for no serial correlation}} \\\${n}Order 1" "Order 2" ///
	 	"\midrule${n}\(N_j\)" "Editor effects" "Journal effects" ///
		"Year effects" "Journal#Year effects" "Institution effects" "Quality controls" "Native speaker")) ///
varlabels(Female "Female ratio (women)" Male "Female ratio (men)" Interaction "Female ratio#male" ///
	L._stat_score "Lagged score", prefix("\mrow{4cm}{") suffix("}"))
latextable, ///
	title("`title'") ///
	cellwidth("p{4cm}S@{}S@{}S@{}") ///
	star(all) ///
	header("&{\crcell[b]{Flesch-\\[-0.1cm] Kincaid}}&{\crcell[b]{Gunning\\[-0.1cm]Fog}}&{SMOG}\\") ///
	note("`note'")
********************************************
