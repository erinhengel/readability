********************************************
************* Display Table 7. *************
********************************************
local title "\autoref{table7}, papers with at least one female author"
distinct ArticleID if !Blind
local nbernonblind = r(N)
local pubnonblind = r(ndistinct)
distinct ArticleID if Blind
local nberblind = r(N)
local pubblind = r(ndistinct)
distinct ArticleID if !Blind & Female==1
local femcount = `r(ndistinct)'
#delimit ;
local note "
	Sample `nbernonblind' NBER working papers; `pubnonblind' published articles (`femcount' female-authored). Estimates exclude `nberblind'
	pre-internet double-blind reviewed articles (see~\autoref{Footnote51}). Columns display estimates identical to those
	in~\autoref{table7}, except that female ratio has been replaced with a dummy variable equal to 1 if at lease one author on a paper is female.
";
#delimit cr
estout reg_Female su_*_Female fe_Female using "`tex_path'/tableXB.tex", style(publishing-female_latex) ///
	stats(editor journal year jnlyr qual native, labels("Editor effects" "Journal effects" "Year effects" ///
		"Journal#Year effects" "Quality controls" "Native speaker")) ///
	prefoot("\midrule")
latextable, ///
	title("`title'") ///
	star(all) ///
	cellwidth("p{4cm}S@{}S@{}S@{}S@{}S@{}") ///
	header("&{OLS}&\multicolumn{3}{c}{{FGLS}}&{OLS}\\\cmidrule(lr){2-2}\cmidrule(lr){3-5}\cmidrule(lr){6-6}&{\crcell[b]{Published\\[-0.1cm]article}}&{{\crcell[b]{Working\\[-0.1cm]paper}}}&{\crcell[b]{Published\\[-0.1cm]article}}&{Difference}&{\crcell[b]{Change\\[-0.1cm]in score}}") ///
	note(`"`note'"') ///
	float
********************************************
