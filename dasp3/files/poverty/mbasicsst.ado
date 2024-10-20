

/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : iwatts                                                        */
/*************************************************************************/

#delim ;





capture program drop isst2n;
program define isst2n, rclass;
version 9.2;
syntax varlist [,  HWeight(string) HSize(string) HGroup(varname) GNumber(int -1)   PL(string) CONF(string) LEVEL(real 95) index(string) *];
preserve;
tokenize `varlist';
                     qui drop if `1'>=. ;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;

sort `1', stable;
tempvar cg;
gen double `cg' = 0;
qui replace    `cg' = (1 - `1'/`pl') if `pl'>`1';



tempvar  hs sw fw ;
gen `sw'=1;
gen `hs'=1;

if ("`hsize'"!="")     qui replace `hs' = `hsize';
tempvar _in;
if ("`hgroup'" != "")  qui gen    `_in' = (`hgroup' == `gnumber');
if ("`hgroup'" != "")  qui replace `hs' = `hs' * `_in';
if ("`hweight'"!="")   qui replace `sw'=`hweight';

gen `fw'=`hs'*`sw';
tempvar smw smwy l1smwy ca;
gen `smw'  =sum(`fw');
gen `smwy' =sum(`cg'*`fw');
gen `l1smwy'=0;
local mu=`smwy'[_N]/`smw'[_N];
local suma=`smw'[_N];
qui count;
forvalues i=2/`r(N)' { ;
qui replace `l1smwy'=`smwy'[`i'-1]  in `i';
};
qui gen `ca'=`mu'+`cg'*((1.0/`smw'[_N])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[_N])*(2.0*`l1smwy'+`fw'*`cg'); 
qui sum `ca' [aw=`fw'], meanonly; 
local gini=`r(mean)'/(2.0);
local xi   = `r(mean)';
tempvar vec_a vec_b  vec_ob theta v1 v2 sv1 sv2;
qui count;

         
            local fx=0;
            gen `v1'=`fw'*`cg';
            gen `v2'=`fw';
            gen `sv1'=sum(`v1');
            gen `sv2'=sum(`v2') ;
            qui replace `v1'=`sv1'[`r(N)']   in 1;
		    qui replace `v2'=`sv2'[`r(N)']   in 1;

            forvalues i=2/`r(N)'  {;
            qui replace `v1'=`sv1'[`r(N)']-`sv1'[`i'-1]   in `i';
		    qui replace `v2'=`sv2'[`r(N)']-`sv2'[`i'-1]   in `i';
            } ;
           
            gen `theta'=`v1'-`v2'*`cg';

           forvalues i=1/`r(N)' {;
                qui replace `theta'=`theta'[`i']*(2.0/`suma')  in `i';
                local fx=`fx'+`fw'[`i']*`cg'[`i'];
            };            
            local fx=`fx'/`suma';
            gen `vec_a' = `hs'*((1.0)*`ca'-`fx'+`theta'-(1.0)*(`xi')-`cg');
            gen `vec_b' =  2*`hs';

            qui svy: ratio `vec_a'/`vec_b'; 

cap drop matrix _aa;
matrix _aa=e(b);
local est = -1*el(_aa,1,1);

cap drop matrix _vv;
matrix _vv=e(V);
local ste = el(_vv,1,1)^0.5;




return scalar pl   = `pl';
return scalar est  = `est';
return scalar ste  = `ste';

end;


#delimit ;
capture program drop mbasicsst;
program define mbasicsst, eclass;
syntax varlist(min=1)[, HSize(varname) HGroup(varname) PLine(string)   XRNAMES(string) *];

tokenize `varlist';
                    local popa = 0;
if "`hgroup'" == "" local popa = 1;
tempvar fw;
version 15.0;
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
qui gen `fw'=`hsize';
if ("`hweight'"~="")    qui replace `fw'=`fw'*`hweight';



/************/

tempvar _ths _fw;
qui gen  `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';
qui gen `_fw'=`_ths';
if (`"`hweight'"'~="") qui replace `_fw'=`_fw'*`hweight';

if (`popa' == 0) {;
if ("`hgroup'" ~="") {;
qui levelsof `hgroup', local(vgr);
local zz = wordcount("`vgr'");
matrix __ms = J(3,`zz',0);
local pos = 1 ;
foreach x of local vgr {;
preserve;
qui keep  if `hgroup' == `x' ;
isst2n `1' , fweight(`_fw') hsize(`_ths') pl(`pline')  ;         
matrix __ms[1,`pos'] =   `r(est)';
matrix __ms[2,`pos'] =   `r(ste)';
matrix __ms[3,`pos'] =   `r(pl)';
local pos = `pos' + 1;
restore; 
};

};

};


if (`popa' == 1) {;
local nvars = wordcount("`varlist'");
matrix __ms = J(3,`nvars',0);
forvalues i = 1/`nvars' {;
isst2n ``i'' , fweight(`_fw') hsize(`_ths') pl(`pline') ;       
matrix __ms[1,`i']  =  `r(est)';
matrix __ms[2,`i']  =  `r(ste)';
matrix __ms[3,`i'] =   `r(pl)';
};	
};

   matrix __ms = __ms ;
ereturn matrix  mmss = __ms ;
end;