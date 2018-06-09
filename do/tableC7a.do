********************************************
************* Display Table 7. *************
********************************************
local title "\autoref{table7}, restricted to abstracts below journals' official word limits"
distinct ArticleID if !Blind&BelowAbstractLen
local nbernonblind = r(N)
local pubnonblind = r(ndistinct)
distinct ArticleID if Blind&BelowAbstractLen
local nberblind = r(N)
local pubblind = r(ndistinct)
#delimit ;
local note "
	Sample `nbernonblind' NBER working papers; `pubnonblind' published articles. 
	Estimates are identical to those in~\autoref{table7}, except that the sample includes only articles whose NBER abstracts
	fell below the official minimum word limit of the respective journal in which it was published.
	";
#delimit cr
estout reg_FemRatio su_*_FemRatio fe_FemRatio using "`tex_path'/tableC7a.tex", style(publishing-female_latex) ///
	stats(editor journal year jnlyr qual native, labels("Editor effects" "Journal effects" "Year effects" ///
		"Journal#Year effects" "Quality controls" "Native speaker")) ///
	prefoot("\midrule")
latextable, ///
	title("`title'") ///
	star(all) ///
	cellwidth("p{4cm}S@{}S@{}S@{}S@{}S@{}") ///
	header("&{OLS}&\multicolumn{3}{c}{{FGLS}}&{OLS}\\\cmidrule(lr){2-2}\cmidrule(lr){3-5}\cmidrule(lr){6-6}&{\crcell[b]{Published\\[-0.1cm]article}}&{{\crcell[b]{Working\\[-0.1cm]paper}}}&{\crcell[b]{Published\\[-0.1cm]article}}&{Difference}&{\crcell[b]{Change\\[-0.1cm]in score}}") ///
	note(`"`note'"')
********************************************
