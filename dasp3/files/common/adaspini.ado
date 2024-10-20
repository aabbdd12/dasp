

cap program drop adaspini
program adaspini
	version 10
    args dof
  tokenize `dof' ,  parse(".")
   local dof = "`1'"
	global ini_daspa `dof'
	discard
    db $cdb
	//macro drop $ini_daspa
end


