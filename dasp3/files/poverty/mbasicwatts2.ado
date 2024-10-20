

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



capture program drop diwatts2dn;
program define diwatts2dn, rclass;
version 9.2;
syntax namelist [,  FWEIGHT1(string) FWEIGHT2(string) HS1(string) HS2(string)  PL1(string) PL2(string)  ];

tokenize `namelist';
tempvar num1 num2;
qui gen  `num1'=0;
qui gen  `num2'=0;



qui replace    `num1' = `hs1'*-(log(`1')-log(`pl1')) if (`pl1'> `1');
qui svy: ratio `num1'/`hs1';
cap drop matrix _aa;
matrix _aa=e(b);
local est1 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std1 = el(_vv,1,1)^0.5;




qui replace    `num2' = `hs2'*-(log(`2')-log(`pl2')) if (`pl2'> `2');
qui svy: ratio `num2'/`hs2';
cap drop matrix _aa;
matrix _aa=e(b);
local est2 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std2 = el(_vv,1,1)^0.5;




local dif=`est2'-`est1';


local equa2="";

local equa1 = "(_b[`num1']/_b[`hs1'])";
local smean1 = "`num1' `hs1' ";

local equa2 = "(_b[`num2']/_b[`hs2'])";
local smean2 = "`num2' `hs2' ";


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

return scalar sdif  = `sdif';
return scalar dif = `dif';



end;





#delimit ;
capture program drop mbasicwatts2;
program define mbasicwatts2, eclass;
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
diwatts2dn `1' `2' ,  fweight1(`fw1') fweight2(`fw2') 
hs1(`ths1') hs2(`ths2') 
pl1(`pline1') pl2(`pline2')   ;

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
diwatts2dn `1' `2' ,  fweight1(`fw1') fweight2(`fw2') 
hs1(`ths1') hs2(`ths2') 
pl1(`pline1') pl2(`pline2')  ;
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