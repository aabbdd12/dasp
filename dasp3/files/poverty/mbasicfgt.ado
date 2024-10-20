

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



capture program drop ifgt2nn;
program define ifgt2nn, rclass;
version 9.2;
syntax varlist [,  FWeight(string) HSize(string) HGroup(varname) GNumber(int -1) AL(real 0) PLN(string) opl(string) PROP(real 50) PERC(real 0.4) REL(string) TYpe(string) INDex(string)];
preserve;
tokenize `varlist';



if "`opl'" =="median" {;
	local opl="quantile"; 
	local perc=0.5;
} ;
cap drop if `1' ==.;
tempvar hs hsr hsy;
gen `hs' =`hsize';
gen `hsr'=`hsize';
local prop = `prop'/100 ;



if ("`rel'"=="group" & `gnumber'!=-1) qui replace `fweight'=`fweight'*(`hgroup'==`gnumber');
if (`gnumber'!=-1)    qui replace `hs'  =`hs'*(`hgroup'==`gnumber');
if ("`rel'"=="group") qui replace `hsr' = `hs';

if ("`opl'"=="mean") {;
qui sum `1' [aw=`fweight'], meanonly; 
local pln=`prop'*`r(mean)';
local mu = `r(mean)';
if (`al'==0){;
qui ifgt_den `fweight' `1' `pln'; 
local pprim = `r(den)';
qui ifgt_den `fweight' `1' `qnt'; 
local fqp  = `r(den)';
};
if (`al'>0){;
local al1=`al'-1;
qui fgt `1', fweight(`fweight') pline(`pln') alpha(`al1'); 
local pprim = `al'*`r(fgt)';
};
};


if ("`opl'"=="quantile") {;
qui ifgt_qua `fweight' `1' `perc'; 
local pln=`prop'*`r(qnt)';
local qnt= `r(qnt)';
if (`al'==0){;
qui ifgt_den `fweight' `1' `pln'; 
local pprim = `r(den)';
qui ifgt_den `fweight' `1' `qnt'; 
local fqp  = `r(den)';
};
if (`al'>0){;
local al1=`al'-1;
qui fgt `1', fweight(`fweight') pline(`pln') alpha(`al1'); 
local pprim = `al'*`r(fgt)';
qui ifgt_den `fweight' `1' `qnt'; 
local fqp  = `r(den)';
};
};


fgt `1', fweight(`fweight') pline(`pln') alpha(`al') type(`type') hgroup(`hgroup') gnumber(`gnumber'); 
local est = `r(fgt)';

cap drop `num' `snum';
tempvar num snum;
qui gen   `num'=0;
qui gen  `snum'=0;
if (`al' == 0)           qui replace   `num' = `hs'*(`pln'> `1');
if (`al' ~= 0)           qui replace   `num' = `hs'*(`pln'-`1')^`al'  if (`pln'>`1');
if (`"`opl'"'=="" & `"`type'"'=="nor"  & `al'!=0)   qui replace `num' = `num'/(`pln'^`al')  if (`pln'>`1');
if ("`opl'"=="mean")     qui replace   `snum' =  `pprim'* `hsr'*(`prop'*`1'-`pln'); 
if ("`opl'"=="quantile") qui replace   `snum' = -`pprim'* `hsr'* `prop' * ((`qnt'>`1')-`perc')/`fqp'  ;


if  (`"`opl'"'=="" ) {;
qui svy: ratio `num'/`hs';
cap drop matrix _vv;
matrix _vv=e(V);
local ste = el(_vv,1,1)^0.5;
};


if  ("`opl'"~="") {;
cap drop `hsy';
if ("`opl'"=="mean")     qui gen `hsy' = `prop'*`hsr'*`1';
if ("`opl'"=="quantile") qui gen `hsy'= -`hsr'* `prop' *((`qnt'>`1')-`perc')/`fqp'  + `hsr'*`pln';

qui svy: mean `num' `snum' `hsy' `hs' `hsr';
if ("`type'"!="nor" | `al'==0 ) qui nlcom (_b[`num']/_b[`hs'] + _b[`snum']/_b[`hsr']),        iterate(10000) ;

if ("`type'"=="nor" & `al'!=0)  qui nlcom ((_b[`num']/_b[`hs'] + _b[`snum']/_b[`hsr']))/((_b[`hsy']/_b[`hsr'])^`al'),  iterate(10000);
cap drop matrix _vv;
matrix _vv=r(V);
local ste = el(_vv,1,1)^0.5;
};

if ("`index'"=="ede") {;
local ste = (1 / `al' )*`est'^( 1/ `al' - 1)*`ste';
local est = `est'^(1/`al');
};


return scalar pl   = `pln';
return scalar est  = `est';
return scalar ste  = `ste';
end;




#delimit ;
capture program drop mbasicfgt;
program define mbasicfgt, eclass;
syntax varlist(min=1)[, HSize(varname) HGroup(varname) ALpha(real 0) PLine(string) 
OPL(string) PROP(real 50) PERC(real 0.4) REL(string) type(string) INDex(string)  XRNAMES(string) *];

tokenize `varlist';

if "`opl'" =="median" {;
	local opl="quantile"; 
	local perc=0.5;
} ;

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

if ("`hgroup'" ~="") {;
if (`popa' == 0 & "`hgroup'"!="") {;

qui levelsof `hgroup', local(vgr);
local zz = wordcount("`vgr'");
matrix __ms = J(3,`zz',0);
local pos = 1 ;
foreach x of local vgr {;
preserve;

ifgt2nn `1' , fweight(`_fw') hsize(`_ths') pln(`pline') opl(`opl') prop(`prop')  perc(`perc') al(`alpha') rel(`rel') type(`type') index(`index') hgroup(`hgroup') gnumber(`x');          
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
ifgt2nn   ``i'' , fweight(`_fw') hsize(`_ths') pln(`pline') opl(`opl') prop(`prop')  perc(`perc') al(`alpha') rel(`rel') type(`type') index(`index');         
matrix __ms[1,`i']  =  `r(est)';
matrix __ms[2,`i']  =  `r(ste)';
matrix __ms[3,`i'] =   `r(pl)';
};	
};




   matrix __ms = __ms ;
ereturn matrix  mmss = __ms ;
end;
