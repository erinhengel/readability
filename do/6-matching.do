quietly {
	*******************************************
	*** Generate author-level matching data. **
	*******************************************
	local strategy propensity
	// local strategy mahalanobis
	
	use `author', clear
	merge m:1 ArticleID using `primary_jel', keep(master match) nogenerate
	tabulate Journal, generate(Journal)
	egen Decade = cut(Year), at(1930 1940 1950 1960 1970 1980 1990 2000 2010 2020)
	tabulate Decade, generate(Decade)
	tabulate AuthorOrderBin, generate(AuthorOrderBin)
	collapse ///
		(firstnm) Sex T ///
		(min) minInstRank=InstRank minCiteCount=CiteCount minPubOrder=PubOrder minN=N ///
		(mean) meanCiteCount=CiteCount meanPubOrder=PubOrder meanN=N meanYear=Year meanInstRank=InstRank Journal? Decade? AuthorOrderBin? ///
		(max) maxCiteCount=CiteCount maxInstRank=InstRank ///
		(sum) JEL1_? ///
		, by(AuthorID)
	* Make AuthorOrderBin percentages.
	foreach bin of varlist AuthorOrderBin* {
		replace `bin' = `bin'*100
	}
	do `varlabels'
	tempfile author_prematching
	save `author_prematching'
	
	tempvar Female rand_sort
	generate `Female' = 1 - Sex
	generate `rand_sort' = runiform()
	sort `rand_sort'
	local matchlist T minPubOrder AuthorOrderBin2 maxCiteCount maxInstRank Decade? Journal? JEL1_?
	if "`strategy'"=="propensity" {
		psmatch2 `Female' `matchlist', //logit
		rename _pscore pscore
		psmatch2 `Female' if T>2, pscore(pscore)
	}
	else if "`strategy'"=="mahalanobis" {
		psmatch2 `Female' if T>2, mahalanobis(`matchlist')
	}
	sort _id
	generate _weight1 = _weight[_n1]
	generate T1 = T[_n1]
	generate AuthorID1 = AuthorID[_n1]
	rename (AuthorID _weight T)=0
	drop if missing(_n1)
	keep AuthorID* _weight*
	tempfile matches
	save `matches'
	forvalues i=0/1 {
		use `matches', clear
		keep AuthorID`i'
		duplicates drop
		rename AuthorID`i' AuthorID
		merge 1:m AuthorID using `author', assert(using match) keep(match) keepusing(t T FemRatio Journal Year N InstRank MaxInst Maxt `stats_varnames') nogenerate
		keep if t==1 | t==3
		replace t = 2 if t>1
		rename (AuthorID t T FemRatio Journal Year N InstRank MaxInst Maxt `stats_varnames') =`i'
		reshape wide `stats_varnames'`i' FemRatio`i' Journal`i' Year`i' N`i' InstRank`i' MaxInst`i' Maxt`i', i(AuthorID`i') j(t)
		merge 1:m AuthorID`i' using `matches', assert(match) nogenerate
		save `matches', replace
	}
	tempfile author_matching
	save `author_matching'
	********************************************
	
	********************************************
	************* Reconstruct Rit **************
	********************************************
	use `author_matching', clear
	
	tempvar id t g
	generate `id' = _n
	reshape long Year0 Year1 FemRatio0 FemRatio1 MaxInst0 MaxInst1 N0 N1 Journal0 Journal1 InstRank0 InstRank1 Maxt0 Maxt1 ///
		_flesch_score0 _flesch_score1 ///
		_fleschkincaid_score0 _fleschkincaid_score1 ///
		_gunningfog_score0 _gunningfog_score1 ///
		_smog_score0 _smog_score1 ///
		_dalechall_score0 _dalechall_score1 ///
			, i(`id') j(`t')
	reshape long AuthorID Year FemRatio MaxInst N Journal InstRank T Maxt _weight ///
		_flesch_score ///
		_fleschkincaid_score ///
		_gunningfog_score ///
		_smog_score ///
		_dalechall_score ///
			, i(`id' `t') j(`g')
	
	foreach v in InstRank Year N MaxInst Maxt {
		summarize `v' if `t'==2, detail
		local `v' = `r(p50)'
	}
	foreach stat in `stats' {
		tempvar resid
		generate _`stat'_R = .
		forvalues gender=0/1 {
			forvalues time=1/2 {
				eststo est_`stat'_`gender'`time': regress _`stat'_score FemRatio N InstRank MaxInst Maxt Year i.Journal ///
					[aw=_weight] if `t'==`time' & `g'==`gender'
				predict double `resid', residuals
				replace _`stat'_R = _b[_cons] + _b[FemRatio]*(1-`g') + _b[N]*`N' + _b[InstRank]*`InstRank' + ///
					_b[MaxInst]*`MaxInst' + _b[Maxt]*`Maxt' + _b[Year]*`Year' + _b[1.Journal] + `resid' if `t'==`time' & `g'==`gender'
				drop `resid'
			}
		}
	}
	local df = `e(N)' - `e(df_r)'
	do `varlabels'
	if "`strategy'"=="propensity" {
		include "`do_path'/tableC12-C13"
	}
	********************************************
	
	********************************************
	******* Generate co-variate balance ********
	********************************************
	estimates clear
	preserve
	keep AuthorID _weight
	duplicates drop
	sort AuthorID
	tempfile matches
	save `matches'
	
	use `author_prematching', clear
	tempvar match
	merge 1:1 AuthorID using `matches', assert(master match) generate(`match')
	tempname b b1 b2
	local rnames
	foreach v of varlist T meanN minPubOrder AuthorOrderBin2 maxCiteCount maxInstRank meanYear Decade? Journal? JEL1_? {
		regress `v' i.Sex if T>=3
		matrix `b1' = nullmat(`b1') \ (_b[_cons], _b[_cons] + _b[1.Sex], -1*_b[1.Sex], -1*_b[1.Sex]/_se[1.Sex])
		
		regress `v' i.Sex if T>=3 & `match'==3 //[aw=_weight]
		matrix `b2' = nullmat(`b2') \ (_b[_cons] + _b[1.Sex], -1*_b[1.Sex], -1*_b[1.Sex]/_se[1.Sex])
		local rnames "`rnames' `v'"
	}
	matrix `b' = `b1' , `b2'
	matrix rownames `b' = `rnames'
	tempfile balance
	save `balance'
	if "`strategy'"=="propensity" {
		include "`do_path'/tableC8"
	}
	********************************************
	
	********************************************
	*************** Estimate Dik ***************
	********************************************
	restore
	reshape wide AuthorID Year FemRatio MaxInst N Journal InstRank Maxt T _weight ///
		_flesch_score _flesch_R ///
		_fleschkincaid_score _fleschkincaid_R ///
		_gunningfog_score _gunningfog_R ///
		_smog_score _smog_R ///
		_dalechall_score _dalechall_R ///
			, i(`id' `t') j(`g')
	reshape wide Year0 Year1 FemRatio0 FemRatio1 MaxInst0 MaxInst1 N0 N1 Journal0 Journal1 InstRank0 InstRank1 Maxt0 Maxt1 ///
		_flesch_score0 _flesch_score1 _flesch_R0 _flesch_R1 ///
		_fleschkincaid_score0 _fleschkincaid_score1 _fleschkincaid_R0 _fleschkincaid_R1 ///
		_gunningfog_score0 _gunningfog_score1 _gunningfog_R0 _gunningfog_R1 ///
		_smog_score0 _smog_score1 _smog_R0 _smog_R1 ///
		_dalechall_score0 _dalechall_score1 _dalechall_R0 _dalechall_R1 ///
			, i(`id') j(`t')
	
	tempname m ms a1 a2 a3 a4 a5 n
	forvalues i=1/3 {
		tempvar bf`i' sf`i' bm`i' sm`i' nf`i' nm`i'
		forvalues j=1/3 {
			tempvar b`i'`j' s`i'`j' n`i'`j'
		}
	}
	foreach stat in `stats' {
		
		* Male effects
		mean _`stat'_R12 [aw=_weight1]
		local df_correct = `e(df_r)'/(`e(N)'-2*`df'-1)
		matrix `m' = _b[_`stat'_R12]
		matrix `ms' = _se[_`stat'_R12]*`df_correct'
		ereturn_post `m', se(`ms') store(R_`stat')
		
		* Mean Conditions 1--2.
		generate _`stat'_Dtm = _`stat'_R12 - _`stat'_R11
		generate _`stat'_Dg = _`stat'_R02 - _`stat'_R12
		generate _`stat'_Dtf = _`stat'_R02 - _`stat'_R01
		
		tempvar D S
		
		mean _`stat'_Dg [aw=_weight1]
		local df_correct = `e(df_r)'/(`e(N)'-2*`df'-1)
		matrix `D' = _b[_`stat'_Dg]
		matrix `S' = _se[_`stat'_Dg]*`df_correct'
		
		mean _`stat'_Dtf [aw=_weight0]
		local df_correct = `e(df_r)'/(`e(N)'-2*`df'-1)
		matrix `D' = `D' , _b[_`stat'_Dtf]
		matrix `S' = `S' , _se[_`stat'_Dtf]*`df_correct'
	
		mean _`stat'_Dtm _`stat'_Dg [aw=_weight1]
		local df_correct = `e(df_r)'/(`e(N)'-2*`df'-1)
		matrix `D' = `D', _b[_`stat'_Dtm]
		matrix `S' = `S', _se[_`stat'_Dtm]*`df_correct'
		
		ereturn_post `D', se(`S') obs(`e(N)') store(D_`stat') colnames(dg dt_female dt_male)
		
		* Dik.
		generate _`stat'_D = 1 if _`stat'_Dtf>0 & _`stat'_Dg>0
		replace _`stat'_D = 0 if  _`stat'_Dtm>0 & _`stat'_Dg<0
		
		generate _`stat'_Ds1 = _`stat'_Dg if !missing(_`stat'_D)
		
		generate _`stat'_Ds2 = _`stat'_Ds1
		replace _`stat'_Ds2 = _`stat'_Dtf if _`stat'_D==1 & _`stat'_R01 > _`stat'_R12
		replace _`stat'_Ds2 = -1*_`stat'_Dtm if _`stat'_D==0 & _`stat'_R11 > _`stat'_R02
		
		generate _`stat'_Ds3 = _`stat'_Ds1
		replace _`stat'_Ds3 = . if _`stat'_Ds1>0 & T0>T1
		replace _`stat'_Ds3 = . if _`stat'_Ds1<0 & T0<T1
		
		* Sample mean Dik.
		forvalues i=1/3 {
			summarize _`stat'_Ds`i' [aw=_weight0] if _`stat'_D==1
			matrix `bf`i'' = nullmat(`bf`i''), r(mean)
			matrix `sf`i'' = nullmat(`sf`i''), r(sd)
			matrix `nf`i'' = nullmat(`nf`i''), r(N)
	
			summarize _`stat'_Ds`i' [aw=_weight1] if _`stat'_D==0
			matrix `bm`i'' = nullmat(`bm`i''), r(mean)
			matrix `sm`i'' = nullmat(`sm`i''), r(sd)
			matrix `nm`i'' = nullmat(`nm`i''), r(N)
			
			* Dik=0 when inconclusive.
			tempvar _`stat'_Ds2
			generate `_`stat'_Ds2' = _`stat'_Ds`i'
			replace `_`stat'_Ds2' = 0 if missing(_`stat'_D)
			mean `_`stat'_Ds2' [aw=_weight1]
			local df_correct = `e(df_r)'/(`e(N)'-2*`df'-1)
			matrix `b2`i'' = nullmat(`b2`i''), _b[`_`stat'_Ds2']
			matrix `s2`i'' = nullmat(`s2`i''), _se[`_`stat'_Ds2']*`df_correct'
			matrix `n2`i'' = nullmat(`n2`i''), e(N)
			
			* Dik=0 when inconclusive for women and Dik<0 when inconclusive for men.
			tempvar _`stat'_Ds3
			generate `_`stat'_Ds3' = `_`stat'_Ds2'
			replace `_`stat'_Ds3' = _`stat'_Dg if missing(_`stat'_D) & _`stat'_Dg<0
			mean `_`stat'_Ds3' [aw=_weight1]
			local df_correct = `e(df_r)'/(`e(N)'-2*`df'-1)
			matrix `b3`i'' = nullmat(`b3`i''), _b[`_`stat'_Ds3']
			matrix `s3`i'' = nullmat(`s3`i''), _se[`_`stat'_Ds3']*`df_correct'
			matrix `n3`i'' = nullmat(`n3`i''), e(N)
		}
		
		* Proportional effect on discrimination.
		mean _`stat'_R12 `_`stat'_Ds2' [aw=_weight1]
		matrix `a1' = nullmat(`a1') \ abs(_b[`_`stat'_Ds2'] / _b[_`stat'_R12])
		
		* Count observations one standard deviation above and below zero.
		summarize _`stat'_Ds1 [aw=_weight1]
		local sd = r(sd)
		count if _`stat'_D==1 & _`stat'_Ds1>`sd'
		local women = `r(N)'
		count if _`stat'_D==0 & _`stat'_Ds1<-1*`sd'
		local men = `r(N)'
		matrix `a2' = nullmat(`a2') \ `women' / `men'
		
		* Count observations exhibiting discrimination.
		count if !missing(_`stat'_D)
		matrix `n' = nullmat(`n') , `r(N)'
	}
	
	* Display average proportional effect on discrimination (2).
	matrix `a1' = diag(`a1')
	noisily display "Average proportional effect on discrimination (1): " round((trace(`a1') / colsof(`a1'))*100,0.01)
	
	* Display average ratio of observations above and below zero.
	matrix `a2' = diag(`a2')
	noisily display "Average ratio of observations above and below zero: " round((trace(`a2') / colsof(`a2')),0.01)
	
	* Percentage of matched pairs with Dik not equal to zero.
	matrix `a3' = diag(`n'/`=_N')
	noisily display "Average percentage of observations exhibiting evidence of discrimination: " round((trace(`a3') / colsof(`a3'))*100,0.01)
	
	* Percentage of Dik not equal to zero pairs in which Dik is positive.
	matrix `a4' = diag(hadamard(`nf1', vecdiag(inv(diag(`n')))))
	noisily display "Conditional on discrimination, percentage of pairs discriminating against women: " round((trace(`a4') / colsof(`a4'))*100,0.01)
	
	* Relative size of Dik.
	matrix `a5' = diag(hadamard(`bf1', vecdiag(inv(diag(`bm1')))))
	noisily display "Conditional on discrimination, ratio of female to male measures of discrimination: " abs(round((trace(`a5') / colsof(`a5')),0.01))
	
	forvalues i=1/3 {
		ereturn_post `bf`i'', se(`sf`i'') store(df`i') colnames(`stats') matrix(N `nf`i'')
		ereturn_post `bm`i'', se(`sm`i'') store(dm`i') colnames(`stats') matrix(N `nm`i'')
		ereturn_post `b2`i'', se(`s2`i'') store(d2`i') colnames(`stats') matrix(N `n2`i'')
		ereturn_post `b3`i'', se(`s3`i'') store(d3`i') colnames(`stats') matrix(N `n3`i'')
	}
	if "`strategy'"=="propensity" {
		include "`do_path'/table9"
		include "`do_path'/table10"
		include "`do_path'/tableC15"
		include "`do_path'/tableC16"
		include "`do_path'/tableC17"
		include "`do_path'/figure4"
	}
	else if "`strategy'"=="mahalanobis" {
		include "`do_path'/table9XA"
		include "`do_path'/table10XA"
		include "`do_path'/figure4XA"
	}
	********************************************
	
	********************************************
	****** Generate list of matched pairs ******
	********************************************
	preserve
	keep AuthorID*
	tempfile author_list
	save `author_list'

	odbc_compress, exec("SELECT AuthorID, AuthorName FROM Author;")
	tempfile names
	save `names'

	use `author_list', clear
	rename AuthorID0 AuthorID
	merge 1:m AuthorID using `names', assert(using match) keep(match) nogenerate

	rename (AuthorID AuthorName AuthorID1) (AuthorID0 AuthorName0 AuthorID)
	merge m:m AuthorID using `names', assert(using match) keep(match) nogenerate

	rename (AuthorID AuthorName) (AuthorID1 AuthorName1)
	
	* Last name, first name
	foreach v of varlist AuthorName* {
		tempvar `v'
		generate ``v'' = regexs(2) + ", " + regexs(1) + " (" + regexs(3) + ")" if regexm(`v', "(.*) (.*), (.*)")
		replace ``v'' = regexs(2) + ", " + regexs(1) if regexm(`v', "(.*) (.*)$") & missing(``v'')
		replace ``v'' = regexs(2) + " " + regexs(1) if regexm(``v'', "(.*) ((La)|(De)|([Vv][ao]n))$")
		drop `v'
		rename ``v'' `v'
	}
	* Sort by female author.
	tempvar sortkey
	generate `sortkey' = ustrsortkey(AuthorName0, "en")
	sort `sortkey'
	
	* Split to fit two columns onto one page
	count
	local split = ceil(`r(N)'/2)
	tempvar i j
	generate `j' = 1 in 1/`split'
	replace `j' = 2 in `++split'/l
	bysort `j': generate `i' = _n
	
	drop AuthorID* `sortkey'
	reshape wide AuthorName0 AuthorName1, i(`i') j(`j')
	
	if "`strategy'"=="propensity" {
		include "`do_path'/tableC14"
	}
	else if "`strategy'"=="mahalanobis" {
		include "`do_path'/tableC14XA"
	}
	restore
	********************************************
	
	********************************************
	** Generate balance for reconstructed Rit **
	********************************************
	preserve
	keep AuthorID* _flesch_D _fleschkincaid_D _gunningfog_D _smog_D _dalechall_D
	foreach stat in `stats' {
		tabulate _`stat'_D, generate(_`stat'_D)
		rename _`stat'_D2 _`stat'_D0
		drop _`stat'_D
	}

	tempvar id
	generate `id' = _n
	reshape long _flesch_D _fleschkincaid_D _gunningfog_D _smog_D _dalechall_D AuthorID, i(`id') j(male)

	merge m:m AuthorID using `balance', assert(using match) keep(match) nogenerate
	foreach stat in `stats' {
		local rnames
		tempname b_`stat'
		foreach v of varlist T meanN minPubOrder AuthorOrderBin2 maxCiteCount maxInstRank meanYear Decade? Journal? JEL1_? {
			regress `v' i._`stat'_D
			matrix `b_`stat'' = nullmat(`b_`stat'') \ (_b[_cons], _b[_cons] + _b[1._`stat'_D], -1*_b[1._`stat'_D], -1*_b[1._`stat'_D]/_se[1._`stat'_D])
			local rnames "`rnames' `v'"
		}
		matrix rownames `b_`stat'' = `rnames'
	}
	if "`strategy'"=="propensity" {
		include "`do_path'/tableC9-C11"
	}
	restore
	********************************************

}
exit