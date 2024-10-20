/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.1)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universite Laval, Quebec, Canada                                       */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : efgtineq                                                      */
/*************************************************************************/

#delim ;


capture program drop efgtineq2;
program define efgtineq2, rclass;
version 9.2;
syntax varlist [,  HWeight(string) HSize(string) HGroup(varname)
 GNumber(int -1) AL(real 0) PL(string)  CONF(string) LEVEL(real 95)];
preserve;
tokenize `varlist';
                     qui drop if `1'>=. ;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`fweight'"!="") qui drop if `fweight'>=.;
tempvar hs hst;
gen `hs' =`hsize';
gen `hst'=`hsize';


if ("`hgroup'"~="")     qui replace `hs'  =`hs'*(`hgroup'==`gnumber');






 sort `1', stable;


tempvar sw fw fwt ;
gen `sw'=1;
if ("`hweight'"!="")   qui replace `sw'=`hweight';

gen `fw' =`hs'*`sw';
gen `fwt'=`hst'*`sw';



tempvar smw smwt smwy smwyt l1smwy l1smwyt ca;
gen `smw'   =sum(`fw');
gen `smwy'  =sum(`1'*`fw');
local mug=`smwy'[_N]/`smw'[_N];

tempvar inc;
gen `inc'=`1'; 
if ("`hgroup'"~="")  qui replace `inc'=`mug' if `hgroup'!=`gnumber';

gen `smwt'   =sum(`fwt');
gen `smwyt'  =sum(`inc'*`fwt');
local mug=`smwy'[_N]/`smw'[_N];


gen `l1smwyt'=0; 

local sumat=`smwt'[_N];
qui count;


forvalues i=2/`r(N)' { ; qui replace `l1smwyt'=`smwyt'[`i'-1]  in `i'; };

gen `ca'=`mug'+`inc'*((1.0/`smwt'[_N])*(2.0*`smwt'-`fwt')-1.0) - (1.0/`smwt'[_N])*(2.0*`l1smwyt'+`fwt'*`inc'); 

qui sum `ca' [aw=`fwt'], meanonly; 
local xi = `r(mean)';
tempvar vec_ag  theta v1 v2 sv1 sv2;
qui count;
            local fx=0;
            gen `v1'=`fwt'*`inc';
            gen `v2'=`fwt';
            gen `sv1'=sum(`v1');
            gen `sv2'=sum(`v2') ;
            qui replace `v1'=`sv1'[`r(N)']   in 1;
		qui replace `v2'=`sv2'[`r(N)']   in 1;

            forvalues i=2/`r(N)'  {;
            qui replace `v1'=`sv1'[`r(N)']-`sv1'[`i'-1]   in `i';
		qui replace `v2'=`sv2'[`r(N)']-`sv2'[`i'-1]   in `i';
            } ;
            
           gen `theta'=`v1'-`v2'*`inc';
           forvalues i=1/`r(N)' {;
                qui replace `theta'=`theta'[`i']*(2.0/`sumat')  in `i';
                local fx=`fx'+`fwt'[`i']*`inc'[`i'];
            };  
         
            local fx=`fx'/`sumat';
            gen `vec_ag' =  `hst'*((1.0)*`ca'+(`inc'-`fx')+`theta'-(1.0)*(`xi'));
 

cap drop `ca'; 
tempvar smw smwy l1smwy ca;
gen `smw'  =sum(`fwt');
gen `smwy' =sum(`1'*`fwt');
gen `l1smwy'=0;
local mu=`smwy'[_N]/`smw'[_N];

local suma=`smw'[_N];
qui count;
forvalues i=2/`r(N)' { ;
qui replace `l1smwy'=`smwy'[`i'-1]  in `i';
};
gen `ca'=`mu'+`1'*((1.0/`smw'[_N])*(2.0*`smw'-`fwt')-1.0) - (1.0/`smw'[_N])*(2.0*`l1smwy'+`fwt'*`1'); 
qui sum `ca' [aw=`fwt'], meanonly; 
local xi = `r(mean)';

tempvar vec_a vec_b  theta v1 v2 sv1 sv2;
qui count;
            local fx=0;
            gen `v1'=`fwt'*`1';
            gen `v2'=`fwt';
            gen `sv1'=sum(`v1');
            gen `sv2'=sum(`v2') ;
            qui replace `v1'=`sv1'[`r(N)']   in 1;
		qui replace `v2'=`sv2'[`r(N)']   in 1;

            forvalues i=2/`r(N)'  {;
            qui replace `v1'=`sv1'[`r(N)']-`sv1'[`i'-1]   in `i';
		qui replace `v2'=`sv2'[`r(N)']-`sv2'[`i'-1]   in `i';
            } ;
           
            gen `theta'=`v1'-`v2'*`1';

           forvalues i=1/`r(N)' {;
                qui replace `theta'=`theta'[`i']*(2.0/`suma')  in `i';
                local fx=`fx'+`fwt'[`i']*`1'[`i'];
            };            
            local fx=`fx'/`suma';
            gen `vec_a' = `hst'*((1.0)*`ca'+(`1'-`fx')+`theta'-(1.0)*(`xi'));




cap drop `num1' `num2' `num3' `num4' `num5';
tempvar num1 num2 num3 num4 num5;
qui gen  `num1'=0;
qui gen  `num2'=0;
qui gen  `num3'=0;
qui gen  `num4'=0;
qui gen  `num5'=0;

local al1=`al'-1;


if (`al' == 0)         {;
                        tempvar fww;
			      qui gen `fww' =`hs'*`hweight';
			      qui su `1' [aw=`fww'], detail;           
				local tmp = (`r(p75)'-`r(p25)')/1.34;                          
				local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;
                        qui count;   
                        if( "`hgroup'"~="") qui count if `hgroup'== `gnumber'; 
				local h   = 0.9*`tmp'*`r(N)'^(-1.0/5.0);  
				qui replace    `num1' = `hs' *exp(-0.5* ( ((`pl'-`1')/`h')^2  )  )/( `h'* sqrt(2*c(pi)));  
                        qui replace    `num3' = `hst'*(`pl'> `1') if (`pl'>`1');
				qui replace    `num4' = `hs'*(`1'-`pl');                     
                        qui replace    `num5' = `hs';  

qui svy: mean `vec_a' `vec_ag'  `num1' `num3' `num4' `num5';

cap drop matrix _aa;
matrix _aa=e(b);
global ws1=el(_aa,1,1);
global ws2=el(_aa,1,2);
global ws3=el(_aa,1,3);
global ws4=el(_aa,1,4);
global ws5=el(_aa,1,5);
global ws6=el(_aa,1,6);


local est=($ws1/$ws2)*($ws3/$ws4)*($ws5/$ws6); 

cap drop matrix mat;
matrix mat=e(V);
cap drop matrix gra;
matrix gra=
(
(1/$ws2)*($ws3/$ws4)*($ws5/$ws6)\
-($ws1/$ws2^2)*($ws3/$ws4)*($ws5/$ws6)\
($ws1/$ws2)*(1/$ws4)*($ws5/$ws6)\
-($ws1/$ws2)*($ws3/$ws4^2)*($ws5/$ws6)\
($ws1/$ws2)*($ws3/$ws4)*(1/$ws6)\
-($ws1/$ws2)*($ws3/$ws4)*($ws5/$ws6^2)
);

cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std= el(_zz,1,1)^0.5; 
   
                       };
