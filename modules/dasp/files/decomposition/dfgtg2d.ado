/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : dfgtg2d                                                     */
/*************************************************************************/






#delim ;
set more off;


capture program drop dfgtg2;
program define dfgtg2, rclass;
version 9.2;
syntax namelist [,  HGroup(string) GNumber(integer 1) HS(string) AL(real 0) PL(string)];

tokenize `namelist';
tempvar num1 snum1;
qui gen  `num1'=0;
tempvar hsi1 hsia1;
qui gen `hsi1'=`hs';


qui gen `hsia1'=`hs';

if ("`hgroup'" ~="")    qui replace `hsi1'=`hsi1'*(`hgroup'==`gnumber');


 qui svy: ratio  `hsi1'/`hsia1';
 cap drop matrix _aa;
 matrix _aa=e(b);
 local est11 = el(_aa,1,1);
 cap drop matrix _vv;
 matrix _vv=e(V);
 local std11 = el(_vv,1,1)^0.5;
 return scalar std11  = `std11';
 return scalar est11  = `est11';
 

  cap drop `num1' `snum1';
  tempvar num1 snum1;
  qui gen   `num1'=0;
  qui gen  `snum1'=0;
  if (`al' == 0)           qui replace    `num1' = `hsi1'*(`pl'> `1');
  if (`al' ~= 0)           qui replace    `num1' = `hsi1'*(1-`1'/`pl')^`al'  if (`pl'>`1');


   qui svy: ratio (eq1: `num1'/`hsi1');
   cap drop matrix _aa;
matrix _aa=e(b);
local est1 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std1 = el(_vv,1,1)^0.5;
 return scalar std1  = `std1';
 return scalar est1  = `est1';

end;










capture program drop dfgtg2d2d;
program define dfgtg2d2d, rclass;
version 9.2;
syntax namelist [,  HGroup(string) GNumber(integer 1) HS1(string) HS2(string) AL(real 0) PL(string) TYpe(string) INDex(string) LEVEL(real 95) REF(int 1)];

tokenize `namelist';
tempvar num1 num2 snum1 snum2;
qui gen  `num1'=0;
qui gen  `num2'=0;
tempvar hsi1 hsi2 hsia1 hsia2;
qui gen `hsi1'=`hs1';
qui gen `hsi2'=`hs2';

qui gen `hsia1'=`hs1';
qui gen `hsia2'=`hs2';

if ("`hgroup'" ~="")    qui replace `hsi1'=`hsi1'*(`hgroup'==`gnumber');
if ("`hgroup'" ~="")    qui replace `hsi2'=`hsi2'*(`hgroup'==`gnumber');



 qui svy: ratio  `hsi1'/`hsia1';
 cap drop matrix _aa;
 matrix _aa=e(b);
 local est11 = el(_aa,1,1);
 cap drop matrix _vv;
 matrix _vv=e(V);
 local std11 = el(_vv,1,1)^0.5;
 return scalar std11  = `std11';
 return scalar est11  = `est11';
 
 qui svy: ratio  `hsi2'/`hsia2';
 cap drop matrix _aa;
 matrix _aa=e(b);
 local est22 = el(_aa,1,1);
 cap drop matrix _vv;
 matrix _vv=e(V);
 local std22 = el(_vv,1,1)^0.5;
 return scalar std22  = `std22';
 return scalar est22  = `est22';

cap drop `num1' `snum1';
tempvar num1 snum1;
qui gen   `num1'=0;
qui gen  `snum1'=0;
if (`al' == 0)           qui replace    `num1' = `hsi1'*(`pl'> `1');
if (`al' ~= 0)           qui replace    `num1' = `hsi1'*(1-`1'/`pl')^`al'  if (`pl'>`1');


qui svy: ratio (eq1: `num1'/`hsi1');
cap drop matrix _aa;
matrix _aa=e(b);
local est1 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std1 = el(_vv,1,1)^0.5;
cap drop `num2' `snum2';
tempvar num2 snum2;
qui gen   `num2'=0;
qui gen  `snum2'=0;
if (`al' == 0)           qui replace    `num2' = `hsi2'*(`pl'> `2');
if (`al' ~= 0)           qui replace    `num2' = `hsi2'*(1-`2'/`pl')^`al'  if (`pl'>`2');
qui svy: ratio (eq2: `num2'/`hsi2');
cap drop matrix _aa;
matrix _aa=e(b);
local est2 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std2 = el(_vv,1,1)^0.5;


local equa1="";

local equa1 = "(_b[`num1']/_b[`hsi1'])";
local smean1 = "`num1' `hsi1' `hsia1'";


local equa2="";

local equa2 = "(_b[`num2']/_b[`hsi2'])";
local smean2 = "`num2' `hsi2' `hsia2'";

local est3=`est2'-`est1';


 qui svy: mean  `smean1' `smean2';

qui nlcom (`equa1'-`equa2'),  iterate(40000);
cap drop matrix _vv;
matrix _vv=r(V);
local std3 = el(_vv,1,1)^0.5;



return scalar std1  = `std1';
return scalar est1  = `est1';

return scalar std2  = `std2';
return scalar est2  = `est2';


return scalar std3  = `std3';
return scalar est3  = `est3';



if (`ref' == 1) {;

/* Poverty component */
local equa = "(_b[`hsi1']/_b[`hsia1'])*( _b[`num2']/_b[`hsi2'] - _b[`num1']/_b[`hsi1'] )";
qui nlcom (`equa'),  iterate(40000);
cap drop matrix _aa;
matrix _aa=r(b);
local est4 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=r(V);
local std4 = el(_vv,1,1)^0.5;

return scalar std4  = `std4';
return scalar est4  = `est4';


/* Population component */
local equa = " (_b[`num1']/_b[`hsi1'] ) * ( _b[`hsi2']/_b[`hsia2'] - _b[`hsi1']/_b[`hsia1'] ) ";
qui nlcom (`equa'),  iterate(40000);
cap drop matrix _aa;
matrix _aa=r(b);
local est5 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=r(V);
local std5 = el(_vv,1,1)^0.5;

return scalar std5  = `std5';
return scalar est5  = `est5';

/* Interaction component */

local equa1 = "((_b[`hsi2']/_b[`hsia2']) - (_b[`hsi1']/_b[`hsia1']))";
local equa2 = "((_b[`num2']/_b[`hsi2']) - (_b[`num1']/_b[`hsi1']))";


qui nlcom ( `equa1' * `equa2' ),  iterate(40000);
cap drop matrix _aa;
matrix _aa=r(b);
local est6 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=r(V);
local std6 = el(_vv,1,1)^0.5;

return scalar std6  = `std6';
return scalar est6  = `est6';




};


if (`ref' == 2) {;
/* Poverty component */
local equa = "(_b[`hsi2']/_b[`hsia2'])*( _b[`num2']/_b[`hsi2'] - _b[`num1']/_b[`hsi1'] )";
qui nlcom (`equa'),  iterate(40000);
cap drop matrix _aa;
matrix _aa=r(b);
local est4 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=r(V);
local std4 = el(_vv,1,1)^0.5;

return scalar std4  = `std4';
return scalar est4  = `est4';


/* Population component */
local equa = "(_b[`num2']/_b[`hsi2']) * (_b[`hsi2']/_b[`hsia2'] - _b[`hsi1']/_b[`hsia1']) ";
qui nlcom (`equa'),  iterate(40000);
cap drop matrix _aa;
matrix _aa=r(b);
local est5 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=r(V);
local std5 = el(_vv,1,1)^0.5;

return scalar std5  = `std5';
return scalar est5  = `est5';

/* Interaction component */

local equa1 = "( (_b[`hsi1']/_b[`hsia1']) - (_b[`hsi2']/_b[`hsia2']))";
local equa2 = "((_b[`num2']/_b[`hsi2']) - (_b[`num1']/_b[`hsi1']))";


qui nlcom ( `equa1' * `equa2' ),  iterate(40000);
cap drop matrix _aa;
matrix _aa=r(b);
local est6 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=r(V);
local std6 = el(_vv,1,1)^0.5;

return scalar std6  = `std6';
return scalar est6  = `est6';


};



if (`ref' == 0) {;
/* Poverty component */
local equa1 = "0.5*((_b[`hsi1']/_b[`hsia1'])+(_b[`hsi2']/_b[`hsia2']))";
local equa2 = "((_b[`num2']/_b[`hsi2'])-(_b[`num1']/_b[`hsi1']))";


qui nlcom (`equa2'*`equa1'),  iterate(40000);
cap drop matrix _aa;
matrix _aa=r(b);
local est4 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=r(V);
local std4 = el(_vv,1,1)^0.5;

return scalar std4  = `std4';
return scalar est4  = `est4';


/* Population component */
local equa1 = "0.5*( (_b[`num1']/_b[`hsi1']) + (_b[`num2']/_b[`hsi2']) )";
local equa2 = "((_b[`hsi2']/_b[`hsia2']) - (_b[`hsi1']/_b[`hsia1']))";

qui nlcom (`equa2'*`equa1'),  iterate(40000);
cap drop matrix _aa;
matrix _aa=r(b);
local est5 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=r(V);
local std5 = el(_vv,1,1)^0.5;

return scalar std5  = `std5';
return scalar est5  = `est5';

/* Interaction component */


return scalar std6  = 0;
return scalar est6  = 0;


};





end;






capture program drop dfgtg2d;
program define dfgtg2d, eclass;
version 9.2;
syntax  namelist(min=2 max=2) [, FILE1(string) FILE2(string) HSize1(string) HSize2(string) HGroup(string)
ALpha(real 0)  PLINE(real 10000)  type(string) DEC(int 6) DSTE(int 1) REF(int 1)];



if ("`type'"=="")          local type="nor";

local ll=10;

local indep = ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  );










/********************************/



if ( "`hsize1'" == "") {;
tempvar hsize1;
qui gen `hsize1'=1;
};

if ( "`hsize2'" == "") {;
tempvar hsize2;
qui gen `hsize2'=1;
};




if ((`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;
if (`"`file1'"'~="") use `"`file1'"', replace;


tempvar Variable EST EST11 EST1 EST2 EST22  EST3 EST4 EST5 EST6 STE STE1 STE11 STE2 STE22 STE3 STE4 STE5 STE6;
qui gen `Variable'="";
qui gen `EST'=0;
qui gen `STE'=0;

qui gen `EST11'=0;
qui gen `STE11'=0;

qui gen `EST2'=0;
qui gen `STE2'=0;

qui gen `EST22'=0;
qui gen `STE22'=0;

qui gen `EST3'=0;
qui gen `STE3'=0;

qui gen `EST4'=0;
qui gen `STE4'=0;

qui gen `EST5'=0;
qui gen `STE5'=0;

qui gen `EST6'=0;
qui gen `STE6'=0;




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
};
restore;preserve;
qui tabulate `hgroup', matrow(gn);
svmat int gn;
global indica=r(r);
tokenize `list';
};


tokenize `namelist';


local cont1 = 0;
local cont2 = 0;
local cont3 = 0;

forvalues k = 1/$indica {;
local kk = gn1[`k'];
dfgtg2d2d `1' `2' ,   hs1(`hsize1') hs2(`hsize2') hgroup(`hgroup') gnumber(`kk')  pl(`pline') al(`alpha') type(`type') ref(`ref')  ;
local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;
qui replace `EST'      = `r(est1)' in `k1';
qui replace `EST'      = `r(std1)' in `k2';

qui replace `EST11'      = `r(est11)' in `k1';
qui replace `EST11'      = `r(std11)' in `k2';

qui replace `EST2'      = `r(est2)' in `k1';
qui replace `EST2'      = `r(std2)' in `k2';

qui replace `EST22'      = `r(est22)' in `k1';
qui replace `EST22'      = `r(std22)' in `k2';

qui replace `EST3'      = `r(est3)' in `k1';
qui replace `EST3'      = `r(std3)' in `k2';

qui replace `EST4'      = `r(est4)' in `k1';
qui replace `EST4'      = `r(std4)' in `k2';

local cont1=`cont1'+`r(est4)';

qui replace `EST5'      = `r(est5)' in `k1';
qui replace `EST5'      = `r(std5)' in `k2';
local cont2=`cont2'+`r(est5)';

qui replace `EST6'      = `r(est6)' in `k1';
qui replace `EST6'      = `r(std6)' in `k2';
local cont3=`cont3'+`r(est6)';
/*
return scalar fgt1_`kk'= `r(est1)';
return scalar fgt2_`kk'= `r(est2)';
return scalar dif_`kk' = `r(est3)';

*/

local label`f'  : label (`hgroup') `kk';
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";
qui replace `Variable' = "`label`f''" in `k1';

local ll=max(`ll',length("`label`f''"));
};
local k = $indica;
local kk1= (`k')*2+1;
local kk2= (`k')*2+2;


dfgtg2d2d `1' `2' ,   hs1(`hsize1') hs2(`hsize2')  pl(`pline') al(`alpha') type(`type')  ref(`ref') gnumber(-1);

qui replace `EST'      = `r(est1)' in `kk1';
qui replace `EST'      = `r(std1)' in `kk2';

qui replace `EST11'      = `r(est11)' in `kk1';
qui replace `EST11'      = `r(std11)' in `kk2';

qui replace `EST2'      = `r(est2)' in `kk1';
qui replace `EST2'      = `r(std2)' in `kk2';

qui replace `EST22'      = `r(est22)' in `kk1';
qui replace `EST22'      = `r(std22)' in `kk2';

qui replace `EST3'      = `r(est3)' in `kk1';
qui replace `EST3'      = `r(std3)' in `kk2';


qui replace `EST4'      = `r(est4)' in `kk1';
qui replace `EST4'      = `r(std4)' in `kk2';

qui replace `EST5'      = `r(est5)' in `kk1';
qui replace `EST5'      = `r(std5)' in `kk2';

qui replace `EST6'      = `r(est6)' in `kk1';
qui replace `EST6'      = `r(std6)' in `kk2';


qui replace `Variable' = "Population" in `kk1';

 tempname table;
        .`table'  = ._tab.new, col(6);
        .`table'.width |`ll'|16 16 16 16 16|;
        .`table'.strcolor . . yellow . . . ;
        .`table'.numcolor yellow yellow . yellow  yellow   yellow  ;
        .`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f %16.`dec'f ;
        di _n as text "{col 4} Decomposition of the FGT index by groups";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";
                            di  as text "{col 5}Parameter alpha : "  %5.2f `alpha'       ;
     
	     di _n as text "{col 4} Population shares and FGT indices";
	 
        .`table'.sep, top;
        .`table'.titles "Group  " "Initial   "   "Initial"   "Final "         "Final "     "Difference in"  ;
        .`table'.titles "       " "Pop. share"   "FGT index"   "Pop. share"   "FGT index"  "FGT index    "  ;
        .`table'.sep, mid;
        local nalt = "ddd";
        forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor white yellow yellow yellow yellow yellow  ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green   green  green  green  green ;
                  if (`dste'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i'] `EST11'[`i'] `EST'[`i']   `EST22'[`i'] `EST2'[`i'] `EST3'[`i'] ;
                        
                };
  .`table'.sep, mid;
.`table'.numcolor white yellow yellow yellow yellow yellow  ;
.`table'.row `Variable'[`kk1']  `EST11'[`kk1'] `EST'[`kk1']  `EST22'[`kk1']  `EST2'[`kk1'] `EST3'[`kk1'] ;
if (`dste'==1){;
.`table'.numcolor white green   green  green green  green;
.`table'.row `Variable'[`kk2'] `EST11'[`kk2']  `EST'[`kk2']  `EST22'[`kk2']  `EST2'[`kk2'] `EST3'[`kk2'] ;
};


.`table'.sep,bot;




 tempname table;
        .`table'  = ._tab.new, col(4);
        .`table'.width |`ll'|16 16 16|;
        .`table'.strcolor . . yellow .  ;
        .`table'.numcolor yellow yellow . yellow  ;
        .`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f ;
    di _n as text "{col 4} Decomposition components";
     
        .`table'.sep, top;
        .`table'.titles "Group  " "Poverty  "      "Population"  "Interaction"  ;
        .`table'.titles "       " "Component"      "Component "   "Component  "  ;
        .`table'.sep, mid;
        local nalt = "ddd";
        forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor white yellow yellow yellow  ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green   green  green  ;
                  if (`dste'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i'] `EST4'[`i']  `EST5'[`i'] `EST6'[`i'] ;
                        
                };
				
  .`table'.sep, mid;
.`table'.numcolor white yellow yellow yellow  ;
.`table'.row `Variable'[`kk1'] `cont1'  `cont2'  `cont3'  ;
if (`dste'==1){;
.`table'.numcolor white green   green  green ;
.`table'.row `Variable'[`kk2']  "===" "===" "===";
};


.`table'.sep,bot;



/********************************/



};


// second stage
if !( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;
if ("`file1'" !="") use `"`file1'"', replace;

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
};
restore;
preserve;
qui tabulate `hgroup', matrow(gn);
svmat int gn;
global indica=r(r);
tokenize `list';
};


tokenize `namelist';


tempvar hs1;
qui gen `hs1'=1;
if ("`hsize1'"~="") {;
qui replace `hs1'= `hsize1'; 
};

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight1=""; 
cap qui svy: total `1'; 
local hweight1=`"`e(wvar)'"';
cap ereturn clear; 

tempvar hsia1;
qui gen `hsia1'  = `hs1'; 

forvalues j = 1/$indica {;
local k = gn1[`j'];
tempvar hsi1`k' num1`k';
                            qui gen    `hsi1`k''  =`hs1'*(`hgroup'==`k');
if (`alpha' == 0)           qui gen    `num1`k'' = `hsi1`k''*(`pline'> `1');
if (`alpha' ~= 0)           qui gen    `num1`k'' = `hsi1`k''*(1-`1'/`pline')^`alpha'  if (`pline'>`1');


dfgtg2 `1' ,   hs(`hs1')  hgroup(`hgroup') pl(`pline') al(`alpha')  gnumber(`k');

local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;

local estt1_`k1' =  `r(est1)';
local estt1_`k2' =  `r(std1)';

local estt11_`k1' =  `r(est11)';
local estt11_`k2' =  `r(std11)';


qui svy: mean `hsia1' `hsi1`k'' `num1`k'';
matrix _V1_`k' = e(V);
matrix _E1_`k' = e(b);

};


dfgtg2 `1' ,   hs(`hs1')   pl(`pline') al(`alpha')  gnumber(-1);

local k = $indica;
local kk1= (`k')*2+1;
local kk2= (`k')*2+2;


local estt1_`kk1' =  `r(est1)';
local estt1_`kk2' =  `r(std1)';

local estt11_`kk1' =  `r(est11)';
local estt11_`kk2' =  `r(std11)';




restore;
if ("`file2'" !="") use `"`file2'"', replace;


local cont1 = 0;
local cont2 = 0;
local cont3 = 0;

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
};
restore;
preserve;
qui tabulate `hgroup', matrow(gn);
svmat int gn;
global indica=r(r);
tokenize `list';
};


tokenize `namelist';

tempvar hs2;
qui gen `hs2'=1;
if ("`hsize2'"~="") {;
qui replace `hs2'= `hsize2'; 
};


qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight2=""; 
cap qui svy: total `1'; 
local hweight2=`"`e(wvar)'"';
cap ereturn clear; 



tempvar Variable EST EST11 EST1 EST2 EST22  EST3 EST4 EST5 EST6 STE STE1 STE11 STE2 STE22 STE3 STE4 STE5 STE6;
qui gen `Variable'="";
qui gen `EST'=0;
qui gen `STE'=0;

qui gen `EST11'=0;
qui gen `STE11'=0;

qui gen `EST2'=0;
qui gen `STE2'=0;

qui gen `EST22'=0;
qui gen `STE22'=0;

qui gen `EST3'=0;
qui gen `STE3'=0;

qui gen `EST4'=0;
qui gen `STE4'=0;

qui gen `EST5'=0;
qui gen `STE5'=0;

qui gen `EST6'=0;
qui gen `STE6'=0;




tempvar hsia2;
qui gen `hsia2'  = `hs2'; 
forvalues j = 1/$indica {;
local k = gn1[`j'];
tempvar hsi2`k' num2`k';
                            qui gen    `hsi2`k''  =`hs2'*(`hgroup'==`k');
if (`alpha' == 0)           qui gen    `num2`k'' = `hsi2`k''*(`pline'> `2');
if (`alpha' ~= 0)           qui gen    `num2`k'' = `hsi2`k''*(1-`2'/`pline')^`alpha'  if (`pline'>`2');


qui svy: mean `hsia2' `hsi2`k'' `num2`k'';
matrix _V2_`k' = e(V);
matrix _E2_`k' = e(b);


svmat  _V1_`k'  ;
svmat  _V2_`k'  ;

qui replace _V2_`k'1 = _V2_`k'1[_n-3] in 4/6;
qui replace _V2_`k'1 =0               in 1/3;
qui replace _V1_`k'1 =0               in 4/6;

qui replace _V2_`k'2 = _V2_`k'2[_n-3] in 4/6;
qui replace _V2_`k'2 =0               in 1/3;
qui replace _V1_`k'2 =0               in 4/6;

qui replace _V2_`k'3 = _V2_`k'3[_n-3] in 4/6;
qui replace _V2_`k'3 =0               in 1/3;
qui replace _V1_`k'3 =0               in 4/6;

mkmat _V1_`k'1 _V1_`k'2 _V1_`k'3 _V2_`k'1 _V2_`k'2 _V2_`k'3 in 1/6, matrix(_V`k');

matrix drop _V1_`k' _V2_`k';

matrix _G`k' = 
(
el(_E1_`k',1,1)\
el(_E1_`k',1,2)\
el(_E1_`k',1,3)\
el(_E2_`k',1,1)\
el(_E2_`k',1,2)\
el(_E2_`k',1,3)
)
;


local s1`k' = el(_E1_`k',1,1); local s2`k' = el(_E1_`k',1,2); local s3`k' = el(_E1_`k',1,3);
local s4`k' = el(_E2_`k',1,1); local s5`k' = el(_E2_`k',1,2); local s6`k' = el(_E2_`k',1,3);


matrix drop _E1_`k' _E2_`k';




if (`ref' == 1) {;


/* Poverty component */
local c1`k' = (`s2`k''/`s1`k'')*( `s6`k''/`s5`k'') - `s3`k''/`s1`k'' ;

cap drop matrix _G`k';
matrix _G`k' = 
(
-(`s2`k''/`s1`k''^2)*( `s6`k''/`s5`k'') + `s3`k''/`s1`k''^2   \
(1/`s1`k'')*( `s6`k''/`s5`k'')                               \
-1/`s1`k''  												  \
0															  \
-(`s2`k''/`s1`k'')*( `s6`k''/`s5`k''^2)  					  \
(`s2`k''/`s1`k'')*( 1/`s5`k'')
)
;

cap matrix drop _zz;
matrix _zz=_G`k''*_V`k'*_G`k';
local  sc1`k'= el(_zz,1,1)^0.5;




/* Population component */
local c2`k' = (`s3`k''/`s2`k'')*( `s5`k''/`s4`k'') - `s3`k''/`s1`k'' ;

cap drop matrix _G`k';
matrix _G`k' = 
(
 `s3`k''/`s1`k''^2   										  \
-(`s3`k''/`s2`k''^2)*( `s5`k''/`s4`k'')                       \
(1/`s2`k'')*( `s5`k''/`s4`k'') - 1/`s1`k'' 					  \
-(`s3`k''/`s2`k'')*( `s5`k''/`s4`k''^2)						  \
(`s3`k''/`s2`k'')*( 1/`s4`k'')			  					  \
0
)
;

cap matrix drop _zz;
matrix _zz=_G`k''*_V`k'*_G`k';
local  sc2`k'= el(_zz,1,1)^0.5;





/* Interaction component */

/*local c3`k' = (`s5`k''/`s4`k''-`s2`k''/`s1`k'')*( `s6`k''/`s5`k'' - `s3`k''/`s2`k'' ); */

local c3`k' = (`s6`k''/`s4`k'')-  (`s2`k''/`s1`k'')*(`s6`k''/`s5`k'')  - (`s5`k''/`s4`k'')*(`s3`k''/`s2`k'')  + (`s3`k''/`s1`k'');



cap drop matrix _G`k';
matrix _G`k' = 
(
(`s2`k''/`s1`k''^2)*(`s6`k''/`s5`k'') - (`s3`k''/`s1`k''^2)               \
(-1/`s1`k'')*(`s6`k''/`s5`k'')  +(`s5`k''/`s4`k'')*(`s3`k''/`s2`k''^2)    \
- (`s5`k''/`s4`k'')*(1/`s2`k'')  + (1/`s1`k'') 					          \
-(`s6`k''/`s4`k''^2)  + (`s5`k''/`s4`k''^2)*(`s3`k''/`s2`k'')		      \
-(`s2`k''/`s1`k'')*(`s6`k''/`s5`k''^2)  - (1/`s4`k'')*(`s3`k''/`s2`k'')   \
-  (`s2`k''/`s1`k'')*(1/`s5`k'')
)
;

cap matrix drop _zz;
matrix _zz=_G`k''*_V`k'*_G`k';
local  sc3`k'= el(_zz,1,1)^0.5;


/* dis `s1`k'' "   " `s2`k'' "  " `s3`k'' "   " `s4`k'' "   " `s5`k'' "  " `s6`k''; */
/* dis `c1`k'' "   " `c2`k'' "   " `c3`k''  ; */

};







if (`ref' == 2) {;



/* Poverty component */
local c1`k' = (`s6`k''/`s4`k'')-(`s5`k''/`s4`k'')*( `s3`k''/`s2`k'') ;



cap drop matrix _G`k';
matrix _G`k' = 
(
0															   \
(`s5`k''/`s4`k'')*(`s3`k''/`s2`k''^2)  					       \
-(`s5`k''/`s4`k'')*( 1/`s2`k'')                                \
(`s5`k''/`s4`k''^2)*( `s3`k''/`s2`k'') - `s6`k''/`s4`k''^2     \
-(1/`s4`k'')*( `s3`k''/`s2`k'')                                 \
1/`s4`k''  												  

)
;

cap matrix drop _zz;
matrix _zz=_G`k''*_V`k'*_G`k';
local  sc1`k'= el(_zz,1,1)^0.5;




/* Population component */


local c2`k' = (`s6`k''/`s4`k'')-(`s6`k''/`s5`k'')*( `s2`k''/`s1`k'')  ;

cap drop matrix _G`k';
matrix _G`k' = 
(
(`s6`k''/`s5`k'')*( `s2`k''/`s1`k''^2)						 \
-( 1/`s1`k'')                     						     \
0								                             \
 -(`s6`k''/`s4`k''^2) 					  				     \
(`s6`k''/`s5`k''^2)*(`s2`k''/`s1`k'')                        \
(1/`s4`k'')
)
;

cap matrix drop _zz;
matrix _zz=_G`k''*_V`k'*_G`k';
local  sc2`k'= el(_zz,1,1)^0.5;





/* Interaction component */

/*local c3`k' = (`s2`k''/`s1`k'' -`s5`k''/`s4`k'')*( `s6`k''/`s5`k'' - `s3`k''/`s2`k'' ); */


local c3`k' =  (`s2`k''/`s1`k'')*(`s6`k''/`s5`k'') - (`s3`k''/`s1`k'') - (`s6`k''/`s4`k'')   + (`s5`k''/`s4`k'')*(`s3`k''/`s2`k'')  ;



cap drop matrix _G`k';
matrix _G`k' = 
(
-(`s2`k''/`s1`k''^2)*(`s6`k''/`s5`k'') + (`s3`k''/`s1`k''^2)               \
(1/`s1`k'')*(`s6`k''/`s5`k'')  -(`s5`k''/`s4`k'')*(`s3`k''/`s2`k''^2)    \
 (`s5`k''/`s4`k'')*(1/`s2`k'')  - (1/`s1`k'') 					          \
(`s6`k''/`s4`k''^2)  - (`s5`k''/`s4`k''^2)*(`s3`k''/`s2`k'')		      \
(`s2`k''/`s1`k'')*(`s6`k''/`s5`k''^2)  + (1/`s4`k'')*(`s3`k''/`s2`k'')   \
  (`s2`k''/`s1`k'')*(1/`s5`k'')
)
;

cap matrix drop _zz;
matrix _zz=_G`k''*_V`k'*_G`k';
local  sc3`k'= el(_zz,1,1)^0.5;


/* dis `s1`k'' "   " `s2`k'' "  " `s3`k'' "   " `s4`k'' "   " `s5`k'' "  " `s6`k''; */
/* dis `c1`k'' "   " `c2`k'' "   " `c3`k''  ; */


};



if (`ref' == 0) {;
/* Poverty component */
local equa1 = 0.5*((`s2`k''/`s1`k'')+(`s5`k''/`s4`k''));
local equa2 = ((`s6`k''/`s5`k'')-(`s3`k''/`s2`k'') );

local c1`k' = `equa1'*`equa2'; 


cap drop matrix _G1`k';
matrix _G1`k' = 
(
-(`s2`k''/`s1`k''^2)*( `s6`k''/`s5`k'') + `s3`k''/`s1`k''^2   \
(1/`s1`k'')*( `s6`k''/`s5`k'')                               \
-1/`s1`k''  												  \
0															  \
-(`s2`k''/`s1`k'')*( `s6`k''/`s5`k''^2)  					  \
(`s2`k''/`s1`k'')*( 1/`s5`k'')
)
;

cap drop matrix _G2`k';
matrix _G2`k' = 
(
0															   \
(`s5`k''/`s4`k'')*(`s3`k''/`s2`k''^2)  					       \
-(`s5`k''/`s4`k'')*( 1/`s2`k'')                                \
(`s5`k''/`s4`k''^2)*( `s3`k''/`s2`k'') - `s6`k''/`s4`k''^2     \
-(1/`s4`k'')*( `s3`k''/`s2`k'')                                 \
1/`s4`k''  												  

)
;

cap drop matrix _G`k';
matrix _G`k' = _G1`k'+_G2`k';

cap matrix drop _zz;
matrix _zz=_G`k''*_V`k'*_G`k';
local  sc1`k'= 0.5*el(_zz,1,1)^0.5;

/* Population component */
local equa1 = 0.5*((`s6`k''/`s5`k'')+(`s3`k''/`s2`k'') );
local equa2 = ((`s5`k''/`s4`k'')-(`s2`k''/`s1`k''));

local c2`k' = `equa1'*`equa2'; 

cap drop matrix _G1`k';
matrix _G1`k' = 
(
 `s3`k''/`s1`k''^2   										  \
-(`s3`k''/`s2`k''^2)*( `s5`k''/`s4`k'')                       \
(1/`s2`k'')*( `s5`k''/`s4`k'') - 1/`s1`k'' 					  \
-(`s3`k''/`s2`k'')*( `s5`k''/`s4`k''^2)						  \
(`s3`k''/`s2`k'')*( 1/`s4`k'')			  					  \
0
)
;

cap drop matrix _G2`k';
matrix _G2`k' = 
(
(`s6`k''/`s5`k'')*( `s2`k''/`s1`k''^2)						 \
-( 1/`s1`k'')                     						     \
0								                             \
 -(`s6`k''/`s4`k''^2) 					  				     \
(`s6`k''/`s5`k''^2)*(`s2`k''/`s1`k'')                        \
(1/`s4`k'')
)
;

cap drop matrix _G`k';
matrix _G`k' = _G1`k'+_G2`k';

cap matrix drop _zz;
matrix _zz=_G`k''*_V`k'*_G`k';
local  sc2`k'= 0.5*el(_zz,1,1)^0.5;

/* Interaction component */


local c3`k'   = 0;
local sc3`k'  = 0;


};









dfgtg2 `2' ,   hs(`hs2') hgroup(`hgroup') pl(`pline') al(`alpha') gnumber(`k');

local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;


qui replace `EST'       = `estt1_`k1'' in `k1';
qui replace `EST'       = `estt1_`k2'' in `k2';

qui replace `EST11'      = `estt11_`k1''  in `k1';
qui replace `EST11'      = `estt11_`k2'' in `k2';

qui replace `EST2'       = `r(est1)' in `k1';
qui replace `EST2'       = `r(std1)' in `k2';

qui replace `EST22'      = `r(est11)' in `k1';
qui replace `EST22'      = `r(std11)' in `k2';

qui replace `EST3'       = `EST2'[`k1']-`EST'[`k1']           in `k1';
qui replace `EST3'       = (`EST2'[`k2']^2+`EST'[`k2']^2)^0.5 in `k2';

qui replace `EST4'      = `c1`k'' in `k1';
qui replace `EST4'      = `sc1`k'' in `k2';

qui replace `EST5'      = `c2`k'' in `k1';
qui replace `EST5'      = `sc2`k'' in `k2';

qui replace `EST6'      = `c3`k'' in `k1';
qui replace `EST6'      = `sc3`k'' in `k2';

local cont1=`cont1'+`c1`k'';
local cont2=`cont2'+`c2`k'';
local cont3=`cont3'+`c3`k'';

local label`k'  : label (`hgroup') `k';
if ( "`label`k''" == "") local label`k'   = "Group: `k'";
qui replace `Variable' = "`label`k''" in `k1';

local ll=max(`ll',length("`label`k''"));

};

dfgtg2 `2' ,   hs(`hs2')  pl(`pline') al(`alpha')  gnumber(-1);
local k = $indica;
local kk1= (`k')*2+1;
local kk2= (`k')*2+2;

qui replace `EST'       =  `estt1_`kk1'' in `kk1';
qui replace `EST'       =  `estt1_`kk2'' in `kk2';

qui replace `EST11'      = `estt11_`kk1''  in `kk1';
qui replace `EST11'      = `estt11_`kk2''  in `kk2';

qui replace `EST2'       = `r(est1)' in `kk1';
qui replace `EST2'       = `r(std1)' in `kk2';

qui replace `EST22'      = `r(est11)' in `kk1';
qui replace `EST22'      = `r(std11)' in `kk2';

qui replace `EST3'       =  `EST2'[`kk1']-`EST'[`kk1']           in `kk1';
qui replace `EST3'       = (`EST2'[`kk2']^2+`EST'[`kk2']^2)^0.5 in `kk2';



qui replace `Variable' = "Population" in `kk1';

tempname table;
        .`table'  = ._tab.new, col(6);
        .`table'.width |`ll'|16 16 16 16 16|;
        .`table'.strcolor . . yellow . . . ;
        .`table'.numcolor yellow yellow . yellow  yellow   yellow  ;
        .`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f %16.`dec'f ;
        di _n as text "{col 4} Decomposition of the FGT index by groups";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";
                            di  as text "{col 5}Parameter alpha : "  %5.2f `alpha'       ;
     
	     di _n as text "{col 4} Population shares and FGT indices";
	 
        .`table'.sep, top;
        .`table'.titles "Group  " "Initial   "   "Initial"   "Final "         "Final "     "Difference in"  ;
        .`table'.titles "       " "Pop. share"   "FGT index"   "Pop. share"   "FGT index"  "FGT index    "  ;
        .`table'.sep, mid;
        local nalt = "ddd";
        forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor white yellow yellow yellow yellow yellow  ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green   green  green  green  green ;
                  if (`dste'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i'] `EST11'[`i'] `EST'[`i']   `EST22'[`i'] `EST2'[`i'] `EST3'[`i'] ;
                        
                };
  .`table'.sep, mid;
.`table'.numcolor white yellow yellow yellow yellow yellow  ;
.`table'.row `Variable'[`kk1']  `EST11'[`kk1'] `EST'[`kk1']  `EST22'[`kk1']  `EST2'[`kk1'] `EST3'[`kk1'] ;
if (`dste'==1){;
.`table'.numcolor white green   green  green green  green;
.`table'.row `Variable'[`kk2'] `EST11'[`kk2']  `EST'[`kk2']  `EST22'[`kk2']  `EST2'[`kk2'] `EST3'[`kk2'] ;
};


.`table'.sep,bot;


 tempname table;
        .`table'  = ._tab.new, col(4);
        .`table'.width |`ll'|16 16 16|;
        .`table'.strcolor . . yellow .  ;
        .`table'.numcolor yellow yellow . yellow  ;
        .`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f ;
    di _n as text "{col 4} Decomposition components";
     
        .`table'.sep, top;
        .`table'.titles "Group  " "Poverty  "      "Population"  "Interaction"  ;
        .`table'.titles "       " "Component"      "Component "   "Component  "  ;
        .`table'.sep, mid;
        local nalt = "ddd";
        forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor white yellow yellow yellow  ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green   green  green  ;
                  if (`dste'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i'] `EST4'[`i']  `EST5'[`i'] `EST6'[`i'] ;
                        
                };
				
  .`table'.sep, mid;
.`table'.numcolor white yellow yellow yellow  ;
.`table'.row `Variable'[`kk1'] `cont1'  `cont2'  `cont3'  ;
if (`dste'==1){;
.`table'.numcolor white green   green  green ;
.`table'.row `Variable'[`kk2']  "===" "===" "===";
};


.`table'.sep,bot;

};

restore;


end;



