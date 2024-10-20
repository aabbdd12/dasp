/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                       */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : disst                                                       */
/*************************************************************************/


#delim ;
set more off;

capture program drop disst2;
program define disst2, rclass;
version 9.2;
version 9.2;
syntax varlist [,  HWeight(string) HSize(string) HGroup(varname) GNumber(int -1)   PL(string) CONF(string) LEVEL(real 95)];
preserve;
tokenize `varlist';
                     qui drop if `1'>=. ;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;

sort `1', stable;
tempvar cg;
gen double     `cg' = 0;
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
            gen `vec_a' = `hs'*((1.0)*`ca'+(`rank'-`fx')+`theta'-(1.0)*(`xi')-`cg');
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
return scalar df  = `fr';
qui count; 
return scalar nobs  = `r(N)';
return scalar pl   = `pl';
return scalar est  = `est';
return scalar std  = `std';
return scalar lb   = `est' - `tt'*`std';
return scalar ub   = `est' + `tt'*`std';
end;




capture program drop disst2d;
program define disst2d, rclass;
version 9.2;
syntax namelist [,  HWEIGHT1(string) HWEIGHT2(string) HS1(string) HS2(string) AL(real 0) 
PL1(string) PL2(string)  CONF(string) LEVEL(real 95)];

tokenize `namelist';
tempvar num1 num2;
qui gen  `num1'=0;
qui gen  `num2'=0;



sort `1', stable;
tempvar cg1;
gen double     `cg1' = 0;
qui replace    `cg1' = (1 - `1'/`pl1') if `pl1'>`1';

tempvar  sw1 fw1 ;
gen `sw1'=1;

if ("`hweight1'"!="")   qui replace `sw1'=`hweight1';

gen `fw1'=`hs1'*`sw1';


tempvar smw1 smwy1 l1smwy1 ca1;
gen `smw1'  =sum(`fw1');
gen `smwy1' =sum(`cg1'*`fw1');
gen `l1smwy1'=0;
local mu1=`smwy1'[_N]/`smw1'[_N];
local suma1=`smw1'[_N];
qui count;
forvalues i=2/`r(N)' { ;
qui replace `l1smwy1'=`smwy1'[`i'-1]  in `i';
};
qui gen `ca1'=`mu1'+`cg1'*((1.0/`smw1'[_N])*(2.0*`smw1'-`fw1')-1.0) - (1.0/`smw1'[_N])*(2.0*`l1smwy1'+`fw1'*`cg1'); 
qui sum `ca1' [aw=`fw1'], meanonly; 
local gini1=`r(mean)'/(2.0);
local xi1   = `r(mean)';
tempvar vec_a1 vec_b1  theta1 v11 v21 sv11 sv21;
qui count;

         
            local fx1=0;
            gen `v11'=`fw1'*`cg1';
            gen `v21'=`fw1';
            gen `sv11'=sum(`v11');
            gen `sv21'=sum(`v21') ;
            qui replace `v11'=`sv11'[`r(N)']   in 1;
		    qui replace `v21'=`sv21'[`r(N)']   in 1;

            forvalues i=2/`r(N)'  {;
            qui replace `v11'=`sv11'[`r(N)']-`sv11'[`i'-1]   in `i';
		    qui replace `v21'=`sv21'[`r(N)']-`sv21'[`i'-1]   in `i';
            } ;
           
            gen `theta1'=`v11'-`v21'*`cg1';

           forvalues i=1/`r(N)' {;
                qui replace `theta1'=`theta1'[`i']*(2.0/`suma1')  in `i';
                local fx1=`fx1'+`fw1'[`i']*`cg1'[`i'];
            };            
            local fx1=`fx1'/`suma1';
            gen `vec_a1' = `hs1'*((1.0)*`ca1'-`fx1'+`theta1'-(1.0)*(`xi1')-`cg1');
            gen `vec_b1' =  2*`hs1';
            
            qui svy: ratio `vec_a1'/`vec_b1'; 

cap drop matrix _aa;
matrix _aa=e(b);
local est1 = -1*el(_aa,1,1);

cap drop matrix _vv;
matrix _vv=e(V);
local std1 = el(_vv,1,1)^0.5;

sort `2', stable;
tempvar cg2;
gen double     `cg2' = 0;
qui replace    `cg2' = (1 - `2'/`pl2') if `pl2'>`2';

