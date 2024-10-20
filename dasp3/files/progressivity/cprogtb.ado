/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Université Laval, Quebec, Canada                                    */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : cprogbt                                                     */
/*************************************************************************/


#delim ;


capture program drop progbt2;
program define progbt2, rclass;
version 9.2;
args www bbb ttt rank appr min max gr ng;
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

cap drop _wy2;
cap drop _lp2;

tempvar y1 y2 y3;
if ("`appr'" == "tr" ) {;
gen `y1' = `bbb';
gen `y2' = `ttt';
gen `y3' = `rank';
// 1+2-2*3
};



if ("`appr'" =="ir" ) {;
gen `y1' = `rank'+`bbb';
gen `y2' = `rank'-`ttt';
};



gen _ww = sum(`www');

cap drop _pc;
qui sum _ww;
gen _pc=_ww/r(max);

gen _wy1 = sum(`www'*`y1');
gen _wy2 = sum(`www'*`y2');
if ("`appr'" =="tr" ) {;
gen _wy3 = sum(`www'*`y3');
};


qui sum `y1' [aw=`www'];
gen _lp1=_wy1/r(sum);


qui sum `y2' [aw=`www'];
gen _lp2=_wy2/r(sum);

if ("`appr'" =="tr" ) {;
qui sum `y3' [aw=`www'];
gen _lp3=_wy3/r(sum);
};

cap drop _finlp1; gen _finlp1=0;

cap drop _finlp2; gen _finlp2=0;

if ("`appr'" =="tr" ) {;
cap drop _finlp3; gen _finlp3=0;
};

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

if ("`appr'" =="tr" ) {;

local i = 1;
forvalues j=0/100 {;
local pcf=`min'+`j' *`step';
local av=`j'+1;
while (`pcf' > _pc[`i']) {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) local lpi=_lp3[`ar']+((_lp3[`i']-_lp3[`ar'])/(_pc[`i']-_pc[`ar']))*(`pcf'-_pc[`ar']);
if (`i'==1) local lpi=0+((_lp3[`i'])/(_pc[`i']))*(`pcf');
qui replace _finlp3=`lpi' in `av';
};
};

if ("`appr'" =="tr" ) gen _finlp  = _finlp1+_finlp2-2*_finlp3;
if ("`appr'" =="ir" ) gen _finlp  = _finlp1-_finlp2;
list _fin* in 1/101;
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat _finlp, matrix (_xx);
restore;
};
end;

capture program drop cprogtb;
program define cprogtb, rclass;
version 9.2;
syntax varlist(min=2 max=2)[, HWeight(varname) HSize(varname) HGroup(varname)
 RANK(varname) MIN(real 0) MAX(real 1) APPR(string)
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
if ("`appr'"=="") local appr = "tr";
if ("`min'"=="")  local min  = 0;
if ("`max'"=="")  local max  = 1;
progbt2 `fw' `1' `2' `rank' `appr' `min' `max' ;
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _corypop;
local _cory  = "`_cory'" + " _corypop";

};

forvalues k = 1/$indica {;
local _cory  = "`_cory'" + " _cory`k'";
local f=`k';
if ("`appr'"=="")    local appr = "tr";
if ("`min'"=="")     local min  = 0;
if ("`max'"=="")     local max  = 1;
if ("`hgroup'"=="") {;
progbt2 `fw' `1' `2' `rank' `appr' `min' `max' ;
local label`f'="``k''";
};

if ("`hgroup'"!="") {;
local kk = gn1[`k'];
local label`f'  : label (`hgroup') `kk';
if ( "`label`f''" == "")   local label`f'   = "Group: `kk'";
progbt2 `fw' `1' `2' `rank' `appr' `min' `max' `hgroup' `k';
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

if ("`appr'" =="tr" ) {;
local ytitle = "C{subscript:B}(p) + C{subscript:T}(p) - 2 L_x(p)";
};



if ("`appr'" =="ir" ) {;
local ytitle = " C{subscript:X+B}(p)- C{subscript:X-T}(p)";
};



forvalues i=1/$indica {;
local k=`j'+`i';
local lg`k'="label(`k' `label`i'') ";
};

        
if ("`hgroup'"=="") local opt2 = "legend(off)";	
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
graphregion(margin(medlarge))
legend(size(medsmall))
plotregion(margin(zero))
legend(size(small))
graphregion(fcolor(white)) 
 xlabel(, nogrid)
 ylabel(, nogrid)
graphregion(margin(medlarge))
`opt2'
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
