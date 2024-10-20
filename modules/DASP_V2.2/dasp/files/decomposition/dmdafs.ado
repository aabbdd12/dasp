/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.2)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : dmdafs                                                      */            
/*************************************************************************/





#delim ;

capture program drop dmdafs_af;
program define dmdafs_af, rclass;
version 9.2;
syntax varlist [,  FWeight(string) 
nembarg(int 1) 
dec(int 3) 
ALPHA(real 1)
PL1(real 0)  PL2(real 0) PL3(real 0) PL4(real 0) PL5(real 0) PL6(real 0) PL7(real 0)  PL8(real 0) PL9(real 0) PL10(real 0) 
W1(real 1)   W2(real 1)  W3(real 1)  W4(real 1)  W5(real 1)  W6(real 1) W7(real 1)   W8(real 1)  W9(real 1)  W10(real 1)  
ALPHA(real 1)  DCUT(real 0.5) 
CONF(string)
LEVEL(real 95) 
];

preserve;
tokenize `varlist';

tempvar num00 num0 num1 num2 pnum00 pnum0 pnum1 pnum2 indt0 indt1 indt2 indp  c1 c2;
qui gen   `num00'   = 0;
qui gen   `num0'   = 0;
qui gen   `num1'   = 0;
qui gen   `num2'   = 0;

qui gen   `pnum00'   = 0;
qui gen   `pnum0'    = 0;
qui gen   `pnum1'    = 0;
qui gen   `pnum2'    = 0;

qui gen   `indp'  = 0;
qui gen   `indt0' = 0;
qui gen   `indt1' = 0;
qui gen   `indt2' = 0;

local swat=0;
forvalues i=1/`nembarg' {;
local swat=`swat'+ `w`i'';
};

forvalues i=1/`nembarg' {;
local w`i'=`w`i''/`swat';

};

forvalues i=1/`nembarg' {;
qui replace    `indt0' = `indt0'+ `w`i''*(`pl`i''> ``i'');
qui replace    `indt1' = `indt1'+ `w`i''*((`pl`i''-``i'')/`pl`i'')^1  if (`pl`i''>``i'');
qui replace    `indt2' = `indt2'+ `w`i''*((`pl`i''-``i'')/`pl`i'')^2  if (`pl`i''>``i'');
};


qui replace    `indp' = (`indt0'>= `dcut'/`swat');

qui replace    `num00' = `indp';
qui replace    `num0'  = `indt0'*`indp';
qui replace    `num1'  = `indt1'*`indp';
qui replace    `num2'  = `indt2'*`indp';


qui sum `num00' [aw= `fweight'] ,  meanonly; local nom1  = r(mean); 
qui sum `num0'  [aw= `fweight']  , meanonly; local nom2  = r(mean); 
qui sum `num1'  [aw= `fweight'] ,  meanonly;  local nom3  = r(mean); 
qui sum `num2'  [aw= `fweight'] ,  meanonly;  local nom4  = r(mean); 



return scalar est_H0  = `nom1'  ;
return scalar est_M0  = `nom2'  ;
return scalar est_M1  = `nom3'  ;
return scalar est_M2  = `nom4'  ;


end;


capture program drop dmdafs;
program define dmdafs, rclass;
version 9.2;
syntax varlist(min=1)[,  
HSize(varname)
dec(int 3)
DCUT(real 0.5)
PL1(real 0)  PL2(real 0) PL3(real 0) PL4(real 0) PL5(real 0) PL6(real 0) PL7(real 0)  PL8(real 0) PL9(real 0) PL10(real 0) 
W1(real 1)   W2(real 1)  W3(real 1)  W4(real 1)  W5(real 1)  W6(real 1) W7(real 1)   W8(real 1)  W9(real 1)  W10(real 1) 
];

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

global indicag=0;
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

tokenize  `varlist';
_nargs    `varlist';

tempvar Variable Estimate ;
qui gen `Variable'="";
qui gen `Estimate'=0;

tempvar _ths _fw;

qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';
qui gen `_fw'=`_ths';
if (`"`hweight'"'~="") qui replace `_fw'=`_fw'*`hweight';


