********************************************
************ Display Table C.14. ***********
********************************************
local title "Mahalanobis matching, list of matched pairs"
#delimit ;
local note "
	Table lists the names of the matched pairs from replicating the analysis in Figure 5 but using Mahalanobis matching to match authors.
	In each panel, female members are listed first; male members second.
";
#delimit cr
listtex AuthorName* using "`tex_path'/tableC14XA.tex", replace end("\\")
latextable using "`tex_path'/tableC14XA.tex", ///
	title("`title'") ///
	cellwidth("llll") ///
	header("\multicolumn{2}{c}{Matched pairs}&\multicolumn{2}{c}{Matched pairs}\\\cmidrule(lr){1-2}\cmidrule(lr){3-4}Female&Male&Female&Male") ///
	label("tableC14XA") ///
	note(`"`note'"') ///
	colnum(4) ///
	long
********************************************
