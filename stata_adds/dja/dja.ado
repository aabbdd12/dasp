#delim ;
cap program drop agini;
program define agini, rclass;
syntax varlist(min=1 max=1) [, FW(varname)  RAnk(varname) RHO(real 2.0) EPS(real 0.5)];
version 8.0;
tokenize `varlist';
qui {;
preserve;
if ("`rank'"=="")        gsort -`1';
if ("`rank'"~="")        gsort -`rank';
cap drop if `1' >=. ; 
cap drop if `fw'>=. ;
gen vr = sum(`fw')^`rho'; gen p = vr  - vr[_n-1];
replace p = vr[1] in 1; replace p = p / vr[_N];

if (`eps' != 1) gen _inca = `1'^(1 - `eps');
if (`eps' == 1) gen _inca = log(`1');
gen  xi = sum(p*_inca);   local xi = xi[_N];
if (`eps' != 1) local xi = `xi'^(1/(1-`eps'));
if (`eps' == 1) local xi = exp(`xi');
sum `1' [aw=`fw']; local mu = `r(mean)';
local gini = 1-`xi'/`mu';
list p; 
restore;  
};
return scalar gini = `gini';
return scalar mu   = `mu'  ;
end;


cap program drop opth;                    
program define opth, rclass; 
preserve;             
args fw x;                       
qui su `x' [aw=`fw'], detail;            
local tmp = (`r(p75)'-`r(p25)')/1.34;                           
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)';     
local h   = 0.9*`tmp'*_N^(-1.0/5.0);                            
return scalar h =  `h'; 
restore; 
end;


capture program drop lle2;
program define lle2, rclass;
version 8.0;
syntax varlist(min=2 max=2) [, HWeight(string)  hh(string) band(string) ];
tokenize `varlist';
tempvar fw;
gen `fw'=1;
if ("`hweight'"~="")     replace `fw'=`fw'*`hweight';
qui count;
qui sum `1';
cap drop _ey;
gen _ey = 0;
opth `fw' `1';
local oph = `r(h)';
if ("`band'"~="") local oph = `band';
qui count;
dis "WAIT";


tempvar  _npe  _t1 _t2  _kt5 _vy _vx _vx2 _vx3 _vx4;
cap drop `_npe' ;
qui gen `_npe' = 0;
qui count;    
local nobs= `r(N)';              
forvalues j=1/`r(N)' {;

cap drop `_kt5' `_vy' `_vx' `_vx2';
qui gen `_kt5' = (exp(-0.5* ( ((`1'[`j']-`1')/`oph')^2  )  )   )^0.5;
qui gen `_vy'=`_kt5'*`2';
qui gen `_vx'=`_kt5'*(`1'-`1'[`j']);
qui gen `_vx2'=0.5*`_kt5'*(`1'-`1'[`j'])^2;
qui regress `_vy'  `_kt5' `_vx' `_vx2'  [aw = `fw'], noconstant;
cap matrix drop _cc;
matrix _cc = e(b);
qui replace `_npe'  = el(_cc,1,1) in `j';
if (`j'/100==round(`j'/100)) dis " "  %6.0f `j' " obs treated among the "  %6.0f `nobs' "obs." ;
cap drop _ey;
gen _ey = `_npe';
};
end;


cap program drop dja;
program define dja, rclass;
syntax varlist(min=2 max=2) [, HWeight(varname) HSize(varname) HGroup(varname) NGroup(string) RHO(real 2.0) EPS(real 0.5) BAND(string)];
version 8.0;
tokenize `varlist';
qui {;
preserve;
drop if `1'==.;
drop if `2'==.;
cap drop _fw;
qui gen _fw=1;
if ("`hsize'"  ~="")     replace _fw=_fw*`hsize';
if ("`hweight'"~="")     replace _fw=_fw*`hweight';
if ("`hgroup'"~="")      replace _fw=_fw*(`hgroup'==`ngroup');

agini `1', fw(_fw) rho(`rho') eps(`eps');
local I_X=`r(gini)';
agini `2', fw(_fw) rho(`rho') eps(`eps');
local I_N=`r(gini)';

};

lle2 `1' `2', hw(_fw) band(`band');
agini _ey , fw(_fw) rho(`rho') eps(`eps') rank(`1');
local I_NE=`r(gini)';

agini `2', fw(_fw) rho(`rho') eps(`eps') rank(`1');
local I_NP=`r(gini)';



qui gen I_X = `I_X';
qui gen I_N = `I_N';
qui gen I_NP = `I_NP';
qui gen I_NE = `I_NE';


local RE=`I_X'-`I_N';
local V =`I_X'-`I_NE';
local H =`I_NP'-`I_NE';
local R =`I_N'-`I_NP';

return scalar re= `RE' ;
return scalar v= `V' ;
return scalar h= `H' ;
return scalar r= `R' ;

qui gen RE = `RE';
qui gen V  = `V';
qui gen H  = `H';
qui gen R  = `R';


      disp in green  "{hline 50}";
      disp in white "        DJA Decomposition  " ;  
      disp in green  "{hline 50}";
format  I_X-R %8.6f;
list I_X I_N I_NP I_NE in 1/1, noobs  ; 
list RE V H R in 1/1 , noobs ; 
cap drop I_X I_N I_NP RE V H R ;
return scalar re= `RE' ;

end;


