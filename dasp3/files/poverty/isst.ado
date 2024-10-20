/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : isst                                                        */
/*************************************************************************/

#delim ;





capture program drop isst2;
program define isst2, rclass;
version 9.2;
syntax varlist [,  HWeight(string) HSize(string) HGroup(varname) GNumber(int -1)  
PL(string) CONF(string) LEVEL(real 95) index(string) *];
preserve;
tokenize `varlist';
                     qui drop if `1'>=. ;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;

sort `1', stable;
tempvar cg;
gen double `cg' = 0;
qui replace    `cg' = (1 - `1'/`pl') if `pl'>`1';



tempvar  hs sw fw ;
gen `sw'=1;
gen `hs'=1;

if ("`hsize'"!="")     qui replace `hs' = `hsize';
tempvar _in;
if ("`hgroup'" != "")  qui gen    `_in' = (`hgroup' == `gnumber');
if ("`hgroup'" != "")  qui replace `hs' = `hs' * `_in';
if ("`hweight'"!="")   qui replace `sw'=`hweight';

gen `fw'=`hs'*`sw';
tempvar smw smwy l1smwy ca;
gen `smw'  =sum(`fw');
gen `smwy' =sum(`cg'*`fw');
gen `l1smwy'=0;
local mu=`smwy'[_N]/`smw'[_N];
local suma=`smw'[_N];
qui count;
forvalues i=2/`r(N)' { ;
qui replace `l1smwy'=`smwy'[`i'-1]  in `i';
};
qui gen `ca'=`mu'+`cg'*((1.0/`smw'[_N])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[_N])*(2.0*`l1smwy'+`fw'*`cg'); 
qui sum `ca' [aw=`fw'], meanonly; 
local gini=`r(mean)'/(2.0);
local xi   = `r(mean)';
tempvar vec_a vec_b  vec_ob theta v1 v2 sv1 sv2;
qui count;

         
            local fx=0;
            gen `v1'=`fw'*`cg';
            gen `v2'=`fw';
            gen `sv1'=sum(`v1');
            gen `sv2'=sum(`v2') ;
            qui replace `v1'=`sv1'[`r(N)']   in 1;
		    qui replace `v2'=`sv2'[`r(N)']   in 1;

            forvalues i=2/`r(N)'  {;
            qui replace `v1'=`sv1'[`r(N)']-`sv1'[`i'-1]   in `i';
		    qui replace `v2'=`sv2'[`r(N)']-`sv2'[`i'-1]   in `i';
            } ;
           
            gen `theta'=`v1'-`v2'*`cg';

           forvalues i=1/`r(N)' {;
                qui replace `theta'=`theta'[`i']*(2.0/`suma')  in `i';
                local fx=`fx'+`fw'[`i']*`cg'[`i'];
            };            
            local fx=`fx'/`suma';
            gen `vec_a' = `hs'*((1.0)*`ca'-`fx'+`theta'-(1.0)*(`xi')-`cg');
            gen `vec_b' =  2*`hs';

            qui svy: ratio `vec_a'/`vec_b'; 

cap drop matrix _aa;
matrix _aa=e(b);
local est = -1*el(_aa,1,1);

cap drop matrix _vv;
matrix _vv=e(V);
local std = el(_vv,1,1)^0.5;


qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');

return scalar pl   = `pl';
return scalar est  = `est';
return scalar std  = `std';
return scalar lb   = `est' - `tt'*`std';
return scalar ub   = `est' + `tt'*`std';
end;

capture program drop isst;
program define isst, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) HGroup(varname) PLine(string)  CONF(string) LEVEL(real 95) DEC(int 6) *];


if ("`conf'"=="")          local conf="ts";

local ll=0;

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 



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
tempvar Variable Estimate STE LB UB PL;
qui gen `Variable'="";
qui gen `Estimate'=0;
qui gen `STE'=0;
qui gen `LB'=0;
qui gen `UB'=0;
qui gen `PL'=0;

tempvar _ths _hw;

qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';
qui gen `_hw'=1;
if (`"`hweight'"'~="") qui replace `_hw'=`hweight';


local ll=length("`1': `grlab`1''");
local component = "Variable";
forvalues k = 1/$indica {;
if ("`hgroup'"=="") {;
qui replace `Variable' = "``k''" in `k';
isst2 ``k'' , hweight(`_hw') hsize(`_ths') pl(`pline')  conf(`conf') level(`level');
local pline=`r(pl)';
qui replace `Estimate' = `r(est)' in `k';
qui replace `STE'      = `r(std)' in `k';
qui replace `LB'       = `r(lb)'  in `k';
qui replace `UB'       = `r(ub)'  in `k';
qui replace `PL'       = `r(pl)'  in `k';
if ("`conf'"=="lb")   qui replace `UB'       =.  in `k';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `k';

};

if ("`hgroup'"!="") {;
local kk = gn1[`k'];

if ( "`grlab`kk''" == "") local grlab`kk' = "Group_`kk'";
qui replace `Variable' = "`kk': `grlab`kk''" in `k';

isst2 `1' ,  hweight(`_hw') hsize(`_ths') pl(`pline')  conf(`conf')  level(`level') hgroup(`hgroup') gnumber(`kk');
qui replace `Estimate' = `r(est)' in `k';
qui replace `STE'      = `r(std)' in `k';
qui replace `LB'       = `r(lb)'  in `k';
qui replace `UB'       = `r(ub)'  in `k';
qui replace `PL'       = `r(pl)'  in `k';
if ("`conf'"=="lb")   qui replace `UB'       =.  in `k';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `k';

local ll=max(`ll',length("`kk': `grlab`k''"));
local component = "Group";
};

};

local ll=`ll'+6;


if ("`hgroup'"!="") {;
isst2 `1' ,  hweight(`_hw') hsize(`_ths') pl(`pline')  conf(`conf') level(`level');
local kk =$indica + 1;
qui replace `Variable' = "Population" in `kk';
qui replace `Estimate' = `r(est)' in `kk';
qui replace `STE'      = `r(std)' in `kk';
qui replace `LB'       = `r(lb)'  in `kk';
qui replace `UB'       = `r(ub)'  in `kk';
qui replace `PL'       = `r(pl)'  in `kk';
if ("`conf'"=="lb")   qui replace `UB'       =.  in `kk';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `kk';
};

local 1kk = $indica;
if ("`hgroup'"!="") local  1kk=`kk'-1;
tempname table;
	.`table'  = ._tab.new, col(6)  separator(0) lmargin(0);
	.`table'.width  `ll'|16 16 16 16 16 ;
	.`table'.strcolor . . yellow . . . ;
	.`table'.numcolor yellow yellow . yellow yellow white ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f %16.2f;
	                      di _n as text in white "{col 5}Poverty index   :   Sen, Shorrocks and Thon index";
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";
       
      .`table'.sep, top;
	.`table'.titles "`component'  " "Estimate" "STE "	"  LB  " "  UB  " "Pov. line" ;
	
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`1kk'{;
           		.`table'.row `Variable'[`i'] `Estimate'[`i'] `STE'[`i'] `LB'[`i'] `UB'[`i'] `PL'[`i']; 
	};
 if ("`hgroup'"=="")  .`table'.sep,bot;
if ("`hgroup'"!="") {;
  .`table'.sep, mid;
  .`table'.numcolor white green   green  green green white ;
  .`table'.row `Variable'[`kk'] `Estimate'[`kk']  `STE'[`kk'] `LB'[`kk'] `UB'[`kk'] `PL'[`kk'];
  .`table'.sep,bot;
};


cap ereturn clear;

tempname ES ST;
 qui mkmat	 `Estimate' in 1/$indica,	matrix(`ES');
 qui mkmat	 `STE'      in 1/$indica,	matrix(`ST');

ereturn matrix est = `ES';
ereturn matrix std = `ST';

restore;
end;



