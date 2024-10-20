/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.0)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universit Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : egftg                                                       */
/*************************************************************************/


#delim ;
set more off;

capture program drop nargs;
program define nargs, rclass;
version 9.0;
syntax varlist(min=0);
quietly {;
tokenize `varlist';
local k = 1;
mac shift;
while "``k''" ~= "" {; 
local k = `k'+1;
};
};
global indica=`k';
end;



cap program drop pscong; // (equation_27)
program define pscong, rclass;
syntax varlist(min=1 max=1) [, RHO(real 2) HWeight(varname) HSize(varname) HGroup(varname) NGroup(string) RAnk(varname)];
version 8.0;
tokenize `varlist';
qui {;
preserve;
tempvar fw;
tempvar fwg;
qui gen `fw'=1;
if ("`hsize'"  ~="")     replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")     replace `fw'=`fw'*`hweight';
qui gen `fwg'=`fw';
if ("`hgroup'"~="")      replace `fwg'=`fwg'*(`hgroup'==`ngroup');
if ("`rank'"=="")        gsort -`1';
if ("`rank'"~="")        gsort -`rank';
cap drop if `1' >=.; 
cap drop if `fw'>=.;
gen vr = sum(`fw')^`rho'; gen p = vr  - vr[_n-1];
replace p = vr[1] in 1; 
replace p = p / vr[_N];

qui sum `1' [aw=`fwg']; 
local mug = `r(mean)';
qui sum `1' [aw=`fw']; 
local mu = `r(mean)';

gen   xi = sum((`mug'-`1')*p*(`hgroup'==`ngroup'));  
local xi = xi[_N];

local pscong = (`xi'/`mu');

};
qui sum `fwg' ; 
local s1=`r(sum)'; 
qui sum `fw' ; 
local s2=`r(sum)'; 
local phg=`s1'/`s2';
return scalar pscong = `pscong';
return scalar icrg   = `pscong'*(`mu')/(`mug'*`phg');
restore; 
end;


cap program drop agini;
program define agini, rclass;
syntax varlist(min=1 max=1) [, RHO(real 2)  HWeight(varname) HSize(varname) HGroup(varname) NGroup(string) RAnk(varname)];
version 8.0;
tokenize `varlist';
qui {;
preserve;
tempvar fw;
qui gen `fw'=1;
if ("`hsize'"  ~="")     replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")     replace `fw'=`fw'*`hweight';
if ("`hgroup'"~="")      replace `fw'=`fw'*(`hgroup'==`ngroup');
if ("`rank'"=="")        gsort -`1';
if ("`rank'"~="")        gsort -`rank';
cap drop if `1' >=.; 
cap drop if `fw'>=.;
gen vr = sum(`fw')^`rho'; gen p = vr  - vr[_n-1];
replace p = vr[1] in 1; replace p = p / vr[_N];
gen  xi = sum(p*`1');  local xi = xi[_N];
sum `1' [aw=`fw']; local mu = `r(mean)';
local gini = 1 - `xi'/`mu';
restore; 
};
return scalar gini = `gini';
return scalar mu   = `mu'  ;
end;

