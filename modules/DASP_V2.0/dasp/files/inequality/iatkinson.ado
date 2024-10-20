/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.0)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universit Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : iatkinson                                                       */
/*************************************************************************/

#delim ;

cap program drop iatkinson2;  
program define iatkinson2, rclass ;    
version 9.2;         
syntax varlist (min=1 max=1) [, HSize(varname) HWeight(varname) HGroup(varname) EPSIlon(real 0.5)  GNumber(int -1) CI(real 5)  CONF(string) LEVEL(real 95)];
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


if ( `epsilon' != 1.0 ) {;

tempvar vec_a vec_b vec_c;
gen   `vec_a' = `hs'*`1'^(1-`epsilon');    
gen   `vec_b' = `hs';           
gen   `vec_c' = `hs'*`1';     
qui svy: mean `vec_a' `vec_b' `vec_c';
cap drop matrix _aa;
matrix _aa=e(b);
global ws1=el(_aa,1,1);
global ws2=el(_aa,1,2);
global ws3=el(_aa,1,3);
local est=  1- $ws1^(1/(1-`epsilon'))*$ws2^(1+(1/(`epsilon'-1)))/$ws3;
cap drop matrix mat;
matrix mat=e(V);
cap drop matrix gra;
matrix gra=
(
-(1/(1-`epsilon'))*$ws1^(1/(1-`epsilon')-1)*$ws2^(1+(1/(`epsilon'-1)))/$ws3\
-(1+(1/(`epsilon'-1)))*$ws1^(1/(1-`epsilon'))*$ws2^((1/(`epsilon'-1)))/$ws3\
 $ws1^(1/(1-`epsilon'))*$ws2^(1+(1/(`epsilon'-1)))/$ws3^2
);
cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std= el(_zz,1,1)^0.5;  
};


if ( `epsilon' ==  1) {;
tempvar vec_a vec_b vec_c;
gen   `vec_a' = `hs'*log(`1');    
gen   `vec_b' = `hs';           
gen   `vec_c' = `hs'*`1';     
qui svy: mean `vec_a' `vec_b' `vec_c';
cap drop matrix _aa;
matrix _aa=e(b);
global ws1=el(_aa,1,1);
global ws2=el(_aa,1,2);
global ws3=el(_aa,1,3);
local est=  1- exp($ws1/$ws2)*($ws2/$ws3);
cap drop matrix mat;
matrix mat=e(V);
cap drop matrix gra;
matrix gra=
(
-exp($ws1/$ws2)*(1/$ws2)*($ws2/$ws3)\
exp($ws1/$ws2)*($ws1/$ws2^2)*($ws2/$ws3) - exp($ws1/$ws2)*(1/$ws3) \
exp($ws1/$ws2)*($ws2/$ws3^2)

);
cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std= el(_zz,1,1)^0.5;  };







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







capture program drop iatkinson;
program define iatkinson, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) HGroup(varname) EPSIlon(real 0.5)  CONF(string)
LEVEL(real 95) DEC(int 6)];


if ("`conf'"=="")          local conf="ts";
local ll=0;

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

tempvar Variable Estimate STD LB UB;
qui gen `Variable'="";
qui gen `Estimate'=0;
qui gen `STD'=0;
qui gen `LB'=0;
qui gen `UB'=0;


tempvar _ths;

qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';



local ll=length("`1': `grlab`1''");
local component = "Variable";
forvalues k = 1/$indica {;
if ("`hgroup'"=="") {;
local tind="atk";


qui replace `Variable' = "`k': `tind'_``k''" in `k';

iatkinson2 ``k'' , hweight(`hweight') epsilon(`epsilon') hsize(`_ths')    conf(`conf') level(`level');

qui replace `Estimate' = `r(est)' in `k';
qui replace `STD'      = `r(std)' in `k';
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

iatkinson2 `1' ,  hweight(`hweight') epsilon(`epsilon')  hsize(`_ths')   conf(`conf') 
level(`level') hgroup(`hgroup') gnumber(`kk');
qui replace `Estimate' = `r(est)' in `k';
qui replace `STD'      = `r(std)' in `k';
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
iatkinson2 `1' ,   hweight(`hweight') hsize(`_ths') epsilon(`epsilon')   conf(`conf') level(`level');
qui replace `Variable' = "Population" in `kk';
qui replace `Estimate' = `r(est)' in `kk';
qui replace `STD'      = `r(std)' in `kk';
qui replace `LB'       = `r(lb)'  in `kk';
qui replace `UB'       = `r(ub)'  in `kk';
if ("`conf'"=="lb")   qui replace `UB'       =.  in `kk';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `kk';
};

local 1kk = $indica;
local index = "Atkinson";


if ("`hgroup'"!="") local  1kk=`kk'-1;
tempname table;
	.`table'  = ._tab.new, col(5)  separator(0) lmargin(0);
	.`table'.width  `ll'|16 16 16 16 ;
	.`table'.strcolor . . yellow . . ;
	.`table'.numcolor yellow yellow . yellow yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f ;
	                      di _n as text in white "{col 5}Index              :  `index' index";
                            di as text     "{col 5}Parameter epsilon  :  `epsilon'";
       if ("`hsize'"!="")   di as text     "{col 5}Household size     :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight    :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable     :  `hgroup'";

       
      .`table'.sep, top;
	.`table'.titles "`component'  " "Estimate" "STD "	"  LB  " "  UB  ";
	
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`1kk'{;
           		.`table'.row `Variable'[`i'] `Estimate'[`i'] `STD'[`i'] `LB'[`i'] `UB'[`i']; 
	};
 if ("`hgroup'"=="")  .`table'.sep,bot;
if ("`hgroup'"!="") {;
  .`table'.sep, mid;
  .`table'.numcolor white green   green  green green ;
  .`table'.row `Variable'[`kk'] `Estimate'[`kk']  `STD'[`kk'] `LB'[`kk'] `UB'[`kk'];
  .`table'.sep,bot;
};

cap ereturn clear;
local kk =$indica + 1;
qui keep in 1/`kk';
tempname ES ST;
mkmat `Estimate', matrix(`ES');
ereturn matrix est = `ES';
mkmat `STD', matrix(`ST');
ereturn matrix std = `ST';
restore;
end;



