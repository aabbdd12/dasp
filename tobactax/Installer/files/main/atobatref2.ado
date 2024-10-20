

cap program drop atobatref2
program atobatref2
	version 10
	local inis $ini_tobatref
	global prg_pointer = "main"
	if "`inis'"~="" {
	cap do "`inis'.trw"
	}
	cap macro drop ini_tobatref 
	global tempprj `inis'
end
