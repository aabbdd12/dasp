/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.2)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : imdpov                                                      */
/* 1- Chakravarty et al (1998)   		: eq(06) // Union              */
/* 2- Extended Watts             		: eq(08) // Union              */
/* 3- Extended FGT               		: eq(09) // Intersection       */
/* 4- Tsui (2002)                		: eq(10) // Intersection       */
/* 5- Intersection headcount index                                     */
/* 6- Union headcount index                                            */ 
/* 7- Bourguignon and Chakravarty (2003) 	: eq(14) //                    */  
/* 8- Alkire and Foster  (2007) 	            :  //                    */                                 
/*************************************************************************/



#delim ;

capture program drop imdpov2;
program define imdpov2, rclass sortpreserve;
version 9.2;
syntax varlist [,  HSize(string) HGroup(varname) GNumber(int -1)
nembarg(int 1) 
dec(int 3)
INDex(int 1) ALPHA(real 1) GAMMA(real 1) BETA(real 1) 
PL1(real 0)  PL2(real 0) PL3(real 0) PL4(real 0) PL5(real 0) PL6(real 0) PL7(real 0)  PL8(real 0) PL9(real 0) PL10(real 0) 
AL1(real 0)  AL2(real 0) AL3(real 0) AL4(real 0) AL5(real 0) AL6(real 0) AL7(real 0)  AL8(real 0) AL9(real 0) AL10(real 0)
A1(real 1)   A2(real 1)  A3(real 1)  A4(real 1)  A5(real 1)  A6(real 1) A7(real 1)   A8(real 1)  A9(real 1)  A10(real 1) 
B1(real 0)   B2(real 0)  B3(real 0)  B4(real 0)  B5(real 0)  B6(real 0) B7(real 0)   B8(real 0)  B9(real 0)  B10(real 0)  
CONF(string)
LEVEL(real 95) 
];


tokenize `varlist';
tempvar hs;
gen `hs' =`hsize';

