/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : clorenzs2d                                                  */
/*************************************************************************/

#delim ;
set more off;
capture program drop cilorenz2d;
program define cilorenz2d, rclass;
version 9.2;
syntax namelist [,  HS1(string) HS2(string) RANK1(string) RANK2(string) MIN(real 0) 
MAX(real 1) TYpe(string) LEVEL(real 95) CONF(string)];
preserve;
tokenize `namelist';
tempvar num1 num2 denum1 denum2 xx dif st lb ub;
gen `xx'=0; 
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



cap drop if `1'  >=.;
cap drop if `2'  >=.;
cap drop if `hs1' >=.;
cap drop if `hs2' >=.;
tempvar ra;
qui gen `ra'=0;
local pas = (`max'-`min')/100;
if (_N<101) qui set obs 101;
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
tempvar fw1 fw2;
gen `fw1'=`hs1';
gen `fw2'=`hs2';

if (`"`hweight'"'~="") {;
qui replace `fw1'=`fw1'*`hweight';
qui replace `fw2'=`fw2'*`hweight';
};

if ("`rank1'"=="") quantile2l2d `fw1'  `1'     `min' `max' ;
if ("`rank1'"~="") quantile2l2d `fw1' `rank1'  `min' `max' ;
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _qp1;

if ("`rank2'"=="") quantile2l2d `fw2'  `2'      `min' `max' ;
if ("`rank2'"~="") quantile2l2d `fw2'  `rank2'  `min' `max' ;
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _qp2;


if ("`rank1'"=="")     local rank1="no";
lorenz2l2d  `fw1' `1' `rank1' `type' `min' `max';
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _lp1;


if ("`rank1'"~="no") {;
npe2l2d `fw1'  `rank1'  `1';
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _enp1;
};

if ("`rank2'"=="")     local rank2="no";
lorenz2l2d  `fw2' `2' `rank2' `type' `min' `max';
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _lp2;
qui gen `dif'=_lp2-_lp1;

if ("`rank2'"~="no") {;
npe2l2d `fw2'  `rank2'  `2';
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _enp2;
};


if ("`type'"=="nor") qui gen  `denum1' = `hs1'*`1';
if ("`type'"=="gen") qui gen  `denum1' = `hs1';


if ("`type'"=="nor") qui gen  `denum2' = `hs2'*`2';
if ("`type'"=="gen") qui gen  `denum2' = `hs2';
local nest=101;
if (`max'<1) local nest=101;
forvalues j=1/`nest' {;
qui replace `ra'=`min'+(`j'-1)*`pas' in `j';
cap drop `num1' `num2'; 
qui gen `num1' =0;
qui gen `num2' =0;

if ("`rank1'"=="no") qui replace `num1' = `hs1'*(`ra'[`j']*_qp1[`j']+(`1'-_qp1[`j'])*(`1'<_qp1[`j']));
if ("`rank1'"~="no") qui replace `num1' = `hs1'*(`ra'[`j']*_enp1[`j']+(`1'-_enp1[`j'])*(`rank1'<_qp1[`j']));

if ("`rank2'"=="no") qui replace `num2' = `hs2'*(`ra'[`j']*_qp2[`j']+(`2'-_qp2[`j'])*(`2'<_qp2[`j']));
if ("`rank2'"~="no") qui replace `num2' = `hs2'*(`ra'[`j']*_enp2[`j']+(`2'-_enp2[`j'])*(`rank2'<_qp2[`j']));




qui svy: ratio (eq1: `num1'/`denum1') (eq2:  `num2'/`denum2'); 
qui nlcom (_b[eq2])-(_b[eq1]);
matrix _vv=r(V);



local std  = el(_vv,1,1)^0.5;
qui replace  `xx' = `ra'[`j']  in `j';

qui replace  `st' = `std' in `j';
qui replace  `lb' = `dif'[`j'] - `tt'*`std' in `j';
qui replace  `ub' = `dif'[`j'] + `tt'*`std' in `j';


