********************************************
************ Display Table C.14. ***********
********************************************
local title "List of matched pairs"
#delimit ;
local note "
	Table lists the names of the matched pairs from~\autoref{seumatching}. In each panel, female members are listed
	first; male members second. Matches were made using a probit model with replacement. See~\autoref{seumatching} for
	details on the matching process.
";
#delimit cr
listtex AuthorName* using "`tex_path'/tableC14.tex", replace end("\\")
latextable using "`tex_path'/tableC14.tex", ///
	title("`title'") ///
	cellwidth("llll") ///
	header("\multicolumn{2}{c}{Matched pairs}&\multicolumn{2}{c}{Matched pairs}\\\cmidrule(lr){1-2}\cmidrule(lr){3-4}Female&Male&Female&Male") ///
	label("tableC14") ///
	note(`"`note'"') ///
	colnum(4) ///
	long
********************************************