if (`gnumber'!=-1)    qui replace `hs'  =`hs'*(`hgroup'==`gnumber');


tempvar num temp c1 c2;
if (`index'==1 | `index'==2 | `index'==6 | `index'==7  )   qui gen   `num' = 0;
if (`index'==3 | `index'==4 |`index'==5)   qui gen   `num' = 1.0;

forvalues i=1/`nembarg' {;
if (`index'==1){;
if (`alpha'==0)             qui replace    `num' = `num'+ `a`i''*(`pl`i''> ``i'');
if (`alpha'!=0)             qui replace    `num' = `num' + `a`i''*((`pl`i''-``i'')/`pl`i'')^`alpha'  if (`pl`i''>``i'');
};

if (`index'==2){;
                         qui replace      `num' = `num' + `a`i''*log(`pl`i''/min(``i'',`pl`i'')) ;
               };

if (`index'==3){;
if (`al`i''==0)           qui replace    `num' = `num'* (`pl`i''> ``i'');
if (`al`i''!=0)           qui replace    `num' = `num'* ((`pl`i''-``i'')/`pl`i'')^`al`i'' * (`pl`i''>``i'');
              };

if (`index'==4){;

if (`b`i''==0)            qui replace      `num' = `num'* (`pl`i''> ``i'');
if (`b`i''!=0)	        qui replace      `num' = `num'* ((`pl`i''/min(``i'',`pl`i''))^`b`i''  - 1) ;              
                };

if (`index'==5){;
                          qui replace      `num' = `num'* (`pl`i''> ``i'');              
               };

if (`index'==6){;         
                          cap drop    `temp';
                          qui gen     `temp'= (`pl`i''> ``i'');
                          qui replace `num' = max(`num',`temp');              
               };




};


if (`index'==7){;         
 cap drop `c1';
 cap drop `c2';
                          qui gen     `c1'= ((`pl1'-`1')/`pl1')^`gamma' * (`pl1'>`1');
				  qui gen     `c2'= ((`pl2'-`2')/`pl2')^`gamma' * (`pl2'>`2');
                          qui replace `num' = (`c1'+ `beta'^(`gamma'/`alpha')*`c2')^(`alpha'/`gamma');              
                };



qui replace `num' =`hs'*`num';

qui svy: ratio `num'/`hs';
cap drop matrix _aa;
matrix _aa=e(b);
local est = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std = el(_vv,1,1)^0.5;



qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');

return scalar est  = `est';
return scalar std  = `std';
return scalar lb   = `est' - `tt'*`std';
return scalar ub   = `est' + `tt'*`std';


end;

#delim ;

capture program drop imdpov_af;
program define imdpov_af, rclass sortpreserve;
version 9.2;
syntax varlist [,  HSize(string) HGroup(varname) GNumber(int -1)
nembarg(int 1) 
dec(int 3)
PL1(real 0)  PL2(real 0) PL3(real 0) PL4(real 0) PL5(real 0) PL6(real 0) PL7(real 0)  PL8(real 0) PL9(real 0) PL10(real 0) 

W1(real 1)   W2(real 1)  W3(real 1)  W4(real 1)  W5(real 1)  W6(real 1) W7(real 1)   W8(real 1)  W9(real 1)  W10(real 1)  

ALPHA(real 1)  DCUT(real 0.5) 
CONF(string)
LEVEL(real 95) 
];


tokenize `varlist';
tempvar hs;
gen `hs' =`hsize';
tempvar hsp;
gen `hsp'=`hsize';
if (`gnumber'!=-1)    qui replace `hs'  =`hs'*(`hgroup'==`gnumber');


tempvar num00 num0 num1 num2 pnum00 pnum0 pnum1 pnum2 indt0 indt1 indt2 indp  c1 c2;
qui gen   `num00'   = 0;
qui gen   `num0'   = 0;
qui gen   `num1'   = 0;
qui gen   `num2'   = 0;

qui gen   `pnum00'   = 0;
qui gen   `pnum0'    = 0;
qui gen   `pnum1'    = 0;
qui gen   `pnum2'    = 0;

qui gen   `indp'  = 0;
qui gen   `indt0' = 0;
qui gen   `indt1' = 0;
qui gen   `indt2' = 0;

local swat=0;
forvalues i=1/`nembarg' {;
local swat=`swat'+ `w`i'';
};

forvalues i=1/`nembarg' {;
local w`i'=`w`i''/`swat';

};



forvalues i=1/`nembarg' {;
qui replace    `indt0' = `indt0'+ `w`i''*(`pl`i''> ``i'');
qui replace    `indt1' = `indt1'+ `w`i''*((`pl`i''-``i'')/`pl`i'')^1  if (`pl`i''>``i'');
qui replace    `indt2' = `indt2'+ `w`i''*((`pl`i''-``i'')/`pl`i'')^2  if (`pl`i''>``i'');
};


qui replace    `indp' = (`indt0'>= `dcut'/`swat');

cap drop _poor;
gen _poor = `indp';

cap drop _priv;
gen _priv =  `indt0'*`swat';

if (`gnumber'==-1) {;
forvalues i=1/`nembarg' {;
tempvar pnum0`i' pnum1`i' pnum2`i';
qui gen        `pnum0`i'' = `w`i''*`hsp'*`indp'*(`pl`i''> ``i'');

qui gen        `pnum1`i'' = 0;
qui replace    `pnum1`i'' = `w`i''*`hsp'*`indp'*((`pl`i''-``i'')/`pl`i'')^1  if (`pl`i''>``i'');
qui gen        `pnum2`i'' = 0;
qui replace    `pnum2`i'' = `w`i''*`hsp'*`indp'*((`pl`i''-``i'')/`pl`i'')^2  if (`pl`i''>``i'');
};
};


cap drop _poor_priv;
gen _poor_priv =  `indt0'*`indp'*`swat';


qui replace    `num00' = `hs'*`indp';
qui replace    `num0'  = `hs'*`indt0'*`indp';
qui replace    `num1'  = `hs'*`indt1'*`indp';
qui replace    `num2'  = `hs'*`indt2'*`indp';

qui replace    `pnum00' = `hsp'*`indp';
qui replace    `pnum0'  = `hsp'*`indt0'*`indp';
qui replace    `pnum1'  = `hsp'*`indt1'*`indp';
qui replace    `pnum2'  = `hsp'*`indt2'*`indp';




qui svy: ratio `hs'/`hsp';
cap drop matrix _aa;
matrix _aa=e(b);
local est_PS = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std_PS = el(_vv,1,1)^0.5;


qui svy: ratio `num00'/`hs';
cap drop matrix _aa;
matrix _aa=e(b);
local est_H0 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std_H0 = el(_vv,1,1)^0.5;


qui svy: ratio `num00'/`pnum00';
cap drop matrix _aa;
matrix _aa=e(b);
local cest_H0 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local cstd_H0 = el(_vv,1,1)^0.5;



qui svy: ratio `num0'/`hs';
cap drop matrix _aa;
matrix _aa=e(b);
local est_M0 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std_M0 = el(_vv,1,1)^0.5;


qui svy: ratio `num0'/`pnum0';
cap drop matrix _aa;
matrix _aa=e(b);
local cest_M0 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local cstd_M0 = el(_vv,1,1)^0.5;


qui svy: ratio `num1'/`hs';
cap drop matrix _aa;
matrix _aa=e(b);
local est_M1 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std_M1 = el(_vv,1,1)^0.5;

qui svy: ratio `num1'/`pnum1';
cap drop matrix _aa;
matrix _aa=e(b);
local cest_M1 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local cstd_M1 = el(_vv,1,1)^0.5;


qui svy: ratio `num2'/`hs';
cap drop matrix _aa;
matrix _aa=e(b);
local est_M2 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std_M2 = el(_vv,1,1)^0.5;


qui svy: ratio `num2'/`pnum2';
cap drop matrix _aa;
matrix _aa=e(b);
local cest_M2 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local cstd_M2 = el(_vv,1,1)^0.5;


return scalar est_PS  = `est_PS';
return scalar std_PS  = `std_PS';

return scalar est_H0  = `est_H0';
return scalar std_H0  = `std_H0';

return scalar est_M0  = `est_M0';
return scalar std_M0  = `std_M0';

return scalar est_M1  = `est_M1';
return scalar std_M1  = `std_M1';

return scalar est_M2  = `est_M2';
return scalar std_M2  = `std_M2';


return scalar cest_H0  = `cest_H0';
return scalar cstd_H0  = `cstd_H0';

return scalar cest_M0  = `cest_M0';
return scalar cstd_M0  = `cstd_M0';

return scalar cest_M1  = `cest_M1';
return scalar cstd_M1  = `cstd_M1';

return scalar cest_M2  = `cest_M2';
return scalar cstd_M2  = `cstd_M2';


if (`gnumber'==-1) {;
forvalues i=1/`nembarg' {;

qui svy: ratio `pnum0`i''/`pnum0';
cap drop matrix _aa;
matrix _aa=e(b);
local cest_M0`i' = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local cstd_M0`i' = el(_vv,1,1)^0.5;
return scalar cest_M0`i'  = `cest_M0`i'';
return scalar cstd_M0`i'  = `cstd_M0`i'';

qui svy: ratio `pnum1`i''/`pnum1';
cap drop matrix _aa;
matrix _aa=e(b);
local cest_M1`i' = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local cstd_M1`i' = el(_vv,1,1)^0.5;
return scalar cest_M1`i'  = `cest_M1`i'';
return scalar cstd_M1`i'  = `cstd_M1`i'';

qui svy: ratio `pnum2`i''/`pnum2';
cap drop matrix _aa;
matrix _aa=e(b);
local cest_M2`i' = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local cstd_M2`i' = el(_vv,1,1)^0.5;
return scalar cest_M2`i'  = `cest_M2`i'';
return scalar cstd_M2`i'  = `cstd_M2`i'';

};
};

end;







capture program drop imdpov;
program define imdpov, rclass;
version 9.2;
syntax varlist(min=1)[,  
HSize(varname)
HGroup(varname)
dec(int 3)
INDex(int 1)
alpha(real 1)  beta(real 1) gamma(real 1) DCUT(real 0.5)
PL1(real 0)  PL2(real 0) PL3(real 0) PL4(real 0) PL5(real 0) PL6(real 0) PL7(real 0)  PL8(real 0) PL9(real 0) PL10(real 0) 
AL1(real 0)  AL2(real 0) AL3(real 0) AL4(real 0) AL5(real 0) AL6(real 0) AL7(real 0)  AL8(real 0) AL9(real 0) AL10(real 0)
A1(real 1)   A2(real 1)  A3(real 1)  A4(real 1)  A5(real 1)  A6(real 1) A7(real 1)   A8(real 1)  A9(real 1)  A10(real 1)  
W1(real 1)   W2(real 1)  W3(real 1)  W4(real 1)  W5(real 1)  W6(real 1) W7(real 1)   W8(real 1)  W9(real 1)  W10(real 1) 
B1(real 0)   B2(real 0)  B3(real 0)  B4(real 0)  B5(real 0)  B6(real 0) B7(real 0)   B8(real 0)  B9(real 0)  B10(real 0)  

CONF(string)
LEVEL(real 95) DSTE(int 1)
];


qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

global indicag=0;
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 




if ("`hgroup'"!="") {;

preserve;
capture {;
local lvgroup:value label `hgroup';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , clear;
qui count;
forvalues i=1/`r(N)' {;
local tem=value[`i'];
local grlab`tem' = label[`i'];
};
};
restore;
};

