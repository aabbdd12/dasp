/* A FINALISER */
/*************************************************************************/
/* The rbdineq Stata module                                              */
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/


#delim ;
cap program drop rbdineq2_gini;
program define rbdineq2_gini, rclass;
syntax varlist(min=1 max=1) [, FWeight(varname) RANK(varname)];
version 8.0;
tokenize `varlist';
qui {;
preserve;
local rho=2;
tempvar fw;
qui gen `fw'=`fweight';
if ("`rank'"=="")  gsort -`1';
if ("`rank'"~="")  gsort -`rank';
cap drop if `1' >=.; 
cap drop if `fw'>=.;
count;
gen vr = sum(`fw')^`rho'; gen p = vr  - vr[_n-1];
replace p = vr[1] in 1; replace p = p / vr[_N];
gen  xi = sum(p*`1');  local xi = xi[_N];
qui sum `1' [aw=`fw']; local mu = `r(mean)';
local ineq = 1 - `xi'/`mu';
restore; 
};
return scalar ineq = `ineq';
return scalar mu   = `mu'  ;
end;


#delim ;
cap program drop rbdineq2_atk;
program define rbdineq2_atk, rclass;
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
cap program drop rbdineq2_cvar;
program define rbdineq2_cvar, rclass;
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
cap program drop rbdineq2_scvar;
program define rbdineq2_scvar, rclass;
syntax varlist(min=2 max=2) [, FWeight(varname)];
version 8.0;
tokenize `varlist';
qui {;
preserve;
tempvar fw;
qui gen `fw'=`fweight';
sum `1' [aw=`fw']; local mu1 = `r(mean)';
sum `2' [aw=`fw']; local mu2 = `r(mean)';
tempvar vec_a vec_b;
gen   `vec_a' = `fw'*(`1'-`mu1')*(`2'-`mu2');    qui sum  `vec_a', meanonly; local  ws1 = `r(mean)';         
gen   `vec_b' = `fw'*`1';      qui sum  `vec_b', meanonly; local  ws2 = `r(mean)';  
local ineq  =  (`ws1'/`ws2'^2);
restore; 
};
return scalar ineq = `ineq';
return scalar mu   = `mu1'  ;
end;


