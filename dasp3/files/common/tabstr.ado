#delim ;
set more off;

cap program drop tabstr;
program define tabstr, rclass;
syntax namelist(min=1)[,   dec1(int 4)   dec2(int 4)   dec3(int 4)   dec4(int 4) dec5(int 4)   dec6(int 4) ];
local nmat: word count `namelist' ;  
tokenize `namelist' ;
local nr = rowsof(`1');
local nc = colsof(`1');
forvalues c=1/`nc' {;
local sc_`c' = 9;
forvalues m=1/`nmat' {;
forvalues r=1/`nr'   {;
   local val = el(``m'',`r',`c') ;
   local ll = int(`val') ;
   local zz = "`ll'";
   local vv = length("`zz'");
   local sc_`c' = max(`sc_`c'', `vv'+`dec`c'' + 1);
};	
};
/* dis "col `c' : " `sc_`c'' ; */
return scalar wic`c' = `sc_`c'' ;
};


end;