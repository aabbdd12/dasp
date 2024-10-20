
/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : ipoegr                                                      */
/*************************************************************************/



#delim ;
cap program drop ginip;
program define ginip, rclass;
args  fw inc;
preserve;
local gini = 0;
qui count;
qui {;
cap drop if `inc'>=. | `fw'>=.;
gsort -`inc';
gen vr = sum(`fw')^2; gen p = vr  - vr[_n-1];
replace p = vr[1] in 1; replace p = p / vr[_N];
gen  xi = sum(p*`inc');  local xi = xi[_N];
sum `inc' [aw=`fw']; local mu = `r(mean)';
local gini = 1 - (`xi'/`mu');
};
restore; 
return scalar gini   = `gini';
end;


capture program drop quantiles;
program define quantiles, rclass sortpreserve;
version 9.2;
args www yyy min max part;
preserve;
local part1=`part'+1;
sort `yyy';
cap drop if `yyy'>=.;
cap drop if `www'>=.;
if (_N<`part1') qui set obs `part1';
tempvar  _finqp _ww _qup _lp _pci _pc;


qui gen `_pci'=0;
qui gen `_ww' = sum(`www');
qui gen `_pc' = `_ww'/`_ww'[_N];
qui gen     `_lp'  = sum(`www'*`yyy');
qui replace `_lp'  = `_lp'/`_lp'[_N];

qui gen `_qup' = `yyy' ;
qui sum `yyy' [aw=`www'];
qui sum  [aw=`www'];
local mina=`r(min)';
local maxa=`r(max)';
local ff=`mina';
if(`min'==0 & `mina'>0) local ff=0;
qui gen  `_finqp'=0;
local step=(`max'-`min')/`part';
local i = 1;
forvalues j=1/`part' {;
local pcf=`j' *`step';
local av=`j'+1;
while (`pcf' > `_lp'[`i']) {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) local lqi=`_qup'[`ar']+((`_qup'[`i']-`_qup'[`ar'])/(`_lp'[`i']-`_lp'[`ar']))*(`pcf'-`_lp'[`ar']);
if (`i'==1) local lqi=`_qup'[`i']);
qui replace `_finqp'=`lqi' in `av';
qui replace `_pci'  =`pcf' in `av';

};

qui keep in 2/`part1';
if `part' > 10 set matsize `part';
cap matrix drop _xx;
mkmat `_pci' `_finqp', matrix (_xx);
restore;
end;





/***********************************************************************/
/* The optimal partition of groups is made with an itterative procedure*/
/***********************************************************************/

#delim ;
cap program drop ipoegr;
program define ipoegr, rclass;
version 9.2;
syntax varlist(min=1 max=1) [, 
NG(int 4)  ALpha(real 1) Beta(real 1) NITR(int 16) PRCS(real 0.000001)
HSize(string)  HGRoup(string) GNumber(int 1) * ];
preserve;
qui tokenize `varlist';
#delim cr

local hweight=""
cap qui svy: total `1' 
local hweight=`"`e(wvar)'"'
cap ereturn clear
sort `1'
tempvar hw hs fw 
gen `hw'=1 
gen `hs'=1
if ("`hweight'" != "")  qui replace  `hw'     =  `hweight'
if ("`hsize'"   != "")  qui replace  `hs'     =  `hsize'
if ("`hgroup'"  != "")  qui keep if  `hgroup' == `gnumber'

qui gen `fw'=`hw'*`hs'
quantiles `fw' `1' 0 1 `ng'
svmat float _xx
cap matrix drop _xx
rename _xx1 _perc
rename _xx2 _qp
cap drop ngr
gen ngr = 0
forvalues i=1/`ng'{
qui replace ngr = `i' in `i'
local qp`i' = _qp[`i']
} 

qui sum `1' [aw=`fw']
local mu = `r(mean)'
local mina = `r(min)'
local maxa = `r(max)'

cap drop _lb _ub
qui gen _lb=0
qui gen _ub=0
forvalues i=1/`ng'{
local j = `i' - 1
cap local _lb`i' = `qp`j''
local _ub`i' = `qp`i''  
} 

local _lb1    = `mina'
local _ub`ng' = `maxa'


tempvar fgr

gen `fgr' = 1

local tgr = 1
forvalues j=1/`r(N)' {
if (`1'[`j']>_qp[`tgr']) local tgr=`tgr'+1
qui replace `fgr' = min(`tgr',`ng') in `j'
}




tempvar tem mu_g mu_ga win ww 

