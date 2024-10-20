/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2008)          */
/* Universite Laval, Quebec, Canada                                    */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : iprog                                                       */
/*************************************************************************/







#delim ;
set more off;
cap program drop iprog2;  
program define iprog2, rclass  ;    
version 9.2;         
syntax varlist (min=2) [, HSize(varname) HWeight(varname) gobs(varname) ynumber(int 2000) ginc(varname)  CI(real 5)  CONF(string) LEVEL(real 95) VAB(real 0) TYPE(string)];
preserve;
if ("`gobs'" != "")  qui   keep if (`gobs' == `ynumber') ;
tokenize `varlist';
if ("`ginc'"=="") sort `1'    , stable;
if ("`ginc'"!="") sort `ginc' , stable;
                     qui drop if `1'>=. ;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;
tempvar  hs sw fw ;
gen `sw'=1;
gen `hs'=1;
if ("`hsize'"!="")     qui replace `hs' = `hsize';
if ("`hweight'"!="")   qui replace `sw' = `hweight';
gen `fw'=`hs'*`sw';
tempvar smw smwy1 l1smwy1 ca1 smwy2 l1smwy2 ca2 ;
gen `smw'  =sum(`fw');
gen `smwy1' =sum(`1'*`fw');
gen `smwy2' =sum(`2'*`fw');
gen `l1smwy1'=0;
gen `l1smwy2'=0;
local mu1=`smwy1'[_N]/`smw1'[_N];
local mu2=`smwy2'[_N]/`smw2'[_N];
local suma=`smw'[_N];
qui count;
forvalues i=2/`r(N)' { ;
qui replace `l1smwy1'=`smwy1'[`i'-1]  in `i';
qui replace `l1smwy2'=`smwy2'[`i'-1]  in `i';
};

