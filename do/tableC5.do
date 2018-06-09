********************************************
************ Display Table C.5. ************
********************************************
local title "~\autoref{table7} (first column), full output"
#delimit ;
local note "
	Sample `nbernonblind' NBER working papers; `pubnonblind' published articles. Estimates exclude `nberblind'
	pre-internet double-blind reviewed articles (see~\autoref{Footnote51}). Coefficients from OLS regression of
	~\autoref{equation2}. First row is the coefficient on \(R_{jW}\); second row is \(\beta_{1P}\), and corresponds to
	results presented in the first column of~\autoref{table7}. Coefficients on quality controls (citation counts,
	\(\text{max. }T_j\) and \(\text{max. }t_j\)) also shown. Standard errors clustered on editor (in parentheses).
";
#delimit cr
estout reg_*_FemRatio using "`tex_path'/tableC5.tex", style(publishing-female_latex) ///
	cells(b(star fmt(3)) se(fmt(3))) ///
	stats(editor journal year jnlyr, labels("Editor effects" "Journal effects" "Year effects" "Year#Journal effects")) ///
	varlabels(1.NativeEnglish "Native speaker" nber_score "\(R_{jW}\)", prefix("\mrow{4cm}{") ///
		suffix("}")) ///
	prefoot("\midrule") ///
	keep(nber_score FemRatio Maxt MaxT CiteCount 1.NativeEnglish)
latextable, ///
	title("`title'") ///
	star(all) ///
	cellwidth("p{3cm}S@{}S@{}S@{}S@{}S@{}") ///
	header("`latex_header'") ///
	note("`note'") ///
	float ///
	sisetup("round-precision=3")
********************************************