cap program drop totwimp;
program define totwimp, rclass;
syntax varlist(min=2) [, RHO(real 2) HWeight(varname) HSize(varname) HGroup(varname) NGroup(string) RAnk(varname)];
version 8.0;
tokenize `varlist';
qui {;
preserve;
tempvar fw;
qui gen `fw'=1;
if ("`hsize'"  ~="")     replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")     replace `fw'=`fw'*`hweight';
if ("`hgroup'"~="")      replace `fw'=`fw'*(`hgroup'==`ngroup');
if ("`rank'"=="")        gsort -`1';
//if ("`rank'"~="")        gsort -`rank';
cap drop if `1' >=.; 
cap drop if `fw'>=.;
gen vr = sum(`fw')^`rho'; gen p = vr  - vr[_n-1];
replace p = vr[1] in 1; replace p = p / vr[_N];
gen  xi = sum(p*(`2'-`1'));  local xi = xi[_N];
sum `1' [aw=`fw']; local mu = `r(mean)';
local totwimp = `xi'/`mu';
restore; 
};
return scalar totwimp = `totwimp';
return scalar mu   = `mu'  ;
end;



capture program drop ifg;
program define ifg, rclass;
version 9.0;
syntax varlist [,  HWeight(varname) HGroup(varname) GNumber(int -1) AL(real 0) PL(string) type(string)];
tokenize `varlist';
cap drop _hhw;
gen      _hhw=1;
if ("`hweight'"!="") qui replace  _hhw=`hweight';
qui sum _hhw;
local s3=`r(mean)';
if ("`hgroup'"!="")  qui replace  _hhw=_hhw*(`hgroup'==`gnumber');
cap drop _num;
qui gen  _num=0;
if (`al' == 0) qui replace                      _num = _hhw*(`pl'> `1');
if (`al' ~= 0  & "`type'"~="nor" )  qui replace _num = _hhw*(`pl'-`1')^`al'  if (`pl'>`1');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace _num = _hhw*((`pl'-`1')/`pl')^`al'  if (`pl'>`1');
qui sum _num;
local s1=`r(mean)';
qui sum _hhw;
local s2=`r(mean)';
return scalar est   = `s1'/`s2';
return scalar psh   = `s2'/`s3';
end;


/***************************************/
/* Density function                    */
/***************************************/

cap program drop den;                    
program define den, rclass;             
syntax varlist(min=1 max=1) [, HSize(string) HWeight(string) HGroup(string) GNumber(integer 1) XVal(real 0) ] ; 
tokenize `varlist';
tempvar x s1 s2 fw;
gen `fw' = 1;
if ("`hsize'"  ~="")    qui replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")    qui replace `fw'=`fw'*`hweight';
local prop = 1;
if ("`hgroup'" ~="") {;
qui sum `fw';
local pop = `r(sum)';
qui sum `fw' if(`hgroup' == `gnumber');
local psh = `r(sum)'/`pop';
};
if ("`hgroup'" ~="")    qui replace `fw'=`fw'*(`hgroup'==`gnumber');  
gen `x' = `1';                 
qui su `x' [aw=`fw'], detail;            
local tmp = (`r(p75)'-`r(p25)')/1.34;                           
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)';     
local h   = 0.9*`tmp'*_N^(-1.0/5.0);                                                                              
gen `s1' = sum( `fw' *exp(-0.5* ( ((`xval'-`x')/`h')^2  )  ));  
gen `s2' = sum( `fw' );
return scalar den = `s1'[_N]/( `h'* sqrt(2*c(pi)) * `s2'[_N] ); 
return local psh `psh'; 
end;


capture program drop efgtg;
program define efgtg, rclass;
version 9.0;
syntax varlist(min=1 max=1)[, HSize(varname)  HGroup(varname) RHO(real 2) ALpha(real 0) PLine(real 0) prc(real 1) type(string) dist(string) INDex(string) STD(string) dec(int 6) CI(real 5)];
local type="nor";
if ("`hgroup'"!="") {;
preserve;

local prc=`prc'/100;
qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

capture {;
local lvgroup:value label `hgroup';
uselabel `lvgroup' , clear;
qui count;
forvalues i=1/`r(N)' {;
local grlab`i' = label[`i'];
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
nargs    `varlist';
preserve;
};


local ll=length("`1': `grlab`1''");
cap drop _ths;
qui gen _ths=1;
if ( "`hsize'"!="") qui replace _ths=`hsize';

cap drop _w;
qui gen _w = _ths ;
if ( "`hweight'"!="") qui replace _w=_ths*`hweight';

qui sum `1' [aw=_w];
local mu=`r(mean)';



