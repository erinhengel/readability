********************************************
************* Display Table 7. *************
********************************************
local title "\autoref{table7}, controlling for \textit{JEL} codes"
distinct ArticleID if !Blind
local nbernonblind = r(N)
local pubnonblind = r(ndistinct)
distinct ArticleID if Blind
local nberblind = r(N)
local pubblind = r(ndistinct)
#delimit ;
local note "
	Sample `nbernonblind' NBER working papers; `pubnonblind' published articles. Estimates exclude `nberblind'
	pre-internet double-blind reviewed articles (see~\autoref{Footnote51}). Columns display estimates identical to those
	in the first four columns of~\autoref{table7}, except that fixed effects for \textit{JEL} codes are included.
";
#delimit cr
estout reg_jel su_2_jel su_1_jel su_3_jel using "`tex_path'/tableXD.tex", style(publishing-female_latex) ///
	stats(editor journal year jnlyr qual native jel, labels("Editor effects" "Journal effects" "Year effects" ///
		"Journal#Year effects" "Quality controls" "Native speaker" "\textit{JEL} (primary) effects")) ///
	prefoot("\midrule")
latextable, ///
	title("`title'") ///
	star(all) ///
	cellwidth("p{4cm}S@{}S@{}S@{}S@{}") ///
	header("&{OLS}&\multicolumn{3}{c}{{FGLS}}\\\cmidrule(lr){2-2}\cmidrule(lr){3-5}&{\crcell[b]{Published\\[-0.1cm]article}}&{{\crcell[b]{Working\\[-0.1cm]paper}}}&{\crcell[b]{Published\\[-0.1cm]article}}&{Difference}") ///
	note(`"`note'"') ///
	float
********************************************
