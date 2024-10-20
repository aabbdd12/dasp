/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : inineq                                                       */
/*************************************************************************/

#delim ;


/*****************************************************/
/* Density function      : fw=Hweight*Hsize      */
/*****************************************************/
cap program drop inineq_den;                    
program define inineq_den, rclass;              
args fw x xval;                         
qui su `x' [aw=`fw'], detail;           
local tmp = (`r(p75)'-`r(p25)')/1.34;                          
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
local h   = 0.9*`tmp'*_N^(-1.0/5.0);                            
tempvar s1 s2;                                                  
gen `s1' = sum( `fw' *exp(-0.5* ( ((`xval'-`x')/`h')^2  )  ));  
gen `s2' = sum( `fw' );
return scalar den = `s1'[_N]/( `h'* sqrt(2*c(pi)) * `s2'[_N] );  
end;


/***************************************/
/* Quantile  & GLorenz                 */
/***************************************/
cap program drop inineq_qua;
program define inineq_qua, rclass sortpreserve;
args fw yyy xval order;
preserve;
sort `yyy', stable;
qui cap drop if `yyy'>=. | `fw'>=.;
tempvar ww qp glp pc;
qui gen `ww'=sum(`fw');
qui gen `pc'=`ww'/`ww'[_N];
qui gen `qp' = `yyy' ;
qui gen `glp' double = sum(`fw'*`yyy')/`ww'[_N];
qui sum `yyy' [aw=`fw'];
local i=1;
while (`pc'[`i'] < `xval') {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) {;
local qnt =`qp'[`ar'] +((`qp'[`i'] -`qp'[`ar']) /(`pc'[`i']-`pc'[`ar']))*(`pc'[`i']-`pc'[`ar']);
local glor=`glp'[`ar']+((`glp'[`i']-`glp'[`ar'])/(`pc'[`i']-`pc'[`ar']))*(`pc'[`i']-`pc'[`ar']);
};
if (`i'==1) {;
local qnt =(max(0,`qp'[`i'])/(`pc'[`i']))*(`pc'[`i']);
local glor=(max(0,`glp'[`i'])/(`pc'[`i']))*(`pc'[`i']);
};

return scalar qnt  = `qnt';
return scalar glor = `glor';
restore;
end;



cap program drop inineq2;  
program define inineq2, rclass ;    
version 9.2;         
syntax varlist (min=1 max=1) [, HSize(varname) HWeight(varname) HGroup(varname) 
p1(real 0.1) p2(real 0.2) p3(real 0.8) p4(real 0.9) index(string)  
GNumber(int -1) CI(real 5)  CONF(string) LEVEL(real 95)];
preserve;
tokenize `varlist';
                     qui drop if `1'>=. ;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;
tempvar  hs sw fw ;
gen `sw'=1;
gen `hs'=1;

if ("`hsize'"!="")     qui replace `hs' = `hsize';
tempvar _in;
if ("`hgroup'" != "")  qui gen    `_in' = (`hgroup' == `gnumber');
if ("`hgroup'" != "")  qui replace `hs' = `hs' * `_in';
if ("`hweight'"!="")   qui replace `sw'=`hweight';


local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
tempvar fw;
gen `fw'=`hs';
if (`"`hweight'"'~="") qui replace `fw'=`fw'*`hweight';

tempvar vec_a vec_b;

if ( "`index'"=="qr") {;
inineq_qua `fw' `1' `p1';
local q1=`r(qnt)';
inineq_qua `fw' `1' `p2';
local q2=`r(qnt)';
local est = `q1'/`q2';
inineq_den `fw' `1' `q1';
local fq1=`r(den)';
inineq_den `fw' `1' `q2';
local fq2=`r(den)';
gen `vec_a' = -`hs'*((`q1'>`1')-`p1')/`fq1' + `hs'*`q1';
gen `vec_b' = -`hs'*((`q2'>`1')-`p2')/`fq2' + `hs'*`q2';
qui svy: ratio `vec_a'/`vec_b';
cap drop matrix _vv;
matrix _vv=e(V);
local std = el(_vv,1,1)^0.5;
};



if ( "`index'"=="sr") {;

inineq_qua `fw' `1' `p1';
local q1=`r(qnt)'; local g1=`r(glor)';
inineq_qua `fw' `1' `p2';
local q2=`r(qnt)'; local g2=`r(glor)';
inineq_qua `fw' `1' `p3';
local q3=`r(qnt)'; local g3=`r(glor)';
inineq_qua `fw' `1' `p4';
local q4=`r(qnt)'; local g4=`r(glor)';

local est = (`g2'-`g1')/(`g4'-`g3');

gen `vec_a' = `hs'*(`q2'*`p2'+(`1'-`q2')*(`q2'>`1')) - `hs'*(`q1'*`p1'+(`1'-`q1')*(`q1'>`1')) ;
gen `vec_b' = `hs'*(`q4'*`p4'+(`1'-`q4')*(`q4'>`1')) - `hs'*(`q3'*`p3'+(`1'-`q3')*(`q3'>`1')) ;;
qui svy: ratio `vec_a'/`vec_b';
cap drop matrix _vv;
matrix _vv=e(V);
local std = el(_vv,1,1)^0.5;


};





qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');


return scalar est  = `est';
return scalar std  = `std';
return scalar lb   = `est' - `tt'*`std';
return scalar ub   = `est' + `tt'*`std';



end;     







capture program drop inineq;
program define inineq, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) HGroup(varname) 
p1(real 0.1) p2(real 0.2) p3(real 0.8) p4(real 0.9) index(string)  
CONF(string) LEVEL(real 95) DEC(int 6) *];


if ("`conf'"=="")          local conf="ts";
local ll=0;
if ("`index'"=="") local index = "qr";

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);


local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

/* ERRORS */

if ("`hgroup'"!="") {;

preserve;
capture {;
local lvgroup:value label `hgroup';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , clear;
qui count;
forvalues i=1/`r(N)' {;
local tem=value[`i'];
local grlab`tem' = label[`i'];
};
};
};
restore;
preserve;
qui tabulate `hgroup', matrow(gn);
svmat int gn;
global indica=r(r);
tokenize `varlist';
};

