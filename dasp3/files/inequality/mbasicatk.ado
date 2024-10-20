

#delimit ;


#delimit ;
capture program drop mbasicatk;
program define mbasicatk, eclass;
syntax varlist(min=1 ) [, HSize(varname) epsilon(real 0.5) HGROUP(varname) XRNAMES(string)];
                    local popa = 0;
if "`hgroup'" == "" local popa = 1;


tempvar hsize; qui g `hsize' = 1;

if "`hgroup'" == "" {;
tempvar hgroup; qui g `hgroup' = 1;
};

tokenize `varlist';
local nvars = $indica ;
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
if ( `epsilon' != 1.0 ) {;
tempvar vec_a vec_b vec_c  ;
gen  double   `vec_a' = `hsize'*`1'^(1-`epsilon');    
gen  double   `vec_b' = `hsize';           
gen  double   `vec_c' = `hsize'*`1';   
};
if ( `epsilon' ==  1) {;
tempvar vec_a vec_b vec_c  ;
gen   double    `vec_a' = `hsize'*log(`1');    
gen   double    `vec_b' = `hsize';           
gen   double    `vec_c' = `hsize'*`1';  
};

qui levelsof `hgroup', local(vgr);
local zz = wordcount("`vgr'");
matrix __ms = J(2,`zz', 0);
local pos = 1 ;
foreach x of local vgr {;
preserve;
qui keep  if `hgroup' == `x' ;
qui svy: mean `vec_a' `vec_b' `vec_c'  ;
if ( `epsilon' != 1.0)   qui nlcom  1 - _b[`vec_a'] ^(1/(1-`epsilon'))*_b[`vec_b']^(1+(1/(`epsilon'-1)))/_b[`vec_c'] , iterate(5000);
if ( `epsilon' == 1.0 )  qui nlcom  1- exp(_b[`vec_a']/_b[`vec_b'])*(_b[`vec_b']/_b[`vec_c'])                        , iterate(5000);
matrix __ms[1,`pos'] =  el(r(b),1,1);
matrix __ms[2,`pos'] =  el(r(V),1,1)^0.5;
local pos = `pos' + 1;
restore; 
};
};

if (`popa' ==1) {;
tempvar vec_a vec_b vec_c  ;
local nvars = wordcount("`varlist'");
matrix __ms = J(2,`nvars',0);
forvalues i = 1/`nvars' {;
cap drop  `vec_a'  ;
cap drop  `vec_b'  ;
cap drop  `vec_c'  ;
gen  double   `vec_a' = `hsize'*``i''^(1-`epsilon');    
gen  double   `vec_b' = `hsize';           
gen  double   `vec_c' = `hsize'*``i'';   

qui svy: mean `vec_a' `vec_b' `vec_c'  ;
if ( `epsilon' != 1.0)   qui nlcom  1 - _b[`vec_a'] ^(1/(1-`epsilon'))*_b[`vec_b']^(1+(1/(`epsilon'-1)))/_b[`vec_c'] , iterate(50000);
if ( `epsilon' == 1.0 )  qui nlcom  1- exp(_b[`vec_a']/_b[`vec_b'])*(_b[`vec_b']/_b[`vec_c'])                        , iterate(50000);
matrix __ms[1,`i'] =  el(r(b),1,1);
matrix __ms[2,`i'] =  el(r(V),1,1)^0.5;
};
};

                 matrix __ms = __ms ;
ereturn matrix  mmss = __ms ;

end;