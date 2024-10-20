/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.2)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)         */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : ipolfw                                                      */
/*************************************************************************/

#delim ;



/*****************************************************/
/* Density function      : fw=Hweight*Hsize          */
/*****************************************************/
cap program drop foswol_den;                    
program define foswol_den, rclass;              
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


cap program drop ipolfw2;  
program define ipolfw2, rclass ;    
version 9.2;         
syntax varlist (min=1 max=1) [, HSize(varname) HWeight(varname) RANK(varname) HGroup(varname)  GNumber(int -1) CI(real 5)  CONF(string) LEVEL(real 95)];
preserve;
tokenize `varlist';
if ("`rank'"=="") sort `1', stable;
if ("`rank'"!="") sort `rank' , stable;
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

gen `fw'=`hs'*`sw';

qui sum `1' [aw=`fw'], detail;
local q50 = `r(p50)';

foswol_den `fw' `1' `q50';
local fq50=`r(den)';

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
local polfw=`r(mean)'/(2.0*`mu');
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
            gen `vec_a' = `hs'*(2*`1'-`ca'-(`1'-`fx')-`theta'+(1.0)*(`xi')) - 4*`hs'*(0.5*`q50'+(`1'-`q50')*(`1'<`q50'));
            gen `vec_b' = `hs'*`q50'-`hs'*((`q50'>`1') - 0.50)/`fq50' ;
			

qui svy: ratio `vec_a'/`vec_b'; 
cap drop matrix _aa;
matrix _aa=e(b);
local estim = el(_aa,1,1);


cap drop matrix _vv;
matrix _vv=e(V);
local std = el(_vv,1,1)^0.5;

qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');


return scalar estim  = `estim';
return scalar std  = `std';
return scalar lb   = `estim' - `tt'*`std';
return scalar ub   = `estim' + `tt'*`std';
end;     




capture program drop ipolfw;
program define ipolfw, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) RANK(varname) HGroup(varname)  CONF(string)
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
local tind="POL_FW";
if ("`rank'" != "" & "`rank'" != "``k''" ) local tind="CONC";

qui replace `Variable' = "`k': `tind'_``k''" in `k';

ipolfw2 ``k'' , hweight(`hweight') rank(`rank') hsize(`_ths')    conf(`conf') level(`level');
qui replace `Estimate' = `r(estim)' in `k';
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

ipolfw2 `1' ,  hweight(`hweight') rank(`rank')  hsize(`_ths')   conf(`conf') 
level(`level') hgroup(`hgroup') gnumber(`kk');
 
qui replace `Estimate' = `r(estim)' in `k';
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
ipolfw2 `1' ,   hweight(`hweight') hsize(`_ths') rank(`rank')   conf(`conf') level(`level');

qui replace `Variable' = "Population" in `kk';
qui replace `Estimate' = `r(estim)' in `kk';
qui replace `STE'      = `r(std)' in `kk';
qui replace `LB'       = `r(lb)'  in `kk';
qui replace `UB'       = `r(ub)'  in `kk';
if ("`conf'"=="lb")   qui replace `UB'       =.  in `kk';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `kk';
};

local 1kk = $indica;
local index = "Foster & Wolfson (1992) polarization";
if ("`rank'"!="") local index = "Concentration";

if ("`hgroup'"!="") local  1kk=`kk'-1;
tempname table;
	.`table'  = ._tab.new, col(5)  separator(0) lmargin(0);
	.`table'.width  `ll'|16 16 16 16 ;
	.`table'.strcolor . . yellow . . ;
	.`table'.numcolor yellow yellow . yellow yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f ;
	                      di _n as text in white "{col 5}Index            :  `index' index";
       if ("`rank'"!="")    di as text     "{col 5}Ranking variable :  `rank'";
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
restore;
end;





