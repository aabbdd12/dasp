/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.1)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universite Laval, Quebec, Canada                                       */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : efgtgr                                                      */
/*************************************************************************/

#delim ;


capture program drop efgtgr2;
program define efgtgr2, rclass;
version 9.2;
syntax varlist [,  FWeight(string) HSize(string) HGroup(varname)
 GNumber(int -1) AL(real 0) PL(string)  CONF(string) LEVEL(real 95)];
preserve;
tokenize `varlist';
tempvar hs hst;
gen `hs' =`hsize';
gen `hst'=`hsize';


if (`gnumber'!=-1)    qui replace `hs'  =`hs'*(`hgroup'==`gnumber');


cap drop `num' `cnum' `denum';
tempvar num cnum denum;
qui gen   `num'=0;
qui gen  `cnum'=0;
qui gen  `denum'=0;
local al1=`al'-1;

if (`al' == 0)         {;
                        local hweight="";  cap qui svy: total `1'; 
                        local hweight=`"`e(wvar)'"'; cap ereturn clear; 
		       	tempvar fw;
				qui gen `fw' =`hs';
			      if (`"`hweight'"'~="") qui replace `fw' =`hs'*`hweight';
			      qui su `1' [aw=`fw'], detail;           
				local tmp = (`r(p75)'-`r(p25)')/1.34;                          
				local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
				local h   = 0.9*`tmp'*_N^(-1.0/5.0);  
				qui replace   `num' =  -`hs' *`pl'*exp(-0.5* ( ((`pl'-`1')/`h')^2  )  )/( `h'* sqrt(2*c(pi)));  
                        qui replace `denum' = `hst'*(`pl'> `1');
                       };
if (`al' > 0)  {;
                  if (`al1' == 0) qui replace    `cnum' = `hs'*(`pl'> `1');
			if (`al1' >  0) qui replace    `cnum' = `hs'*(1 - `1' / `pl' )^`al1'     if (`pl'>`1');

	            qui replace    `num'   = `hs'*(1 - `1' / `pl' )^`al' - `cnum'         if (`pl'>`1');
                  qui replace    `num' = `al'*`num';
			qui replace    `denum' = `hst'*(1 - `1' / `pl' )^`al'                    if (`pl'>`1');
		    };

qui svy: mean `num' `hs' `denum' `hst';

cap drop matrix _aa;
matrix _aa=e(b);
global ws1=el(_aa,1,1);
global ws2=el(_aa,1,2);
global ws3=el(_aa,1,3);
global ws4=el(_aa,1,4);

local est=($ws1*$ws4)/($ws2*$ws3); 
cap drop matrix mat;
matrix mat=e(V);
cap drop matrix gra;
matrix gra=
(
($ws4)/($ws2*$ws3)\
-($ws1*$ws4)/($ws2^2*$ws3)\
-($ws1*$ws4)/($ws3^2*$ws2)\
($ws1)/($ws2*$ws3)
);
cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std= el(_zz,1,1)^0.5; 



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

capture program drop efgtgr;
program define efgtgr, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) HGroup(varname) 
ALpha(real 0) PLine(real 0) 
CONF(string)
LEVEL(real 95) DEC(int 6)];



if ("`conf'"=="")          local conf="ts";
local ll=0;

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);




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
preserve;
};
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


local ll=length("`1': `grlab`1''");
local component = "Variable";
forvalues k = 1/$indica {;
if ("`hgroup'"=="") {;
qui replace `Variable' = "``k''" in `k';
efgtgr2 ``k'' ,  hsize(`_ths') pl(`pline') al(`alpha')  conf(`conf') level(`level');
qui replace `Estimate' = `r(est)' in `k';
qui replace `STE'      = `r(std)' in `k';
qui replace `LB'       = `r(lb)'  in `k';
qui replace `UB'       = `r(ub)'  in `k';

if ("`conf'"=="lb")   qui replace `UB'       =.  in `k';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `k';

};

if ("`hgroup'"!="") {;
local kk = gn1[`k'];

if ( "`grlab`kk''" == "") local grlab`kk' = "Group_`kk'";
qui replace `Variable' = "`kk': `grlab`kk''" in `k';

efgtgr2 `1' ,   hsize(`_ths') pl(`pline') al(`alpha')   conf(`conf') 
level(`level') hgroup(`hgroup') gnumber(`kk');
qui replace `Estimate' = `r(est)' in `k';
qui replace `STE'      = `r(std)' in `k';
qui replace `LB'       = `r(lb)'  in `k';
qui replace `UB'       = `r(ub)'  in `k';
if ("`conf'"=="lb")   qui replace `UB'       =.  in `k';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `k';

local ll=max(`ll',length("`kk': `grlab`k''"));
local component = "Group";
};

};

local ll=`ll'+6;


if ("`hgroup'"!="") {;
efgtgr2 `1' ,   hsize(`_ths') pl(`pline') al(`alpha')  conf(`conf') level(`level');
local kk =$indica + 1;
qui replace `Variable' = "Population" in `kk';
qui replace `Estimate' = `r(est)' in `kk';
qui replace `STE'      = `r(std)' in `kk';
qui replace `LB'       = `r(lb)'  in `kk';
qui replace `UB'       = `r(ub)'  in `kk';
if ("`conf'"=="lb")   qui replace `UB'       =.  in `kk';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `kk';
};

local 1kk = $indica;
if ("`hgroup'"!="") local  1kk=`kk'-1;
tempname table;
	.`table'  = ._tab.new, col(5)  separator(0) lmargin(0);
	.`table'.width  `ll'|16 16 16 16  ;
	.`table'.strcolor . . yellow . .  ;
	.`table'.numcolor yellow yellow . yellow yellow  ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f;
	                      di _n as text in white "{col 5}Elasticity of total poverty with respect to average income growth.";
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";
       
        di  as text "{col 5}Parameter alpha : "  %5.2f `alpha'       ;
      .`table'.sep, top;
	.`table'.titles "`component'  " "Estimate" "STE "	"  LB  " "  UB  "  ;
	
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`1kk'{;
           		.`table'.row `Variable'[`i'] `Estimate'[`i'] `STE'[`i'] `LB'[`i'] `UB'[`i'] ; 
	};
 if ("`hgroup'"=="")  .`table'.sep,bot;
if ("`hgroup'"!="") {;
  .`table'.sep, mid;
  .`table'.numcolor white green   green  green green  ;
  .`table'.row `Variable'[`kk'] `Estimate'[`kk']  `STE'[`kk'] `LB'[`kk'] `UB'[`kk'] ;
  .`table'.sep,bot;
};


cap ereturn clear;

local est="(";
local std="(";
forvalues i=1/$indica{;
local tem1=`Estimate'[`i'];
local tem2=`STE'[`i'];
 if (`i'!=$indica) local est = "`est'"+ "`tem1'\";
 if (`i'==$indica) local est = "`est'"+ "`tem1')";
 if (`i'!=$indica) local std = "`std'"+ "`tem2'\";
 if (`i'==$indica) local std = "`std'"+ "`tem2')";
};
tempname ES ST;
matrix define `ES'=`est';
matrix define `ST'=`std';
ereturn matrix est = `ES';
ereturn matrix std = `ST';
restore;
end;