if (`j'!=101)  dis "." , _continue;
if (`j'/10==round(`j'/10)) dis " "  %4.2f `j' " %";
};
qui keep in 1/101;


if (`max'==1  ) qui replace  `xx'  = 1 in 101;

if (`max'==1 & "`type'"=="nor" )  {;
qui replace  `dif' = 0 in 101;
qui replace  `st'  = 0 in 101;
qui replace  `lb'  = 0 in 101;
qui replace  `ub'  = 0 in 101;
};

cap drop matrix _res;
mkmat `xx' `dif' `st' `lb' `ub', matrix(_res);
end;



capture program drop quantile2l2d;
program define quantile2l2d, rclass sortpreserve;
version 9.2;
args www yyy min max gr ng;
preserve;
if ("`gr'" ~="") qui keep if (`gr'==gn1[`ng']);
sort `yyy';
cap drop if `yyy'>=.;
cap drop if `www'>=.;
if (_N<101) qui set obs 101;
tempvar  _finqp _ww _qup _pc;
qui gen `_ww'=sum(`www');
qui gen `_pc'=`_ww'/`_ww'[_N];
qui gen `_qup' = `yyy' ;
qui sum `yyy' [aw=`www'];
qui sum  [aw=`www'];
local mina=`r(min)';
local maxa=`r(max)';
local ff=`mina';
if(`min'==0 & `mina'>0) local ff=0;
qui gen  `_finqp'=0;
local step=(`max'-`min')/100;
local i = 1;
forvalues j=0/100 {;
local pcf=`min'+`j' *`step';
local av=`j'+1;
while (`pcf' > `_pc'[`i']) {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) local lqi=`_qup'[`ar']+((`_qup'[`i']-`_qup'[`ar'])/(`_pc'[`i']-`_pc'[`ar']))*(`pcf'-`_pc'[`ar']);
if (`i'==1) local lqi=`ff'+(max(0,`_qup'[`i'])/(`_pc'[`i']))*(`pcf');
qui replace `_finqp'=`lqi' in `av';
};

if(`min'==0 & `mina'>0) qui replace `_finqp' = 0 in 1;
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat `_finqp', matrix (_xx);
restore;
end;



capture program drop npe2l2d;
program define npe2l2d, rclass sortpreserve;
version 9.2;
args www xxx yyy;
preserve;

cap drop if `yyy'>=.;
cap drop if `www'>=.;
cap drop if `xxx'>=.;


qui su `xxx' [aw=`www'], detail;            
local tmp = (`r(p75)'-`r(p25)')/1.34;                           
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)';     
local band   = 0.9*`tmp'*_N^(-1.0/5.0); 
tempvar _npe;
qui gen `_npe'=0;
if (_N<101) qui set obs 101;                   
gen _s2 = sum( `www' ); 
forvalues j=1/101 {;
cap drop `_t1'' `_t2'; 
tempvar _t1 _t2;
qui gen `_t1'=`www'*exp(-0.5* ( ((_qp1[`j']-`xxx')/`band')^2  )  )*`yyy';
qui replace `_t1'=0  in `j';
qui gen `_t2'=`www'*exp(-0.5* ( ((_qp1[`j']-`xxx')/`band')^2  )  );
qui replace `_t2'=0  in `j';
qui sum  `_t1',  meanonly ;
local su1 =  `r(sum)';
qui  sum `_t2',  meanonly ;
local su2 =  `r(sum)';
local temp = `su1'/`su2';
qui replace `_npe' = `temp' in `j';
};
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat `_npe', matrix (_xx);
restore;
end;

capture program drop lorenz2l2d;
program define lorenz2l2d, rclass sortpreserve;
;
version 9.2;
args www yyy rank type min max gr ng;
quietly {;
preserve;
if ("`gr'" ~="") qui keep if (`gr'==gn1[`ng']);
sort `yyy';
if ("`rank'" ~= "" & "`rank'" ~= "no") sort `rank';
cap drop if `yyy'>=.;
cap drop if `www'>=.;
if (_N<101) qui set obs 101;
cap drop _ww;
cap drop _wy;
cap drop _lp;
qui gen _ww = sum(`www');
qui gen _wy = sum(`www'*`yyy');
local suma = _wy[_N];
cap drop _pc;
qui sum _ww;
qui gen _pc=_ww/r(max);
if ("`type'"~="gen" )  qui sum `yyy' [aw=`www'];
if ("`type'"=="gen" )  qui sum `www';
local suma = `suma'/`r(sum)';
qui gen _lp=_wy/r(sum);
cap drop _finlp;
qui gen _finlp=0;
local i = 1;
local step=(`max'-`min')/100;
local i = 1;
forvalues j=0/100 {;
local pcf=`min'+`j' *`step';
local av=`j'+1;
while (`pcf' > _pc[`i']) {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) local lpi=_lp[`ar']+((_lp[`i']-_lp[`ar'])/(_pc[`i']-_pc[`ar']))*(`pcf'-_pc[`ar']);
if (`i'==1) local lpi=0+((_lp[`i'])/(_pc[`i']))*(`pcf');
qui replace _finlp=`lpi' in `av';
};
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat _finlp, matrix (_xx);
restore;
};
end;


capture program drop cilorenz2;
program define cilorenz2, rclass sortpreserve;
version 9.2;
syntax  varlist(min=1 max=1) [, hs(varname) rank(varname) min(real 0) max(real 1) type(string)];
tokenize `varlist';
preserve;
cap drop if `1'  >=.;
cap drop if `hs' >=.;
tempvar ra ga est var;

qui gen `est'=0; 
qui gen `var'=0; 

qui gen `ra'=0;
local pas = (`max'-`min')/100;
if (_N<101) qui set obs 101;

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
tempvar fw;
gen `fw'=`hs';
if (`"`hweight'"'~="") qui replace `fw'=`fw'*`hweight';

if ("`rank'"=="") quantile2l2d `fw'  `1'   `min' `max' ;
if ("`rank'"~="") quantile2l2d `fw' `rank'  `min' `max' ;
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _qp1;

if ("`rank'"=="")     local rank="no";
lorenz2l2d  `fw' `1' `rank' `type' `min' `max';
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _lp;
qui replace `est'=_lp;

if ("`rank'"~="no") {;
npe2l2d `fw'  `rank'  `1';
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _enp1;
};

cap drop _denum;
if ("`type'"=="nor") qui gen  _denum = `hs'*`1';
if ("`type'"=="gen") qui gen  _denum = `hs';

forvalues j=1/101 {;
qui replace `ra'=`min'+(`j'-1)*`pas' in `j';
cap drop _num;
qui gen _num=0;
if ("`rank'"=="no") qui replace _num = `hs'*(`ra'[`j']*_qp1[`j']+(`1'-_qp1[`j'])*(`1'<_qp1[`j']));
if ("`rank'"~="no") qui replace _num = `hs'*(`ra'[`j']*_enp1[`j']+(`1'-_enp1[`j'])*(`rank'<_qp1[`j']));

qui svy: ratio _num/_denum; 
matrix _vv=e(V);
local varev = el(_vv,1,1);

qui replace  `var'  = `varev'             in `j';


if (`j'!=101)  dis "." , _continue;
if (`j'/10==round(`j'/10)) dis " "  %4.2f $counter+`j'/2 " %";



};

qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat `ra' `est' `var', matrix (_res);
restore;
end;

capture program drop clorenzs2d;
program define clorenzs2d, rclass;
version 9.2;
syntax  namelist(min=2 max=2) [, 
FILE1(string) FILE2(string)
RANK1(string) RANK2(string) 
HSize1(string) HSize2(string)  
COND1(string) COND2(string) 
type(string) LEVEL(real 95)  CONF(string) LRES(int 0) SRES(string) 
 MIN(real 0) MAX(real 1) DGRA(int 1) DHOL(int 1) SGRA(string) EGRA(string) *];


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

                                    local tit="Lorenz";
if ("`rank1'"~="" & "`rank2'" ~="") local tit="Concentration";
if ("`rank1'"=="" & "`rank2'" ~="") local tit="Lorenz and concentration";
if ("`rank1'"~="" & "`rank2'" =="") local tit="Concentration and Lorenz";

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
dis as error "With the condition(s) of distribution_1, the number of observations is 0.";
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
dis as error "With the condition(s) of distribution_2, the number of observations is 0.";
exit;
};
};


cap svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

cilorenz2d `1' `2' ,  hs1(_ths1) hs2(_ths2) rank1(`rank1') rank2(`rank2')   min(`min') max(`max') type(`type')  level(`level') conf(`conf');

