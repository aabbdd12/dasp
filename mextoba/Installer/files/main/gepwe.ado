# delimit ;
capture program drop gepwe;
program define gepwe, rclass sortpreserve;
version 9.2;
syntax varlist(min=1) [fw aw pw] [,  CBAND1(real 0.9) BAND1(real 0) BAND2(real 0) PER1(real 0.1) PER2(real 0.2) nper(int 1) ];

local vw=subinstr("`exp'","=","",1);
tempvar fw pc;
qui gen `fw' = 1;
if "`vw'"~="" replace `fw' = `vw' ;
tokenize `varlist';
sort `1';
qui gen `pc' = sum(`fw');
qui replace `pc'=`pc'/`pc'[_N];

dis `nper';
forvalues i=1/`nper' {;
qui su `pc' , detail     ;       
local tmp    = (`r(p75)'-`r(p25)')/1.34    ;                       
local tmp    = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)'  ; 
if  `band`i'' == 0 local band`i'   =     `cband1'*`tmp'*_N^(-1.0/5.0);

tempvar ww`i' ;
qui count;
qui gen `ww`i''   = (exp(-0.5* ( ((`pc'-`per`i'')/`band`i'')^2  )  )   )^0.5 / ( `band`i''* sqrt(2*c(pi)) * `r(N)' ) ;
};
cap drop _pcw;
qui gen _pcw = `ww1';
if `nper' == 2  {;
qui sum `ww1' ;
local m1=r(max);
qui sum `ww2' ;
local m2=r(max);
qui replace _pcw = `ww2' if  `pc' >= `per2';
qui replace _pcw = `m1'+((`m2'-`m1')/(`per2'-`per1'))*(`pc'-`per1') if  `pc' >= `per1' & `pc' < `per2';
};

qui sum _pcw [aw=`fw'];
*line _pcw  `pc';
  
end;


