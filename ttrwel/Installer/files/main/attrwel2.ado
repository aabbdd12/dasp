

cap program drop attrwel2
program attrwel2
	version 10
	local inis $ini_ttrwel
	global prg_pointer = "main"
	if "`inis'"~="" {
	cap do "`inis'.trw"
	}
	cap macro drop ini_ttrwel 
	global tempprj `inis'
end
