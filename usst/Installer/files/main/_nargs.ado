/********************************************************************************/
/*  Package       : USST //Usefull Stata Tools                                  */
/*  Version       :   0.10   //                       JUNE         2020         */
/*  Stata Version : Required  15.0 and higher                                   */
/*  Authors       : Abdelkrim Araar  // aabd@ecn.ulaval.ca                      */
/********************************************************************************/


#delim ;
capture program drop _nargs;
program define _nargs, rclass;
version 9.2;
syntax varlist(min=0);
quietly {;
tokenize `varlist';
local k = 1;
mac shift;
while "``k''" ~= "" {; 
local k = `k'+1;
};
};
global indica=`k';
end;
