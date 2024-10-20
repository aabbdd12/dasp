/********************************************/
/* By: Araar Abdelkrim : aabd@ecn.ulaval.ca */
/* 21/01/2006                               */
/********************************************/



#delim cr
cap program drop sgini
program define sgini, rclass
version 8.0
args  fw inc gr indi
#delim ;
cap drop if `inc'>=. | `fw'>=.;
qui {;
preserve;
if ("`fw'" == "") {;
cap drop fw;
gen fw = 1;
};

if ("`gr'" != "") {;
keep if(`gr' == `indi');
};
};
local gini = 0;
qui count;
if (`r(N)' > 1) {;
qui {;
gsort -`inc';
gen vr = sum(`fw')^2; gen p = vr  - vr[_n-1];
replace p = vr[1] in 1; replace p = p / vr[_N];
gen  xi = sum(p*`inc');  local xi = xi[_N];
sum `inc' [aw=`fw']; local mu = `r(mean)';
local gini = 1 - (`xi'/`mu');
};
};
restore; 
return scalar gini   = `gini';
/* estimating the area A */


qui sum `fw';
gen _sw  = `fw'/`r(sum)';
gen _sy  =  sum(`fw'*`inc');
gen _py  = _sy/_sy[_N];
local A=0;
local CC=0;
local Aee=0;
local adjustA=0;
local adjustC=0;

local i = 1;
if (_py[`i']<0) {;
local A=-_sw[`i']*_py[`i']*0.5;
local i =`i'+1;
while (_py[`i']<=0 & `i'<=_N) {;
local A=`A'-_sw[`i']*_py[`i']-_sw[`i']*(-_py[`i']+_py[`i'-1])*0.5;
local i =`i'+1;
};
local i =`i' -1;
local dxe  = (_sw[`i'+1])/(_sy[`i'+1]-_sy[`i']) * -_sy[`i'];
local cdxe  = (_sw[`i'+1])-`dxe';
local adjustA  =  abs(_py[`i']) * `dxe'*0.5;
local adjustC =   _py[`i'+1] * (`cdxe')*0.5;
};
local Aee =`A' + `adjustA';
local ginie=`gini'/(1+2*abs(`A'));
return scalar ginie   = `ginie';
local giniee=`gini'/(1+2*abs(`Aee'));
return scalar giniee   = `giniee';
return scalar A   = abs(`A');
return scalar Aee   = abs(`Aee');
local Bee=(0.5+`Aee')*`giniee'-`Aee';
local Cee=0.5-`Bee';
return scalar Bee   = `Bee';
return scalar Cee   = `Cee';
end;



set more off;
#delim ;
cap program drop ctr;
program define ctr, rclass;
version 8.0;
syntax varlist(min=1 max=1) [, HWeight(string) HSize(string)  ];
preserve;
qui tokenize `varlist';
#delim cr
tempvar pw hs fw 
gen `pw'=1 
gen `hs'=1
if ("`hweight'" != "") qui replace `pw' = `hweight'
if ("`hsize'"   != "") qui replace `hs' = `hsize'
qui gen `fw'=`pw'*`hs'
sort `1'
sgini `fw' `1' 
set more off
      disp in green _newline "{hline 50}"
      disp in white "     "_col(15)" GINI_CTR_Index"
      disp in white "     "_col(15)" By: Araar Abdelkrim"   
      disp in green "{hline 50}" 
      disp in white " Estimated    Gini         :" _col(25) in yellow %16.6f `r(gini)'
      disp in white " Estimated    Gini_e       :" _col(25) in yellow %16.6f `r(ginie)'
      disp in white " Estimated    Gini_ee      :" _col(25) in yellow %16.6f `r(giniee)'
      disp in white " Estimated    A_e          :" _col(25) in yellow %16.6f `r(A)'
      disp in white " Estimated    A_ee         :" _col(25) in yellow %16.6f `r(Aee)'
      disp in white " Estimated    B_ee         :" _col(25) in yellow %16.6f `r(Bee)'
      disp in white " Estimated    C_ee         :" _col(25) in yellow %16.6f `r(Cee)'
      disp in green  "{hline 50}"
restore
end 

