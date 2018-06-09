local fpath "~/Dropbox/Readability/draft/pdf"

include master
use `article', clear
summarize FemRatio if Journal==1
local aer = round(r(mean)*100, 0.01)
summarize FemRatio if Journal==2
local eca = round(r(mean)*100, 0.01)
summarize FemRatio if Journal==3
local jpe = round(r(mean)*100, 0.01)
summarize FemRatio if Journal==4
local qje = round(r(mean)*100, 0.01)


use `author', clear
generate Fem = Sex==0
collapse (sum) Fem, by(Journal)
graph pie Fem, ///
	scheme(publishing-female) ///
	over(Journal) ///
	plabel(1 "{it:AER}" "`aer' %", size(large)) ///
	plabel(2 "{it: Econometrica}" "`eca' %", size(large)) ///
	plabel(3 "{it:JPE}" "`jpe' %", size(large)) ///
	plabel(4 "{it:QJE}" "`qje' %", size(large)) ///
	pie(1, color(pfblue)) ///
	pie(2, color(pfyellow)) ///
	pie(3, color(pfpink)) ///
	pie(4, color(pfteal)) ///
	legend(off)
graph export "`fpath'/journal.pdf", replace
