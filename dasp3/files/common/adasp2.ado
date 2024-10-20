
cap program drop adasp2
program adasp2
        version 10
        local inis $ini_daspa
        global prg_pointer = "main"
        if "`inis'"~="" {
        cap do "`inis'.dasp"
        }
        cap macro drop ini_daspa 
        global tempprj `inis'
end
