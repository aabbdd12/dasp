

#delim ;


/*****************************************************/
/* Density function      : fw=Hweight*Hsize      */
/*****************************************************/
cap program drop inineq_den;                    
program define inineq_den, rclass;              
args fw x xval;                         
qui su `x' [aw=`fw'], detail;           
local tmp = (`r(p75)'-`r(p25)')/1.34;                          
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
local h   = 0.9*`tmp'*_N^(-1.0/5.0);                            
tempvar s1 s2;                                                  
gen `s1' = sum( `fw' *exp(-0.5* ( ((`xval'-`x')/`h')^2  )  ));  
gen `s2' = sum( `fw' );
return scalar den = `s1'[_N]/( `h'* sqrt(2*c(pi)) * `s2'[_N] );  
end;


/***************************************/
/* Quantile  & GLorenz                 */
/***************************************/
cap program drop inineq_qua;
program define inineq_qua, rclass sortpreserve;
args fw yyy xval order;
preserve;
sort `yyy', stable;
qui cap drop if `yyy'>=. | `fw'>=.;
tempvar ww qp glp pc;
qui gen `ww'=sum(`fw');
qui gen `pc'=`ww'/`ww'[_N];
qui gen `qp' = `yyy' ;
qui gen `glp' double = sum(`fw'*`yyy')/`ww'[_N];
qui sum `yyy' [aw=`fw'];
local i=1;
while (`pc'[`i'] < `xval') {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) {;
local qnt =`qp'[`ar'] +((`qp'[`i'] -`qp'[`ar']) /(`pc'[`i']-`pc'[`ar']))*(`pc'[`i']-`pc'[`ar']);
local glor=`glp'[`ar']+((`glp'[`i']-`glp'[`ar'])/(`pc'[`i']-`pc'[`ar']))*(`pc'[`i']-`pc'[`ar']);
};
if (`i'==1) {;
local qnt =(max(0,`qp'[`i'])/(`pc'[`i']))*(`pc'[`i']);
local glor=(max(0,`glp'[`i'])/(`pc'[`i']))*(`pc'[`i']);
};

return scalar qnt  = `qnt';
return scalar glor = `glor';
restore;
end;



cap program drop inineq2;  
program define inineq2, rclass ;    
version 9.2;         
syntax varlist (min=1 max=1) [, HSize(varname) HWeight(varname) HGroup(varname) 
p1(real 0.1) p2(real 0.2) p3(real 0.8) p4(real 0.9) index(string)  
GNumber(int -1)];
preserve;
tokenize `varlist';
                     qui drop if `1'>=. ;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;
tempvar  hs sw fw ;
gen `sw'=1;
gen `hs'=1;

if ("`hsize'"!="")     qui replace `hs' = `hsize';
tempvar _in;
if ("`hgroup'" != "")  qui gen    `_in' = (`hgroup' == `gnumber');
if ("`hgroup'" != "")  qui replace `hs' = `hs' * `_in';
if ("`hweight'"!="")   qui replace `sw'=`hweight';


local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
tempvar fw;
gen `fw'=`hs';
if (`"`hweight'"'~="") qui replace `fw'=`fw'*`hweight';

tempvar vec_a vec_b;

if ( "`index'"=="qr") {;
inineq_qua `fw' `1' `p1';
local q1=`r(qnt)';
inineq_qua `fw' `1' `p2';
local q2=`r(qnt)';
local est = `q1'/`q2';
inineq_den `fw' `1' `q1';
local fq1=`r(den)';
inineq_den `fw' `1' `q2';
local fq2=`r(den)';
gen `vec_a' = -`hs'*((`q1'>`1')-`p1')/`fq1' + `hs'*`q1';
gen `vec_b' = -`hs'*((`q2'>`1')-`p2')/`fq2' + `hs'*`q2';
qui svy: ratio `vec_a'/`vec_b';
cap drop matrix _vv;
matrix _vv=e(V);
local ste = el(_vv,1,1)^0.5;
};



if ( "`index'"=="sr") {;

inineq_qua `fw' `1' `p1';
local q1=`r(qnt)'; local g1=`r(glor)';
inineq_qua `fw' `1' `p2';
local q2=`r(qnt)'; local g2=`r(glor)';
inineq_qua `fw' `1' `p3';
local q3=`r(qnt)'; local g3=`r(glor)';
inineq_qua `fw' `1' `p4';
local q4=`r(qnt)'; local g4=`r(glor)';

local est = (`g2'-`g1')/(`g4'-`g3');

gen `vec_a' = `hs'*(`q2'*`p2'+(`1'-`q2')*(`q2'>`1')) - `hs'*(`q1'*`p1'+(`1'-`q1')*(`q1'>`1')) ;
gen `vec_b' = `hs'*(`q4'*`p4'+(`1'-`q4')*(`q4'>`1')) - `hs'*(`q3'*`p3'+(`1'-`q3')*(`q3'>`1')) ;;
qui svy: ratio `vec_a'/`vec_b';
cap drop matrix _vv;
matrix _vv=e(V);
local ste = el(_vv,1,1)^0.5;


};






return scalar est  = `est';
return scalar ste  = `ste';




end;     



#delimit ;
capture program drop mbasicine;
program define mbasicine, eclass;
syntax varlist(min=1 ) [, HSize(varname) Hweight(varname) p1(real 0.1) p2(real 0.2) p3(real 0.8) p4(real 0.9) index(string)  HGROUP(varname) XRNAMES(string)];

tokenize `varlist';
                    local popa = 0;
if "`hgroup'" == "" local popa = 1;

tempvar fw;
version 15.0;
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
qui gen `fw'=`hsize';
if ("`hweight'"~="")    qui replace `fw'=`fw'*`hweight';



/************/
if (`popa' == 0) {;
if ("`hgroup'" ~="") {;
qui levelsof `hgroup', local(vgr);
local zz = wordcount("`vgr'");
matrix __ms = J(2,`zz',0);
local pos = 1 ;
foreach x of local vgr {;
preserve;
qui keep  if `hgroup' == `x' ;
qui inineq2 `1' ,   hweight(`hweight') hsize(`hsize')  p1(`p1') p2(`p2') p3(`p3') p4(`p4') index(`index') ;              
matrix __ms[1,`pos'] = r(est);
matrix __ms[2,`pos'] = r(ste);
local pos = `pos' + 1;
restore; 
};	
};
};

if (`popa' == 1) {;
local nvars = wordcount("`varlist'");
matrix __ms = J(2,`nvars',0);
forvalues i = 1/`nvars' {;
qui inineq2 ``i'' ,   hweight(`hweight') hsize(`hsize')  p1(`p1') p2(`p2') p3(`p3') p4(`p4') index(`index') ;              
matrix __ms[1,`i'] = r(est);
matrix __ms[2,`i'] = r(ste);
};
};


   matrix __ms = __ms ;
ereturn matrix  mmss = __ms ;
end;