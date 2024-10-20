/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.0)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universit Laval, Quebec, Canada                                      */
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
/* Non parametric regression           */
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
syntax varlist(min=1 max=1) [, FWeight(string) HGroup(string) GNumber(integer 1) 
PLine(real 0) ALpha(real 0) type(string)];
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




capture program drop ifgt2;
program define ifgt2, rclass;
version 9.2;
syntax varlist [,  FWeight(string) HSize(string) HGroup(varname) GNumber(int -1) AL(real 0) PL(string) OPL(string) PROP(real 0.5) PERC(real 0.4) REL(string) TYpe(string) INDex(string) CONF(string) LEVEL(real 95)];
preserve;
tokenize `varlist';
tempvar hs hsr hsy;
gen `hs' =`hsize';
gen `hsr'=`hsize';

if ("`rel'"=="group" & `gnumber'!=-1) qui replace `fweight'=`fweight'*(`hgroup'==`gnumber');
if (`gnumber'!=-1)    qui replace `hs'  =`hs'*(`hgroup'==`gnumber');
if ("`rel'"=="group") qui replace `hsr' = `hs';

if ("`opl'"=="mean") {;
qui sum `1' [aw=`fweight'], meanonly; 
local pl=`prop'*`r(mean)';
local mu = `r(mean)';
if (`al'==0){;
qui ifgt_den `fweight' `1' `pl'; 
local pprim = `r(den)';
qui ifgt_den `fweight' `1' `qnt'; 
local fqp  = `r(den)';
};
if (`al'>0){;
local al1=`al'-1;
qui fgt `1', fweight(`fweight') pline(`pl') alpha(`al1'); 
local pprim = `al'*`r(fgt)';
};
};


if ("`opl'"=="quantile") {;
qui ifgt_qua `fweight' `1' `perc'; 
local pl=`prop'*`r(qnt)';
local qnt= `r(qnt)';
if (`al'==0){;
qui ifgt_den `fweight' `1' `pl'; 
local pprim = `r(den)';
qui ifgt_den `fweight' `1' `qnt'; 
local fqp  = `r(den)';
};
if (`al'>0){;
local al1=`al'-1;
qui fgt `1', fweight(`fweight') pline(`pl') alpha(`al1'); 
local pprim = `al'*`r(fgt)';
qui ifgt_den `fweight' `1' `qnt'; 
local fqp  = `r(den)';
};
};

fgt `1', fweight(`fweight') pline(`pl') alpha(`al') type(`type') hgroup(`hgroup') gnumber(`gnumber'); 
local est = `r(fgt)';

cap drop `num' `snum';
tempvar num snum;
qui gen   `num'=0;
qui gen  `snum'=0;
if (`al' == 0)           qui replace    `num' = `hs'*(`pl'> `1');
if (`al' ~= 0)           qui replace    `num' = `hs'*(`pl'-`1')^`al'  if (`pl'>`1');
if ((`"`opl'"'=="") & (`"`type'"'=="nor")  & `al'!=0)   qui replace `num' = `num'/(`pl'^`al')  if (`pl'>`1');

if ("`opl'"=="mean")     qui replace    `snum' =  `pprim'*`hsr'*(`prop'*`1'-`pl'); 
if ("`opl'"=="quantile") qui replace    `snum' = -`pprim'* `hsr'* `prop' * ((`qnt'>`1')-`perc')/`fqp'  ;


if  (`"`opl'"'=="" ) {;
qui svy: ratio `num'/`hs';
cap drop matrix _vv;
matrix _vv=e(V);
local std = el(_vv,1,1)^0.5;
};


if  ("`opl'"~="") {;
cap drop `hsy';
if ("`opl'"=="mean")     qui gen `hsy' = `prop'*`hsr'*`1';
if ("`opl'"=="quantile") qui gen `hsy'= -`hsr'* `prop' *((`qnt'>`1')-`perc')/`fqp'  + `hsr'*`pl';

qui svy: mean `num' `snum' `hsy' `hs' `hsr';
if ("`type'"!="nor" | `al'==0 ) qui nlcom (_b[`num']/_b[`hs'] + _b[`snum']/_b[`hsr']),        iterate(10000) ;
if ("`type'"=="nor" & `al'!=0)  qui nlcom (_b[`num']/_b[`hs'])/((_b[`hsy']/_b[`hsr'])^`al'),  iterate(10000);
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

return scalar pl   = `pl';
return scalar est  = `est';
return scalar std  = `std';
return scalar lb   = `est' - `tt'*`std';
return scalar ub   = `est' + `tt'*`std';


end;

capture program drop ifgt;
program define ifgt, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) HGroup(varname) ALpha(real 0) PLine(real 0) 
OPL(string) PROP(real 50) PERC(real 0.4) REL(string) type(string) INDex(string) CONF(string)
LEVEL(real 95) DEC(int 6)];

if ("`prop'"!="")          local prop=`prop'/100;
if ("`type'"=="")          local type="nor";
if ("`conf'"=="")          local conf="ts";
if ("`rel'"=="")           local rel ="popul"; 
local ll=0;

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);


local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

/* ERRORS */

if (`alpha' == 0 & "`index'"=="ede") {;
 di as err "For the EDE index, the parameter alpha should be greater than 0."; exit;
};


if ("`opl'"=="median")   {;
local opl = "quantile";
local perc = 0.5;
};


if ("`hgroup'"!="") {;

preserve;
capture {;
local lvgroup:value label `hgroup';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , clear;
qui count;
forvalues i=1/`r(N)' {;
local tem=value[`i'];
local grlab`tem' = label[`i'];
};
};
};
restore;
preserve;
qui tabulate `hgroup', matrow(gn);
svmat int gn;
global indica=r(r);
tokenize `varlist';
};

if ("`hgroup'"=="") {;
tokenize `varlist';
_nargs    `varlist';
preserve;
};
local ci=100-`level';
tempvar Variable Estimate STD LB UB PL;
qui gen `Variable'="";
qui gen `Estimate'=0;
qui gen `STD'=0;
qui gen `LB'=0;
qui gen `UB'=0;
qui gen `PL'=0;

tempvar _ths _fw;

qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';
qui gen `_fw'=`_ths';
if (`"`hweight'"'~="") qui replace `_fw'=`_fw'*`hweight';


local ll=length("`1': `grlab`1''");
local component = "Variable";
forvalues k = 1/$indica {;
if ("`hgroup'"=="") {;
qui replace `Variable' = "``k''" in `k';
ifgt2 ``k'' , fweight(`_fw') hsize(`_ths') pl(`pline') opl(`opl') prop(`prop') 
perc(`perc') al(`alpha') type(`type') index(`index') conf(`conf') level(`level');
local pline=`r(pl)';
qui replace `Estimate' = `r(est)' in `k';
qui replace `STD'      = `r(std)' in `k';
qui replace `LB'       = `r(lb)'  in `k';
qui replace `UB'       = `r(ub)'  in `k';
qui replace `PL'       = `r(pl)'  in `k';
if ("`conf'"=="lb")   qui replace `UB'       =.  in `k';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `k';

};

if ("`hgroup'"!="") {;
local kk = gn1[`k'];

if ( "`grlab`kk''" == "") local grlab`kk' = "Group_`kk'";
qui replace `Variable' = "`kk': `grlab`kk''" in `k';

ifgt2 `1' ,  fweight(`_fw') hsize(`_ths') pl(`pline') opl(`opl') prop(`prop') 
perc(`perc') rel(`rel')  al(`alpha') type(`type') index(`index') conf(`conf') 
level(`level') hgroup(`hgroup') gnumber(`kk');
qui replace `Estimate' = `r(est)' in `k';
qui replace `STD'      = `r(std)' in `k';
qui replace `LB'       = `r(lb)'  in `k';
qui replace `UB'       = `r(ub)'  in `k';
qui replace `PL'       = `r(pl)'  in `k';
if ("`conf'"=="lb")   qui replace `UB'       =.  in `k';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `k';

local ll=max(`ll',length("`kk': `grlab`k''"));
local component = "Group";
};

};

local ll=`ll'+6;
if ("`type'"=="not")  local nor = "Non normalised ";
if ("`index'"=="ede") local ind = "EDE-";

if ("`hgroup'"!="") {;
ifgt2 `1' ,  fweight(`_fw') hsize(`_ths') pl(`pline') opl(`opl') prop(`prop') 
perc(`perc') al(`alpha') type(`type') index(`index') conf(`conf') level(`level');
local kk =$indica + 1;
qui replace `Variable' = "Population" in `kk';
qui replace `Estimate' = `r(est)' in `kk';
qui replace `STD'      = `r(std)' in `kk';
qui replace `LB'       = `r(lb)'  in `kk';
qui replace `UB'       = `r(ub)'  in `kk';
qui replace `PL'       = `r(pl)'  in `kk';
if ("`conf'"=="lb")   qui replace `UB'       =.  in `kk';
if ("`conf'"=="ub")   qui replace `LB'       =.  in `kk';
};

local 1kk = $indica;
if ("`hgroup'"!="") local  1kk=`kk'-1;
tempname table;
	.`table'  = ._tab.new, col(6)  separator(0) lmargin(0);
	.`table'.width  `ll'|16 16 16 16 16 ;
	.`table'.strcolor . . yellow . . . ;
	.`table'.numcolor yellow yellow . yellow yellow white ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f %16.2f;
	                      di _n as text in white "{col 5}Poverty index   :  `nor'`ind'FGT index";
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";
       
        di  as text "{col 5}Parameter alpha : "  %5.2f `alpha'       ;
      .`table'.sep, top;
	.`table'.titles "`component'  " "Estimate" "STD "	"  LB  " "  UB  " "Pov. line" ;
	
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`1kk'{;
           		.`table'.row `Variable'[`i'] `Estimate'[`i'] `STD'[`i'] `LB'[`i'] `UB'[`i'] `PL'[`i']; 
	};
 if ("`hgroup'"=="")  .`table'.sep,bot;
if ("`hgroup'"!="") {;
  .`table'.sep, mid;
  .`table'.numcolor white green   green  green green white ;
  .`table'.row `Variable'[`kk'] `Estimate'[`kk']  `STD'[`kk'] `LB'[`kk'] `UB'[`kk'] `PL'[`kk'];
  .`table'.sep,bot;
};


cap ereturn clear;

local est="(";
local std="(";
forvalues i=1/$indica{;
local tem1=`Estimate'[`i'];
local tem2=`STD'[`i'];
 if (`i'!=$indica) local est = "`est'"+ "`tem1'\";
 if (`i'==$indica) local est = "`est'"+ "`tem1')";
 if (`i'!=$indica) local std = "`std'"+ "`tem2'\";
 if (`i'==$indica) local std = "`std'"+ "`tem2')";
};
tempname ES ST;
matrix define `ES'=`est';
matrix define `ST'=`std';
ereturn matrix est = `ES';
ereturn matrix std = `ST';
restore;
end;



