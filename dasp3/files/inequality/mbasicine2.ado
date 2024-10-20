

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



cap program drop inineq2d;  
program define inineq2d, rclass ;    
version 9.2;         
syntax varlist (min=2 max=2) [, HSize1(varname)  HSize2(varname) HWeight(varname) HGroup(varname) 
p1(real 0.1) p2(real 0.2) p3(real 0.8) p4(real 0.9) index(string)  
GNumber(int -1)];
preserve;
tokenize `varlist';
                     qui drop if `1'>=. ;
					 qui drop if `2'>=. ;
if ("`hsize1'"!="")   qui drop if `hsize1'>=.;
if ("`hsize2'"!="")   qui drop if `hsize2'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;
tempvar  hs1 sw1 fw1   hs2 sw2 fw2 ;
gen `sw1'=1;
gen `hs1'=1;

gen `sw2'=1;
gen `hs2'=1;

if ("`hsize1'"!="")     qui replace `hs1' = `hsize1';
if ("`hsize2'"!="")     qui replace `hs2' = `hsize2';
tempvar _in;
if ("`hgroup'" != "")  qui gen    `_in' = (`hgroup' == `gnumber');
if ("`hgroup'" != "")  qui replace `hs1' = `hs1' * `_in';
if ("`hgroup'" != "")  qui replace `hs2' = `hs2' * `_in';
if ("`hweight'"!="")   qui replace `sw1'=`hweight';
if ("`hweight'"!="")   qui replace `sw2'=`hweight';


local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
tempvar fw1 fw2;
gen `fw1'=`hs1';
if (`"`hweight'"'~="") qui replace `fw1'=`fw1'*`hweight';
gen `fw2'=`hs2';
if (`"`hweight'"'~="") qui replace `fw2'=`fw2'*`hweight';

tempvar vec_a vec_b  vec_c vec_d ;

if ( "`index'"=="qr") {;
inineq_qua `fw1' `1' `p1';
local q11=`r(qnt)';
inineq_qua `fw1' `1' `p2';
local q21=`r(qnt)';
local est1 = `q11'/`q21';
inineq_den `fw1' `1' `q1';
local fq11=`r(den)';
inineq_den `fw1' `1' `q2';
local fq21=`r(den)';

inineq_qua `fw2' `2' `p1';
local q12=`r(qnt)';
inineq_qua `fw2' `2' `p2';
local q22=`r(qnt)';
local est2 = `q12'/`q22';
inineq_den `fw2' `2' `q1';
local fq12=`r(den)';
inineq_den `fw2' `2' `q2';
local fq22=`r(den)';

local dif = `est2' - `est1' ;

gen `vec_a' = -`hs1'*((`q11'>`1')-`p1')/`fq11' + `hs1'*`q11';
gen `vec_b' = -`hs1'*((`q21'>`1')-`p2')/`fq21' + `hs1'*`q21';

gen `vec_c' = -`hs2'*((`q12'>`2')-`p1')/`fq12' + `hs2'*`q12';
gen `vec_d' = -`hs2'*((`q22'>`2')-`p2')/`fq22' + `hs2'*`q22';

qui svy: mean  `vec_a' `vec_b' `vec_c' `vec_d';

qui nlcom   (_b[`vec_a']/_b[`vec_b']) , iterate(50000);
local ste1 =  el(r(V),1,1)^0.5;
qui nlcom   (_b[`vec_c']/_b[`vec_d']) , iterate(50000);
local ste2 =  el(r(V),1,1)^0.5;
qui nlcom   (_b[`vec_c']/_b[`vec_d']) - (_b[`vec_a']/_b[`vec_b']) , iterate(50000);
local sdif =  el(r(V),1,1)^0.5;
};



if ( "`index'"=="sr") {;

inineq_qua `fw1' `1' `p1';
local q11=`r(qnt)'; local g11=`r(glor)';
inineq_qua `fw1' `1' `p2';
local q21=`r(qnt)'; local g21=`r(glor)';
inineq_qua `fw1' `1' `p3';
local q31=`r(qnt)'; local g31=`r(glor)';
inineq_qua `fw1' `1' `p4';
local q41=`r(qnt)'; local g41=`r(glor)';

inineq_qua `fw2' `2' `p1';
local q12=`r(qnt)'; local g12=`r(glor)';
inineq_qua `fw2' `2' `p2';
local q22=`r(qnt)'; local g22=`r(glor)';
inineq_qua `fw2' `2' `p3';
local q32=`r(qnt)'; local g32=`r(glor)';
inineq_qua `fw2' `2' `p4';
local q42=`r(qnt)'; local g42=`r(glor)';

local est1 = (`g21'-`g11')/(`g41'-`g31');
local est2 = (`g22'-`g12')/(`g42'-`g32');
local dif = `est2' - `est1' ;

gen `vec_a' = `hs1'*(`q21'*`p2'+(`1'-`q21')*(`q21'>`1')) - `hs1'*(`q11'*`p1'+(`1'-`q11')*(`q11'>`1')) ;
gen `vec_b' = `hs1'*(`q41'*`p4'+(`1'-`q41')*(`q41'>`1')) - `hs1'*(`q31'*`p3'+(`1'-`q31')*(`q31'>`1')) ;

gen `vec_c' = `hs2'*(`q22'*`p2'+(`2'-`q22')*(`q22'>`2')) - `hs2'*(`q12'*`p1'+(`2'-`q12')*(`q12'>`2')) ;
gen `vec_d' = `hs2'*(`q42'*`p4'+(`2'-`q42')*(`q42'>`2')) - `hs2'*(`q32'*`p3'+(`2'-`q32')*(`q32'>`2')) ;

qui svy: mean  `vec_a' `vec_b' `vec_c' `vec_d';
qui nlcom   (_b[`vec_a']/_b[`vec_b']) , iterate(50000);
local ste1 =  el(r(V),1,1)^0.5;
qui nlcom   (_b[`vec_c']/_b[`vec_d']) , iterate(50000);
local ste2 =  el(r(V),1,1)^0.5;
qui nlcom   (_b[`vec_c']/_b[`vec_d']) -(_b[`vec_a']/_b[`vec_b']) , iterate(50000);
local sdif =  el(r(V),1,1)^0.5;


};






return scalar est1  = `est1';
return scalar ste1  = `ste1';
return scalar est2  = `est2';
return scalar ste2  = `ste2';
return scalar dif   = `dif';
return scalar sdif  = `sdif';

end;     



#delimit ;
capture program drop mbasicine2;
program define mbasicine2, eclass;
syntax varlist(min=2 max=2) [, HSize1(varname) HSize2(varname)  Hweight(varname) p1(real 0.1) p2(real 0.2) p3(real 0.8) p4(real 0.9) index(string)  HGROUP(varname) XRNAMES(string)];

tokenize `varlist';
tempvar fw1 fw2;
version 15.0;
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
qui gen `fw1'=`hsize1';
qui gen `fw2'=`hsize2';
if ("`hweight'"~="")    qui replace `fw1'=`fw1'*`hweight';
if ("`hweight'"~="")    qui replace `fw2'=`fw2'*`hweight';


/************/

if ("`hgroup'" =="") {;
matrix __ms = J(1,6,0);
qui inineq2d `varlist' ,   hweight(`hweight') hsize1(`hsize1') hsize2(`hsize2')  p1(`p1') p2(`p2') p3(`p3') p4(`p4') index(`index')  ;
matrix __ms[1,1] =  r(est1);
matrix __ms[1,2] =  r(ste1);
matrix __ms[1,3] =  r(est2);
matrix __ms[1,4] =  r(ste3);
matrix __ms[1,5] =  r(dif);
matrix __ms[1,6] =  r(sdif);
};

if ("`hgroup'" ~="") {;
qui levelsof `hgroup', local(vgr);
local zz = wordcount("`vgr'");
matrix __ms = J(`zz',6,0);
local pos = 1 ;
foreach x of local vgr {;
preserve;
qui keep  if `hgroup' == `x' ;
qui inineq2d `varlist' ,   hweight(`hweight') hsize1(`hsize1') hsize2(`hsize2')  p1(`p1') p2(`p2') p3(`p3') p4(`p4') index(`index')  ;
matrix __ms[`pos',1] =  r(est1);
matrix __ms[`pos',2] =  r(ste1);
matrix __ms[`pos',3] =  r(est2);
matrix __ms[`pos',4] =  r(ste3);
matrix __ms[`pos',5] =  r(dif);
matrix __ms[`pos',6] =  r(sdif);             
local pos = `pos' + 1;
restore; 
};


	
};

matrix __msp = __ms' ;
ereturn matrix __ms = __ms ;
ereturn matrix mmss = __msp ;
end;