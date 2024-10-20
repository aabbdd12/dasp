/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.1)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : ipolder                                                      */
/*************************************************************************/




#delim cr;

cap program drop opth                    
program define opth, rclass 
version 9.2
preserve             
args fw x                        
qui su `x' [aw=`fw'], detail            
local tmp = (`r(p75)'-`r(p25)')/1.34                           
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)'     
local h   = 0.9*`tmp'*_N^(-1.0/5.0)                            
return scalar h =  `h' 
restore 
end

cap program drop oph                    
program define oph, rclass  
version 9.2
args w y m alpha                     
qui su `y' [aw=`w'], detail    
 if (`r(skewness)'>6) local m = 2  
local h  = 0 
      if (`m'==1)  local h = 4.7*_N^-0.5*`r(sd)'*`alpha'^(0.1) // equals25
else if  (`m'==2) {
local inter=(`r(p75)'-`r(p25)')
tempvar ly
gen `ly'=ln(`y')
qui sum `ly' [aw=`w']
local ls=`r(sd)'
local h = _N^-0.5 * `inter' * (3.76 + 14.7 *`ls')/((1+1.09*0.0001*`ls')^(7268+15323*`alpha'))
} // equals26                 
return scalar h = `h'
end


cap program drop fkerv                    
program define fkerv, rclass  sortpreserve
version 9.2
args w y h alpha dname                    
cap drop _fker
gen _fker=0
if (`alpha'==0) qui replace _fker=1

if (`alpha'>0) {
tempvar s1 s2
gen `s2' = sum( `w' )
local pi=3.141592653589793100
qui count
if (`r(N)'>100) dis "WAIT: Estimation of density (`dname') ==>>"

local stp0=`r(N)'/100
local stp=`stp0'
local j=0
local pr=10
local sym = ":"
forvalues i=1/`r(N)' {
cap drop `s1'
gen `s1' = sum( `w' *exp(-0.5* ( ((`y'[`i']-`y')/`h')^2  )  ))
qui replace _fker = (`s1'[_N]/( `h'* sqrt(2*`pi') * `s2'[_N] ))^(`alpha') in `i'
if (`i'>=`stp') {
if `r(N)'>=100 dis    "`sym'", _continue 
 local stp = `stp'+`stp0'
local j=`j' + 1
if (`j'/2 == round(`j'/2)) local sym = ":"
if (`j'/2 != round(`j'/2)) local sym = "."

}
if (`j'==10 ) {
if `r(N)'>=100 dis "`pr'%"
local j=0
local pr=`pr'+10
}
}
if (`r(N)'>=100) dis "<== END"
}
end


