/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.0)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universit Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/


#delim ;
set more off;
capture program drop cicd2d;
program define cicd2d, rclass;
version 9.2;
syntax namelist [,  FW1(string) FW2(string) HSize1(string) HSize2(string) INC(string) ORDER(real 1) MIN(string) 
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
local al=`order'-1;

if (`order'==1) {;
tempvar   _kt5 _vy _vx _vx2;

qui su `inc' [aw=`fw1'], detail;            
local tmp = (`r(p75)'-`r(p25)')/1.34;                           
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)';     
local h1   = 0.9*`tmp'*_N^(-1.0/5.0); 


qui su `inc' [aw=`fw2'], detail;            
local tmp = (`r(p75)'-`r(p25)')/1.34;                           
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)';     
local h2   = 0.9*`tmp'*_N^(-1.0/5.0); 
};

dis "ESTIMATION IN PROGRESS";
forvalues i=1/101{;
local pl=`min'+ (`i'-1)*`step';


if (`order'>1) {;
cap drop `num1' `num2';
qui gen  `num1'=0;
qui gen  `num2'=0;

qui replace `num1' = `hsize1'*((`pl'-`inc')/`pl')^`al'*`1'  if (`pl'>`inc');
qui replace `num2' = `hsize2'*((`pl'-`inc')/`pl')^`al'*`2'  if (`pl'>`inc');


qui svy: ratio (eq1: `num1'/`hsize1') (eq2:  `num2'/`hsize2'); 
qui nlcom (_b[eq1])-(_b[eq2]);

cap matrix drop _aa;
matrix _aa=r(b);
local est = el(_aa,1,1);
matrix _vv=r(V);
local std = el(_vv,1,1)^0.5;

};

if (`order'==1) {;


cap drop `_kt5' `_vx' `_vx2';
qui gen `_kt5' = (exp(-0.5* ( ((`pl'-`inc')/`h1')^2  )  )   )^0.5;
qui gen `_vx' =`_kt5'*(`inc'-`pl');
qui gen `_vx2'=0.5*`_kt5'*(`inc'-`pl')^2;

/*
cap drop  `_vy' ;
qui gen `_vy' =`_kt5'*`1';
qui regress `_vy'   `_vx' `_kt5' `_vx2'  [aw = `fw1'];
cap matrix drop _cc;
matrix _cc = e(b);
local est1  = el(_cc,1,2);


cap drop  `_vy' ;
qui gen `_vy' =`_kt5'*`2';
qui regress `_vy'   `_vx' `_kt5' `_vx2'  [aw = `fw2'];
cap matrix drop _cc;
matrix _cc = e(b);
local est2  = el(_cc,1,2);

local est = `est1'-`est2';

*/
/* in test */
cap drop _dif;
gen _dif = `1'-`2';
cap drop  `_vy' ;
qui gen `_vy' =`_kt5'*_dif;
qui regress `_vy'   `_vx' `_kt5' `_vx2'  [aw = `fw1'];
cap matrix drop _cc;
matrix _cc = e(b);
local est  = el(_cc,1,2);

cap matrix drop _cc;
matrix _cc = e(V);
local std  = el(_cc,2,2)^0.5;


/******/





};

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




capture program drop ccd2d;
program define ccd2d, rclass;
version 9.2;
syntax  namelist(min=2 max=2) [, 
INC(string) HSize1(string) HSize2(string)  
ORDER(real 1)
COND1(string) COND2(string) 
type(string) LEVEL(real 95)  
CONF(string) LRES(int 0) SRES(string) 
 MIN(string) MAX(string) DGRA(int 1) 
DHOL(int 1) SGRA(string) EGRA(string) OPTIONS(string) *];


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

tempvar cd1;
cap drop _ths1;
qui gen _ths1=1;
if ( "`hsize1'"!="") qui replace _ths1=`hsize1';
if ( "`cond1'"!="") {;
gen `cd1'=`cond1';
qui replace _ths1=_ths1*`cd1';
qui sum `cd1';
if (`r(sum)'==0) {;
dis as error " With the condition(s) of distribution_1, the number of observations is 0.";
exit;
};
};

tempvar cd2;
cap drop _ths2;
qui gen _ths2=1;
if ( "`hsize1'"!="") qui replace _ths2=`hsize1';
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace _ths2=_ths2*`cd2';
qui sum `cd2i';
if (`r(sum)'==0) {;
dis as error " With the condition(s) of distribution_2, the number of observations is 0.";
exit;
};
};




cap svy: total `1';
local weight=`"`e(wvar)'"';
dis `weight';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
cap ereturn clear;


qui gen _fw1=_ths1*`weight';
qui gen _fw2=_ths2*`weight';

cicd2d `1' `2' ,  fw1(_fw1) fw2(_fw2) hsize1(_ths1) hsize2(_ths2) inc(`inc') min(`min') max(`max')
order(`order') type(`type')  level(`level') conf(`conf');

svmat float _res;
cap matrix drop _res;
rename _res1 _pline;
rename _res2 _dif;
rename _res3 _std;
rename _res4 _lb;
rename _res5 _ub;



// second stage

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
legend(order(1 "Confidence interval (`level' %)" 2 "Estimated difference:"`1' - `2'""))
title("Difference between MCD curves")
subtitle("(order = `order')")
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
title("Difference between MCD curves")
subtitle("(order = `order')")
xtitle("Poverty line (z)") 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max')
plotregion(margin(zero))
lcolor(black) 
lpattern(solid)
legend(
label(1 "Difference:"`1' - `2'")
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
title("Difference between MCD curves")
subtitle("(order = `order')")
xtitle("Poverty line (z)") 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max')
plotregion(margin(zero))
legend(
label(1 "Difference:"`1' - `2'")
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



