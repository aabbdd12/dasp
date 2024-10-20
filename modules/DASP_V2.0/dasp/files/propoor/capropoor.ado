
/* Best File */

/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.0)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universit Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/

#delim ;

capture program drop ifgtaprop2d;
program define ifgtaprop2d, rclass;
version 9.0;
set more off;
syntax namelist [,  FWeight(string) HSize1(string) HSize2(string) AL(real 0) PL(string) PL2(string) TYpe(string) CONF(string) LEVEL(real 95)];

if("`alpha'" == "0") local type ="not";
tokenize `namelist';

tempvar num1 hs1 num2 hs2;


qui gen `hs1'  = `hsize1';
qui gen `hs2'  = `hsize2';



qui gen  `num1'=0;
if (`al' == 0) qui replace                      `num1' = `hs1'*(`pl'> `1') ;
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `num1' = `hs1'*(`pl'-`1')^`al'          if (`pl'>`1');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace `num1' = `hs1'*((`pl'-`1')/`pl')^`al'  if (`pl'>`1' & `pl'!=0);

qui gen  `num2'=0;
if (`al' == 0) qui replace                      `num2' = `hs2'*(`pl2'> `2') ;
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `num2' = `hs2'*(`pl2'-`2')^`al'          if (`pl2'>`2');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace `num2' = `hs2'*((pl2'-`2')/`pl2')^`al'  if (`pl2'>`2' & `pl2'!=0);

qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;

if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');

qui svy: ratio (eq1: `num1'/`hsize1') (eq2:  `num2'/`hsize2'); 
cap drop matrix _aa;
matrix _aa=e(b);
local est1 = el(_aa,1,1);
matrix _vv=e(V);
local std1 = el(_vv,1,1)^0.5;


qui nlcom (_b[eq2]);
cap drop matrix _vv _aa;
matrix _aa=r(b);
local est2 = el(_aa,1,1);
matrix _vv=r(V);
local std2 = el(_vv,1,1)^0.5;



qui nlcom (_b[eq2])-(_b[eq1]);
cap drop matrix _vv _aa;

matrix _aa=r(b);
local est3 = el(_aa,1,1);
matrix _vv=r(V);
local std3 = el(_vv,1,1)^0.5;

return scalar std1  = `std1';
return scalar est1  = `est1';
return scalar lb1   = `est1' - `tt'*`std1';
return scalar ub1   = `est1' + `tt'*`std1';

return scalar std2  = `std2';
return scalar est2  = `est2';
return scalar lb2   = `est2' - `tt'*`std2';
return scalar ub2   = `est2' + `tt'*`std2';

return scalar std3  = `std3';
return scalar est3  = `est3';
return scalar lb3   = `est3' - `tt'*`std3';
return scalar ub3   = `est3' + `tt'*`std3';
end;



capture program drop ifgtaprop2_D;
program define ifgtaprop2_D, rclass;
version 9.0;
syntax namelist [,  HSize(string)  AL(real 0) PL(string) TYpe(string) CONF(string) LEVEL(real 95)];
tokenize `namelist';
tempvar num hs hsy;
qui gen `hs'  = `hsize';
qui gen  `num'=0;
if (`al' == 0) qui replace                      `num' = `hs'*(`pl'> `1');
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `num' = `hs'*(`pl'-`1')^`al'  if (`pl'>`1');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace `num' = `hs'*((`pl'-`1')/`pl')^`al'  if (`pl'>`1' & `pl'!=0);
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

return scalar std  = `std';
return scalar est  = `est';
return scalar lb   = `est' - `tt'*`std';
return scalar ub   = `est' + `tt'*`std';

end;





capture program drop capropoor;
program define capropoor, rclass;
version 9.0;
syntax  namelist(min=2 max=2) [, FILE1(string) FILE2(string) HSize1(string) 
HSize2(string) ALpha(real 0) MIN(real 0) MAX(real 10000)  COND1(string) COND2(string) 
cons(real 0) type(string) CONF(string) LEVEL(real 95) DEC(int 6) boot(string)];
global indica=3;
tokenize `namelist';
if ("`conf'"=="") local conf = "ts";
local abs = `cons';
preserve;
if ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;
set more off;
if (`"`file1'"'~="") use `"`file1'"', replace;
if ("`boot'"=="yes") bsample, strata(strata) cluster(psu);
tempvar cd1;
cap drop _ths1;
qui gen _ths1=1;
if ( "`hsize1'"!="") qui replace _ths1=`hsize1';
if ( "`cond1'"!="") {;
gen `cd1'=`cond1';
qui replace _ths1=_ths1*`cd1';
qui sum `cd1';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_1, the number of observations is 0.";
exit;
};
};

tempvar cd2;
cap drop _ths2;
qui gen _ths2=1;
if ( "`hsize2'"!="") qui replace _ths2=`hsize2';
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace _ths2=_ths2*`cd2';
qui sum `cd2i';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_2, the number of observations is 0.";
exit;
};
};




qui gen _fw=_ths2;
cap svy: total `2';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);



gen __pline=0;
gen __dif=0;
gen __lb=0;
gen __ub=0;
local _step=(`max'-`min')/100;

forvalues i=1/101 {;
local pl=(`i'-1)*`_step';
local pl2=`pl'+`abs';
ifgtaprop2d `1' `2' ,  hsize1(_ths1) hsize2(_ths2) pl(`pl') pl2(`pl2')  al(`alpha') type(`type')  conf(`conf') level(`level') ;
qui replace __pline =`pl'      in `i';
qui replace __dif  =`r(est3)' in `i';
qui replace __lb   =`r(lb3)'  in `i';
qui replace __ub   =`r(ub3)'  in `i';
};
qui mkmat __pline __dif __lb __ub in 1/101,  matrix(RES);

};


// second stage

if !( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;

if ("`file1'" !="") use `"`file1'"', replace;
if ("`boot'"=="yes") bsample, strata(strata) cluster(psu);
tempvar cd1;
cap drop _ths1;
qui gen _ths1=1;
if ( "`hsize1'"!="") qui replace _ths1=`hsize1';
if ( "`cond1'"!="") {;
gen `cd1'=`cond1';
qui replace _ths1=_ths1*`cd1';
qui sum `cd1';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_1, the number of observations is 0.";
exit;
};
};

cap svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);





cap drop __est1;
cap drop __std1;

cap gen __est1=0;
cap gen __std1=0;

local _step=(`max'-`min')/100;

dis "STEP 1/2";
forvalues i=1/101 {;
local pl=(`i'-1)*`_step';
ifgtaprop2_D `1' ,  hsize(_ths1 ) pl(`pl') al(`alpha') type(`type') conf(`conf') level(`level');
qui replace __est1  = `r(est)'   in `i';
qui replace __std1  = `r(std)'   in `i';
if (`i'!=101)  dis "." ,  _continue;
if (`i'/10==round(`i'/10)) dis " "  %4.2f `i' " %";
};

cap matrix drop MTA;
qui mkmat __est1 __std1  in 1/101, matrix(MTA);


cap matrix drop gra1;
cap matrix drop gra2;

restore;

preserve;

if ("`file2'" !="") use `"`file2'"', replace;
if ("`boot'"=="yes") bsample, strata(strata) cluster(psu);
tempvar cd2;
cap drop _ths2;
qui gen _ths2=1;
if ( "`hsize2'"!="") qui replace _ths2=`hsize2';
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace _ths2=_ths2*`cd2';
qui sum `cd2';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_2 the number of observations is 0.";
exit;
};
};

cap svy: total `2';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);





cap drop __est2;
cap drop __std2;

cap gen __est2=0;
cap gen __std2=0;

local _step=(`max'-`min')/100;
dis "STEP 2/2";
forvalues i=1/101 {;
local pl=(`i'-1)*`_step';
local pl2=`pl'+`abs';
ifgtaprop2_D `2' ,  hsize(_ths2 ) pl(`pl2') al(`alpha') type(`type')  conf(`conf') level(`level');
qui replace __est2  = `r(est)'   in `i';
qui replace __std2  = `r(std)'   in `i';
if (`i'!=101)  dis "." ,  _continue;
if (`i'/10==round(`i'/10)) dis " "  %4.2f `i' " %";
};

cap matrix drop MTB;
qui mkmat __est2 __std2  in 1/101, matrix(MTB);



cap drop __pline; qui gen __pline=0;
cap drop __dif;   qui gen __dif=0;
cap drop __std;   qui gen __std=0;
cap drop __lb;  qui gen __lb=0;
cap drop __ub;  qui gen __ub=0;

if ("`conf'"!="ts") local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl = (1-(100-`level')/200);
local zzz=invnorm(`lvl');

forvalues i=1/101 {;
local pl=(`i'-1)*`_step';
local dif=el(MTB,`i',1)-el(MTA,`i',1);
local std_dif=(el(MTA,`i',2)^2+el(MTB,`i',2)^2)^0.5;

qui replace __pline = `pl' in `i';
qui replace __dif = el(MTB,`i',1)-el(MTA,`i',1) in `i';
qui replace __lb   = `dif' - `zzz'*`std_dif'    in `i';
qui replace __ub   = `dif' + `zzz'*`std_dif'    in `i';
};


qui mkmat __pline __dif __lb __ub in 1/101,  matrix(RES);

};

qui restore;
end;