gen _y_mu=`mu';
gen _y_mug=0;
gen _y_phi=0;
gen _y_mu_mug=0;



cap drop _sy _sy2;
gen _sy =`1'+`prc'*(`1'-`mu');
gen _sy2=0;
gen _sy3=0;



if (`alpha'==0){;
ifg `1' , hw(_w) pl(`pline') al(`alpha') type(`type');
local p_y = `r(est)';
ifg _sy , hw(_w) pl(`pline') al(`alpha') type(`type');
local p_sy = `r(est)';
local simp =`p_sy'-`p_y';
den `1' , hw(_w) xval(`pline');
local fz=`r(den)';
local timp=`fz'*(`mu'-`pline')*`prc';
};

if (`alpha'>0){;
ifg `1' , hw(_w) pl(`pline') al(`alpha') type(`type');
local p_y = `r(est)';
local al1=`alpha'-1;
ifg `1' , hw(_w) pl(`pline') al(`al1') type(`type');
local p_y_1 = `r(est)';
ifg _sy , hw(_w) pl(`pline') al(`alpha') type(`type');
local p_sy = `r(est)';

local simp =`p_sy'-`p_y';
local timp=`alpha'*(`p_y'+`p_y_1'*(`mu'-`pline')/`pline')*`prc';
};

global p_y=`p_y';
qui agini `1' , rho(`rho') hw(_w);
global I_y=`r(gini)';


local CW=0;
local CB2=0;
local CB3=0;
local cons2=0;

qui gen Group="";
qui gen EST=0;
qui gen EST2=0;
qui gen EST3=0;
qui gen EST4=0;

qui gen COMP="";
qui gen IMPC =0;
qui replace COMP = "TOTAL"      in 1;
qui replace IMPC = `timp'/$p_y  in 1;
global timp=`timp';
local swipov=0;

forvalues k = 1/$indica {;
local kk = gn1[`k'];
pscong `1', rho(`rho') hweight(_w) hgroup(`hgroup') ngroup(`kk');
local pscong=`r(pscong)';
local icrg=`r(icrg)';


qui sum `1' [aw=_w] if (`hgroup'==`kk');
local mug=`r(mean)';


qui replace _y_mug=`mug' if (`hgroup'==`kk');
qui sum _w if (`hgroup'==`kk'); local s1=`r(sum)';
qui sum _w ; local s2=`r(sum)';
local phi=`s1'/`s2';
qui replace _y_phi=`phi' if (`hgroup'==`kk');
qui replace _y_mu_mug=(`mu'/`mug')*`1'                  if (`hgroup'==`kk');
qui replace _sy2=`1'+`prc'*(`mug'-`mu')               if (`hgroup'==`kk');
qui replace _sy3=`1'+`1'*(`prc'*(`mug'-`mu')/`mug')   if (`hgroup'==`kk');


cap drop _syg;
gen _syg =`1'+`prc'*(`1'-`mug')*(`hgroup'==`kk');

ifg _syg , hw(_w) pl(`pline') al(`alpha') type(`type');
local p_y_t = `r(est)';
qui agini _syg , rho(`rho') hw(_w);
local I_y_t=`r(gini)';
local relpg=((`p_y_t'-$p_y)/$p_y);
local relig=((`I_y_t'-$I_y)/$I_y);
local sim_elas=`relpg'/`relig'; 


if (`alpha'==0){;
den `1' , hw(_w) xval(`pline') hg(`hgroup') gnumber(`kk');
local fz = `r(den)';
local psh=`r(psh)';
local timp =`fz'*(`mug'-`pline')*`prc';
local timp2=`fz'*(`mu'-`mug')*`prc';
local timp3=`fz'*(`mu'-`mug')/`mug'*`pline'*`prc';
local timp4=`psh'*(`mug'-`mu')/`mu'*`icrg';
};

if (`alpha'>0){;
ifg `1' , hw(_w) pl(`pline') al(`alpha') type(`type') hg(`hgroup') gnumber(`kk');
local p_y = `r(est)';
local psh=`r(psh)';
local al1=`alpha'-1;
ifg `1' , hw(_w) pl(`pline') al(`al1') type(`type') hg(`hgroup') gnumber(`kk');
local p_y_1 = `r(est)';
local timp=`alpha'*(`p_y'+`p_y_1'*(`mug'-`pline')/`pline')*`prc';
local timp2=`alpha'*(`p_y_1'*(`mu'-`mug')/`pline')*`prc';
local timp3=`alpha'*(`mug'-`mu')/`mug'*(`p_y'-`p_y_1')*`prc';
local timp4=`psh'*(`mug'-`mu')/`mu'*`icrg';
};


ifg _sy2 , hw(_w) pl(`pline') al(`alpha') type(`type');
local p_sy2 = `r(est)';
local simp2 =`p_sy2'-$p_y;

ifg _sy3 , hw(_w) pl(`pline') al(`alpha') type(`type');
local p_sy3 = `r(est)';
local simp3 =`p_sy3'-$p_y;


local CW=`CW'+`psh'*`timp';
local CB2=`CB2'+`psh'*`timp2';
local CB3=`CB3'+`psh'*`timp3';
local cons2=`cons2'+`timp4';


local pscong=`pscong'*`prc';

qui replace EST       = `psh'           in    `k';
qui replace EST2      = (`psh'*`timp')  in    `k';
qui replace EST3      = `pscong'        in    `k';
qui replace EST4      = ((`psh'*`timp')/$p_y)/(`pscong'/$I_y)   in    `k';
local swpov= `swpov' +`psh'*`timp';


if (`kk'==1){;
return scalar th = EST4[`k'];
return scalar sm = `sim_elas' ;
};

if ( "`grlab`k''" == "") local grlab`k' = "Group_`kk'";
qui replace Group = "`k': `grlab`k''" in `k';
local ll=max(`ll',length("`k': `grlab`k''"));
};



local ll=max(`ll',10);




qui replace COMP = "Within"      in 2;
qui replace IMPC = `CW'/$p_y     in 2;


if (`alpha'==0){;
den _y_mug , hw(_w) xval(`pline');
local fz = `r(den)';
local CB=`fz'*(`mu'-`pline')*`prc';
};
if(`alpha'>0){;
ifg _y_mug , hw(_w) pl(`pline') al(`alpha') type(`type') ;
local p_y = `r(est)';
local al1=`alpha'-1;
ifg _y_mug  , hw(_w) pl(`pline') al(`al1') type(`type');
local p_y_1 = `r(est)';
local CB=`alpha'*(`p_y'+`p_y_1'*(`mu'-`pline')/`pline')*`prc';
};


qui agini _y_mug , rho(`rho') hw(_w) rank(`1');
local cons1=`r(gini)';

local consbgin=(`cons1'+`cons2');
qui replace COMP = "Between_AP1" in 3;
qui replace COMP = "Between_AP2" in 4;
qui replace COMP = "Between_AP3" in 5;
qui replace IMPC = `CB'/$p_y       in 3;
qui replace IMPC = `CB2'/$p_y      in 4;
qui replace IMPC = (`CB3'/$p_y)/(`consbgin'/$I_y)      in 5;

qui totwimp `1' _y_mug _y_phi , rho(`rho') hw(_w);
local totwi=`r(totwimp)'*`prc';

qui gen _sy4=`1'+(`prc'*(`1'-_y_mug))  ;

