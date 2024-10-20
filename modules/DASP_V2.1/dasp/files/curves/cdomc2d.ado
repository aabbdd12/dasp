/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.1)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universite Laval , Quebec, Canada                                     */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : cdomc2d                                                     */
/*************************************************************************/




#delim ;



capture program drop cdomc2dc2;
program define cdomc2dc2, rclass;
version 9.2;
syntax varlist(min=1)[,  HWEIGHT(string) HSize(string) HGroup(varname) NGroup(int 1) prc(real 100) component1(string) component2(string)  ALpha(real 1) PLINE(real 10000)
cnor(string) est(string)
];
preserve;
tokenize `varlist';
tempvar hs1 hsr1 hsy1   hs2 hsr2 hsy2;
if ("`hsize'"~="") {;
gen `hs1' =`hsize';
gen `hsr1'=`hsize';

gen `hs2' =`hsize';
gen `hsr2'=`hsize';
};

if ("`hsize'"=="") {;
gen `hs1' =1;
gen `hsr1'=1;

gen `hs2' =1;
gen `hsr2'=1;
};

local prc = `prc'/100;
if ("`est'"=="rat" )     local prc=1;

if ("`hgroup'"~="")                            qui replace `hs1'  =`hs1'*(`hgroup'==`ngroup');
if ("`cnor'" ~= "yes" & "`component1'"~="")    qui replace `hs1'  =`hs1'*(`component1'!=0);

if ("`hgroup'"~="")                            qui replace `hs2'  =`hs2'*(`hgroup'==`ngroup');
if ("`cnor'" ~= "yes" & "`component2'"~="")    qui replace `hs2'  =`hs2'*(`component2'!=0);

