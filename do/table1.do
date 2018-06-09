********************************************
************* Display Table 1. *************
********************************************
local title "Article count, by journal and decade"
#delimit ;
local note "
	Included is every article published between January 1950 and December 2015 for which an English abstract was found
	(i) on journal websites or websites of third party digital libraries or (ii) printed in the article itself. Papers
	published in the May issue of \textit{AER} (\textit{Papers \& Proceedings}) are excluded. Final row and column
	display total article counts by journal and decade, respectively.
";
#delimit cr
estout matrix(`N', fmt(%9.0f)) using "`tex_path'/table1.tex", ///
	varlabels(, blist(Total "\midrule${n}")) ///
	replace ///
	style(tex) ///
	substitute(" ." "  ") ///
	mlabels(none) ///
	collabels(none)
latextable, ///
	title("`title'") ///
	sisetup("table-figures-decimal=0") ///
	cellwidth("p{1.5cm}SSSSS") ///
	header("{Decade}&{\textit{AER}}&{\textit{ECA}}&{\textit{JPE}}&{\textit{QJE}}&{Total}") ///
	note("`note'")
noisily estout_display matrix(`N', fmt(%9.0fc)), ///
	mlabels(none) ///
	collabels("AER" "ECA" "JPE" "QJE" "Total") ///
	title("Table 1: `title'") ///
	substitute(" ." "  ") ///
	note("`note'", width(75))
********************************************