#delim ;
cap program drop rbdineq2_ge;
program define rbdineq2_ge, rclass;
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
qui gen   `vec_a' = `fw'*`1'^`theta';   
qui sum  `vec_a', meanonly; local  ws1 = `r(mean)';  
local ineq= ( 1/(`theta'*(`theta'-1) ) )*((`ws1'/`ws2')/((`ws3'/`ws2')^`theta') - 1);
};


if ( `theta' ==  0) {;
tempvar vec_a vec_b vec_c;
qui gen      `vec_a' = `fw'*log(`1');    
qui sum  `vec_a', meanonly; local  ws1 = `r(mean)';  
local ineq=log(`ws3'/`ws2')-`ws1'/`ws2'; 
};


if ( `theta' ==  1) {;
qui gen   `vec_a' = `fw'*`1'*log(`1');    
qui sum  `vec_a', meanonly; local  ws1 = `r(mean)';              
local ineq=(`ws1'/`ws3')-log(`ws3'/`ws2');
};

restore; 
};
return scalar ineq = `ineq';
return scalar mu   = `mu'  ;
end;




capture program drop rbdineq;
program define rbdineq, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname)  HGroup(varname) DEP(varname)
INDEX(string)
EPSilon(real 0.5)
THETA(real 0.5)
DEC(int 6) 
APPR(string)
METHOD(string)
MODEL(string)
NOCONSTANT
DREGRES(int 0)
];

timer clear 1;
timer on 1;
preserve;
if ("`conf'"=="")          local conf="ts";
if ("`method'"=="")        local method="mean";
if ("`appr'"=="")          local appr="shapley";
if ("`index'"=="")         local index="gini";
if ("`model'"=="")         local model="linear";

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



if ("`model'"=="semilog") {;
tempvar mark;
qui gen `mark'=1;
qui replace `mark' = 0 if `dep'<= 0;
qui count if `mark'==0;
if `r(N)'>0 {;
dis "Warning-> `r(N)'  OBS are omitted:" ; 
dis " - Dependent variable should not be =< 0 with a semilog specification."; 
};
qui drop if `mark'==0; qui count; if `r(N)'==0 exit;
qui gen _log_dep = log(`dep');
if `dregres' == 1     regress _log_dep `varlist' [aw=`fw'], `noconstant';
if `dregres' == 0 qui regress _log_dep `varlist' [aw=`fw'], `noconstant';
};

if ("`model'"=="linear") {;
if `dregres' == 1     regress `dep' `varlist' [aw=`fw'], `noconstant'; 
if `dregres' == 0 qui regress `dep' `varlist' [aw=`fw'], `noconstant';
};

predict _p_xb , xb;
predict _p_resi , residual; 
cap drop matrix coef;
matrix coef = e(b);
if "`noconstant'" =="" local   predval = "_p_cons ";
//local    predval = "`predval'"+" _p_resi"; 
forvalues i=1/$indica {;
qui gen _p_``i'' = el(coef,1,`i')*``i'';
local    predval = "`predval'"+" _p_``i''"; 
};
local indc1=$indica+1;
qui gen _p_cons=0;
if "`noconstant'" ==""     qui replace _p_cons=el(coef,1,`indc1');

if ("`model'"=="semilog") local    predval = "`predval'"+" _p_resi";  

qui tokenize `predval';
_nargs   `predval';
if ("`model'"=="linear") {;
if ("`index'"=="atk" ) {;
tempvar mark;
qui gen `mark'=1;
forvalues j=1/$indica {;
                     qui replace `mark' = 0 if ``j''< 0;
if (`epsilon' == 1)  qui replace `mark' = 0 if ``j''<= 0;
};
qui count if `mark'==0;

if `r(N)'>0 {;
dis "Warning-> `r(N)'  OBS are omitted:" ; 
dis " - The Atkinson index is not defined for values < 0.";
dis " - For epsilon=`epsilon', the Atkinson index is not defined for values = 0.";  
};
qui drop if `mark'==0; qui count; if `r(N)'==0 exit;
}; 

if ("`index'"=="ge" ) {;
tempvar mark;
qui gen `mark'=1;
forvalues j=1/$indica {;
									qui replace `mark' = 0 if ``j''< 0;
if (`theta' == 0 | `theta' == 1 )   qui replace `mark' = 0 if ``j''==0;
};
qui count if `mark'==0;

if `r(N)'>0 {;
dis "Warning-> `r(N)'  OBS are omitted:" ; 
dis " - The generalized entropy index is not defined for values < 0.";
dis " - For theta=`theta', the generalized entropy index is not defined for values = 0.";  
};
qui drop if `mark'==0; qui count; if `r(N)'==0 exit;
}; 

};


tempvar txb  tinco ;
qui gen    `txb'=0 ;
forvalues j=1/$indica {;
qui replace `txb' = `txb'+``j'';
};
 
                          qui gen `tinco' = `txb'; 
if ("`model'"=="semilog") qui replace `tinco'=exp(`txb');
qui sum  `txb' [aw=`fw']; local mu_xb = `r(mean)';

if ("`index'"=="gini")   qui rbdineq2_gini `tinco', fweight(`fw');
if ("`index'"=="cvar")   qui rbdineq2_cvar `tinco', fweight(`fw');
if ("`index'"=="ge")     qui rbdineq2_ge   `tinco', fweight(`fw') theta(`theta');
if ("`index'"=="atk")    qui rbdineq2_atk  `tinco', fweight(`fw') epsilon(`epsilon');
if ("`index'"=="scvar")  qui rbdineq2_scvar  `tinco' `tinco', fweight(`fw');

local     tineqp = `r(ineq)'; 


if ("`index'"=="gini") qui rbdineq2_gini `dep', fweight(`fw');
if ("`index'"=="cvar") qui rbdineq2_cvar `dep', fweight(`fw');
if ("`index'"=="ge")   qui rbdineq2_ge   `dep', fweight(`fw') theta(`theta');
if ("`index'"=="atk")  qui rbdineq2_atk  `dep', fweight(`fw') epsilon(`epsilon');
if ("`index'"=="scvar")  qui rbdineq2_scvar  `dep' `dep', fweight(`fw') ;


local     tineq = `r(ineq)'; 
local     mu_inc = `r(mu)';




tempvar Variable INCS  ABSC  RELC;
qui gen `Variable'="";
qui gen `INCS'=0;
qui gen `ABSC'=0;
qui gen `RELC'=0;

if ("`appr'"=="shapley") {;
shapar $indica;
cap drop _shav;
qui gen  _shav=0;
forvalues i=1/$shasize {;
cap drop `sub_xb' ;
tempvar sub_xb;
qui gen `sub_xb'=0;
forvalues j=1/$indica {;
qui replace `sub_xb' = `sub_xb' + ``j'' *(_o`j'[`i'] != .);
};

qui sum `sub_xb' [aw=`fw'], meanonly; 
local mup=`r(mean)';


if ("`method'"=="mean")   qui replace `sub_xb'=`sub_xb' + `mu_xb' - `mup';
tempvar inco; cap drop `inco';
gen `inco' = `sub_xb';
if ("`model'"=="semilog") qui replace `inco' =exp(`sub_xb');
if ("`index'"=="gini") qui rbdineq2_gini `inco', fweight(`fw');
if ("`index'"=="cvar") qui rbdineq2_cvar `inco', fweight(`fw');
if ("`index'"=="atk")  qui rbdineq2_atk  `inco', fweight(`fw') epsilon(`epsilon');
if ("`index'"=="ge")   qui rbdineq2_ge   `inco', fweight(`fw') theta(`theta');

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
tempvar shav; qui gen `shav'=0;
qui replace `shav'         =  _shav*_shapwe`k';
qui sum `shav';
local est_abs`k'         = `r(sum)';
};

};

if ("`appr'" == "analytic") {;

if ("`index'"=="gini") {;
qui sum  _p_xb [aw=`fw']; local mu_xb = `r(mean)';
qui rbdineq2_gini _p_xb, fweight(`fw') ; local ineq_xb=`r(ineq)';
qui gen _p_xbnc = _p_xb-_p_cons;
qui sum  _p_xbnc [aw=`fw']; local mu_xbnc = `r(mean)';


forvalues k=1/$indica {;
qui sum ``k'' [aw=`fw'];  local incs  = `r(mean)'/`mu_xbnc';
 qui rbdineq2_gini ``k'', fweight(`fw') rank(_p_xb);
local est_abs`k'         = `incs'*`r(ineq)';
if ("`noconstant'" =="" & `k'==1) local est_abs`k' = - _p_cons[1]/`mu_xbnc'*`ineq_xb';
};
};


if ("`index'"=="scvar") {;
qui sum  _p_xb [aw=`fw']; local mu_xb = `r(mean)';
qui rbdineq2_scvar _p_xb _p_xb, fweight(`fw'); local ineq_xb=`r(ineq)';
qui gen _p_xbnc = _p_xb-_p_cons;
qui sum  _p_xbnc  [aw=`fw']; local mu_xbnc = `r(mean)';

forvalues k=1/$indica {;
qui sum ``k'' [aw=`fw'];  local incs  = `r(mean)'/`mu_xbnc';
qui rbdineq2_scvar `dep' ``k'', fweight(`fw');
local est_abs`k'    = `r(ineq)';

if ("`noconstant'" =="" & `k'==1) local est_abs`k' = - _p_cons[1]/`mu_xbnc'*`ineq_xb';
};
};


};



forvalues k=1/$indica {;
local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+4;
qui replace `Variable' = "`k': ``k''"    in `k1';
tempvar  wcomk;
qui sum ``k'' [aw=`fw']; 
qui replace `INCS'         = `r(mean)'/`mu_inc'    in `k1';
if ("`model'"=="semilog") qui replace `INCS' = .   in `k1';
qui replace `ABSC'         = `est_abs`k''          in `k1';
qui replace `RELC'         = `est_abs`k''/(`tineq')    in `k1';
local tm = `k';
};

if ("`model'"=="semilog") local k1= ($indica-2)*2+1;
if ("`model'"=="semilog") local k2= ($indica-2)*2+4;

local k=`tm'+1;




if ("`model'"~="semilog") {;
local ka=`k1'+2;
local kb=`k1'+3;
qui replace `Variable'     = "`k': _p_resi" in `ka';
qui replace `ABSC'         = `tineq'-`tineqp'  in `ka';
qui replace `RELC'         = (`tineq'-`tineqp')/`tineq'    in `ka';
qui replace `RELC'         = 0.0    in `kb';
if ("`model'"=="semilog") qui replace `INCS' = .   in `ka';
if ("`model'"=="semilog") qui replace `INCS' = .   in `kb';
};



local ka=`k1'+4;
local kb=`k1'+5;
qui replace `Variable'     = "Total"  in `ka';
if ("`model'"=="semilog") qui replace `INCS' = .       in `ka';
if ("`model'"=="semilog") qui replace `INCS' = .       in `kb';
qui replace `ABSC'         = `tineq'  in `ka';
qui replace `RELC'         = 1.0      in `ka';
qui replace `RELC'         = 0.0      in `kb';




if "`index'" == "gini" local ind = "Gini index";
if "`index'" == "atk"  local ind = "Atkinson index";
if "`index'" == "ge"   local ind = "Generalized entropy index";
if "`index'" == "cvar" local ind = "Coefficient of variation index";
if "`index'" == "scvar" local ind = "Squared coefficient of variation index";
local shapt="";
if ("`appr'" == "shapley") local shapt= " (using the Shapley value)";
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
           di _n as text "{col 4} Regression-based inequality decomposition by predicted income components`shapt'.";
           di as text  "{col 5}Execution  time       :{col 30}" %-10.2f `ptime'  "second(s)";
		   di  as text "{col 5}Inequality index      :{col 30}`ind'  "    ;
           di  as text "{col 5}Estimated inequality  :{col 30}" %-10.6f  `tineq'      ;
       if ("`hsize'"!="")   di as text     "{col 5}Household size        :{col 30}`hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight       :{col 30}`hweight'";
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

if ("`appr'"=="shapley") {;

disp _n;
      disp in green  "{hline 60}";
      disp in yellow "Marginal contributions:";
      disp in green  "{hline 60}";
local ntab=ceil($indica/5)-1;
forvalues i=0/`ntab' {; 
local b= `i'*5+1;
local e= min(`b'+4,$indica);
tabdisp  Source in 1/$indica, cellvar(level_`b'-level_`e') concise format(%18.6f) left total;
};

}; 
};

end;  

