********************************************
************* Display Table 8. *************
********************************************
local title "\autoref{table8}, papers authored 100\% by women"
#delimit ;
local note "
	Columns display estimates identical to those in Table 7, except that female ratio has been replaced with a dummy
	variable equal to 1 if all authors on a paper are female. (Papers written by authors of both genders are excluded.)
	";
#delimit cr
estout reg_Fem100_* using "`tex_path'/table8XC.tex", style(publishing-female_latex) ///
	stats(obs Nj editor journal year jnlyr inst qual native, labels("No. observations" "\(N_j\)" "Editor effects" ///
		"Journal effects" "Year effects" "Journal#Year effects" "Institution effects" "Quality controls" ///
		"Native speaker")) ///
	prefoot("\midrule")
latextable, ///
	title("`title'") ///
	star(all) ///
	cellwidth("p{3cm}S@{}S@{}S@{}S@{}S@{}S@{}S@{}") ///
	header("&{\(t=1\)}&{\(t=2\)}&{\(t=3\)}&{\(t=4\text{--}5\)}&{\(t\ge6\)}&{All}") ///
	note(`"`note'"')
********************************************
