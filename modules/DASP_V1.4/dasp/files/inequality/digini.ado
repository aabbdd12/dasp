/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 1.4)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2008)          */
/* Université Laval, Quebec, Canada                                    */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : digini                                                       */
/*************************************************************************/




#delim ;
set more off;
cap program drop digini2;  
program define digini2, rclass sortpreserve ;    
version 9.2;         
syntax varlist (min=1 max=1) [, HSize(varname) HWeight(varname) RANK(varname)  CI(real 5)  CONF(string) LEVEL(real 95) VAB(real 0)];
tokenize `varlist';
if ("`rank'"=="") sort `1'    , stable;
if ("`rank'"!="") sort `rank' , stable;
                     qui drop if `1'>=. ;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;
tempvar  hs sw fw ;
gen `sw'=1;
gen `hs'=1;
if ("`hsize'"!="")     qui replace `hs' = `hsize';
if ("`hweight'"!="")   qui replace `sw' = `hweight';
gen `fw'=`hs'*`sw';
tempvar smw smwy l1smwy ca;
gen `smw'  =sum(`fw');
gen `smwy' =sum(`1'*`fw');
gen `l1smwy'=0;
local mu=`smwy'[_N]/`smw'[_N];
local suma=`smw'[_N];
qui count;
forvalues i=2/`r(N)' { ;
qui replace `l1smwy'=`smwy'[`i'-1]  in `i';
};

gen `ca'=`mu'+`1'*((1.0/`smw'[_N])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[_N])*(2.0*`l1smwy'+`fw'*`1'); 
qui sum `ca' [aw=`fw'], meanonly; 
local gini=`r(mean)'/(2.0*`mu');
local xi = `r(mean)';
tempvar vec_a vec_b theta v1 v2 sv1 sv2;
qui count; 
            local fx=0;
            gen `v1'=`fw'*`1';
            gen `v2'=`fw';
            gen `sv1'=sum(`v1');
            gen `sv2'=sum(`v2') ;
            qui replace `v1'=`sv1'[`r(N)']   in 1;
            qui replace `v2'=`sv2'[`r(N)']   in 1;

            forvalues i=2/`r(N)'  {;
            qui replace `v1'=`sv1'[`r(N)']-`sv1'[`i'-1]   in `i';
		qui replace `v2'=`sv2'[`r(N)']-`sv2'[`i'-1]   in `i';
            } ;
           
            gen `theta'=`v1'-`v2'*`1';

           forvalues i=1/`r(N)' {;
                qui replace `theta'=`theta'[`i']*(2.0/`suma')  in `i';
                local fx=`fx'+`fw'[`i']*`1'[`i'];
            };            
            local fx=`fx'/`suma';
            gen `vec_a' = `hs'*((1.0)*`ca'+(`1'*`mu'-`fx')+`theta'-(1.0)*(`xi'));
            gen `vec_b' =  2*`hs'*`1';

qui svy: ratio `vec_a'/`vec_b'; 
cap drop matrix _aa;
matrix _aa=e(b);
local est = `gini';
cap drop matrix _vv;
matrix _vv=e(V);
local std = el(_vv,1,1)^0.5;
qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');
return scalar est  = `est';
return scalar std  = `std';
return scalar lb   = `est' - `tt'*`std';
return scalar ub   = `est' + `tt'*`std';

if (`vab'==1) {;
qui gen __va=`vec_a';
qui gen __vb=`vec_b';
};
end;     





capture program drop digini;
program define digini, eclass;
version 9.2;
syntax  namelist(min=2 max=2) [, FILE1(string) FILE2(string) 
RANK1(string)  RANK2(string)
HSize1(string) HSize2(string)
COND1(string)  COND2(string)  
type(string) LEVEL(real 95) CONF(string) DEC(int 6)];

global indica=3;
tokenize `namelist';
if ("`conf'"=="")          local conf="ts";

preserve;
local vab=0;
if ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) local vab=1;
if ("`file1'" !="") use `"`file1'"', replace;
tempvar cd1;
tempvar ths1;
qui gen `ths1'=1;

if ( "`hsize1'"!="") qui replace `ths1'=`hsize1';

if ( "`cond1'"!="") {;
gen `cd1'=`cond1';
qui replace `ths1'=`ths1'*`cd1';
qui sum `cd1';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_1, the number of observartions is 0.";
exit;
};
};

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight1=""; 
cap qui svy: total `1'; 
local hweight1=`"`e(wvar)'"';
cap ereturn clear; 