gen `ca1'=`mu1'+`1'*((1.0/`smw'[_N])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[_N])*(2.0*`l1smwy1'+`fw'*`1'); 
gen `ca2'=`mu2'+`2'*((1.0/`smw'[_N])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[_N])*(2.0*`l1smwy2'+`fw'*`2'); 
qui sum `ca1' [aw=`fw'], meanonly;  local xi1 = `r(mean)';
local est1=`r(mean)'/(2.0*`mu1'); 
qui sum `ca2' [aw=`fw'], meanonly;  local xi2 = `r(mean)';
local est2=`r(mean)'/(2.0*`mu2');



tempvar vec_a vec_b theta1 v11 v21 sv11 sv21;
qui count;

         
            local fx1=0;
            gen `v11'=`fw'*`1';
            gen `v21'=`fw';
            gen `sv11'=sum(`v11');
            gen `sv21'=sum(`v21') ;
                qui replace `v11'=`sv11'[`r(N)']   in 1;
                qui replace `v21'=`sv21'[`r(N)']   in 1;

            forvalues i=2/`r(N)'  {;
                qui replace `v11'=`sv11'[`r(N)']-`sv11'[`i'-1]   in `i';
                qui replace `v21'=`sv21'[`r(N)']-`sv21'[`i'-1]   in `i';
            } ;
           
            gen `theta1'=`v11'-`v21'*`1';

           forvalues i=1/`r(N)' {;
                qui replace `theta1'=`theta1'[`i']*(2.0/`suma')  in `i';
                local fx1=`fx1'+`fw'[`i']*`1'[`i'];
            };            
            local fx1=`fx1'/`suma';
            qui gen `vec_a' = `hs'*((1.0)*`ca1'+(`1'-`fx1')+`theta1'-(1.0)*(`xi1'));
            qui gen `vec_b' =  2*`hs'*`1';
			
			
			
tempvar vec_c vec_d theta2 v12 v22 sv12 sv22;
qui count;

         
            local fx2=0;
            gen `v12'=`fw'*`2';
            gen `v22'=`fw';
            gen `sv12'=sum(`v12');
            gen `sv22'=sum(`v22') ;
                qui replace `v12'=`sv12'[`r(N)']   in 1;
                qui replace `v22'=`sv22'[`r(N)']   in 1;

            forvalues i=2/`r(N)'  {;
                qui replace `v12'=`sv12'[`r(N)']-`sv12'[`i'-1]   in `i';
                qui replace `v22'=`sv22'[`r(N)']-`sv22'[`i'-1]   in `i';
            } ;
           
            gen `theta2'=`v12'-`v22'*`2';

           forvalues i=1/`r(N)' {;
                qui replace `theta2'=`theta2'[`i']*(2.0/`suma')  in `i';
                local fx2=`fx2'+`fw'[`i']*`2'[`i'];
            };            
            local fx2=`fx2'/`suma';
            qui gen `vec_c' = `hs'*((1.0)*`ca2'+(`2'-`fx2')+`theta2'-(1.0)*(`xi2'));
            qui gen `vec_d' =  2*`hs'*`2';

qui svy: mean  `vec_a' `vec_b' `vec_c' `vec_d'; 
qui nlcom  (_b[`vec_a']/_b[`vec_b']) - (_b[`vec_c']/_b[`vec_d']), iterate(50000);
cap matrix drop _aa;
matrix _aa=r(b);
local est =  el(_aa,1,1);
return scalar est    = `est';
matrix _vv=r(V);
local std = el(_vv,1,1)^0.5;
return scalar std    = `std';
qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');
return scalar est  = `est';
return scalar std  = `std';
return scalar lb   = `est' - `tt'*`std';
return scalar ub   = `est' + `tt'*`std';
return scalar df  = `fr';
qui count; 
return scalar nobs  = `r(N)';
restore;
end;     




capture program drop iprog;
program define iprog, eclass;
version 9.2;
syntax  varlist(min=1) [, GINC(string) HSize(string) gobs(varname) TYPE(string) INDEX(string)  LEVEL(real 95) CONF(string) TEST(string) DEC(int 6)];
if ("`index'"=="") local index = "ka" ;
if ("`type'" =="") local type =  "t" ;

if ("`conf'"=="")          local conf="ts";


if ("`gobs'"!="") {;

preserve;
capture {;
local lvgroup:value label `gobs';
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
qui tabulate `gobs', matrow(gn);
svmat int gn;
global indica=r(r);
tokenize `varlist';
};

if ("`gobs'"=="") {;
tokenize `varlist';
_nargs    `varlist';
preserve;
};

tempvar ths;
qui gen `ths'=1;

if ( "`hsize'"!="") qui replace `ths'=`hsize';


qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

local ci=100-`level';

tempvar Index Estimate STE LB UB;
qui gen `Index'="";
qui gen `Estimate'=0;
qui gen `STE'=0;
qui gen `LB'=0;
qui gen `UB'=0;


tempvar _ths;

qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';

local ll=length("`1': `grlab`1''");
local component = "Index";
forvalues k = 1/$indica {;
if ("`gobs'"=="") {;
                         local tind="KAK";
if ("`index'" == "rs"  ) local tind="R&S";
qui replace `Index' = "`k': `tind'_``k''" in `k';

cap drop  `comp1' `comp2' ;
tempvar   comp1 comp2 ;
if "`index'" == "ka" & "`type'" == "t" {;
gen  `comp1'  = ``k'' ;
gen  `comp2'  = `ginc' ;
};

if "`index'" == "ka" & "`type'" == "b" {;
gen  `comp1'  = `ginc' ;
gen  `comp2'  = ``k'' ;
};

if "`index'" == "rs" & "`type'" == "t" {;
gen  `comp2'  = `ginc' - ``k''  ;
gen  `comp1'  = `ginc' ;
};
if "`index'" == "rs" & "`type'" == "b" {;
gen  `comp2'  = `ginc' + ``k''  ;
gen  `comp1'  = `ginc' ;
};
iprog2 `comp1' `comp2' , hweight(`hweight') ginc(`ginc') hsize(`_ths')   
 conf(`conf') level(`level') ;

qui replace `Estimate' = `r(est)' in `k';
qui replace `STE'      = `r(std)' in `k';
qui replace `LB'       = `r(lb)'  in `k';
qui replace `UB'       = `r(ub)'  in `k';
if ("`conf'"=="lb")   qui replace `UB'       =.  in `k';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `k';

};



if ("`gobs'"!="") {;
local kk = gn1[`k'];
local label`k'  : label (`gobs') `kk';
if "`label`k''"=="" local label`k'="gobs: `kk'";
qui replace `Index' = "`label`k''" in `k';

cap drop  `comp1' `comp2' ;
tempvar   comp1 comp2 ;
if "`index'" == "ka" & "`type'" == "t" {;
gen  `comp1'  = `1' ;
gen  `comp2'  = `ginc' ;
};

if "`index'" == "ka" & "`type'" == "b" {;
gen  `comp1'  = `ginc' ;
gen  `comp2'  = `1' ;
};

if "`index'" == "rs" & "`type'" == "t" {;
gen  `comp2'  = `ginc' - `1'  ;
gen  `comp1'  = `ginc' ;
};
if "`index'" == "rs" & "`type'" == "b" {;
gen  `comp2'  = `ginc' + `1'  ;
gen  `comp1'  = `ginc' ;
};

iprog2 `comp1' `comp2' ,   hweight(`hweight') ginc(`ginc')  hsize(`_ths')   conf(`conf') 
level(`level') gobs(`gobs') ynumber(`kk') type(`type') ;
qui replace `Estimate' = `r(est)' in `k';
qui replace `STE'      = `r(std)' in `k';
qui replace `LB'       = `r(lb)'  in `k';
qui replace `UB'       = `r(ub)'  in `k';

if ("`conf'"=="lb")   qui replace `UB'       =.  in `k';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `k';

local ll=max(`ll',length(" gobs_`grlab`k''"));
local component = "gobs";
};

};

local ll=`ll'+10;



                       local inda = "Kakwani progressivity";
if ("`index'" == "rs") local inda = "Reynold and Smolensky progressivity";


tempname table;
        .`table'  = ._tab.new, col(5)  separator(0) lmargin(0);
        .`table'.width  `ll'|16 16 16 16 ;
        .`table'.strcolor . . yellow . . ;
        .`table'.numcolor yellow yellow . yellow yellow ;
        .`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f ;
                              di _n as text in white "{col 5}Index            {col 30}:  `inda' index";
       if ("`ginc'"!="")    di as text     "{col 5}Gross income variable  {col 30}:  `ginc'";
       if ("`hsize'"!="")   di as text     "{col 5}Household size   {col 30}:  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight  {col 30}:  `hweight'";
       if ("`gobs'"!="")  di as text     "{col 5}gobs variable   {col 30}:  `gobs'";

       
      .`table'.sep, top;
        .`table'.titles "`component'  " "Estimate" "STE "       "  LB  " "  UB  ";
        
        .`table'.sep, mid;
        local nalt = "ddd";
        forvalues i=1/$indica{;
                        .`table'.row `Index'[`i'] `Estimate'[`i'] `STE'[`i'] `LB'[`i'] `UB'[`i']; 
        };
 .`table'.sep,bot;

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