svmat float _res;
cap matrix drop _res;
rename _res1 _corx;
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
dis as error "With the condition(s) of distribution_1, the number of observations is 0.";
exit;
};
};

cap svy: total;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

cilorenz2 `1' ,  hs(_ths1 ) rank(`rank1') min(`min') max(`max') type(`type');

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
dis as error " With the condition(s) of distribution_2 the number of observations is 0.";
exit;
};
};
cap svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
cilorenz2 `2' ,  hs(_ths2 ) rank(`rank2')  min(`min') max(`max') type(`type');
matrix _res_b=_res;
matrix   drop _res;

svmat float _res_a;
matrix drop _res_a;
svmat float _res_b;
matrix drop _res_b;
rename _res_a1 _corx;
qui gen _dif = _res_b2-_res_a2;
qui gen _std = (_res_a3+_res_b3)^0.5;

local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invnorm(`lvl');
qui gen _lb=_dif+`tt'*_std;
qui gen _ub=_dif-`tt'*_std;
};

dis "END: WAIT FOR THE GRAPH...";

local m5 = (`max'-`min')/5;
gen _nl=0;
qui keep in 1/101;

                   local mylist = "_corx _dif _std _lb _ub";
if("`conf'"=="lb") local mylist = "_corx _dif _std _lb";
if("`conf'"=="ub") local mylist = "_corx _dif _std _ub"; 

if( `lres' == 1) {;
set more off;
list `mylist';
};

local drhline = "";
if (`dhol'==1) local drhline ="(line   _nl _corx,  clcolor(gs9) lpattern(solid) `hor_line_opts')";
quietly {;
if (`dgra'!=0) {;


if("`conf'"=="ts") {;
twoway 
(rarea _lb _ub _corx, sort 
blwidth(none)
blcolor(gs14) 
bfcolor(gs14) 
legend(order(1 "Confidence interval"))
`conf_area_opts'
) 
(line _dif _corx, sort 
lcolor(black) 
lpattern(solid) 
legend(order(1 "Confidence interval (`level' %)" 2 "Estimated difference"))
title("Difference Between `tit' Curves")
xtitle("Percentile")
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
line  _dif _corx,
title("Difference between `tit' Curves")
xtitle("Percentile")
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max')
plotregion(margin(zero))
legend(
label(1 "Difference")
label(2 "Lower bound of `level'% confidence interval")
label(3 "Null horizontal line")
)
lcolor(black) 
lpattern(solid) 
`options'
`dif_line_opts'
)
( line  _lb _corx, 
lcolor(black) 
lpattern(dash) 
`conf_line_opts')
`drhline'
;
};

if("`conf'"=="ub") {;

twoway
(
line  _dif _corx,
title("Difference between `tit' Curves")
xtitle("Percentile")
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max')
plotregion(margin(zero))
legend(
label(1 "Difference")
label(2 "Upper bound of `level'% confidence interval")
label(3 "Null horizontal line")
)
lcolor(black) 
lpattern(solid) 
`options'
`dif_line_opts'
)
(line  _ub _corx, 
lcolor(black) 
lpattern(dash) 
`conf_line_opts')
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



