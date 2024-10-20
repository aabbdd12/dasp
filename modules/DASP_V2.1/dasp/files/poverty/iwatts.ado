/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.1)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : iwatts                                                        */
/*************************************************************************/

#delim ;





capture program drop iwatts2;
program define iwatts2, rclass;
version 9.2;
syntax varlist [,  FWeight(string) HSize(string) HGroup(varname) GNumber(int -1)  
PL(string) CONF(string) LEVEL(real 95)];
preserve;
tokenize `varlist';
cap drop if `1' ==.;
tempvar hs hsy;
gen `hs' =`hsize';

if (`gnumber'!=-1)    qui replace `fweight'=`fweight'*(`hgroup'==`gnumber');
if (`gnumber'!=-1)    qui replace `hs'  =`hs'*(`hgroup'==`gnumber');

cap drop `num' `snum';
tempvar num snum;
qui gen   `num'=0;
qui gen  `snum'=0;
qui replace    `num' = `hs'*-(log(`1')-log(`pl')) if (`pl'> `1');

qui svy: ratio `num'/`hs';
cap drop matrix _aa;
matrix _aa=e(b);
local est = el(_aa,1,1);
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

capture program drop iwatts;
program define iwatts, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) HGroup(varname) PLine(real 0)  CONF(string) LEVEL(real 95) DEC(int 6)];


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

tempvar _ths _fw;

qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';
qui gen `_fw'=`_ths';
if (`"`hweight'"'~="") qui replace `_fw'=`_fw'*`hweight';


local ll=length("`1': `grlab`1''");
local component = "Variable";
forvalues k = 1/$indica {;
if ("`hgroup'"=="") {;
qui replace `Variable' = "``k''" in `k';
iwatts2 ``k'' , fweight(`_fw') hsize(`_ths') pl(`pline')  conf(`conf') level(`level');
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

iwatts2 `1' ,  fweight(`_fw') hsize(`_ths') pl(`pline')  conf(`conf')  level(`level') hgroup(`hgroup') gnumber(`kk');
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
iwatts2 `1' ,  fweight(`_fw') hsize(`_ths') pl(`pline')  conf(`conf') level(`level');
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
	                      di _n as text in white "{col 5}Poverty index   :   Watts index";
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

local est="(";
local std="(";
forvalues i=1/$indica{;
local tem1=`Estimate'[`i'];
local tem2=`STE'[`i'];
 if (`i'!=$indica) local est = "`est'"+ "`tem1'\";
 if (`i'==$indica) local est = "`est'"+ "`tem1')";
 if (`i'!=$indica) local std = "`std'"+ "`tem2'\";
 if (`i'==$indica) local std = "`std'"+ "`tem2')";
};
tempname ES ST;
matrix define `ES'=`est';
matrix define `ST'=`std';
ereturn matrix est = `ES';
ereturn matrix std = `ST';
restore;
end;



