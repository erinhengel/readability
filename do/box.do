import delimited ~/Dropbox/Readability/dta/correlations.txt, ///
	case(preserve) ///
	clear ///
	varnames(1) ///
	encoding("utf-8")

preserve
by TestType Source, sort: generate Study = cond(_n==1, 1, 0)
table TestType, contents(median Correlation freq sum Study) replace
rename (table*) (median corrs studies)
sort median
tempname bd
mkmat median corrs studies, matrix(`bd') rownames(TestType)
restore

graph box Correlation, ///
	over(TestType, ///
		sort(1) ///
		gap(85) ///
		relabel(1 `""Human judgement{sup}{c 134}""' 2 `""Oral reading fluency""' 3 `""Comprehension tests""' 4 `""Readability scores""' 5 `""Cloze procedure""')) ///
	scheme(publishing-female) ///
	nooutsides ///
	note("") ///
	legend(off) ///
	title("") subtitle("Correlation", placement(nwest) size(vsmall)) ytitle("") ///
	asyvars showyvars ///
	medtype(cline) medline(lcolor(white) lwidth(vthin) lpattern(solid)) cwhiskers lines(lwidth(vthin)) alsize(0) ///
	intensity(90) lintensity(90) ///
	graphregion(margin(small)) ///
	box(1, color(pfblue)) ///
	box(2, color(pfblue)) ///
	box(3, color(pfblue)) ///
	box(4, color(pfyellow)) ///
	box(5, color(pfblue)) ///
	text(`"`: display `bd'[1,1]+0.001'"' 8 `"{it: N} = `: display `bd'[1,2]'"' " " "`: display `bd'[1,3]' studies", size(vsmall) color(white)) ///
	text(`"`: display `bd'[2,1]+0.002'"' 29 `"{it: N} = `: display `bd'[2,2]'"' " " "`: display `bd'[2,3]' studies", size(vsmall) color(white)) ///
	text(`"`: display `bd'[3,1]+0.002'"' 50 `"{it: N} = `: display `bd'[3,2]'"' " " "`: display `bd'[3,3]' studies", size(vsmall) color(white)) ///
	text(`"`: display `bd'[4,1]+0.004'"' 71 `"{it: N} = `: display `bd'[4,2]'"' " " "`: display `bd'[4,3]' studies", size(vsmall) color(white)) ///
	text(`"`: display `bd'[5,1]+0.003'"' 92 `"{it: N} = `: display `bd'[5,2]'"' " " "`: display `bd'[5,3]' studies", size(vsmall) color(black))
graph export ~/Dropbox/Readability/draft/pdf/figure0X.pdf, replace
// graph export ~/Dropbox/Readability/presentation/COSME/pdf/figure0X.pdf, replace

preserve
drop if TestType=="RS"
distinct Source
display "Distinct studies showing correlations with alternative measures of readability: " r(ndistinct)

exit