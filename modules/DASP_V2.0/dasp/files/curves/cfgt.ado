/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.0)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universit Laval , Quebec, Canada                                    */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : cfgt                                                        */
/*************************************************************************/

#delim ;


capture program drop fgt2;
program define fgt2, rclass;
version 9.2;
args www yyy al type min max gr ng;
preserve;
if ("`gr'" ~="") qui keep if (`gr'==gn1[`ng']);
cap drop if `yyy'>=.;
cap drop if `www'>=.;
tempvar ww wy ra ga ffgt;

gen `ffgt'=0;
gen `ra'=0;
local pas = (`max'-`min')/100;
if (_N<101) qui set obs 101;
forvalues j=1/101 {;
qui replace `ra'=`min'+(`j'-1)*`pas' in `j';
cap drop `ga';
gen `ga' = 0;
if (`al'== 0) qui replace `ga' = (`ra'[`j']>`yyy');
if (`al' ~= 0  & "`type'"=="nor") qui replace `ga' = ((`ra'[`j']-`yyy')/`ra'[`j'])^`al' if (`ra'[`j']>`yyy');
if (`al' ~= 0  & "`type'"!="nor") qui replace `ga' = ((`ra'[`j']-`yyy'))^`al' if (`ra'[`j']>`yyy');
qui sum `ga' [aweight= `www'];
qui replace `ffgt'=`r(mean)' in `j';
};
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat `ffgt', matrix (_xx);
restore;
end;

capture program drop cfgt;
program define cfgt, rclass;
version 9.2;
syntax varlist(min=1)[,  HSize(varname) HGroup(varname) ALpha(real 0) 
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
local tit1="FGT"; 
local tit2="FGT"; 
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
if (r(N)<101) qui set obs 101;

forvalues k = 1/$indica {;

local _cory  = "`_cory'" + " _cory`k'";
local f=`k';
if ("`hgroup'"=="") {;
local label`f'  =  "``k''";
if ("`dif'"=="c1") local label`f'  = "FGT_``k'' - FGT_`1'";
fgt2 `fw' ``k'' `alpha' `type' `min' `max';
};

if ("`hgroup'"!="") {;
local kk = gn1[`k'];
local k1 = gn1[1];
local label`f'  : label (`hgroup') `kk';
local labelg1   : label (`hgroup') `k1';
if ( "`label1'" == "")   local labelg1    = "Group: `k1'";
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";
local titd="FGT";
if ("`dif'"=="c1") local label`f'= "`titd'_`label`f'' - `titd'_`labelg1'";


fgt2 `fw' `1' `alpha' `type'  `min' `max' `hgroup' `k';
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
)
title(`ftitle')
ytitle(`ytitle')
xtitle(Poverty line (z)) 
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



