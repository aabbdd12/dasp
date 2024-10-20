/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.2)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : clorenzs                                                    */
/*************************************************************************/

#delim ;


capture program drop quantile2l;
program define quantile2l, rclass sortpreserve;
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



capture program drop npe2l;
program define npe2l, rclass sortpreserve;
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

capture program drop lorenz2l;
program define lorenz2l, rclass sortpreserve;
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


capture program drop clorenzs2;
program define clorenzs2, rclass sortpreserve;
version 9.2;
args fw hs yyy type min max conf level rank;
preserve;
cap drop if `yyy'>=.;
cap drop if `hs' >=.;
tempvar ra ga est std lb ub;

qui gen `est'=0; qui gen `std'=0; qui gen `lb'=0; qui gen `ub'=0;

qui gen `ra'=0;
local pas = (`max'-`min')/100;
if (_N<101) qui set obs 101;
qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');

if ("`rank'"=="") quantile2l `fw' `yyy'   `min' `max' ;
if ("`rank'"~="") quantile2l `fw' `rank'  `min' `max' ;
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _qp1;

if ("`rank'"=="")    local rank="no";
lorenz2l  `fw' `yyy' `rank' `type' `min' `max';
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _lp;
qui replace `est'=_lp;

if ("`rank'"~="no") {;
npe2l `fw'  `rank'  `yyy';
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _enp1;
};

cap drop _denum;
if ("`type'"=="nor") qui gen  _denum = `hs'*`yyy';
if ("`type'"=="gen") qui gen  _denum = `hs';

forvalues j=1/101 {;
qui replace `ra'=`min'+(`j'-1)*`pas' in `j';
cap drop _num;
qui gen _num=0;
if ("`rank'"=="no") qui replace _num = `hs'*(`ra'[`j']*_qp1[`j']+(`yyy'-_qp1[`j'])*(`yyy'<_qp1[`j']));
if ("`rank'"~="no") qui replace _num = `hs'*(`ra'[`j']*_enp1[`j']+(`yyy'-_enp1[`j'])*(`rank'<_qp1[`j']));

qui svy: ratio _num/_denum; 
matrix _vv=e(V);
local stdev = el(_vv,1,1)^0.5;

qui replace  `std'  = `stdev'             in `j';
qui replace  `lb'   = `est' - `tt'*`std'  in `j';
qui replace  `ub'   = `est' + `tt'*`std'  in `j';

if (`j'!=101)  dis "." ,  _continue;
if (`j'/10==round(`j'/10)) dis " "  %4.2f `j' " %";


};
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat `ra' `est' `std' `lb' `ub', matrix (_xx);
restore;
end;

capture program drop clorenzs;
program define clorenzs, rclass;
version 9.2;
syntax varlist(min=1)[,  RANK(varname) HSize(varname) HGroup(varname)  NGroup(int 1)  
type(string)  LRES(int 0) SRES(string) MIN(real 0) MAX(real 1) DGRA(int 1) 
SGRA(string) EGRA(string) CONF(string)
LEVEL(real 95) *];


if ("`type'"=="")  local type="nor";
if ("`conf'"=="")  local conf="ts";

  _get_gropts , graphopts(`options') getallowed(conf_area_opts conf_line_opts dif_line_opts);
        local options `"`s(graphopts)'"';
        local conf_area_opts `"`s(conf_area_opts)'"';
        local conf_line_opts `"`s(conf_line_opts)'"';
        local dif_line_opts `"`s(dif_line_opts)'"';



dis "OPTIONS  `options'";

if (`min' < 0) {;
 di as err "min should be >=0"; exit;
};
if (`max' > 1) {;
 di as err "max should be <=1"; exit;
};

if (`max' <= `min') {;
 di as err "max should be greater than min"; exit;
};


tokenize `varlist';
_nargs   `varlist';
preserve;
qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

tempvar hs;
gen `hs'=1;
if ("`hsize'"    ~="")      qui replace `hs'=`hsize';
if ("`hgroup'"   ~="")      qui replace `hs'=`hs'*(`hgroup'==`ngroup');

if ("`min'"  =="")          local min =0;
if ("`max'"  =="")          local max =1;
if ("`type'"  =="")         local type ="yes";
qui count;
if (r(N)<101) qui set obs 101;

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

tempvar fw;
gen `fw'=`hs';
if (`"`hweight'"'~="") qui replace `fw'=`fw'*`hweight';
dis "ESTIMATION IN PROGRESS";
clorenzs2 `fw' `hs' `1' `type' `min' `max' `conf' `level' `rank';
dis "END: WAIT FOR THE GRAPH...";
svmat float _xx;
cap matrix drop _xx;

rename _xx1 _perc;
rename _xx2 _est;
rename _xx3 _std;
rename _xx4 _lb;
rename _xx5 _ub;


qui keep in 1/101;
gen _nl=0;
local pas = (`max'-`min')/100;
local m5 = (`max'-`min')/5;



                   local mylist = "_perc _est _std _lb _ub";
if("`conf'"=="lb") local mylist = "_perc _est _std _lb";
if("`conf'"=="ub") local mylist = "_perc _est _std _ub"; 

if( `lres' == 1) {;
set more off;
list `mylist';
};

                     local titcur = "Lorenz";
if ("`rank'"~="")    local titcur = "Concentration";
if ("`type'"=="gen") local titcur = "Generalised `titcur'";

if (`dgra'!=0) {;

if("`conf'"=="ts") {;
twoway 
(rarea _lb _ub _perc, 
sort 
blcolor(gs14) 
bfcolor(gs14)  
legend(order(1 "Confidence Interval"))
`conf_area_opts'

) 
(line _est _perc,
sort
lcolor(black) 
lpattern(solid) 
legend(order(1 "Confidence interval (`level' %)" 2 "Estimate"))
title("`titcur' Curve ")
xtitle("Percentiles") 
plotregion(margin(zero))
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
`dif_line_opts'
`options'
)
; 
};

if("`conf'"=="lb") {;
twoway 
(
line  _est _perc, 
legend(
label(1 "Estimate")
label(2 "Lower bound of `level'% confidence interval")
)
lcolor(black) 
lpattern(solid) 
title("`titcur' curve ")
xtitle("Percentiles") 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max')
plotregion(margin(zero))
`dif_line_opts'
`options'
)
(
line  _lb _perc, 
lcolor(black) 
lpattern(dash)
`conf_line_opts'
)
;
};


if("`conf'"=="ub") {;
twoway 
(
line  _est _perc, 
legend(
label(1 "Estimate")
label(2 "Upper bound of `level'% confidence interval")
)
lcolor(black) 
lpattern(solid)
title("`titcur' curve ")
xtitle("Percentiles") 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max')
plotregion(margin(zero))
graphregion(margin(medlarge))
legend(size(medsmall))
`dif_line_opts'
`options'
)
(
line  _ub _perc, 
lcolor(black) 
lpattern(dash)
`conf_line_opts'
)
;
};
};

if( "`sres'" ~= "") {;
keep `mylist';
save `"`sres'"', replace;
};

if( "`sgra'" ~= "") {;
graph save `"`sgra'"', replace;
};

if( "`egra'" ~= "") {;
graph export `"`egra'"', replace;
};





end;





