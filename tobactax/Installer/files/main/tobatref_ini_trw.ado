



cap program drop tobatrefl_ini_trw
program tobatrefl_ini_trw
	version 10
    args dof
  tokenize `dof' ,  parse(".")
   local dof = "`1'"
	global ini_tobatref `dof'
	
	discard
    db tobatref
    
end


