/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 1.5  )          */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : cpoverty                                                    */
/*************************************************************************/


#delim ;



capture program drop cpov1;
program define cpov1, rclass;
version 9.2;
args www yyy pline type min max gr ng;
preserve;
if ("`gr'" ~="") qui keep if (`gr'==gn1[`ng']);
sort `yyy';
cap drop if `yyy'>=.;
cap drop if `www'>=.;
if (_N<101) qui set obs 101;
cap drop _ww;
cap drop _qp;
cap drop _pc;
qui gen _ww=sum(`www');
gen _pc=_ww/_ww[_N];
gen _qp = `yyy' ;
qui sum `yyy' [aw=`www'];
qui sum  [aw=`www'];
local mina=`r(min)';
local maxa=`r(max)';
local ff=`mina';
if(`min'==0 & `mina'>0) local ff=0;
cap drop _finqp;
gen _finqp=0;
local step=(`max'-`min')/100;
local i = 1;
forvalues j=0/100 {;
local pcf=`min'+`j' *`step';
local av=`j'+1;
while (`pcf' > _pc[`i']) {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) local lqi=_qp[`ar']+((_qp[`i']-_qp[`ar'])/(_pc[`i']-_pc[`ar']))*(`pcf'-_pc[`ar']);
if (`i'==1) local lqi=`ff'+(max(0,_qp[`i'])/(_pc[`i']))*(`pcf');
if "`type'"!="nor"  qui replace _finqp=max(0,`pline'-`lqi')  in `av';
if "`type'"=="nor"  qui replace _finqp=max(0,1-`lqi'/`pline')  in `av';
};

qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat _finqp, matrix (_xx);
restore;
end;



capture program drop cpov2;
program define cpov2, rclass;
version 9.2;
args www yyy pline type min max gr ng;
quietly {;
preserve;
if ("`gr'" ~="") qui keep if (`gr'==gn1[`ng']);
sort `yyy';
cap drop if `yyy'>=.;
cap drop if `www'>=.;
if (_N<101) qui set obs 101;
cap drop _ww;
cap drop _wy;
cap drop _lp;
if "`type'"!="nor"  qui replace `yyy'=max(0,`pline'-`yyy');
if "`type'"=="nor"  qui replace `yyy'=max(0,1-`yyy'/`pline');
gen _ww = sum(`www');
gen _wy = sum(`www'*`yyy');
local suma = _wy[_N];
cap drop _pc;
qui sum _ww;
gen _pc=_ww/r(max);
qui sum `www';
local suma = `suma'/`r(sum)';
gen _lp=_wy/r(sum);
cap drop _finlp;
gen _finlp=0;
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




capture program drop cpoverty;
program define cpoverty, rclass;
version 9.2;
version 9.2;
syntax varlist(min=1)[, HSize(varname) PLine(real 0) HGroup(varname)
 MIN(real 0) MAX(real 1) curve(string) type(string) DIF(string)
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

 

local tit2="PG";
if ("`curve'"=="cpg") local tit2="CPG";
local tit1="Poverty Gap";
if ("`curve'"=="cpg") local tit1="Cumulative poverty gap";
if ("`dif'"=="c1")   local tit0="Difference between ";
if ("`dif'"=="c1")   local Ytit0="Dif: ";


local tit_s="";
if ($indica>1) local tit_s="s";
local ftitle = "`tit0'"+"`tit1' Curve`tit_s'";
local ytitle = "`Ytit0'`tit2'(p)";
local xtitle = "Percentiles (p)";

tempvar fw;
gen `fw'=1;
if ("`hsize'"   ~="")     qui replace `fw'=`fw'*`hsize';
if ("`hweight'" ~="")     qui replace `fw'=`fw'*`hweight';
local xtitle = "Percentiles (p)";
if ("`cytitle'"  ~="") local ytitle ="`cytitle'";
if ("`cxtitle'"  ~="") local xtitle ="`cxtitle'";

qui count;
if (r(N)<101) set obs 101;
if ("`curve'"=="") local curve="pg";
if ("`type'"=="")  local type="nor";
forvalues k = 1/$indica {;
local _cory  = "`_cory'" + " _cory`k'";
local f =`k';


if ("`curve'"=="") local curve = "no";
if ("`min'"=="")  local min  = 0;
if ("`max'"=="")  local max  = 1;
if ("`hgroup'"=="") {;
local label`f'  =  "``k''";
if ("`dif'"=="c1") local label`f'  = "`tit2'_``k'' - `tit2'_`1'";
if ("`curve'"=="pg")  qui cpov1 `fw' ``k'' `pline'  `type' `min' `max' ;
if ("`curve'"=="cpg") qui cpov2 `fw' ``k'' `pline'  `type' `min' `max' ;

};
if ("`hgroup'"!="") {;
local kk = gn1[`k'];
local k1 = gn1[1];
local label`f'  : label (`hgroup') `kk';
local labelg1   : label (`hgroup') `k1';
if ( "`label1'" == "")   local labelg1    = "Group: `k1'";
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";

if ("`dif'"=="c1") local label`f'="`tit2'_`label`f'' - `tit2'_`labelg1'";

if ("`curve'"=="pg")  qui cpov1 `fw' `1' `pline' `type' `min' `max' `hgroup' `k';
if ("`curve'"=="cpg") qui cpov2 `fw' `1' `pline' `type' `min' `max' `hgroup' `k';


};
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _cory`k';
};
local m5=(`max'-`min')/5;
local step=(`max'-`min')/100;
gen _perc = `min'+(_n-1)*`step';
qui keep in 1/101;
if( "`lres'" == "yes") {;
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
if( `lres' == 1) {;
set more off;
list _perc _cory*;
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
