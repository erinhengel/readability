quietly {
	********************************************
	******** Generate review time data. ********
	********************************************
	#delimit ;
	local sql "
	SELECT ArticleID, AuthorCorr.AuthorID AS AuthorID, CAST(STRFTIME('%Y', PubDate) AS INTEGER) AS Year, Received, Accepted,
	CAST(STRFTIME('%Y', Received) AS INTEGER) AS ReceivedYear,
	LastPage - FirstPage AS PageN, (JULIANDAY(Accepted) - JULIANDAY(Received)) / 30 AS ReviewLength,
	CASE WHEN Children.Year BETWEEN CAST(STRFTIME('%Y', Received) AS INTEGER) AND CAST(STRFTIME('%Y', Accepted) AS INTEGER) THEN 1 ELSE 0 END AS Birth,
	CAST(CASE WHEN Received-Children.Year>=0 THEN Received-Children.Year ELSE NULL END AS INTEGER) AS ChildReceived,
	CASE WHEN Accepted-Children.Year>=0 THEN Accepted-Children.Year ELSE NULL END AS ChildAccepted
		FROM Article
		NATURAL JOIN AuthorCorr
		LEFT OUTER JOIN Children ON AuthorCorr.AuthorID=Children.AuthorID
		WHERE Received IS NOT NULL
	";
	#delimit cr
	odbc_compress, exec("`sql'") dsn(readdb)
	date_replace Received, mask("YMD")
	date_replace Accepted, mask("YMD")
	merge m:1 ArticleID using `article', keep(master match) nogenerate
	do `varlabels'
	compress
	* Drop Andrea Wilson.
	// drop if ArticleID==8273
	* Drop articles that take more than 100 months.
	// drop if ReviewLength>100
	tempfile time
	save `time'
	********************************************
	
	********************************************
	******** Econometrica review times. ********
	********************************************
	use `time', clear
	// local year Year
	local year ReceivedYear
	foreach dvar in FemRatio Fem100 Female Fem50 {
		foreach i of numlist 2/4 9 17 {
			preserve
				generate Mother = ChildReceived<=`i'|ChildAccepted<=`i'
				collapse (firstnm) ReviewLength `dvar' PageN N PubOrder Year ReceivedYear Editor Maxt MaxInst CiteCount (max) Mother Birth, by(ArticleID AuthorID)
				collapse (firstnm) ReviewLength `dvar' PageN N PubOrder Year ReceivedYear Editor Maxt MaxInst CiteCount (min) Mother Birth, by(ArticleID)
			
				eststo est_`i'_`dvar': regress ReviewLength `dvar' Mother Birth Maxt PageN N PubOrder CiteCount i.MaxInst i.`year' i.Editor, vce(cluster Year)
				estadd local year = "✓" : est_`i'_`dvar'
				estadd local inst = "✓" : est_`i'_`dvar'
				estadd local editor = "✓" : est_`i'_`dvar'
			
				count if Mother
				local momN = r(N)
				count if Birth
				local birthN = r(N)
				noisily display "Age threshold `=`i'+1', papers by mothers: " %2.0fc `momN' "; papers with births: " %2.0fc `birthN'
			
				if `i'==4 {
					* Exclude motherhood & birth indicators.
					eststo est_`i'_exclude_`dvar': regress ReviewLength `dvar' Maxt PageN N PubOrder CiteCount i.MaxInst i.`year' i.Editor if !Mother & !Birth, vce(cluster `year')
					eststo est_`i'_nomom_`dvar': regress ReviewLength `dvar' Birth Maxt PageN N PubOrder CiteCount i.MaxInst i.`year' i.Editor, vce(cluster `year')
					eststo est_`i'_nobirth_`dvar': regress ReviewLength `dvar' Mother Maxt PageN N PubOrder CiteCount i.MaxInst i.`year' i.Editor, vce(cluster `year')
					eststo est_`i'_none_`dvar': regress ReviewLength `dvar' Maxt PageN N PubOrder CiteCount i.MaxInst i.`year' i.Editor, vce(cluster `year')
				
					* Add JEL.
					merge 1:1 ArticleID using `primary_jel', keep(match) nogenerate
					eststo est_`i'_90s_`dvar': regress ReviewLength `dvar' Mother Birth Maxt PageN N PubOrder CiteCount i.MaxInst i.`year' i.Editor, vce(cluster `year')
					eststo est_`i'_jel_`dvar': regress ReviewLength `dvar' Mother Birth Maxt PageN N PubOrder CiteCount i.MaxInst i.`year' i.Editor JEL1_*, vce(cluster `year')
					estadd local jel = "✓" : est_`i'_jel_`dvar'
				
					foreach ind in year inst editor {
						foreach reg in nomom nobirth none exclude jel 90s {
							estadd local `ind' = "✓" : est_`i'_`reg'_`dvar'
						}
					}
				
					estimates restore est_`i'_`dvar'
					noisily display "{title:Age threshold 5}"
					margins, at(`dvar'=0)
					tempname m
					matrix `m' = r(table)
					noisily display "Male review time: " %6.2fc `m'[1,1] " (standard error: " %4.3fc `m'[2,1] ")"
					count if `dvar'==1
					noisily display "Papers by women: " %4.0fc r(N)
					summarize ReviewLength, detail
					local p75 = r(p75)
					count if ReviewLength < r(p25) & `dvar'==1
					local p25 = r(N)
					noisily display "Papers by women with review times below 25th percentile: " %2.0fc `p25'
					count if ReviewLength > `p75' & `dvar'==1
					local p75 = r(N)
					noisily display "Papers by women with review times above 75th percentile: " %2.0fc `p75'
					noisily display "Women's ratio 75th/25th: " %6.2fc `p75' / `p25'
				
					* Sample sizes.
					count if `dvar'>0
					local fem_sample = r(N)
					count if `dvar'==1 & Mother
					local mom_sample = r(N)
					count if `dvar'==1 & Birth
					local birth_sample = r(N)
					count if !Mother & !Birth
					local exclude_sample = r(N)
				}
			restore
		}
		if "`year'"=="Year" {
			if "`dvar'"=="FemRatio" {
				include "`do_path'/table11"
				include "`do_path'/tableC18"
			}
			else if "`dvar'"=="Fem100" {
				include "`do_path'/table11XA"
			}
			else if "`dvar'"=="Female" {
				include "`do_path'/table11XB"
			}
			else if "`dvar'"=="Fem50" {
				include "`do_path'/table11XC"
			}
		}
		else if "`year'"=="ReceivedYear" {
			include "`do_path'/table11XXA"
		}
	}
	********************************************
	estimates clear
}
exit