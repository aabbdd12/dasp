
cap program drop ashexp2
program ashexp2
        version 10
        local inis $shexp_db_ini
        global prg_pointer = "main"
        if "`inis'"~="" {
        cap do "`inis'.shexp"
        }
        cap macro drop shexp_db_ini 
        global tempprj `inis'
end
