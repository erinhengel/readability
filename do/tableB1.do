********************************************
**** Display % change from first score. ****
********************************************
local title "Percentage change from first score"
noisily estout matrix(`B', fmt(2)), ///
	mlabels(none) ///
	collabels(`table_header') ///
	eqlabels("% change first to mean score" "% change first to final score", span) ///
	title("{title:`title'}")
********************************************

********************************************
************ Display Table B.1. ************
********************************************
local title "Average first, mean and final paper scores"
estimates restore est_flesch
local cells cells(b(nostar fmt(2)) se(par fmt(2)))
local eqlabels "Average first paper score" "Average mean score" "Average final paper score"
#delimit ;
local note "
	Sample `e(N)' authors; includes only authors with three or more publications. Figures are average readability scores
	for authors' first, mean and last published articles. Grade-level scores have been multiplied by negative one (see
	~\autoref{measuringreadability}). Standard errors in parentheses.
";
#delimit cr
estout est_* using "`tex_path'/tableB1.tex", style(publishing-female_latex) ///
	`cells' ///
	eqlabels("`eqlabels'", span prefix("\multicolumn{6}{l}{\textbf{") suffix("}}")) ///
	varlabels(, elist(First:Men "${n}\midrule" Mean:Men "${n}\midrule") prefix("\quad "))
latextable, ///
	title("`title'") ///
	cellwidth("p{3cm}S@{}S@{}S@{}S@{}S@{}") ///
	header("`latex_header'") ///
	note("`note'") ///
	float
noisily estout_display est_*, style(publishing-female_smcl) ///
	`cells' ///
	title("Table B.3: `title'") ///
	mlabels(`table_header') ///
	eqlabels("`eqlabels'", span) ///
	note("`note'", width(100)) ///
	collabels(none)
********************************************
