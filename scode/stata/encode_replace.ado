program encode_replace
	syntax varname [, *]
		
	tempname `varlist'
	rename `varlist' ``varlist''
	encode ``varlist'', generate(`varlist') `options'
end
exit