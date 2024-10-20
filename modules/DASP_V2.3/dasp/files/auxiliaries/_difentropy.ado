
#delimit ;


#delimit ;
capture program drop _difentropy;
program define _difentropy, rclass;
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
