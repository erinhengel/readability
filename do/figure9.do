include master

use `time', clear
generate Mother = ChildReceived<=4|ChildAccepted<=4
collapse (firstnm) ReviewLength FemRatio PageN N PubOrder Year ReceivedYear Received Accepted Editor Maxt MaxInst CiteCount (max) Mother Birth, by(ArticleID AuthorID)
collapse (firstnm) ReviewLength FemRatio PageN N PubOrder Year ReceivedYear Received Accepted Editor Maxt MaxInst CiteCount (min) Mother Birth, by(ArticleID)

merge 1:m ArticleID using `nber', keep(match) nogenerate
generate ReleaseSubmit = (WPDate - Received)/30

local pdf_path "$home/Dropbox/Readability/draft/pdf"

regress ReleaseSubmit FemRatio i.Year, robust
margins, at(FemRatio=(0 1)) over(Year)
marginsplot, xdimension(Year) noci ///
	scheme(publishing-female) ///
	xlabel(1975(10)2015) ///
	ylabel(0 `""Journal" "submission" "(month 0)""') ///
	ytitle("") ///
	xtitle("") ///
	yline(0) ///
	title("Time difference (in mos.)", size(vsmall)) ///
	legend(order(1 "Male" 2 "Female"))
graph export "`pdf_path'/figure8.pdf", replace
