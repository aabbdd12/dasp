

/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : isst                                                        */
/*************************************************************************/

#delim ;



capture program drop disst2dn;
program define disst2dn, rclass;
version 9.2;
syntax namelist [,  HWEIGHT1(string) HWEIGHT2(string) HS1(string) HS2(string) PL1(string) PL2(string)  ];

tokenize `namelist';
tempvar num1 num2;
qui gen  `num1'=0;
qui gen  `num2'=0;



sort `1', stable;
tempvar cg1;
gen double     `cg1' = 0;
qui replace    `cg1' = (1 - `1'/`pl1') if `pl1'>`1';

tempvar  sw1 fw1 ;
gen `sw1'=1;

if ("`hweight1'"!="")   qui replace `sw1'=`hweight1';

gen `fw1'=`hs1'*`sw1';


tempvar smw1 smwy1 l1smwy1 ca1;
gen `smw1'  =sum(`fw1');
gen `smwy1' =sum(`cg1'*`fw1');
gen `l1smwy1'=0;
local mu1=`smwy1'[_N]/`smw1'[_N];
local suma1=`smw1'[_N];
qui count;
forvalues i=2/`r(N)' { ;
qui replace `l1smwy1'=`smwy1'[`i'-1]  in `i';
};
qui gen `ca1'=`mu1'+`cg1'*((1.0/`smw1'[_N])*(2.0*`smw1'-`fw1')-1.0) - (1.0/`smw1'[_N])*(2.0*`l1smwy1'+`fw1'*`cg1'); 
qui sum `ca1' [aw=`fw1'], meanonly; 
local gini1=`r(mean)'/(2.0);
local xi1   = `r(mean)';
tempvar vec_a1 vec_b1  theta1 v11 v21 sv11 sv21;
qui count;

         
            local fx1=0;
            gen `v11'=`fw1'*`cg1';
            gen `v21'=`fw1';
            gen `sv11'=sum(`v11');
            gen `sv21'=sum(`v21') ;
            qui replace `v11'=`sv11'[`r(N)']   in 1;
                    qui replace `v21'=`sv21'[`r(N)']   in 1;

            forvalues i=2/`r(N)'  {;
            qui replace `v11'=`sv11'[`r(N)']-`sv11'[`i'-1]   in `i';
                    qui replace `v21'=`sv21'[`r(N)']-`sv21'[`i'-1]   in `i';
            } ;
           
            gen `theta1'=`v11'-`v21'*`cg1';

           forvalues i=1/`r(N)' {;
                qui replace `theta1'=`theta1'[`i']*(2.0/`suma1')  in `i';
                local fx1=`fx1'+`fw1'[`i']*`cg1'[`i'];
            };            
            local fx1=`fx1'/`suma1';
            gen `vec_a1' = `hs1'*((1.0)*`ca1'-`fx1'+`theta1'-(1.0)*(`xi1')-`cg1');
            gen `vec_b1' =  2*`hs1';
            
            qui svy: ratio `vec_a1'/`vec_b1'; 

cap drop matrix _aa;
matrix _aa=e(b);
local est1 = -1*el(_aa,1,1);

cap drop matrix _vv;
matrix _vv=e(V);
local std1 = el(_vv,1,1)^0.5;

sort `2', stable;
tempvar cg2;
gen double     `cg2' = 0;
qui replace    `cg2' = (1 - `2'/`pl2') if `pl2'>`2';

tempvar  sw2 fw2 ;
gen `sw2'=1;

if ("`hweight2'"!="")   qui replace `sw2'=`hweight2';

gen `fw2'=`hs2'*`sw2';
tempvar smw2 smwy2 l1smwy2 ca2;
gen `smw2'  =sum(`fw2');
gen `smwy2' =sum(`cg2'*`fw2');
gen `l1smwy2'=0;
local mu2=`smwy2'[_N]/`smw2'[_N];
local suma2=`smw2'[_N];
qui count;
forvalues i=2/`r(N)' { ;
qui replace `l1smwy2'=`smwy2'[`i'-1]  in `i';
};
qui gen `ca2'=`mu2'+`cg2'*((1.0/`smw2'[_N])*(2.0*`smw2'-`fw2')-1.0) - (1.0/`smw2'[_N])*(2.0*`l1smwy2'+`fw2'*`cg2'); 
qui sum `ca2' [aw=`fw2'], meanonly; 
local gini2=`r(mean)'/(2.0);
local xi2   = `r(mean)';
tempvar vec_a2 vec_b2  vec_ob2 theta2 v12 v22 sv12 sv22;
qui count;

         
            local fx2=0;
            gen `v12'=`fw2'*`cg2';
            gen `v22'=`fw2';
            gen `sv12'=sum(`v12');
            gen `sv22'=sum(`v22') ;
            qui replace `v12'=`sv12'[`r(N)']   in 1;
                    qui replace `v22'=`sv22'[`r(N)']   in 1;

            forvalues i=2/`r(N)'  {;
            qui replace `v12'=`sv12'[`r(N)']-`sv12'[`i'-1]   in `i';
                    qui replace `v22'=`sv22'[`r(N)']-`sv22'[`i'-1]   in `i';
            } ;
           
            gen `theta2'=`v12'-`v22'*`cg2';

           forvalues i=1/`r(N)' {;
                qui replace `theta2'=`theta2'[`i']*(2.0/`suma2')  in `i';
                local fx2=`fx2'+`fw2'[`i']*`cg2'[`i'];
            };            
            local fx2=`fx2'/`suma2';
            gen `vec_a2' = `hs2'*((1.0)*`ca2'-`fx2'+`theta2'-(1.0)*(`xi2')-`cg2');
            gen `vec_b2' =  2*`hs2';

            qui svy: ratio `vec_a2'/`vec_b2'; 

