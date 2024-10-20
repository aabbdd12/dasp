
/*************************************************************************/
/* The dsineqs Stata module                                              */
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/


#delim ;
cap program drop dsineqs2_gini;
program define dsineqs2_gini, rclass;
syntax varlist(min=1 max=1) [, FWeight(varname)];
version 8.0;
tokenize `varlist';
qui {;
preserve;
local rho=2;
tempvar fw;
qui gen `fw'=`fweight';
gsort -`1';
cap drop if `1' >=.; 
cap drop if `fw'>=.;
gen vr = sum(`fw')^`rho'; gen p = vr  - vr[_n-1];
replace p = vr[1] in 1; replace p = p / vr[_N];
gen  xi = sum(p*`1');  local xi = xi[_N];
sum `1' [aw=`fw']; local mu = `r(mean)';
local ineq = 1 - `xi'/`mu';
restore; 
};
return scalar ineq = `ineq';
return scalar mu   = `mu'  ;
end;


#delim ;
cap program drop dsineqs2_atk;
program define dsineqs2_atk, rclass;
syntax varlist(min=1 max=1) [, FWeight(varname) epsilon(real 0.5)];
version 9.2;
tokenize `varlist';
preserve;
tempvar fw;
qui gen `fw'=`fweight';
sum `1' [aw=`fw']; local mu = `r(mean)';

tempvar vec_a vec_b vec_c;
gen   `vec_b' = `fw';      qui sum  `vec_b', meanonly; local  ws2 = `r(mean)';          
gen   `vec_c' = `fw'*`1';  qui sum  `vec_c', meanonly; local  ws3 = `r(mean)';  

if ( `epsilon' != 1.0 ) {;
gen      `vec_a' = `fw'*`1'^(1-`epsilon');    qui sum  `vec_a', meanonly; local  ws1 = `r(mean)'; 
local ineq =  1 - (`ws1')^(1/(1-`epsilon'))*(`ws2')^(1+(1/(`epsilon'-1)))/(`ws3');          
};

