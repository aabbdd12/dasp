/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 1.5)          */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2008)               */
/* Universite Laval, Quebec, Canada                                    */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : difgt                                                       */
/*************************************************************************/


#delim ;
set more off;



/*****************************************************/
/* Density function      : ici fw=Hweight*Hsize      */
/*****************************************************/
cap program drop dens;                    
program define dens, rclass;              
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
/* Non parametric regression           */
/***************************************/
cap program drop npe;
program define npe, rclass;
args fw x y xval;
qui su `x' [aw=`fw'], detail;
local tmp = (`r(p75)'-`r(p25)')/1.34 ;   
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)';
local h   = 0.9*`tmp'*_N^(-1.0/5.0);
tempvar s1 s2; 
gen `s1' = sum( `fw'*exp(-0.5* ( ((`xval'-`x')/`h')^2  )  )    *`y');
gen `s2' = sum( `fw'*exp(-0.5* ( ((`xval'-`x')/`h')^2  )  ));
return scalar nes = `s1'[_N]/`s2'[_N];
end;



/***************************************/
/* Quantile                            */
/***************************************/
cap program drop quant;
program define quant, rclass;
args fw yyy xval;
preserve;
sort `yyy';
qui cap drop if `yyy'>=. | `fw'>=.;
tempvar ww qp pc;
qui gen `ww'=sum(`fw');
qui gen `pc'=`ww'/`ww'[_N];
qui gen `qp' = `yyy' ;
qui sum `yyy' [aw=`fw'];
local i=1;
while (`pc'[`i'] < `xval') {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) local qnt=`qp'[`ar']+((`qp'[`i']-`qp'[`ar'])/(`pc'[`i']-`pc'[`ar']))*(`pc'[`i']-`pc'[`ar']);
if (`i'==1) local qnt=(max(0,`qp'[`i'])/(`pc'[`i']))*(`pc'[`i']);
return scalar qnt = `qnt';
restore;
end;


/***************************************/
/* FGT                                 */
/***************************************/
capture program drop fgt;
program define fgt, rclass;
syntax varlist(min=1 max=1) [, FWeight(string) HGroup(string) GNumber(integer 1) 
PLine(string) ALpha(real 0) type(string)];
tokenize `varlist';
tempvar fw ga hy;
gen `hy' = `1';
gen `fw'=1;
if ("`fweight'"~="")    qui replace `fw'=`fw'*`fweight';
if ("`hgroup'" ~="")    qui replace `fw'=`fw'*(`hgroup'==`gnumber');
gen `ga' = 0;
if (`alpha'==0) qui replace `ga' = (`pline'>`hy');
if (`alpha'~=0) qui replace `ga' = ((`pline'-`hy'))^`alpha' if (`pline'>`hy');
qui sum `ga' [aweight= `fw'];
local fgt = r(mean);
if ("`type'" == "nor") local fgt = `fgt' /(`pline'^`alpha');
return scalar fgt = `fgt';
end;




capture program drop difgt2;
program define difgt2, rclass;
version 9.2;
syntax varlist [,  FWeight(string) HSize(varname)  AL(real 0) 
PL(string) OPL(string) PROP(real 0.5) PERC(real 0.4)
TYpe(string) INDex(string) CONF(string) LEVEL(real 95)];
preserve;
tokenize `varlist';
tempvar hs hsy;
gen `hs' =`hsize';
if ("`opl'"=="mean") {;
qui sum `1' [aw=`fweight'], meanonly; 
local pl=`prop'*`r(mean)';
local mu = `r(mean)';
if (`al'==0){;
qui dens `fweight' `1' `pl'; 
local pprim = `r(den)';
qui dens `fweight' `1' `qnt'; 
local fqp  = `r(den)';
};
if (`al'>=1){;
local al1=`al'-1;
qui fgt `1', fweight(`fweight') pline(`pl') alpha(`al1'); 
local pprim = `al'*`r(fgt)';
};
};
if ("`opl'"=="quantile") {;
qui quant `fweight' `1' `perc'; 
local pl=`prop'*`r(qnt)';
local qnt= `r(qnt)';
if (`al'==0){;
qui dens `fweight' `1' `pl'; 
local pprim = `r(den)';
qui dens `fweight' `1' `qnt'; 
local fqp  = `r(den)';
};

if (`al'>=1){;
local al1=`al'-1;
qui fgt `1', fweight(`fweight') pline(`pl') alpha(`al1'); 
local pprim = `al'*`r(fgt)';
qui dens `fweight' `1' `qnt'; 
local fqp  = `r(den)';
};
};
fgt `1', fweight(`fweight') pline(`pl') alpha(`al') type(`type'); 
local est = `r(fgt)';

cap drop `num' `snum';
tempvar num snum;
qui gen   `num'=0;
qui gen  `snum'=0;
if (`al' == 0)           qui replace    `num' = `hs'*(`pl'> `1');
if (`al' ~= 0)           qui replace    `num' = `hs'*(`pl'-`1')^`al'  if (`pl'>`1');
if ((`"`opl'"'=="") & (`"`type'"'=="nor")  & `al'!=0)   qui replace `num' = `num'/(`pl'^`al')  if (`pl'>`1');

if ("`opl'"=="mean")     qui replace    `snum' =  `pprim'*`hs'*(`prop'*`1'- `pl'); 
if ("`opl'"=="quantile") qui replace    `snum' = -`pprim'*`hs'* `prop' * ((`qnt'>`1')-`perc')/`fqp'  ;


if  (`"`opl'"'=="" ) {;
qui svy: ratio `num'/`hs';
cap drop matrix _vv;
matrix _vv=e(V);
local std = el(_vv,1,1)^0.5;
};


if  ("`opl'"~="") {;
cap drop `hsy';
if ("`opl'"=="mean")     qui gen `hsy' = `prop'*`hs'*`1';
if ("`opl'"=="quantile") qui gen `hsy'= -`hs'* `prop' *((`qnt'>`1')-`perc')/`fqp'  + `hs'*`pl';
qui svy: mean `num' `snum' `hsy' `hs';


if ("`type'"!="nor" | `al'==0 ) qui nlcom (_b[`num']/_b[`hs']+_b[`snum']/_b[`hs'] ),  iterate(10000);
if ("`type'"=="nor" & `al'!=0)  qui nlcom (_b[`num']/_b[`hs']+_b[`snum']/_b[`hs'] )/((_b[`hsy']/_b[`hs'])^`al'),  iterate(10000);
cap drop matrix _vv;
matrix _vv=r(V);
local std = el(_vv,1,1)^0.5;
};

if ("`index'"=="ede") {;
local std = (1 / `al' )*`est'^( 1/ `al' - 1)*`std';
local est = `est'^(1/`al');
};


qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');

return scalar pl  = `pl';
return scalar est  = `est';
return scalar df  = `fr';
qui count; return scalar nobs  = `r(N)';
return scalar std  = `std';
return scalar lb   = `est' - `tt'*`std';
return scalar ub   = `est' + `tt'*`std';


end;




capture program drop difgt2d;
program define difgt2d, rclass;
version 9.2;
syntax namelist [,  FWEIGHT1(string) FWEIGHT2(string) HS1(string) HS2(string) AL(real 0) 
PL1(string) PL2(string) 
OPL1(string) 
PROP1(real 0.5) 
PERC1(real 0.4)
OPL2(string) 
PROP2(real 0.5) 
PERC2(real 0.4)
TYpe(string) INDex(string) CONF(string) LEVEL(real 95)];

tokenize `namelist';
tempvar num1 num2 snum1 snum2 hsy1 hsy2;
qui gen  `num1'=0;
qui gen  `num2'=0;


if ("`opl1'"=="mean") {;
qui sum `1' [aw=`fweight1'], meanonly; 
local pl1=`prop1'*`r(mean)';
local mu = `r(mean)';
if (`al'==0){;
qui dens `fweight1' `1' `pl1'; 
local pprim1 = `r(den)';
};
if (`al'>=1){;
local al1=`al'-1;
qui fgt `1', fweight(`fweight1') pline(`pl1') alpha(`al1'); 
local pprim1 = `al'*`r(fgt)';
};
};



if ("`opl1'"=="quantile") {;
qui quant `fweight1' `1' `perc1'; 
local pl1=`prop1'*`r(qnt)';
local qnt1= `r(qnt)';
if (`al'==0){;
qui dens `fweight1' `1' `pl1'; 
local pprim1 = `r(den)';
qui dens `fweight1' `1' `qnt1'; 
local fqp1  = `r(den)';
};

if (`al'>=1){;
local al1=`al'-1;
qui fgt `1', fweight(`fweight1') pline(`pl1') alpha(`al1'); 
local pprim1 = `al'*`r(fgt)';
qui dens `fweight1' `1' `qnt1'; 
local fqp1  = `r(den)';
};
};
fgt `1', fweight(`fweight1') pline(`pl1') alpha(`al') type(`type'); 
local est1 = `r(fgt)';

cap drop `num1' `snum1';
tempvar num1 snum1;
qui gen   `num1'=0;
qui gen  `snum1'=0;
if (`al' == 0)           qui replace    `num1' = `hs1'*(`pl1'> `1');
if (`al' ~= 0)           qui replace    `num1' = `hs1'*(`pl1'-`1')^`al'  if (`pl1'>`1');
if ((`"`opl1'"'=="") & (`"`type'"'=="nor")  & `al'!=0)   qui replace `num1' = `num1'/(`pl1'^`al')  if (`pl1'>`1');

if ("`opl1'"=="mean")     qui replace    `snum1' =  `pprim1'*`hs1'*(`prop1'*`1'- `pl1'); 
if ("`opl1'"=="quantile") qui replace    `snum1' = -`pprim1'*`hs1'* `prop1' * ((`qnt1'>`1')-`perc1')/`fqp1'  ;




if  (`"`opl1'"'=="" ) {;
qui svy: ratio (eq1: `num1'/`hs1');
cap drop matrix _vv;
matrix _vv=e(V);
local std1 = el(_vv,1,1)^0.5;
};


if  ("`opl1'"~="") {;
cap drop `hsy1';
if ("`opl1'"=="mean")     qui gen `hsy1' = `prop1'*`hs1'*`1';
if ("`opl1'"=="quantile") qui gen `hsy1'= -`hs1'* `prop1' *((`qnt1'>`1')-`perc1')/`fqp1'  + `hs1'*`pl1';
qui svy: mean `num1' `snum1' `hsy1' `hs1';
if ("`type'"!="nor" | `al'==0 ) qui nlcom (eq1:    _b[`num1']/_b[`hs1']+_b[`snum1']/_b[`hs1']                                ),  iterate(10000);
if ("`type'"=="nor" & `al'!=0)  qui nlcom (eq1:   (_b[`num1']/_b[`hs1']+_b[`snum1']/_b[`hs1'])/(_b[`hsy1']/_b[`hs1'])^`al'  ), iterate(10000);
cap drop matrix _vv;
matrix _vv=r(V);
local std1 = el(_vv,1,1)^0.5;
};



if ("`opl2'"=="mean") {;
qui sum `2' [aw=`fweight2'], meanonly; 
local pl2=`prop2'*`r(mean)';
local mu = `r(mean)';
if (`al'==0){;
qui dens `fweight2' `2' `pl2'; 
local pprim2 = `r(den)';
};

if (`al'>=1){;
local al2=`al'-1;
qui fgt `2', fweight(`fweight2') pline(`pl2') alpha(`al2'); 
local pprim2 = `al'*`r(fgt)';
};
};


if ("`opl2'"=="quantile") {;
qui quant `fweight2' `2' `perc2'; 
local pl2=`prop2'*`r(qnt)';
local qnt2= `r(qnt)';
if (`al'==0){;
qui dens `fweight2' `2' `pl2'; 
local pprim2 = `r(den)';
qui dens `fweight2' `2' `qnt2'; 
local fqp2  = `r(den)';
};

if (`al'>=1){;
local al1=`al'-1;
qui fgt `2', fweight(`fweight2') pline(`pl2') alpha(`al1'); 
local pprim2 = `al'*`r(fgt)';
qui dens `fweight2' `2' `qnt2'; 
local fqp2  = `r(den)';
};
};

fgt `2', fweight(`fweight2') pline(`pl2') alpha(`al') type(`type'); 
local est2 = `r(fgt)';

cap drop `num2' `snum2';
tempvar num2 snum2;
qui gen   `num2'=0;
qui gen  `snum2'=0;
if (`al' == 0)           qui replace    `num2' = `hs2'*(`pl2'> `2');
if (`al' ~= 0)           qui replace    `num2' = `hs2'*(`pl2'-`2')^`al'  if (`pl2'>`2');
if ((`"`opl2'"'=="") & (`"`type'"'=="nor")  & `al'!=0)   qui replace `num2' = `num2'/(`pl2'^`al')  if (`pl2'>`2');

if ("`opl2'"=="mean")     qui replace    `snum2' =  `pprim2'*`hs2'*(`prop2'*`2'- `pl2'); 
if ("`opl2'"=="quantile") qui replace    `snum2' = -`pprim2'*`hs2'* `prop2' * ((`qnt2'>`2')-`perc2')/`fqp2';


if  (`"`opl2'"'=="" ) {;
qui svy: ratio (eq2: `num2'/`hs2');
cap drop matrix _vv;
matrix _vv=e(V);
local std2 = el(_vv,1,1)^0.5;
};


if  ("`opl2'"~="") {;
cap drop `hsy2';
if ("`opl2'"=="mean")     qui gen `hsy2' = `prop2'*`hs2'*`2';
if ("`opl2'"=="quantile") qui gen `hsy2'= -`hs2'* `prop2' *((`qnt2'>`2')-`perc2')/`fqp2'  + `hs1'*`pl2';
qui svy: mean `num2' `snum2' `hsy2' `hs2';
if ("`type'"!="nor" | `al'==0 ) qui nlcom (eq2:   _b[`num2']/_b[`hs2']+_b[`snum2']/_b[`hs2']),  iterate(10000);
if ("`type'"=="nor" & `al'!=0)  qui nlcom (eq2:  (_b[`num2']/_b[`hs2']+_b[`snum2']/_b[`hs2'])/(_b[`hsy2']/_b[`hs2'])^`al'),  iterate(10000);
cap drop matrix _vv;
matrix _vv=r(V);
local std2 = el(_vv,1,1)^0.5;
};




local est3=`est2'-`est1';

local equa1="";
if  (`"`opl1'"'=="") {;
local equa1 = "(_b[`num1']/_b[`hs1'])";
local smean1 = "`num1' `hs1' ";
};
if (`"`opl1'"'!="") {;
if ("`type'"!="nor" | `al'==0)  local equa1 = "(_b[`num1']/_b[`hs1']+_b[`snum1']/_b[`hs1'] )";
if ("`type'"=="nor" & `al'!=0)  local equa1 = "(_b[`num1']/_b[`hs1'])/((_b[`hsy1']/_b[`hs1'])^`al')";
local smean1 = "`num1' `snum1' `hsy1' `hs1' ";
};

local equa2="";
if  (`"`opl2'"'=="") {;
local equa2 = "(_b[`num2']/_b[`hs2'])";
local smean2 = "`num2' `hs2' ";
};

if (`"`opl2'"'!="") {;
if ("`type'"!="nor" | `al'==0)  local equa2 = "(_b[`num2']/_b[`hs2']+_b[`snum2']/_b[`hs2'] )";
if ("`type'"=="nor" & `al'!=0)  local equa2 = "(_b[`num2']/_b[`hs2'])/((_b[`hsy2']/_b[`hs2'])^`al')";
local smean2 = "`num2' `snum2' `hsy2' `hs2' ";
};

qui svy: mean  `smean1' `smean2';

qui nlcom (`equa1'-`equa2'),  iterate(10000);
cap drop matrix _vv;
matrix _vv=r(V);
local std3 = el(_vv,1,1)^0.5;


qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;

if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');

return scalar std1  = `std1';
return scalar est1  = `est1';
return scalar lb1   = `est1' - `tt'*`std1';
return scalar ub1   = `est1' + `tt'*`std1';
return scalar pl1   = `pl1';
return scalar df    = `fr';
qui count; 
return scalar nobs  = `r(N)';

return scalar std2  = `std2';
return scalar est2  = `est2';
return scalar lb2   = `est2' - `tt'*`std2';
return scalar ub2   = `est2' + `tt'*`std2';
return scalar pl2   = `pl2';

return scalar std3  = `std3';
return scalar est3  = `est3';
return scalar lb3   = `est3' - `tt'*`std3';
return scalar ub3   = `est3' + `tt'*`std3';


end;






capture program drop difgt;
program define difgt, eclass;
version 9.2;
syntax  namelist(min=2 max=2) [, FILE1(string) FILE2(string) HSize1(string) HSize2(string)
ALpha(real 0)  COND1(string) COND2(string) 
PLINE1(string) OPL1(string) PROP1(real 50) PERC1(real 0.4)
PLINE2(string) OPL2(string) PROP2(real 50) PERC2(real 0.4)
type(string) LEVEL(real 95) CONF(string) DEC(int 6) BOOT(string) NREP(string) TEST(string)];

global indica=3;
tokenize `namelist';

if ("`prop1'"!="")          local prop1=`prop1'/100;
if ("`prop2'"!="")          local prop2=`prop2'/100;
if ("`type'"=="")          local type="nor";
if ("`conf'"=="")          local conf="ts";

if ("`opl1'"=="median")   {;
local opl1 = "quantile";
local perc1 = 0.5;
};

if ("`opl2'"=="median")   {;
local opl2 = "quantile";
local perc2 = 0.5;
};



preserve;

local indep = ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  );


if ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;
if (`"`file1'"'~="") use `"`file1'"', replace;


tempvar cd1 ths1;

qui gen `ths1'=1;
if ( "`hsize1'"!="") qui replace `ths1'=`hsize1';
if ( "`cond1'"!="") {;
gen `cd1'=`cond1';
qui replace `ths1'=`ths1'*`cd1';
qui sum `cd1';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_1, the number of observations is 0.";
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
dis as error " With condition(s) of distribution_2, the number of observations is 0.";
exit;
};
};


qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
tempvar fw1 fw2;
gen `fw1'=`ths1';
gen `fw2'=`ths2';
if ("`hweight'"!="") qui replace `fw1'=`fw1'*`hweight';
if ("`hweight'"!="") qui replace `fw2'=`fw2'*`hweight';

difgt2d `1' `2' ,  fweight1(`fw1') fweight2(`fw2') 
hs1(`ths1') hs2(`ths2') 
pl1(`pline1') pl2(`pline2') 
opl1(`opl1') prop1(`prop1') perc1(`perc1')
opl2(`opl2') prop2(`prop2') perc2(`perc2')
al(`alpha') type(`type')  level(`level') conf(`conf');

matrix _res_d1  =(`r(est1)',`r(std1)',`r(lb1)',`r(ub1)' ,`r(pl1)');
matrix _res_d2  =(`r(est2)',`r(std2)',`r(lb2)',`r(ub2)' ,`r(pl2)');
matrix _res_di  =(`r(est3)',`r(std3)',`r(lb3)',`r(ub3)');

_dasp_dif_table_ifgt `1' `1', 
name1("`1'") name2("`2'")
pl1(`r(pl1)')  pl2(`r(pl2)')
m1(`r(est1)')  m2(`r(est2)')
s1(`r(std1)')  s2(`r(std2)')
df1(`r(df)') df2(`r(df)')
dif(`r(est3)') sdif(`r(std3)')
level(`level') conf(`conf') indep(`indep') test(`test');



};


// second stage
if !( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;
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
dis as error " With condition(s) of distribution_1, the number of observations is 0.";
exit;
};
};

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight1=""; 
cap qui svy: total `1'; 
local hweight1=`"`e(wvar)'"';
cap ereturn clear; 

tempvar fw1;
gen `fw1'=`ths1';
if ("`hweight1'"!="") qui replace `fw1'=`fw1'*`hweight1';

difgt2 `1' , fweight(`fw1') hsize(`ths1') pl(`pline1') opl(`opl1') prop(`prop1') 
perc(`perc1') al(`alpha') type(`type')  conf(`conf') level(`level') ;
matrix _res_d1  =(`r(est)',`r(std)',`r(lb)',`r(ub)' ,`r(pl)', `r(df)');



if ("`file2'" !="") use `"`file2'"', replace;
tempvar cd2 ths2;

qui gen `ths2'=1;
if ( "`hsize2'"!="") qui replace `ths2'=`hsize2';
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace `ths2'=`ths2'*`cd2';
qui sum `cd2';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_2 the number of observations is 0.";
exit;
};
};
qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local hweight2=""; 
cap qui svy: total `2'; 
local hweight2=`"`e(wvar)'"';
cap ereturn clear; 

tempvar fw2;
gen `fw2'=`ths2';

if ("`hweight2'"!="") qui replace `fw2'=`fw2'*`hweight2';


difgt2 `2' , fweight(`fw2') hsize(`ths2') pl(`pline2') opl(`opl2') prop(`prop2') 
perc(`perc2') al(`alpha') type(`type')  conf(`conf') level(`level') ;
matrix _res_d2  =(`r(est)',`r(std)',`r(lb)',`r(ub)' ,`r(pl)', `r(df)');



local dif = el(_res_d2,1,1)-el(_res_d1,1,1);
local stdif = (el(_res_d1,1,2)^2+el(_res_d2,1,2)^2)^0.5;

matrix _res_di =(`dif',`stdif');

local est1=el(_res_d1,1,1);
local est2=el(_res_d2,1,1);

local std1=el(_res_d1,1,2);
local std2=el(_res_d2,1,2);

local df1=el(_res_d1,1,6);
local df2=el(_res_d2,1,6);

local pl1=el(_res_d1,1,5);
local pl2=el(_res_d2,1,5);
local name1 "FGT_Dist1";
local name2 "FGT_Dist2";     
_dasp_dif_table_ifgt `2' `2', 
name1("`name1'")          name2("`name2'")
pl1(`pl1')         pl2(`pl2')
m1(`est1')            m2(`est2')
s1(`std1')             s2(`std2')
df1(`df1')            df2(`df2')
dif(`dif') sdif(`stdif')
level(`level') conf(`conf') indep(`indep') test(`test');
};


restore;

ereturn matrix d1 = _res_d1;
ereturn matrix d2 = _res_d2;
ereturn matrix di = _res_di;


cap matrix drop _res_d1;
cap matrix drop _res_d2;
cap matrix drop _res_di;
end;



