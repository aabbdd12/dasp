

#delimit ;
cap program drop tobelas;
program define tobelas, eclas;
syntax varlist(min=2 max=2)[, 
DECILE(varname)
indcon(string) 
indcat(string) 
DEC(int  4)
DREGRES(int 0)
ELASFILE(string)
DGRA(int 0)   *];



tokenize `varlist';

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);



cap drop if `1' == 0 | `1' ==. ;
cap drop if `2' ==. ;

cap drop  LnQuantity ;
qui gen   LnQuantity = ln(`1');
cap drop  LnPrice ;
qui gen   LnPrice  = ln(`2');


if ("`decile'" ~="") {;
cap drop LnPrice_Decile_* ;
	forvalues i=1/10 {;
	tempvar lnpr_`i';
	*gen `lnpr_`i'' = LnPrice*(`i'==`decile') ;
	cap drop  LnPrice_Decile_0`i' ;
	if `i' <= 9  gen LnPrice_Decile_0`i' = LnPrice*(`i'==`decile') ;
	cap drop  LnPrice_Decile_10 ;
	if `i' == 10 gen LnPrice_Decile_`i'  = LnPrice*(`i'==`decile') ;
	*label var `lnpr_`i'' "LnPrice*Decile_`i'" ;
	};
	};
	
if ("`indcat'"~="")	 {;
tokenize `indcat';
_nargs `indcat';
forvalues i=1/$indica {;
local catindep `catindep' i.``i'' ;
};
};

                       local disreg = "";
if   (`dregres' == 0)  local disreg = "qui" ;
eststo clear;
`disreg' svy: reg LnQuantity LnPrice `catindep' `indcon';
eststo m1;
if ("`decile'" ~="") {;
`disreg' svy: reg LnQuantity LnPrice_Decile_01-LnPrice_Decile_10  `catindep' `indcon';
 eststo m2;
};

if ("`decile'" =="") esttab m1, not  r2 mtitle("(Model 01)" ) nodepvars nonumbers b(`dec') varwidth(34) label;
if ("`decile'" ~="") esttab m1 m2, not r2 mtitle("(Model 01)" "(Model 02)") nodepvars nonumbers b(`dec') varwidth(34) label;


if ((`dgra'==1 | "`elasfile'" ~= "")& "`decile'" ~="") {;
qui svy: reg LnQuantity LnPrice_Decile_01-LnPrice_Decile_10  `catindep' `indcon';
	matrix aa = r(table)';
	tempname varx ;
    matrix `varx' = (1 \2 \3 \4 \5 \6 \7 \8 \9 \10);
	matrix bb = `varx', aa[1..10,1..1],aa[1..10,5..5],aa[1..10,6..6];
};

if (("`elasfile'" ~= "")& "`decile'" ~="") {;

preserve;
svmat bb , names(_re_);
cap drop decile;
cap drop est_medium;
cap drop est_lower;
cap drop est_upper;
rename _re_1 decile;
rename _re_2 est_medium;
rename _re_3 est_lower;
rename _re_4 est_upper;
keep in 1/10;
keep decile est_medium est_lower est_upper;
save `elasfile', replace;
restore; 
};


/*return list;*/
if (`dgra'==1 & "`decile'" ~="") {;
cmnpe bb,  min(0) max(10) band(1.0) 
title("The estimated price elasticity by decile(s)")  
subtitle("(The subtitle)")
xtitle("Decile") 
ytitle("Estimated elasticities") 

/* note("Source: Author̳ estimation using a price shock of `cprinc'%") */
 
lab1("Estimated elasticity")  
;

};

cap drop  LnQuantity ;
cap drop  LnPrice ;
forvalues i=1/10 {;
	cap drop  LnPrice_Decile_0`i' ;
	cap drop  LnPrice_Decile_i' ;
	};
cap matrix drop bb;
end;

*set trace on;
/*
cd C:\PDATA\WB\Alan_Fuchs\temp\tobelas;
use mydata_cig, replace;
svyset _n [pweight=weight], vce(linearized) singleunit(missing);
gen lnx = ln(i_cap_gc) ; 
save , replace;
tobelas quantity pricet, decile(decile) indcat(sex marital) indcon(age lnx);
*/