if ("`hweight'"=="")   {;
tempvar hweight;
gen `hweight' = 1;
};


local al1 = `alpha' - 1;

gen `hsy1'=`hs1'*`component1';

gen `hsy2'=`hs2'*`component2';

cap drop if `1'>=.;

cap drop `num1' `numi1';
tempvar   num1 denum1 numi1;
qui gen    `num1' = 0;
qui gen    `numi1'= 0;

cap drop `num2' `numi2';
tempvar   num2 denum2 numi2;
qui gen    `num2' = 0;
qui gen    `numi2'= 0;

				    
if (`alpha' == 0 )                        qui replace    `num1' = `hs1'*(`pline'> `1');
if (`alpha' ~= 0 & `pline' ~=0)           qui replace    `num1' = `hs1'*((`pline'-`1')/`pline')^`alpha'  if (`pline'>`1');

if ("`cnor'" ~= "yes") {;

if (`alpha' > 0) {;
if (`al1'   == 0 & `pline' ~=0)              qui replace    `numi1' = `alpha'/`pline'*`hs1'*(`pline'> `1');
if (`alpha' ~= 0 & `pline' ~=0)            qui replace    `numi1' = `alpha'/`pline'*`hs1'*((`pline'-`1')/`pline')^`al1'*`component1'  if (`pline'>`1');
							 
};
};

if ("`cnor'" == "yes") {;
if (`alpha' > 0) {;
if (`al1' == 0 & `pline' ~=0)             qui replace    `numi1' = `alpha'/`pline'*`hs1'*(`pline'> `1');
if (`al1' ~= 0 & `pline' ~=0 )            qui replace    `numi1' = `alpha'/`pline'*`hs1'*((`pline'-`1')/`pline')^`al1'  if (`pline'>`1');
						      qui replace    `numi1' = `numi1'*`component1';
};

};

if (`alpha' == 0) {;
tempvar fw1;
qui gen `fw1' =`hs1'*`hweight';
qui su `1' [aw=`fw1'], detail;           
local tmp = (`r(p75)'-`r(p25)')/1.34;                          
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
local h   = 0.9*`tmp'*_N^(-1.0/5.0);  
qui replace `numi1' =  `hs1' *exp(-0.5* ( ((`pline'-`1')/`h')^2  )  )/( `h'* sqrt(2*c(pi)));  
qui replace `numi1' = `numi1'*`component1';
};



				    
if (`alpha' == 0 )                        qui replace    `num2' = `hs2'*(`pline'> `1');
if (`alpha' ~= 0 & `pline' ~=0)           qui replace    `num2' = `hs2'*((`pline'-`1')/`pline')^`alpha'  if (`pline'>`1');

if ("`cnor'" ~= "yes") {;

if (`alpha' > 0) {;
if (`al1'   == 0 & `pline' ~=0)              qui replace    `numi2' = `alpha'/`pline'*`hs2'*(`pline'> `1');
if (`alpha' ~= 0 & `pline' ~=0)              qui replace    `numi2' = `alpha'/`pline'*`hs2'*((`pline'-`1')/`pline')^`al1'*`component2'  if (`pline'>`1');
							 
};
};

if ("`cnor'" == "yes") {;
if (`alpha' > 0) {;
if (`al1' == 0 & `pline' ~=0)             qui replace    `numi2' = `alpha'/`pline'*`hs2'*(`pline'> `1');
if (`al1' ~= 0 & `pline' ~=0 )            qui replace    `numi2' = `alpha'/`pline'*`hs2'*((`pline'-`1')/`pline')^`al1'  if (`pline'>`1');
						      qui replace    `numi2' = `numi2'*`component2';
};

};

if (`alpha' == 0) {;
tempvar fw2;
qui gen `fw2' =`hs2'*`hweight';
qui su `1' [aw=`fw2'], detail;           
local tmp = (`r(p75)'-`r(p25)')/1.34;                          
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
local h   = 0.9*`tmp'*_N^(-1.0/5.0);  
qui replace `numi2' =  `hs2' *exp(-0.5* ( ((`pline'-`1')/`h')^2  )  )/( `h'* sqrt(2*c(pi)));  
qui replace `numi2' = `numi2'*`component2';
};


qui sum `numi1'; local snumi1    = `r(sum)';
qui sum `hs1';   local shs1      = `r(sum)';
qui sum `hsr1';  local shsr1     = `r(sum)';
qui sum `hsy1';  local shsy1     = `r(sum)';

qui sum `numi2'; local snumi2    = `r(sum)';
qui sum `hs2';   local shs2      = `r(sum)';
qui sum `hsr2';  local shsr2     = `r(sum)';
qui sum `hsy2';  local shsy2     = `r(sum)';



if ("`cnor'"=="no"){;

qui svy: mean `numi1' `hsr1' `numi2' `hsr2' ; 
if ("`est'"=="dif") qui nlcom _b[`numi2']/_b[`hsr2']-_b[`numi1']/_b[`hsr1'], iterate(50000) ;
if ("`est'"=="rat") qui nlcom (_b[`numi2']/_b[`hsr2']) / (_b[`numi1']/_b[`hsr1']), iterate(50000) ;

cap drop matrix _aa;
matrix _aa=r(b);
local est3 = el(_aa,1,1);
return scalar impp    = `prc'*el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=r(V);
local sest3 = el(_vv,1,1)^0.5;
return scalar simpp  = `prc'*`sest3';


};


if ("`cnor'"=="yes"){;

qui svy: mean `numi1' `hsy1' `numi2' `hsy2' ; 
if ("`est'"=="dif") qui nlcom _b[`numi2']/_b[`hsy2']   -  _b[`numi1']/_b[`hsy1'], iterate(50000) ;
if ("`est'"=="rat") qui nlcom (_b[`numi2']/_b[`hsy2']) / (_b[`numi1']/_b[`hsy1']), iterate(50000) ;
cap drop matrix _aa;
matrix _aa=r(b);
local est3 = el(_aa,1,1);
return scalar impp    = `prc'*el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=r(V);
local sest3 = `prc'*el(_vv,1,1)^0.5;
return scalar simpp  = `sest3';

};



restore;
end;



capture program drop gcdomc2dc2;
program define gcdomc2dc2, rclass;
version 9.2;
syntax varlist(min=1)[,  HWEIGHT(string) HSize(string) HGroup(varname) NGroup(int 1)
 prc(real 100)  component1(string) component2(string) ALpha(real 1) 
MIN(real 0) MAX(real 10000)
cnor(string)
est(string)
type(string)
dci(string)
level(real 95)
conf(string)
label(string)
];
preserve;
tokenize `varlist';
tempvar hs1 hsr1 hsy1   hs2 hsr2 hsy2;
if ("`hsize'"~="") {;
gen `hs1' =`hsize';
gen `hsr1'=`hsize';

gen `hs2' =`hsize';
gen `hsr2'=`hsize';
};

if ("`hsize'"=="") {;
gen `hs1' =1;
gen `hsr1'=1;

gen `hs2' =1;
gen `hsr2'=1;
};

local prc = `prc'/100;
if ("`est'"=="rat" )     local prc=1;

if ("`hgroup'"~="")                            qui replace `hs1'  =`hs1'*(`hgroup'==`ngroup');
if ("`cnor'" ~= "yes" & "`component1'"~="")    qui replace `hs1'  =`hs1'*(`component1'!=0);

if ("`hgroup'"~="")                            qui replace `hs2'  =`hs2'*(`hgroup'==`ngroup');
if ("`cnor'" ~= "yes" & "`component2'"~="")    qui replace `hs2'  =`hs2'*(`component2'!=0);

if ("`hweight'"=="")   {;
tempvar hweight;
gen `hweight' = 1;
};


local al1 = `alpha' - 1;

gen `hsy1'=`hs1'*`component1';

gen `hsy2'=`hs2'*`component2';

cap drop if `1'>=.;

cap drop `num1' `numi1';
tempvar   num1 denum1 numi1;
qui gen    `num1' = 0;
qui gen    `numi1'= 0;

cap drop `num2' `numi2';
tempvar   num2 denum2 numi2;
qui gen    `num2' = 0;
qui gen    `numi2'= 0;




if ("`dci'"=="no") {;
qui replace `hs1' = `hs1'*`hweight';
qui replace `hsr1'=`hsr1'*`hweight';
qui replace `hsy1'=`hsy1'*`hweight';

qui replace `hs2' = `hs2'*`hweight';
qui replace `hsr2'=`hsr2'*`hweight';
qui replace `hsy2'=`hsy2'*`hweight';
};



tempvar ra vimpp _limpp _uimpp;

gen  `vimpp'=0;
gen `_limpp'=0;
gen `_uimpp'=0;


if ("`dci'"=="yes"){;
qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');
};


gen `ra'=0;
local pas = (`max'-`min')/100;
if (_N<101) qui set obs 101;

dis "Estimation for: `label'";

forvalues j=1/101 {;

qui replace `ra'=`min'+(`j'-1)*`pas' in `j';
local pline = `min'+(`j'-1)*`pas';

				    
if (`alpha' == 0 )                        qui replace    `num1' = `hs1'*(`pline'> `1');
if (`alpha' ~= 0 & `pline' ~=0)           qui replace    `num1' = `hs1'*((`pline'-`1')/`pline')^`alpha'  if (`pline'>`1');

if ("`cnor'" ~= "yes") {;
if (`alpha' > 0) {;
if (`al1'   == 0 & `pline' ~=0)              qui replace    `numi1' = `alpha'/`pline'*`hs1'*(`pline'> `1');
if (`alpha' ~= 0 & `pline' ~=0)             qui replace    `numi1' = `alpha'/`pline'*`hs1'*((`pline'-`1')/`pline')^`al1'*`component1'  if (`pline'>`1');
							 
};

};

if ("`cnor'" == "yes") {;
if (`alpha' > 0) {;
if (`al1' == 0 & `pline' ~=0)             qui replace    `numi1' = `alpha'/`pline'*`hs1'*(`pline'> `1');
if (`al1' ~= 0 & `pline' ~=0 )            qui replace    `numi1' = `alpha'/`pline'*`hs1'*((`pline'-`1')/`pline')^`al1'  if (`pline'>`1');
						                  qui replace    `numi1' = `numi1'*`component1';
};

};

if (`alpha' == 0) {;
tempvar fw1;
qui gen `fw1' =`hs1'*`hweight';
qui su `1' [aw=`fw1'], detail;           
local tmp = (`r(p75)'-`r(p25)')/1.34;                          
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
local h   = 0.9*`tmp'*_N^(-1.0/5.0);  
qui replace `numi1' =  `hs1' *exp(-0.5* ( ((`pline'-`1')/`h')^2  )  )/( `h'* sqrt(2*c(pi)));  
qui replace `numi1' = `numi1'*`component1';
};



				    
if (`alpha' == 0 )                        qui replace    `num2' = `hs2'*(`pline'> `1');
if (`alpha' ~= 0 & `pline' ~=0)           qui replace    `num2' = `hs2'*((`pline'-`1')/`pline')^`alpha'  if (`pline'>`1');

if ("`cnor'" ~= "yes") {;

if (`alpha' > 0) {;
if (`al1'   == 0 & `pline' ~=0)              qui replace    `numi2' = `alpha'/`pline'*`hs2'*(`pline'> `1');
if (`alpha' ~= 0 & `pline' ~=0)              qui replace    `numi2' = `alpha'/`pline'*`hs2'*((`pline'-`1')/`pline')^`al1'*`component2'  if (`pline'>`1');
							 
};
};

if ("`cnor'" == "yes") {;
if (`alpha' > 0) {;
if (`al1' == 0 & `pline' ~=0)             qui replace    `numi2' = `alpha'/`pline'*`hs2'*(`pline'> `1');
if (`al1' ~= 0 & `pline' ~=0 )            qui replace    `numi2' = `alpha'/`pline'*`hs2'*((`pline'-`1')/`pline')^`al1'  if (`pline'>`1');
						      qui replace    `numi2' = `numi2'*`component2';
};

};


if (`alpha' == 0) {;
tempvar fw2;
qui gen `fw2' =`hs2'*`hweight';
qui su `1' [aw=`fw2'], detail;           
local tmp = (`r(p75)'-`r(p25)')/1.34;                          
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
local h   = 0.9*`tmp'*_N^(-1.0/5.0);  
qui replace `numi2' =  `hs2' *exp(-0.5* ( ((`pline'-`1')/`h')^2  )  )/( `h'* sqrt(2*c(pi)));  
qui replace `numi2' = `numi2'*`component2';
};


qui sum `numi1'; local snumi1    = `r(sum)';
qui sum `hs1';   local shs1      = `r(sum)';
qui sum `hsr1';  local shsr1     = `r(sum)';
qui sum `hsy1';  local shsy1     = `r(sum)';

qui sum `numi2'; local snumi2    = `r(sum)';
qui sum `hs2';   local shs2      = `r(sum)';
qui sum `hsr2';  local shsr2     = `r(sum)';
qui sum `hsy2';  local shsy2     = `r(sum)';



if ("`cnor'"=="no"){;

if ("`dci'"=="no") {;
if ("`est'"=="dif")  local impp = `snumi2'/`shsr2' - `snumi1'/`shsr1' ; 
if ("`est'"=="rat")  local impp = `snumi2'/`shsr2' / `snumi1'/`shsr1' ;
};

if ("`dci'"=="yes"){;
qui svy: mean `numi1' `hsr1' `numi2' `hsr2' ; 
if ("`est'"=="dif") qui nlcom _b[`numi2']/_b[`hsr2']   -  _b[`numi1']/_b[`hsr1'], iterate(50000) ;
if ("`est'"=="rat") qui nlcom (_b[`numi2']/_b[`hsr2']) / (_b[`numi1']/_b[`hsr1']), iterate(50000) ;
matrix _aa=r(b);
local impp = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=r(V);
local simpp = el(_vv,1,1)^0.5;
local limpp   = `impp' - `tt'*`simpp';
local uimpp   = `impp' + `tt'*`simpp';

};

};



if ("`cnor'"=="yes"){;

if ("`dci'"=="no"){;
if ("`est'"=="dif")  local impp = `snumi2'/`shsy2' - `snumi1'/`shsy1' ; 
if ("`est'"=="rat")  local impp = `snumi2'/`shsy2' / `snumi1'/`shsy1' ;
};

if ("`dci'"=="yes"){;
qui svy: mean `numi1' `hsy1' `numi2' `hsy2' ; 
if ("`est'"=="dif") qui nlcom _b[`numi2']/_b[`hsy2']   -  _b[`numi1']/_b[`hsy1'], iterate(50000) ;
if ("`est'"=="rat") qui nlcom (_b[`numi2']/_b[`hsy2']) / (_b[`numi1']/_b[`hsy1']), iterate(50000) ;
matrix _aa=r(b);
local impp = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=r(V);
local simpp = el(_vv,1,1)^0.5;
local limpp   = `impp' - `tt'*`simpp';
local uimpp   = `impp' + `tt'*`simpp';
};

};


if ("`dci'"=="no") {;
qui replace `vimpp'=`prc'*`impp' in `j';
};

if ("`dci'"=="yes") {;
 qui replace `_limpp'=`prc'*`limpp' in `j';
 qui replace `_uimpp'=`prc'*`uimpp' in `j';
};


if (`j'!=101)  dis "." ,  _continue;
if (`j'/10==round(`j'/10)) dis " "  %4.2f `j' " %";

};
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
if ("`dci'"=="no")  mkmat `vimpp', matrix (_xx);
if ("`dci'"=="yes") mkmat `_limpp' `_uimpp', matrix (_xx);
restore;
end;




capture program drop cdomc2d;
program define cdomc2d, rclass;
version 9.2;
syntax varlist(min=2)[,  
HSize(varname)  HGroup(varname)  inc(varname)  ORDER(real 1) PLINE(real 10000)
PRC(real 1)
cnor(string) est(string)
DEC(int 9)
DSTE(int 1)
  LRES(int 0) SRES(string) DCI(string) LEVEL(real 95)
CONF(string) DIF(string) MIN(string) MAX(string) DGRA(int 1) SGRA(string) EGRA(string) *];

_get_gropts , graphopts(`options') ;
	local options `"`s(graphopts)'"';

local alpha = `order'-1;

if ("`cnor'"=="")     local cnor="no";
if ("`dci'"=="")      local dci="no";
if ("`conf'"=="")     local conf="ts";

if ("`prc'"=="" )     local prc=1;
if ("`est'"=="")     local est="dif";
	
if ("`hgroup'"!="") {;
preserve;
tokenize `varlist';
tempvar com1 com2;
gen  `com1'=`1';
gen  `com2'=`2';
capture {;
local lvgroup:value label `hgroup';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , replace;
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
tempvar com1 com2;
gen  `com1'=`1';
gen  `com2'=`2';
_nargs    `varlist';
global indica=1;
preserve;
};


qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 



local hweight=""; 
cap qui svy: total `1'; 

cap if (`e(wvar)') local hweight=`"`e(wvar)'"';
if ("`e(wvar)'"~="`hweight'") dis as txt in blue " Warning: sampling weight is initialized but not found.";


local dgr = "no";

if ("`max'" ~= "" ) local dgr = "yes";




if ("`dgr'" == "no" ){;
tempvar Variable EST EST1 EST2 EST3 EST4 STE STE1 STE2 STE3 STE4;

qui gen `Variable'="";
qui gen `EST'=0;
qui gen `STE'=0;

qui gen `EST2'=0;
qui gen `STE2'=0;

qui gen `EST3'=0;
qui gen `STE3'=0;


local ll=16;

forvalues k = 1/$indica {;
local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;
if ("`hgroup'"~="") {;
local kk = gn1[`k'];
local  label`f'  : label (`hgroup') `kk';
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";
cdomc2dc2 `inc', hweight(`hweight')  hsize(`hsize')  hgroup(`hgroup') ngroup(`kk') component1(`com1') component2(`com2') prc(`prc')  
 alpha(`alpha') pline(`pline') cnor(`cnor') est(`est');;


qui replace `EST3'      = `r(impp)' in `k1';
qui replace `EST3'      = `r(simpp)' in `k2';

qui replace `Variable' = "`label`f''" in `k1';
local ll=max(`ll',length("`label`f''"));
};

if ("`hgroup'"=="") {;
qui replace `Variable' = "Population" in `k1';
cdomc2dc2 `inc', hweight(`hweight') 
hsize(`hsize')  component1(`com1') component2(`com2') prc(`prc')   alpha(`alpha') pline(`pline') cnor(`cnor')  est(`est') ;


local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;

qui replace `EST3'      = `r(impp)'  in `k1';
qui replace `EST3'      = `r(simpp)' in `k2';

};

};

local kk1 = `k2'+1;
local kk2 = `k2'+2;


/*****RESULTS*****/
                     local targetg = "Whole population";


  tempname table;
	.`table'  = ._tab.new, col(2);
	.`table'.width |16 |16|;
	                         di as text     "{col 4}Normalized by cost :  `cnor'";
       if ("`hsize'"!="")   di as text     "{col 4}Household size     :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 4}Sampling weight    :  `hweight'";
                            if ("`hgroup'"!="") di as text      "{col 4}Group variable     :  `hgroup'";
                            di as text     "{col 4}Parameter alpha    : "  %5.2f `alpha'       ;
     			          di as text       "{col 4}Poverty line       : "  %5.2f `pline'       ;
						  
	.`table'.strcolor . .  ;
	.`table'.numcolor yellow yellow  ;
	.`table'.numfmt %16.`dec'f  %16.`dec'f  ;
         
	.`table'.sep, top;
	.`table'.titles  "Group    "   " Difference "   ;
	.`table'.numcolor yellow yellow  ;
	.`table'.sep,mid;
     forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor white  yellow  ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green  ;
		  if (`dste'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i']  `EST3'[`i'];
              	        
                };

.`table'.sep,bot;





}; //DGRAPH NO




if ("`dgr'" ~= "no" ){;
set more off;
dis "ESTIMATION IN PROGRESS";

tempvar fw;
local _cory  = "";
local _coryl  = "";
local _coryu  = "";
local mcmd   = "";
local label  = "";
quietly{;
local tits="";
if ($indica>1) local tits="s";
gen `fw'=1;
local tit1="Consumption Dominance"; 
local tit2="CD"; 
local tit3="";
local tit4="";

if ("`type'"=="nor") {;
local tit3="";
local tit4="Normalised ";
};

local ft = "Difference";
if ("`est'"=="rat") local ft = "Ratio";
local ftitle = "`ft' Between C. Dominance Curve`tits' (order = `order')";

local ytitle = "`ft'";
if ("`hsize'"  ~="")      replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")      replace `fw'=`fw'*`hweight';
};

qui count;
qui sum `1';
if ("`min'"  =="")      local min =`r(min)';
if ("`max'"  =="")      local max =`r(max)';

if (r(N)<101) qui set obs 101;


forvalues k = 1/$indica {;

                                     local _cory  = "`_cory'" + " _cory`k'";
if ("`dci'"=="yes" & "`conf'"=="ts") local mcmd  = "`mcmd'" + "(rarea  _coryl`k'  _coryu`k' _corx) ";
local f=`k';
if ("`dif'"=="c1")  local f =`k'-1;


if ("`hgroup'"!="")      {;
local kk = gn1[`k'];
local  label`f'  : label (`hgroup') `kk';
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";

if ( "`label1'" == "")   local labelg1    = "``1''";
if ( "`label`f''" == "") local label`f'   = "``kk''";
local titd="Impact on FGT";
if ("`dif'"=="c1") local label`f'= "`titd'_`label`f'' - `titd'_`labelg1'";

gcdomc2dc2 `inc', hweight(`hweight') hgroup(`hgroup') ngroup(`kk') prc(`prc') 
hsize(`hsize') component1(`com1') component2(`com2') alpha(`alpha') min(`min') max(`max')
cnor(`cnor') dci(`dci') level(`level') conf(`conf') label(`label`f'') est(`est');

};



if ("`hgroup'"=="") {;
if ( "`label1'" == "")   local labelg1    = "`1'";
if ( "`label`f''" == "") local label`f'   = "``k''";
local titd="Impact on FGT";
if ("`dif'"=="c1") local label`f'= "`titd'_`label`f'' - `titd'_`labelg1'";

gcdomc2dc2 `inc', hweight(`hweight') component1(`com1') component2(`com2') prc(`prc') 
hsize(`hsize')  alpha(`alpha') min(`min') max(`max')
cnor(`cnor') dci(`dci') level(`level') conf(`conf') est(`est') label(Population);


};


svmat float _xx;
cap matrix drop _xx;
if ("`dci'"=="no") rename _xx1 _cory`k';

if ("`dci'"=="yes"){;

if ("`conf'"=="ts") {;
 rename _xx1 _coryl`k';
 rename _xx2 _coryu`k';
};

if ("`conf'"=="lb"){;
rename _xx1 _cory`k';
};

if ("`conf'"=="ub"){;
 rename _xx2 _cory`k';
};

};

cap drop _xx*;
};


qui keep in 1/101;
gen _corx=0;
local pas = (`max'-`min')/100;
local m5 = (`max'-`min')/5;
forvalues j=1/101 {;
qui replace _corx=`min'+(`j'-1)*`pas' in `j';
};

                      local typeb = "Lower";
if ("`conf'"=="ub")   local typeb = "Upper";

if ("`dif'"=="c1") {;
gen _dct=_cory1;
forvalues k = 1/$indica {;
qui replace _cory`k'=_cory`k'-_dct;
};
local label1  ="Null horizontal line";
};

if( `lres' == 1) {;
set more off;
list _corx _cory*;
};
quietly {;

if (`dgra'!=0) {; 
dis "END: WAIT FOR THE GRAPH...";

if ("`dci'"=="no"){;
line `_cory'  _corx, 
legend(
label(1 `label1')
label(2 `label2')
label(3 `label3')
label(4 `label4')
label(5 `label5')
label(6 `label6')
label(7 `label7')
label(8 `label8')
label(9 `label9')
label(10 `label10')
label(11 `label11')
label(12 `label12')
)
title(`ftitle')
ytitle(`ytitle')
xtitle(Poverty line (z)) 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
plotregion(margin(zero))
graphregion(margin(medlarge))
legend(size(medsmall))
`options'
;

};


if ("`dci'"=="yes"){;

if ("`conf'"=="ts"){;
twoway `mcmd'
, 
legend(
label(1 `label1')
label(2 `label2')
label(3 `label3')
label(4 `label4')
label(5 `label5')
label(6 `label6')
label(7 `label7')
label(8 `label8')
label(9 `label9')
label(10 `label10')
label(11 `label11')
label(12 `label12')
)
title(`ftitle')
subtitle("Confidence interval(`level'%)")
ytitle(`ytitle')
xtitle(Poverty line (z)) 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
plotregion(margin(zero))
graphregion(margin(medlarge))
legend(size(medsmall))
`options'
;
};

if ("`conf'"~="ts") {;
line `_cory'  _corx, 
legend(
label(1 `label1')
label(2 `label2')
label(3 `label3')
label(4 `label4')
label(5 `label5')
label(6 `label6')
label(7 `label7')
label(8 `label8')
label(9 `label9')
label(10 `label10')
label(11 `label11')
label(12 `label12')
)
title(`ftitle')
subtitle("`typeb' bound(`level'%)")
ytitle(`ytitle')
xtitle(Poverty line (z)) 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
plotregion(margin(zero))
graphregion(margin(medlarge))
legend(size(medsmall))
`options'
;
};

};


};
cap matrix drop _xx;
if( "`sres'" ~= "") {;
keep _corx _cory*;
save `"`sres'"', replace;
};

if( "`sgra'" ~= "") {;
graph save `"`sgra'"', replace;
};

if( "`egra'" ~= "") {;
graph export `"`egra'"', replace;
};
};

}; // GRAPH YES




end;



