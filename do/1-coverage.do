quietly {
	********************************************
	********* Generate coverage data. **********
	********************************************
	#delimit ;
	local sql "
	SELECT COUNT(ArticleID) AS _, Journal,
	CASE
		WHEN CAST(SUBSTR(PubDate, 1, 4) AS INTEGER) < 1960 THEN '1950--59'
		WHEN CAST(SUBSTR(PubDate, 1, 4) AS INTEGER) < 1970 THEN '1960--69'
		WHEN CAST(SUBSTR(PubDate, 1, 4) AS INTEGER) < 1980 THEN '1970--79'
		WHEN CAST(SUBSTR(PubDate, 1, 4) AS INTEGER) < 1990 THEN '1980--89'
		WHEN CAST(SUBSTR(PubDate, 1, 4) AS INTEGER) < 2000 THEN '1990--99'
		WHEN CAST(SUBSTR(PubDate, 1, 4) AS INTEGER) < 2010 THEN '2000--09'
		WHEN CAST(SUBSTR(PubDate, 1, 4) AS INTEGER) < 2020 THEN '2010--15'
	END Decade
		FROM Article
		WHERE Language = 'English' AND Journal <> 'P&P'
	GROUP BY Journal, Decade
	UNION
	SELECT COUNT(ArticleID) AS _, Journal, 'Total' AS Decade
		FROM Article
		WHERE Language = 'English' AND Journal <> 'P&P'
	GROUP BY Journal
	";
	#delimit cr
	odbc_compress, exec("`sql'") dsn(readdb)
	reshape wide _, i(Decade) j(Journal) string
	egen DecadeTotal = rowtotal(_*)
	compress
	tempfile coverage
	save `coverage'
	
	tempname N
	mkmat _* DecadeTotal, matrix(`N') rownames(Decade)
	include "`do_path'/table1"
	********************************************
	estimates clear
}
exit