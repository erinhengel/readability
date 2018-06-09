********************************************
************ Display Table C.8. ************
********************************************
count if T>=3 & Sex==0
local nf1 = `r(N)'
count if T>=3 & Sex==1
local nm1 = `r(N)'
local title "Pre- and post-matching summary statistics"
#delimit ;
local note "
	Sample restricted to authors with three or more publications. First panel shows pre-match summary statistics (`nf1'
	female authors, `nm1' male authors). Second panel shows post-match summary statistics (`nm' male authors).
	\(t\)-values for differences reported in columns four and seven.
";
#delimit cr
estout matrix(`b', fmt(2)) using "`tex_path'/tableC8.tex", style(tex) ///
	label ///
	mlabels(none) ///
	collabels(none) ///
	varlabels(, ///
		prefix("\quad ") ///
		blist(AuthorOrderBin1 "\multicolumn{8}{l}{\textbf{Fraction of articles per author ordering}}\\\${n}" ///
			Journal1 "\multicolumn{8}{l}{\textbf{Fraction of articles per journal}}\\\${n}" ///
			Decade1 "\multicolumn{8}{l}{\textbf{Fraction of articles per decade}}\\\${n}" ///
			JEL_A "\multicolumn{8}{l}{\textbf{Fraction of articles per \textit{JEL} code}}\\\${n}") ///
		elist(meanYear "${n}\midrule" Journal4 "${n}\midrule" Decade7 "${n}\midrule")) ///
	substitute(.\\ \\ .& &) ///
	replace
latextable, ///
	title("`title'") ///
	cellwidth("p{3.55cm}S[group-separator={}]@{}S[group-separator={}]@{}S@{}S@{}S[group-separator={}]@{}S@{}S@{}") ///
	header("&&\multicolumn{3}{c}{{Pre-match means}}&\multicolumn{3}{c}{{Post-match means}}\\\cmidrule(lr){3-5}\cmidrule(lr){6-8}&{{Women}}&{{Men}}&{{Difference}}&{{\(t\)}}&{{Men}}&{{Difference}}&{\(t\)}") ///
	note(`"`note'"') ///
	adjustwidth(-0.085cm) ///
	float
********************************************
