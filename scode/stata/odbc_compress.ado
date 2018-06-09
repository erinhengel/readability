program odbc_compress
	syntax [, exec(string) dsn(string) clear *]
	odbc load, exec(`"`exec'"') dsn(`"`dsn'"') clear `options'
	destring, replace
	compress
end
exit