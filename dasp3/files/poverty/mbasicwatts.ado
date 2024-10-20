

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



capture program drop iwatts2n;
program define iwatts2n, rclass;
version 9.2;
syntax varlist [,  FWeight(string) HSize(string) HGroup(varname) GNumber(int -1)   PL(string) index(string)];
preserve;
tokenize `varlist';
cap drop if `1' ==.;
tempvar hs hsy;
gen `hs' =`hsize';

if (`gnumber'!=-1)    qui replace `fweight'=`fweight'*(`hgroup'==`gnumber');
if (`gnumber'!=-1)    qui replace `hs'  =`hs'*(`hgroup'==`gnumber');

cap drop `num' `snum';
tempvar num snum;
qui gen   `num'=0;
qui gen  `snum'=0;
qui replace    `num' = `hs'*-(log(`1')-log(`pl')) if (`pl'> `1');

qui svy: ratio `num'/`hs';
cap drop matrix _aa;
matrix _aa=e(b);
local est = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local ste = el(_vv,1,1)^0.5;



return scalar pl   = `pl';
return scalar est  = `est';
return scalar ste  = `ste';

end;


#delimit ;
capture program drop mbasicwatts;
program define mbasicwatts, eclass;
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
iwatts2n `1' , fweight(`_fw') hsize(`_ths') pl(`pline')  ;         
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
iwatts2n ``i'' , fweight(`_fw') hsize(`_ths') pl(`pline') ;       
matrix __ms[1,`i']  =  `r(est)';
matrix __ms[2,`i']  =  `r(ste)';
matrix __ms[3,`i'] =   `r(pl)';
};	
};

   matrix __ms = __ms ;
ereturn matrix  mmss = __ms ;
end;