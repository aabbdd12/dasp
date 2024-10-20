



cap program drop ttrwell_ini_trw
program ttrwell_ini_trw
	version 10
    args dof
  tokenize `dof' ,  parse(".")
   local dof = "`1'"
	global ini_ttrwel `dof'
	
	discard
    db ttrwel
    
end


