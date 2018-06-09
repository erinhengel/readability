local fpath "~/Dropbox/Readability/draft/pdf"

binscatter asinhCiteCount _flesch_score if Year>2000 ///
	, scheme(publishing-female) ///
	legend(off) ///
	name(female, replace) ///
	color(pfblue pfblue) ///
	xtitle("Flesch Reading Ease", placement(seast)) ytitle("") title("") subtitle("Citation count (asinh)", placement(nwest) size(vsmall))

graph export "`fpath'/asinhCiteCount.pdf", replace

