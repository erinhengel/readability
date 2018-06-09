quietly {
	********************************************
	****** Avg. first, mean & last scores ******
	********************************************
	use `author', clear
	sort AuthorID t
	tempname B b
	foreach stat in `stats' {
		preserve
		collapse (mean) Mean=_`stat'_score (first) Sex First=_`stat'_score (last) Last=_`stat'_score if T>2, by(AuthorID)
		label values Sex gender
		mean First Mean Last, over(Sex)
		ereturn_post e(b) e(V), obs(`e(N)') dof(`e(df_r)') store(est_`stat')
		
		* Percentage change from first score (cf. Section 3.3)
		matrix `b' = e(b)
		matrix `b' = (`b'[1, 3]-`b'[1,1])/`b'[1,1] \ (`b'[1, 4]-`b'[1,2])/`b'[1,2] \ (`b'[1, 5]-`b'[1,1])/`b'[1,1] \ (`b'[1, 6]-`b'[1,2])/`b'[1,2]
		matrix `B' = nullmat(`B') , 100*`b'
		restore
	}
	matrix rownames `B' = Mean:Women Mean:Men Last:Women Last:Men
	
	include "`do_path'/tableB1"
	********************************************
	estimates clear
}
exit