if ( `epsilon' == 1.0)  {;
gen   `vec_a' = `fw'*log(`1'); 
qui sum  `vec_a', meanonly; local  ws1 = `r(mean)';       
local ineq =  1- exp(`ws1'/`ws2')*(`ws2'/`ws3');
};



return scalar ineq = `ineq';
return scalar mu   = `mu'  ;
restore; 

end;


#delim ;
cap program drop dsineqs2_cvar;
program define dsineqs2_cvar, rclass;
syntax varlist(min=1 max=1) [, FWeight(varname)];
version 8.0;
tokenize `varlist';
qui {;
preserve;
tempvar fw;
qui gen `fw'=`fweight';
sum `1' [aw=`fw']; local mu = `r(mean)';
tempvar vec_a vec_b vec_c;
gen   `vec_a' = `fw'*`1'^2;    qui sum  `vec_a', meanonly; local  ws1 = `r(mean)'; 
gen   `vec_b' = `fw';          qui sum  `vec_b', meanonly; local  ws2 = `r(mean)';          
gen   `vec_c' = `fw'*`1';      qui sum  `vec_c', meanonly; local  ws3 = `r(mean)';  
local ineq  =  (`ws1'*`ws2'/`ws3'^2-1)^0.5;
restore; 
};
return scalar ineq = `ineq';
return scalar mu   = `mu'  ;
end;


#delim ;
cap program drop dsineqs2_ge;
program define dsineqs2_ge, rclass;
syntax varlist(min=1 max=1) [, FWeight(varname) theta(real 0.5)];
version 8.0;
tokenize `varlist';
qui {;
preserve;
tempvar fw;
qui gen `fw'=`fweight';
sum `1' [aw=`fw']; local mu = `r(mean)';

tempvar vec_a vec_b vec_c;
   
gen   `vec_b' = `fw';      qui sum  `vec_b', meanonly; local  ws2 = `r(mean)';          
gen   `vec_c' = `fw'*`1';  qui sum  `vec_c', meanonly; local  ws3 = `r(mean)';  

if ( `theta' !=  0 & `theta' != 1 ) {;
gen   `vec_a' = `fw'*`1'^`theta';   
qui sum  `vec_a', meanonly; local  ws1 = `r(mean)';  
local ineq= ( 1/(`theta'*(`theta'-1) ) )*((`ws1'/`ws2')/((`ws3'/`ws2')^`theta') - 1);
};


if ( `theta' ==  0) {;
tempvar vec_a vec_b vec_c;
gen      `vec_a' = `fw'*log(`1');    
qui sum  `vec_a', meanonly; local  ws1 = `r(mean)';  
local ineq=log(`ws3'/`ws2')-`ws1'/`ws2'; 
};


if ( `theta' ==  1) {;
gen   `vec_a' = `fw'*`1'*log(`1');    
qui sum  `vec_a', meanonly; local  ws1 = `r(mean)';              
local ineq=(`ws1'/`ws3')-log(`ws3'/`ws2');
};

restore; 
};
return scalar ineq = `ineq';
return scalar mu   = `mu'  ;
end;




capture program drop dsineqs;
program define dsineqs, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname)  HGroup(varname) 
INDEX(string)
EPSilon(real 0.5)
THETA(real 0.5)
DEC(int 6) METHOD(string)
];

timer clear 1;
timer on 1;
preserve;
if ("`conf'"=="")          local conf="ts";
if ("`method'"=="")          local method="mean";
if ("`index'"=="")         local index="gini";


local ll=0;

 tokenize `varlist';
_nargs    `varlist';


if ("`index'"=="atk" & `epsilon' == 1) {;
tempvar mark;
qui gen `mark'=1;
forvalues j=1/$indica {;
qui replace `mark' = 0 if ``j''==0;
};
qui count if `mark'==0;
if `r(N)'>0 dis "Warning: `r(N)' will be omitted: Atkinson index (epsilon==`epsilon') is not defined with zero values."; 
qui drop if `mark'==0;
}; 

if ("`index'"=="ge" & (`theta' == 0 | `theta' == 0 ) ) {;
tempvar mark;
qui gen `mark'=1;
forvalues j=1/$indica {;
qui replace `mark' = 0 if ``j''==0;
};
qui count if `mark'==0;
if `r(N)'>0 dis "Warning: `r(N)' will be omitted: Generalized entropy index (theta==0) is not defined with zero values."; 
qui drop if `mark'==0;
}; 

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
};


if ("`index'"=="gini") qui dsineqs2_gini `tinco', fweight(`fw');
if ("`index'"=="cvar") qui dsineqs2_cvar `tinco', fweight(`fw');
if ("`index'"=="ge")   qui dsineqs2_ge   `tinco', fweight(`fw') theta(`theta');
if ("`index'"=="atk")  qui dsineqs2_atk  `tinco', fweight(`fw') epsilon(`epsilon');

local     tineq = `r(ineq)'; 
local     mu_inc = `r(mu)';


cap drop _shav;
qui gen  _shav=0;

tempvar Variable INCS  ABSC  RELC;
qui gen `Variable'="";
qui gen `INCS'=0;
qui gen `ABSC'=0;
qui gen `RELC'=0;




forvalues i=1/$shasize {;
cap drop `inco';
tempvar inco;
gen `inco'=0;
forvalues j=1/$indica {;
qui replace `inco' = `inco' + ``j'' *(_o`j'[`i'] != .);
};

qui sum `inco' [aw=`fw'], meanonly; 
local mup=`r(mean)';
if ("`method'"=="mean")  qui replace `inco'=`inco' + `mu_inc' - `mup';

sum `inco'; 
if ("`index'"=="gini") qui dsineqs2_gini `inco', fweight(`fw');
if ("`index'"=="cvar") qui dsineqs2_cvar `inco', fweight(`fw');
if ("`index'"=="atk")  qui dsineqs2_atk  `inco', fweight(`fw') epsilon(`epsilon');
if ("`index'"=="ge")   qui dsineqs2_ge   `inco', fweight(`fw') theta(`theta');

qui replace _shav = `r(ineq)' in `i';
                                               
};


forvalues l=1/$indica {;
cap drop level_`l' ; qui gen level_`l'=0;
forvalues j=1/$indica {;
cap drop `temp';
tempvar temp;  qui gen `temp' = 0;
qui replace `temp'   =  (_o`j'==`j')*(_sg==`l') | (_o`j'!=`j')*(_sg==`l'-1) ;
qui replace `temp'   =  `temp'*_shav*_shapwe`j';
qui sum `temp' in 1/$shasize;
qui replace level_`l' =  `r(sum)' in `j' ; 
};
};


forvalues k=1/$indica {;
local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;
qui replace `Variable' = "`k': ``k''"    in `k1';
tempvar  wcomk;
qui sum ``k'' [aw=`fw']; 
qui replace `INCS'         = `r(mean)'/`mu_inc'  in `k1';
tempvar shav; qui gen `shav'=0;
qui replace `shav'         =  _shav*_shapwe`k';
qui sum `shav';
qui replace `ABSC'         = `r(sum)'               in `k1';
qui replace `RELC'         = `r(sum)'/(`tineq')    in `k1';
};







local ka=`k1'+2;
local kb=`k1'+3;
qui replace `Variable'     = "Total" in `ka';
qui replace `INCS'         = 1      in `ka';
qui replace `INCS'         = 0      in `kb';


qui replace `ABSC'         = `tineq'  in `ka';

qui replace `RELC'         = 1.0    in `ka';
qui replace `RELC'         = 0.0    in `kb';








timer off 1;
qui timer list 1;
local ptime = `r(t1)';
/****TO DISPLAY RESULTS *****/
set more off;
local ll = 20;
        tempname table;
        .`table'  = ._tab.new, col(4);
        .`table'.width |`ll'|16 16 16 |;
        .`table'.strcolor . . yellow .  ;
        .`table'.numcolor yellow yellow . yellow ;
        .`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f ;
           di _n as text "{col 4} Decomposition of the inequality index by income components (using the Shapley value).";
           di as text  "{col 5}Execution  time :    "  %10.2f `ptime' " second(s)";
           di  as text "{col 5}ineq index      :    "  %10.6f `tineq'       ;
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
        .`table'.sep, top;
        .`table'.titles "Sources  "  "Income   "     "  Absolute  " "  Relative  " ;
        .`table'.titles "         "  " Share   "     "Contribution" "Contribution" ;
        .`table'.sep, mid;
        local nalt = "ddd";
        forvalues i=1/`k2'{;
             if (`i'/2!=round(`i'/2)) .`table'.numcolor  white yellow yellow   yellow ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green    green   green  ;
             if ((`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i'] `INCS'[`i']  `ABSC'[`i'] `RELC'[`i']; 
                    };
                     
  .`table'.sep, mid;
.`table'.numcolor white yellow yellow   yellow  ;
.`table'.row  "Total" `INCS'[`ka']  `ABSC'[`ka'] `RELC'[`ka'];
if ("`ste'"=="yes"){;
.`table'.numcolor white green   green green  ;
.`table'.row " "  `INCS'[`kb']  `ABSC'[`kb'] `RELC'[`kb'];
};
	.`table'.sep,bot;


if ("`ste'"~="yes") {;
cap drop Source; qui gen Source="";
forvalues k=1/$indica {;
qui replace Source = "`k': ``k''"    in `k';
};

disp _n;
      disp in green  "{hline 60}";
      disp in yellow "Marginal contributions:";
      disp in green  "{hline 60}";
local ntab=ceil($indica/5)-1;
forvalues i=0/`ntab' {; 
local b= `i'*5+1;
local e= min(`b'+4,$indica);
tabdisp Source in 1/$indica, cellvar(level_`b'-level_`e') concise format(%18.6f) left total;
};

}; 

end;  