if (`al' > 0)  {;


qui replace                    `num1' = `hs'*(1 - `1' / `pl' )^`al'          if (`pl'>`1');
if (`al1' == 0) qui replace    `num2' = `hs'*(`pl'> `1')                     if (`pl'>`1');
if (`al1' >  0) qui replace    `num2' = `hs'*(1 - `1' / `pl' )^`al1'         if (`pl'>`1');
                qui replace    `num3' = `hst'*(1 - `1' / `pl' )^`al'         if (`pl'>`1');	
		    qui replace    `num4' = `hs'*(`1'-`pl');                     
                qui replace    `num5' = `hs'*`pl';     


qui svy: mean `vec_a' `vec_ag'  `num1' `num2' `num3' `num4' `num5';

cap drop matrix _aa;
matrix _aa=e(b);
global ws1=el(_aa,1,1);
global ws2=el(_aa,1,2);
global ws3=el(_aa,1,3);
global ws4=el(_aa,1,4);
global ws5=el(_aa,1,5);
global ws6=el(_aa,1,6);
global ws7=el(_aa,1,7);

local est=`al'*($ws1/$ws2)*($ws3/$ws5+($ws4/$ws5)*($ws6/$ws7)); 

cap drop matrix mat;
matrix mat=e(V);
cap drop matrix gra;
matrix gra=
(
(1/$ws2)*($ws3/$ws5+($ws4/$ws5)*($ws6/$ws7))\
-($ws1/$ws2^2)*($ws3/$ws5+($ws4/$ws5)*($ws6/$ws7))\
($ws1/$ws2)*(1/$ws5)\
($ws1/$ws2)*((1/$ws5)*($ws6/$ws7))\
-($ws1/$ws2)*($ws3/$ws5^2+($ws4/$ws5^2)*($ws6/$ws7))\
($ws1/$ws2)*(($ws4/$ws5)*(1/$ws7))\
-($ws1/$ws2)*(($ws4/$ws5)*($ws6/$ws7^2))
);

cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std= `al'*el(_zz,1,1)^0.5; 
               
};





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

capture program drop efgtineq;
program define efgtineq, eclass;
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

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
if (`"`hweight'"'=="") {;
tempvar hweight; qui gen `hweight'=1;
};

qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';
qui gen `_fw'=`_ths';
if (`"`hweight'"'~="") qui replace `_fw'=`_fw'*`hweight';




local ll=length("`1': `grlab`1''");
local component = "Variable";
forvalues k = 1/$indica {;
if ("`hgroup'"=="") {;
qui replace `Variable' = "``k''" in `k';
efgtineq2 ``k'' ,  hweight(`hweight')  hsize(`_ths') pl(`pline') al(`alpha')  conf(`conf') level(`level');
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

efgtineq2 `1' ,   hweight(`hweight') hsize(`_ths') pl(`pline') al(`alpha')   conf(`conf') 
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
set more off;
set trace off;
set tracedepth 2;

if ("`hgroup'"!="") {;
efgtineq2 `1' , hweight(`hweight')  hsize(`_ths') pl(`pline') al(`alpha')  conf(`conf')
 level(`level');
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
	                      di _n as text in white "{col 5}Elasticity of total poverty with respect to inequality.";
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";
       
        di  as text "{col 5}Parameter alpha : "  %5.2f `alpha'       ;
        di  as text "{col 5}Poverty line    : "  %12.2f `pline'       ;
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



