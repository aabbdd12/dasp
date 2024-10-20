/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.2)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : dmdafg                                                      */
/* 8- Decomposition of Alkire and Foster  (2007) index by population groups */	                              */                                 
/*************************************************************************/



#delim ;

capture program drop dmdafg_af;
program define dmdafg_af, rclass;
version 9.2;
syntax varlist [,  HSize(string) HGroup(varname) GNumber(int -1)
nembarg(int 1) 
dec(int 3)
PL1(real 0)  PL2(real 0) PL3(real 0) PL4(real 0) PL5(real 0) PL6(real 0)
W1(real 1)   W2(real 1)  W3(real 1)  W4(real 1)  W5(real 1)  W6(real 1)
ALPHA(real 1)  DCUT(real 0.5) 
CONF(string)
LEVEL(real 95) 
];

preserve;
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

qui svy: ratio `num00'/`hsp';
cap drop matrix _aa;
matrix _aa=e(b);
local a_est_H0 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local a_std_H0 = el(_vv,1,1)^0.5;


qui svy: ratio `num00'/`pnum00';
cap drop matrix _aa;
matrix _aa=e(b);
local r_est_H0 = el(_aa,1,1)*100;
cap drop matrix _vv;
matrix _vv=e(V);
local r_std_H0 = el(_vv,1,1)^0.5*100;



qui svy: ratio `num0'/`hs';
cap drop matrix _aa;
matrix _aa=e(b);
local est_M0 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std_M0 = el(_vv,1,1)^0.5;


qui svy: ratio `num0'/`hsp';
cap drop matrix _aa;
matrix _aa=e(b);
local a_est_M0 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local a_std_M0 = el(_vv,1,1)^0.5;


qui svy: ratio `num0'/`pnum0';
cap drop matrix _aa;
matrix _aa=e(b);
local r_est_M0 = el(_aa,1,1)*100;
cap drop matrix _vv;
matrix _vv=e(V);
local r_std_M0 = el(_vv,1,1)^0.5*100;



qui svy: ratio `num1'/`hs';
cap drop matrix _aa;
matrix _aa=e(b);
local est_M1 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std_M1 = el(_vv,1,1)^0.5;



qui svy: ratio `num1'/`hsp';
cap drop matrix _aa;
matrix _aa=e(b);
local a_est_M1 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local a_std_M1 = el(_vv,1,1)^0.5;


qui svy: ratio `num1'/`pnum1';
cap drop matrix _aa;
matrix _aa=e(b);
local r_est_M1 = el(_aa,1,1)*100;
cap drop matrix _vv;
matrix _vv=e(V);
local r_std_M1 = el(_vv,1,1)^0.5*100;



qui svy: ratio `num2'/`hs';
cap drop matrix _aa;
matrix _aa=e(b);
local est_M2 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std_M2 = el(_vv,1,1)^0.5;


qui svy: ratio `num2'/`hsp';
cap drop matrix _aa;
matrix _aa=e(b);
local a_est_M2 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local a_std_M2 = el(_vv,1,1)^0.5;


qui svy: ratio `num2'/`pnum2';
cap drop matrix _aa;
matrix _aa=e(b);
local r_est_M2 = el(_aa,1,1)*100;
cap drop matrix _vv;
matrix _vv=e(V);
local r_std_M2 = el(_vv,1,1)^0.5*100;



return scalar est_PS  = `est_PS';
return scalar std_PS  = `std_PS';

return scalar est_H0  = `est_H0';
return scalar std_H0  = `std_H0';

return scalar r_est_H0  = `r_est_H0';
return scalar r_std_H0  = `r_std_H0';

return scalar a_est_H0  = `a_est_H0';
return scalar a_std_H0  = `a_std_H0';


return scalar est_M0  = `est_M0';
return scalar std_M0  = `std_M0';


return scalar r_est_M0  = `r_est_M0';
return scalar r_std_M0  = `r_std_M0';

return scalar a_est_M0  = `a_est_M0';
return scalar a_std_M0  = `a_std_M0';

return scalar est_M1  = `est_M1';
return scalar std_M1  = `std_M1';
return scalar r_est_M1  = `r_est_M0';
return scalar r_std_M1  = `r_std_M0';

return scalar a_est_M1  = `a_est_M1';
return scalar a_std_M1  = `a_std_M1';

return scalar est_M2  = `est_M2';
return scalar std_M2  = `std_M2';

return scalar r_est_M2  = `r_est_M2';
return scalar r_std_M2  = `r_std_M2';

