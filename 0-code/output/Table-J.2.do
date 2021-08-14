********************************************************************************
*************************** Table J.2: Matched pairs ***************************
********************************************************************************
* Get author names.
odbc_compress, exec("SELECT AuthorID, AuthorName FROM Author;") conn(`"`connstr'"')
tempfile names
save `names'

* Match AuthorIDs to male names then to female names.
use "0-data/generated/author_matching", clear
keep AuthorID*
rename AuthorID0 AuthorID
merge 1:m AuthorID using `names', assert(using match) keep(match) nogenerate
rename (AuthorID AuthorName AuthorID1) (AuthorID0 AuthorName0 AuthorID)
merge m:m AuthorID using `names', assert(using match) keep(match) nogenerate
rename (AuthorID AuthorName) (AuthorID1 AuthorName1)

* List last name, first name
foreach v of varlist AuthorName* {
	tempvar `v'
	generate ``v'' = regexs(2) + ", " + regexs(1) + " (" + regexs(3) + ")" if regexm(`v', "(.*) (.*), (.*)")
	replace ``v'' = regexs(2) + ", " + regexs(1) if regexm(`v', "(.*) (.*)$") & missing(``v'')
	replace ``v'' = regexs(2) + " " + regexs(1) if regexm(``v'', "(.*) ((La)|(De)|([Vv][ao]n))$")
	drop `v'
	rename ``v'' `v'
}
* Sort unicode string by female author name.
tempvar sortkey
generate `sortkey' = ustrsortkey(AuthorName0, "en")
sort `sortkey'

* Split list into two columns.
count
local split = ceil(`r(N)'/2)
tempvar i j
generate `j' = 1 in 1/`split'
replace `j' = 2 in `++split'/l
bysort `j': generate `i' = _n
drop AuthorID* `sortkey'
reshape wide AuthorName0 AuthorName1, i(`i') j(`j')

* Create LaTeX table.
listtex AuthorName* using "0-tex/generated/Table-J.2.tex", replace end("\\")
create_latex using "0-tex/generated/Table-J.2.tex", tablename("matchlist")
********************************************************************************
