/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Universite Laval , Quebec, Canada                                    */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : ctgpr                                                        */
/*************************************************************************/


#delimit ;
capture program drop tgpr3;
program define tgpr3, rclass;
version 9.2;
args www yyy al type pline min max gr ng;
preserve;
qui sum `www' ; local s1=r(sum);
qui sum `www' if (`gr'==gn1[`ng']);  local s2=r(sum);
local phig= `s2'/`s1' ;
if ("`gr'" ~="") qui keep if (`gr'==gn1[`ng']);
cap drop if `yyy'>=.;
cap drop if `www'>=.;
tempvar ww wy ra rp ftgpr;

gen `ftgpr'=0;
gen `ra'=0;
local pas = (`max'-`min')/100;
if (_N<101) qui cap set obs 101;
forvalues j=1/101 {;
qui replace `ra'=`min'+(`j'-1)*`pas' in `j';
cap drop `rp';
gen `rp' = 0;
if (`al'== 0) qui replace `rp' = (`pline'>`yyy')*((`yyy'+`ra'[`j']/`phig')>=`pline') ;
if (`al'== 1) qui replace `rp' = min(`ra'[`j']/`phig', (`pline'-`yyy'))/`pline' if (`pline'>`yyy');
if (`al' != 0 &  `al' != 1 ) qui replace `rp' = ((`pline'-`yyy')/`pline')^`al' -((`pline'-min(`yyy'+`ra'[`j']/`phig',`pline'))/`pline')^`al'   if (`pline'>`yyy');
qui sum `rp' [aweight= `www'];
qui replace `ftgpr'= `phig'*`r(mean)' in `j';
};
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat `ftgpr', matrix (_xx);
restore;
end;

#delim ;
capture program drop cgtpr;
program define cgtpr, rclass;
version 9.2;
syntax varlist(min=1)[,  HSize(varname) HGroup(varname) ALpha(real 0)  PLine(real 10000) 
type(string)  LRES(int 0) SRES(string) 
 DIF(string) MIN(string) MAX(string) DGRA(int 1) SGRA(string) EGRA(string) *];

if ("`dif'"=="no") local dif="";
if ("`type'"=="")  local type="nor";

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

local hweight=""; 
cap qui svy: total `1'; 

cap if (`e(wvar)') local hweight=`"`e(wvar)'"';
if ("`e(wvar)'"~="`hweight'") dis as txt in blue " Warning: sampling weight is initialized but not found.";

tempvar fw;
local _cory  = "";
local label = "";
quietly{;
gen `fw'=1;
local tit1="GTPR"; 
local tit2="GTPR"; 
local tit3="";
local tit4="";
local tits="";
if ($indica>1) local tits="s";
if ("`type'"=="nor") {;
local tit3="";
local tit4="";
};

if ("`dif'"=="c1") local tit0 = "Difference between";
local ftitle = "`tit0'"+"`tit3'"+" `tit1' Curve`tits' (alpha=`alpha')";
                   local ytitle = "`tit4'`tit2'(z, alpha = `alpha')";
if ("`dif'"=="c1") local ytitle = "Differences";
if ("`hsize'"  ~="")      replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")      replace `fw'=`fw'*`hweight';
};

qui count;
qui sum `1';
if ("`min'"  =="")      local min =`r(min)';
if ("`max'"  =="")      local max =`r(max)';
if ("`type'"  =="")     local type ="yes";
if (r(N)<101) qui cap set obs 101;

forvalues k = 1/$indica {;

local _cory  = "`_cory'" + " _cory`k'";
local f=`k';
if ("`hgroup'"=="") {;
local label`f'  =  "``k''";
if ("`dif'"=="c1") local label`f'  = "tgpr_``k'' - tgpr_`1'";
tgpr3 `fw' ``k'' `alpha' `type' `pline' `min' `max';
};

if ("`hgroup'"!="") {;
local kk = gn1[`k'];
local k1 = gn1[1];
local label`f'  : label (`hgroup') `kk';
local labelg1   : label (`hgroup') `k1';
if ( "`label1'" == "")   local labelg1    = "Group: `k1'";
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";
local titd="tgpr";
if ("`dif'"=="c1") local label`f'= "`titd'_`label`f'' - `titd'_`labelg1'";
tgpr3 `fw' `1' `alpha' `type'  `pline' `min' `max' `hgroup' `k';
};
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _cory`k';
};

qui keep in 1/101;
gen _corx=0;
local pas = (`max'-`min')/100;
local m5 = (`max'-`min')/5;
forvalues j=1/101 {;
qui replace _corx=`min'+(`j'-1)*`pas' in `j';
};

if ("`dif'"=="c1") {;
gen _dct=_cory1;
forvalues k = 1/$indica {;
qui replace _cory`k'=_cory`k'-_dct;
};
local label1  ="Null horizontal line";
};

if( `lres' == 1) {;
set more off;
list _corx _cory*;
};

quietly {;
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
label(13 `label13')
label(14 `label14')
label(15 `label15')
label(16 `label16')
)
title(`ftitle')
ytitle(`ytitle')
xtitle(Per capita transfer (tau)) 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
plotregion(margin(zero))
graphregion(margin(medlarge))
legend(size(medsmall))
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
};
end;

cgtpr exppc, alpha(3) pline(80000) hsize(size) hgroup(gse) min(0) max(1000);

