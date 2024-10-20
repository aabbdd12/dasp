#delimit ;

capture program drop _difpov;
program define _difpov, rclass;
syntax varlist(min=2 max=2) [, HSize(varname)  PLINE(varname)  ALpha(real 0) ];
preserve; 
tokenize `varlist';
tempvar we ga0 ga10 ga1 hy;
gen `hy' = `1';


local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
qui gen `we'=1;
if ("`hweight'"~="")    qui replace `we'=`we'*`hweight';


gen `ga0' = 0;
gen `ga10' = 0;
gen `ga1' = 0;


if (`alpha'==0) qui replace `ga0' = `hsize'*(`pline'>`1');
if (`alpha'~=0) qui replace `ga0' = `hsize'*((`pline'-`1')/`pline')^`alpha' if (`pline'>`1');


if (`alpha'==0) qui replace `ga1' = `hsize'*(`pline'>`2');
if (`alpha'~=0) qui replace `ga1' = `hsize'*((`pline'-`2')/`pline')^`alpha' if (`pline'>`2');



qui replace `ga10' = `ga1'-`ga0';


qui sum `hsize' [aweight= `we'];
local denom = r(mean);

qui sum `ga1' [aweight= `we'];
local fgt1 = r(mean)/`denom';


qui svydes;
local fr=`r(N_units)'-`r(N_strata)';

qui svy: ratio `ga10' / `hsize';
cap drop matrix _aa;
matrix _aa=e(b);
local est10 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local ste10 = el(_vv,1,1)^0.5;
return scalar est10 = `est10'*100;
return scalar ste10 = `ste10'*100;
local tval = `est10'/`ste10';
return scalar  tval = `tval';
local pval = 1-2*(normal(abs(`tval'))-0.5);
if `ste10'==0 local pval = 0; 
return scalar pval10 = `pval';


qui svy: ratio `ga0' / `hsize';
cap drop matrix _aa;
matrix _aa=e(b);
local est0 = el(_aa,1,1);
return scalar fgt0 = `est0'*100;
cap drop matrix _vv;
matrix _vv=e(V);
local ste0 = el(_vv,1,1)^0.5;
return scalar ste0 = `ste0'*100;

qui svy: ratio `ga1' / `hsize';
cap drop matrix _aa;
matrix _aa=e(b);
local est1 = el(_aa,1,1);
return scalar fgt1 = `est1'*100;
cap drop matrix _vv;
matrix _vv=e(V);
local ste1 = el(_vv,1,1)^0.5*100;
return scalar ste1 = `ste1'*100;


end;