gen  `win' =`fw'*`1'
egen `tem'   =  mean(`win')  , by(`fgr')
egen `ww'    =  mean(`fw')   , by(`fgr')
gen  `mu_g'  = `tem'/(`ww'*`mu')
gen  `mu_ga'  = `tem'/(`ww')
qui sum `ww' 
tempvar phi
gen `phi'=`ww'/`r(sum)'


cap drop _phi
gen _phi=0
cap drop _mug
gen _mug=0
forvalues h=1/`ng'{
qui sum  `phi' if `fgr'==`h'
qui replace _phi= `r(sum)' in `h'
qui sum  `mu_ga' if `fgr'==`h'
qui replace _mug= `r(mean)' in `h'
}

/**********/

local olderr=.
forvalues s=1/`nitr'{


cap drop a1
gen a1 = 0
local ng1=`ng'-1
forvalues i=1/`ng1'{
qui replace a1 = (_phi[`i']*_mug[`i']+_phi[`i'+1]*_mug[`i'+1])/(_phi[`i']+_phi[`i'+1]) in `i'
}

cap drop _fgr

gen  _fgr= 1 
local tgr = 1
qui count
forvalues j=1/`r(N)' {
if (`1'[`j']>a1[`tgr']) local tgr=`tgr'+1
qui replace _fgr = min(`tgr',`ng') in `j'
}



tempvar phi tem mu_g mu_ga ww 

egen `tem'    =  mean(`win')  , by(_fgr)
egen `ww'     =  mean(`fw')   , by(_fgr)
gen  `mu_g'   = `tem'/(`ww'*`mu')
gen  `mu_ga'  = `tem'/(`ww')
qui sum `ww' 
gen `phi'=`ww'/`r(sum)'


cap drop _phi
gen _phi=0
cap drop _mug
gen _mug=0

forvalues h=1/`ng'{
qui sum `phi' if _fgr==`h'
qui replace _phi = `r(sum)' in `h'
qui sum  `mu_ga' if _fgr==`h'
qui replace _mug= `r(mean)' in `h'
}


ginip `fw' `1'
local est1=`r(gini)'
ginip `ww' `mu_g'
local est2=`r(gini)'

local corr = (`est1'-`est2')
local error= `corr'/`est1'*100
local conv=(`olderr'-`error')/`olderr'
local olderr = `error'

dis "Iteration Number->" %2.0f `s' " | Error = " %8.6f `error' "% | Convergence = " %8.6f `conv'
if (`conv' < `prcs') continue, break
}

cap drop _lb _ub
qui gen _lb=0
qui gen _ub=0
forvalues i=1/`ng'{
local j = `i' - 1
cap local _lb`i' = a1[`j']
local     _ub`i' = a1[`i']  
local _lb1    = `mina'
local _ub`ng' = `maxa'
} 




ginip `fw' `1'
local est1=`r(gini)'
ginip `ww' `mu_g'
local est2=`r(gini)'

local corr = (`est1'-`est2')
local error= `corr'/`est1'*100

collapse (mean) `mu_g' `mu_ga' (sum)`phi' , by(_fgr)

gen L_Bound=0
gen U_Bound=0
gen Average    = `mu_ga'
gen Prop = `phi'
gen Group=_n
forvalues i=1/`ng'{
qui replace L_Bound=`_lb`i'' in `i'
qui replace U_Bound=`_ub`i'' in `i'
}


local ERI=0
forvalues i=1/`ng'{
local tempo=0
forvalues j=1/`ng'{
local tempo=`tempo'+`phi'[`j']*abs(`mu_g'[`i']-`mu_g'[`j'])
}
local ERI=`ERI' + `phi'[`i']^(`alpha'+1)*`tempo'
}


local  ERI =  (`ERI'   - `beta'*`corr')

//local  ERI =  (`ERI'/2 - `beta'*`corr')

//local  ERI =  (`ERI'   - `beta'*`corr')/2








      set more off
      disp in green _newline "{hline 70}"
      disp in white "     "_col(5)" Generalised Esteban et al. (1999) polarization index"  
      disp in green "{hline 70}" 
      disp in white " Alpha             :" _col(25) in yellow %8.2f `alpha'
      disp in white " Beta              :" _col(25) in yellow %8.2f `beta'				 
      disp in white " Numbers of groups :" _col(25) in yellow %8.0f `ng'  
      disp in green "{hline 70}"
      dis "Optimal partition of groups:" _continue
      tabdis Group, cellvar(L_Bound U_Bound Average Prop) concise format(%24.3f)

      disp in green "{hline 50}" 
      disp in white " Gini(f)             :" _col(25) in yellow %8.6f `est1'
      disp in white " Gini(rho*)          :" _col(25) in yellow %8.6f `est2'				 
      disp in white " Error               :" _col(25) in yellow %8.2f `error' "%" 
      disp in green "{hline 50}" 
      disp in white " EGR Index           :" _col(25) in yellow %8.6f `ERI'  
      disp in green "{hline 50}" 



restore

return scalar egr   = `ERI'

end
