/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 1.5)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2008)          */
/* Universit Laval, Quebec, Canada                                    */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/

#delim ;
set more off;
cap program drop ipropidens;                    
program define ipropidens, rclass;              
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


capture program drop ipropifgt;
program define ipropifgt, rclass;
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
local ipropifgt = r(mean);
if ("`type'" == "nor" & `pline'!=0) local ipropifgt = `ipropifgt' /(`pline'^`alpha');
return scalar ipropifgt = `ipropifgt';

qui sum `wga' [aweight= `fw'];
return scalar watts = `r(mean)';

qui sum `fd' [aweight= `fw'];
return scalar fd = `r(mean)';

end;





capture program drop ipropi2d;
program define ipropi2d, rclass;
version 9.0;
syntax namelist [,  FWeight(string) HSize1(string) HSize2(string) AL(real 0) PL(string) 
PL2(string) TYpe(string) CONF(string) LEVEL(real 95)];

if("`alpha'" == "0") local type ="not";
if("`conf'" == "")   local conf ="ts";
tokenize `namelist';
tempvar num1 hs1 num12 hsy1 num2 hs2 hsy2 wnum1 fnum1 wnum2 fnum2;
qui gen `hs1'  = `hsize1';
qui gen `hs2'  = `hsize2';
qui gen `hsy1'  = `hsize1'*`1';
qui gen `hsy2'  = `hsize2'*`2';

qui svy: ratio `hsy1'/`hs1';
cap drop matrix _aa;
matrix _aa=e(b);
local mu1 = el(_aa,1,1);

qui svy: ratio `hsy2'/`hs2';
cap drop matrix _aa;
matrix _aa=e(b);
local mu2 = el(_aa,1,1);

tempvar fweight1;
qui gen `fweight1' = `hs1';
local wname="";
cap svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
cap estat svyset;
cap local wname=`"`e(wvar)'"';
if (`"`wname'"'~="") qui replace `fweight1'=`fweight1'*`wname';

local cons=`mu1'/`mu2';
local cpl=`cons'*`pl';
local pprmu1=0;
local pprmu2=0;
if (`al'==0) {;
tempvar una;
gen `una'=1;
ipropidens `una' `1' `cpl';
local pprmu1= `pl'/`mu2'*`r(den)';
local pprmu2=-`pl'*`mu1'/(`mu2'^2)*`r(den)';
};
if (`al'>0) {;

local al1=`al'-1;
if ("`type'"~="nor") {;
tempvar ngap;
gen `ngap' = 0;
qui replace `ngap' = (`cpl'-`1')^`al1'     if (`cpl'>`1');
qui sum `ngap';
local suma1=`r(mean)';
local pprmu1= `al'*`pl'/`mu2'*`suma1';
local pprmu2=-`al'*`pl'*`mu1'/(`mu2'^2)*`suma1';
};

