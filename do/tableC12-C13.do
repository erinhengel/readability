********************************************
*********** Display Table C.12. ************
********************************************
distinct AuthorID if `g'==0
local nf = r(ndistinct)
distinct AuthorID if `g'==1
local nm = r(ndistinct)
local title "Regression output generating \(\widehat R_{it}\)"
#delimit ;
local note "
	Sample `nf' female authors; `nm' male authors. Sample restricted to matched authors. See~\autoref{seumatching} for
	details on how matches were made. Regressions weighted by the frequency observations are used in a match. Standard
	errors in parentheses.
";
#delimit cr
estout est_flesch_0* est_flesch_12 est_fleschkincaid_0* est_fleschkincaid_12 using "`tex_path'/tableC12.tex", ///
	style(publishing-female_latex) ///
	varlabels(2.Journal "\textit{Econometrica}" 3.Journal "\textit{JPE}" 4.Journal "\textit{QJE}" _cons Constant)
latextable, ///
	title("`title'") ///
	sisetup("group-separator={}") ///
	cellwidth("p{2.5cm}SSSSSS") ///
	header("&\multicolumn{3}{c}{{Flesch Reading Ease}}&\multicolumn{3}{c}{{Flesch-Kincaid}}\\\cmidrule[0.01pt](lr){2-4}\cmidrule[0.01pt](lr){5-7}&\multicolumn{2}{c}{{Women}}&{{Men}}&\multicolumn{2}{c}{{Women}}&{{Men}}\\\cmidrule(lr){2-3}\cmidrule(lr){4-4}\cmidrule(lr){5-6}\cmidrule(lr){7-7}&{{\(t=1\)}}&{{\(t=3\)}}&{{\(t=3\)}}&{{\(t=1\)}}&{{\(t=3\)}}&{{\(t=3\)}}") ///
	note(`"`note'"') ///
	star(all) ///
	float
********************************************

********************************************
*********** Display Table C.13. ************
********************************************
estout est_gunningfog_0* est_gunningfog_12 est_smog_0* est_smog_12 est_dalechall_0* est_dalechall_12 using "`tex_path'/tableC13.tex", ///
	style(publishing-female_latex) ///
	varlabels(2.Journal "\textit{Econometrica}" 3.Journal "\textit{JPE}" 4.Journal "\textit{QJE}" _cons Constant)
latextable, ///
	title("`title'") ///
	sisetup("group-separator={}") ///
	cellwidth("p{2.5cm}SSSSSSSSS") ///
	header("&\multicolumn{3}{c}{{Gunning Fog}}&\multicolumn{3}{c}{{SMOG}}&\multicolumn{3}{c}{{Dale-Chall}}\\\cmidrule[0.01pt](lr){2-4}\cmidrule[0.01pt](lr){5-7}\cmidrule[0.01pt](lr){8-10}&\multicolumn{2}{c}{{Women}}&{{Men}}&\multicolumn{2}{c}{{Women}}&{{Men}}&\multicolumn{2}{c}{{Women}}&{{Men}}\\\cmidrule(lr){2-3}\cmidrule(lr){4-4}\cmidrule(lr){5-6}\cmidrule(lr){7-7}\cmidrule(lr){8-9}\cmidrule(lr){10-10}&{{\(t=1\)}}&{{\(t=3\)}}&{{\(t=3\)}}&{{\(t=1\)}}&{{\(t=3\)}}&{{\(t=3\)}}&{{\(t=1\)}}&{{\(t=3\)}}&{{\(t=3\)}}") ///
	note(`"`note'"') ///
	star(all) ///
	landscape
********************************************
