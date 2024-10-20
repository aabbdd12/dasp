
cap program drop shexp_db_ini
program shexp_db_ini
	version 10
    args dof
  tokenize `dof' ,  parse(".")
   local dof = "`1'"
	global shexp_db_ini `dof'
	discard
    db shexp
    
end