digini2 `1' , hweight(`hweight1') hsize(`ths1')  rank(`rank1') conf(`conf') level(`level') vab(`vab');
if (`vab'==1) {;
tempvar va vb;
qui gen `va'=__va;
qui gen `vb'=__vb;
qui drop __va __vb;
};
matrix _res_d1  =(`r(est)',`r(std)',`r(lb)',`r(ub)') ;


if ("`file2'" !="" & `vab'!=1) use `"`file2'"', replace;
tempvar cd2 ths2;
qui gen `ths2'=1;
if ( "`hsize2'"!="") qui replace `ths2'=`hsize2';
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace `ths2'=`ths2'*`cd2';
qui sum `cd2';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_2 the number of observartions is 0.";
exit;
};
};
qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local hweight2=""; 
cap qui svy: total `2'; 
local hweight2=`"`e(wvar)'"';
cap ereturn clear; 



digini2 `2' , hweight(`hweight2') hsize(`ths2') rank(`rank2')  conf(`conf') level(`level') vab(`vab') ;
if (`vab'==1) {;
tempvar vc vd;
qui gen `vc'=__va;
qui gen `vd'=__vb;
qui drop __va __vb;
};

matrix _res_d2 =(`r(est)',`r(std)',`r(lb)',`r(ub)' );
local dif = el(_res_d1,1,1)-el(_res_d2,1,1);
local std = (el(_res_d1,1,2)^2+el(_res_d2,1,2)^2)^0.5;
if (`vab'==1) {;
qui svy: mean `va' `vb' `vc' `vd';
qui nlcom (_b[`va']/_b[`vb']-_b[`vc']/_b[`vd'] ),  iterate(10000);;
cap drop matrix _vv;
matrix _vv=r(V);
local std = el(_vv,1,1)^0.5;
}; 

if ("`conf'"!="ts") local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl = (1-(100-`level')/200);
local zzz=invnorm(`lvl');
local lb   = `dif' -  `zzz'*`std';
local ub   = `dif' +  `zzz'*`std';
matrix _res_di =(`dif',`std',`lb',`ub');




local lb_d1  = el(_res_d1,1,3);
local lb_d2  = el(_res_d2,1,3);
local lb_dif = el(_res_di,1,3);
local ub_d1  = el(_res_d1,1,4);
local ub_d2  = el(_res_d2,1,4);
local ub_dif = el(_res_di,1,4);



if ("`conf'"=="lb")  {;
local ub_d1  = ".";
local ub_d2  = ".";
local ub_dif = ".";
};

if ("`conf'"=="ub")  {;
local lb_d1  = ".";
local lb_d2  = ".";
local lb_dif = ".";
};

local tyind1="GINI";
local tyind2="GINI";
if (`"`rank1'"'~="" & `"`rank1'"'~="`1'") local tyind1="CONC";
if (`"`rank2'"'~="" & `"`rank2'"'~="`2'") local tyind2="CONC";
if ("`type'"=="not") local not = "Not normalised ";

      tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width  24|16 16 16 16 ;
	.`table'.strcolor . . yellow . . ;
	.`table'.numcolor yellow yellow . yellow yellow;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f ;
         if ("`hgroup'"!="") di as text  "{col 5}Group variable  :    `hgroup'";
        .`table'.sep, top;
	.`table'.titles "`component'  " "Estimate"  "STD "  "  LB  " "  UB  "  ;
	
	.`table'.sep, mid;
	local nalt = "ddd";
	
      .`table'.row "Distribution_1:(`tyind1')" el(_res_d1,1,1)  el(_res_d1,1,2) `lb_d1'  `ub_d1'  ; 
      .`table'.row "Distribution_2:(`tyind2')" el(_res_d2,1,1)  el(_res_d2,1,2) `lb_d2'  `ub_d2'  ;


  .`table'.sep,mid;
  .`table'.numcolor white white   white  white white ;
  .`table'.row "Difference" el(_res_di,1,1)  el(_res_di,1,2) `lb_dif'  `ub_dif' ;
  .`table'.sep,bot;

restore;


ereturn clear;
ereturn matrix d1 = _res_d1;
ereturn matrix d2 = _res_d2;
ereturn matrix di = _res_di;

cap matrix drop _res_d1;
cap matrix drop _res_d2;
cap matrix drop _res_di;
end;