preserve;
qui tabulate `hgroup', matrow(gn);
svmat int gn;
global indicag=r(r);
tokenize `varlist';
};


tokenize  `varlist';
_nargs    `varlist';

foreach var of varlist `varlist' {;
cap drop if `var'==. ;
} ;

local ci=100-`level';
tempvar Variable Estimate STE LB UB PL;
qui gen `Variable'="";
qui gen `Estimate'=0;
qui gen `STE'=0;
qui gen `LB'=0;
qui gen `UB'=0;
qui gen `PL'=0;

tempvar _ths _fw;

qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';
qui gen `_fw'=`_ths';
if (`"`hweight'"'~="") qui replace `_fw'=`_fw'*`hweight';

local ll = 12;
local k=1;
tempvar _ths;
qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';

if `index'!=8 {;
imdpov2 `varlist', hsize(`_ths') nembarg($indica) dec(`dec') index(`index')
pl1(`pl1')  pl2(`pl2') pl3(`pl3') pl4(`pl4') pl5(`pl5') pl6(`pl6') 
pl7(`pl7')  pl8(`pl8') pl9(`pl9') pl10(`pl10')  
a1(`a1')  a2(`a2') a3(`a3') a4(`a4') a5(`a5') a6(`a6') 
a7(`a7')  a8(`a8') a9(`a9') a10(`a10') 
b1(`b1')  b2(`b2') b3(`b3') b4(`b4') b5(`b5') b6(`b6') 
b7(`b7')  b8(`b8') b9(`b9') b10(`b10') 
al1(`al1')  al2(`al2') al3(`al3') al4(`al4') al5(`al5') al6(`al6') 
al7(`al7')  al8(`al8') al9(`al9') al10(`al10') 

alpha(`alpha') gamma(`gamma') beta(`beta') 
conf(`conf') level(`level');


if ("`hgroup'"~="") local k=$indicag+1;

qui replace `Variable' = "Population" in `k';
qui replace `Estimate' = `r(est)' in `k';
qui replace `STE'      = `r(std)' in `k';
qui replace `LB'       = `r(lb)'  in `k';
qui replace `UB'       = `r(ub)'  in `k';
if ("`conf'"=="lb")   qui replace `UB'       =.  in `k';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `k';
};

if `index'==8 {;
imdpov_af `varlist', hsize(`_ths') nembarg($indica) dec(`dec') 
pl1(`pl1')  pl2(`pl2') pl3(`pl3') pl4(`pl4') pl5(`pl5') pl6(`pl6') 
pl7(`pl7')  pl8(`pl8') pl9(`pl9') pl10(`pl10') 
w1(`w1')  w2(`w2') w3(`w3') w4(`w4') w5(`w5') w6(`w6')
w7(`w7')  w8(`w8') w9(`w9') w10(`w10') 
alpha(`alpha')  dcut(`dcut')
conf(`conf') level(`level');



local k=$indicag+1;

tempvar Component CONT0 CONT1 CONT2;
qui gen `Component'="";
qui gen `CONT0'=0;
qui gen `CONT1'=0;
qui gen `CONT2'=0;
local f = 0;
forvalues i=1/$indica {;
local f = `f'+ 1;
qui replace `Component' = "``i''"     in `f';
qui replace `CONT0' = `r(cest_M0`i')'*100 in `f'; 
qui replace `CONT1' = `r(cest_M1`i')'*100 in `f'; 
qui replace `CONT2' = `r(cest_M2`i')'*100 in `f'; 
local f = `f'+ 1;
qui replace `CONT0' = `r(cstd_M0`i')'*100 in `f'; 
qui replace `CONT1' = `r(cstd_M1`i')'*100 in `f'; 
qui replace `CONT2' = `r(cstd_M2`i')'*100 in `f'; 
};


tempvar Variable EST1 EST2 EST3 EST4 EST5  CEST2 CEST3 CEST4 CEST5  ;
qui gen `Variable'="";

qui gen `EST1'=0;
qui gen `EST2'=0;
qui gen `EST3'=0;
qui gen `EST4'=0;
qui gen `EST5'=0;

qui gen `CEST2'=0;
qui gen `CEST3'=0;
qui gen `CEST4'=0;
qui gen `CEST5'=0;

local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;
qui replace `EST1'      = `r(est_PS)' in `k1';
qui replace `EST1'      = `r(std_PS)' in `k2';

qui replace `EST2'      = `r(est_H0)' in `k1';
qui replace `EST2'      = `r(std_H0)' in `k2';

qui replace `EST3'      = `r(est_M0)' in `k1';
qui replace `EST3'      = `r(std_M0)' in `k2';
return scalar M0_`k' = `r(est_M0)';
return scalar H0_`k' = `r(est_H0)'; 

qui replace `EST4'      = `r(est_M1)' in `k1';
qui replace `EST4'      = `r(std_M1)' in `k2';

qui replace `EST5'      = `r(est_M2)' in `k1';
qui replace `EST5'      = `r(std_M2)' in `k2';

qui replace `CEST2'      = `r(cest_H0)' in `k1';
qui replace `CEST2'      = `r(cstd_H0)' in `k2';

qui replace `CEST3'      = `r(cest_M0)' in `k1';
qui replace `CEST3'      = `r(cstd_M0)' in `k2';

qui replace `CEST4'      = `r(cest_M1)' in `k1';
qui replace `CEST4'      = `r(cstd_M1)' in `k2';

qui replace `CEST5'      = `r(cest_M2)' in `k1';
qui replace `CEST5'      = `r(cstd_M2)' in `k2';

qui replace `Variable' = "Population" in `k1';
};

 
if ("`hgroup'"~=""){;

forvalues k=1/$indicag {; 


local kk = gn1[`k'];
local ll=max(`ll',length("`kk': `grlab`k''"));
local component = "Group";

if `index'!=8 {;
if ( "`grlab`kk''" == "") local grlab`kk' = "Group_`kk'";
qui replace `Variable' = "`kk': `grlab`kk''" in `k';
imdpov2 `varlist', hsize(`_ths') hgroup(`hgroup') gnumber(`kk') 
nembarg($indica) dec(`dec') index(`index')
pl1(`pl1')  pl2(`pl2') pl3(`pl3') pl4(`pl4') pl5(`pl5') pl6(`pl6') 
pl7(`pl7')  pl8(`pl8') pl9(`pl9') pl10(`pl10')  
a1(`a1')  a2(`a2') a3(`a3') a4(`a4') a5(`a5') a6(`a6') 
a7(`a7')  a8(`a8') a9(`a9') a10(`a10') 
b1(`b1')  b2(`b2') b3(`b3') b4(`b4') b5(`b5') b6(`b6') 
b7(`b7')  b8(`b8') b9(`b9') b10(`b10') 
al1(`al1')  al2(`al2') al3(`al3') al4(`al4') al5(`al5') al6(`al6') 
al7(`al7')  al8(`al8') al9(`al9') al10(`al10') 
alpha(`alpha')  gamma(`gamma') beta(`beta') conf(`conf') level(`level');

qui replace `Estimate' = `r(est)' in `k';
qui replace `STE'      = `r(std)' in `k';
qui replace `LB'       = `r(lb)'  in `k';
qui replace `UB'       = `r(ub)'  in `k';
if ("`conf'"=="lb")   qui replace `UB'       =.  in `k';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `k';

};

if `index'==8 {;
local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;
local kk = gn1[`k'];
if ( "`grlab`kk''" == "") local grlab`kk' = "Group_`kk'";
qui replace `Variable' = "`kk': `grlab`kk''" in `k1';
imdpov_af `varlist', hsize(`_ths') hgroup(`hgroup') gnumber(`kk') 
nembarg($indica) dec(`dec') 
pl1(`pl1')  pl2(`pl2') pl3(`pl3') pl4(`pl4') pl5(`pl5') pl6(`pl6') 
pl7(`pl7')  pl8(`pl8') pl9(`pl9') pl10(`pl10')
w1(`w1')  w2(`w2') w3(`w3') w4(`w4') w5(`w5') w6(`w6')
w7(`w7')  w8(`w8') w9(`w9') w10(`w10') 
alpha(`alpha')   dcut(`dcut')
conf(`conf') level(`level');

qui replace `EST1'      = `r(est_PS)' in `k1';
qui replace `EST1'      = `r(std_PS)' in `k2';

qui replace `EST2'      = `r(est_H0)' in `k1';
qui replace `EST2'      = `r(std_H0)' in `k2';

qui replace `EST3'      = `r(est_M0)' in `k1';
qui replace `EST3'      = `r(std_M0)' in `k2';

qui replace `EST4'      = `r(est_M1)' in `k1';
qui replace `EST4'      = `r(std_M1)' in `k2';

qui replace `EST5'      = `r(est_M2)' in `k1';
qui replace `EST5'      = `r(std_M2)' in `k2';

qui replace `CEST2'      = `r(cest_H0)' in `k1';
qui replace `CEST2'      = `r(cstd_H0)' in `k2';

qui replace `CEST3'      = `r(cest_M0)' in `k1';
qui replace `CEST3'      = `r(cstd_M0)' in `k2';

qui replace `CEST4'      = `r(cest_M1)' in `k1';
qui replace `CEST4'      = `r(cstd_M1)' in `k2';

qui replace `CEST5'      = `r(cest_M2)' in `k1';
qui replace `CEST5'      = `r(cstd_M2)' in `k2';


};


};

};




                   local sindex="Chakravarty et al (1998)                       ";
if (`index'==2)    local sindex="Extended Watts                                 ";
if (`index'==3)    local sindex="Extended FGT                                   ";
if (`index'==4)    local sindex="Tsui (2002)                                    ";
if (`index'==5)    local sindex="Intersection headcount index                   ";
if (`index'==6)    local sindex="Union headcount index                          ";
if (`index'==7)    local sindex="Bourguignon and Chakravarty (2003)             ";
if (`index'==8)    local sindex="Alkire and Foster (2007)                       ";


if `index'!=8 {;
  tempname table;
	.`table'  = ._tab.new, col(5)  separator(0) lmargin(0);

	.`table'.width  `ll' | 16 16 16 16 |;

	.`table'.strcolor . . yellow . .  ;

	.`table'.numcolor yellow yellow . yellow yellow  ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f ;
	                      di _n as text in white "{col 5}M.D. Poverty index :  `sindex'";
	   if (`index'==8)    di as text     "{col 5}Dimensional cutoff :  `dcut'";
       if ("`hsize'"!="")   di as text     "{col 5}Household size     :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight    :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable     :  `hgroup'";
      .`table'.sep, top;
	.`table'.titles "`component'  " "Estimate" "STE "	"  LB  " "  UB  " ;
	
	.`table'.sep, mid;
	local nalt = "ddd";
      if ("`hgroup'"~=""){;

		forvalues k=1/$indicag {; 
						.`table'.row `Variable'[`k'] `Estimate'[`k'] `STE'[`k'] `LB'[`k'] `UB'[`k'] ; 
						};
                         .`table'.sep,mid;
				};
     .`table'.row `Variable'[$indicag+1] `Estimate'[$indicag+1] `STE'[$indicag+1] `LB'[$indicag+1] `UB'[$indicag+1] ; 

   .`table'.sep,bot;    
};

if (`index'==8) {;

local kk1 = `k2'+1;
local kk2 = `k2'+2;
tempname table;
	.`table'  = ._tab.new, col(6);
	.`table'.width |`ll'|16 16 16 16 16|;
	.`table'.strcolor . . yellow . . . ;
	.`table'.numcolor yellow yellow . yellow yellow yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f %16.`dec'f;
	di _n as text "{col 4} Alkire and Foster (2007) MDP indices";
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";
     
	.`table'.sep, top;
	.`table'.titles "Group  " "Pop. share"  " H0 "  " M0 " " M1 " " M2 " ;

	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor white yellow yellow yellow yellow yellow ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green   green  green green green ;
		  if (`dste'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i'] `EST1'[`i']  `EST2'[`i'] `EST3'[`i'] `EST4'[`i'] `EST5'[`i'];
              	        
                };

if ("`hgroup'"~=""){;
  .`table'.sep, mid;
.`table'.numcolor white yellow yellow yellow yellow yellow  ;
.`table'.row `Variable'[`kk1'] `EST1'[`kk1']  `EST2'[`kk1'] `EST3'[`kk1'] `EST4'[`kk1'] `EST5'[`kk1'];
if (`dste'==1){;
.`table'.numcolor white green   green  green green green;
.`table'.row `Variable'[`kk2'] `EST1'[`kk2']  `EST2'[`kk2'] `EST3'[`kk2'] `EST4'[`kk2'] `EST5'[`kk2'];
};

};
.`table'.sep,bot;

};



if (`index'==8 & "`hgroup'"~="" ) {;

local kk1 = `k2'+1;
local kk2 = `k2'+2;
tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width |`ll'|16 16 16 16|;
	.`table'.strcolor . . yellow .  . ;
	.`table'.numcolor yellow yellow . yellow yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f ;
	di _n as text "{col 4} The relative contribution to the Alkire and Foster (2007) MDP indices";
     
	.`table'.sep, top;
	.`table'.titles "Group  "  " H0 "  " M0 " " M1 " " M2 " ;

	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor white yellow  yellow yellow yellow ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green     green green green ;
		  if (`dste'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i']   `CEST2'[`i'] `CEST3'[`i'] `CEST4'[`i'] `CEST5'[`i'];
              	        
                };
.`table'.sep,bot;

};


if (`index'==8) {;
tempname table;
	.`table'  = ._tab.new, col(4);
	.`table'.width |`ll'|16 16 16|;
	.`table'.strcolor .  yellow .  . ;
	.`table'.numcolor  yellow . yellow yellow ;
	.`table'.numfmt %16.0g   %16.2f %16.2f %16.2f ;
	di _n as text "{col 4} The relative contribution of dimensions to the Alkire and Foster (2007) ";
	di    as text "{col 4} MDP indices estimated at population level (results in %).";
     
	.`table'.sep, top;
	.`table'.titles "Dimensions  "  " M0 " " M1 " " M2 " ;

	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`f'{;
        
             if (`i'/2!=round(`i'/2))  .`table'.numcolor white   yellow yellow yellow ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white     green green green ;
		  if (`dste'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Component'[`i']   `CONT0'[`i'] `CONT1'[`i'] `CONT2'[`i'];
              	        
                };
.`table'.sep,bot;

};


end;


 
