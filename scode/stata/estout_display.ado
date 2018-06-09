program estout_display, rclass
	syntax anything [, note(string) title(string) style(string) *]
	
	preserve
	
	* Make substitutions to labels per .def file.
	if "`style'"!="" {
		quietly findfile `"estout_`style'.def"'
		tempname fh
		local linenum = 0
		file open `fh' using `"`r(fn)'"', read
		file read `fh' line
		while r(eof)==0 {
			tokenize `"`line'"'
			if `"`1'"'=="substitute" {
				local substitute = trim(usubinstr(`"`line'"', "substitute", "", 1))
				local S: word count `macval(substitute)'
				forv s = 1(2)`S' {
					local from: word `s' of `macval(substitute)'
					local to:  word `=`s'+1' of `macval(substitute)'
					if `"`macval(from)'`macval(to)'"'!="" {
						foreach varname of varlist * {
							local oldlab : variable label `varname'
							local newlab: subinstr local oldlab `"`macval(from)'"' `"`macval(to)'"', all
							label variable `varname' `"`newlab'"'
							local labname : value label `varname'
							if "`labname'"!="" {
								quietly label list `labname'
								forvalues i=`r(min)'/`r(max)' {
									local oldlab : label `labname' `i'
									local newlab: subinstr local oldlab `"`macval(from)'"' `"`macval(to)'"', all
									label define `labname' `i' `"`newlab'"', modify
								}
							}
						}
					}
				}
				continue, break
			}
			file read `fh' line
		}
		file close `fh'
		local style style(`"`style'"')
	}
	
	if `"`title'"' != "" {
		local title = "{title:`title'}"
	}
	
	if `"`note'"' != "" {
		* Find numbers and format.
		while ustrregexm(`"`note'"', "[^\w](\d{4,})") {
			local num = ustrregexs(1)			
			local format_num : display %9.0fc `num'
			local note = usubinstr(`"`note'"', "`num'", "`format_num'", 1)
		}
		
		* Fix mis-formmated years.
		local note = subinstr(`"`note'"', "2,015", "2015", .)
		local note = subinstr(`"`note'"', "1,950", "1950", .)
		
		* Save data for later restore
		tempfile data
		quietly save `data'
		
		* Find text replacements.
		quietly findfile "substitute.csv"
		quietly import delimited find replace using `"`r(fn)'"', clear encoding("utf-8")
		forvalues i=1/`=_N' {
			local note = usubinstr(`"`note'"', `"`=find[`i']'"', `"`=replace[`i']'"', .)
			local title = usubinstr(`"`title'"', `"`=find[`i']'"', `"`=replace[`i']'"', .)
		}
		use `data', clear
		
		* Remove LaTeX.
		while ustrregexm(`"`note'"', "\\text\{(.*)\}") {
			local code = ustrregexs(0)
			local text = ustrregexs(1)
			local note = usubinstr(`"`note'"', "`code'", "`text'", 1)
		}
		
		local regexm = ustrregexm(`"`note'"', "(.*),\s?width\((.*)\)\s?$")
		local colwidth = trim(ustrregexs(2))
		if "`colwidth'" == "" {
			local colwidth = 100
		}
		else {
			confirm integer number `colwidth'
			local note = ustrregexs(1)
		}
		
		local note = ustrtrim(stritrim(`"`note'"'))
		local note = subinstr(`"`note'"', "( ", "(", .)
		local note = subinstr(`"`note'"', " )", ")", .)
		
		* Save note to rclass local.
		return local note `"`note'"'
		
		* Add SMCL formatting.
		local note = `"{p 0 0 0 `colwidth'} `note' {p_end}"'
	}
	
	estout `anything', note(`"`note'"') title(`"`title'"') `style' `options'
	restore
end
exit