cap program drop ckfkerv                    
program define ckfkerv, rclass   sortpreserve   
version 9.2        
syntax varlist(min=1 max=1) [, weight(varname) band(real -1) h(real -1) alpha(real 0) dname(string)]
tokenize `varlist'
cap drop _fker
gen _fker=1.0
if (`alpha'>0) {
qui drop if `1'>=. 
if ("`weight'"~="" ) qui drop if `weight'>=. | `weight'==0
tempvar fw
gen `fw' = 1
if ("`weight'"!="") qui replace `fw'=`weight'
opth `fw' `1'
if (`band'==-1) {
local band=r(h)/2
}
if (`h'==-1) {
local h=r(h)
}
local prc = 4
tempvar group
gen `group'=round(`1'/(`prc'*`band'))+1
qui tab `group'
local ng=r(r) 
tempvar mu gr std pshare
sort `group'
qui tabstat `1' [aweight=`fw' ], statistics( mean sd ) by(`group') columns(variables) save
cap drop `mu' 
cap drop `gr'
cap drop `std'
cap drop `pshare'
gen `mu'  = 0
gen `gr' = 0
gen `std' = 0
gen `pshare'=0
forvalues i=1/`ng' {
qui replace `gr'=`r(name`i')' in `i'
matrix _re = r(Stat`i')
qui replace `mu'=el(_re, 1, 1) in `i'
qui replace `std' =el(_re, 2, 1) in `i'
qui replace `std' = 0 in `i' if `std'[`i']>=.
cap _drop _matrix _re
}

qui sum `fw'
local suma = r(sum)
qui tabstat `fw', statistics(sum) by(`group') columns(variables) save
forvalues i=1/`ng' {
matrix _re = r(Stat`i')
qui replace `pshare'=el(_re, 1, 1)/`suma' in `i'
cap drop matrix _re
}
local pi=3.141592653589793100
qui count
local NN=`r(N)'
local stp0=`NN'/100
set more off
if (`NN'>100) dis "WAIT: Estimation of density (`dname') ==>>"
tempvar ck

local stp=`stp0'
local j=0
local pr=10
local sym = ":"
forvalues i=1/`NN' {

qui gen `ck' = sum( `pshare'/((2*`pi')^0.5*(`std'^2+`h'^2)^0.5)*exp((-(`1'[`i']-`mu')^2)/(2*(`std'^2+`h'^2))) ) in 1/`ng'
qui replace _fker=`ck'[`ng']^`alpha' in `i'
cap drop `ck'

if (`i'>=`stp' & (`NN'>=100)) {
dis "`sym'", _continue 
local stp = `stp'+`stp0'
local j=`j' + 1
if (`j'/2 == round(`j'/2)) local sym = ":"
if (`j'/2 != round(`j'/2)) local sym = "."
}
if (`j'==10 ) {
if (`NN'>=100) dis "`pr'%"
local j=0
local pr=`pr'+10
}
}
if (`NN'>=100)  dis "<== END"

}
end


#delim ;
cap program drop ipolder2;  
program define ipolder2, rclass ;    
version 9.2;         
syntax varlist (min=1 max=1) [, HSize(varname) HWeight(varname) 
HGroup(varname) ALpha(real 0.5) FAST(int 0) 
GNumber(int -1) dname(string) CI(real 5)  CONF(string) LEVEL(real 95)];
preserve;
local ci=100-`level';
tokenize `varlist';
sort `1', stable;

                     qui drop if `1'>=. ;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;
tempvar  hs sw fw ;
gen `sw'=1;
gen `hs'=1;

if ("`hsize'"!="")     qui replace `hs' = `hsize';
tempvar _in;
if ("`hgroup'" != "")  qui gen    `_in' = (`hgroup' == `gnumber');
if ("`hgroup'" != "")  qui replace `hs' = `hs' * `_in';
if ("`hweight'"!="")   qui replace `sw'=`hweight';

gen `fw'=`hs'*`sw';
qui sum `1' [aw=`fw'];
qui replace `1' = `1'/`r(mean)';
tempvar smw smwy l1smwy aa ca;
gen `smw'  =sum(`fw');
gen `smwy' =sum(`1'*`fw');
gen `l1smwy'=0;
local mu=`smwy'[_N]/`smw'[_N];
local suma=`smw'[_N];
qui count;
forvalues i=2/`r(N)' { ;
qui replace `l1smwy'=`smwy'[`i'-1]  in `i';
};

qui gen `aa'=`mu'+`1'*((1.0/`smw'[_N])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[_N])*(2.0*`l1smwy'+`fw'*`1'); 


oph `fw' `1' 1 `alpha';
local h = `r(h)';
if (`fast'!=1)  fkerv `fw' `1' `h' `alpha' "`dname'";
if (`fast'==1)  ckfkerv    `1' , weight(`fw') h(`h') alpha(`alpha') dname(`dname');
gen `ca' = _fker*`aa';  


 qui sum `aa' [aw=`fw'], meanonly;  
 local alien=`r(mean)'/(2.0*`mu');

 qui sum _fker;  
 local ident=`r(mean)';
 
 qui sum `ca' [aw=`fw'], meanonly; 
local polder=`r(mean)'/(2.0*`mu'^(1.0-`alpha'));

local rho = `polder'/(`alien'*`ident')-1;
local tempo = r(mean);


