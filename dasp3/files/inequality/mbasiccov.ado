

#delimit ;
capture program drop mbasiccov;
program define mbasiccov, eclass;
syntax varlist(min=1 ) [, HSize(varname)  HGROUP(varname) XRNAMES(string)];

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

tempvar vec_a vec_b vec_c;

gen  double `vec_a' = `hsize'*`1'^2;    
gen  double `vec_b' = `hsize';           
gen  double `vec_c' = `hsize'*`1';     


if ("`hgroup'" ~="") {;
qui levelsof `hgroup', local(vgr);
local zz = wordcount("`vgr'");
matrix __ms = J(2,`zz',0);
local pos = 1 ;
foreach x of local vgr {;
preserve;
qui keep  if `hgroup' == `x' ;
qui svy: mean `vec_a' `vec_b' `vec_c'  ;
qui nlcom   (_b[`vec_a']*_b[`vec_b']/_b[`vec_c']^2-1)^0.5 , iterate(50000);            
matrix __ms[1,`pos'] =  el(r(b),1,1);
matrix __ms[2,`pos'] =  el(r(V),1,1)^0.5;
local pos = `pos' + 1;
restore; 
};

};

};


if (`popa' == 1) {;
tempvar vec_a vec_b vec_c;
tempvar vec_a vec_b vec_c;
local nvars = wordcount("`varlist'");
matrix __ms = J(2,`nvars',0);
forvalues i = 1/`nvars' {;
cap drop  `vec_a'  ;
cap drop  `vec_b'  ;
cap drop  `vec_c'  ;

gen  double `vec_a' = `hsize'*``i''^2;    
gen  double `vec_b' = `hsize';           
gen  double `vec_c' = `hsize'*``i'';     
qui svy: mean `vec_a' `vec_b' `vec_c'  ;
qui nlcom   (_b[`vec_a']*_b[`vec_b']/_b[`vec_c']^2-1)^0.5 , iterate(50000);     
matrix __ms[1,`i']  =  el(r(b),1,1);
matrix __ms[2,`i']  =  el(r(V),1,1)^0.5;
};


	
};




   matrix __ms = __ms ;
ereturn matrix  mmss = __ms ;
end;