

/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : ifgt                                                        */
/*************************************************************************/

#delim ;

/*****************************************************/
/* Density function      : fw=Hweight*Hsize      */
/*****************************************************/
cap program drop ifgt_den;                    
program define ifgt_den, rclass;              
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
/* Nonparametric regression           */
/***************************************/
cap program drop ifgt_npe;
program define ifgt_npe, rclass;
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
cap program drop ifgt_qua;
program define ifgt_qua, rclass;
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
syntax varlist(min=1 max=1) [, FWeight(string) HGroup(string) GNumber(integer 1)  PLINE(string) ALpha(real 0) type(string)];
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
if ("`type'" == "nor" & `alpha' !=0) local fgt = `fgt' /(`pline'^`alpha');
return scalar fgt = `fgt';
end;


capture program drop difgt2dn;
program define difgt2dn, rclass;
version 9.2;
syntax namelist [,  FWEIGHT1(string) FWEIGHT2(string) HS1(string) HS2(string) AL(real 0) 
PL1(string) PL2(string) 
OPL1(string) 
PROP1(real 0.5) 
PERC1(real 0.4)
OPL2(string) 
PROP2(real 0.5) 
PERC2(real 0.4)
TYpe(string) INDex(string) ];



tokenize `namelist';
tempvar num1 num2 snum1 snum2 hsy1 hsy2;
qui gen  `num1'=0;
qui gen  `num2'=0;

if ("`opl1'"=="mean") {;
qui sum `1' [aw=`fweight1'], meanonly; 
local pl1=`prop1'*`r(mean)';
local mu = `r(mean)';
if (`al'==0){;
qui ifgt_den `fweight1' `1' `pl1'; 
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
qui ifgt_den `fweight1' `1' `pl1'; 
local pprim1 = `r(den)';
qui ifgt_den `fweight1' `1' `qnt1'; 
local fqp1  = `r(den)';
};

if (`al'>=1){;
local al1=`al'-1;
qui fgt `1', fweight(`fweight1') pline(`pl1') alpha(`al1'); 
local pprim1 = `al'*`r(fgt)';
qui ifgt_den `fweight1' `1' `qnt1'; 
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
local ste1 = el(_vv,1,1)^0.5;
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
local ste1 = el(_vv,1,1)^0.5;
};



if ("`opl2'"=="mean") {;
qui sum `2' [aw=`fweight2'], meanonly; 
local pl2=`prop2'*`r(mean)';
local mu = `r(mean)';
if (`al'==0){;
qui ifgt_den `fweight2' `2' `pl2'; 
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
qui ifgt_den `fweight2' `2' `pl2'; 
local pprim2 = `r(den)';
qui ifgt_den `fweight2' `2' `qnt2'; 
local fqp2  = `r(den)';
};

if (`al'>=1){;
local al1=`al'-1;
qui fgt `2', fweight(`fweight2') pline(`pl2') alpha(`al1'); 
local pprim2 = `al'*`r(fgt)';
qui ifgt_den `fweight2' `2' `qnt2'; 
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
local ste2 = el(_vv,1,1)^0.5;
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
local ste2 = el(_vv,1,1)^0.5;
};




local dif=`est2'-`est1';

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

qui nlcom (`equa2'-`equa1'),  iterate(10000);
cap drop matrix _vv;
matrix _vv=r(V);
local sdif = el(_vv,1,1)^0.5;


return scalar ste1  = `ste1';
return scalar est1  = `est1';



return scalar ste2  = `ste2';
return scalar est2  = `est2';


return scalar sdif  = `sdif';
return scalar dif  = `dif';



end;




#delimit ;
capture program drop mbasicfgt2;
program define mbasicfgt2, eclass;
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

local prop1 = `prop1'/100 ;
local prop2 = `prop2'/100 ;

tempvar  ths1;

qui gen `ths1'=1;
if ( "`hsize1'"!="") qui replace `ths1'=`hsize1';
tempvar  ths2;
qui gen `ths2'=1;
if ( "`hsize2'"!="") qui replace `ths2'=`hsize2';



/************/

if ("`hgroup'" =="") {;
matrix __ms = J(1,6,0);
difgt2dn `1' `2' ,  fweight1(`fw1') fweight2(`fw2') 
hs1(`ths1') hs2(`ths2') 
pl1(`pline1') pl2(`pline2') 
opl1(`opl1') prop1(`prop1') perc1(`perc1')
opl2(`opl2') prop2(`prop2') perc2(`perc2')
al(`alpha') type(`type')  ;

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
difgt2dn `1' `2' ,  fweight1(`fw1') fweight2(`fw2') 
hs1(`ths1') hs2(`ths2') 
pl1(`pline1') pl2(`pline2') 
opl1(`opl1') prop1(`prop1') perc1(`perc1')
opl2(`opl2') prop2(`prop2') perc2(`perc2')
al(`alpha') type(`type')  ;
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
