
cap program drop dasp_db_ini
program dasp_db_ini
	version 10
    args dof
  tokenize `dof' ,  parse(".")
   local dof = "`1'"
	global dasp_db_ini `dof'
	discard
    db difgt
    
end


