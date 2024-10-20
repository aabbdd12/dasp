cap program drop dismat
program define dismat

syntax namelist (min=1 max=1) [if] [in] [,  TITLE(string) DEC(int 6)]

#delimit ;
tokenize `namelist';
local matname = "`1'";
dis "`title'";
local cilc = 38;
                noi di in smcl in gr "{hline 9}{c TT}{hline 49}";

                 noi di in smcl in gr "         {c |}" /*
                 */ _col(14) "Est. val." _col(25) /*
                 */ "Std. Err."  _col(`cilc') `"[`=strsubdp("`level'")'95% Conf. interval]"';
                 noi di in smcl in gr "{hline 9}{c +}{hline 49}"; 


                  

 forvalues i=1/10 {;
 
 
  local lbl = "%9.0g  `lb'";
  
 local beg = 9 - length(`"Decile_0`i'"');
 
 local est=el(`matname',`i',1);
 local ste=el(`matname',`i',2);
 local lb =el(`matname',`i',3);
 local ub =el(`matname',`i',4);

   
                 noi di in smcl in gr _col(`beg') `"Decile_`i'"' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %10.`dec'f   `est'   /*
                 */ _col(24) %10.`dec'f   `ste'     /*
                 */ _col(36) %10.`dec'f   `lb'  /*
                 */ _col(48) %10.`dec'f   `ub';
                 
};




di in smcl in gr "{hline 9}{c BT}{hline 49}";
 noi di _n;
end;