return scalar a_est_M2  = `a_est_M2';
return scalar a_std_M2  = `a_std_M2';






end;







capture program drop dmdafg;
program define dmdafg, rclass;
version 9.2;
syntax varlist(min=1)[,  
HSize(varname)
HGroup(varname)
dec(int 3)
PL1(real 0)  PL2(real 0) PL3(real 0) PL4(real 0) PL5(real 0) PL6(real 0)
A1(real 1)   A2(real 1)  A3(real 1)  A4(real 1)  A5(real 1)  A6(real 1) 
W1(real 1)   W2(real 1)  W3(real 1)  W4(real 1)  W5(real 1)  W6(real 1)
alpha(real 1)  beta(real 1) gamma(real 1) DCUT(real 0.5)
B1(real 1)   B2(real 1)  B3(real 1)  B4(real 1)  B5(real 1)  B6(real 1)
AL1(real 0)  AL2(real 0) AL3(real 0) AL4(real 0) AL5(real 0) AL6(real 0)
XFIL(string) XSHE(string) XLAN(string) XTIT1(string) XTIT2(string) XTIT3(string) XTIT4(string)
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

tokenize  `varlist';
_nargs    `varlist';

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




dmdafg_af `varlist', hsize(`_ths') nembarg($indica) dec(`dec') 
pl1(`pl1')  pl2(`pl2') pl3(`pl3') pl4(`pl4') pl5(`pl5') pl6(`pl6') 
w1(`w1')  w2(`w2') w3(`w3') w4(`w4') w5(`w5') w6(`w6')
alpha(`alpha')  dcut(`dcut')
conf(`conf') level(`level');



local k=$indicag+1;

tempvar Component CONT0 CONT1 CONT2;
qui gen `Component'="";
qui gen `CONT0'=0;
qui gen `CONT1'=0;
qui gen `CONT2'=0;
local f = 0;


tempvar Variable EST1 EST2 EST2r EST2a EST3 EST3r EST3a  EST4 EST4r EST4a  EST5 EST5r EST5a    ;
qui gen `Variable'="";

qui gen `EST1'=0;

qui gen `EST2'=0;
qui gen `EST2r'=0;
qui gen `EST2a'=0;

qui gen `EST3'=0;
qui gen `EST3r'=0;
qui gen `EST3a'=0;

qui gen `EST4'=0;
qui gen `EST4r'=0;
qui gen `EST4a'=0;

qui gen `EST5'=0;
qui gen `EST5r'=0;
qui gen `EST5a'=0;


local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;
qui replace `EST1'      = `r(est_PS)' in `k1';
qui replace `EST1'      = `r(std_PS)' in `k2';

qui replace `EST2'      = `r(est_H0)' in `k1';
qui replace `EST2'      = `r(std_H0)' in `k2';

qui replace `EST2r'      = `r(r_est_H0)' in `k1';
qui replace `EST2r'      = `r(r_std_H0)' in `k2';

qui replace `EST2a'      = `r(a_est_H0)' in `k1';
qui replace `EST2a'      = `r(a_std_H0)' in `k2';


qui replace `EST3'      = `r(est_M0)' in `k1';
qui replace `EST3'      = `r(std_M0)' in `k2';

qui replace `EST3r'      = `r(r_est_M0)' in `k1';
qui replace `EST3r'      = `r(r_std_M0)' in `k2';

qui replace `EST3a'      = `r(a_est_M0)' in `k1';
qui replace `EST3a'      = `r(a_std_M0)' in `k2';


qui replace `EST4'      = `r(est_M1)' in `k1';
qui replace `EST4'      = `r(std_M1)' in `k2';

qui replace `EST4r'      = `r(r_est_M1)' in `k1';
qui replace `EST4r'      = `r(r_std_M1)' in `k2';

qui replace `EST4a'      = `r(a_est_M1)' in `k1';
qui replace `EST4a'      = `r(a_std_M1)' in `k2';

qui replace `EST5'      = `r(est_M2)' in `k1';
qui replace `EST5'      = `r(std_M2)' in `k2';

qui replace `EST5r'      = `r(r_est_M2)' in `k1';
qui replace `EST5r'      = `r(r_std_M2)' in `k2';

qui replace `EST5a'      = `r(a_est_M2)' in `k1';
qui replace `EST5a'      = `r(a_std_M2)' in `k2';


qui replace `Variable' = "Population" in `k1';


 
if ("`hgroup'"~=""){;

forvalues k=1/$indicag {; 



local kk = gn1[`k'];
local ll=max(`ll',length("`kk': `grlab`k''"));
local component = "Group";

/*
if ( "`grlab`kk''" == "") local grlab`kk' = "Group_`kk'";
qui replace `Variable' = "`kk': `grlab`kk''" in `k';

*/


local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;
local kk = gn1[`k'];
if ( "`grlab`kk''" == "") local grlab`kk' = "Group_`kk'";
qui replace `Variable' = "`kk': `grlab`kk''" in `k1';
dmdafg_af `varlist', hsize(`_ths') hgroup(`hgroup') gnumber(`kk') 
nembarg($indica) dec(`dec') 
pl1(`pl1')  pl2(`pl2') pl3(`pl3') pl4(`pl4') pl5(`pl5') pl6(`pl6') 
w1(`w1')  w2(`w2') w3(`w3') w4(`w4') w5(`w5') w6(`w6')
alpha(`alpha')   dcut(`dcut')
conf(`conf') level(`level');
qui replace `EST1'      = `r(est_PS)' in `k1';
qui replace `EST1'      = `r(std_PS)' in `k2';

qui replace `EST2'      = `r(est_H0)' in `k1';
qui replace `EST2'      = `r(std_H0)' in `k2';

qui replace `EST2r'      = `r(r_est_H0)' in `k1';
qui replace `EST2r'      = `r(r_std_H0)' in `k2';

qui replace `EST2a'      = `r(a_est_H0)' in `k1';
qui replace `EST2a'      = `r(a_std_H0)' in `k2';


qui replace `EST3'      = `r(est_M0)' in `k1';
qui replace `EST3'      = `r(std_M0)' in `k2';

qui replace `EST3r'      = `r(r_est_M0)' in `k1';
qui replace `EST3r'      = `r(r_std_M0)' in `k2';

qui replace `EST3a'      = `r(a_est_M0)' in `k1';
qui replace `EST3a'      = `r(a_std_M0)' in `k2';


qui replace `EST4'      = `r(est_M1)' in `k1';
qui replace `EST4'      = `r(std_M1)' in `k2';

qui replace `EST4r'      = `r(r_est_M1)' in `k1';
qui replace `EST4r'      = `r(r_std_M1)' in `k2';

qui replace `EST4a'      = `r(a_est_M1)' in `k1';
qui replace `EST4a'      = `r(a_std_M1)' in `k2';

qui replace `EST5'      = `r(est_M2)' in `k1';
qui replace `EST5'      = `r(std_M2)' in `k2';

qui replace `EST5r'      = `r(r_est_M2)' in `k1';
qui replace `EST5r'      = `r(r_std_M2)' in `k2';

qui replace `EST5a'      = `r(a_est_M2)' in `k1';
qui replace `EST5a'      = `r(a_std_M2)' in `k2';



};





  
};


local kk1 = `k2'+1;
local kk2 = `k2'+2;
tempname table;
	.`table'  = ._tab.new, col(6);
	.`table'.width |`ll'|16 16 16 16 16|;
	.`table'.strcolor . . yellow . . . ;
	.`table'.numcolor yellow yellow . yellow yellow yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f %16.`dec'f;
	di _n as text "{col 4} Alkire and Foster (2007) MDP indices";
	    di as text     "{col 5}Dimensional cutoff :  `dcut'";
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



local ind2 = "H0"; 
local ind3 = "M0"; 
local ind4 = "M1"; 
local ind5 = "M2"; 

forvalues j = 2/5 {;
	tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width |`ll'|20 20 20 20|;
	.`table'.strcolor . . yellow . . ;
	.`table'.numcolor yellow yellow . yellow yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.2f;
	di _n as text "{col 4} Decomposition of the AF-`ind`j'' index by groups";
                            di as text in white "{col 5}Poverty index   :  `norm'`ind'FGT index";
 	    di as text     "{col 5}Dimensional cutoff :  `dcut'";
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";
     
	.`table'.sep, top;
	.`table'.titles "Group  " "Population"  "    `ind`j''     "  "  Absolute  " "  Relative  " ;
	.`table'.titles "       " "   share   "   "        "  "contribution" "contribution (in %)" ;
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor white yellow yellow yellow yellow ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green   green  green green ;
		  if (`dste'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i'] `EST1'[`i']  `EST`j''[`i'] `EST`j'a'[`i'] `EST`j'r'[`i'];
              	        
                };
  .`table'.sep, mid;
.`table'.numcolor white yellow yellow yellow yellow ;
.`table'.row `Variable'[`kk1'] `EST1'[`kk1']  `EST`j''[`kk1'] `EST`j'a'[`kk1'] `EST`j'r'[`kk1'];
if (`dste'==1){;
.`table'.numcolor white green   green  green green ;
.`table'.row `Variable'[`kk2'] `EST1'[`kk2']  `EST`j''[`kk2'] `EST`j'a'[`kk2'] `EST`j'r'[`kk2'];
};


.`table'.sep,bot;

};

global indica = `k2'/2;

cap drop __compa;
qui gen  __compna=`Variable';

local lng = ($indica*2+2);
qui keep in 1/`lng';


local rnam;
forvalues i=1(2)`lng'  {;
local temn=__compna[`i'];
               local rnam `"`rnam' "`temn'""';
if (`dste'~=0) local rnam `"`rnam' " ""';
};

global rnam `"`rnam'"';
if (`dste'==0) {;
local bf=`lng'/2+1;
forvalues j=2(1)`bf'{;
qui drop in `j';
};
};
tempname zz00;
qui mkmat	 `EST1'  `EST2' `EST2a' `EST2r',	matrix(`zz00');

tempname zz0;
qui mkmat	 `EST1'  `EST3' `EST3a' `EST3r',	matrix(`zz0');

tempname zz1;
qui mkmat	 `EST1'  `EST4' `EST4a' `EST4r',	matrix(`zz1');

tempname zz2;
qui mkmat	 `EST1'  `EST5' `EST5a' `EST5r',	matrix(`zz2');


                                 local index = "AF_Index";
             if ("`xlan'"=="fr") local index = "Indice AF";


local cnam;
			        
if ("`xlan'"~="fr")  local cnam `"`cnam' "Population share""';
if ("`xlan'"=="fr")  local cnam `"`cnam' "Proportion de la population""';
                     local cnam `"`cnam' "`index'""';
if ("`xlan'"~="fr")  local cnam `"`cnam' "Absolute contribution""';
if ("`xlan'"=="fr")  local cnam `"`cnam' "Contribution absolue""';
if ("`xlan'"~="fr")  local cnam `"`cnam' "Relative contribution""';
if ("`xlan'"=="fr")  local cnam `"`cnam' "Contribution relative""';
global cnam `"`cnam'"';

                     local xtit1 = "Table   ##: Decomposition of AF-H0 index by groups";
if ("`xlan'"=="fr")  local xtit1 = "Tableau ##: Dcomposition de l'indice AF-H0 par groupes";
if ("`xtit'"~="")    local xtit1 = "`xtit1'";

                     local xtit2 = "Table   ##: Decomposition of AF-M0 index by groups";
if ("`xlan'"=="fr")  local xtit2 = "Tableau ##: Dcomposition de l'indice AF-M0 par groupes";
if ("`xtit'"~="")    local xtit2 = "`xtit2'";

                     local xtit3 = "Table   ##: Decomposition of AF-M1 index by groups";
if ("`xlan'"=="fr")  local xtit3 = "Tableau ##: Dcomposition de l'indice AF-M1 par groupes";
if ("`xtit'"~="")    local xtit3 = "`xtit3'";

                     local xtit4 = "Table   ##: Decomposition of AF-M2 index by groups";
if ("`xlan'"=="fr")  local xtit4 = "Tableau ##: Dcomposition de l'indice AF-M2 par groupes";
if ("`xtit'"~="")    local xtit4 = "`xtit4'";

if ("`xfil'" ~="") {;
mk_xtab_m1 `1' ,  matn(`zz00') dec(`dec') xfil(`xfil') xshe(Dec_H0) xtit(`xtit1') xlan(`xlan') dste(`dste');
mk_xtab_m1 `1' ,  matn(`zz0') dec(`dec')  xfil(`xfil') xshe(Dec_M0) xtit(`xtit2') xlan(`xlan') dste(`dste');
mk_xtab_m1 `1' ,  matn(`zz1') dec(`dec') xfil(`xfil') xshe(Dec_M1) xtit(`xtit3') xlan(`xlan') dste(`dste');
mk_xtab_m1 `1' ,  matn(`zz2') dec(`dec') xfil(`xfil') xshe(Dec_M2) xtit(`xtit4') xlan(`xlan') dste(`dste');
};
cap matrix drop _vv _aa gn;

restore;
end;





/*

dmdafg  fd_exp nfd_exp, pl1(300) pl2(200) hg( strata) hs(size) index(1);
*/
 
