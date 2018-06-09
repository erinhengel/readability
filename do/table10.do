********************************************
************* Display Table 10. ************
********************************************
local title "\(\underline D_{ik}\),~\autoref{equation11}"
#delimit ;
local note "
	Sample `nf' matched pairs (`nm' and `nf' distinct men and women, respectively). First and second panels display
	conditional means, standard deviations and observation counts of \(\underline D_{ik}\) (\autoref{equation11}) from
	subpopulations of matched pairs in which the woman or man, respectively, satisfies Conditions 1 and 2. Third panel
	displays mean \(\underline D_{ik}\) over all observations. To account for the 30--40 percent of pairs for which
	~\autoref{Theorem1} is inconclusive, (1) sets \(\underline D_{ik}=0\), while (2) sets
	\(\underline D_{ik}=\widehat R_{i3}-\widehat R_{k3}\) if \(\widehat R_{i3}<\widehat R_{k3}\) (\(i\) female, \(k\)
	male) and zero, otherwise. Male scores are subtracted from female scores; \(\underline D_{ik}\) is positive in panel
	one and negative in panel two. \(\underline D_{ik}\) weighted by frequency observations are used in a match;
	degrees-of-freedom corrected standard errors in parentheses (panel three, only).
";
#delimit cr
local header "&\multicolumn{3}{c}{{\crcell[b]{Discrimination against\\[-0.1cm]women (\(\underline{D}_{ik}>0\))}}}&\multicolumn{3}{c}{{\crcell[b]{Discrimination against\\[-0.1cm]men (\(\underline{D}_{ik}<0\))}}}&\multicolumn{2}{c}{{\crcell[b]{Mean, all\\[-0.1cm]observations}}}\\\cmidrule(lr){2-4}\cmidrule(lr){5-7}\cmidrule(lr){8-9}&{{Mean}}&{{S.D.}}&{{\(N\)}}&{{Mean}}&{{S.D.}}&{{\(N\)}}&{{(1)}}&{{(2)}}"
local cellwidth "p{3cm}S[table-format=3.3]@{}S[table-format=3.3]@{}S[table-format=3.2]@{}S[table-format=4.3]@{}S[table-format=3.3]@{}S[table-format=3.1]@{}S@{}S@{}"
local cells cells("b(fmt(2) nostar pattern(1 1 0 0)) se(fmt(2) nopar pattern(1 1 0 0)) N(fmt(0) pattern(1 1 0 0)) b(star pattern(0 0 1 1))" ". . . se(fmt(2) par pattern(0 0 1 1))")
#delimit cr
estout df1 dm1 d21 d31 using "`tex_path'/table10.tex", style(publishing-female_latex) ///
	`cells' ///
	varlabels(`table_varlables')
latextable, ///
	title("`title'") ///
	cellwidth("`cellwidth'") ///
	star(all) ///
	header("`header'") ///
	note("`note'")
noisily estout_display df1 dm1 d21 d31, style(publishing-female_smcl) ///
	`cells' ///
	mlabels(none) ///
	mgroups("Women" "Men" "Means", pattern(1 1 0 1 0)) ///
	collabels("Mean" "S.D." "N") ///
	title("Table 10: `title'") ///
	modelwidth(10) ///
	note("`note'") ///
	varlabels(`table_varlables') ///
	varwidth(15)
********************************************
