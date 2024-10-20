/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.1)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : clorenzsm                                                    */
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


capture program drop clorenzsm2;
program define clorenzsm2, rclass sortpreserve;
version 9.2;
syntax varlist(min=1)[,  RANK(varname) FW(string) HS(string) HGroup(varname) NG(int 1)   type(string)  MIN(real 0) MAX(real 1) CONF(string) LEVEL(real 95) ];
preserve;
tokenize `varlist'; 
tempvar yyy; 
gen `yyy'=`1';
if ("`hgroup'" ~="") qui keep if (`hgroup'==`ng');
cap drop if `yyy'>=.;
cap drop if `hs' >=.;
tempvar ra ga est std lb ub;

qui gen `est'=0; qui gen `std'=0; 
qui gen `lb'=0; qui gen `ub'=0;

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

if ("`rank'"=="")     local rank="no";
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

capture program drop clorenzsm;
program define clorenzsm, rclass;
version 9.2;
syntax varlist [,  
RANK(varname) HSize(varname) HGroup(varname)   
type(string)  
LRES(int 0) SRES(string) 
MIN(real 0) MAX(real 1)
CONF(string) LEVEL(real 95)
DGRA(int 1) 
SGRA(string) EGRA(string) *];

set more off;
if ("`type'"=="")  local type="nor";
if ("`conf'"=="")  local conf="ts";

  _get_gropts , graphopts(`options') ;
        local options `"`s(graphopts)'"';

if ("`hgroup'"!="") {;
preserve;
capture {;
local lvgroup:value label `hgroup';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , replace;
qui count;
forvalues i=1/`r(N)' {;
local tem=value[`i'];
local grlab`tem' = label[`i'];
};
};
};
restore;
preserve;
qui tabulate `hgroup', matrow(gn);
svmat int gn;
global indica=r(r);
tokenize `varlist';
};

if ("`hgroup'"=="") {;
tokenize `varlist';
_nargs    `varlist';
preserve;
};


if (`min' < 0) {;
 di as err "min should be >=0"; exit;
};
if (`max' > 1) {;
 di as err "max should be <=1"; exit;
};

if (`max' <= `min') {;
 di as err "max should be greater than min"; exit;
};



qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

tempvar hs;
gen `hs'=1;
if ("`hsize'"    ~="")      qui replace `hs'=`hsize';


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

forvalues k = 1/$indica {;
                                     local _cory  = "`_cory'" + " _cory`k'";
if ("`conf'"=="ts") local mcmd  = "`mcmd'" + "(rarea  _coryl`k'  _coryu`k' _corx) ";

if ("`hgroup'"=="") {;
local label`k'   = "``k''";
dis "Computation for variable -> ``k''"; 
clorenzsm2  ``k'', fw(`fw') hs(`hs')  type(`type') min(`min')  
max(`max') conf(`conf') level(`level') rank(`rank');
};


if ("`hgroup'"!="") {;
local kk = gn1[`k'];
local label`k'   = "Group: `kk'";
local labelv  : label (`hgroup') `kk';
if (length("`labelv'")>2) local label`k'="`labelv'";
dis "Computation for the group -> `label`k''"; 
clorenzsm2  `1', fw(`fw') hs(`hs') hgroup(`hgroup') ng(`kk') type(`type') min(`min') 
max(`max') conf(`conf') level(`level') rank(`rank');
};

svmat float _xx;
if ("`conf'"=="ts") {;
 rename _xx4 _coryl`k';
 rename _xx5 _coryu`k';
};

if ("`conf'"=="lb"){;
rename _xx4 _cory`k';
};

if ("`conf'"=="ub"){;
 rename _xx5 _cory`k';
};

cap drop _xx*;


};

dis "END: WAIT FOR THE GRAPH...";

qui keep in 1/101;
gen _nl=0;
local pas = (`max'-`min')/100;
local m5 = (`max'-`min')/5;
local step=(`max'-`min')/100;
gen _corx = `min'+(_n-1)*`step';



if( `lres' == 1) {;
set more off;
list _corx _cory*;
};

                      local titcur = "Lorenz";
if ("`rank'"~="")     local titcur = "Concentration";
if ("`type'"=="gen")  local titcur = "Generalized `titcur'";
                      local typeb = "Lower";
if ("`conf'"=="ub")   local typeb = "Upper";

if (`dgra'!=0) {;

if ("`conf'"=="ts"){;
twoway `mcmd' , 
legend(
label(1 `label1')
label(2 `label2')
label(3 `label3')
label(4 `label4')
label(5 `label5')
label(6 `label6')
label(7 `label7')
label(8 `label8')
label(9 `label9')
label(10 `label10')
label(11 `label11')
label(12 `label12')
)
title("`titcur' Curve(s)")
xtitle("Percentiles")
subtitle("Confidence interval(`level'%)")
xtitle("Percentile (p)") 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
plotregion(margin(zero))
graphregion(margin(medlarge))
legend(size(medsmall))
`options'
;
};

if ("`conf'"~="ts") {;
line `_cory'  _corx, 
legend(
label(1 `label1')
label(2 `label2')
label(3 `label3')
label(4 `label4')
label(5 `label5')
label(6 `label6')
label(7 `label7')
label(8 `label8')
label(9 `label9')
label(10 `label10')
label(11 `label11')
label(12 `label12')
)
title("`titcur' Curve(s)")
subtitle("`typeb' bound(`level'%)")
xtitle(Percentiles (p)) 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
plotregion(margin(zero))
graphregion(margin(medlarge))
legend(size(medsmall))
`options'
;
};

if("`conf'"=="ub") {;
twoway 
(
line  `_cory' _corx, 
legend(
label(1 `label1')
label(2 `label2')
label(3 `label3')
label(4 `label4')
label(5 `label5')
label(6 `label6')
label(7 `label7')
label(8 `label8')
label(9 `label9')
label(10 `label10')
label(11 `label11')
label(12 `label12')
)
title("`titcur' Curve(s)")
subtitle("`typeb' bound(`level'%)")
xtitle("Percentiles") 
ytitle(`ytitle')
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max')
plotregion(margin(zero))
graphregion(margin(medlarge))
legend(size(medsmall))
`dif_line_opts'
`options'
)
;
};

};

cap matrix drop _xx;
if( "`sres'" ~= "") {;
keep _corx _cory*;
save `"`sres'"', replace;
};

if( "`sgra'" ~= "") {;
graph save `"`sgra'"', replace;
};

if( "`egra'" ~= "") {;
graph export `"`egra'"', replace;
};





end;





