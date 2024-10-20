/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 1.4)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2008)          */
/* Université Laval, Quebec, Canada                                    */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : c_quantile                                                  */
/*************************************************************************/


#delim ;
capture program drop _nargs;
program define _nargs, rclass;
version 9.2;
syntax varlist(min=0);
quietly {;
tokenize `varlist';
local k = 1;
mac shift;
while "``k''" ~= "" {; 
local k = `k'+1;
};
};
global indica=`k';
end;

capture program drop cquantile2;
program define cquantile2, rclass;
version 8.0;
args www yyy type min max gr ng;
preserve;
if ("`gr'" ~="") qui keep if (`gr'==gn1[`ng']);
sort `yyy';
cap drop if `yyy'>=.;
cap drop if `www'>=.;
if (_N<101) qui set obs 101;
tempvar _ww _qp _pc _finqp;
qui gen `_ww'=sum(`www');
gen `_pc'=`_ww'/`_ww'[_N];
gen `_qp' = `yyy' ;
qui sum `yyy' [aw=`www'];
if ("`type'"=="nor") qui replace `_qp' = `_qp' / `r(mean)' ;
if ("`type'"=="abs") qui replace `_qp' = `_qp' - `r(mean)' ;
qui sum  [aw=`www'];
local mina=`r(min)';
local maxa=`r(max)';
local ff=`mina';
if(`min'==0 & `mina'>0) local ff=0;

gen `_finqp'=0;
local step=(`max'-`min')/100;
local i = 1;
forvalues j=0/100 {;
local pcf=`min'+`j' *`step';
local av=`j'+1;
while (`pcf' > `_pc'[`i']) {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) local lqi=`_qp'[`ar']+((`_qp'[`i']-`_qp'[`ar'])/(`_pc'[`i']-`_pc'[`ar']))*(`pcf'-`_pc'[`ar']);
if (`i'==1) local lqi=`ff'+(max(0,`_qp'[`i'])/(`_pc'[`i']))*(`pcf');
qui replace `_finqp'=`lqi' in `av';
};
if(`min'==0 & `mina'>0) qui replace `_finqp' = 0 in 1;
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat `_finqp', matrix (_xx);
restore;
end;






capture program drop c_quantile;
program define c_quantile, rclass;
version 9.2;
syntax varlist(min=1)[,  HSize(varname) HGroup(varname)
MIN(real 0) MAX(real 1) type(string) DIF(string)
 LRES(int 0)  SRES(string) DGRA(int 1) SGRA(string) EGRA(string) *];

if (`min' < 0) {;
 di as err "min should be >=0"; exit;
};
if (`max' > 1) {;
 di as err "max should be <=1"; exit;
};

if (`max' <= `min') {;
 di as err "max should be greater than min"; exit;
};
if ("`dif'"=="no") local dif="";

_get_gropts , graphopts(`options') ;
	local options `"`s(graphopts)'"';
	
if ("`hgroup'"!="") {;
preserve;
capture {;
local lvgroup:value label `hgroup';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , clear;
qui count;
forvalues i=1/`r(N)' {;
local grlab`i' = label[`i'];
};
};
};
restore;
preserve;
qui tabulate `hgroup', matrow(gn);
svmat int gn;
global indica=r(r);
tokenize `varlist';
matrix drop gn;
};
if ("`hgroup'"=="") {;
tokenize  `varlist';
_nargs    `varlist';
preserve;
};


qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
tempvar fw;
local _cory  = "";
local label  = "";
quietly{;
gen `fw'=1;
local tit1="Quantile"; 
local tit2="Q"; 
local tit3="";
local tit4="";

if ("`type'"=="nor") {;
local tit3="Normalised ";
local tit4="N";
};

if ("`dif'"=="c1")   local tit0="Difference Between ";
if ("`dif'"=="c1")   local Ytit0="Dif: ";

local tit_s="";
if ($indica>1) local tit_s="s";
local ftitle = "`tit0'`tit3'"+"`tit1' Curve`tit_s'";
local ytitle = "`Ytit0'`tit4'`tit2'(p)";

if ("`ctitle'"  ~="")    local ftitle ="`ctitle'";
if ("`hsize'"  ~="")     replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")     replace `fw'=`fw'*`hweight';
};
qui count;
if (r(N)<101) set obs 101;
forvalues k = 1/$indica {;
local _cory  = "`_cory'" + " _cory`k'";
local f=`k';
if ("`type'"=="") local type = "no";
if ("`min'"=="") local min = 0;
if ("`max'"=="") local max = 1;
if ("`hgroup'"=="") {;
local label`f'  =  "``k''";
if ("`dif'"=="c1") local label`f'  = "`tit2'_``k'' - `tit2'_`1'";
cquantile2 `fw' ``k'' `type' `min' `max' ;
};

if ("`hgroup'"!="") {;
local kk = gn1[`k'];
local k1 = gn1[1];
local label`f'  : label (`hgroup') `kk';
local labelg1   : label (`hgroup') `k1';
if ( "`label1'" == "")   local labelg1    = "Group: `k1'";
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";
if ("`dif'"=="c1") local label`f'="`tit2'_`label`f'' - `tit2'_`labelg1'";

cquantile2 `fw' `1' `type' `min' `max' `hgroup' `k';

};
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _cory`k';
};
local step=(`max'-`min')/100;
gen _perc = `min'+(_n-1)*`step';
qui keep in 1/101;
if( `lres' == 1) {;
set more off;
list _perc _cory*;
};

 // end of quietly 

 
if ("`dif'"=="c1") {;
gen _dct=_cory1;
forvalues k = 1/$indica {;
qui replace _cory`k'=_cory`k'-_dct;
};
local label1  ="Null Horizontal Line";
};

quietly {;

if (`dgra'!=0) {; 
line `_cory'  _perc, 
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
title(`ftitle')
subtitle(`cstitle')
ytitle(`ytitle')
xtitle(Percentiles (p)) 
plotregion(margin(zero))
`options'		
;
};
cap matrix drop _xx;
if( "`sres'" ~= "") {;
keep _perc _cory*;
save `"`sres'"', replace;
};

if( "`sgra'" ~= "") {;
graph save `"`sgra'"', replace;
};

if( "`egra'" ~= "") {;
graph export `"`egra'"', replace;
};

restore;
}; // end of quietly
end;