if ("`type'"=="nor") {;
tempvar ngap try;
gen `ngap' = 0;
gen `try'= (`1'/`pl')*(`mu2'/`mu1');
qui replace `ngap' = (1-`try')^`al1'*`1'/`pl'      if (1>`try');
qui sum `ngap';
local suma1=`r(mean)';
local pprmu1= `al'*`mu2'/(`mu1'^2)*`suma1';
local pprmu2=-`al'/`mu1'*`suma1';
};

};


qui gen     `fnum1' = `hs1'*(`pl'> `1');
qui gen     `wnum1' =  0;
qui replace `wnum1' = -`hs1'*log((`1'/`pl'))  if (`pl'>`1');


qui gen  `num1'=0;
if (`al' == 0) qui replace                      `num1' = `hs1'*(`pl'> `1') ;
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `num1' = `hs1'*(`pl'-`1')^`al'          if (`pl'>`1');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace `num1' = `hs1'*((`pl'-`1')/`pl')^`al'  if (`pl'>`1' & `pl'!=0);

qui gen  `num12'=0;
local pla = `pl'*`mu1'/`mu2';
if (`al' == 0) qui replace                      `num12'  = `hs1'*(`pla'> `1');
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `num12'  = `hs1'*(`pla'-`1')^`al' if (`pla'>`1');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace `num12'  = `hs1'*((`pla'-`1')/`pla')^`al'  if (`pla'>`1' & `pla'!=0);

qui replace   `num12' = `num12'+`pprmu1'*`hs1'*(`1'-`mu1')+`pprmu2'*`hs2'*(`2'-`mu2');



qui gen     `wnum2' =  0;
qui replace `wnum2' = -`hs2'*log((`2'/`pl'))  if (`pl'>`2');



qui gen  `num2'=0;
if (`al' == 0) qui replace                      `num2' = `hs2'*(`pl'> `2') ;
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `num2' = `hs2'*(`pl'-`2')^`al'          if (`pl'>`2');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace `num2' = `hs2'*((`pl'-`2')/`pl2')^`al'   if (`pl'>`2' & `pl'!=0);




qui svy: mean `wnum1' `hs1'  `fnum1' `hsy1' `wnum2' `hs2' `hsy2' ;
cap drop matrix _aa;
matrix _aa=e(b);
cap drop matrix mat;
matrix mat=e(V);
global ws1=el(_aa,1,1);
global ws2=el(_aa,1,2);
global ws3=el(_aa,1,3);
global ws4=el(_aa,1,4);
global ws5=el(_aa,1,5);
global ws6=el(_aa,1,6);
global ws7=el(_aa,1,7);

local A = ($ws1/$ws2-$ws5/$ws6);
local B = ($ws3/$ws2);

local est0= `A'/`B';



cap drop matrix gra;
matrix gra=
(
1/$ws3 \
-$ws5/($ws3*$ws6)\
-$ws1/($ws3^2)+($ws2*$ws5)/($ws3^2*$ws6)\
0\
-$ws2/($ws3*$ws6) \
($ws2*$ws5)/($ws3*$ws6^2)\
0
);

cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std0= el(_zz,1,1)^0.5;


local est00 = `est0' - (($ws2*$ws7)/($ws6*$ws4) -1);


cap drop matrix gra;
matrix gra=
(
1/$ws3 \
-$ws5/($ws3*$ws6)-$ws7/($ws4*$ws6)\
-$ws1/($ws3^2)+($ws2*$ws5)/($ws3^2*$ws6)\
($ws2*$ws7)/($ws4^2*$ws6)\
-$ws2/($ws3*$ws6) \
($ws2*$ws5)/($ws3*$ws6^2)+($ws2*$ws7)/($ws4*$ws6^2)\
-$ws2/($ws4*$ws6) 
);

cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std00= el(_zz,1,1)^0.5;


qui svy: mean `num1' `hs1' `hsy1' `num12' `num2' `hs2' `hsy2' ;
cap drop matrix _aa;
matrix _aa=e(b);
global s1=el(_aa,1,1);
global s2=el(_aa,1,2);
global s5=el(_aa,1,3);
global s7=el(_aa,1,4);
global s3=el(_aa,1,5);
global s4=el(_aa,1,6);
global s6=el(_aa,1,7);

local A=$s4*$s1-$s3*$s2;
local B=($s1-$s7)*$s4;
local C=$s6*$s2-$s5*$s4;
local D=$s5*$s4;

local E=`A'/`B';
local F=`C'/`D';

local est1 = `A'/`B';
local est2 = `F'*`E';


cap drop matrix mat;
matrix mat=e(V);

cap matrix drop gra;
matrix gra=
(
($s4*`B'-`A')/(`B'^2) \
-$s3/`B'\
0 \
$s4*`A'/(`B'^2) \
-$s2/`B'\
($s1*`B'-($s1-$s7)*`A')/(`B'^2) \
0
);

cap matrix drop _zz;
matrix _zz=gra'*mat*gra;

local std1= el(_zz,1,1)^0.5;



cap matrix drop gra;
matrix gra=
(
 `F'*(($s4*`B'-`A')/(`B'^2)) \
 `E'*($s6/`D')-`F'*($s3/`B')\
-`E'*(($s4*(`D'+`C'))/`D'^2) \
 `F'*($s4*`A'/(`B'^2)) \
-`F'*($s2/`B') \
-`E'*($s5*(`D'+`C')/`D'^2) + `F'*(($s1*`B'-($s1-$s7)*`A')/(`B'^2)) \
 `E'*$s2/`D'
);

cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std2= el(_zz,1,1)^0.5;



local estg= `F';
cap matrix drop gra;
matrix gra=
(
 0 \
($s6/`D')\
-(($s4*(`D'+`C'))/`D'^2) \
0 \
0 \
-($s5*(`D'+`C')/`D'^2) \
$s2/`D'
);

cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local stdg= el(_zz,1,1)^0.5;



local A=$s4*$s7-$s3*$s2;
local B=($s1-$s7)*$s4;
local C=$s6*$s2-$s5*$s4;
local D=$s5*$s4;

local E=`A'/`B';
local F=`C'/`D';


local est3 = `F'*`E';

cap matrix drop gra;
matrix gra=
(
 `F'*((-$s4*`A')/(`B'^2)) \
 `E'*($s6/`D')-`F'*($s3/`B')\
-`E'*(($s4*(`D'+`C'))/`D'^2) \
 `F'*($s4*(`B'+`A')/(`B'^2)) \
-`F'*($s2/`B') \
-`E'*($s5*(`D'+`C')/`D'^2) + `F'*(($s7*`B'-($s1-$s7)*`A')/(`B'^2)) \
 `E'*$s2/`D'
);

cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std3= el(_zz,1,1)^0.5;




qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;

local tt=invttail(`fr',`lvl');

matrix _resg = ( `estg' , `stdg' , `estg' - `tt'*`stdg' , `estg' + `tt'*`stdg' );
matrix _res0 = ( `est0' , `std0' , `est0' - `tt'*`std0' , `est0' + `tt'*`std0' );
matrix _res00 = ( `est00' , `std00' , `est00' - `tt'*`std00' , `est00' + `tt'*`std00' );
matrix _res1 = ( `est1' , `std1' , `est1' - `tt'*`std1' , `est1' + `tt'*`std1' );
matrix _res2 = ( `est2' , `std2' , `est2' - `tt'*`std2' , `est2' + `tt'*`std2' );
matrix _res3 = ( `est3' , `std3' , `est3' - `tt'*`std3' , `est3' + `tt'*`std3' );

end;



capture program drop ipropoor_D2;
program define ipropoor_D2, rclass;
version 9.0;
syntax namelist [,  HSize(string)  AL(real 0) PL(string) TYpe(string)  LEVEL(real 95)];
tokenize `namelist';
tempvar num hs hsy wnum2;
qui gen `hs'  =  `hsize';
qui gen `hsy'  = `hsize'*`1';

qui gen     `wnum2' =  0;
qui replace `wnum2' = -`hs'*log((`1'/`pl'))  if (`pl'>`1');

qui svy: mean `wnum2' `hs' `hsy';
cap drop matrix _aa02;
matrix _aa02=e(b);
cap drop matrix mat02;
matrix mat02=e(V);

qui gen  `num'=0;
if (`al' == 0) qui replace                      `num' = `hs'*(`pl'> `1');
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `num' = `hs'*(`pl'-`1')^`al'  if (`pl'>`1');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace `num' = `hs'*((`pl'-`1')/`pl')^`al'  if (`pl'>`1' & `pl'!=0);
qui svy: ratio `hsy'/`hs';
cap drop matrix _vv;
matrix _vv=e(V);
local vmu2 = el(_vv,1,1);
return scalar vmu2  = `vmu2';
cap drop matrix _aa;
matrix _aa=e(b);
local mu2 = el(_aa,1,1);
qui svy: mean `num' `hs' `hsy';
cap drop matrix _aa;
matrix _aa=e(b);
cap drop matrix _vv;
matrix _vv=e(V);
matrix mat2=_vv;
return scalar mu2  = `mu2';
end;


capture program drop ipropoor_D1;
program define ipropoor_D1, rclass;
version 9.0;
syntax namelist [,  HSize(string)  AL(real 0) PL(string) MU2(string) VMU2(string) TYpe(string)  LEVEL(real 95)];
tokenize `namelist';
tempvar num num2 hs hsy wnum1 fnum1;
qui gen `hs'  =  `hsize';
qui gen `hsy'  = `hsize'*`1';
qui svy: ratio `hsy'/`hs';
cap drop matrix _aa;
matrix _aa=e(b);
local mu1 = el(_aa,1,1);
tempvar fweight;
qui gen `fweight' = `hs';
local wname="";
qui svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
cap estat svyset;
cap local wname=`"`e(wvar)'"';
if (`"`wname'"'~="") qui replace `fweight'=`fweight'*`wname';

if("`alpha'" == "0") local type ="not";
local cons=`mu1'/`mu2';
local cpl=`cons'*`pl';
local pprmu1=0;
local pprmu2=0;
if (`al'==0) {;
tempvar una;
gen `una'=1;
ipropidens `una' `1' `cpl';
local pprmu1= `pl'/`mu2'*`r(den)';
local pprmu2=-`pl'*`mu1'/(`mu2'^2)*`r(den)';
};
if (`al'>0) {;

local al1=`al'-1;
if ("`type'"~="nor") {;
tempvar ngap;
gen `ngap' = 0;
qui replace `ngap' = (`cpl'-`1')^`al1'     if (`cpl'>`1');
 sum `ngap';
local suma1=`r(mean)';
local pprmu1= `al'*`pl'/`mu2'*`suma1';
local pprmu2=-`al'*`pl'*`mu1'/(`mu2'^2)*`suma1';
};

if ("`type'"=="nor") {;
tempvar ngap try;
gen `ngap' = 0;
gen `try'= (`1'/`pl')*(`mu2'/`mu1');
qui replace `ngap' = (1-`try')^`al1'*`1'/`pl'      if (1>`try');
qui sum `ngap';
local suma1=`r(mean)';
local pprmu1= `al'*`mu2'/(`mu1'^2)*`suma1';
local pprmu2=-`al'/`mu1'*`suma1';
};

};

qui gen     `fnum1' = `hs'*(`pl'> `1');
qui gen     `wnum1' =  0;
qui replace `wnum1' = -`hs'*log((`1'/`pl'))  if (`pl'>`1');

qui svy: mean `wnum1' `hs' `fnum1' `hsy';
cap drop matrix _aa01;
matrix _aa01=e(b);
cap drop matrix mat01;
matrix mat01=e(V);


qui gen  `num'=0;
if (`al' == 0) qui replace                      `num'  = `hs'*(`pl'> `1');
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `num'  = `hs'*(`pl'-`1')^`al' if (`pl'>`1');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace `num'  = `hs'*((`pl'-`1')/`pl')^`al'  if (`pl'>`1' & `pl'!=0);               
qui gen  `num2'=0;
local pla = `pl'*`mu1'/`mu2';
if (`al' == 0) qui replace                      `num2'  = `hs'*(`pla'> `1');
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `num2'  = `hs'*(`pla'-`1')^`al' if (`pla'>`1');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace `num2'  = `hs'*((`pla'-`1')/`pla')^`al'  if (`pla'>`1' & `pla'!=0);
qui replace   `num2' = `num2'+`pprmu1'*`hs'*(`1'-`mu1');
local add=(`pprmu2')^2*$vmu2;
qui svy: mean `num' `hs' `hsy' `num2' ;
cap drop matrix _aa;
matrix _aa=e(b);
cap drop matrix _vv;
matrix _vv = e(V);
cap drop _vv;
svmat _vv;
qui replace _vv4 = _vv4[4]+`add' in 4;
mkmat _vv1 _vv2 _vv3 _vv4 in 1/4, matrix(mat1);
end;






capture program drop ipropoor;
program define ipropoor, rclass;
version 9.2;
syntax  namelist(min=2 max=2) [, FILE1(string) FILE2(string) HSize1(string) 
HSize2(string) ALpha(real 0) PLINE(real 0)  COND1(string) COND2(string) 
 type(string) CONF(string) LEVEL(real 95) DEC(int 6) boot(string)];

global indica=3;
tokenize `namelist';

if ("`conf'"=="") local conf = "ts";
local pl2=`pline';

preserve;
if ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;

if (`"`file1'"'~="") use `"`file1'"', replace;
if ("`boot'"=="yes") bsample;
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

tempvar cd2;
cap drop _ths2;
qui gen _ths2=1;
if ( "`hsize2'"!="") qui replace _ths2=`hsize2';
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace _ths2=_ths2*`cd2';
qui sum `cd2i';
if (`r(sum)'==0) {;
dis as error " With the condition(s) of distribution_2, the number of observations is 0.";
exit;
};
};




qui gen _fw=_ths2;
cap svy: total `2';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
ipropi2d `1' `2' ,  hsize1(_ths1) hsize2(_ths2) pl(`pline') pl2(`pl2')  al(`alpha') type(`type')  conf(`conf') level(`level');
};


if !( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;

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
ipropifgt `2', fw(`fw2') pl(`pl2') al(`alpha')  type(`type');
global p2=`r(ipropifgt)';
global wat2=`r(watts)';

ipropoor_D2 `2' ,  hsize(_ths2 ) pl(`pl2') al(`alpha') type(`type')  level(`level');
matrix v2  =_vv;
matrix e2  =_aa;
global s3=el(_aa,1,1);
global s4=el(_aa,1,2);
global s6=el(_aa,1,3);
global mu2=`r(mu2)';
global vmu2=`r(vmu2)';

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


ipropoor_D1 `1' ,  hsize(_ths1 ) pl(`pline') al(`alpha') type(`type')  mu2($mu2) vmu2($vmu2) level(`level');

global s1=el(_aa,1,1);
global s2=el(_aa,1,2);
global s5=el(_aa,1,3);
global s7=el(_aa,1,4);

local A=$s4*$s1-$s3*$s2;
local B=($s1-$s7)*$s4;

cap matrix drop gra1;
matrix gra1=
(
($s4*(`B'-`A'))/(`B'^2) \
-$s3/`B'\
0 \
$s4*`A'/(`B'^2)
);

cap matrix drop gra2;
matrix gra2=
(
-$s2/`B'\
($s1*`B'-($s1-$s7)*`A')/(`B'^2) \
0
);

cap matrix drop _zz;
matrix _zz=gra1'*mat1*gra1+gra2'*mat2*gra2;
local est1=`A'/`B';
local std1= el(_zz,1,1)^0.5;

/* second index */


local C=$s6*$s2-$s5*$s4;
local D=$s5*$s4;

local E=`A'/`B';
local F=`C'/`D';


local est2 = `F'*`E';

cap matrix drop gra1;
matrix gra1=
(
 `F'*(($s4*(`B'-`A'))/(`B'^2)) \
 `E'*($s6/`D')-`F'*($s3/`B')\
-`E'*(($s4*(`D'+`C'))/`D'^2) \
 `F'*($s4*`A'/(`B'^2))
);

cap matrix drop gra2;
matrix gra2=
(
-`F'*($s2/`B') \
-`E'*($s5*(`D'+`C')/`D'^2) + `F'*(($s1*`B'-($s1-$s7)*`A')/(`B'^2)) \
 `E'*$s2/`D'
);

cap matrix drop _zz;
matrix _zz=gra1'*mat1*gra1+gra2'*mat2*gra2;
local std2= el(_zz,1,1)^0.5;


local estg= `F';
cap matrix drop gra1;
matrix gra1=
(
 0 \
($s6/`D')\
-(($s4*(`D'+`C'))/`D'^2) \
0
);

cap matrix drop gra2;
matrix gra2=
(
0 \
-($s5*(`D'+`C')/`D'^2) \
$s2/`D'
);

cap matrix drop _zz;
matrix _zz=gra1'*mat1*gra1+gra2'*mat2*gra2;
local stdg= el(_zz,1,1)^0.5;



local A=$s4*$s7-$s3*$s2;
local B=($s1-$s7)*$s4;
local C=$s6*$s2-$s5*$s4;
local D=$s5*$s4;

local E=`A'/`B';
local F=`C'/`D';


local est3 = `F'*`E';

cap matrix drop gra1;
matrix gra1=
(
 `F'*((-$s4*`A')/(`B'^2)) \
 `E'*($s6/`D')-`F'*($s3/`B')\
-`E'*(($s4*(`D'+`C'))/`D'^2) \
 `F'*($s4*(`B'+`A')/(`B'^2))
);

cap matrix drop gra2;
matrix gra2=
(
-`F'*($s2/`B') \
-`E'*($s5*(`D'+`C')/`D'^2) + `F'*(($s7*`B'-($s1-$s7)*`A')/(`B'^2)) \
 `E'*$s2/`D'
);

cap matrix drop _zz;
matrix _zz=gra1'*mat1*gra1+gra2'*mat2*gra2;
local std3= el(_zz,1,1)^0.5;


global ws1=el(_aa01,1,1);
global ws2=el(_aa01,1,2);
global ws3=el(_aa01,1,3);
global ws4=el(_aa01,1,4);
global ws5=el(_aa02,1,1);
global ws6=el(_aa02,1,2);
global ws7=el(_aa02,1,3);

local A = ($ws1/$ws2-$ws5/$ws6);
local B = ($ws3/$ws2);

local est0= `A'/`B';



cap drop matrix gra1;
matrix gra1=
(
1/$ws3 \
-$ws5/($ws3*$ws6)\
-$ws1/($ws3^2)+($ws2*$ws5)/($ws3^2*$ws6)\
0
);
cap drop matrix gra2;
matrix gra2=
(
-$ws2/($ws3*$ws6) \
($ws2*$ws5)/($ws3*$ws6^2)\
0
);

cap matrix drop _zz;
matrix _zz=gra1'*mat01*gra1+gra2'*mat02*gra2;
local std0= el(_zz,1,1)^0.5;


local est00 = `est0' - `estg';

cap drop matrix gra1;
matrix gra1=
(
1/$ws3 \
-$ws5/($ws3*$ws6)-$ws7/($ws4*$ws6)\
-$ws1/($ws3^2)+($ws2*$ws5)/($ws3^2*$ws6)\
($ws2*$ws7)/($ws4^2*$ws6)
);
cap drop matrix gra2;
matrix gra2=
(
-$ws2/($ws3*$ws6) \
($ws2*$ws5)/($ws3*$ws6^2)+($ws2*$ws7)/($ws4*$ws6^2)\
-$ws2/($ws4*$ws6) 
);

cap matrix drop _zz;
matrix _zz=gra1'*mat01*gra1+gra2'*mat02*gra2;
local std00= el(_zz,1,1)^0.5;






cap matrix drop gra1; 
cap matrix drop gra2;
cap matrix drop mat1; 
cap matrix drop mat2;
cap matrix drop mat01; 
cap matrix drop mat02;
cap matrix drop _aa;
cap matrix drop _aa01;
cap matrix drop _aa02;
cap matrix drop _vv;
cap matrix drop _zz;

if ("`conf'"~="ts") local lvl = (100-`level')/100;
if ("`conf'"=="ts") local lvl = 1-((100-`level')/200);
local zzz=invnorm(`lvl');

matrix _res0 = ( `est0' , `std0' , `est0' - `zzz'*`std0' , `est0' + `zzz'*`std0' );

matrix _res00 = ( `est00' , `std00' , `est00' - `zzz'*`std00' , `est00' + `zzz'*`std00' );

matrix _res1 = ( `est1' , `std1' , `est1' - `zzz'*`std1' , `est1' + `zzz'*`std1' );

matrix _resg = ( `estg' , `stdg' , `estg' - `zzz'*`stdg' , `estg' + `zzz'*`stdg' );

matrix _res2 = ( `est2' , `std2' , `est2' - `zzz'*`std2' , `est2' + `zzz'*`std2' );

matrix _res3 = ( `est3' , `std3' , `est3' - `zzz'*`std3' , `est3' + `zzz'*`std3' );


};


local lb_e0  = el(_res0,1,3);
local ub_e0  = el(_res0,1,4);

local lb_e00  = el(_res00,1,3);
local ub_e00  = el(_res00,1,4);

local lb_e1  = el(_res1,1,3);
local ub_e1  = el(_res1,1,4);

local lb_e2  = el(_res2,1,3);
local ub_e2  = el(_res2,1,4);


local lb_e3  = el(_res3,1,3);
local ub_e3  = el(_res3,1,4);

local lb_eg  = el(_resg,1,3);
local ub_eg  = el(_resg,1,4);

if ("`conf'"=="lb")  {;
local ub_e0  = ".";
local ub_e00  = ".";
local ub_e1  = ".";
local ub_e2  = ".";
local ub_e3  = ".";
local ub_eg  = ".";
};

if ("`conf'"=="ub")  {;
local lb_e0  = ".";
local lb_e00  = ".";
local lb_e1  = ".";
local lb_e2  = ".";
local lb_e3  = ".";
local lb_eg  = ".";
};





      tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width  30|16 16 16 16 ;
	.`table'.strcolor . . yellow . . ;
	.`table'.numcolor yellow yellow . yellow yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f;
       if ("`hgroup'"!="") di as text  "{col 4}Group variable  :    `hgroup'";
        di  as text "{col 4}Poverty line    : "  %12.2f `pline'       ;
        di  as text "{col 4}Parameter alpha : "  %12.2f `alpha'       ;
      .`table'.sep, top;
	.`table'.titles "Pro-poor indices" "Estimate"  "STD "  "  LB  " "  UB  " ;
	.`table'.sep, mid;
      .`table'.row "Growth rate(g)"              el(_resg,1,1)  el(_resg,1,2) `lb_eg' `ub_eg' ;
      .`table'.sep, mid;
      .`table'.row "Ravallion & Chen (2003) index" el(_res0,1,1)  el(_res0,1,2) `lb_e0' `ub_e0' ;
      .`table'.row "Ravallion & Chen (2003) - g  " el(_res00,1,1)  el(_res00,1,2) `lb_e00' `ub_e00' ;
	.`table'.sep, mid;
      .`table'.row "Kakwani & Pernia (2000) index" el(_res1,1,1)  el(_res1,1,2) `lb_e1' `ub_e1' ; 
      .`table'.sep,mid;
      .`table'.row "PEGR index"                    el(_res2,1,1)  el(_res2,1,2) `lb_e2' `ub_e2' ;  
      .`table'.row "  PEGR - g  "                    el(_res3,1,1)  el(_res3,1,2) `lb_e3' `ub_e3' ;
      .`table'.sep,bot;
 cap matrix drop _res0;
 cap matrix drop _res00;
 cap matrix drop _resg;
 cap matrix drop _res1;
 cap matrix drop _res2;
 cap matrix drop _res3;
;
restore;
end;







