/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 1.4  )          */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2008)          */
/* Université Laval, Quebec, Canada                                    */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : cdensity                                                    */
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



capture program drop cdensity2;
program define cdensity2, rclass;
version 9.2;
args www yyy min max band gr ng;

preserve;
if ("`gr'" ~="") qui keep if (`gr'==gn1[`ng']);
cap drop if `yyy'>=.;
cap drop if `www'>=.;
qui count;
if (`r(N)'<101) set obs 101;


tempvar  _density _ra;
qui gen `_ra'=0;
qui gen `_density'=0;
local pas = (`max'-`min')/100;
if (_N<101) qui set obs 101;
qui su `yyy' [aw=`www'], detail;            
local tmp = (`r(p75)'-`r(p25)')/1.34;                           
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)';     
local h   = 0.9*`tmp'*_N^(-1.0/5.0); 
if (`band'==0) local band=`h';  

tempvar _s2;
gen `_s2' = sum( `www' ); 

forvalues j=1/101 {;
qui replace `_ra'=`min'+(`j'-1)*`pas' in `j';
cap drop `_s1'; 
tempvar  _s1;
qui gen `_s1' = sum( `www' *exp(-0.5* ( ((`_ra'[`j']-`yyy')/`band')^2  )  ));  
qui replace `_density'=`_s1'[_N]/( `band'* sqrt(2*c(pi)) * `_s2'[_N] )  in `j';
};
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat `_density', matrix (_xx);
restore;
end;

capture program drop cdensity;
program define cdensity, rclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) HGroup(varname) BAND(real 0) 
  LRES(int 0) SRES(string) MIN(string) MAX(string) DGRA(int 1) SGRA(string) EGRA(string) *];
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
};

if ("`hgroup'"=="") {;
tokenize `varlist';
_nargs    `varlist';
preserve;
};


qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local hweight=""; 
cap qui svy: total `1'; 
cap local hweight=`"`e(wvar)'"';
cap ereturn clear; 

tempvar fw;
local _cory  = "";
local label = "";

quietly{;
gen `fw'=1;


if ($indica>1) local tits="s";
local ftitle = "Density Curve`tits'";
local ytitle = "f(y)";
local xtitle = "y";
if ("`cytitle'"  ~="") local ytitle ="`cytitle'";
if ("`cxtitle'"  ~="") local xtitle ="`cxtitle'";

if ("`ctitle'"  ~="")     local ftitle ="`ctitle'";
if ("`hsize'"  ~="")      replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")      replace `fw'=`fw'*`hweight';
};

qui count;
qui sum `1';
if ("`min'"  =="")     local min =`r(min)';
if ("`max'"  =="")     local max =`r(max)';
if ("`type'"  =="")     local type ="yes";


forvalues k = 1/$indica {;

local _cory  = "`_cory'" + " _cory`k'";
local f=`k';
if ("`hgroup'"=="") {;
local label`f'  =  "``k''";

cdensity2 `fw' ``k'' `min' `max' `band';
};

if ("`hgroup'"!="") {;
local kk = gn1[`k'];
local label`f'  : label (`hgroup') `kk';
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";

cdensity2 `fw' `1' `min' `max' `band' `hgroup' `k';

};
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _cory`k';
};
qui count;
if (`r(N)'<101) set obs 101;

qui keep in 1/101;
gen _corx=0;
local m5  = (`max'-`min')/5;
local pas = (`max'-`min')/100;
forvalues j=1/101 {;
qui replace _corx=`min'+(`j'-1)*`pas' in `j';
};

if( `lres' == 1) {;
set more off;
list _corx _cory*;
};

if (`dgra'!=0) {;  
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
title(`ftitle')
subtitle(`cstitle')
ytitle(`ytitle')
xtitle(`xtitle') 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))

plotregion(margin(zero))
`options'
;

;
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
restore;
end;



