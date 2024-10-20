

#delimit ;
capture program drop mbasicatk2;
program define mbasicatk2, eclass;
syntax varlist(min=2 max=2 ) [, HSize1(varname) HSize2(varname) epsilon(real 0.5) HGROUP(varname) conf(real 5)  LEVEL(real 95) XRNAMES(string) ];

tokenize `varlist';




/************/


if ( `epsilon' != 1.0 ) {;
tempvar vec_a vec_b vec_c vec_d vec_e vec_f   ;
gen  double   `vec_a' = `hsize1'*`1'^(1-`epsilon');    
gen  double   `vec_b' = `hsize1';           
gen  double   `vec_c' = `hsize1'*`1';   
gen  double   `vec_d' = `hsize2'*`2'^(1-`epsilon');    
gen  double   `vec_e' = `hsize2';           
gen  double   `vec_f' = `hsize2'*`2';   
};
if ( `epsilon' ==  1) {;
tempvar vec_a vec_b vec_c vec_d vec_e vec_f   ;
gen   double    `vec_a' = `hsize1'*log(`1');    
gen   double    `vec_b' = `hsize1';           
gen   double    `vec_c' = `hsize1'*`1';  
gen   double    `vec_d' = `hsize2'*log(`2');    
gen   double    `vec_e' = `hsize2';           
gen   double    `vec_f' = `hsize2'*`2'; 

};

if ("`hgroup'" =="") {;
matrix __ms = J(1,6,0);
qui svy: mean `vec_a' `vec_b' `vec_c'  `vec_d' `vec_e' `vec_f' ;
if ( `epsilon' != 1.0)   qui nlcom  1 - _b[`vec_a'] ^(1/(1-`epsilon'))*_b[`vec_b']^(1+(1/(`epsilon'-1)))/_b[`vec_c'] , iterate(50000);
if ( `epsilon' == 1.0 )  qui nlcom  1- exp(_b[`vec_a']/_b[`vec_b'])*(_b[`vec_b']/_b[`vec_c'])                        , iterate(50000);
matrix __ms[1,1] =  el(r(b),1,1);
matrix __ms[1,2] =  el(r(V),1,1)^0.5;
if ( `epsilon' != 1.0)   qui nlcom  1 - _b[`vec_d'] ^(1/(1-`epsilon'))*_b[`vec_e']^(1+(1/(`epsilon'-1)))/_b[`vec_f'] , iterate(50000);
if ( `epsilon' == 1.0 )  qui nlcom  1- exp(_b[`vec_d']/_b[`vec_e'])*(_b[`vec_e']/_b[`vec_f'])                        , iterate(50000);
matrix __ms[1,3] =  el(r(b),1,1);
matrix __ms[1,4] =  el(r(V),1,1)^0.5;
if ( `epsilon' != 1.0)   qui nlcom  1 - _b[`vec_a'] ^(1/(1-`epsilon'))*_b[`vec_b']^(1+(1/(`epsilon'-1)))/_b[`vec_c'] 
-  (1 - _b[`vec_d'] ^(1/(1-`epsilon'))*_b[`vec_e']^(1+(1/(`epsilon'-1)))/_b[`vec_f'] ) , iterate(50000);
if ( `epsilon' == 1.0 )  qui nlcom  1- exp(_b[`vec_a']/_b[`vec_b'])*(_b[`vec_b']/_b[`vec_c'])      
 -  ( 1- exp(_b[`vec_d']/_b[`vec_e'])*(_b[`vec_e']/_b[`vec_f'])  ), iterate(50000);
matrix __ms[1,5] =  el(r(b),1,1);
matrix __ms[1,6] =  el(r(V),1,1)^0.5;


};

if ("`hgroup'" ~="") {;
qui levelsof `hgroup', local(vgr);
local zz = wordcount("`vgr'");
matrix __ms = J(`zz',6,0);
local pos = 1 ;
foreach x of local vgr {;
preserve;
qui keep  if `hgroup' == `x' ;
qui svy: mean `vec_a' `vec_b' `vec_c'  `vec_d' `vec_e' `vec_f' ;
if ( `epsilon' != 1.0)   qui nlcom  1 - _b[`vec_a'] ^(1/(1-`epsilon'))*_b[`vec_b']^(1+(1/(`epsilon'-1)))/_b[`vec_c'] , iterate(5000);
if ( `epsilon' == 1.0 )  qui nlcom  1- exp(_b[`vec_a']/_b[`vec_b'])*(_b[`vec_b']/_b[`vec_c'])                        , iterate(5000);
matrix __ms[`pos',1] =  el(r(b),1,1);
matrix __ms[`pos',2] =  el(r(V),1,1)^0.5;
if ( `epsilon' != 1.0)   qui nlcom  1 - _b[`vec_d'] ^(1/(1-`epsilon'))*_b[`vec_e']^(1+(1/(`epsilon'-1)))/_b[`vec_f'] , iterate(50000);
if ( `epsilon' == 1.0 )  qui nlcom  1- exp(_b[`vec_d']/_b[`vec_e'])*(_b[`vec_e']/_b[`vec_f'])                        , iterate(50000);
matrix __ms[`pos',3] =  el(r(b),1,1);
matrix __ms[`pos',4] =  el(r(V),1,1)^0.5;
if ( `epsilon' != 1.0)   qui nlcom      (1 - _b[`vec_d'] ^(1/(1-`epsilon'))*_b[`vec_e']^(1+(1/(`epsilon'-1)))/_b[`vec_f'] )  - (1 - _b[`vec_a'] ^(1/(1-`epsilon'))*_b[`vec_b']^(1+(1/(`epsilon'-1)))/_b[`vec_c']), iterate(50000);
if ( `epsilon' == 1.0 )  qui nlcom    (1- exp(_b[`vec_d']/_b[`vec_e'])*(_b[`vec_e']/_b[`vec_f']))  -  (1- exp(_b[`vec_a']/_b[`vec_b'])*(_b[`vec_b']/_b[`vec_c'])) , iterate(50000);
matrix __ms[`pos',5] =  el(r(b),1,1);
matrix __ms[`pos',6] =  el(r(V),1,1)^0.5;
local pos = `pos' + 1;
restore; 
};
};
matrix __ms = __ms' ;
ereturn matrix mmss = __ms ;
end;
