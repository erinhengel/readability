********************************************
************* Display Table 10. ************
********************************************
local title "\autoref{table10}, Mahalanobis matching"
#delimit ;
local note "
	Sample `nf' matched pairs (`nm' and `nf' distinct men and women, respectively). Table displays estimates identical to those in~\autoref{table10}, except that
	a Mahalanobis distance is used to generate matched pairs.
	";
#delimit cr
local header "&\multicolumn{3}{c}{{\crcell[b]{Discrimination against\\[-0.1cm]women (\(\underline{D}_{ik}>0\))}}}&\multicolumn{3}{c}{{\crcell[b]{Discrimination against\\[-0.1cm]men (\(\underline{D}_{ik}<0\))}}}&\multicolumn{2}{c}{{\crcell[b]{Mean, all\\[-0.1cm]observations}}}\\\cmidrule(lr){2-4}\cmidrule(lr){5-7}\cmidrule(lr){8-9}&{{Mean}}&{{S.D.}}&{{\(N\)}}&{{Mean}}&{{S.D.}}&{{\(N\)}}&{{(1)}}&{{(2)}}"
local cellwidth "p{3cm}S[table-format=3.3]@{}S[table-format=3.3]@{}S[table-format=3.2]@{}S[table-format=4.3]@{}S[table-format=3.3]@{}S[table-format=3.1]@{}S@{}S@{}"
local cells cells("b(fmt(2) nostar pattern(1 1 0 0)) se(fmt(2) nopar pattern(1 1 0 0)) N(fmt(0) pattern(1 1 0 0)) b(star pattern(0 0 1 1))" ". . . se(fmt(2) par pattern(0 0 1 1))")
#delimit cr
estout df1 dm1 d21 d31 using "`tex_path'/table10XA.tex", style(publishing-female_latex) ///
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
