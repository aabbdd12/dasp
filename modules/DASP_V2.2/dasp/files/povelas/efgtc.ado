/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.2)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : egftc                                                       */
/*************************************************************************/

#delim ;
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


cap program drop agini;
program define agini, rclass;
syntax varlist(min=1 max=1) [, HWeight(varname) HSize(varname) HGroup(varname) NGroup(string) RAnk(varname)];
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
gen vr = sum(`fw')^2; gen p = vr  - vr[_n-1];
replace p = vr[1] in 1; replace p = p / vr[_N];
gen  xi = sum(p*`1');  local xi = xi[_N];
sum `1' [aw=`fw']; local mu = `r(mean)';
local gini = 1 - `xi'/`mu';
restore; 
};
return scalar gini = `gini';
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


capture program drop iccd;
program define iccd, rclass;
version 8.0;
syntax varlist [,   HWeight(varname) income(varname)  AL(real 1) PL(string) TYpe(string) ];
tokenize `varlist';
cap drop _hw;
gen _hw=`hweight';
local al = `al'-1;
cap drop _num ;
qui gen  _num=0;
qui sum `1' [aw=_hw];
local muk = `r(mean)';
if ("`type'"!="nor") qui replace _num = _hw*((`pl'-`income'))^`al'*`1'/`muk'       if (`pl'>`income');
if ("`type'"=="nor") qui replace _num = _hw*((`pl'-`income')/`pl')^`al'*`1'/`muk'  if (`pl'>`income');
qui sum _num;
local s1 = `r(sum)';
qui sum _hw ;
local s2 = `r(sum)';
return scalar icd=`s1'/`s2';
end;

capture program drop ifgk;
program define ifgk, rclass;
version 9.0;
syntax varlist [,  HWeight(varname)  AL(real 0) PL(string) type(string)];
tokenize `varlist';
cap drop _hhw;
gen      _hhw=`hweight';

qui sum _hhw;
local s3=`r(mean)';

qui sum `2' [aw=_hhw];
local muk=`r(mean)';
cap drop _num;
qui gen  _num=0;
local al1=`al'-1;

if ( "`type'"~="nor" )  qui replace _num = _hhw*(`pl'-`1')^`al1'*(`muk'-`2')               if (`pl'>`1');
if ( "`type'"=="nor" )  qui replace _num = _hhw*((`pl'-`1')/`pl')^`al1'*(`muk'-`2')/`pl'   if (`pl'>`1');

qui sum _num;
local s1=`r(mean)';
qui sum _hhw;
local s2=`r(mean)';
return scalar est   = `s1'/`s2';
return scalar psh   = `s2'/`s3';
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
tempvar s1 s2 ;
gen `s1' = sum( `fw'*exp(-0.5* ( ((`xval'-`x')/`h')^2  )  )    *`y');
gen `s2' = sum( `fw'*exp(-0.5* ( ((`xval'-`x')/`h')^2  )  ));
return scalar nes = `s1'[_N]/`s2'[_N];
end;



/***************************************/
/* Density function                    */
/***************************************/

cap program drop den;                    
program define den, rclass;             
syntax varlist(min=1 max=1) [, HWeight(string) HGroup(string) GNumber(integer 1) XVal(real 0) ] ; 
tokenize `varlist';
tempvar x s1 s2 fw;
gen `fw' = `hweight';

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
qui count;     
local h   = 0.9*`tmp'*_N^(-1.0/5.0);                                                                              
gen `s1' = sum( `fw' *exp(-0.5* ( ((`xval'-`x')/`h')^2  )  ));  
gen `s2' = sum( `fw' );
return scalar den = `s1'[_N]/( `h'* sqrt(2*c(pi)) * `s2'[_N] ); 
return local psh `psh'; 
end;


capture program drop efgtc;
program define efgtc, rclass;
version 9.0;
syntax varlist(min=1)[, TOT(varname) HSize(varname)  HGroup(varname) ALpha(real 0) PLine(real 0) prc(real 1) type(string) dist(string) INDex(string) STE(string) dec(int 6) CI(real 5)  APPR(string)];

local type="nor";
if ("`appr'"=="") local appr="ntr";
tokenize `varlist';
nargs    `varlist';
preserve;
qui svyset ;
local prc=`prc'/100;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
cap drop _ths;
qui gen _ths=1;
if ( "`hsize'"!="") qui replace _ths=`hsize';
cap drop _w;
qui gen  _w = _ths  ;
if ( "`hweight'"!="") qui replace _w=_ths*`hweight';
qui sum `tot' [aw=_w];
local mu=`r(mean)';
qui gen Source="";
qui gen EST=0;
qui gen EST2=0;
qui gen EST3=0;
qui gen EST4=0;



if ("`appr'"=="ntr") {;
local cons=0;
local conssc=0;
ifg `tot', hw(_w) pl(`pline') al(`alpha') type(`type');
global p_y=`r(est)';
local al1=`alpha'-1;
ifg `tot', hw(_w) pl(`pline') al(`al1') type(`type');
global p_y_1=`r(est)';

agini `tot', hw(_w);
global I_y=`r(gini)';

cap drop _wtots;
gen _wtots=0;

cap drop _btots;
gen _btots=0;

forvalues i=1/$indica {;
qui sum ``i'' [aw=_w];
local muk=`r(mean)';

qui replace Source ="`i': ``i''" in `i';
qui replace EST    =`muk'/`mu'   in `i';

cap drop _sk;
gen _sk =`tot'+`prc'*(``i''-`muk');
qui replace _wtots=_wtots+``i''+`prc'*(``i''-`muk');
qui replace _btots=_btots+``i''*(1+`prc'*(1-(`mu'/$indica)/`muk'));

if (`alpha'==0){;
ifg `tot', hw(_w) pl(`pline') al(`alpha') type(`type');
local p_y = `r(est)';
ifg _sk , hw(_w) pl(`pline') al(`alpha') type(`type');
local p_sk = `r(est)';
local simp =`p_sk'-$p_y;

npe _w `tot' ``i'' `pline';
local esk=`r(nes)';
den `tot' , hw(_w) xval(`pline');
local fz=`r(den)';
local cons=`cons' -`fz'*`esk'*(1-`mu'/(`muk'*$indica));
local timp=`fz'*(`muk'-`esk')*`prc';

if (`i'==1){;
return scalar th= `timp' ;
return scalar sm= `simp' ;
};


};