if ("`hgroup'"=="") {;
tokenize `varlist';
_nargs    `varlist';
preserve;
};
local ci=100-`level';

tempvar Variable Estimate STE LB UB;
qui gen `Variable'="";
qui gen `Estimate'=0;
qui gen `STE'=0;
qui gen `LB'=0;
qui gen `UB'=0;


tempvar _ths;

qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';



local ll=length("`1': `grlab`1''");
local component = "Variable";
forvalues k = 1/$indica {;
if ("`hgroup'"=="") {;

qui replace `Variable' = "``k''" in `k';

inineq2 ``k'' , hweight(`hweight') p1(`p1') p2(`p2') p3(`p3') p4(`p4') index(`index') hsize(`_ths')    conf(`conf') level(`level');

qui replace `Estimate' = `r(est)' in `k';
qui replace `STE'      = `r(std)' in `k';
qui replace `LB'       = `r(lb)'  in `k';
qui replace `UB'       = `r(ub)'  in `k';
if ("`conf'"=="lb")   qui replace `UB'       =.  in `k';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `k';

};



if ("`hgroup'"!="") {;
local kk = gn1[`k'];
local label`k'  : label (`hgroup') `kk';
if "`label`k''"=="" local label`k'="Group: `kk'";
qui replace `Variable' = "`k': `label`k''" in `k';

inineq2 `1' ,  hweight(`hweight') p1(`p1') p2(`p2') p3(`p3') p4(`p4') index(`index')  hsize(`_ths')   conf(`conf') 
level(`level') hgroup(`hgroup') gnumber(`kk');
qui replace `Estimate' = `r(est)' in `k';
qui replace `STE'      = `r(std)' in `k';
qui replace `LB'       = `r(lb)'  in `k';
qui replace `UB'       = `r(ub)'  in `k';

if ("`conf'"=="lb")   qui replace `UB'       =.  in `k';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `k';

local ll=max(`ll',length("`kk': `grlab`k''"));
local component = "Group";
};

};

local ll=`ll'+10;


if ("`hgroup'"!="") {;
local kk =$indica + 1;
qui count;
if (`r(N)'<`kk') qui set obs `kk';
inineq2 `1' ,   hweight(`hweight') hsize(`_ths')  p1(`p1') p2(`p2') p3(`p3') p4(`p4') index(`index')  conf(`conf') level(`level');
qui replace `Variable' = "Population" in `kk';
qui replace `Estimate' = `r(est)' in `kk';
qui replace `STE'      = `r(std)' in `kk';
qui replace `LB'       = `r(lb)'  in `kk';
qui replace `UB'       = `r(ub)'  in `kk';
if ("`conf'"=="lb")   qui replace `UB'       =.  in `kk';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `kk';
};

local 1kk = $indica;
local ind = "Quantile ratio";

local lr = "p1 = `p1'";
local hr = "p2 = `p2'";

if ("`index'"=="sr") {;

local ind = "Share ratio";
local lr = "p1 = `p1' / p2 = `p2'";
local hr = "p3 = `p3' / p4 = `p4'";
};


if ("`hgroup'"!="") local  1kk=`kk'-1;
tempname table;
	.`table'  = ._tab.new, col(5)  separator(0) lmargin(0);
	.`table'.width  `ll'|16 16 16 16 ;
	.`table'.strcolor . . yellow . . ;
	.`table'.numcolor yellow yellow . yellow yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f ;
	                      di _n as text in white "{col 5}Index            :  `ind' index of inequality";
                            di as text     "{col 5}Lower  rank      :  `lr'";
                            di as text     "{col 5}Higher rank      :  `hr'";
       if ("`hsize'"!="")   di as text     "{col 5}Household size   :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight  :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable   :  `hgroup'";

       
      .`table'.sep, top;
	.`table'.titles "`component'  " "Estimate" "STE "	"  LB  " "  UB  ";
	
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`1kk'{;
           		.`table'.row `Variable'[`i'] `Estimate'[`i'] `STE'[`i'] `LB'[`i'] `UB'[`i']; 
	};
 if ("`hgroup'"=="")  .`table'.sep,bot;
if ("`hgroup'"!="") {;
  .`table'.sep, mid;
  .`table'.numcolor white green   green  green green ;
  .`table'.row `Variable'[`kk'] `Estimate'[`kk']  `STE'[`kk'] `LB'[`kk'] `UB'[`kk'];
  .`table'.sep,bot;
};

cap ereturn clear;
local kk =$indica + 1;
qui keep in 1/`kk';
tempname ES ST;
mkmat `Estimate', matrix(`ES');
ereturn matrix est = `ES';
mkmat `STE', matrix(`ST');
ereturn matrix std = `ST';
ereturn scalar est = `Estimate'[1];
restore;
end;



