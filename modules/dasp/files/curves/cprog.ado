/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Université Laval, Quebec, Canada                                    */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : cprog                                                     */
/*************************************************************************/


#delim ;


capture program drop prog2;
program define prog2, rclass;
version 9.2;
args www yyy rank type appr min max gr ng;
quietly {;
preserve;
if ("`gr'" ~="") qui keep if (`gr'==gn1[`ng']);
 sort `rank';
cap drop if `yyy'>=.;
cap drop if `www'>=.;
if (_N<101) qui set obs 101;
cap drop _ww;
cap drop _wy1;
cap drop _lp1;

cap drop _wy2;
cap drop _lp2;

tempvar y1 y2;
if ("`type'" =="t" & "`appr'" =="tr" ) {;
gen `y1' = `rank';
gen `y2' = `yyy';
};


if ("`type'" =="b" & "`appr'" =="tr" ) {;
gen `y1' = `yyy';
gen `y2' = `rank';
};

if ("`type'" =="t" & "`appr'" =="ir" ) {;
gen `y1' = `rank'-`yyy';
gen `y2' = `rank';
};

if ("`type'" =="b" & "`appr'" =="ir" ) {;
gen `y1' = `rank'+`yyy';
gen `y2' = `rank';
};

gen _ww = sum(`www');

cap drop _pc;
qui sum _ww;
gen _pc=_ww/r(max);

gen _wy1 = sum(`www'*`y1');


gen _wy2 = sum(`www'*`y2');



qui sum `y1' [aw=`www'];
gen _lp1=_wy1/r(sum);


qui sum `y2' [aw=`www'];
gen _lp2=_wy2/r(sum);

cap drop _finlp1; gen _finlp1=0;

cap drop _finlp2; gen _finlp2=0;


local step=(`max'-`min')/100;

local i = 1;
forvalues j=0/100 {;
local pcf=`min'+`j' *`step';
local av=`j'+1;
while (`pcf' > _pc[`i']) {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) local lpi=_lp1[`ar']+((_lp1[`i']-_lp1[`ar'])/(_pc[`i']-_pc[`ar']))*(`pcf'-_pc[`ar']);
if (`i'==1) local lpi=0+((_lp1[`i'])/(_pc[`i']))*(`pcf');
qui replace _finlp1=`lpi' in `av';
};

local i = 1;
forvalues j=0/100 {;
local pcf=`min'+`j' *`step';
local av=`j'+1;
while (`pcf' > _pc[`i']) {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) local lpi=_lp2[`ar']+((_lp2[`i']-_lp2[`ar'])/(_pc[`i']-_pc[`ar']))*(`pcf'-_pc[`ar']);
if (`i'==1) local lpi=0+((_lp2[`i'])/(_pc[`i']))*(`pcf');
qui replace _finlp2=`lpi' in `av';
};

gen _finlp  = _finlp1-_finlp2;
list _fin* in 1/101;
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat _finlp, matrix (_xx);
restore;
};
end;

capture program drop cprog;
program define cprog, rclass;
version 9.2;
syntax varlist(min=1)[, HWeight(varname) HSize(varname) HGroup(varname)
 RANK(varname) MIN(real 0) MAX(real 1) type(string) APPR(string)
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


qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 



local _cory  = "";
local label = "";



local tit_s="";
if ($indica>1) local tit_s="s";
local ftitle = "Progressivity curve(s)";


tempvar fw;
gen `fw'=1;
if ("`hsize'"   ~="")     replace `fw'=`fw'*`hsize';
if ("`hweight'" ~="")     replace `fw'=`fw'*`hweight';
local xtitle = "Percentiles (p)";
if ("`cytitle'"  ~="") local ytitle ="`cytitle'";
if ("`cxtitle'"  ~="") local xtitle ="`cxtitle'";

qui count;
if (r(N)<101) set obs 101;

gen _corh=0;
local _cory = "`_cory'" + " _corh";

if ("`hgroup'"!="") {;
if ("`type'"=="") local type = "t";
if ("`appr'"=="") local appr = "tr";
if ("`min'"=="")  local min  = 0;
if ("`max'"=="")  local max  = 1;
prog2 `fw' `1' `rank' `type' `appr' `min' `max' ;
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _corypop;
local _cory  = "`_cory'" + " _corypop";

};

forvalues k = 1/$indica {;
local _cory  = "`_cory'" + " _cory`k'";
local f=`k';
if ("`type'"=="")    local type = "t";
if ("`appr'"=="")    local appr = "tr";
if ("`min'"=="")     local min  = 0;
if ("`max'"=="")     local max  = 1;
if ("`hgroup'"=="") {;
prog2 `fw' ``k'' `rank' `type' `appr' `min' `max' ;
local label`f'="``k''";
};

if ("`hgroup'"!="") {;
local kk = gn1[`k'];
local label`f'  : label (`hgroup') `kk';
if ( "`label`f''" == "")   local label`f'   = "Group: `kk'";
prog2 `fw' `1' `rank' `type' `appr' `min' `max' `hgroup' `k';
};
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _cory`k';
};




qui{;
local m5=(`max'-`min')/5;
local step=(`max'-`min')/100;
gen _corx = `min'+(_n-1)*`step';
qui keep in 1/101;
}; // end of quietly 

 

local labela1  ="Null horizontal line";
local lg1="label(1 `labela1') ";
                    local j=1; 
if ("`hgroup'"!="") {;
local labela2  ="Population";
local lg2="label(2 `labela2') ";
local j=2;
};

if ("`type'" =="t" & "`appr'" =="tr" ) {;
local ytitle = "L_x(p) - C_t(p)";
};


if ("`type'" =="b" & "`appr'" =="tr" ) {;
local ytitle = " C_b(p)- L_x(P)";
};

if ("`type'" =="t" & "`appr'" =="ir" ) {;
local ytitle = " C_x-t(p)- L_x(p)";
};

if ("`type'" =="b" & "`appr'" =="ir" ) {;
local ytitle = " C_x+b(p)- L_x(p)";
};

forvalues i=1/$indica {;
local k=`j'+`i';
local lg`k'="label(`k' `label`i'') ";
};


if( `lres' == 1) {;
set more off;
list _corx _cory*;
};
quietly {;
if (`dgra'!=0) {; 
line `_cory'  _corx, 
legend(
`lg1'  `lg2'  `lg3' `lg4' 
`lg5'  `lg6'  `lg7' `lg8' 
`lg9'  `lg10'  `lg11' `lg12'
)
title(`ftitle')
ytitle(`ytitle')
xtitle(`xtitle') 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
plotregion(margin(zero))
legend(size(small))
`options'		
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
}; // end of quietly
end;
