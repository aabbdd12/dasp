/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/

#delim ;
set more off;
cap program drop ifgtidens;                    
program define ifgtidens, rclass;              
args fw x xval;                         
qui su `x' [aw=`fw'], detail;           
local tmp = (`r(p75)'-`r(p25)')/1.34;                          
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
local h   = 0.9*`tmp'*_N^(-1.0/5.0);                            
tempvar s1 s2;                                                  
gen `s1' = sum( `fw' *exp(-0.5* ( ((`xval'-`x')/`h')^2  )  ));  
gen `s2' = sum( `fw' );
return scalar den = `s1'[_N]/( `h'* sqrt(2*c(pi)) * `s2'[_N] );  
end;


capture program drop ifgtifgt;
program define ifgtifgt, rclass;
syntax namelist(min=1 max=1) [, FWeight(string) HGroup(string) GNumber(integer 1) 
PLine(real 0) ALpha(real 0) type(string)];
tokenize `namelist';
tempvar fw ga hy wga fd;
gen `hy' = `1';
gen `fw'=1;
if ("`fweight'"~="")    qui replace `fw'=`fw'*`fweight';
if ("`hgroup'" ~="")    qui replace `fw'=`fw'*(`hgroup'==`gnumber');

gen `fd' = (`pline'>`hy');
gen         `wga' = 0;
qui replace `wga' = -log(`hy'/`pline') if (`pline'>`hy');

gen `ga' = 0;
if (`alpha'==0) qui replace `ga' = (`pline'>`hy');
if (`alpha'~=0) qui replace `ga' = ((`pline'-`hy'))^`alpha' if (`pline'>`hy');
qui sum `ga' [aweight= `fw'];
local ifgtifgt = r(mean);
if ("`type'" == "nor" & `pline'!=0) local ifgtifgt = `ifgtifgt' /(`pline'^`alpha');
return scalar ifgtifgt = `ifgtifgt';

qui sum `wga' [aweight= `fw'];
return scalar watts = `r(mean)';

qui sum `fd' [aweight= `fw'];
return scalar fd = `r(mean)';

end;








capture program drop dfgtgr2d;
program define dfgtgr2d, rclass;
version 9.0;
syntax namelist [,  HSIZE1(string) HSIZE2(string)  AL(real 0) PL(string) LEVEL(real 95) CONF(string)];
tokenize `namelist';

tempvar num1 num2 num12 num22  hs1 hsy1  hs2 hsy2  /* num13 num14wnum1 fnum1 */ ;
if ("`conf'"=="") local conf = "ts";

qui gen `hs1'  =  `hsize1';
qui gen `hsy1'  = `hsize1'*`1';

qui gen `hs2'  =  `hsize2';
qui gen `hsy2'  = `hsize2'*`2';

qui svy: ratio `hsy1'/`hs1';
cap drop matrix _aa;
matrix _aa=e(b);
local mu1 = el(_aa,1,1);

qui svy: ratio `hsy2'/`hs2';
cap drop matrix _aa;
matrix _aa=e(b);
local mu2 = el(_aa,1,1);

tempvar fweight1 fweight2;
qui gen `fweight1' = `hs1';
qui gen `fweight2' = `hs2';

local wname="";
cap svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
cap estat svyset;
cap local wname=`"`e(wvar)'"';

if (`"`wname'"'~="") {;
qui replace `fweight1'=`fweight1'*`wname';
qui replace `fweight2'=`fweight2'*`wname';
};



local cons1=`mu1'/`mu2';
local cons2=`mu2'/`mu1';
local cpl1=`cons1'*`pl';
local cpl2=`cons2'*`pl';

local pprmu11=0;
local pprmu12=0;

local pprmu21=0;
local pprmu22=0;

if (`al'==0) {;
tempvar una;
gen `una'=1;
ifgtidens `fweight1' `1' `cpl1';
local pprmu11= `pl'/`mu2'*`r(den)';
local pprmu12=-`pl'*`mu1'/(`mu2'^2)*`r(den)';

ifgtidens `fweight2' `2' `cpl2';
local pprmu21= `pl'/`mu1'*`r(den)';
local pprmu22=-`pl'*`mu2'/(`mu1'^2)*`r(den)';

};

if (`al'>0) {;
local al1=`al'-1;
tempvar ngap1 try1  ngap2 try2;
gen `ngap1' = 0;
gen `ngap2' = 0;

gen `try1'= (`1'/`pl')*(`mu2'/`mu1');
gen `try2'= (`2'/`pl')*(`mu1'/`mu2');

qui replace `ngap1' = (1-`try1')^`al1'*`1'/`pl'      if (1>`try1');
qui replace `ngap2' = (1-`try2')^`al1'*`2'/`pl'      if (1>`try2');


qui sum `ngap1' [aw=`fweight1'];
local suma1=`r(mean)';
local pprmu11= `al'*`mu2'/(`mu1'^2)*`suma1';
local pprmu12=-`al'/`mu1'*`suma1';


qui sum `ngap2' [aw=`fweight2'];
local suma2=`r(mean)';
local pprmu21=-`al'/`mu2'*`suma2';
local pprmu22= `al'*`mu1'/(`mu2'^2)*`suma2';


};


dis " PPRIM2:  `pprmu11'    `pprmu12' ";

dis " PPRIM2:  `pprmu21'    `pprmu22' ";


qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');





qui gen  `num1'=0;
qui gen  `num2'=0;
qui gen  `num12'=0;
qui gen  `num22'=0;
if (`al' == 0)  qui replace `num1'  = `hs1'*(`pl'> `1');
if (`al' ~= 0)  qui replace `num1'  = `hs1'*((`pl'-`1')/`pl')^`al'  if (`pl'>`1' & `pl'!=0);

local pla1 = `pl'*`mu1'/`mu2';
if (`al' == 0)  qui replace `num12'  = `hs1'*(`pla1'> `1');
if (`al' ~= 0)  qui replace `num12'  = `hs1'*((`pla1'-`1')/`pla1')^`al'  if (`pla1'>`1' & `pla1'!=0);
qui replace `num12'  = `num12'+`pprmu11'*`hs1'*(`1'-`mu1')+`pprmu12'*`hs2'*(`2'-`mu2');  

if (`al' == 0)  qui replace `num2'  = `hs2'*(`pl'> `2');
if (`al' ~= 0)  qui replace `num2'  = `hs2'*((`pl'-`2')/`pl')^`al'  if (`pl'>`2' & `pl'!=0); 

local pla2 = `pl'*`mu2'/`mu1';
if (`al' == 0)  qui replace `num22'  = `hs2'*(`pla2'> `2');
if (`al' ~= 0)  qui replace `num22'  = `hs2'*((`pla2'-`2')/`pla2')^`al'  if (`pla2'>`2' & `pla2'!=0);
qui replace `num22'  = `num22'+`pprmu22'*`hs2'*(`2'-`mu2')+`pprmu21'*`hs1'*(`1'-`mu1'); 



qui svy: ratio `num1'/`hs1';
cap drop matrix _aa;
matrix _aa=e(b);
cap drop matrix _vv;
matrix _vv=e(V);
local est  = el(_aa,1,1);
local std  = el(_vv,1,1)^0.5;
local lb   = `est' - `tt'*`std';
local ub   = `est' + `tt'*`std';
matrix _res_d1   = (`est',`std',`lb',`ub');

qui svy: ratio `num2'/`hs2';
cap drop matrix _aa;
matrix _aa=e(b);
cap drop matrix _vv;
matrix _vv=e(V);
local est  = el(_aa,1,1);
local std  = el(_vv,1,1)^0.5;
local lb   = `est' - `tt'*`std';
local ub   = `est' + `tt'*`std';
matrix _res_d2   = (`est',`std',`lb',`ub');


qui svy: mean `num1' `hs1' `num2' `hs2' `num12' `num22';
cap drop matrix _aa;
matrix _aa=e(b);
global sv1=el(_aa,1,1);
global sv2=el(_aa,1,2);
global sv3=el(_aa,1,3);
global sv4=el(_aa,1,4);
global sv5=el(_aa,1,5);
global sv6=el(_aa,1,6);

cap drop matrix _vv;
matrix _vv=e(V);
local est = ($sv3/$sv4)-($sv1/$sv2);
cap matrix drop gra;
matrix gra = (
-1/$sv2\
$sv1/$sv2^2\
1/$sv2\
-$sv3/$sv4^2\
0\
0
);

cap matrix drop _zz;
matrix _zz=gra'*_vv*gra;
local std= el(_zz,1,1)^0.5;
local lb   = `est' - `tt'*`std';
local ub   = `est' + `tt'*`std';

matrix _res_di   = (`est',`std',`lb',`ub');


local est = ($sv5/$sv2)-($sv1/$sv2);
cap matrix drop gra;
matrix gra = (
-1/$sv2\
($sv1-$sv5)/$sv2^2\
0\
0\
1/$sv2\
0
);

cap matrix drop _zz;
matrix _zz=gra'*_vv*gra;
local std= el(_zz,1,1)^0.5;
local lb   = `est' - `tt'*`std';
local ub   = `est' + `tt'*`std';

matrix _res_grt1   = (`est',`std',`lb',`ub');

local est = ($sv6/$sv4)-($sv1/$sv2);
cap matrix drop gra;
matrix gra = (
-1/$sv2\
$sv1/$sv2^2\
0\
-$sv6/$sv4^2\
0\
1/$sv4
);

cap matrix drop _zz;
matrix _zz=gra'*_vv*gra;
local std= el(_zz,1,1)^0.5;
local lb   = `est' - `tt'*`std';
local ub   = `est' + `tt'*`std';

matrix _res_redt1   = (`est',`std',`lb',`ub');

matrix _res_rest1 = (el(_res_di,1,1)-el(_res_grt1,1,1)-el(_res_redt1,1,1),0,0,0);





local est = ($sv3/$sv4)-($sv6/$sv4);
cap matrix drop gra;
matrix gra = (
0\
0\
1/$sv4\
($sv6-$sv3)/$sv4^2\
0\
-1/$sv4
);

cap matrix drop _zz;
matrix _zz=gra'*_vv*gra;
local std= el(_zz,1,1)^0.5;
local lb   = `est' - `tt'*`std';
local ub   = `est' + `tt'*`std';

matrix _res_grt2   = (`est',`std',`lb',`ub');

local est = ($sv3/$sv4)-($sv5/$sv2);
cap matrix drop gra;
matrix gra = (
0\
$sv5/$sv2^2\
1/$sv4\
-$sv3/$sv4^2\
-1/$sv2\
0
);

cap matrix drop _zz;
matrix _zz=gra'*_vv*gra;
local std= el(_zz,1,1)^0.5;
local lb   = `est' - `tt'*`std';
local ub   = `est' + `tt'*`std';

matrix _res_redt2   = (`est',`std',`lb',`ub');
matrix _res_rest2 = (el(_res_di,1,1)-el(_res_grt1,1,1)-el(_res_redt1,1,1),0,0,0);





local est = 0.5*(($sv5-$sv1)/$sv2+($sv3-$sv6)/$sv4);
cap matrix drop gra;
matrix gra = (
-1/$sv2\
($sv1-$sv2)/$sv2^2\
1/$sv4\
($sv6-$sv3)/$sv4^2\
1/$sv2\
-1/$sv4
);

cap matrix drop _zz;
matrix _zz=gra'*_vv*gra;
local std= 0.5*el(_zz,1,1)^0.5;
local lb   = `est' - `tt'*`std';
local ub   = `est' + `tt'*`std';

matrix _res_grsh   = (`est',`std',`lb',`ub');

local est = 0.5*(($sv6+$sv3)/$sv4-($sv1+$sv5)/$sv2);
cap matrix drop gra;
matrix gra = (
-1/$sv2\
($sv1+$sv5)/$sv2^2\
1/$sv4\
-($sv6+$sv3)/$sv4^2\
-1/$sv2\
1/$sv4
);

cap matrix drop _zz;
matrix _zz=gra'*_vv*gra;
local std= 0.5*el(_zz,1,1)^0.5;
local lb   = `est' - `tt'*`std';
local ub   = `est' + `tt'*`std';

matrix _res_redsh   = (`est',`std',`lb',`ub');




end;







capture program drop dfgtgr2;
program define dfgtgr2, rclass;
version 9.0;
syntax namelist [,  HSize(string) HSIZE2(string)  AL(real 0) PL(string) LEVEL(real 95) CONF(string) MU2(string) VMU2(string) PPRIM(string) sco(int 0) per(int 1)];
tokenize `namelist';
tempvar num num2 num12 num13 num14 hs hsy wnum1 fnum1;
if "`per'"=="" local per=1;
qui gen `hs'  =  `hsize';
qui gen `hsy'  = `hsize'*`1';
qui svy: ratio `hsy'/`hs';
cap drop matrix _aa;
matrix _aa=e(b);
local mu1 = el(_aa,1,1);
cap drop matrix _mm;
matrix _mm=e(V);
return scalar  mu=`mu1';
return scalar vmu=el(_mm,1,1);

tempvar fweight;
qui gen `fweight' = `hs';
local wname="";
cap svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
cap estat svyset;
cap local wname=`"`e(wvar)'"';
if (`"`wname'"'~="") qui replace `fweight'=`fweight'*`wname';


if (`sco'==1) {;
if("`alpha'" == "0") local type ="not";
local cons=`mu1'/`mu2';
local cpl=`cons'*`pl';
local pprmu1=0;
local pprmu2=0;
if (`al'==0) {;
tempvar una;
gen `una'=1;
ifgtidens `fweight' `1' `cpl';
local pprmu1= `pl'/`mu2'*`r(den)';
local pprmu2=-`pl'*`mu1'/(`mu2'^2)*`r(den)';
return scalar pprima = `pprmu2';
};
if (`al'>0) {;
local al1=`al'-1;
tempvar ngap try;
gen `ngap' = 0;
gen `try'= (`1'/`pl')*(`mu2'/`mu1');
qui replace `ngap' = (1-`try')^`al1'*`1'/`pl'      if (1>`try');
qui sum `ngap' [aw=`fweight'];
local suma1=`r(mean)';
local pprmu1= `al'*`mu2'/(`mu1'^2)*`suma1';
local pprmu2=-`al'/`mu1'*`suma1';
return scalar pprima = `pprmu2';
};
};


qui gen  `num'=0;
if (`al' == 0)  qui replace                      `num'  = `hs'*(`pl'> `1');
if (`al' ~= 0)  qui replace `num'  = `hs'*((`pl'-`1')/`pl')^`al'  if (`pl'>`1' & `pl'!=0); 


if (`sco'==1) {;             
qui gen  `num2'=0;
qui gen  `num12'=0;
qui gen  `num13'=0;
qui gen  `num14'=0;
local pla = `pl'*`mu1'/`mu2';
if (`al' == 0)  qui replace                      `num2'  = `hs'*(`pla'> `1');
if (`al' ~= 0)  qui replace `num2'  = `hs'*((`pla'-`1')/`pla')^`al'  if (`pla'>`1' & `pla'!=0);
if ("`pprim'"~="") qui replace   `num12' = `num' - `pprim'*`hs'*(`1'-`mu1'); 
 qui replace   `num2'  = `num2'+`pprmu1'*`hs'*(`1'-`mu1'); 
 if ("`pprim'"~="")             qui replace   `num13' =`num2'- `num' - `pprim'*`hs'*(`1'-`mu1'); 
 if ("`pprim'"~="" & `per'==2) qui replace   `num13' =`num2'- `num' + `pprim'*`hs'*(`1'-`mu1'); 
 if ("`pprim'"~="") qui replace  `num14' =`num2'+ `num' - `pprim'*`hs'*(`1'-`mu1'); 
};



qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');




if (`sco'==1) {; 
qui svy: mean `num2' `num' `hs' ;
cap drop matrix _aa;
matrix _aa=e(b);
global sv1=el(_aa,1,1);
global sv2=el(_aa,1,2);
global sv3=el(_aa,1,3);


              local est = ($sv1-$sv2)/$sv3;
if (`per'==2) local est=-`est';

local add=(`pprmu2')^2*`vmu2';

cap drop matrix _vv;
matrix _vv=e(V);
svmat _vv;
qui replace _vv1 = _vv1[1]+`add' in 1;


mkmat _vv1 _vv2 _vv3 in 1/3, matrix(mat);
cap matrix drop gra;
matrix gra = (
1/$sv3\
-1/$sv3\
($sv2-$sv1)/($sv3^2)
);




cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std= el(_zz,1,1)^0.5;

tempvar num3;

if (`per'!=2) gen `num3'= `num2'-`num';
if (`per'==2) gen `num3'= `num'-`num2';

 svy: ratio `num3'/`hs';

return scalar esta  = `est';
return scalar stda  = `std';
return scalar lba   = `est' - `tt'*`std';
return scalar uba   = `est' + `tt'*`std';


qui svy: ratio `num2'/`hs';
cap drop matrix _aaaa;
matrix _aaaa=e(b);
cap drop matrix _vvvv;
matrix _vvvv=e(V);
return scalar estb  = el(_aaaa,1,1);;
return scalar varb  = el(_vvvv,1,1);


qui svy: ratio `num12'/`hs';
cap drop matrix _aaaaa;
matrix _aaaaa=e(b);
cap drop matrix _vvvvv;
matrix _vvvvv=e(V);
return scalar esta2  = el(_aaaaa,1,1);;
return scalar vara2  = el(_vvvvv,1,1);


qui svy: ratio `num13'/`hs';
cap drop matrix _aaaaaa;
matrix _aaaaaa=e(b);
cap drop matrix _vvvvvv;
matrix _vvvvvv=e(V);
return scalar esta3  = el(_aaaaaa,1,1);;
return scalar vara3  = el(_vvvvvv,1,1);


qui svy: ratio `num14'/`hs';
cap drop matrix _aaaaaaa;
matrix _aaaaaaa=e(b);
cap drop matrix _vvvvvvv;
matrix _vvvvvvv=e(V);
return scalar esta4  = el(_aaaaaaa,1,1);;
return scalar vara4  = el(_vvvvvvv,1,1);


};


qui svy: ratio  `num'/`hs' ;
cap drop matrix _aa;
matrix _aa=e(b);
local est = el(_aa,1,1);
cap drop matrix _vvv;
matrix _vvv=e(V);
local std = (el(_vvv,1,1))^0.5;

return scalar est  = `est';
return scalar std  = `std';
return scalar lb   = `est' - `tt'*`std';
return scalar ub   = `est' + `tt'*`std';


end;






capture program drop dfgtgr;
program define dfgtgr, eclass;
syntax  namelist(min=2 max=2) [, FILE1(string) FILE2(string) HSize1(string) 
HSize2(string) ALpha(real 0) PLINE(real 0)  COND1(string) COND2(string) 
 type(string) CONF(string) LEVEL(real 95) DEC(int 6) boot(string)];

global indica=3;
tokenize `namelist';

if ("`conf'"=="") local conf = "ts";
local pl2=`pline';

preserve;
local depend=0;
if ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) local depend=1;


if (`depend'==1) {;


if (`"`file1'"'~="") use `"`file1'"', replace;

tempvar cd1 ths1;

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

tempvar cd2 ths2;
qui gen `ths2'=1;
if ( "`hsize2'"!="") qui replace `ths2'=`hsize2';
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace `ths2'=`ths2'*`cd2';
qui sum `cd2i';
if (`r(sum)'==0) {;
dis as error " With the condition(s) of distribution_2, the number of observations is 0.";
exit;
};
};


qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);



dfgtgr2d `1' `2' , hsize1(`ths1') hsize2(`ths2') pl(`pline') al(`alpha')  level(`level') conf(`conf');




};

if (`depend'==0) {;


if ("`file2'" !="") use `"`file2'"', replace;

tempvar cd2;
cap drop _ths2;
qui gen _ths2=1;
if ( "`hsize2'"!="") qui replace _ths2=`hsize2';
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace _ths2=_ths2*`cd2';
qui sum `cd2';
if (`r(sum)'==0) {;
dis as error " With the condition(s) of distribution_2, the number of observations is 0.";
exit;
};
};

tempvar fw2;
qui gen `fw2' = _ths2;
local wname="";
cap svy: total `2';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
cap estat svyset;
cap local wname=`"`e(wvar)'"';
if (`"`wname'"'~="") qui replace `fw2'=`fw2'*`wname';


dfgtgr2 `2' ,  hsize(_ths2 ) pl(`pl2') al(`alpha') level(`level');
global mu2=`r(mu)';
global vmu2=`r(vmu)';

matrix _res_d2 =(`r(est)',`r(std)',`r(lb)',`r(ub)' );
restore;

preserve;

if ("`file1'" !="") use `"`file1'"', replace;

tempvar cd1;
cap drop _ths1;
qui gen _ths1=1;
if ( "`hsize1'"!="") qui replace _ths1=`hsize1';
if ( "`cond1'"!="") {;
gen `cd1'=`cond1';
qui replace _ths1=_ths1*`cd1';
qui sum `cd1';
if (`r(sum)'==0) {;
dis as error " With the condition(s) of distribution_1, the number of observations is 0.";
exit;
};
};
cap svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

tempvar fw1;
qui gen `fw1' = _ths1;
local wname="";
cap svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
cap estat svyset;
cap local wname=`"`e(wvar)'"';
if (`"`wname'"'~="") qui replace `fw1'=`fw1'*`wname';


dfgtgr2 `1' ,  hsize(_ths1 ) pl(`pline') al(`alpha') level(`level') mu2($mu2) vmu2($vmu2) sco(1);
global mu1 =`r(mu)';
global vmu1=`r(vmu)';
local pprima=`r(pprima)';
matrix _res_d1   = (`r(est)',`r(std)',`r(lb)',`r(ub)');
matrix _res_grt1 = (`r(esta)',`r(stda)',`r(lba)',`r(uba)');

local est_mt2_pt1      = `r(estb)';
local var_mt2_pt1      = `r(varb)';

restore;
//=============================
preserve;


if ("`file2'" !="") use `"`file2'"', replace;

tempvar cd2;
cap drop _ths2;
qui gen _ths2=1;
if ( "`hsize2'"!="") qui replace _ths2=`hsize2';
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace _ths2=_ths2*`cd2';
qui sum `cd2';
if (`r(sum)'==0) {;
dis as error " With the condition(s) of distribution_2, the number of observations is 0.";
exit;
};
};

tempvar fw2;
qui gen `fw2' = _ths2;
local wname="";
cap svy: total `2';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
cap estat svyset;
cap local wname=`"`e(wvar)'"';
if (`"`wname'"'~="") qui replace `fw2'=`fw2'*`wname';
qui sum `2' [aw=`fw2'], meanonly;
global mu2=`r(mean)';
ifgtifgt `2', fw(`fw2') pl(`pl2') al(`alpha');
global p2=`r(ifgtifgt)';
global wat2=`r(watts)';

if ("`conf'"!="ts") local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl = (1-(100-`level')/200);
local zzz=invnorm(`lvl');
dfgtgr2 `2' ,  hsize(_ths2 ) pl(`pline') al(`alpha') level(`level') mu2($mu1) vmu2($vmu1) pprim(`pprima') sco(1) per(2);


local varas2=`r(vara3)';
local varasr2=`r(vara4)';

matrix _res_grt2 = (`r(esta)',`r(stda)',`r(lba)',`r(uba)');

local est_mt1_pt2      = `r(estb)';
local var_mt1_pt2      = `r(varb)';



local STE_C1_t2 = (`r(vara2)'+`var_mt2_pt1')^0.5;


local pprima=`r(pprima)';


local dif = el(_res_d2,1,1)-el(_res_d1,1,1);
local std = (el(_res_d1,1,2)^2+el(_res_d2,1,2)^2)^0.5;
if ("`conf'"!="ts") local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl = (1-(100-`level')/200);
local zzz=invnorm(`lvl');
local lb   = `dif' -  `zzz'*`std';
local ub   = `dif' +  `zzz'*`std';
matrix _res_di =(`dif',`std',`lb',`ub');


restore;



//============================



preserve;

if ("`file1'" !="") use `"`file1'"', replace;

tempvar cd1;
cap drop _ths1;
qui gen _ths1=1;
if ( "`hsize1'"!="") qui replace _ths1=`hsize1';
if ( "`cond1'"!="") {;
gen `cd1'=`cond1';
qui replace _ths1=_ths1*`cd1';
qui sum `cd1';
if (`r(sum)'==0) {;
dis as error " With the condition(s) of distribution_1, the number of observations is 0.";
exit;
};
};
cap svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

tempvar fw1;
qui gen `fw1' = _ths1;
local wname="";
cap svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
cap estat svyset;
cap local wname=`"`e(wvar)'"';
if (`"`wname'"'~="") qui replace `fw1'=`fw1'*`wname';


dfgtgr2 `1' ,  hsize(_ths1 ) pl(`pline') al(`alpha') level(`level') mu2($mu2) vmu2($vmu2) pprim(`pprima') sco(1);

local varas1=`r(vara3)';
local varasr1=`r(vara4)';

local STE_C1_t1 = (`r(vara2)'+`var_mt1_pt2')^0.5;

local dif=`est_mt1_pt2'-el(_res_d1,1,1);
local lb   = `dif' -  `zzz'*`STE_C1_t1';
local ub   = `dif' +  `zzz'*`STE_C1_t1';
matrix _res_redt1 = (`dif',`STE_C1_t1',`lb',`ub');
matrix _res_rest1 = (el(_res_di,1,1)-el(_res_grt1,1,1)-el(_res_redt1,1,1),0,0,0);


local dif=el(_res_d2,1,1)-`est_mt2_pt1';
local lb   = `dif' -  `zzz'*`STE_C1_t2';
local ub   = `dif' +  `zzz'*`STE_C1_t2';
matrix _res_redt2 = (`dif',`STE_C1_t2',`lb',`ub');

matrix _res_rest2 = (el(_res_di,1,1)-el(_res_grt2,1,1)-el(_res_redt2,1,1),0,0,0);

//====================================

local dif=0.5*(el(_res_grt1,1,1)+el(_res_grt2,1,1));
local std=0.5*(`varas1'+`varas2')^0.5;
local lb   = `dif' -  `zzz'*`std';
local ub   = `dif' +  `zzz'*`std';
matrix _res_grsh = (`dif',`std',`lb',`ub');


local dif=0.5*(el(_res_redt1,1,1)+el(_res_redt2,1,1));
local std=0.5*(`varasr1'+`varasr2')^0.5;
local lb   = `dif' -  `zzz'*`std';
local ub   = `dif' +  `zzz'*`std';
matrix _res_redsh = (`dif',`std',`lb',`ub');





};

local lb_d1  = el(_res_d1,1,3);
local lb_d2  = el(_res_d2,1,3);
local ub_d1  = el(_res_d1,1,4);
local ub_d2  = el(_res_d2,1,4);

local lb_dif = el(_res_di,1,3);
local ub_dif = el(_res_di,1,4);

local lb_grt1  = el(_res_grt1,1,3);
local ub_grt1  = el(_res_grt1,1,4);

local lb_redt1  = el(_res_redt1,1,3);
local ub_redt1  = el(_res_redt1,1,4);



local lb_grt2  = el(_res_grt2,1,3);
local lb_grsh  = el(_res_grsh,1,3);



local ub_grt2  = el(_res_grt2,1,4);
local ub_grsh  = el(_res_grsh,1,4);


local lb_redt2  = el(_res_redt2,1,3);
local lb_redsh  = el(_res_redsh,1,3);


local ub_redt2  = el(_res_redt2,1,4);
local ub_redsh  = el(_res_redsh,1,4);

if ("`conf'"=="lb")  {;
local ub_d1  = ".";
local ub_d2  = ".";

local ub_dif = ".";

local ub_grt1  = ".";

local ub_grt2  = ".";
local ub_grsh  = ".";

local ub_redt1  = ".";
local ub_redt2  = ".";
local ub_redsh  = ".";

};

if ("`conf'"=="ub")  {;
local lb_d1  = ".";
local lb_d2  = ".";

local lb_dif = ".";

local lb_grt1  = ".";

local lb_grt2  = ".";
local lb_grsh  = ".";

local lb_redt1  = ".";
local lb_redt2  = ".";
local lb_redsh  = ".";

};





      tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width  20|16 16 16 16  ;
	.`table'.strcolor . . yellow . .  ;
	.`table'.numcolor yellow yellow . yellow yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f ;
	 di _n as text in white "{col 4}Decomposition of the variation in the FGT index into growth and redistribution.";
        di  as text "{col 4}Parameter alpha : "  %12.2f `alpha'       ;
       di  as text "{col 4}Poverty line    : "  %12.2f `pline'       ;
      .`table'.sep, top;
	.`table'.titles "`component'  " "Estimate"  "STE "  "  LB  " "  UB  "   ;
	
	.`table'.sep, mid;
	local nalt = "ddd";
	
      .`table'.row "Distribution_1" el(_res_d1,1,1)  el(_res_d1,1,2) `lb_d1'  `ub_d1'  ; 
      .`table'.row "Distribution_2" el(_res_d2,1,1)  el(_res_d2,1,2) `lb_d2'  `ub_d2'  ;


  .`table'.sep,mid;
  .`table'.numcolor white white   white  white  white ;
  .`table'.row "Difference: (d2-d1)" el(_res_di,1,1)  el(_res_di,1,2) `lb_dif'  `ub_dif'  ;

  .`table'.sep,mid;

  .`table'.numcolor white white   white  white  white ;  
     
    .`table'.titles "  " "  Datt & Ravallion approach: reference period  t1" "" "" " " ;
   
.`table'.sep, mid;
  .`table'.row  "Growth         " el(_res_grt1,1,1)  el(_res_grt1,1,2) `lb_grt1'     `ub_grt1'  ;

   .`table'.row "Redistribution " el(_res_redt1,1,1)  el(_res_redt1,1,2) `lb_redt1'  `ub_redt1'  ;

   .`table'.row "Residue        " el(_res_rest1,1,1)  "---" "---"   "---"   ;

 .`table'.sep, mid;
    .`table'.titles " " "  Datt & Ravallion approach: reference period  t2" "" "" " "  ;
.`table'.sep, mid;    
  .`table'.row  "Growth         "          el(_res_grt2,1,1)  el(_res_grt2,1,2) `lb_grt2'  `ub_grt2'  ;
   .`table'.row "Redistribution " el(_res_redt2,1,1)  el(_res_redt2,1,2) `lb_redt2'  `ub_redt2'  ;
   .`table'.row "Residue        " el(_res_rest2,1,1)  "---" "---"   "---"   ;
   .`table'.sep, mid;
    .`table'.titles " "  "  Shapley approach" "" "" " " ;
.`table'.sep, mid;    
  .`table'.row  "Growth         "          el(_res_grsh,1,1)  el(_res_grsh,1,2) `lb_grsh'  `ub_grsh'  ;
   .`table'.row "Redistribution " el(_res_redsh,1,1)  el(_res_redsh,1,2) `lb_redsh'  `ub_redsh'  ;


  .`table'.sep,bot;

ereturn scalar c1=el(_res_grt1,1,1);
ereturn scalar c2=el(_res_redt1,1,1);

ereturn scalar c3=el(_res_grt2,1,1);
ereturn scalar c4=el(_res_redt2,1,1);

ereturn scalar c5=el(_res_grsh,1,1);
ereturn scalar c6=el(_res_redsh,1,1);

matrix drop _all;
end;


cd c:/data/mexico;
//dfgtgr expend expend, alpha(1) pline(100000) hsize1(weight);
/*
clear;
global nboot = 100;
set obs $nboot;
gen c1=0;
gen c2=0;
gen c3=0;
gen c4=0;
gen c5=0;
gen c6=0;
forvalues i=1/$nboot{;
preserve;
use c:/data/mexico/b4, clear;
bsample;
qui save f1, replace;
/*
use c:/data/mexico/b5, clear;
bsample;
qui save f2, replace;
*/
restore;

qui dfgtgr b1 b2, alpha(1) pline(1100)  file1(f1) file2(f1);
dis `i' " -- " `e(c1)' " -- " `e(c2)';
qui replace c1=`e(c1)' in `i';
qui replace c2=`e(c2)' in `i';
qui replace c3=`e(c3)' in `i';
qui replace c4=`e(c4)' in `i';
qui replace c5=`e(c5)' in `i';
qui replace c6=`e(c6)' in `i';
};

*/
/*
dfgtgr b1 b2, alpha(1) pline(1100)  file1(b4) file2(b5);

*/

/*
dfgtgr b2 b1, alpha(1) pline(1100)  file1(b4) file2(b4);
*/


dfgtgr b1 b2, alpha(1) pline(1100)  file1(b4) file2(b4);

dfgtgr b2 b1, alpha(1) pline(1100)  file1(b4) file2(b4);

dfgtgr b1 b2, alpha(1) pline(1100)  file1(b4) file2(b5);
