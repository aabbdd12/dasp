/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.0)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universit Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/

#delim ;
set more off;

/*****************************************************/
/* denscrpoity function      : ici fw=Hweight*Hsize      */
/*****************************************************/
cap program drop denscrpo;                    
program define denscrpo, rclass;              
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





/***************************************/
/* crpoor                                 */
/***************************************/
capture program drop crpoor;
program define crpoor, rclass;
syntax namelist(min=1 max=1) [, FWeight(string) HGroup(string) GNumber(integer 1) 
PLine(real 0) ALpha(real 0) type(string)];
tokenize `namelist';
tempvar fw ga hy;
gen `hy' = `1';
gen `fw'=1;
if ("`fweight'"~="")    qui replace `fw'=`fw'*`fweight';
if ("`hgroup'" ~="")    qui replace `fw'=`fw'*(`hgroup'==`gnumber');
gen `ga' = 0;
if (`alpha'==0) qui replace `ga' = (`pline'>`hy');
if (`alpha'~=0) qui replace `ga' = ((`pline'-`hy'))^`alpha' if (`pline'>`hy');
qui sum `ga' [aweight= `fw'];
local crpoor = r(mean);
if ("`type'" == "nor" & `pline'!=0) local crpoor = `crpoor' /(`pline'^`alpha');
return scalar crpoor = `crpoor';
end;






capture program drop icrpoor2d;
program define icrpoor2d, rclass;
version 9.0;
syntax namelist [,  FWeight(string) HSize1(string) HSize2(string) AL(real 0) PL(string) TYpe(string) CONF(string) LEVEL(real 95)];



if("`alpha'" == "0") local type ="not";
tokenize `namelist';

tempvar num1 hs1 hsy1 num2 num22 hs2 hsy2;


qui gen `hs1'  = `hsize1';
qui gen `hsy1' = `hsize1'*`1';

qui gen `hs2'  = `hsize2';
qui gen `hsy2' = `hsize2'*`2';

qui svy: ratio `hsy1'/`hs1';
cap drop matrix _aa;
matrix _aa=e(b);
local mua = el(_aa,1,1);

qui svy: ratio `hsy2'/`hs2';
cap drop matrix _aa;
matrix _aa=e(b);
local mub = el(_aa,1,1);

local cons=`mub'/`mua';
local cpl=`cons'*`pl';
local gam=`mua'/(`mub'*`pl');

local pprmua=0;
local pprmub=0;

if (`al'==0) {;
local al1=`al'-1;
denscrpo `fweight' `2' `cpl';
local pprmua=-`pl'*`mub'/(`mua'^2)*`r(den)';
local pprmub=`pl'/`mua'*`r(den)';
};

if (`al'>0) {;
local al1=`al'-1;

if ("`type'"~="nor") {;
crpoor `2', fweight(`fweight') alpha(`al1') pline(`cpl') type(not);
local pprmua=-`al'*`pl'*`mub'/(`mua'^2)*`r(crpoor)';
local pprmub=`al'*`pl'/`mua'*`r(crpoor)';
};

if ("`type'"=="nor") {;
tempvar ngap try;
gen `ngap' = 0;
gen `try'= `2'*`gam';
qui replace `ngap' = `fweight'*(1-`try')^`al1'*`2'          if (1>`try');
qui sum `ngap';
local suma1=`r(sum)';
qui sum `fweight';
local suma2=`r(sum)';
local pprmua=-`al'/(`pl'*`mub')*`suma1'/`suma2';
local pprmub=`al'*`mua'/(`pl'*`mub'^2)*`suma1'/`suma2';
};
};

qui gen  `num1'=0;
if (`al' == 0) qui replace                      `num1' = `hs1'*(`pl'> `1') ;
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `num1' = `hs1'*(`pl'-`1')^`al'          if (`pl'>`1');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace `num1' = `hs1'*((`pl'-`1')/`pl')^`al'  if (`pl'>`1' & `pl'!=0);

qui gen  `num2'=0;
if (`al' == 0) qui replace                      `num2' = `hs2'*(`cpl'> `2') ;
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `num2' = `hs2'*(`cpl'-`2')^`al'          if (`cpl'>`2');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace `num2' = `hs2'*((`cpl'-`2')/`cpl')^`al'  if (`cpl'>`2' & `cpl'!=0);

qui replace `num2'=`num2'+`pprmub'*`hs2'*(`2'-`mub');
qui gen `num22'   =`pprmua'*`hs1'*(`1'-`mua');



qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;

if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');

qui svy: ratio (eq1: `num1'/`hsize1') (eq2:  `num2'/`hsize2')  (eq3:  `num22'/`hsize1'); 
cap drop matrix _aa;
matrix _aa=e(b);
local est1 = el(_aa,1,1);
matrix _vv=e(V);
local std1 = el(_vv,1,1)^0.5;


qui nlcom (_b[eq2])+(_b[eq3]);
cap drop matrix _vv _aa;
matrix _aa=r(b);
local est2 = el(_aa,1,1);
matrix _vv=r(V);
local std2 = el(_vv,1,1)^0.5;



qui nlcom (_b[eq2])+(_b[eq3])-(_b[eq1]);
cap drop matrix _vv _aa;

matrix _aa=r(b);
local est3 = el(_aa,1,1);
matrix _vv=r(V);
local std3 = el(_vv,1,1)^0.5;

return scalar std1  = `std1';
return scalar est1  = `est1';
return scalar lb1   = `est1' - `tt'*`std1';
return scalar ub1   = `est1' + `tt'*`std1';

return scalar std2  = `std2';
return scalar est2  = `est2';
return scalar lb2   = `est2' - `tt'*`std2';
return scalar ub2   = `est2' + `tt'*`std2';

return scalar std3  = `std3';
return scalar est3  = `est3';
return scalar lb3   = `est3' - `tt'*`std3';
return scalar ub3   = `est3' + `tt'*`std3';
end;



capture program drop icrpoor2_A;
program define icrpoor2_A, rclass;
version 9.0;
syntax namelist [,  HSize(string)  AL(real 0) PL(string) TYpe(string)  CONF(string) LEVEL(real 95)];
tokenize `namelist';
tempvar num hs hsy;
qui gen `hs'  = `hsize';
qui gen `hsy' = `hsize'*`1';
qui gen  `num'=0;
if (`al' == 0) qui replace                      `num' = `hs'*(`pl'> `1');
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `num' = `hs'*(`pl'-`1')^`al'  if (`pl'>`1');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace `num' = `hs'*((`pl'-`1')/`pl')^`al'  if (`pl'>`1' & `pl'!=0);
qui svy: ratio `num'/`hs';
cap drop matrix _aa;
matrix _aa=e(b);
local est = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std = el(_vv,1,1)^0.5;
qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;

if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');

return scalar std  = `std';
return scalar est  = `est';
return scalar lb   = `est' - `tt'*`std';
return scalar ub   = `est' + `tt'*`std';


qui svy: ratio `hsy'/`hs';
cap drop matrix _aa;
matrix _aa=e(b);
local mua = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
return scalar mua   = `mua';
return scalar vmua  = el(_vv,1,1);
end;


capture program drop icrpoor2_A_PING;
program define icrpoor2_A_PING, rclass;
version 9.0;
syntax namelist [,  HSize(string)  AL(real 0) PL(string) TYpe(string)  CONF(string) LEVEL(real 95) PPRMUA(string) MUA(string)];
tokenize `namelist';
tempvar num hs hsy;
qui gen `hs'  = `hsize';
qui gen `hsy' = `hsize'*`1';



qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;

if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');

qui gen  `num'=0;
if (`al' == 0) qui replace                      `num' = `hs'*(`pl'> `1');
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `num' = `hs'*(`pl'-`1')^`al'  if (`pl'>`1');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace `num' = `hs'*((`pl'-`1')/`pl')^`al'  if (`pl'>`1' & `pl'!=0);
qui replace `num' = `num' - `pprmua'*`hs'*(`1'-`mua');
qui svy: ratio `num'/`hs';
cap drop matrix _aa;
matrix _aa=e(b);
local est = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std = el(_vv,1,1)^0.5;

return scalar std  = `std';
return scalar est  = `est';
return scalar lb   = `est' - `tt'*`std';
return scalar ub   = `est' + `tt'*`std';



cap drop matrix _vv;
matrix _vv=e(V);

end;


capture program drop icrpoor2_B;
program define icrpoor2_B, rclass;
version 9.0;
syntax namelist [,  FWeight(string) HSize(string)  AL(real 0) PL(string) MUA(string) VMUA(string) TYpe(string)  CONF(string) LEVEL(real 95)];
tokenize `namelist';
tempvar num hs hsy;
qui gen `hs'  = `hsize';
qui gen `hsy' = `hsize'*`1';
qui svy: ratio `hsy'/`hs';
cap drop matrix _aa;
matrix _aa=e(b);
local mub = el(_aa,1,1);
if("`alpha'" == "0") local type ="not";
local cons=`mub'/`mua';
local cpl=`cons'*`pl';
local gam=`mua'/(`mub'*`pl');
if (`pl'==0) local gam=0;
local pprmua=0;
local pprmub=0;

if (`al'==0) {;
local al1=`al'-1;
denscrpo `fweight' `1' `cpl';
local pprmua=-`pl'*`mub'/(`mua'^2)*`r(den)';
local pprmub=`pl'/`mua'*`r(den)';
};

if (`al'>0) {;
local al1=`al'-1;

if ("`type'"~="nor") {;
crpoor `1', fweight(`fweight') alpha(`al1') pline(`cpl') type(not);
local pprmua=-`al'*`pl'*`mub'/(`mua'^2)*`r(crpoor)';
local pprmub=`al'*`pl'/`mua'*`r(crpoor)';
};

if ("`type'"=="nor") {;
tempvar ngap try;
gen `ngap' = 0;
gen `try'= `1'*`gam';
qui replace `ngap' = `fweight'*(1-`try')^`al1'*`1'          if (1>`try');
qui sum `ngap';
local suma1=`r(sum)';
qui sum `fweight';
local suma2=`r(sum)';
local pprmua=-`al'/(`pl'*`mub')*`suma1'/`suma2';
local pprmub=`al'*`mua'/(`pl'*`mub'^2)*`suma1'/`suma2';
if ( `pl' == 0 ) {;
local  pprmua = 0 ;
local  pprmub = 0 ;
};
};

};

qui gen  `num'=0;
if (`al' == 0) qui replace                      `num' = `hs'*(`cpl'> `1') ;
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `num' = `hs'*(`cpl'-`1')^`al'                if (`cpl'>`1');
if (`al' ~= 0  & "`type'"=="nor" & `cpl' != 0 )  qui replace `num' = `hs'*((`cpl' - `1')/`cpl')^`al'      if (`cpl'>`1' );

qui replace `num'=`num' + `pprmub' *`hs'*(`1'-`mub');


qui svy: ratio `num'/`hs';

cap drop matrix _aa;
matrix _aa=e(b);
local est = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local stdn=el(_vv,1,1)^0.5;
local var=el(_vv,1,1)+(`pprmua')^2*`vmua';
local std = `var'^0.5;

qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');

return scalar std  = `std';
return scalar stdn  = `stdn';
return scalar pprmua  = `pprmua'; 
return scalar est  = `est';
return scalar lb   = `est' - `tt'*`std';
return scalar ub   = `est' + `tt'*`std';
end;



capture program drop crpropoor;
program define crpropoor, rclass;
version 9.0;
syntax  namelist(min=2 max=2) [, FILE1(string) FILE2(string) HSize1(string) 
HSize2(string) ALpha(real 0) min(real 0)  max(real 10000) COND1(string) COND2(string) 
type(string) LEVEL(real 95) CONF(string) DEC(int 6) boot(string)];
set more off;
global indica=3;
tokenize `namelist';

if (`alpha'==0) loca type="not";
if (`alpha'!=0) loca type="nor";
if ("`conf'" == "")   local conf= "ts";

preserve;

if ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;
if (`"`file1'"'~="") use `"`file1'"', replace;
if ("`boot'"=="yes") bsample, strata(strata) cluster(psu);
tempvar cd1;
cap drop _ths1;
qui gen _ths1=1;
if ( "`hsize1'"!="") qui replace _ths1=`hsize1';
if ( "`cond1'"!="") {;
gen `cd1'=`cond1';
qui replace _ths1=_ths1*`cd1';
qui sum `cd1';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_1, the number of observations is 0.";
exit;
};
};

tempvar cd2;
cap drop _ths2;
qui gen _ths2=1;
if ( "`hsize2'"!="") qui replace _ths2=`hsize2';
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace _ths2=_ths2*`cd2';
qui sum `cd2i';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_2, the number of observations is 0.";
exit;
};
};


local wname="";
qui gen _fw=_ths2;
cap svy: total `2';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
cap estat svyset;
cap local wname=`"`e(wvar)'"';
if (`"`wname'"'~="") qui replace _fw=_fw*`wname';

gen __pline=0
gen __dif=0
gen __lb=0
gen __ub=0
local _step=(`max'-`min')/100;
forvalues i=1/101 {;
local pl=(`i'-1)*`_step';
icrpoor2d `1' `2' ,  fweight(_fw) hsize1(_ths1) hsize2(_ths2) pl(`pl')  al(`alpha') type(`type')  
conf(`conf') level(`level');
qui replace __pline =`pl'      in `i';
qui replace __dif  =`r(est3)' in `i';
qui replace __lb   =`r(lb3)'  in `i';
qui replace __ub   =`r(ub3)'  in `i';
if (`i'!=101)  dis "." ,  _continue;
if (`i'/10==round(`i'/10)) dis " "  %4.2f `i' " %";
};

qui mkmat __pline __dif __lb __ub, matrix(RES);
};


/* second stage*/

if !( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;

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
dis as error " With condition(s) of distribution_1, the number of observations is 0.";
exit;
};
};

cap svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

cap drop __est1;
cap drop __std1;
cap drop __mua;
cap drop __vmua;
cap gen __est1=0;
cap gen __std1=0;
cap gen __mua=0;
cap gen __vmua=0;
local _step=(`max'-`min')/100;
dis "STEP 1/3";
forvalues i=1/101 {;
local pl=(`i'-1)*`_step';
icrpoor2_A `1' ,  hsize(_ths1 ) pl(`pl') al(`alpha') type(`type')  conf(`conf') level(`level');

qui replace __est1  = `r(est)'   in `i';
qui replace __std1  = `r(std)'   in `i';
qui replace __mua   = `r(mua)'   in `i';
qui replace __vmua  = `r(vmua)'  in `i';

if (`i'!=101)  dis "." ,  _continue;
if (`i'/10==round(`i'/10)) dis " "  %4.2f `i' " %";
};


cap matrix drop MTA;

qui mkmat __est1 __std1 __mua __vmua in 1/101, matrix(MTA);

restore;
if ("`file2'" !="") use `"`file2'"', replace;
if ("`boot'"=="yes") bsample, strata(strata) cluster(psu);
tempvar cd2;
cap drop _ths2;
qui gen _ths2=1;
if ( "`hsize2'"!="") qui replace _ths2=`hsize2';
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace _ths2=_ths2*`cd2';
qui sum `cd2';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_2 the number of observations is 0.";
exit;
};
};

qui gen _fw=_ths2;
cap svy: total `2';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
cap estat svyset;
cap local wname=`"`e(wvar)'"';
if (`"`wname'"'~="") qui replace _fw=_fw*`wname';



local _step=(`max'-`min')/100;
cap drop __est1;
cap drop __etd2;

gen __est2=0;
gen __std2=0;
gen __pprmua=0;
gen __stdn=0;
dis "STEP 2/3";
forvalues i=1/101 {;
local pl=(`i'-1)*`_step';
local mua =el(MTA,`i',3);
local vmua=el(MTA,`i',4);
icrpoor2_B `2' , fweight(_fw) hsize(_ths2 ) pl(`pl') al(`alpha') mua(`mua') vmua(`vmua') type(`type') 
conf(`conf') level(`level');

qui replace __est2    = `r(est)'   in `i';
qui replace __std2    = `r(std)'   in `i';
qui replace __pprmua  = `r(pprmua)'   in `i';
qui replace __stdn    = `r(stdn)'   in `i';

if (`i'!=101)  dis "." ,  _continue;
if (`i'/10==round(`i'/10)) dis " "  %4.2f `i' " %";

};

qui mkmat __est2 __std2 __pprmua __stdn in 1/101, matrix(MTB);

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
dis as error " With condition(s) of distribution_1, the number of observations is 0.";
exit;
};
};
gen __dif=0;
gen __pline=0;
gen __lb=0;
gen __ub=0;
local _step=(`max'-`min')/100;

dis "STEP 3/3";

forvalues i=1/101 {;
local pl=(`i'-1)*`_step';

cap svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local pprmua=el(MTB,`i',3);
icrpoor2_A_PING `1' ,  hsize(_ths1 ) pl(`pl') al(`alpha') type(`type')  conf(`conf') level(`level')
pprmua(`pprmua') mua(`mua');
local stdn=el(MTB,`i',4);
local std_dif=(`r(std)'^2+`stdn'^2)^0.5;
local dif = el(MTB,`i',1)-el(MTA,`i',1);

if ("`conf'"!="ts") local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl = (1-(100-`level')/200);
local zzz=invnorm(`lvl');

local lb   = `dif' - `zzz'*`std_dif';
local ub   = `dif' + `zzz'*`std_dif';

qui replace __pline=`pl' in `i';
qui replace __dif=`dif'  in `i';
qui replace __lb=`lb'    in `i';
qui replace __ub=`ub'    in `i';
if (`i'!=101)  dis "." ,  _continue;
if (`i'/10==round(`i'/10)) dis " "  %4.2f `i' " %";
};

qui keep in 1/101;
qui mkmat __pline __dif __lb __ub, matrix(RES);
};



cap matrix drop _res_d1;
cap matrix drop _res_d2;
cap matrix drop _res_di;
cap matrix drop _aa;
cap matrix drop _vv;
cap matrix drop MTA;
cap matrix drop MTB;
restore;
end;






