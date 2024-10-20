/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 1.4)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2008)          */
/* Université Laval, Quebec, Canada                                    */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : imdpov                                                      */
/* 1- Chakravarty et al (1998)   		: eq(06) // Union              */
/* 2- Extended Watts             		: eq(08) // Union              */
/* 3- Extended FGT               		: eq(09) // Intersection       */
/* 4- Tsui (2002)                		: eq(10) // Intersection       */
/* 5- Intersection headcount index                                       */
/* 6- Union headcount index                                              */ 
/* 7- Bourguignon and Chakravarty (2003) 	: eq(14) //                    */                                   
/*************************************************************************/



#delim ;

capture program drop imdpov2;
program define imdpov2, rclass;
version 9.2;
syntax varlist [,  HSize(string) HGroup(varname) GNumber(int -1)
nembarg(int 1) 
dec(int 3)
INDex(int 1)
PL1(real 0)  PL2(real 0) PL3(real 0) PL4(real 0) PL5(real 0) PL6(real 0)
A1(real 1)   A2(real 1)  A3(real 1)  A4(real 1)  A5(real 1)  A6(real 1)
ALPHA(real 1) GAMMA(real 1) BETA(real 1)
B1(real 0)   B2(real 0)  B3(real 0)  B4(real 0)  B5(real 0)  B6(real 0)
AL1(real 0)  AL2(real 0) AL3(real 0) AL4(real 0) AL5(real 0) AL6(real 0)
CONF(string)
LEVEL(real 95) 
];

preserve;
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





capture program drop imdpov;
program define imdpov, rclass;
version 9.2;
syntax varlist(min=1)[,  
HSize(varname)
HGroup(varname)
dec(int 3)
INDex(int 1)
PL1(real 0)  PL2(real 0) PL3(real 0) PL4(real 0) PL5(real 0) PL6(real 0)
A1(real 1)   A2(real 1)  A3(real 1)  A4(real 1)  A5(real 1)  A6(real 1) alpha(real 1)  beta(real 1) gamma(real 1)
B1(real 1)   B2(real 1)  B3(real 1)  B4(real 1)  B5(real 1)  B6(real 1)
AL1(real 0)  AL2(real 0) AL3(real 0) AL4(real 0) AL5(real 0) AL6(real 0)
CONF(string)
LEVEL(real 95) 
];


qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

global indicag=0;
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

/* ERRORS */

if (`alpha' == 0 & "`index'"=="ede") {;
 di as err "For the EDE index, the parameter alpha should be greater than 0."; exit;
};


if ("`opl'"=="median")   {;
local opl = "quantile";
local perc = 0.5;
};


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

local ci=100-`level';
tempvar Variable Estimate STD LB UB PL;
qui gen `Variable'="";
qui gen `Estimate'=0;
qui gen `STD'=0;
qui gen `LB'=0;
qui gen `UB'=0;
qui gen `PL'=0;

tempvar _ths _fw;

qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';
qui gen `_fw'=`_ths';
if (`"`hweight'"'~="") qui replace `_fw'=`_fw'*`hweight';


tempvar _ths;


qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';




imdpov2 `varlist', hsize(`_ths') nembarg($indica) dec(`dec') index(`index')
pl1(`pl1')  pl2(`pl2') pl3(`pl3') pl4(`pl4') pl5(`pl5') pl6(`pl6') 
a1(`a1')  a2(`a2') a3(`a3') a4(`a4') a5(`a5') a6(`a6')
b1(`b1')  b2(`b2') b3(`b3') b4(`b4') b5(`b5') b6(`b6')
al1(`al1')  al2(`al2') al3(`al3') al4(`al4') al5(`al5') al6(`al6')
alpha(`alpha') gamma(`gamma') beta(`beta') 
conf(`conf') level(`level');
local ll = 12;
local k=1;
if ("`hgroup'"~="") local k=$indicag+1;

qui replace `Variable' = "Population" in `k';
qui replace `Estimate' = `r(est)' in `k';
qui replace `STD'      = `r(std)' in `k';
qui replace `LB'       = `r(lb)'  in `k';
qui replace `UB'       = `r(ub)'  in `k';
if ("`conf'"=="lb")   qui replace `UB'       =.  in `k';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `k';
 
if ("`hgroup'"~=""){;

forvalues k=1/$indicag {; 



local kk = gn1[`k'];
if ( "`grlab`kk''" == "") local grlab`kk' = "Group_`kk'";
qui replace `Variable' = "`kk': `grlab`kk''" in `k';

local ll=max(`ll',length("`kk': `grlab`k''"));
local component = "Group";

imdpov2 `varlist', hsize(`_ths') hgroup(`hgroup') gnumber(`kk') 
nembarg($indica) dec(`dec') index(`index')
pl1(`pl1')  pl2(`pl2') pl3(`pl3') pl4(`pl4') pl5(`pl5') pl6(`pl6') 
a1(`a1')  a2(`a2') a3(`a3') a4(`a4') a5(`a5') a6(`a6')
b1(`b1')  b2(`b2') b3(`b3') b4(`b4') b5(`b5') b6(`b6')
al1(`al1')  al2(`al2') al3(`al3') al4(`al4') al5(`al5') al6(`al6')
alpha(`alpha')  gamma(`gamma') beta(`beta')
conf(`conf') level(`level');
qui replace `Estimate' = `r(est)' in `k';
qui replace `STD'      = `r(std)' in `k';
qui replace `LB'       = `r(lb)'  in `k';
qui replace `UB'       = `r(ub)'  in `k';
if ("`conf'"=="lb")   qui replace `UB'       =.  in `k';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `k';
};

};




                   local sindex="Chakravarty et al (1998)                       ";
if (`index'==2)    local sindex="Extended Watts                                 ";
if (`index'==3)    local sindex="Extended FGT                                   ";
if (`index'==4)    local sindex="Tsui (2002)                                    ";
if (`index'==5)    local sindex="Intersection headcount index                   ";
if (`index'==6)    local sindex="Union headcount index                          ";
if (`index'==7)    local sindex="Bourguignon and Chakravarty (2003)             ";



  tempname table;
	.`table'  = ._tab.new, col(5)  separator(0) lmargin(0);

	.`table'.width  `ll' | 16 16 16 16 |;

	.`table'.strcolor . . yellow . .  ;

	.`table'.numcolor yellow yellow . yellow yellow  ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f ;
	                      di _n as text in white "{col 5}M.D. Poverty index :  `sindex'";

       if ("`hsize'"!="")   di as text     "{col 5}Household size     :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight    :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable     :  `hgroup'";
      .`table'.sep, top;
	.`table'.titles "`component'  " "Estimate" "STD "	"  LB  " "  UB  " ;
	
	.`table'.sep, mid;
	local nalt = "ddd";
      if ("`hgroup'"~=""){;

		forvalues k=1/$indicag {; 
						.`table'.row `Variable'[`k'] `Estimate'[`k'] `STD'[`k'] `LB'[`k'] `UB'[`k'] ; 
						};
                         .`table'.sep,mid;
				};
     .`table'.row `Variable'[$indicag+1] `Estimate'[$indicag+1] `STD'[$indicag+1] `LB'[$indicag+1] `UB'[$indicag+1] ; 

   .`table'.sep,bot;    

end;

/*

imdpov  fd_exp nfd_exp, pl1(300) pl2(200) hg( strata) hs(size) index(1);
*/
 
