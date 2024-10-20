/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.1)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universit Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : imdi                                                       */
/*************************************************************************/


#delim ;
cap program drop dsmdi2;
program define dsmdi2, rclass;
syntax varlist(min=1 max=1) [, FWeight(string) RANK(string) TYPE(string)];
version 8.0;
tokenize `varlist';
qui {;
preserve;
local rho=2;
tempvar fw;
qui gen `fw'=`fweight';
sum `fw';
if ("`rank'"=="") gsort -`1';
if ("`rank'"!="") gsort -`rank';
cap drop if `1' >=.; 
cap drop if `fw'>=.;
qui gen vr = sum(`fw')^`rho'; gen p = vr  - vr[_n-1];
replace p = vr[1] in 1; replace p = p / vr[_N];
gen  xi = sum(p*`1');  local xi = xi[_N];
sum `1' [aw=`fw']; local mu = `r(mean)';
local est = 1 - `xi'/`mu';
if ("`type'"=="abs") local est = `mu' - `xi';
restore; 
};
return scalar est = `est';
return scalar mu   = `mu'  ;
end;



cap program drop imdi2;  
program define imdi2, rclass ;    
version 9.2;         
syntax varlist (max=12) [, FWeight(string) TOT(string) HGroup(varname)  
GNumber(int -1) ISHARE(string)
lam1(real 0.5)  lam2(real 0.5)
lam3(real 0.5)  lam4(real 0.5)
lam5(real 0.5)  lam6(real 0.5)
lam7(real 0.5)  lam8(real 0.5)
lam9(real 0.5)  lam10(real 0.5)
lam11(real 0.5) lam12(real 0.5)

TYPE(string)];
preserve;
tokenize `varlist';
tempvar fw;                 qui gen `fw'=`fweight'; 
if ("`hgroup'"!="") qui replace     `fw'=`fweight'*(`hgroup'==`gnumber');
local est =0;
qui sum `tot' [aw=`fweight'], meanonly; local mut=`r(mean)';
local ish = 1/$ndim;
forvalues i=1/$ndim {;

if ("`ishare'"=="yes") {;
qui sum ``i'' [aw=`fweight'], meanonly; local mus=`r(mean)';
local ish = `mus'/`mut';
};

dsmdi2 ``i'' , fweight(`fw') type(`type');
local est1=`lam`i''*`r(est)'; 
dsmdi2 ``i'' , fweight(`fw') rank(`tot') type(`type');
local est2=(1-`lam`i'')*`r(est)'; 
local est= `est' + `ish'*(`est1'+`est2');
local cest`i' = `ish'*(`est1'+`est2');
};

forvalues i=1/$ndim {;
return scalar est`i'  = `cest`i''/`est' * 100;
};

return scalar est  = `est';
end;     



capture program drop imdi;
program define imdi, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) 
lam1(real 0.5)  lam2(real 0.5)
lam3(real 0.5)  lam4(real 0.5)
lam5(real 0.5)  lam6(real 0.5)
lam7(real 0.5)  lam8(real 0.5)
lam9(real 0.5)  lam10(real 0.5)
lam11(real 0.5) lam12(real 0.5)
lambda(real 0.5) ishare(string)
TYPE(string) HGroup(varname)  
DEC(int 6)];



local ll=0;

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);


_nargs     `varlist';
global ndim=$indica;
cap drop __total; qui gen __total=0;
forvalues i=1/$ndim {;
qui replace __total = __total+``i'';
};

if ("`lambda'"!="") forvalues i=1/12{;
if ("`lam`i''"=="") local lam`i' = `lambda';

};

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

/* ERRORS */

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
tokenize `varlist';
};

if ("`hgroup'"=="") {;
 tokenize `varlist';
_nargs    `varlist';
global indica=1;
preserve;
};


tempvar Variable Estimate STD LB UB;
qui gen `Variable'="";
qui gen `Estimate'=0;
qui gen `STD'=0;

cap drop nvar_i;
qui gen nvar_i="";
forvalues i=1/$ndim {;
local tmp="``i''";
qui gen c_`tmp'=0;
};


tempvar _fw;

qui gen `_fw'=1;
if ( "`hsize'"!="")   qui replace `_fw'=`hsize';

if ( "`hweight'"!="") qui replace `_fw'=`_fw'*`hweight';



