quietly {
	********************************************
	********* Effect in tth pulication *********
	********************************************
	use `author', clear
	foreach dvar in FemRatio Fem100 Female Fem50 {
		tempname B S P M MS
		foreach stat in `stats' {
			local i = 1
			foreach if in t==1 t==2 t==3 t==4|t==5 t>5 {
			
				* No MaxT: small sample sizes.
				* No i.Journal#i.Year: small sample sizes.
				eststo `stat'_`dvar'_`i': regress _`stat'_score `dvar' c.`dvar'#1.Sex N i.Editor i.Journal i.Year CiteCount i.MaxInst i.NativeEnglish if `if' [aweight=AuthorWeight]
				local n`i++' = e(N)
			}
		
			eststo `stat'_`dvar': suest2 `stat'_`dvar'_*, cluster(AuthorID Editor)
		
			tempname b se
			matrix `b' = (_b[`stat'_`dvar'_1_mean:`dvar'] \ _b[`stat'_`dvar'_2_mean:`dvar'] \ _b[`stat'_`dvar'_3_mean:`dvar'] \ _b[`stat'_`dvar'_4_mean:`dvar'] \ _b[`stat'_`dvar'_5_mean:`dvar'])
			matrix `se' = (_se[`stat'_`dvar'_1_mean:`dvar'] \ _se[`stat'_`dvar'_2_mean:`dvar'] \ _se[`stat'_`dvar'_3_mean:`dvar'] \ _se[`stat'_`dvar'_4_mean:`dvar'] \ _se[`stat'_`dvar'_5_mean:`dvar'])
			
			if "`dvar'"=="FemRatio" {
				* Male effects.
				tempvar grps
				egen `grps' = group(_est_`stat'_`dvar'_5 _est_`stat'_`dvar'_4 _est_`stat'_`dvar'_3 _est_`stat'_`dvar'_2 _est_`stat'_`dvar'_1)
				margins, at(`dvar'=0) over(`grps') post

				tempname m ms
				matrix `m' = e(b)'
				matrix `ms' = (_se[1.`grps'] \ _se[2.`grps'] \ _se[3.`grps'] \ _se[4.`grps'] \ _se[5.`grps'])
			}
		
			xtreg _`stat'_score `dvar' c.`dvar'#1.Sex N i.Editor i.Journal##i.Year i.MaxInst CiteCount i.MaxT i.NativeEnglish, pa corr(ar 1) vce(robust)
			local n6 = e(N)
				
			matrix `B' = nullmat(`B'), (`b' \ _b[`dvar'])
			matrix `S' = nullmat(`S'), (`se' \ _se[`dvar'])
			
			if "`dvar'"=="FemRatio" {
				* Male effects
				margins, at(`dvar'=0) post
				matrix `M' = nullmat(`M'), (`m' \ _b[_cons])
				matrix `MS' = nullmat(`MS'), (`ms' \ _se[_cons])
			}
		}
	
		tempname b se
		forvalues i=1/5 {
			matrix `b' = `B'[`i', 1...]
			matrix `se' = `S'[`i', 1...]
			ereturn_post `b', se(`se') obs(`e(N)') scalar(obs `n`i'') local(Nj ✓ editor ✓ year ✓ journal ✓ inst ✓ qual ✓⁴ native ✓) store(reg_`dvar'_`i') colnames(`stats_varnames')
			
			if "`dvar'"=="FemRatio" {
				* Male effects.
				matrix `b' = `M'[`i', 1...]
				matrix `se' = `MS'[`i', 1...]
				ereturn_post `b', se(`se') obs(`e(N)') scalar(obs `n`i'') local(Nj ✓ editor ✓ year ✓ journal ✓ inst ✓ qual ✓⁴ native ✓) store(male_`i') colnames(`stats_varnames')
			}
		}
		matrix `b' = `B'[6, 1...]
		matrix `se' = `S'[6, 1...]
		ereturn_post `b', se(`se') obs(`e(N)') scalar(obs `n6') local(Nj ✓ editor ✓ year ✓ journal ✓ jnlyr ✓ inst ✓ qual ✓¹ native ✓) store(reg_`dvar'_6) colnames(`stats_varnames')
		
		if "`dvar'"=="FemRatio" {
			matrix `b' = `M'[6, 1...]
			matrix `se' = `MS'[6, 1...]
			ereturn_post `b', se(`se') obs(`e(N)') scalar(obs `n6') local(Nj ✓ editor ✓ year ✓ journal ✓ jnlyr ✓ inst ✓ qual ✓¹ native ✓) store(male_6) colnames(`stats_varnames')
		}
		
		if "`dvar'"=="FemRatio" {
			include "`do_path'/table8.do"
			include "`do_path'/tableC7.do"
		}
		else if "`dvar'"=="Fem100" {
			include "`do_path'/table8XC"
		}
		else if "`dvar'"=="Female" {
			include "`do_path'/table8XA"
		}
		else if "`dvar'"=="Fem50" {
			include "`do_path'/table8XB"
		}
	}
	********************************************
	
	********************************************
	************ β₁ equality tests. ************
	********************************************
	tempname P Chi
	foreach stat in `stats' {
		estimates restore `stat'_FemRatio
		tempname p chi
		forvalues i=2/5 {
			test [`stat'_FemRatio_1_mean]FemRatio = [`stat'_FemRatio_`i'_mean]FemRatio
			matrix `p' = nullmat(`p') , r(p)
			matrix `chi' = nullmat(`chi') , r(chi2)
		}
		test [`stat'_FemRatio_2_mean]FemRatio = [`stat'_FemRatio_3_mean]FemRatio
		matrix `P' = nullmat(`P') \ (`p' , r(p))
		matrix `Chi' = nullmat(`Chi') \ (`chi' , r(chi2))
	}
	matrix rownames `P' = `stats_varnames'
	matrix rownames `Chi' = `stats_varnames'
	include "`do_path'/tableC6.do"
	********************************************
	
	estimates clear
}
exit
