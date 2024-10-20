


#delim ;

capture program drop dtablet01;
program define  dtablet01, rclass;
version 9.2;
syntax varlist (min=2 max=2) [,  HSize(varname) HGroup(varname) GNumber(int -1)];

tokenize `varlist';
tempvar _hs;
gen `_hs'=`hsize';
if (`gnumber'!=-1)  qui replace `_hs'=`_hs'*(`hgroup'==`gnumber');
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

tempvar _num _denum _fw _w;
qui gen `_fw'=`_hs';
if (`"`hweight'"'~="") qui replace `_fw'=`_fw'*`hweight';

qui gen `_w'=1;
if (`"`hweight'"'~="") qui replace `_w'=`hweight';
if (`gnumber'!=-1)     qui replace `_w'=`_w'*(`hgroup'==`gnumber');

qui sum `_fw';
return scalar est1  = `r(sum)';

qui sum `_w';
return scalar est2  = `r(sum)';

qui sum `hsize' [aw=`_w'];
return scalar est3   = `r(mean)';

qui sum `1' [aw=`_fw'];
return scalar est4   = `r(mean)';

qui sum `2' [aw=`_fw'];
return scalar est5   = `r(mean)';


end;




capture program drop ttrjob10;
program define ttrjob10, eclass;
version 9.2;
syntax varlist(min=2 max=2)[, HSize(varname) HGroup(varname)   LAN(string)];


if ("`hgroup'"!="") {;
preserve;
capture {;
local lvgroup:value label `hgroup';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , clear;
qui count;
forvalues i=1/`r(N)' {;
local tem=value[`i'];
local grlab`tem' = label[`i'];
};
};
};
restore;preserve;
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

tempvar Variable EST1 EST2 EST3 EST4 EST5 ;
qui gen `Variable'="";
qui gen `EST1'=0;
qui gen `EST2'=0;
qui gen `EST3'=0;
qui gen `EST4'=0;
qui gen `EST5'=0;



tempvar _ths;
qui gen  `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';
cap svy: total;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local ll=length("`1': `grlab`1''");
forvalues k = 1/$indica {;
local kk = gn1[`k'];
dtablet01 `varlist' ,  hsize(`_ths') hgroup(`hgroup') gnumber(`kk');

qui replace `EST1'      = `r(est1)'  in `k';
qui replace `EST2'      = `r(est2)' in `k';
qui replace `EST3'      = `r(est3)' in `k';
qui replace `EST4'      = `r(est4)' in `k';
qui replace `EST5'      = `r(est5)' in `k';
local label`f'  : label (`hgroup') `kk';
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";
qui replace `Variable' = "`label`f''" in `k';
local ll=max(`ll',length("`label`f''"));
};
local ll=`ll'+10;


dtablet01 `varlist',  hsize(`_ths');

local kk1 = $indica+1;
qui replace `Variable' = "Total" in `kk1';
qui replace `EST1'      = `r(est1)'  in `kk1';
qui replace `EST2'      = `r(est2)' in `kk1';
qui replace `EST3'      = `r(est3)' in `kk1';
qui replace `EST4'      = `r(est4)' in `kk1';
qui replace `EST5'      = `r(est5)' in `kk1';



cap drop __compna;
qui gen  __compna=`Variable';

local lng = ($indica+1);
qui keep in 1/`lng';

local dste=0;
local rnam;
forvalues i=1(1)`lng'  {;
local temn=__compna[`i'];
               local rnam `"`rnam' "`temn'""';
};

global rnam `"`rnam'"';
tempname zz;
qui mkmat        `EST1'  `EST2' `EST3' `EST4' `EST5' `EST6',   matrix(`zz');


local cnam = "";
                     local cnam `"`cnam' "Population ""';
                                         
if ("`lan'"~="fr")  local cnam `"`cnam' "Number of households""';
if ("`lan'"~="fr")  local cnam `"`cnam' "Household size""';
if ("`lan'"~="fr")  local cnam `"`cnam' "Expenditures per capita""';
if ("`lan'"~="fr")  local cnam `"`cnam' "Exp. per cap. on Tobacco""';




matrix rownames `zz' = `rnam' ;
matrix colnames `zz' = `cnam' ;




cap matrix drop _vv _aa gn;

ereturn matrix est = `zz';

restore;
end;