tempvar  sw2 fw2 ;
gen `sw2'=1;

if ("`hweight2'"!="")   qui replace `sw2'=`hweight2';

gen `fw2'=`hs2'*`sw2';
tempvar smw2 smwy2 l1smwy2 ca2;
gen `smw2'  =sum(`fw2');
gen `smwy2' =sum(`cg2'*`fw2');
gen `l1smwy2'=0;
local mu2=`smwy2'[_N]/`smw2'[_N];
local suma2=`smw2'[_N];
qui count;
forvalues i=2/`r(N)' { ;
qui replace `l1smwy2'=`smwy2'[`i'-1]  in `i';
};
qui gen `ca2'=`mu2'+`cg2'*((1.0/`smw2'[_N])*(2.0*`smw2'-`fw2')-1.0) - (1.0/`smw2'[_N])*(2.0*`l1smwy2'+`fw2'*`cg2'); 
qui sum `ca2' [aw=`fw2'], meanonly; 
local gini2=`r(mean)'/(2.0);
local xi2   = `r(mean)';
tempvar vec_a2 vec_b2  vec_ob2 theta2 v12 v22 sv12 sv22;
qui count;

         
            local fx2=0;
            gen `v12'=`fw2'*`cg2';
            gen `v22'=`fw2';
            gen `sv12'=sum(`v12');
            gen `sv22'=sum(`v22') ;
            qui replace `v12'=`sv12'[`r(N)']   in 1;
		    qui replace `v22'=`sv22'[`r(N)']   in 1;

            forvalues i=2/`r(N)'  {;
            qui replace `v12'=`sv12'[`r(N)']-`sv12'[`i'-1]   in `i';
		    qui replace `v22'=`sv22'[`r(N)']-`sv22'[`i'-1]   in `i';
            } ;
           
            gen `theta2'=`v12'-`v22'*`cg2';

           forvalues i=1/`r(N)' {;
                qui replace `theta2'=`theta2'[`i']*(2.0/`suma2')  in `i';
                local fx2=`fx2'+`fw2'[`i']*`cg2'[`i'];
            };            
            local fx2=`fx2'/`suma2';
            gen `vec_a2' = `hs2'*((1.0)*`ca2'-`fx2'+`theta2'-(1.0)*(`xi2')-`cg2');
            gen `vec_b2' =  2*`hs2';

            qui svy: ratio `vec_a2'/`vec_b2'; 

cap drop matrix _aa;
matrix _aa=e(b);
local est2 = -1*el(_aa,1,1);

cap drop matrix _vv;
matrix _vv=e(V);
local std2 = el(_vv,1,1)^0.5;





local est3=`est2'-`est1';


local equa2="";

local equa1 = "(_b[`vec_a1']/_b[`vec_b1'])";
local smean1 = " `vec_a1' `vec_b1' ";

local equa2 = "(_b[`vec_a2']/_b[`vec_b2'])";
local smean2 = " `vec_a2' `vec_b2' ";


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






capture program drop disst;
program define disst, eclass;
version 9.2;
syntax  namelist(min=2 max=2) [, FILE1(string) FILE2(string) HSize1(string) HSize2(string)
ALpha(real 0)  COND1(string) COND2(string) 
PLINE1(real 10000) 
PLINE2(real 10000) 
LEVEL(real 95) CONF(string) DEC(int 6) BOOT(string) NREP(string) TEST(string)];

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
tempvar hw1 hw2;
gen `hw1'=1;
gen `hw2'=1;
if ("`hweight'"!="") qui replace `hw1'=`hw1'*`hweight';
if ("`hweight'"!="") qui replace `hw2'=`hw2'*`hweight';

disst2d `1' `2' ,  
hweight1(`hw1') hweight2(`hw2') 
hs1(`ths1') hs2(`ths2') 
pl1(`pline1') pl2(`pline2')  
level(`level') conf(`conf');

matrix _res_d1  =(`r(est1)',`r(std1)',`r(lb1)',`r(ub1)' ,`r(pl1)');
matrix _res_d2  =(`r(est2)',`r(std2)',`r(lb2)',`r(ub2)' ,`r(pl2)');
matrix _res_di  =(`r(est3)',`r(std3)',`r(lb3)',`r(ub3)');

local name1 "ISST_D1";
local name2 "ISST_D2";   
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

tempvar hw1;
gen `hw1'=1;
if ("`hweight1'"!="") qui replace `hw1'=`hw1'*`hweight1';

disst2 `1' , hweight(`hw1') hsize(`ths1') pl(`pline1')  conf(`conf') level(`level') ;
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

tempvar hw2;
gen `hw2'=1;

if ("`hweight2'"!="") qui replace `hw2'=`hw2'*`hweight2';


disst2 `2' , hweight(`hw2') hsize(`ths2') pl(`pline2')  conf(`conf') level(`level') ;
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
local name1 "ISST_D1";
local name2 "ISST_D2";         
_dasp_dif_table_ifgt `2' `2', 
name1("`name1'")          name2("`nane2'")
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



