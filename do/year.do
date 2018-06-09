local fpath "~/Dropbox/Readability/draft/pdf"

preserve
collapse (mean) _flesch_score _fleschkincaid_score _gunningfog_score _smog_score _dalechall_score, by(Year)
tsset Year

local colour1 "216 92 99"
local colour2 "42 157 143"
local colour3 "52 108 139"
local colour4 "255 193 69"

keep if Year>1985
tssmooth ma ma_flesch_score=_flesch_score, window(5)
tssmooth ma ma_dalechall_score=_dalechall_score, window(5)
graph twoway ///
	(line ma_flesch_score Year, color("`colour1'") lwidth(medium) yaxis(1)) ///
	(line ma_dalechall_score Year, color("`colour2'") lwidth(medium) yaxis(2)) ///
	, xlabel(1990(5)2015) ///
	scheme(publishing-female) ///
	xtitle("") legend(off) ///
	ytitle("Flesch Reading Ease", axis(1)) ytitle("-1 ⨉ Dale-Chall", axis(2)) ///
	aspectratio(1.75, placement(west))
graph export "`fpath'/year.pdf", replace
restore
