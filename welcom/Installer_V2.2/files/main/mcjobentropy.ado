


#delimit ;
capture program drop basicentropy;
program define basicentropy, rclass;
syntax varlist(min=2 max=2) [, HSize(varname) theta(real 0)];
preserve; 
tokenize `varlist';
tempvar fw;

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
qui gen `fw'=`hsize';
if ("`hweight'"~="")    qui replace `fw'=`fw'*`hweight';




/************/

if ( `theta' !=  0 | `theta' != 1 ) {;
tempvar vec_a vec_b vec_c vec_d vec_e vec_f;
gen   `vec_a' = `hsize'*`1'^`theta';    
gen   `vec_b' = `hsize';           
gen   `vec_c' = `hsize'*`1'; 
gen   `vec_d' = `hsize'*`2'^`theta';    
gen   `vec_e' = `hsize';           
gen   `vec_f' = `hsize'*`2';
    

  
qui svy: mean `vec_a' `vec_b' `vec_c'  `vec_d' `vec_e' `vec_f';
cap drop matrix _aa;
matrix _aa=e(b);
global ws1=el(_aa,1,1);
global ws2=el(_aa,1,2);
global ws3=el(_aa,1,3);
global ws4=el(_aa,1,4);
global ws5=el(_aa,1,5);
global ws6=el(_aa,1,6);

local est1= ( 1/(`theta'*(`theta'-1) ) )*(($ws1/$ws2)/(($ws3/$ws2)^`theta') - 1);
local est2= ( 1/(`theta'*(`theta'-1) ) )*(($ws4/$ws5)/(($ws6/$ws5)^`theta') - 1);
return scalar est1 = `est1';
return scalar est2 = `est2';

local dif = `est2' - `est1';
cap drop matrix mat;
matrix mat=e(V);
cap drop matrix gra1;
matrix gra1=
(
((1/(`theta'*(`theta'-1)))*($ws2^(`theta'-1)))/($ws3^`theta')\
(1/`theta')*($ws1 )*($ws2^(`theta'-2))/($ws3^`theta')\
(1/(1-`theta'))*(($ws1 )*($ws2^(`theta'-1)))/($ws3^(`theta'+1))\
0\
0\
0
);

matrix gra2=
(
0\
0\
0\
((1/(`theta'*(`theta'-1)))*($ws5^(`theta'-1)))/($ws6^`theta')\
(1/`theta')*($ws4 )*($ws5^(`theta'-2))/($ws6^`theta')\
(1/(1-`theta'))*(($ws4 )*($ws5^(`theta'-1)))/($ws6^(`theta'+1))

);

matrix gra=
(
((1/(`theta'*(`theta'-1)))*($ws2^(`theta'-1)))/($ws3^`theta')\
 (1/`theta')*($ws1 )*($ws2^(`theta'-2))/($ws3^`theta')\
 (1/(1-`theta'))*(($ws1 )*($ws2^(`theta'-1)))/($ws3^(`theta'+1))\
-((1/(`theta'*(`theta'-1)))*($ws5^(`theta'-1)))/($ws6^`theta')\
-(1/`theta')*($ws4 )*($ws5^(`theta'-2))/($ws6^`theta')\
-(1/(1-`theta'))*(($ws4 )*($ws5^(`theta'-1)))/($ws6^(`theta'+1))

);




cap matrix drop _zz;
matrix _zz=gra1'*mat*gra1;
local std1= el(_zz,1,1)^0.5;  

cap matrix drop _zz;
matrix _zz=gra2'*mat*gra2;
local std2= el(_zz,1,1)^0.5;  

cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local stddif= el(_zz,1,1)^0.5;  
 
};


if ( `theta' ==  0) {;
tempvar vec_a vec_b vec_c vec_d vec_e vec_f;
gen   `vec_a' = `hsize'*log(`1');    
gen   `vec_b' = `hsize';           
gen   `vec_c' = `hsize'*`1';  
gen   `vec_d' = `hsize'*log(`2');    
gen   `vec_e' = `hsize';           
gen   `vec_f' = `hsize'*`2';    

qui svy: mean `vec_a' `vec_b' `vec_c'  `vec_d' `vec_e' `vec_f';
cap drop matrix _aa;
matrix _aa=e(b);
global ws1=el(_aa,1,1);
global ws2=el(_aa,1,2);
global ws3=el(_aa,1,3);
global ws4=el(_aa,1,4);
global ws5=el(_aa,1,5);
global ws6=el(_aa,1,6);

local est1=log($ws3/$ws2)-$ws1/$ws2; 
local est2=log($ws6/$ws5)-$ws4/$ws5; 
return scalar est1 =  `est1';
return scalar est2 =  `est2';
local dif = `est2' - `est1';
cap drop matrix mat;
matrix mat=e(V);
cap drop matrix gra;
matrix gra1=
(
-1/($ws2)\
(($ws1-$ws2))/($ws2^2)\
1/($ws3)\
0\
0\
0
);

matrix gra2=
(
0\
0\
0\
-1/($ws5)\
(($ws4-$ws5))/($ws2^5)\
1/($ws6)
);

matrix gra=
(
-1/($ws2)\
(($ws1-$ws2))/($ws2^2)\
1/($ws3)\
1/($ws5)\
-(($ws4-$ws5))/($ws2^5)\
-1/($ws6)
);


cap matrix drop _zz;
matrix _zz=gra1'*mat*gra1;
local std1= el(_zz,1,1)^0.5;  

cap matrix drop _zz;
matrix _zz=gra2'*mat*gra2;
local std2= el(_zz,1,1)^0.5;  

cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local stddif= el(_zz,1,1)^0.5;  

};


if ( `theta' ==  1) {;
tempvar vec_a vec_b vec_c vec_d vec_e vec_f;
gen   `vec_a' = `hsize'*`1'*log(`1');    
gen   `vec_b' = `hsize';           
gen   `vec_c' = `hsize'*`1';   
gen   `vec_d' = `hsize'*`2'*log(`2');    
gen   `vec_e' = `hsize';           
gen   `vec_f' = `hsize'*`2';   

qui svy: mean `vec_a' `vec_b' `vec_c'  `vec_d' `vec_e' `vec_f';
cap drop matrix _aa;
matrix _aa=e(b);
global ws1=el(_aa,1,1);
global ws2=el(_aa,1,2);
global ws3=el(_aa,1,3);
global ws4=el(_aa,1,4);
global ws5=el(_aa,1,5);
global ws6=el(_aa,1,6);

local est1=($ws1/$ws3)-log($ws3/$ws2);
local est2=($ws4/$ws6)-log($ws6/$ws5);
local dif = `est2' - `est1';

cap drop matrix mat;
matrix mat=e(V);
cap drop matrix gra;
matrix gra1=
(
1/($ws3)\
1/($ws2)\
-($ws1+$ws3)/($ws3^2)\
0\
0\
0
);

matrix gra2=
(
0\
0\
0\
1/($ws6)\
1/($ws5)\
-($ws4+$ws6)/($ws6^2)

);

matrix gra=
(
1/($ws3)\
1/($ws2)\
-($ws1+$ws3)/($ws3^2)\
-1/($ws6)\
-1/($ws5)\
($ws4+$ws6)/($ws6^2)

);

cap matrix drop _zz;
matrix _zz=gra1'*mat*gra1;
local std1= el(_zz,1,1)^0.5;  

cap matrix drop _zz;
matrix _zz=gra2'*mat*gra2;
local std2= el(_zz,1,1)^0.5;  

cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local stddif= el(_zz,1,1)^0.5;  
};


qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local tval = (`est2'-`est1')/`stddif';
return scalar tval = `tval';
local pval = 1-2*(normal(abs(`tval'))-0.5);
if `stddif'==0 local pval = 0; 
return scalar pval = `pval';



return scalar  a0 = `est1';
return scalar sa0 = `std1';

return scalar  a1 = `est2';
return scalar sa1 = `std2';

return scalar dif = `est2'-`est1';
return scalar sdif = `stddif';

		
restore;
end;



capture program drop mcjobentropy;
program define mcjobentropy, eclass;
version 9.2;
syntax varlist(min=1)[, 
HSize(varname)
HGroup(varname)
AEHS(varname)   
PCEXP(varname)
XRNAMES(string) 
LAN(string) 
MOVE(int 1)
theta(real 0)
];




preserve;

tokenize `varlist';
_nargs    `varlist';
local indica2 = $indica+2;

tempvar total;
qui gen `total'=0;
tempvar Variable EST1 EST11 EST111  EST1111;
qui gen `EST1'=0;
qui gen `EST11'=0;
qui gen `EST111'=0;
qui gen `EST1111'=0;


forvalues i=1/$indica {;
qui replace `total'=`total'+``i'';
};




tempvar Variable ;
qui gen `Variable'="";

tempvar _ths;
qui gen  `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';

cap svy: total;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);


tempvar apcexp;
gen `apcexp' = `pcexp';
if (`move'==1)     {; 
tempvar sliving asliving osliving;
qui gen `sliving' = `pcexp'-`total';
qui gen `asliving' = `sliving';
if ("`aehs'" ~= "" ) qui replace `asliving' = `sliving'*`_ths'/`aehs' ;
gen `osliving' = `asliving' ;
basicentropy `asliving' `pcexp',  hsize(`_ths')  theta(`theta');
};
if (`move'==-1)     {; 
tempvar sliving asliving osliving;
qui gen `sliving' = `pcexp'+ `total';
qui gen `asliving' = `sliving';
if ("`aehs'" ~= "" ) qui replace `asliving' = `sliving'*`_ths'/`aehs' ;
gen `osliving' = `asliving' ;
basicentropy `pcexp' `asliving',  hsize(`_ths') theta(`theta');
};




qui replace `Variable' = "Pre-reform" in 1;
qui replace `EST1'=  `r(est1)'  in 	1;
qui replace `EST11'=  . in 	1;
qui replace `EST111'=  .  in 	1;
qui replace `EST1111'=  .  in 	1;
/*
sum  `_ths'  tot_integ;
ientropy `pcexp' `asliving' pcexpf,  hsize(`_ths');
*/
forvalues k = 1/$indica {;
local j = `k' +1;
tempvar sliving;
tempvar asliving;
if (`move'== 1)   qui gen `sliving'  = `pcexp'-`total'+``k'';
if (`move'==-1)   qui gen `sliving'   = `pcexp'+``k'';
qui gen `asliving' = `sliving';
if ("`aehs'" ~= "" ) qui replace `asliving' = `sliving'*`_ths'/`aehs' ;
if (`move'== 1)   basicentropy `asliving' `osliving',  hsize(`_ths')  theta(`theta');
if (`move'==-1)   basicentropy `asliving' `pcexp' ,    hsize(`_ths')   theta(`theta');
qui replace `EST1'=  `r(est1)'  in `j';
qui replace `EST11'=  `r(dif)'  in 	`j';
qui replace `EST111'=  `r(sdif)'  in 	`j';
qui replace `EST1111'=  `r(pval)'  in 	`j';



};

if (`move'==-1)     {; 

tempvar sliving asliving;
qui gen `sliving' = `pcexp'+`total';
qui gen `asliving' = `sliving';
if ("`aehs'" ~= "" ) qui replace `asliving' = `sliving'*`_ths'/`aehs' ;
basicentropy `asliving' `pcexp',  hsize(`_ths');
};
if (`move'==1)     {; 
tempvar sliving asliving;
qui gen `sliving' = `pcexp'+`total';
qui gen `asliving' = `sliving';
if ("`aehs'" ~= "" ) qui replace `asliving' = `sliving'*`_ths'/`aehs' ;
basicentropy `pcexp' `osliving',  hsize(`_ths')   theta(`theta');
};
qui replace `EST1'=  `r(est1)'  in `indica2';
qui replace `EST11'=  `r(dif)'  in `indica2';
qui replace `EST111'=  `r(sdif)'  in 	`indica2';
qui replace `EST1111'=  `r(pval)'  in 	`indica2';


qui replace `Variable' = "Post-reform" in `indica2';








/****TO DISPLAY RESULTS*****/

local cnam = "";

					 
if ("`lan'"~="fr")  local cnam `"`cnam' "The entropy index""';
if ("`lan'"~="fr")  local cnam `"`cnam' "Variation in entropy""';
if ("`lan'"~="fr")  local cnam `"`cnam' "Standard error""';
if ("`lan'"~="fr")  local cnam `"`cnam' "P_Value""';

if ("`lan'"=="fr")  local cnam `"`cnam' "Indice de entropy""';
if ("`lan'"=="fr")  local cnam `"`cnam' "Variation en entropy""';
if ("`lan'"=="fr")  local cnam `"`cnam' "Erreur type""';
if ("`lan'"=="fr")  local cnam `"`cnam' "P_Value""';



local lng = (`indica2');
qui keep in 1/`lng';

local dste=0;



tempname zz;
qui mkmat   `EST1' `EST11' `EST111' `EST1111',   matrix(`zz');


if `move'== 1 {;
local inlab = "Competitive  Market" ;
local filab = "Concentrated Market" ;
};
if `move'==-1 {;
local filab = "Competitive  Market" ;
local inlab = "Concentrated Market" ;
};

local rnam;
local rnam `"`rnam' "`inlab'""';
if ("`xrnames'"~="") {;
local xrna  "`xrnames'";
local xrna : subinstr local xrna " " ",", all ;
local xrna : subinstr local xrna "|" " ", all ;
local count : word count `xrna';
tokenize "`xrna'";
forvalues i = 1/`count' {;
	local `i': subinstr local `i' "," " ", all ;
	    local tmp = substr("``i''",1,30);
	    local rnam `"`rnam' "`tmp'""';
	
};
};

local rnam `"`rnam' "`filab'""';



matrix rownames `zz' = `rnam' ;
matrix colnames `zz' = `cnam' ;


cap matrix drop _vv _aa gn;

ereturn matrix est = `zz';

restore;

end;