tempvar vec_a vec_b vec_c theta v1 v2 sv1 sv2;
qui count;

            local mfx=0;
            local fx=0;
           
            gen `v1'=`fw'*_fker*`1';
            gen `v2'=`fw'*_fker;
            gen `sv1'=sum(`v1');
            gen `sv2'=sum(`v2') ;
            qui replace `v1'=`sv1'[`r(N)']   in 1;
		qui replace `v2'=`sv2'[`r(N)']   in 1;
            forvalues i=2/`r(N)'  {;
            qui replace `v1'=`sv1'[`r(N)']-`sv1'[`i'-1]   in `i';
		qui replace `v2'=`sv2'[`r(N)']-`sv2'[`i'-1]   in `i';
            }; 
           
                gen `theta'=`v1'-`v2'*`1';
                forvalues i=1/`r(N)'  {;
                qui replace `theta'=`theta'[`i']*(2.0/`suma')  in `i';
                local mfx=`mfx'+`fw'[`i']*_fker[`i'];
                local fx=`fx'+`fw'[`i']*`1'[`i']*_fker[`i'];
            };

            
            local mfx=`mfx'/`suma';
            local fx=`fx'/`suma';   
            gen `vec_a'= `hs'*((1.0+`alpha')*`ca'+(`1'*`mfx'-`fx')+`theta'-(1.0+`alpha')*(`tempo'));
            gen `vec_b'= `hs'*`1'   ;                                                                    
            gen `vec_c'= `hs' ;  
               



local est = `polder';

qui svy:mean `vec_a' `vec_b' `vec_c';
matrix res=e(b);
local s1=el(res,1,1);
local s2=el(res,1,2);
local s3=el(res,1,3);

local v1=1/(`s2'^(1.0-`alpha')*`s3'^`alpha');
local v2=`s1'*(`alpha'-1.0)/(`s2'^(2.0-`alpha')*(`s3'^`alpha') );
local v3=-(`alpha')*`s1'/(`s2'^(1.0-`alpha')*`s3'^(`alpha'+1.0));

matrix grad = (`v1',`v2',`v3');
matrix vv=grad*e(V)*grad';


local std= el(vv,1,1)^0.5/2.0 ;


qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');


return scalar est  = `est';
return scalar std  = `std';
return scalar lb   = `est' - `tt'*`std';
return scalar ub   = `est' + `tt'*`std';


return scalar alien  = `alien';
return scalar ident  = `ident';
return scalar rho    = `rho';

end;     







capture program drop ipolder;
program define ipolder, eclass;
version 9.2;
syntax varlist(min=1)[, 
HSize(varname)  HGroup(varname)
ALpha(real 0.5) FAST(int 0)
CONF(string) LEVEL(real 95) DEC(int 6)];


if ("`conf'"=="")          local conf="ts";
local ll=0;

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);


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
preserve;
};
local ci=100-`level';

tempvar Variable Estimate STE LB UB;
qui gen `Variable'="";
qui gen `Estimate'=0;
qui gen `STE'=0;
qui gen `LB'=0;
qui gen `UB'=0;

tempvar alienat identi correl;

qui gen `alienat'=0;
qui gen `identi'=0;
qui gen `correl'=0;



tempvar _ths;

qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';



local ll=length("`1': `grlab`1''");
local component = "Variable";
forvalues k = 1/$indica {;
if ("`hgroup'"=="") {;


qui replace `Variable' = "`k': ``k''" in `k';

ipolder2 ``k'' , hweight(`hweight') hsize(`_ths') fast(`fast') alpha(`alpha')   conf(`conf') level(`level') dname("``k''");

qui replace `Estimate' = `r(est)' in `k';
qui replace `STE'      = `r(std)' in `k';
qui replace `LB'       = `r(lb)'  in `k';
qui replace `UB'       = `r(ub)'  in `k';

qui replace `alienat'      = `r(alien)'  in `k';
qui replace `identi'       = `r(ident)'  in `k';
qui replace `correl'       = `r(rho)'    in `k';

if ("`conf'"=="lb")   qui replace `UB'       =.  in `k';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `k';




};



if ("`hgroup'"!="") {;
local kk = gn1[`k'];
local label`k'  : label (`hgroup') `kk';
if "`label`k''"=="" local label`k'="Group: `kk'";
qui replace `Variable' = "`k': `label`k''" in `k';

ipolder2 `1' ,  hweight(`hweight')   hsize(`_ths')  fast(`fast') alpha(`alpha')  conf(`conf')   dname("`label`k''")
level(`level') hgroup(`hgroup') gnumber(`kk');
qui replace `Estimate' = `r(est)' in `k';
qui replace `STE'      = `r(std)' in `k';
qui replace `LB'       = `r(lb)'  in `k';
qui replace `UB'       = `r(ub)'  in `k';

qui replace `alienat'      = `r(alien)'  in `k';
qui replace `identi'       = `r(ident)'  in `k';
qui replace `correl'       = `r(rho)'    in `k';


if ("`conf'"=="lb")   qui replace `UB'       =.  in `k';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `k';

local ll=max(`ll',length("`kk': `grlab`k''"));
local component = "Group";



};

};

