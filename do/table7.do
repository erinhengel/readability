********************************************
***** Display % caused by peer review. *****
********************************************
noisily estout matrix(`P', fmt(2)), ///
	title("Percent of gap caused in peer review") ///
	label ///
	mlabels(none) ///
	collabels("%")
********************************************

********************************************
************* Display Table 7. *************
********************************************
local title "The impact of peer review on the gender readability gap"
distinct ArticleID if !Blind
local nbernonblind = r(N)
local pubnonblind = r(ndistinct)
distinct ArticleID if Blind
local nberblind = r(N)
local pubblind = r(ndistinct)
#delimit ;
local note "
	Sample `nbernonblind' NBER working papers; `pubnonblind' published articles. Estimates exclude `nberblind'
	pre-internet double-blind reviewed articles (see~\autoref{Footnote51}). Column one displays coefficients on female
	ratio (\(\beta_{1P}\)) from estimating~\autoref{equation2} directly via OLS (see~\aref{appendixdraftcorr} for
	coefficients on \(R_{jW}\)); standard errors clustered by editor in parentheses. Columns two and three display
	\(\wt\beta_{1W}\) and \(\wt\beta_{1W}+\beta_{1P}\) from FGLS estimation of~\autoref{equation6} and
	~\autoref{equation7}, respectively; standard errors clusterd by year and robust to cross-model correlation in
	parentheses. Their difference (\(\beta_{1P}\)) is shown in column four. Column five displays \(\beta_{1P}\) from OLS
	estimation of~\autoref{equation3}; standard errors clustered by year in parentheses. Quality controls denoted by
	\(\text{\ding{51}}^2\) include citation count, \(\text{max. }T_j\) and \(\text{max. }t_j\); \(\text{\ding{51}}^3\)
	includes \(\text{max. }t_j\), only (see~\autoref{Footnote46}).
";
#delimit cr
estout reg_FemRatio su_*FemRatio fe_FemRatio using "`tex_path'/table7.tex", style(publishing-female_latex) ///
	stats(editor journal year jnlyr qual native, labels("Editor effects" "Journal effects" "Year effects" ///
		"Journal#Year effects" "Quality controls" "Native speaker")) ///
	prefoot("\midrule")
latextable, ///
	title("`title'") ///
	star(all) ///
	cellwidth("p{4cm}S@{}S@{}S@{}S@{}S@{}") ///
	header("&{OLS}&\multicolumn{3}{c}{{FGLS}}&{OLS}\\\cmidrule(lr){2-2}\cmidrule(lr){3-5}\cmidrule(lr){6-6}&{\crcell[b]{Published\\[-0.1cm]article}}&{{\crcell[b]{Working\\[-0.1cm]paper}}}&{\crcell[b]{Published\\[-0.1cm]article}}&{Difference}&{\crcell[b]{Change\\[-0.1cm]in score}}") ///
	note(`"`note'"')
noisily estout_display reg_FemRatio su_*FemRatio fe_FemRatio, style(publishing-female_smcl) ///
	stats(editor journal year jnlyr qual native, labels("Editor effects" "Journal effects" "Year effects" ///
		"Journal#Year effects" "Quality controls" "Native speaker")) ///
	title("Table 8: `title'") ///
	mlabels("Published article" "Working paper" "Published article" "Difference" "∆ score") ///
	note(`"`note'"', width(100)) ///
	mgroups("OLS" "FGLS" "OLS", pattern(1 1 0 0 1)) ///
	collabels(none)
********************************************
