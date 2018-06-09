// quietly {
	
	********************************************
	*********** Generate NBER data. ************
	********************************************
	#delimit ;
	local sql "
	SELECT ArticleID, NberID, WPDate, StatName,
	CASE WHEN (StatName='flesch_score' OR StatName LIKE '%_count') THEN StatValue ELSE -1 * StatValue END AS nber_
		FROM NBER
		NATURAL JOIN NBERCorr
		NATURAL JOIN NBERStat
	";
	#delimit cr
	odbc_compress, exec("`sql'") dsn(readdb)
	reshape wide nber_, i(ArticleID NberID) j(StatName) string
	merge m:1 ArticleID using `article', keep(match) nogenerate
	generate nber_wps_count = nber_word_count / nber_sent_count
	generate nber_pps_count = nber_polysyblword_count / _sent_count
	generate nber_spw_count = nber_sybl_count / nber_word_count
	generate nber_pww_count = nber_polysyblword_count / nber_word_count
	generate nber_dww_count = nber_notdalechall_count / nber_word_count
	generate Blind = Year<=1997&(Journal==4|(Year>=1992&Journal==1))
	generate SemiBlind = (Journal==1&Year<2012|Journal==4&Year<2005)&Year>1997
	generate BelowAbstractLen = (Journal==3)|(Journal==4)|(nber_word_count<=100&Journal==1)|(nber_word_count<=150&Journal==2)
	date_replace WPDate, mask("YMD")
	do `varlabels'
	compress
	tempfile nber
	save `nber'
	********************************************
	
	********************************************
	***** NBER WP textual characteristics. *****
	********************************************
	use `nber', clear
	tempname b s B S p
	foreach stat in `nber_counts_varnames' `stats_varnames' {
		mean nber`stat' `stat' if FemRatio<0.5
		lincom _b[`stat']-_b[nber`stat']
		matrix `b' = (e(b), r(estimate))
		matrix `s' = (vecdiag(cholesky(e(V))), r(se))
		local N = e(N)
		local dof = r(df)

		mean nber`stat' `stat' if FemRatio>=0.5
		lincom _b[`stat']-_b[nber`stat']
		matrix `b' = (`b', e(b), r(estimate))
		matrix `s' = (`s', vecdiag(cholesky(e(V))), r(se))
		local N_f = e(N)
		local dof_f = r(df)

		matrix `B' = nullmat(`B') \ `b'
		matrix `S' = nullmat(`S') \ `s'

		matrix `p' = nullmat(`p') \ 100*(`b'[1,3]/`b'[1,1],`b'[1, 6]/`b'[1,4],(`b'[1, 6]-`b'[1,3])/`b'[1,3])
	}

	forvalues i=1/6 {
		matrix `b' = `B'[1...,`i']'
		matrix `s' = `S'[1...,`i']'
		if `i' == 4 {
			local N = `N_f'
			local dof = `dof_f'
		}
		ereturn_post `b', se(`s') obs(`N') dof(`dof') colnames(`nber_counts_varnames' `stats_varnames') store(sum_`i')
	}

	* List number of total observations.
	distinct NberID
	noisily display "No. distinct NBER working papers: " `r(ndistinct)'
	distinct ArticleID
	noisily display "No. distinct published articles: " `r(ndistinct)'

	* Generate table.
	include "`do_path'/table6"
	********************************************

	********************************************
	**** Published vs. NBER paper versions. ****
	********************************************
	use `nber', clear
	foreach restriction in !Blind !Blind&BelowAbstractLen {
		foreach dvar in FemRatio Fem100 Female Fem50 {
			tempname B SE rb rse
			foreach stat in `stats' {
				rename nber_`stat'_score nber_score

				* OLS, controlling for draft readability (biased).
				eststo reg_`stat'_`dvar': reghdfe _`stat'_score nber_score `dvar' Maxt MaxT CiteCount i.NativeEnglish if `restriction', absorb(i.Year##i.Journal i.Editor) vce(cluster Editor)
				local b_fem = _b[`dvar']
				local se_fem = _se[`dvar']

				estadd local journal = "✓"
				estadd local year = "✓"
				estadd local jnlyr = "✓"
				estadd local editor = "✓"
				estadd local qual = "✓²"
				estadd local native = "✓"

				rename nber_score nber_`stat'_score

				* FGLS.
				eststo nber: regress nber_`stat'_score `dvar' Maxt MaxT CiteCount i.NativeEnglish i.Year##i.Journal i.Editor if `restriction'
				eststo reg: regress      _`stat'_score `dvar' Maxt MaxT CiteCount i.NativeEnglish i.Year##i.Journal i.Editor if `restriction'
				suest nber reg, vce(cluster Year)
				lincom _b[reg_mean:`dvar'] - _b[nber_mean:`dvar']
				matrix `B' = (nullmat(`B'), (`b_fem' \ _b[nber_mean:`dvar'] \ _b[reg_mean:`dvar'] \ r(estimate)))
				matrix `SE' = (nullmat(`SE'), (`se_fem' \ _se[nber_mean:`dvar'] \ _se[reg_mean:`dvar'] \ r(se)))
			}
			tempname b se
			matrix `b' = `B'[1, 1...]
			matrix `se' = `SE'[1, 1...]
			ereturn_post `b', se(`se') obs(`e(N)') colnames(`stats_varnames') store(reg_`dvar') local(journal ✓ year ✓ jnlyr ✓ editor ✓ qual ✓² native ✓)

			matrix `b' = `B'[2, 1...]
			matrix `se' = `SE'[2, 1...]
			ereturn_post `b', se(`se') obs(`e(N)') colnames(`stats_varnames') store(su_2_`dvar') local(journal ✓ year ✓ jnlyr ✓ editor ✓ qual ✓² native ✓)

			matrix `b' = `B'[3, 1...]
			matrix `se' = `SE'[3, 1...]
			ereturn_post `b', se(`se') obs(`e(N)') colnames(`stats_varnames') store(su_1_`dvar') local(journal ✓ year ✓ jnlyr ✓ editor ✓ qual ✓² native ✓)

			matrix `b' = `B'[4, 1...]
			matrix `se' = `SE'[4, 1...]
			ereturn_post `b', se(`se') obs(`e(N)') colnames(`stats_varnames') store(su_3_`dvar')


			if "`restriction'"=="!Blind"&"`dvar'"=="FemRatio" {
				* Percentage of gap caused during peer review.
				tempname P
				forvalues i=1/`=colsof(`B')' {
					matrix `P' = nullmat(`P') \ 100*(`B'[4,`i']' / `B'[3,`i'])
				}
				matrix `P' = `P' \ trace(diag(`P'))/rowsof(`P')
				matrix rownames `P' = `stats_varnames' Average
			}
			* Fixed effects.
			preserve
			reshape long @_score, i(NberID) j(stat) string
			generate time = substr(stat, 1, 4)!="nber"
			replace stat = substr(stat, 5, .) if !time
			reshape wide _score, i(NberID time) j(stat) string
			rename _score* *_score
			egen id = group(NberID)
			xtset id time

			tempname b se B S
			foreach stat in `stats' {

				if "`restriction'"=="!Blind"&"`dvar'"=="FemRatio" {
					* Blind.
					eststo dreg: reghdfe D._`stat'_score c.`dvar'##i.Blind Maxt i.NativeEnglish, absorb(i.Editor i.Journal i.Year#i.Journal) vce(cluster Year)
					// eststo dreg: regress D._`stat'_score c.`dvar'##i.Blind Maxt i.NativeEnglish i.Editor i.Journal i.Year#i.Journal if (Journal==1|Journal==4), vce(cluster Year)
					lincom _b[c.`dvar'] + _b[c.`dvar'#1.Blind]
					matrix `B' = _b[c.`dvar'] , r(estimate) , -1*_b[c.`dvar'#1.Blind]
					matrix `S' = _se[c.`dvar'] , r(se) , _se[c.`dvar'#1.Blind]
					// margins, at(`dvar'=(0 1)) over(Blind) post
					// matrix `B' = _b[2._at#0.Blind] , _b[1._at#0.Blind] , `B'[1,1] , _b[2._at#1.Blind] , _b[1._at#1.Blind] , `B'[1,2...]
					// matrix `S' = _se[2._at#0.Blind] , _se[1._at#0.Blind] , `S'[1,1] , _se[2._at#1.Blind] , _se[1._at#1.Blind] , `S'[1,2...]
					ereturn_post `B', se(`S') obs(`e(N)') colnames(nonblind blind diff) store(blind_`stat') local(journal ✓ jnlyr ✓ editor ✓ qual ✓³ native ✓)

					* Semi-blind.
					reghdfe D._`stat'_score c.`dvar'##i.SemiBlind Maxt i.NativeEnglish if `restriction'&Year>1997, absorb(i.Editor i.Journal i.Year#i.Journal) vce(cluster Year)
					lincom _b[c.`dvar'] + _b[c.`dvar'#1.SemiBlind]
					matrix `B' = _b[c.`dvar'] , r(estimate) , -1*_b[c.`dvar'#1.SemiBlind]
					matrix `S' = _se[c.`dvar'] , r(se) , _se[c.`dvar'#1.SemiBlind]
					ereturn_post `B', se(`S') obs(`e(N)') colnames(nonblind semiblind diff) store(semiblind_`stat') local(journal ✓ jnlyr ✓ editor ✓ qual ✓³ native ✓)
				}

				* Exclude blinded observations.
				reghdfe D._`stat'_score `dvar' Maxt i.NativeEnglish if `restriction', absorb(i.Editor i.Journal i.Year#i.Journal) vce(cluster Year)
				matrix `b' = (nullmat(`b') , _b[`dvar'])
				matrix `se' = (nullmat(`se') , _se[`dvar'])

			}
			ereturn_post `b', se(`se') obs(`e(N)') colnames(`stats_varnames') store(fe_`dvar') local(journal ✓ jnlyr ✓ editor ✓ qual ✓³ native ✓)
			restore

			if "`restriction'"=="!Blind" {
				* Generate table.
				if "`dvar'"=="FemRatio" {
					include "`do_path'/table7"
					include "`do_path'/tableC5"
					include "`do_path'/table8a"
					include "`do_path'/tableC6a"
				}
				else if "`dvar'"=="Fem100" {
					include "`do_path'/tableXA"
				}
				else if "`dvar'"=="Female" {
					include "`do_path'/tableXB"
				}
				else if "`dvar'"=="Fem50" {
					include "`do_path'/tableXC"
				}
			}
			else if "`restriction'"=="!Blind&BelowAbstractLen"&"`dvar'"=="FemRatio" {
				include "`do_path'/tableC7a"
			}
		}
	}
	********************************************
	
	* Alternative program for calculating readability statistics
	use `nber', clear
	merge 1:1 NberID using "`project_path'/data/nberstat", assert(using match) keep(match) nogenerate
	tempname B SE rb rse
	foreach stat in Flesch_Kincaid Gunning_Fog_Index SMOG {

		* OLS, controlling for draft readability (biased).
		eststo reg_`stat': reghdfe `stat' NBER_`stat' FemRatio Maxt MaxT CiteCount i.NativeEnglish if !Blind, absorb(i.Year##i.Journal i.Editor) vce(cluster Editor)
		local b_fem = _b[FemRatio]
		local se_fem = _se[FemRatio]

		estadd local journal = "✓"
		estadd local year = "✓"
		estadd local jnlyr = "✓"
		estadd local editor = "✓"
		estadd local qual = "✓²"
		estadd local native = "✓"

		* FGLS.
		eststo nber: regress NBER_`stat' FemRatio Maxt MaxT CiteCount i.NativeEnglish i.Year##i.Journal i.Editor if !Blind
		eststo reg: regress      `stat' FemRatio Maxt MaxT CiteCount i.NativeEnglish i.Year##i.Journal i.Editor if !Blind
		suest nber reg, vce(cluster Year)
		lincom _b[reg_mean:FemRatio] - _b[nber_mean:FemRatio]
		matrix `B' = (nullmat(`B'), (`b_fem' \ _b[nber_mean:FemRatio] \ _b[reg_mean:FemRatio] \ r(estimate)))
		matrix `SE' = (nullmat(`SE'), (`se_fem' \ _se[nber_mean:FemRatio] \ _se[reg_mean:FemRatio] \ r(se)))
	}
	tempname b se
	matrix `b' = `B'[1, 1...]
	matrix `se' = `SE'[1, 1...]
	ereturn_post `b', se(`se') obs(`e(N)') colnames(_fleschkincaid_score _gunningfog_score _smog_score) store(reg_alt) local(journal ✓ year ✓ jnlyr ✓ editor ✓ qual ✓² native ✓)

	matrix `b' = `B'[2, 1...]
	matrix `se' = `SE'[2, 1...]
	ereturn_post `b', se(`se') obs(`e(N)') colnames(_fleschkincaid_score _gunningfog_score _smog_score) store(su_2_alt) local(journal ✓ year ✓ jnlyr ✓ editor ✓ qual ✓² native ✓)

	matrix `b' = `B'[3, 1...]
	matrix `se' = `SE'[3, 1...]
	ereturn_post `b', se(`se') obs(`e(N)') colnames(_fleschkincaid_score _gunningfog_score _smog_score) store(su_1_alt) local(journal ✓ year ✓ jnlyr ✓ editor ✓ qual ✓² native ✓)

	matrix `b' = `B'[4, 1...]
	matrix `se' = `SE'[4, 1...]
	ereturn_post `b', se(`se') obs(`e(N)') colnames(_fleschkincaid_score _gunningfog_score _smog_score) store(su_3_alt)
	
	* Fixed effects.
	preserve
	drop *_score *_count
	rename (Flesch_Kincaid Gunning_Fog_Index SMOG) (_Flesch_Kincaid_score _Gunning_Fog_Index_score _SMOG_score)
	rename (NBER_Flesch_Kincaid NBER_Gunning_Fog_Index NBER_SMOG) (NBER_Flesch_Kincaid_score NBER_Gunning_Fog_Index_score NBER_SMOG_score)
	reshape long @_score, i(NberID) j(stat) string
	generate time = substr(stat, 1, 4)!="NBER"
	replace stat = substr(stat, 5, .) if !time
	reshape wide _score, i(NberID time) j(stat) string
	rename _score* *_score
	egen id = group(NberID)
	xtset id time

	tempname b se B S
	desc
	list in 1/10
	foreach stat in Flesch_Kincaid Gunning_Fog_Index SMOG {
		reghdfe D._`stat'_score FemRatio Maxt i.NativeEnglish if !Blind, absorb(i.Editor i.Journal i.Year#i.Journal) vce(cluster Year)
		matrix `b' = (nullmat(`b') , _b[FemRatio])
		matrix `se' = (nullmat(`se') , _se[FemRatio])
	}
	ereturn_post `b', se(`se') obs(`e(N)') colnames(_fleschkincaid_score _gunningfog_score _smog_score) store(fe_alt) local(journal ✓ jnlyr ✓ editor ✓ qual ✓³ native ✓)
	restore
	
	include "`do_path'/table7ALTERNATIVE"
	********************************************
	
	********************************************
	******* Double-blind in entire sample ******
	********************************************
	use `article_primary_jel', clear
	generate Blind = Year<=1997&(Journal==4|(Year>=1992&Journal==1))
	foreach stat in `stats' {
		tempname b se
		reghdfe _`stat'_score c.FemRatio##i.Blind CiteCount i.NativeEnglish, absorb(i.Journal##i.Year i.Editor i.MaxInst i.MaxT) vce(cluster Editor)
		lincom _b[c.FemRatio] + _b[c.FemRatio#1.Blind]
		matrix `b' = _b[c.FemRatio] , r(estimate) , -1*_b[c.FemRatio#1.Blind]
		matrix `se' = _se[c.FemRatio] , r(se) , _se[c.FemRatio#1.Blind]
		ereturn_post `b', se(`se') obs(`e(N)') colnames(nonblind blind diff) store(blindfull_`stat') local(editor ✓ journal ✓ year ✓ jnlyr ✓ inst ✓ qual ✓¹ native ✓)
	}
	include "`do_path'/tableC6b"
	********************************************

	********************************************
	************** Field effects ***************
	********************************************
	use `article_primary_jel', clear
	merge 1:m ArticleID using `nber', keep(match) nogenerate
	tempname B SE
	foreach stat in `stats' {
		rename nber_`stat'_score nber_score

		* OLS, controlling for draft readability (biased).
		eststo reg_`stat'_FemRatio: regress _`stat'_score nber_score FemRatio Maxt MaxT CiteCount i.NativeEnglish i.Year##i.Journal i.Editor JEL1_* if !Blind, vce(cluster Editor)
		local b_fem = _b[FemRatio]
		local se_fem = _se[FemRatio]

		estadd local journal = "✓"
		estadd local year = "✓"
		estadd local jnlyr = "✓"
		estadd local editor = "✓"
		estadd local qual = "✓²"
		estadd local native = "✓"
		estadd local jel = "✓"

		rename nber_score nber_`stat'_score

		* FGLS.
		eststo nber: regress nber_`stat'_score FemRatio Maxt MaxT CiteCount i.NativeEnglish i.Year##i.Journal i.Editor JEL1_* if !Blind
		eststo reg: regress      _`stat'_score FemRatio Maxt MaxT CiteCount i.NativeEnglish i.Year##i.Journal i.Editor JEL1_* if !Blind
		suest nber reg, vce(cluster Year)
		lincom _b[reg_mean:FemRatio] - _b[nber_mean:FemRatio]
		matrix `B' = (nullmat(`B'), (`b_fem' \ _b[nber_mean:FemRatio] \ _b[reg_mean:FemRatio] \ r(estimate)))
		matrix `SE' = (nullmat(`SE'), (`se_fem' \ _se[nber_mean:FemRatio] \ _se[reg_mean:FemRatio] \ r(se)))
	}
	tempname b se
	matrix `b' = `B'[1, 1...]
	matrix `se' = `SE'[1, 1...]
	ereturn_post `b', se(`se') obs(`e(N)') colnames(`stats_varnames') store(reg_jel) local(journal ✓ year ✓ jnlyr ✓ editor ✓ qual ✓² native ✓ jel ✓)

	matrix `b' = `B'[2, 1...]
	matrix `se' = `SE'[2, 1...]
	ereturn_post `b', se(`se') obs(`e(N)') colnames(`stats_varnames') store(su_2_jel) local(journal ✓ year ✓ jnlyr ✓ editor ✓ qual ✓² native ✓ jel ✓)

	matrix `b' = `B'[3, 1...]
	matrix `se' = `SE'[3, 1...]
	ereturn_post `b', se(`se') obs(`e(N)') colnames(`stats_varnames') store(su_1_jel) local(journal ✓ year ✓ jnlyr ✓ editor ✓ qual ✓² native ✓ jel ✓)

	matrix `b' = `B'[4, 1...]
	matrix `se' = `SE'[4, 1...]
	ereturn_post `b', se(`se') obs(`e(N)') colnames(`stats_varnames') store(su_3_jel)

	include "`do_path'/tableXD"
	********************************************
	
	// ********************************************
	// **** Effect of additional publication. *****
	// ********************************************
	// use `nber', clear
	// merge m:m ArticleID using `author', keep(match) nogenerate
	//
	// tempvar tBin
	// recode t (1=1)(2=2)(3=3)(4/5=4)(nonmissing=5), generate(`tBin')
	// label define tBin 1 "1" 2 "2" 3 "3" 4 "4-5" 5 "6+"
	// label values `tBin' tBin
	//
	// eststo nber: regress nber_flesch_score c.FemRatio##c.`tBin' MaxT CiteCount i.NativeEnglish i.Year##i.Journal i.Editor [aweight=AuthorWeight]
	// eststo reg:  regress _flesch_score     c.FemRatio##c.`tBin' MaxT CiteCount i.NativeEnglish i.Year##i.Journal i.Editor [aweight=AuthorWeight]
	// eststo suest: suest nber reg, vce(cluster Editor)
	//
	// local j = 1
	// tempname B SE se b
	//
	// * Direct impact of peer review: Female.
	// margins, at(FemRatio=1) over(`tBin') expression(predict(equation(reg_mean))-predict(equation(nber_mean)))
	// matrix `B' = nullmat(`B') \ r(b)
	// matrix `se' = r(table)
	// matrix `SE' = nullmat(`SE') \ `se'[rownumb(`se',"se"), 1...]
	// noisily display `j++'
	//
	// * Direct impact of peer review: Male.
	// margins, at(FemRatio=0) over(`tBin') expression(predict(equation(reg_mean))-predict(equation(nber_mean)))
	// matrix `B' = nullmat(`B') \ r(b)
	// matrix `se' = r(table)
	// matrix `SE' = nullmat(`SE') \ `se'[rownumb(`se',"se"), 1...]
	// noisily display `j++'
	//
	// * Impact of female ratio: published articles.
	// margins, dydx(FemRatio) over(`tBin') predict(equation(reg_mean))
	// matrix `B' = nullmat(`B') \ r(b)
	// matrix `se' = r(table)
	// matrix `SE' = nullmat(`SE') \ `se'[rownumb(`se',"se"), 1...]
	// noisily display `j++'
	//
	// * Impact of female ratio: working papers.
	// margins, dydx(FemRatio) over(`tBin') predict(equation(nber_mean))
	// matrix `B' = nullmat(`B') \ r(b)
	// matrix `se' = r(table)
	// matrix `SE' = nullmat(`SE') \ `se'[rownumb(`se',"se"), 1...]
	// noisily display `j++'
	//
	// * Difference
	// margins, at(FemRatio=0 FemRatio=1) over(`tBin') contrast(atcontrast(r)) expression(predict(equation(reg_mean))-predict(equation(nber_mean)))
	// matrix `B' = nullmat(`B') \ r(b)
	// matrix `se' = r(table)
	// matrix `SE' = nullmat(`SE') \ `se'[rownumb(`se',"se"), 1...]
	// noisily display `j++'
	//
	// forvalues i=1/`=colsof(`B')' {
	// 	matrix `b' = `B'[1...,`i']'
	// 	matrix `se' = `SE'[1...,`i']'
	// 	ereturn_post `b', se(`se') colnames(women men reg nber diff) obs(`e(N)') store(est_`i') local(journal ✓ year ✓ jnlyr ✓ editor ✓ qual ✓⁵ native ✓)
	// }
	//
	// * Make figure.
	// tempname b
	// estimates restore suest
	// margins, at(FemRatio=0) at(FemRatio=1) over(`tBin') predict(equation(nber_mean)) predict(equation(reg_mean))
	// matrix `b' = r(table)'
	//
	// include "`do_path'/figure6"
	// include "`do_path'/table12"
	//
	// ********************************************
	estimates clear
}
exit