local ll=length("`1': `grlab`1''");
local component = "Variable";
forvalues k = 1/$indica {;

if ("`hgroup'"=="") {;
local tind="MDI";


qui replace `Variable' = "MDI_Population" in `k';

qui replace nvar_i = "MDI_Population" in `k';

imdi2 `varlist' , fweight(`_fw')  tot(__total)   
lam1(`lam1')  lam2(`lam2')
lam3(`lam3')  lam4(`lam4')
lam5(`lam5')  lam6(`lam6')
lam7(`lam7')  lam8(`lam8')
lam9(`lam9')  lam10(`lam10')
lam11(`lam11') lam12(`lam12')
ishare(`ishare')
type(`type');

qui replace `Estimate' = `r(est)' in `k';

forvalues i=1/$ndim {;
local tmp="``i''";
qui qui replace c_`tmp'= `r(est`i')' in `k';
};

};



if ("`hgroup'"!="") {;
local kk = gn1[`k'];
local label`k'  : label (`hgroup') `kk';
if "`label`k''"=="" local label`k'="Group: `kk'";
qui replace `Variable' = "`k': `label`k''" in `k';
qui replace nvar_i = "`k': `label`k''" in `k';
imdi2 `varlist' , fweight(`_fw') tot(__total)  
lam1(`lam1')  lam2(`lam2')
lam3(`lam3')  lam4(`lam4')
lam5(`lam5')  lam6(`lam6')
lam7(`lam7')  lam8(`lam8')
lam9(`lam9')  lam10(`lam10')
lam11(`lam11') lam12(`lam12')
hgroup(`hgroup') gnumber(`kk') 
ishare(`ishare')
type(`type');

qui replace `Estimate' = `r(est)' in `k';

forvalues i=1/$ndim {;
local tmp="``i''";
qui qui replace c_`tmp'= `r(est`i')' in `k';
};

local ll=max(`ll',length("`kk': `grlab`k''"));
local component = "Group";
};

};

local ll=`ll'+20;


if ("`hgroup'"!="") {;
local kk =$indica + 1;
qui count;
if (`r(N)'<`kk') qui set obs `kk';
imdi2 `varlist' , fweight(`_fw') tot(__total)  
lam1(`lam1')  lam2(`lam2')
lam3(`lam3')  lam4(`lam4')
lam5(`lam5')  lam6(`lam6')
lam7(`lam7')  lam8(`lam8')
lam9(`lam9')  lam10(`lam10')
lam11(`lam11') lam12(`lam12')
ishare(`ishare')
 type(`type');
qui replace `Variable' = "Population" in `kk';
qui replace nvar_i =  "Population" in `kk';
qui replace `Estimate' = `r(est)' in `kk';
forvalues i=1/$ndim {;
local tmp="``i''";
qui qui replace c_`tmp'= `r(est`i')' in `kk';
};

};

local 1kk = $indica;
local index = "mdi";
if ("`rank'"!="") local index = "Concentration";

if ("`hgroup'"!="") local  1kk=`kk'-1;
tempname table;
	.`table'  = ._tab.new, col(2)  separator(0) lmargin(0);
	.`table'.width  `ll'|16  ;
	.`table'.strcolor . .  ;
	.`table'.numcolor yellow  yellow  ;
	.`table'.numfmt %16.0g  %16.`dec'f   ;
	                      di _n as text in white "{col 5}Index            :  `index' index";
       if ("`hsize'"!="")   di as text     "{col 5}Household size   :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight  :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable   :  `hgroup'";

       
      .`table'.sep, top;
	.`table'.titles "`component'  " "Estimate";
	
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`1kk'{;
           		.`table'.row `Variable'[`i'] `Estimate'[`i']; 
	};
 if ("`hgroup'"=="")  .`table'.sep,bot;
if ("`hgroup'"!="") {;
  .`table'.sep, mid;
  .`table'.numcolor white green    ;
  .`table'.row `Variable'[`kk'] `Estimate'[`kk']  ;
  .`table'.sep,bot;
};


disp _n;
      disp in green  "{hline 60}";
      disp in yellow "Relative Contributions (in %)";
      disp in green  "{hline 60}";
global indica1 = $indica+1;
local ntab=ceil($ndim/5)-1;
forvalues i=0/`ntab' {; 
local b= `i'*5+1;
local e= min(`b'+4,$ndim);
local indica2 = $indica1-1;
if ("`hgroup'"!="") tabdisp  nvar_i in 1/$indica1, cellvar(c_``b''-c_``e'') concise format(%18.2f) left total;
if ("`hgroup'"=="") tabdisp  nvar_i in 1/`indica2', cellvar(c_``b''-c_``e'') concise format(%18.2f);
};

cap ereturn clear;
local kk =$indica + 1;
qui keep in 1/`kk';
tempname ES;
mkmat `Estimate', matrix(`ES');
ereturn matrix est = `ES';
restore;
end;