dmdafs_af `varlist', fweight(`_fw') nembarg($indica) dec(`dec') 
pl1(`pl1')  pl2(`pl2') pl3(`pl3') pl4(`pl4') pl5(`pl5') pl6(`pl6') 
pl7(`pl7')  pl8(`pl8') pl9(`pl9') pl10(`pl10') 
w1(`w1')  w2(`w2') w3(`w3') w4(`w4') w5(`w5') w6(`w6')
w7(`w7')  w8(`w8') w9(`w9') w10(`w10') 
  dcut(`dcut');



local k=$indicag+1;

tempvar Component;
qui gen `Component'="";
local f = 0;
forvalues i=1/$indica {;
local f = `f'+ 1;
qui replace `Component' = "``i''"     in `f';
local f = `f'+ 1;
};


tempvar Variable  EST2 EST3 EST4 EST5   ;
qui gen `Variable'="";


qui gen `EST2'=0;
qui gen `EST3'=0;
qui gen `EST4'=0;
qui gen `EST5'=0;

qui replace `EST2'      = `r(est_H0)' in `k';
qui replace `EST3'      = `r(est_M0)' in `k';
qui replace `EST4'      = `r(est_M1)' in `k';
qui replace `EST5'      = `r(est_M2)' in `k';

qui replace `Variable' = "Population" in `k';


local sindex="Alkire and Foster (2007)                       ";


tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width |24|16  16 16 16|;
	
	.`table'.numcolor white yellow yellow yellow yellow  ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f ;
	di _n as text "{col 4} Alkire and Foster (2007) MDP indices";
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";
     
	.`table'.sep, top;
	.`table'.titles "Group  "   " H0 "  " M0 " " M1 " " M2 " ;

	.`table'.sep, mid;
	local nalt = "ddd";
	
		         .`table'.row `Variable'[1]  `EST2'[1] `EST3'[1] `EST4'[1] `EST5'[1];
              	        
.`table'.sep,bot;



end;




capture program drop dmdafs;
program define dmdafs, eclass;
version 9.2;
syntax varlist(min=1)[,  
HSize(varname)
dec(int 3)
PL1(real 0)  PL2(real 0) PL3(real 0) PL4(real 0) PL5(real 0) PL6(real 0) PL7(real 0)  PL8(real 0) PL9(real 0) PL10(real 0) 
W1(real 1)   W2(real 1)  W3(real 1)  W4(real 1)  W5(real 1)  W6(real 1) W7(real 1)   W8(real 1)  W9(real 1)  W10(real 1) 
DCUT(real 0.5)
];


timer clear 1;
timer on 1;
preserve;
local ll=0;

 tokenize `varlist';
_nargs    `varlist';

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

tempvar hw; qui gen `hw'=1; if ("`hweight'"~="") qui replace `hw'=`hweight';

tempvar fw;
qui gen `fw'=1;
qui replace `fw'=`fw'*`hw';
tempvar hs;
qui gen `hs'=1;
if ("`hsize'"~="")   qui replace `hs'=`hsize';
qui replace `fw'=`fw'*`hs';

shapar $indica;
tempvar tinco   ;
gen    `tinco'=0 ;
forvalues j=1/$indica {;
qui replace `tinco' = `tinco'+``j'';
tempvar vpl`j';
gen `vpl`j'' = `pl`j'';
};

dmdafs_af `varlist', fweight(`fw') nembarg($indica) dec(`dec') 
pl1(`pl1')  pl2(`pl2') pl3(`pl3') pl4(`pl4') pl5(`pl5') pl6(`pl6') 
pl7(`pl7')  pl8(`pl8') pl9(`pl9') pl10(`pl10') 
w1(`w1')  w2(`w2') w3(`w3') w4(`w4') w5(`w5') w6(`w6')
w7(`w7')  w8(`w8') w9(`w9') w10(`w10')
  dcut(`dcut');
  

local     taf1 = `r(est_H0)'; 
local     taf2 = `r(est_M0)';
local     taf3 = `r(est_M1)';
local     taf4 = `r(est_M2)';




tempvar Variable   ;  qui gen `Variable'="";

forvalues z=1/4 {;
cap drop _shav`z'; qui gen  _shav`z'=0;

tempvar   ABSC`z'  RELC`z' ;
qui gen `ABSC`z''=0;
qui gen `RELC`z''=0;
};

forvalues i=1/$shasize {;
local mylist  = "" ;
forvalues j=1/$indica {;
if (_o`j'[`i'] != .) local mylist `mylist' ``j'' ;
if (_o`j'[`i'] == .) local mylist `mylist' `vpl`j'' ;
};


dmdafs_af `mylist', fweight(`fw') nembarg($indica) dec(`dec') 
pl1(`pl1')  pl2(`pl2') pl3(`pl3') pl4(`pl4') pl5(`pl5') pl6(`pl6') 
pl7(`pl7')  pl8(`pl8') pl9(`pl9') pl10(`pl10') 
w1(`w1')  w2(`w2') w3(`w3') w4(`w4') w5(`w5') w6(`w6')
w7(`w7')  w8(`w8') w9(`w9') w10(`w10')
  dcut(`dcut');
qui replace _shav1 = `r(est_H0)' in `i';
qui replace _shav2 = `r(est_M0)' in `i';
qui replace _shav3 = `r(est_M1)' in `i';
qui replace _shav4 = `r(est_M2)' in `i';
                                              
};



forvalues i=1/$indica  {;
local temn= "Level `i'";
local cnam `"`cnam' "`temn'""';
			   
local temn= "``i''";
local rnam `"`rnam' "`temn'""';
};



forvalues l=1/$indica {;
forvalues z=1/4 {;
cap drop level`z'_`l' ; 
qui gen level`z'_`l'=0;

forvalues j=1/$indica {;
cap drop `temp`z'' ;
tempvar temp`z';  
qui gen `temp`z'' = 0;
qui replace `temp`z''   =  (_o`j'==`j')*(_sg==`l') | (_o`j'!=`j')*(_sg==`l'-1) ;
qui replace `temp`z''   =  `temp`z''*_shav`z'*_shapwe`j';
qui sum `temp`z'' in 1/$shasize;
qui replace level`z'_`l' =  `r(sum)' in `j' ; 
};
};
};

forvalues k=1/$indica {;
local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;
qui replace `Variable' = "`k': ``k''"    in `k1';
};


local ka=`k1'+2;
qui replace `Variable'     = "Total" in `ka';

forvalues z=1/4 {;

forvalues k=1/$indica {;
local k1= (`k'-1)*2+1;
tempvar shav`z'; qui gen `shav`z''=0;
qui replace `shav`z''         =  _shav`z'*_shapwe`k';
qui sum `shav`z'';
qui replace `ABSC`z''         = `r(sum)'                in `k1';
qui replace `RELC`z''         = `r(sum)'/ (`taf`z'')    in `k1';
};

local ka=`k1'+2;
local kb=`k1'+3;

qui replace `ABSC`z''         = `taf`z''  in `ka';
qui replace `RELC`z''         = 1.0    in `ka';
qui replace `RELC`z''         = 0.0    in `kb';

};




timer off 1;
qui timer list 1;
local ptime = `r(t1)';
/****TO DISPLAY RESULTS *****/
set more off;

local ind1 = "H0"; local ind2 = "M0";  local ind3 = "M1";  local ind4 = "M2"; 

          di _n as text "{col 4} Decomposition of the AF indices by dimensions using the Shapley approach.";
           di as text  "{col 5}Execution  time {col 25}:" %10.2f `ptime' " second(s)";
        
       if ("`hsize'"!="")   di as text     "{col 5}Household size   {col 25}:  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight  {col 25}:  `hweight'";
						    di as text     "{col 5}Cut-off          {col 25}:  `dcut'";

 
							
	forvalues z=1/4 {;
	di _n ;
	di _n as text "{col 4} - `ind`z'' index";
	local ll = 20;
        tempname table;
        .`table'  = ._tab.new, col(3) sep(0);
        .`table'.width |`ll'|16 16  |;
        .`table'.strcolor . . yellow   ;
        .`table'.numcolor yellow . yellow ;
        .`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f ;
        .`table'.sep, top;
        .`table'.titles "Sources  "      "  Absolute  " "  Relative  " ;
        .`table'.titles "         "      "Contribution" "Contribution" ;
        .`table'.sep, mid;
        local nalt = "ddd";
        forvalues i=1/`k2'{;
        
                     if ((`i'/2!=round(`i'/2)))     .`table'.row `Variable'[`i'] `ABSC`z''[`i'] `RELC`z''[`i']; 
                     };
                     
  .`table'.sep, mid;
.`table'.numcolor white yellow yellow    ;
.`table'.row  "Total"  `ABSC`z''[`ka'] `RELC`z''[`ka'];

	.`table'.sep,bot;



order level`z'*;

cap drop Source; qui gen Source="";
forvalues k=1/$indica {;
qui replace Source = "`k': ``k''"    in `k';



};



 tempname table;
        tempname AA;
		mkmat level`z'_1-level`z'_$indica in 1/$indica, matrix(`AA')  ;
		*dis " ici `cnam' " ;
		
		
		matrix colnames `AA' = `cnam' ;
		matrix rownames `AA' = `rnam' ;
		distable `AA', atit(Dimensions) dsmidl(-1) head1("Marginal contributions:");

};


end;  



/*

* set trace on;
set tracedepth 1;
set more off; 
*dmdafs nsc_hab nsc_san nsc_etu, hsize(s00q9) dcut(2) w1(1) pl1(1) w2(1) pl2(1) w3(1) pl3(1) ;
 
 
 dmdafs nsc_hab nsc_san nsc_etu  , hsize(s00q9) dcut(3)
 w1(1) pl1(1) w2(1) pl2(1) w3(1) pl3(1)
 /*w4(1) pl4(1) w5(1) pl5(1) w6(1) pl6(1)*/
 ;
*/
