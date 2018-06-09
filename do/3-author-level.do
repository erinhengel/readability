quietly {
	********************************************
	********** Author-level analysis. **********
	********************************************
	use `author', clear
	merge m:1 ArticleID using "/tmp/readstat", assert(using match) keep(match)
	sort AuthorID t
	// keep if mod(ArticleID, 3)==0
	// foreach dvar in FemRatio Fem100 Female Fem50 {
	// 	tempname b se mb mV p
	// 	foreach stat in `stats' {
	// 		noisily display "`stat'"
	// 		eststo author: xtabond2 _`stat'_score L._`stat'_score `dvar' c.`dvar'#1.Sex N CiteCount i.NativeEnglish i.Journal##i.Year i.Editor i.MaxInst i.MaxT ///
	// 			[aweight=AuthorWeight], gmm(L._`stat'_score) iv(`dvar' c.`dvar'#i.Sex N CiteCount i.NativeEnglish i.Journal##i.Year i.Editor i.MaxInst i.MaxT) ///
	// 			cluster(AuthorID Editor) small h(2)
	// 		lincom _b[`dvar'] + _b[1.Sex#c.`dvar']
	// 		matrix `b' = (_b[`dvar'] , r(estimate), _b[1.Sex#c.`dvar'], _b[L._`stat'_score])
	// 		matrix `se' = (_se[`dvar'] , r(se), _se[1.Sex#c.`dvar'], _se[L._`stat'_score])
	// 		ereturn_post `b', se(`se') obs(`e(N)') dof(`e(df_r)') local(editor ✓ journal ✓ year ✓ jnlyr ✓ inst ✓ qual ✓¹ Nj ✓ native ✓) scalar(N_g `e(N_g)' ar1 `e(ar1)' ar2 `e(ar2)') colnames(Female Male Interaction L._stat_score) store(est_`dvar'_`stat')
	// 		local N_g = `e(N_g)'
	//
	// 		if "`dvar'"=="FemRatio" {
	// 			* Percent female > male.
	// 			estimates restore author
	// 			local bFem = _b[`dvar']
	// 			margins, at(`dvar'=0) post
	// 			matrix `p' = (nullmat(`p') \ 100*abs(`bFem'/_b[_cons]))
	//
	// 			* Appendix: Male effects.
	// 			matrix `mb' = e(b)
	// 			matrix `mV' = e(V)
	// 			ereturn_post `mb' `mV', obs(`e(N)') local(editor ✓ journal ✓ year ✓ jnlyr ✓ inst ✓ qual ✓¹ Nj ✓ native ✓) store(male_`stat')
	// 		}
	// 	}
	// 	if "`dvar'"=="FemRatio" {
	// 		include "`do_path'/table5"
	// 		include "`do_path'/tableC4"
	// 	}
	// 	else if "`dvar'"=="Fem100" {
	// 		include "`do_path'/tableC5c"
	// 	}
	// 	else if "`dvar'"=="Female" {
	// 		include "`do_path'/tableC5a"
	// 	}
	// 	else if "`dvar'"=="Fem50" {
	// 		include "`do_path'/tableC5b"
	// 	}
	// }
	
	* Alternative program for calculating readability statistics
	tempname b se
	foreach stat in Flesch_Kincaid Gunning_Fog_Index SMOG {
		noisily display "`stat'"
		eststo author: xtabond2 `stat' L.`stat' FemRatio c.FemRatio#1.Sex N CiteCount i.NativeEnglish i.Journal##i.Year i.Editor i.MaxInst i.MaxT ///
			[aweight=AuthorWeight], gmm(L.`stat') iv(FemRatio c.FemRatio#i.Sex N CiteCount i.NativeEnglish i.Journal##i.Year i.Editor i.MaxInst i.MaxT) ///
			cluster(AuthorID Editor) small h(2)
		lincom _b[FemRatio] + _b[1.Sex#c.FemRatio]
		matrix `b' = (_b[FemRatio] , r(estimate), _b[1.Sex#c.FemRatio], _b[L.`stat'])
		matrix `se' = (_se[FemRatio] , r(se), _se[1.Sex#c.FemRatio], _se[L.`stat'])
		ereturn_post `b', se(`se') obs(`e(N)') dof(`e(df_r)') local(editor ✓ journal ✓ year ✓ jnlyr ✓ inst ✓ qual ✓¹ Nj ✓ native ✓) scalar(N_g `e(N_g)' ar1 `e(ar1)' ar2 `e(ar2)') colnames(Female Male Interaction L.L._stat_score) store(ALT_`stat')
	}
	include "`do_path'/table5APPENDIX"
	
	********************************************
	estimates clear
}
exit
