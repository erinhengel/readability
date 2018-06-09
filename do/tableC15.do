********************************************
************ Display Table C.15. ***********
********************************************
local title "\(D_{ik}\),~\autoref{equation12}"
#delimit ;
local note "
	Sample `nf' matched pairs (`nm' and `nf' distinct men and women, respectively). First and second panels display
	conditional means, standard deviations and observation counts of \(\underline D_{ik}\) (\autoref{equation12}) from
	subpopulations of matched pairs in which the woman or man, respectively, satisfies Conditions 1 and 2. Third panel
	displays mean \(\underline D_{ik}\) over all observations. To account for the 30--40 percent of pairs for which
	~\autoref{Theorem1} is inconclusive, (1) sets \(\underline D_{ik}=0\), while (2) sets
	\(\underline D_{ik}=\widehat R_{i3}-\widehat R_{k3}\) if \(\widehat R_{i3}<\widehat R_{k3}\) (\(i\) female, \(k\)
	male) and zero, otherwise. Male scores are subtracted from female scores; \(\underline D_{ik}\) is positive in panel
	one and negative in panel two. \(\underline D_{ik}\) weighted by frequency observations are used in a match;
	degrees-of-freedom corrected standard errors in parentheses (panel three, only).
";
#delimit cr
estout df2 dm2 d22 d32 using "`tex_path'/tableC15.tex", style(publishing-female_latex) ///
	`cells' ///
	varlabels(`table_varlables')
latextable, ///
	title("`title'") ///
	cellwidth("`cellwidth'") ///
	star(all) ///
	header("`header'") ///
	note("`note'") ///
	float
********************************************
