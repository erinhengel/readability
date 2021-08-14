program odbc_compress
	syntax [, exec(string) clear *]
	
	odbc load, exec(`"`exec'"') clear `options'
	destring, replace
	compress
end
exit