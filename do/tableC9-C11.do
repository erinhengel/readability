********************************************
************ Display Table C.9. ************
********************************************
local title "Co-variate post-match balance when \(\underline D_{ik}\ne0\)"
#delimit ;
local note "
	Sample restricted to authors with three or more publications. First panel shows pre-match summary statistics.
	\(t\)-values for differences reported in columns four and seven.
";
#delimit cr
tempname b
matrix `b' = (`b_flesch' , `b_fleschkincaid')
estout matrix(`b', fmt(2)) using "`tex_path'/tableC9.tex", style(tex) ///
	label ///
	mlabels(none) ///
	collabels(none) ///
	varlabels(, ///
		prefix("\quad ") ///
		blist(AuthorOrderBin1 "\multicolumn{9}{l}{\textbf{Fraction of articles per author ordering}}\\\${n}" ///
			Journal1 "\multicolumn{9}{l}{\textbf{Fraction of articles per journal}}\\\${n}" ///
			Decade1 "\multicolumn{9}{l}{\textbf{Fraction of articles per decade}}\\\${n}" ///
			JEL_A "\multicolumn{9}{l}{\textbf{Fraction of articles per \textit{JEL} code}}\\\${n}") ///
		elist(meanYear "${n}\midrule" Journal4 "${n}\midrule" Decade7 "${n}\midrule")) ///
	substitute(.\\ \\ .& &) ///
	replace
latextable, ///
	title("`title'") ///
	sisetup("group-separator={}") ///
	cellwidth("p{3.55cm}S@{}S@{}S@{}S@{}S@{}S@{}S@{}S@{}") ///
	header("&\multicolumn{4}{c}{{Flesch Reading Ease}}&\multicolumn{4}{c}{{Flesch Kincaid}}\\\cmidrule(lr){2-5}\cmidrule(lr){6-9}&\multicolumn{2}{c}{{Discrimination}}&&&\multicolumn{2}{c}{{Discrimination}}&&\\\cmidrule[0.01pt](lr){2-3}\cmidrule[0.01pt](lr){6-7}&{{\crcell[b]{Against\\[-0.1cm]women}}}&{{\crcell[b]{Against\\[-0.1cm]men}}}&{{Difference}}&{{\(t\)}}&{{\crcell[b]{Against\\[-0.1cm]women}}}&{{\crcell[b]{Against\\[-0.1cm]men}}}&{{Difference}}&{{\(t\)}}") ///
	note(`"`note'"') ///
	adjustwidth(-0.6cm) ///
	float
********************************************

********************************************
************ Display Table C.10. ***********
********************************************
matrix `b' = (`b_gunningfog' , `b_smog')
estout matrix(`b', fmt(2)) using "`tex_path'/tableC10.tex", style(tex) ///
	label ///
	mlabels(none) ///
	collabels(none) ///
	varlabels(, ///
		prefix("\quad ") ///
		blist(AuthorOrderBin1 "\multicolumn{9}{l}{\textbf{Fraction of articles per author ordering}}\\\${n}" ///
			Journal1 "\multicolumn{9}{l}{\textbf{Fraction of articles per journal}}\\\${n}" ///
			Decade1 "\multicolumn{9}{l}{\textbf{Fraction of articles per decade}}\\\${n}" ///
			JEL_A "\multicolumn{9}{l}{\textbf{Fraction of articles per \textit{JEL} code}}\\\${n}") ///
		elist(meanYear "${n}\midrule" Journal4 "${n}\midrule" Decade7 "${n}\midrule")) ///
	substitute(.\\ \\ .& &) ///
	replace
latextable, ///
	title("`title'") ///
	sisetup("group-separator={}") ///
	cellwidth("p{3.55cm}S@{}S@{}S@{}S@{}S@{}S@{}S@{}S@{}") ///
	header("&\multicolumn{4}{c}{{Gunning Fog}}&\multicolumn{4}{c}{{SMOG}}\\\cmidrule(lr){2-5}\cmidrule(lr){6-9}&\multicolumn{2}{c}{{Discrimination}}&&&\multicolumn{2}{c}{{Discrimination}}&&\\\cmidrule[0.01pt](lr){2-3}\cmidrule[0.01pt](lr){6-7}&{{\crcell[b]{Against\\[-0.1cm]women}}}&{{\crcell[b]{Against\\[-0.1cm]men}}}&{{Difference}}&{{\(t\)}}&{{\crcell[b]{Against\\[-0.1cm]women}}}&{{\crcell[b]{Against\\[-0.1cm]men}}}&{{Difference}}&{{\(t\)}}") ///
	note(`"`note'"') ///
	adjustwidth(-0.6cm) ///
	float
********************************************

********************************************
*********** Display Table C.11. ************
********************************************
estout matrix(`b_dalechall', fmt(2)) using "`tex_path'/tableC11.tex", style(tex) ///
	label ///
	mlabels(none) ///
	collabels(none) ///
	varlabels(, ///
		prefix("\quad ") ///
		blist(AuthorOrderBin1 "\multicolumn{9}{l}{\textbf{Fraction of articles per author ordering}}\\\${n}" ///
			Journal1 "\multicolumn{5}{l}{\textbf{Fraction of articles per journal}}\\\${n}" ///
			Decade1 "\multicolumn{5}{l}{\textbf{Fraction of articles per decade}}\\\${n}" ///
			JEL_A "\multicolumn{5}{l}{\textbf{Fraction of articles per \textit{JEL} code}}\\\${n}") ///
		elist(meanYear "${n}\midrule" Journal4 "${n}\midrule" Decade7 "${n}\midrule")) ///
	substitute(.\\ \\ .& &) ///
	replace
latextable, ///
	title("`title'") ///
	sisetup("group-separator={}") ///
	cellwidth("p{3.55cm}S@{}S@{}S@{}S@{}") ///
	header("&\multicolumn{4}{c}{{Dale-Chall}}\\\cmidrule(lr){2-5}&\multicolumn{2}{c}{{Discrimination}}&&\\\cmidrule[0.01pt](lr){2-3}&{{\crcell[b]{Against\\[-0.1cm]women}}}&{{\crcell[b]{Against\\[-0.1cm]men}}}&{{Difference}}&{{\(t\)}}") ///
	note(`"`note'"') ///
	float
********************************************
