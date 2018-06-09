********************************************
************* Display correlation table. ************
********************************************
local title "Correlations between readability scores"
#delimit ;
local note "
	`=_N' articles. Table displays Spearman rank correaltions between readability scores.
";
#delimit cr
estout using "`tex_path'/tableCORR.tex", style(publishing-female_latex) ///
	unstack ///
	cells(rho(star fmt(2))) ///
	varlabels($label_list, prefix("\mrow{2.64cm}{") suffix("}")) ///
	posthead("\midrule") ///
	eqlabels("{\crcell[b]{Flesch\\[-0.1cm]Reading\\[-0.1cm]Ease}}" "{\crcell[b]{Flesch-\\[-0.1cm]Kincaid}}" ///
		"{\crcell[b]{Gunning\\[-0.1cm]Fog}}" "{SMOG}" "{\crcell[b]{Dale-\\[-0.1cm]Chall}}")
latextable, ///
	title("`title'") ///
	cellwidth("p{2.64cm}S@{}S@{}S@{}S@{}S@{}") ///
	star(all) ///
	float ///
	note("`note'")
noisily estout_display ., style(publishing-female_smcl) ///
	cells(rho(star fmt(2))) ///
	mlabels(none) ///
	note(`"`note'"') ///
	title("Table 4: `title'") ///
	numbers ///
	collabels(none) ///
	unstack ///
	nonumbers
********************************************