local ll=`ll'+10;


if ("`hgroup'"!="") {;
local kk =$indica + 1;
qui count;
if (`r(N)'<`kk') qui set obs `kk';
ipolder2 `1' ,   hweight(`hweight') hsize(`_ths') fast(`fast') alpha(`alpha')    conf(`conf') level(`level') dname("`1'");
qui replace `Variable' = "Population" in `kk';
qui replace `Estimate' = `r(est)' in `kk';
qui replace `STE'      = `r(std)' in `kk';
qui replace `LB'       = `r(lb)'  in `kk';
qui replace `UB'       = `r(ub)'  in `kk';

qui replace `alienat'      = `r(alien)'  in `kk';
qui replace `identi'       = `r(ident)'  in `kk';
qui replace `correl'       = `r(rho)'    in `kk';

if ("`conf'"=="lb")   qui replace `UB'       =.  in `kk';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `kk';
};

local 1kk = $indica;
local index = "Duclos Esteban and Ray Index of polarization (2004)";


if ("`hgroup'"!="") local  1kk=`kk'-1;

tempname table;
	.`table'  = ._tab.new, col(5)  separator(0) lmargin(0);
	.`table'.width  `ll'|16 16 16 16 ;
	.`table'.strcolor . . yellow . . ;
	.`table'.numcolor yellow yellow . yellow yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f ;
	                      di _n as text in white "{col 5}Index            :  `index'";
                            di as text     "{col 5}Paremeter alpha  :  `alpha'";
       if ("`hsize'"!="")   di as text     "{col 5}Household size   :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight  :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable   :  `hgroup'";

       
      .`table'.sep, top;
	.`table'.titles "`component'  " "Estimate" "STE "	"  LB  " "  UB  ";
	
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`1kk'{;
           		.`table'.row `Variable'[`i'] `Estimate'[`i'] `STE'[`i'] `LB'[`i'] `UB'[`i']; 
	};
 if ("`hgroup'"=="")  .`table'.sep,bot;
if ("`hgroup'"!="") {;
  .`table'.sep, mid;
  .`table'.numcolor white green   green  green green ;
  .`table'.row `Variable'[`kk'] `Estimate'[`kk']  `STE'[`kk'] `LB'[`kk'] `UB'[`kk'];
  .`table'.sep,bot;
};



tempname table;
	.`table'  = ._tab.new, col(4)  separator(0) lmargin(0);
	.`table'.width  `ll'|16 16 16  ;
	.`table'.strcolor . . yellow .  ;
	.`table'.numcolor yellow yellow . yellow  ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f ;
	                      di _n as text in white "{col 5}Main polarization components";  
      .`table'.sep, top;
	.`table'.titles "`component'  " "Alienation   " "    Identification "	   "Correlation ";
	
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`1kk'{;
           		.`table'.row `Variable'[`i'] `alienat'[`i'] `identi'[`i'] `correl'[`i']; 
	};
 if ("`hgroup'"=="")  .`table'.sep,bot;
if ("`hgroup'"!="") {;
  .`table'.sep, mid;
  .`table'.numcolor white green   green  green  ;
  .`table'.row `Variable'[`kk'] `alienat'[`kk'] `identi'[`kk'] `correl'[`kk'];
  .`table'.sep,bot;
};

cap ereturn clear;
local kk =$indica + 1;
qui keep in 1/`kk';
tempname ES ST;
mkmat `Estimate', matrix(`ES');
ereturn matrix est = `ES';
mkmat `STE', matrix(`ST');
ereturn matrix std = `ST';
restore;
end;