qui agini _sy4 , rho(`rho') hw(_w);
local twgini=(`r(gini)'-$I_y);



local j=$indica+1;
local k=$indica+2;
local l=$indica+3;

local consbgin=`consbgin'*`prc';

qui replace EST       = .   in    `j';
qui replace EST2      =  `swpov'                           in    `j';
qui replace EST3      = `totwi'                            in    `j';
qui replace EST4      = (`swpov'/$p_y)/((`totwi')/$I_y)   in    `j';

return scalar is2 = `swpov' ;
return scalar el2 = (`swpov'/$p_y)/((`totwi')/$I_y) ;

qui replace EST       = .           in    `k';
qui replace EST2      = (`CB3')     in    `k';
qui replace EST3      = `consbgin'    in    `k';
qui replace EST4      = (`CB3'/$p_y)/((`consbgin')/$I_y)   in    `k';


return scalar is3 = `CB3';
return scalar el3 = (`CB3'/$p_y)/((`consbgin')/$I_y);

ifg _sy3 , hw(_w) pl(`pline') al(`alpha') type(`type');
local p_sy3 = `r(est)';
local simp3 =(`p_sy3'-$p_y)/$p_y;


qui agini _sy3 , rho(`rho') hw(_w);
local tbgini=(`r(gini)'-$I_y)/$I_y;


local simgam=`simp3'/`tbgini';


return scalar sm2= `simgam' ;
return scalar tm2= EST4[`k'];


qui replace EST       = 1.0                     in    `l';
qui replace EST2      = $timp                   in    `l';
qui replace EST3      = $I_y*`prc'            in    `l';
qui replace EST4      = ($timp/$p_y)/`prc'    in    `l';


return scalar is1= $timp;
return scalar el1= ($timp/$p_y)/`prc';

if ("`dist'"!="no"){;
set more off;
tempname table;
	.`table'  = ._tab.new, col(2);
	.`table'.width |15|18|;
	.`table'.strcolor . . ;
	.`table'.numcolor yellow yellow    ;
	.`table'.numfmt %16.0g  %16.`dec'f   ;
      di _n as text "{col 3}Poverty and inequality indices";
	.`table'.sep, top;
	.`table'.titles "Indices  " "Estimate "     ;
	.`table'.sep, mid;
	local nalt = "ddd";
      .`table'.numcolor white yellow ;
      .`table'.row "FGT   " $p_y;
      .`table'.row "Gini  " $I_y;
     .`table'.sep,bot;

local j=$indica+1;
local k=$indica+2;
local l=$indica+3;


tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width |`ll'|16|16|16|16|;
	.`table'.strcolor . . yellow yellow yellow  ;
	.`table'.numcolor yellow yellow .  .  . ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f  %16.`dec'f  %16.`dec'f;
	 di _n as text "{col 3}Marginal Impact & Elasticities By Groups";
	.`table'.sep, top;
	.`table'.titles "Group  " "Population "     "Marginal       "  "Marginal      " "Elasticity  " ;
	.`table'.titles "       " "Share      "     "impact on ineq."  "impact on pov." "            ";
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/$indica{;
            .`table'.numcolor white yellow yellow yellow yellow ;
		.`table'.row Group[`i'] EST[`i']  EST3[`i']  EST2[`i']  EST4[`i'];
          
	};
  .`table'.sep,mid;
  .`table'.row "Within" EST[`j']  EST3[`j']  EST2[`j']  EST4[`j'];
  .`table'.sep,mid;
  .`table'.row "Between" EST[`k']  EST3[`k']  EST2[`k']  EST4[`k'];
  .`table'.sep,mid;
  .`table'.row "Population"   EST[`l']  EST3[`l']  EST2[`l']  EST4[`l'];
  .`table'.sep,bot;

};
return scalar  tot = IMP[1];
return scalar stot = `simp'/$p_y;
return scalar sb2  = `simp2'/$p_y;
return scalar sb3  = `simp3'/$p_y;
return scalar wit  = IMP[2];
return scalar bet  = IMP[3];
return scalar bet2 = IMP[4];
return scalar bet3 = IMP[5];


restore;
end;


