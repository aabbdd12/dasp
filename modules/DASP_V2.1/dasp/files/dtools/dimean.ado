/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.1)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : dimean                                                       */
/*************************************************************************/




#delim ;
set more off;
cap program drop dimean2;  
program define dimean2, rclass;    
version 9.2;         
syntax varlist (min=1 max=1) [, HSize(varname) HWeight(varname)  CI(real 5)  CONF(string) LEVEL(real 95) VAB(real 0)];
tokenize `varlist';

                     qui drop if `1'>=. ;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;
tempvar  hs sw fw ;
gen `sw'=1;
gen `hs'=1;
if ("`hsize'"!="")     qui replace `hs' = `hsize';
if ("`hweight'"!="")   qui replace `sw' = `hweight';
gen `fw'=`hs'*`sw';



tempvar vec_a vec_b;
gen   `vec_a' = `hs'*`1';    
gen   `vec_b' = `hs';           
qui svy: ratio `vec_a'/`vec_b';
cap drop matrix _aa;
matrix _aa=e(b);
local est  =  el(_aa,1,1);
matrix _vv=e(V);
local std= el(_vv,1,1)^0.5;  

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

if (`vab'==1) {;
qui gen __va=`vec_a';
qui gen __vb=`vec_b';

};
end;     





capture program drop dimean;
program define dimean, eclass;
version 9.2;
syntax  namelist(min=2 max=2) [, FILE1(string) FILE2(string) 
HSize1(string) HSize2(string)
COND1(string)  COND2(string)  
 LEVEL(real 95) CONF(string) TEST(string) DEC(int 6)];

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
dis as error " With condition(s) for distribution_1, the number of observations is 0.";
exit;
};
};

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight1=""; 
cap qui svy: total `1'; 
local hweight1=`"`e(wvar)'"';
cap ereturn clear; 

dimean2 `1' , hweight(`hweight1') hsize(`ths1')  conf(`conf') level(`level') vab(`vab');
if (`vab'==1) {;
tempvar va vb vc;
qui gen `va'=__va;
qui gen `vb'=__vb;
qui drop __va __vb;
};
matrix _res_d1  =(`r(est)',`r(std)',`r(lb)',`r(ub)',`r(df)') ;


if ("`file2'" !="" & `vab'!=1) use `"`file2'"', replace;
tempvar cd2 ths2;
qui gen `ths2'=1;
if ( "`hsize2'"!="") qui replace `ths2'=`hsize2';
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace `ths2'=`ths2'*`cd2';
qui sum `cd2';
if (`r(sum)'==0) {;
dis as error " With condition(s) for distribution_2 the number of observations is 0.";
exit;
};
};
qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local hweight2=""; 
cap qui svy: total `2'; 
local hweight2=`"`e(wvar)'"';
cap ereturn clear; 



dimean2 `2' , hweight(`hweight2') hsize(`ths2')  conf(`conf') level(`level') vab(`vab') ;
if (`vab'==1) {;
tempvar vc vd ;
qui gen `vc'=__va;
qui gen `vd'=__vb;
qui drop __va __vb;
};

matrix _res_d2 =(`r(est)',`r(std)',`r(lb)',`r(ub)', `r(df)') ;

local dif = el(_res_d2,1,1)-el(_res_d1,1,1);
local std = (el(_res_d1,1,2)^2+el(_res_d2,1,2)^2)^0.5;

if (`vab'==1) {;
qui svy: mean `va' `vb' `vc' `vd';
cap drop matrix _aa;
matrix _aa=e(b);
global ws1=el(_aa,1,1);
global ws2=el(_aa,1,2);
global ws3=el(_aa,1,3);
global ws4=el(_aa,1,4);
cap drop matrix mat;
matrix mat=e(V);


cap drop matrix gra;

matrix gra=
(
1/$ws2\
-$ws1/$ws2^2\
-1/$ws4\
$ws3/$ws4^2
);

cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std= el(_zz,1,1)^0.5; 

}; 

local sdif = `std';

if ("`conf'"!="ts") local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl = (1-(100-`level')/200);
local zzz=invnorm(`lvl');
local lb   = `dif' -  `zzz'*`std';
local ub   = `dif' +  `zzz'*`std';
matrix _res_di =(`dif',`std',`lb',`ub');




local est1=el(_res_d1,1,1);
local est2=el(_res_d2,1,1);

local std1=el(_res_d1,1,2);
local std2=el(_res_d2,1,2);

local df1=el(_res_d1,1,5);
local df2=el(_res_d2,1,5);
     

local tyind1="mean_D1";
local tyind2="mean_D2";


_dasp_dif_table `2' `2', 
name1("`tyind1'")          name2("`tyind2'")
m1(`est1')            m2(`est2')
s1(`std1')            s2(`std2')
df1(`df1')            df2(`df2')
dif(`dif') sdif(`sdif')
level(`level') conf(`conf') indep(`indep') test(`test');




restore;
ereturn clear;
ereturn matrix d1 = _res_d1;
ereturn matrix d2 = _res_d2;
ereturn matrix di = _res_di;

cap matrix drop _res_d1;
cap matrix drop _res_d2;
cap matrix drop _res_di;
end;



