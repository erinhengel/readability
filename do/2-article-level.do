// quietly {
	********************************************
	********* Textual characteristics. *********
	********************************************
	use `article', clear
	tempname B SE
	foreach stat in `counts' {
		replace _`stat'_count = _`stat'_count / _sent_count
		regress _`stat'_count FemRatio, robust
		lincom _b[_cons] + _b[FemRatio]
		matrix `B' = (nullmat(`B') , (_b[_cons] \ r(estimate) \ -1 * _b[FemRatio]))
		matrix `SE' = (nullmat(`SE') , (_se[_cons] \ r(se) \ _se[FemRatio]))
	}
	tempname b se
	forvalues i=1/3 {
		matrix `b' = `B'[`i', 1...]
		matrix `se' = `SE'[`i', 1...]
		ereturn_post `b', se(`se') obs(`e(N)') dof(`e(df_r)') store(sum_`i') colnames(`counts_varnames')
	}
	include "`do_path'/table3"
	********************************************
	
	********************************************
	********* Article-level analysis. **********
	********************************************
	use `article_primary_jel', clear
	local jcode1
	foreach jel of varlist JEL1_* {
		local jcod1 "`jcode1' `jel'"
	}
	use `article_tertiary_jel_pp', clear
	local jcode3
	foreach jel of varlist JEL3_* {
		local jcode3 "`jcode3' `jel'"
	}
	foreach dvar in FemRatio Fem100 Female Fem50 {
		tempname p P b1 se1 b2 se2 b3 se3 b4 se4 b5 se5 b6 se6 b7 se7 bA1 seA1 bA2 seA2 bA3 seA3 bA4 seA4 bA5 seA5 bA6 seA6 mb1 mb2 mb3 mb4 mb5 mb6 mb7 ms1 ms2 ms3 ms4 ms5 ms6 ms7
		foreach stat in `stats' {
		
			* (1)
			use `article', clear
			reghdfe _`stat'_score `dvar', absorb(i.Journal i.Editor) vce(cluster Editor)
			matrix `b1' = (nullmat(`b1'), _b[`dvar'])
			matrix `se1' = (nullmat(`se1'), _se[`dvar'])
			local obs1 = e(N)
			local dof1 = e(df_r)
			if "`dvar'"=="FemRatio" {
				margins, at(`dvar'=(0 1)) post
				matrix `mb1' = (nullmat(`mb1'), _b[1._at])
				matrix `ms1' = (nullmat(`ms1'), _se[1._at])
				matrix `p' = 100 * abs((_b[1._at]-_b[2._at])/_b[1._at])
			}
		
			* (2)
			eststo reg_`stat'_Editor: reghdfe _`stat'_score `dvar', absorb(i.Journal i.Editor i.Year) vce(cluster Editor)
			matrix `b2' = (nullmat(`b2'), _b[`dvar'])
			matrix `se2' = (nullmat(`se2'), _se[`dvar'])
			local obs2 = e(N)
			local dof2 = e(df_r)
			if "`dvar'"=="FemRatio" {
				margins, at(`dvar'=(0 1)) post
				matrix `mb2' = (nullmat(`mb2'), _b[1._at])
				matrix `ms2' = (nullmat(`ms2'), _se[1._at])
				matrix `p' = (`p', 100 * abs((_b[1._at]-_b[2._at])/_b[1._at]))
			}
		
			* (3)
			reghdfe _`stat'_score `dvar', absorb(i.Journal##i.Year i.Editor) vce(cluster Editor)
			matrix `b3' = (nullmat(`b3'), _b[`dvar'])
			matrix `se3' = (nullmat(`se3'), _se[`dvar'])
			local obs3 = e(N)
			local dof3 = e(df_r)
			if "`dvar'"=="FemRatio" {
				margins, at(`dvar'=(0 1)) post
				matrix `mb3' = (nullmat(`mb3'), _b[1._at])
				matrix `ms3' = (nullmat(`ms3'), _se[1._at])
				matrix `p' = (`p', 100 * abs((_b[1._at]-_b[2._at])/_b[1._at]))
			}
		
			* (4)
			reghdfe _`stat'_score `dvar', absorb(i.Journal##i.Year i.Editor i.MaxInst) vce(cluster Editor)
			matrix `b4' = (nullmat(`b4'), _b[`dvar'])
			matrix `se4' = (nullmat(`se4'), _se[`dvar'])
			local obs4 = e(N)
			local dof4 = e(df_r)
			if "`dvar'"=="FemRatio" {
				margins, at(`dvar'=(0 1)) post
				matrix `mb4' = (nullmat(`mb4'), _b[1._at])
				matrix `ms4' = (nullmat(`ms4'), _se[1._at])
				matrix `p' = (`p', 100 * abs((_b[1._at]-_b[2._at])/_b[1._at]))
			}
		
			* (5)
			reghdfe _`stat'_score `dvar' asinhCiteCount, absorb(i.Journal##i.Year i.Editor i.MaxInst i.MaxT i.NativeEnglish) vce(cluster Editor)
			matrix `b5' = (nullmat(`b5'), _b[`dvar'])
			matrix `se5' = (nullmat(`se5'), _se[`dvar'])
			local obs5 = e(N)
			local dof5 = e(df_r)
			if "`dvar'"=="FemRatio" {
				margins, at(`dvar'=(0 1)) post
				matrix `mb5' = (nullmat(`mb5'), _b[1._at])
				matrix `ms5' = (nullmat(`ms5'), _se[1._at])
				matrix `p' = (`p', 100 * abs((_b[1._at]-_b[2._at])/_b[1._at]))
			}
	
			* (6) JEL
			use `article_primary_jel', clear
			reghdfe _`stat'_score `dvar' asinhCiteCount, absorb(i.Journal##i.Year i.Editor i.MaxInst i.MaxT i.NativeEnglish `jcode1') vce(cluster Editor)
			matrix `b6' = (nullmat(`b6'), _b[`dvar'])
			matrix `se6' = (nullmat(`se6'), _se[`dvar'])
			local obs6 = e(N)
			local dof6 = e(df_r)
			if "`dvar'"=="FemRatio" {
				margins, at(`dvar'=(0 1)) post
				matrix `mb6' = (nullmat(`mb6'), _b[1._at])
				matrix `ms6' = (nullmat(`ms6'), _se[1._at])
				matrix `p' = (`p', 100 * abs((_b[1._at]-_b[2._at])/_b[1._at]))
			}

			* (7) Tertiary JEL
			use `article_tertiary_jel_pp', clear
			reghdfe _`stat'_score `dvar' asinhCiteCount, absorb(i.Journal##i.Year Editor MaxInst MaxT NativeEnglish `jcode3') vce(cluster Editor)
			matrix `b7' = (nullmat(`b7'), _b[`dvar'])
			matrix `se7' = (nullmat(`se7'), _se[`dvar'])
			local obs7 = e(N)
			local dof7 = e(df_r)
			if "`dvar'"=="FemRatio" {
				margins, at(`dvar'=(0 1)) post
				matrix `mb7' = (nullmat(`mb7'), _b[1._at])
				matrix `ms7' = (nullmat(`ms7'), _se[1._at])
				matrix `p' = (`p', 100 * abs((_b[1._at]-_b[2._at])/_b[1._at]))
				matrix `P' = (nullmat(`P') \ `p')
			}
		}
		ereturn_post `b1', se(`se1') obs(`obs1') dof(`dof1') store(est_1_Editor) colnames(`stats_varnames') local(editor ✓ journal ✓)
		ereturn_post `b2', se(`se2') obs(`obs2') dof(`dof2') store(est_2_Editor) colnames(`stats_varnames') local(editor ✓ journal ✓ year ✓)
		ereturn_post `b3', se(`se3') obs(`obs3') dof(`dof3') store(est_3_Editor) colnames(`stats_varnames') local(editor ✓ journal ✓ year ✓ jnlyr ✓)
		ereturn_post `b4', se(`se4') obs(`obs4') dof(`dof4') store(est_4_Editor) colnames(`stats_varnames') local(editor ✓ journal ✓ year ✓ jnlyr ✓ inst ✓)
		ereturn_post `b5', se(`se5') obs(`obs5') dof(`dof5') store(est_5_Editor) colnames(`stats_varnames') local(editor ✓ journal ✓ year ✓ jnlyr ✓ inst ✓ qual ✓¹ native ✓)
		ereturn_post `b6', se(`se6') obs(`obs6') dof(`dof6') store(est_6_Editor) colnames(`stats_varnames') local(editor ✓ journal ✓ year ✓ jnlyr ✓ inst ✓ qual ✓¹ native ✓ jel ✓)
		ereturn_post `b7', se(`se7') obs(`obs7') dof(`dof7') store(est_7_Editor) colnames(`stats_varnames') local(editor ✓ journal ✓ year ✓ jnlyr ✓ inst ✓ qual ✓¹ native ✓ jel3 ✓)
		
		* Effect for men.
		if "`dvar'"=="FemRatio" {
			ereturn_post `mb1', se(`ms1') obs(`obs1') dof(`dof1') store(man_1_Editor) colnames(`stats_varnames') local(editor ✓ journal ✓)
			ereturn_post `mb2', se(`ms2') obs(`obs2') dof(`dof2') store(man_2_Editor) colnames(`stats_varnames') local(editor ✓ journal ✓ year ✓)
			ereturn_post `mb3', se(`ms3') obs(`obs3') dof(`dof3') store(man_3_Editor) colnames(`stats_varnames') local(editor ✓ journal ✓ year ✓ jnlyr ✓)
			ereturn_post `mb4', se(`ms4') obs(`obs4') dof(`dof4') store(man_4_Editor) colnames(`stats_varnames') local(editor ✓ journal ✓ year ✓ jnlyr ✓ inst ✓)
			ereturn_post `mb5', se(`ms5') obs(`obs5') dof(`dof5') store(man_5_Editor) colnames(`stats_varnames') local(editor ✓ journal ✓ year ✓ jnlyr ✓ inst ✓ qual ✓¹ native ✓)
			ereturn_post `mb6', se(`ms6') obs(`obs6') dof(`dof6') store(man_6_Editor) colnames(`stats_varnames') local(editor ✓ journal ✓ year ✓ jnlyr ✓ inst ✓ qual ✓¹ native ✓ jel ✓)
			ereturn_post `mb7', se(`ms7') obs(`obs7') dof(`dof7') store(man_7_Editor) colnames(`stats_varnames') local(editor ✓ journal ✓ year ✓ jnlyr ✓ inst ✓ qual ✓¹ native ✓ jel3 ✓)
		
			include "`do_path'/table4"
			include "`do_path'/tableC2"
			include "`do_path'/tableC3"
		}
		else if "`dvar'"=="Fem100" {
			include "`do_path'/tableC4a"
		}
		else if "`dvar'"=="Female" {
			include "`do_path'/tableC4b"
		}
		else if "`dvar'"=="Fem50" {
			include "`do_path'/tableC4c"
		}
	}
	********************************************
	
	********************************************
	************ JEL classification ************
	********************************************
	use `article_primary_jel_pp', clear
	drop JEL1_A JEL1_B JEL1_P JEL1_M
	reghdfe _dalechall_score c.FemRatio##(`jcode1') asinhCiteCount, absorb(i.Editor i.Journal i.Year i.MaxInst i.MaxT i.NativeEnglish) vce(cluster Editor)
	count if e(sample)
	noisily display "Figure 1 sample size: " %9.0fc r(N)
	count if Journal==5 & e(sample)
	noisily display "Figure 1 P&P sample size: " %9.0fc r(N)

	tempname A B
	margins, dydx(FemRatio)
	matrix `A' = r(table)'
	noisily display "Figure 1 average female ratio coefficient: " %4.3fc `A'[1,1] " (standard error " %4.3fc `A'[1,2] ")"

	foreach jel of varlist JEL1_* {
		lincom _b[FemRatio] + _b[1.`jel'#c.FemRatio]
		matrix `B' = nullmat(`B') \ (r(estimate), r(se)) \ (_b[1.`jel'#c.FemRatio], _se[1.`jel'#c.FemRatio])
		matname `B' asobs:`jel' inter:`jel', rows(`=rowsof(`B')-1'...) explicit
	}
	matrix `B' = `B'[1...,1],`B'[1...,1]-invttail(e(df_r),0.05)*`B'[1...,2],`B'[1...,1]+invttail(e(df_r),0.05)*`B'[1...,2]
	matrix colnames `B' = b ll ul

	svmat_rownames `B', names(col) generate(jel eq) roweq rowname clear
	by eq (b), sort: generate jel_id = _n if eq == "asobs"
	by jel (eq), sort: replace jel_id = jel_id[_n-1] if eq == "inter"
	do `vallabels'
	encode_replace jel, label(jel_labels1)
	label values jel jel_labels2
	labmask jel_id, values(jel) decode
	encode_replace eq
	include "`do_path'/figure1"
	********************************************

	estimates clear
}
exit