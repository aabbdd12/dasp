/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : dipolder                                                     */
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
      if (`m'==1)  local h = 4.7*_N^-0.5*`r(sd)'*`alpha'^(0.1) // is equal to25
else if  (`m'==2) {
local inter=(`r(p75)'-`r(p25)')
tempvar ly
gen `ly'=ln(`y')
qui sum `ly' [aw=`w']
local ls=`r(sd)'
local h = _N^-0.5 * `inter' * (3.76 + 14.7 *`ls')/((1+1.09*0.0001*`ls')^(7268+15323*`alpha'))
} // is equal to26                 
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
cap program drop dipolder2;  
program define dipolder2, rclass sortpreserve;     
version 9.2;         
syntax varlist (min=1 max=1) [, HSize(varname) HWeight(varname) 
HGroup(varname) ALpha(real 0.5) FAST(int 0)  BAND(string)
GNumber(int -1) dname(string) CI(real 5)  CONF(string) LEVEL(real 95) VAB(real 0) ];
tokenize `varlist';
sort `1', stable;

                       qui drop if `1'>=. ;
if ("`hsize'"  !="")   qui drop if `hsize'>=.;
if ("`hweight'"!="")   qui drop if `hweight'>=.;
tempvar  hs sw fw ;
gen `sw'=1;
gen `hs'=1;

if ("`hsize'"!="")     qui replace `hs' = `hsize';
tempvar _in;
if ("`hgroup'" != "")  qui gen    `_in' = (`hgroup' == `gnumber');
if ("`hgroup'" != "")  qui replace `hs' = `hs' * `_in';
if ("`hweight'"!="")   qui replace `sw'=`hweight';

gen `fw'=`hs'*`sw';
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
if ("`band'"!="")  local h = `band';
if (`fast'!=1)  fkerv `fw' `1' `h' `alpha' "`dname'";
if (`fast'==1)  ckfkerv  `1' , weight(`fw') h(`h') alpha(`alpha') dname(`dname');
gen `ca' = _fker*`aa';  

 qui sum `ca' [aw=`fw'], meanonly; 
local polder=`r(mean)'/(2.0*`mu'^(1.0-`alpha'));
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
return scalar df   = `fr';

if (`vab'==1) {;
qui gen __va=`vec_a';
qui gen __vb=`vec_b';
qui gen __vc=`vec_c';
return scalar gr1  = `v1';
return scalar gr2  = `v2';
return scalar gr3  = `v3';
};

end;     





capture program drop dipolder;
program define dipolder, eclass;
version 9.2;
syntax  namelist(min=2 max=2) [, 
FILE1(string) FILE2(string) 
HSize1(string) HSize2(string)
COND1(string)  COND2(string)
ALpha(real 0.5) FAST(int 0)  
LEVEL(real 95) CONF(string) TEST(string) DEC(int 6) BAND(string) *];

global indica=3;
tokenize `namelist';
if ("`conf'"=="")          local conf="ts";

preserve;
local indep = ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  );
local vab=0;
if ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) local vab=1;
if ("`file1'" !="") use `"`file1'"', replace;
tempvar cd1;
tempvar ths1;
qui gen `ths1'=1;

if ( "`hsize1'"!="") qui replace `ths1'=`hsize1';

if ( "`cond1'"!="") {;
gen `cd1'=`cond1';
qui replace `ths1'=`ths1'*`cd1';
qui sum `cd1';
if (`r(sum)'==0) {;
dis as error " With the condition(s) of distribution_1, the number of observations is 0.";
exit;
};
};

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight1=""; 
cap qui svy: total `1'; 
local hweight1=`"`e(wvar)'"';
cap ereturn clear; 

dipolder2 `1' , hweight(`hweight1') hsize(`ths1') alpha(`alpha') fast(`fast') conf(`conf') level(`level') vab(`vab') dname("Distribution 1") band(`band') ;

if (`vab'==1) {;
tempvar va vb vc;
qui gen `va'=__va;
qui gen `vb'=__vb;
qui gen `vc'=__vc;
qui drop __va __vb __vc;
global v1 = `r(gr1)';
global v2 = `r(gr2)';
global v3 = `r(gr3)';
};
matrix _res_d1  =(`r(est)',`r(std)',`r(lb)',`r(ub)', `r(df)') ;


if ("`file2'" !="" & `vab'!=1) use `"`file2'"', replace;
tempvar cd2 ths2;
qui gen `ths2'=1;
if ( "`hsize2'"!="") qui replace `ths2'=`hsize2';
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace `ths2'=`ths2'*`cd2';
qui sum `cd2';
if (`r(sum)'==0) {;
dis as error " With the condition(s) of distribution_2, the number of observations is 0.";
exit;
};
};
qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local hweight2=""; 
cap qui svy: total `2'; 
local hweight2=`"`e(wvar)'"';
cap ereturn clear; 



dipolder2 `2' , hweight(`hweight2') hsize(`ths2') alpha(`alpha') fast(`fast') conf(`conf') level(`level') vab(`vab') dname("Distribution 2") band(`band');
if (`vab'==1) {;
tempvar vd ve vf;
qui gen `vd'=__va;
qui gen `ve'=__vb;
qui gen `vf'=__vc;
qui drop __va __vb __vc;
global v4 = -`r(gr1)';
global v5 = -`r(gr2)';
global v6 = -`r(gr3)';
};



matrix _res_d2 =(`r(est)',`r(std)',`r(lb)',`r(ub)', `r(df)' );
local dif = el(_res_d2,1,1)-el(_res_d1,1,1);
local std = (el(_res_d1,1,2)^2+el(_res_d2,1,2)^2)^0.5;
if (`vab'==1) {;
qui svy: mean `va' `vb' `vc' `vd' `ve' `vf' ;
matrix grad = ($v1,$v2,$v3,$v4,$v5,$v6);
matrix vv=grad*e(V)*grad';
local std= el(vv,1,1)^0.5/2.0 ;
}; 
local sdif=`std';

local index = "Duclos, Esteban and Ray index of polarization (2004) (DER)";
local tyind1="DER_Dis1";
local tyind2="DER_Dis2";

dis  "dec = `dec'";
      tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width  24|16 16 16 16 ;
	.`table'.strcolor . . yellow . . ;
	.`table'.numcolor yellow yellow . yellow yellow;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f ;
      di _n as text in white "{col 5}Index            :  `index' index";
      di as text     "{col 5}Paremeter alpha  :  `alpha'";
       
local est1=el(_res_d1,1,1);
local est2=el(_res_d2,1,1);

local std1=el(_res_d1,1,2);
local std2=el(_res_d2,1,2);

local df1=el(_res_d1,1,5);
local df2=el(_res_d2,1,5);
     




_dasp_dif_table `2' `2', 
name1("`tyind1'")          name2("`tyind2'")
m1(`est1')            m2(`est2')
s1(`std1')            s2(`std2')
df1(`df1')            df2(`df2')
dif(`dif') sdif(`sdif')
level(`level') conf(`conf') indep(`indep') test(`test');


restore;
ereturn clear;
ereturn matrix d1 = _res_d1;
ereturn matrix d2 = _res_d2;


cap matrix drop _res_d1;
cap matrix drop _res_d2;

end;



