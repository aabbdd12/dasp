capture program drop Init_DB
program define Init_DB
	syntax [namelist] [, ndb(string)]
	local namelist  a b css

	foreach v of local namelist {
		//capture confirm numeric variable  `v'
		/*if ! _rc {*/
			.`ndb'_dlg.variables.Arrpush "`v'"
		/*}*/
	}

	global cdb = "`ndb'"
end