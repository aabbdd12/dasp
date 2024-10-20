/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 1.5)          */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2008)               */
/* Universite Laval, Quebec, Canada                                    */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : diwatts                                                       */
/*************************************************************************/


#delim ;
set more off;





capture program drop diwatts2;
program define diwatts2, rclass;
version 9.2;
syntax varlist [,  FWeight(string) HSize(varname)  
PL(string) CONF(string) LEVEL(real 95)];
preserve;
tokenize `varlist';
tempvar hs;
gen `hs' =`hsize';




cap drop `num' ;
tempvar num;
qui gen   `num'=0;
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
return scalar df  = `fr';
qui count; 
return scalar nobs  = `r(N)';
return scalar pl   = `pl';
return scalar est  = `est';
return scalar std  = `std';
return scalar lb   = `est' - `tt'*`std';
return scalar ub   = `est' + `tt'*`std';
end;




capture program drop diwatts2d;
program define diwatts2d, rclass;
version 9.2;
syntax namelist [,  FWEIGHT1(string) FWEIGHT2(string) HS1(string) HS2(string) AL(real 0) 
PL1(string) PL2(string)  CONF(string) LEVEL(real 95)];

tokenize `namelist';
tempvar num1 num2;
qui gen  `num1'=0;
qui gen  `num2'=0;



qui replace    `num1' = `hs1'*-(log(`1')-log(`pl1')) if (`pl1'> `1');
qui svy: ratio `num1'/`hs1';
cap drop matrix _aa;
matrix _aa=e(b);
local est1 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std1 = el(_vv,1,1)^0.5;




qui replace    `num2' = `hs2'*-(log(`2')-log(`pl2')) if (`pl2'> `2');
qui svy: ratio `num2'/`hs2';
cap drop matrix _aa;
matrix _aa=e(b);
local est2 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std2 = el(_vv,1,1)^0.5;




local est3=`est2'-`est1';


local equa2="";

local equa1 = "(_b[`num1']/_b[`hs1'])";
local smean1 = "`num1' `hs1' ";

local equa2 = "(_b[`num2']/_b[`hs2'])";
local smean2 = "`num2' `hs2' ";


qui svy: mean  `smean1' `smean2';

qui nlcom (`equa1'-`equa2'),  iterate(50000);
cap drop matrix _vv;
matrix _vv=r(V);
local std3 = el(_vv,1,1)^0.5;


qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;

if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');

return scalar std1  = `std1';
return scalar est1  = `est1';
return scalar lb1   = `est1' - `tt'*`std1';
return scalar ub1   = `est1' + `tt'*`std1';
return scalar pl1   = `pl1';
return scalar df    = `fr';
qui count; 
return scalar nobs  = `r(N)';

return scalar std2  = `std2';
return scalar est2  = `est2';
return scalar lb2   = `est2' - `tt'*`std2';
return scalar ub2   = `est2' + `tt'*`std2';
return scalar pl2   = `pl2';

return scalar std3  = `std3';
return scalar est3  = `est3';
return scalar lb3   = `est3' - `tt'*`std3';
return scalar ub3   = `est3' + `tt'*`std3';


end;






capture program drop diwatts;
program define diwatts, eclass;
version 9.2;
syntax  namelist(min=2 max=2) [, FILE1(string) FILE2(string) HSize1(string) HSize2(string)
ALpha(real 0)  COND1(string) COND2(string) 
PLINE1(real 10000) 
PLINE2(real 10000) 
LEVEL(real 95) CONF(string) DEC(int 6) BOOT(string) NREP(string) TEST(string) *];

global indica=3;
tokenize `namelist';

if ("`conf'"=="")          local conf="ts";

preserve;

local indep = ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  );


if ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;
if (`"`file1'"'~="") use `"`file1'"', replace;


tempvar cd1 ths1;

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

tempvar cd2 ths2;
qui gen `ths2'=1;
if ( "`hsize2'"!="") qui replace `ths2'=`hsize2';
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace `ths2'=`ths2'*`cd2';
qui sum `cd2i';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_2, the number of observations is 0.";
exit;
};
};


qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
tempvar fw1 fw2;
gen `fw1'=`ths1';
gen `fw2'=`ths2';
if ("`hweight'"!="") qui replace `fw1'=`fw1'*`hweight';
if ("`hweight'"!="") qui replace `fw2'=`fw2'*`hweight';

diwatts2d `1' `2' ,  
fweight1(`fw1') fweight2(`fw2') 
hs1(`ths1') hs2(`ths2') 
pl1(`pline1') pl2(`pline2')  
level(`level') conf(`conf');

matrix _res_d1  =(`r(est1)',`r(std1)',`r(lb1)',`r(ub1)' ,`r(pl1)');
matrix _res_d2  =(`r(est2)',`r(std2)',`r(lb2)',`r(ub2)' ,`r(pl2)');
matrix _res_di  =(`r(est3)',`r(std3)',`r(lb3)',`r(ub3)');
local name1 "Watts_D1";
local name2 "Watts_D2";    
_dasp_dif_table_ifgt `1' `1', 
name1("`name1'") name2("`name2'")
pl1(`r(pl1)')  pl2(`r(pl2)')
m1(`r(est1)')  m2(`r(est2)')
s1(`r(std1)')  s2(`r(std2)')
df1(`r(df)') df2(`r(df)')
dif(`r(est3)') sdif(`r(std3)')
level(`level') conf(`conf') indep(`indep') test(`test');



};


// second stage
if !( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;
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

tempvar fw1;
gen `fw1'=`ths1';
if ("`hweight1'"!="") qui replace `fw1'=`fw1'*`hweight1';

diwatts2 `1' , fweight(`fw1') hsize(`ths1') pl(`pline1')  conf(`conf') level(`level') ;
matrix _res_d1  =(`r(est)',`r(std)',`r(lb)',`r(ub)' ,`r(pl)', `r(df)');



if ("`file2'" !="") use `"`file2'"', replace;
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

tempvar fw2;
gen `fw2'=`ths2';

if ("`hweight2'"!="") qui replace `fw2'=`fw2'*`hweight2';


diwatts2 `2' , fweight(`fw2') hsize(`ths2') pl(`pline2')  conf(`conf') level(`level') ;
matrix _res_d2  =(`r(est)',`r(std)',`r(lb)',`r(ub)' ,`r(pl)', `r(df)');



local dif = el(_res_d2,1,1)-el(_res_d1,1,1);
local stdif = (el(_res_d1,1,2)^2+el(_res_d2,1,2)^2)^0.5;


local est1=el(_res_d1,1,1);
local est2=el(_res_d2,1,1);

local std1=el(_res_d1,1,2);
local std2=el(_res_d2,1,2);

local df1=el(_res_d1,1,6);
local df2=el(_res_d2,1,6);

local pl1=el(_res_d1,1,5);
local pl2=el(_res_d2,1,5);
local name1 "Watts_D1";
local name2 "Watts_D2";      

dis _n "Poverty Index: WATTS"; 
_dasp_dif_table_ifgt `2' `2', 
name1("`name1'")          name2("`name2'")
pl1(`pl1')         pl2(`pl2')
m1(`est1')            m2(`est2')
s1(`std1')             s2(`std2')
df1(`df1')            df2(`df2')
dif(`dif') sdif(`stdif')
level(`level') conf(`conf') indep(`indep') test(`test');
};





restore;


cap matrix drop _res_d1;
cap matrix drop _res_d2;
cap matrix drop _res_di;
end;