if (`alpha'>0){;
ifg `tot' , hw(_w) pl(`pline') al(`alpha') type(`type');
local p_y = `r(est)';
ifg _sk , hw(_w) pl(`pline') al(`alpha') type(`type');
local p_sk = `r(est)';
local simp =`p_sk'-`p_y';
iccd ``i'' , hw(_w) pl(`pline') al(`alpha') type(`type') income(`tot');
local cons=`cons'+`r(icd)';
ifgk `tot' ``i'' , hw(_w) pl(`pline') al(`alpha') type(`type');
local timp=`r(est)'*`prc';


};


agini ``i'' , hw(_w) rank(`tot');

local conssc=`conssc'+`r(gini)'/$indica;

local impi=EST[`i']*`r(gini)'*`prc';
qui replace EST2    =`timp'                             in `i';
qui replace EST3    =`impi'                             in `i';
qui replace EST4    =(`timp'/$p_y)/(`impi'/$I_y)        in `i';



};

local j=$indica+1;
local k=$indica+2;
local l=$indica+3;
qui sum `tot' [aw=_w]; local mu=`r(mean)';
if (`alpha'==0){;
den `tot' , hw(_w) xval(`pline');
local fz=`r(den)';
local timtot=`fz'*(`mu'-`pline')*`prc';
};
if (`alpha'>0){;
ifg `tot' , hw(_w) pl(`pline') al(`alpha') type(`type');
local p_y = `r(est)';
local al1=`alpha'-1;
ifg `tot' , hw(_w) pl(`pline') al(`al1') type(`type');
local p_y_1 = `r(est)';
local timtot=`alpha'*(`p_y'+`p_y_1'*(`mu'-`pline')/`pline')*`prc';
};


qui replace EST       = .     in    `j';
qui replace EST2      = `timtot'    in    `j';
qui replace EST3      = $I_y*`prc'  in    `j';
qui replace EST4      = (`timtot'/$p_y)/(`prc')     in    `j'; 







// between sources
if (`alpha'>0)  local BS = `alpha'*($p_y-$p_y_1+`mu'/`pline'*`cons'/($indica))*`prc';
if (`alpha'==0) local BS = `cons'*`prc';

ifg _btots , hw(_w) pl(`pline') al(`alpha') type(`type');
local p_sk = `r(est)';
local simbp=`p_sk'-$p_y;


agini _btots , hw(_w);
local i_sk = `r(gini)';
local simbi=`i_sk'-$I_y;
local thimp= ($I_y-`conssc')*`prc';






qui replace EST       = .           in    `k';
qui replace EST2      = `BS'        in    `k';
qui replace EST3      =   `thimp'            in    `k';
qui replace EST4      =(`BS'/$p_y)/((`thimp')/$I_y)          in    `k';

};

//===============

if ("`appr'"=="trn") {;

cap drop _wtots;
gen _wtots=0;

cap drop _btots;
gen _btots=0;

local cons=0;
local conssc=0;
local spwtimp=0;
local picrk=0;
local sphik=0;



ifg `tot', hw(_w) pl(`pline') al(`alpha') type(`type');
global p_y=`r(est)';
local al1=`alpha'-1;
ifg `tot', hw(_w) pl(`pline') al(`al1');
global p_y_1=`r(est)';

agini `tot',  hw(_w);
global I_y=`r(gini)';

forvalues i=1/$indica {;
cap drop _wk;
gen _wk=(``i''>0)*_w;
qui sum _wk; local su1=`r(sum)';
qui sum _w;  local su2=`r(sum)';
local phik=`su1'/`su2';
local sphik=`sphik'+`phik';
};



forvalues i=1/$indica {;
qui sum ``i'' [aw=_w];
local muk=`r(mean)';
cap drop _wk;
gen _wk=(``i''>0)*_w;
qui replace Source ="`i': ``i''" in `i';
qui replace EST    =`muk'/`mu'   in `i';

qui sum ``i'' [aw=_wk];
local mk=`r(mean)';


cap drop _sk;
gen _sk =`tot'+`prc'*(``i''-`mk')*(``i''>0);
qui replace _wtots=_wtots+``i''+`prc'*(``i''-`mk')*(``i''>0);
qui replace _btots=_btots+``i''*(1+`prc'*(1-(`mu'/`sphik')/`mk'))*(``i''>0);



qui sum _wk; local su1=`r(sum)';
qui sum _w;  local su2=`r(sum)';
local phik=`su1'/`su2';



if (`alpha'==0){;
ifg `tot', hw(_w) pl(`pline') al(`alpha') type(`type');
local p_y = `r(est)';
ifg _sk , hw(_w) pl(`pline') al(`alpha') type(`type');
local p_sk = `r(est)';
local simp =`p_sk'-$p_y;

npe _w `tot' ``i'' `pline';
local esk=`r(nes)';
cap drop _wp;
qui gen _wp=(``i''>0);

npe _w `tot' _wp  `pline';
local esphi=`r(nes)';



den `tot' , hw(_w) xval(`pline');
local fz=`r(den)';

local timp=`fz'*(`mk'*`esphi'-`esk')*`prc';
local spwtimp=`spwtimp'+`timp';



local cons=`cons'-`fz'*`esk'*(1-(`mu'/`sphik')/(`mk'));
};

if (`alpha'>0){;
ifg `tot' , hw(_w) pl(`pline') al(`alpha') type(`type');
local p_y = `r(est)';
ifg _sk , hw(_w) pl(`pline') al(`alpha') type(`type');
local p_sk = `r(est)';
local simp =`p_sk'-$p_y;
iccd ``i'' , hw(_w) pl(`pline') al(`alpha') type(`type') income(`tot');
local cons=`cons'+`phik'*`r(icd)';
local iccd=`r(icd)';
local al1=`alpha'-1;
ifg `tot', hw(_wk) pl(`pline') al(`al1') type(`type') ;
local timp=(`alpha'*`muk'*(`r(est)'-`iccd')/`pline')*`prc';
local spwtimp=`spwtimp'+`timp';



};

agini ``i'' ,  hw(_w) rank(`tot');

local conssc = `conssc' + `phik' *  `r(gini)' / `sphik' ;


qui replace EST2    =  `timp'   in `i';
cap drop _phip;
qui gen _phip=(``i''>0);
agini ``i'' , hw(_w) rank(`tot');
local tm1=`r(gini)';

agini _phip ,  hw(_w) rank(`tot');
local tm2=`r(gini)';
local picrk =`picrk'+`muk'/`mu' *`tm2';
local timki=(`muk'/`mu' * ( `tm1' - `tm2' ))*`prc';
agini _sk , hw(_w);
local simki=`r(gini)'-$I_y;
 

qui replace EST3    =  `timki'   in `i';

qui replace EST4    =  (`timp'/$p_y)/(`timki'/$I_y)   in `i';


if (`i'==1) {;

local  simelas= ( `simp' / $p_y)/( `simki' / $I_y );

};


};




local j=$indica+1;
local k=$indica+2;




agini _wtots ,  hw(_w);
local i_sk = `r(gini)';
local simbi=`i_sk'-$I_y;


local thimp= ($I_y-`picrk')*`prc';


qui replace EST       = .     in          `j';
qui replace EST2      = `spwtimp'    in           `j';
qui replace EST3      = `thimp'  in  `j';
qui replace EST4      = (`spwtimp'/$p_y)/(`thimp'/$I_y)        in          `j'; 


qui replace _btots=_btots;
ifg _wtots , hw(_w) pl(`pline') al(`alpha') type(`type');
local p_sk = `r(est)';
local simwp=`p_sk'-$p_y;



/* between sources*/
if (`alpha'> 0)  local BS = `alpha'*($p_y-$p_y_1+(`mu'/`pline')*(`cons'/`sphik'))*`prc';
if (`alpha'==0)  local BS = `cons'*`prc';



ifg _btots , hw(_w) pl(`pline') al(`alpha') type(`type');
local p_sk = `r(est)';
local simbp=`p_sk'-$p_y;


/*
return scalar th= `simbp' ;
return scalar sm= `BS' ;
*/

agini _btots , hw(_w);
local i_sk = `r(gini)';
local simbi=`i_sk'-$I_y;
local thimp= ($I_y-`conssc')*`prc';




qui replace EST       =  .                                   in    `k';
qui replace EST2      = `BS'                                 in    `k';
qui replace EST3      =  `thimp'                             in    `k';
qui replace EST4      =  (`BS'/$p_y)/(`thimp'/$I_y)          in    `k';


local simbelas=(`simbp'/$p_y)/(`simbi'/$I_y);

};


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
tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width |24|16|16||16|16|;
	.`table'.strcolor . . yellow yellow yellow ;
	.`table'.numcolor yellow yellow . . .  ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f  %16.`dec'f  ;
       di _n as text "{col 3}Marginal impacts and elasticities of poverty with respect to within/between";
	 di    as text "{col 3}inequality in income components";
      .`table'.sep, top;
	.`table'.titles "Source  " "Income "     "Impact on  "  "Impact on  "  "Elasticity  " ;
	.`table'.titles "        " " Share "     "Inequality "  "Poverty    "  "            " ;
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/$indica{;
            .`table'.numcolor white yellow yellow yellow yellow  ; 
		.`table'.row Source[`i'] EST[`i']  EST3[`i']  EST2[`i']  EST4[`i'];
	};
  .`table'.sep,mid;
  .`table'.row "Within " EST[`j']  EST3[`j']  EST2[`j']  EST4[`j'];
  .`table'.sep,mid;
  .`table'.row "Between" EST[`k']  EST3[`k']  EST2[`k']  EST4[`k'];
  .`table'.sep,bot;
};


restore;
end;