cap drop matrix _aa;
matrix _aa=e(b);
local est2 = -1*el(_aa,1,1);

cap drop matrix _vv;
matrix _vv=e(V);
local std2 = el(_vv,1,1)^0.5;





local dif=`est2'-`est1';


local equa2="";

local equa1 = "(_b[`vec_a1']/_b[`vec_b1'])";
local smean1 = " `vec_a1' `vec_b1' ";

local equa2 = "(_b[`vec_a2']/_b[`vec_b2'])";
local smean2 = " `vec_a2' `vec_b2' ";


qui svy: mean  `smean1' `smean2';

qui nlcom (`equa2'-`equa1'),  iterate(50000);
cap drop matrix _vv;
matrix _vv=r(V);
local sdif = el(_vv,1,1)^0.5;




return scalar std1  = `std1';
return scalar est1  = `est1';
return scalar pl1   = `pl1';



return scalar std2  = `std2';
return scalar est2  = `est2';
return scalar pl2   = `pl2';

return scalar dif  = `dif';
return scalar sdif  = `sdif';


end;





#delimit ;
capture program drop mbasicsst2;
program define mbasicsst2, eclass;
syntax varlist(min=2 max=2) [, HSize1(varname) HSize2(varname) 
PLINE1(string) OPL1(string) PROP1(real 50) PERC1(real 0.4)
PLINE2(string) OPL2(string) PROP2(real 50) PERC2(real 0.4) ALpha(real 0) 
index(string)  HGROUP(varname) XRNAMES(string) type(string) ];

tokenize `varlist';
tempvar fw1 fw2;
version 15.0;
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
qui gen `fw1'=`hsize1';
qui gen `fw2'=`hsize2';
if ("`hweight'"~="")    qui replace `fw1'=`fw1'*`hweight';
if ("`hweight'"~="")    qui replace `fw2'=`fw2'*`hweight';

tempvar  ths1;

qui gen `ths1'=1;
if ( "`hsize1'"!="") qui replace `ths1'=`hsize1';
tempvar  ths2;
qui gen `ths2'=1;
if ( "`hsize2'"!="") qui replace `ths2'=`hsize2';



/************/

if ("`hgroup'" =="") {;
matrix __ms = J(1,6,0);
disst2dn `1' `2' ,   hs1(`ths1') hs2(`ths2')  pl1(`pline1') pl2(`pline2')   ;

matrix __ms[1,1] =  r(est1);
matrix __ms[1,2] =  r(ste1);
matrix __ms[1,3] =  r(est2);
matrix __ms[1,4] =  r(ste3);
matrix __ms[1,5] =  r(dif);
matrix __ms[1,6] =  r(sdif);
};

if ("`hgroup'" ~="") {;
qui levelsof `hgroup', local(vgr);
local zz = wordcount("`vgr'");
matrix __ms = J(`zz',6,0);
local pos = 1 ;
foreach x of local vgr {;
preserve;
qui keep  if `hgroup' == `x' ;
disst2dn `1' `2' ,   hs1(`ths1') hs2(`ths2')  pl1(`pline1') pl2(`pline2')   ;
matrix __ms[`pos',1] =  r(est1);
matrix __ms[`pos',2] =  r(ste1);
matrix __ms[`pos',3] =  r(est2);
matrix __ms[`pos',4] =  r(ste3);
matrix __ms[`pos',5] =  r(dif);
matrix __ms[`pos',6] =  r(sdif);             
local pos = `pos' + 1;
restore; 
};


	
};

matrix __msp = __ms' ;
ereturn matrix __ms = __ms ;
ereturn matrix mmss = __msp ;
end;