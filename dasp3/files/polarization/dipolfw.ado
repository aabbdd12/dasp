/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                       */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : dipolfw                                                     */
/*************************************************************************/



#delim ; 


/*****************************************************/
/* Density function      : fw=Hweight*Hsize      */
/*****************************************************/
cap program drop dfoswol_den;                    
program define dfoswol_den, rclass;              
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


cap program drop dipolfw2;  
program define dipolfw2, rclass ;    
version 9.2;         
syntax varlist (min=1 max=1) [, HSize(varname) HWeight(varname) RANK(varname) HGroup(varname)  GNumber(int -1) CI(real 5)  CONF(string) LEVEL(real 95) VAB(real 0)];

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

dfoswol_den `fw' `1' `q50';
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
            gen `vec_a' = 2*(`hs'*0.5*(2*`1'-`ca'-(`1'-`fx')-`theta'+(1.0)*(`xi')) - 2*`hs'*(0.5*`q50'+(`1'-`q50')*(`1'<`q50')));
            gen `vec_b' = `hs'*`q50'-`hs'*((`q50'>`1') - 0.50)/`fq50' ;

qui svy: ratio `vec_a'/`vec_b'; 
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


return scalar est  = `est';
return scalar std  = `std';
return scalar lb   = `est' - `tt'*`std';
return scalar ub   = `est' + `tt'*`std';
return scalar df   = `fr';

if (`vab'==1) {;
qui gen __va=`vec_a';
qui gen __vb=`vec_b';
};
end;     




capture program drop dipolfw;
program define dipolfw, eclass;
version 9.2;
syntax  namelist(min=2 max=2) [, FILE1(string) FILE2(string) 
RANK1(string)  RANK2(string)
HSize1(string) HSize2(string)
COND1(string)  COND2(string)  
type(string) LEVEL(real 95) CONF(string) TEST(string) DEC(int 6) *];

global indica=3;
tokenize `namelist';
if ("`conf'"=="")          local conf="ts";

preserve;
local indep = ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  );
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
dis as error " With condition(s) of distribution_1, the number of observations is 0.";
exit;
};
};

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight1=""; 
cap qui svy: total `1'; 
local hweight1=`"`e(wvar)'"';
cap ereturn clear; 

dipolfw2 `1' , hweight(`hweight1') hsize(`ths1')  rank(`rank1') conf(`conf') level(`level') vab(`vab');


if (`vab'==1) {;
tempvar va vb;
qui gen `va'=__va;
qui gen `vb'=__vb;
qui drop __va __vb;
};
matrix _res_d1  =(`r(est)',`r(std)',`r(lb)',`r(ub)', `r(df)') ;


if ("`file2'" !="" & `vab'!=1) use `"`file2'"', replace;
tempvar cd2 ths2;
qui gen `ths2'=1;
if ( "`hsize2'"!="") qui replace `ths2'=`hsize2';
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace `ths2'=`ths2'*`cd2';
qui sum `cd2';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_2 the number of observations is 0.";
exit;
};
};
qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local hweight2=""; 
cap qui svy: total `2'; 
local hweight2=`"`e(wvar)'"';
cap ereturn clear; 



dipolfw2 `2' , hweight(`hweight2') hsize(`ths2') rank(`rank2')  conf(`conf') level(`level') vab(`vab') ;

if (`vab'==1) {;
tempvar vc vd;
qui gen `vc'=__va;
qui gen `vd'=__vb;
qui drop __va __vb;
};

matrix _res_d2 =(`r(est)',`r(std)',`r(lb)',`r(ub)', `r(df)');
local dif = el(_res_d2,1,1)-el(_res_d1,1,1);
local std = (el(_res_d1,1,2)^2+el(_res_d2,1,2)^2)^0.5;
if (`vab'==1) {;
qui svy: mean `va' `vb' `vc' `vd';
qui nlcom (_b[`va']/_b[`vb']-_b[`vc']/_b[`vd'] ),  iterate(10000);;
cap drop matrix _vv;
matrix _vv=r(V);
local std = el(_vv,1,1)^0.5;
}; 

local sdif=`std';
local index = "Foster and Wolfson index of polarization (1992) (FW)";
local tyind1="FW_Dis1";
local tyind2="FW_Dis2";

      tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width  24|16 16 16 16 ;
	.`table'.strcolor . . yellow . . ;
	.`table'.numcolor yellow yellow . yellow yellow;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f ;
      di _n as text in white "{col 5}Index            :  `index' index";
       
local est1=el(_res_d1,1,1);
local est2=el(_res_d2,1,1);

local std1=el(_res_d1,1,2);
local std2=el(_res_d2,1,2);

local df1=el(_res_d1,1,5);
local df2=el(_res_d2,1,5);
     




_dasp_dif_table `2' `2', 
name1("`tyind1'")          name2("`tyind2'")
m1(`est1')            m2(`est2')
s1(`std1')            s2(`std2')
df1(`df1')            df2(`df2')
dif(`dif') sdif(`sdif')
level(`level') conf(`conf') indep(`indep') test(`test');


ereturn clear;
ereturn matrix d1 = _res_d1;
ereturn matrix d2 = _res_d2;


cap matrix drop _res_d1;
cap matrix drop _res_d2;



restore;

end;



