/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : cfgts2d                                                     */
/*************************************************************************/

#delim ;
set more off;
capture program drop cifgt2d;
program define cifgt2d, rclass;
version 9.2;
syntax namelist [,  HSize1(string) HSize2(string) AL(real 0) MIN(string) 
MAX(string) TYpe(string) LEVEL(real 95) CONF(string)];
preserve;
tokenize `namelist';
tempvar num1 num2 xx yy st lb ub;
gen `xx'=0; 
gen `yy'=0; 
gen `st'=0; 
gen `lb'=0; 
gen `ub'=0; 
qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');
local step=(`max'-`min')/100;
dis "ESTIMATION IN PROGRESS";
forvalues i=1/101{;
local pl=`min'+ (`i'-1)*`step';
cap drop `num1' `num2';
qui gen  `num1'=0;
qui gen  `num2'=0;
if (`al' == 0) qui replace                      `num1' = `hsize1'*(`pl'> `1');
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `num1' = `hsize1'*(`pl'-`1')^`al'  if (`pl'>`1');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace `num1' = `hsize1'*((`pl'-`1')/`pl')^`al'  if (`pl'>`1');
if (`al' == 0) qui replace                      `num2' = `hsize2'*(`pl'> `2');
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `num2' = `hsize2'*(`pl'-`2')^`al'  if (`pl'>`2');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace `num2' = `hsize2'*((`pl'-`2')/`pl')^`al'  if (`pl'>`2');

qui svy: ratio (eq1: `num1'/`hsize1') (eq2:  `num2'/`hsize2'); 
qui nlcom (_b[eq2])-(_b[eq1]);

cap matrix drop _aa;
matrix _aa=r(b);
local est = el(_aa,1,1);
matrix _vv=r(V);
local std = el(_vv,1,1)^0.5;
qui replace  `xx' = `pl'  in `i';
qui replace  `yy' = `est' in `i';
qui replace  `st' = `std' in `i';
qui replace  `lb' = `est' - `tt'*`std' in `i';
qui replace  `ub' = `est' + `tt'*`std' in `i';
if (`i'!=101)  dis "." , _continue;
if (`i'/10==round(`i'/10)) dis " "  %4.2f `i' " %";
};
qui keep in 1/101;

mkmat `xx' `yy' `st' `lb' `ub', matrix(_res);
end;



capture program drop cifgt2;
program define cifgt2, rclass;
version 9.2;
syntax varlist [,  HSize(string)  AL(real 0) MIN(string) 
MAX(string) TYpe(string)];
tokenize `varlist';


tempvar num hs xx yy va;
gen `xx'=0; 
gen `yy'=0; 
gen `va'=0; 
local step=(`max'-`min')/100;
qui gen `hs'=`hsize';
forvalues i=1/101{;
local pl=`min'+ (`i'-1)*`step';
cap drop `num';
qui gen  `num'=0;
if (`al' == 0) qui replace                      `num' = `hs'*(`pl'> `1');
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `num' = `hs'*(`pl'-`1')^`al'  if (`pl'>`1');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace `num' = `hs'*((`pl'-`1')/`pl')^`al'  if (`pl'>`1');
qui svy: ratio `num'/`hs';
cap matrix drop _aa;
matrix _aa=e(b);
local est = el(_aa,1,1);
cap matrix drop _vv;
matrix _vv=e(V);
local var = el(_vv,1,1);
qui replace  `xx'  = `pl'   in `i';
qui replace  `yy'  = `est'  in `i';
qui replace  `va'  = `var'  in `i';

cap  matrix drop _vv _aa;
if (`i'!=101)  dis "." , _continue;
if (`i'/10==round(`i'/10)) dis " "  %4.2f $counter+`i'/2 " %";
};
qui keep in 1/101;
mkmat `xx' `yy' `va', matrix(_res);
end;

capture program drop cfgts2d;
program define cfgts2d, rclass;
version 9.2;
syntax  namelist(min=2 max=2) [, 
FILE1(string) FILE2(string) 
HSize1(string) HSize2(string) ALpha(real 0) 
 COND1(string) COND2(string) 
type(string) LEVEL(real 95)  CONF(string) LRES(int 0) SRES(string) 
 MIN(string) MAX(string) DGRA(int 1) DHOL(int 1) SGRA(string) EGRA(string) *];


if ("`type'"=="")  local type="nor";
if ("`conf'"=="")  local conf="ts";
  _get_gropts , graphopts(`options') getallowed(conf_area_opts conf_line_opts dif_line_opts hor_line_opts);
        local options `"`s(graphopts)'"';
        local conf_area_opts `"`s(conf_area_opts)'"';
        local conf_line_opts `"`s(conf_line_opts)'"';
        local dif_line_opts `"`s(dif_line_opts)'"';
        local hor_line_opts `"`s(hor_line_opts)'"';
qui count;
if (`r(N)'<101) set obs 101;
	
global indica=3;
tokenize `namelist';



preserve;
if ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;
if (`"`file1'"'~="") use `"`file1'"', replace;


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


cap svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

cifgt2d `1' `2' ,  hsize1(_ths1) hsize2(_ths2) min(`min') max(`max')
al(`alpha') type(`type')  level(`level') conf(`conf');

svmat float _res;
cap matrix drop _res;
rename _res1 _pline;
rename _res2 _dif;
rename _res3 _std;
rename _res4 _lb;
rename _res5 _ub;
};


// second stage

if !( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;

if ("`file1'" !="") use `"`file1'"', replace;
tempvar cd1;
cap drop _ths1;
qui gen _ths1=1;

if ( "`hsize1'"!="") qui replace _ths1=`hsize1';
dis "ESTIMATION IN PROGRESS";
global counter=0;
if ( "`cond1'"!="") {;
gen `cd1'=`cond1';
qui replace _ths1=_ths1*`cd1';
qui sum `cd1';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_1, the number of observations is 0.";
exit;
};
};

cap svy: total;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

cifgt2 `1' ,  hsize(_ths1 ) min(`min') max(`max') al(`alpha') type(`type');

matrix _res_a=_res;
matrix drop _res;


if ("`file2'" !="") use `"`file2'"', replace;
global counter=50;
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
cap svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
cifgt2 `2' ,  hsize(_ths2 )  min(`min') max(`max') al(`alpha') type(`type');
matrix _res_b=_res;
matrix drop _res;

svmat float _res_a;
matrix drop _res_a;
svmat float _res_b;
matrix drop _res_b;
rename _res_a1 _pline;
gen _dif = _res_b2-_res_a2;
gen _std = (_res_a3+_res_b3)^0.5;

local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invnorm(`lvl');
gen _lb=_dif+`tt'*_std;
gen _ub=_dif-`tt'*_std;
};

dis "END: WAIT FOR THE GRAPH...";

local m5 = (`max'-`min')/5;
gen _nl=0;
qui keep in 1/101;

                   local mylist = "_pline _dif _std _lb _ub";
if("`conf'"=="lb") local mylist = "_pline _dif _std _lb";
if("`conf'"=="ub") local mylist = "_pline _dif _std _ub"; 

if( `lres' == 1) {;
set more off;
list `mylist';
};

local drhline = "";
if (`dhol'==1) local drhline ="(line   _nl _pline,  sort clcolor(gs9) lpattern(solid) `hor_line_opts' 
)";
quietly {;
if (`dgra'!=0) {;


if("`conf'"=="ts") {;
twoway 
(rarea _lb _ub _pline, sort blcolor(ltbluishgray) 
blwidth(none)
blcolor(gs14) 
bfcolor(gs14) 
legend(order(1 "Confidence Interval"))
`conf_area_opts'
) 
(line _dif _pline, sort 
lcolor(black) 
lpattern(solid) 
legend(order(1 "Confidence interval (`level' %)" 2 "Estimated difference"))
title("Difference between FGT curves")
subtitle("(alpha = `alpha')")
xtitle("Poverty line (z)") 
plotregion(margin(zero))
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
`dif_line_opts'
`options'
)
`drhline'
; 
};

if("`conf'"=="lb") {;

twoway 
(
line  _dif _pline,
title("Difference between FGT curves")
subtitle("(alpha = `alpha')")
xtitle("Poverty line (z)") 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max')
plotregion(margin(zero))
lcolor(black) 
lpattern(solid)
legend(
label(1 "Difference")
label(2 "Lower bound of `level'% confidence interval")
label(3 "Null horizontal line")
)
`options'
`dif_line_opts'
)
( line  _lb _pline, 
lcolor(black) 
lpattern(dash)
`conf_line_opts')
`drhline'
;
};

if("`conf'"=="ub") {;

twoway
(
line  _dif _pline,
lcolor(black) 
lpattern(solid)
title("Difference between FGT curves")
subtitle("(alpha = `alpha')")
xtitle("Poverty line (z)") 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max')
plotregion(margin(zero))
legend(
label(1 "Difference")
label(2 "Upper bound of `level'% confidence interval")
label(3 "Null horizontal line")
)
`options'
`dif_line_opts'
)
(line  _ub _pline, 
`conf_line_opts'
lcolor(black) 
lpattern(dash)
)

`drhline'
;
};






};
cap matrix drop _xx;
if( "`sres'" ~= "") {;
keep  `mylist';
save `"`sres'"', replace;
};

if( "`sgra'" ~= "") {;
graph save `"`sgra'"', replace;
};

if( "`egra'" ~= "") {;
graph export `"`egra'"', replace;
};

};



restore;

end;



