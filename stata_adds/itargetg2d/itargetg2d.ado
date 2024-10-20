/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.1)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universite Laval , Quebec, Canada                                     */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : itargetg2d                                                  */
/*************************************************************************/

#delimit; 
set more off;
capture program drop itarg2d_test;
program define itarg2d_test, rclass sortpreserve;
version 9.2;
syntax varlist(min=3)[,  NG(int 1) mname(string) slev(real 0.05)];
preserve;
tokenize `varlist';
qui keep in 1/`ng';
tempvar rank;
qui egen float `rank' = rank(`1');
qui sort `rank' , stable;  
qui gen  resu = "";
global resas="";
forvalues i=1/`ng' {;
qui replace resu = resu+string(`3'[`i'])+"<-" in `i';
local i1=`i'+1;
forvalues j=`i1'/`ng' {;

local dif = `1'[`i'] - `1'[`j'];

local ste =    el(`mname',`i',`j');
local ste2 = (`2'[`i']^2 + `2'[`j']^2)^0.5;
        local z  = (`dif')/`ste';
        local p = 1-2*(normal(abs(`z'))-0.5);
                if `z'>0 {;
                local pr = normal(abs(`z'));
                local pl =  1 - `pr';
                };
                else {;
                local pl = normal(abs(`z'));
                local pr =  1 - `pl';
                };
if (`pr' < `slev') qui replace resu = resu[`i']+":"+string(`3'[`j']) in `i';

};
local tmp = resu[`i'];
global resas  $resas `tmp' ;
};


restore;

end;


capture program drop itargetg2d2;
program define itargetg2d2, rclass sortpreserve;
version 9.2;
syntax varlist(min=2)[,  HWEIGHT(string) HSize(string) HGroup(string) NGroup(int 1) ALpha(real 0)  PLINE1(real 10000) PLINE2(real 10000)
IMPON(string)
cnor(string)
type(string)
ampl(real 1)
SO(real 0)
POS(int 0)];
/*preserve;*/
tokenize `varlist';
tempvar hs hsr hsy;
if ("`hsize'"~="") {;
gen `hs' =`hsize';
gen `hsr'=`hsize';
};

if ("`hsize'"=="") {;
gen `hs' =1;
gen `hsr'=1;
};

local al1 = `alpha' - 1;

if ("`hgroup'"~="")    qui replace `hs'  =`hs'*(`hgroup'==`ngroup');

if ("`hweight'"=="")   {;
tempvar hweight;
gen `hweight' = 1;
};

gen `hsy'=`hs'*`1';

cap drop if `1'>=.;

cap drop `num' `denum' `num0' `num1';
tempvar num cnum num1 num0 denum cnumi numi numi0 numi1 numi2;
qui gen     `num' = 0;
qui gen    `cnum' = 0;

qui gen    `num0' = 0;
qui gen    `num1' = 0;

qui gen    `numi' = 0;
qui gen    `numi2'= 0;

qui gen    `numi0'= 0;
qui gen    `numi1'= 0;

qui gen    `cnumi'= 0;
				    


if (`alpha' == 0)          				     qui replace    `num' = `hs'*(`pline1'> `1')*(`pline2'> `2');
if (`alpha' ~= 0 & `pline1' ~= 0 )           qui replace    `num' = `hs'*((`pline1'-`1')/`pline1')^`alpha'*((`pline2'-`2')/`pline2')^`alpha'  if (`pline1'>`1') & (`pline2'>`2');


if (`alpha' == 0)          				     qui replace    `num0' = `hs'*(`pline1'> `1');
if (`alpha' ~= 0 & `pline1' ~= 0 )           qui replace    `num0' = `hs'*((`pline1'-`1')/`pline1')^`alpha'  if (`pline1'>`1') ;


if (`alpha' == 0)          				     qui replace    `num1' = `hs'*(`pline2'> `2');
if (`alpha' ~= 0 & `pline2' ~= 0 )           qui replace    `num1' = `hs'*((`pline2'-`2')/`pline2')^`alpha'  if (`pline2'>`2') ;


if (`alpha' > 0) {;

/*

qui replace    `numi' = -`alpha'/`pline1'*`hs'*(`pline2'> `2');
qui replace    `numi' = -`alpha'/`pline1'*`hs'*((`pline1'-`1')/`pline1')^`al1'*((`pline2'-`2')/`pline2')^`alpha'  if (`pline1'>`1') & (`pline2'>`2');


qui replace    `cnumi' = -`alpha'/`pline2'*`hs'*(`pline1'> `1');
qui replace    `cnumi' = -`alpha'/`pline2'*`hs'*((`pline2'-`2')/`pline2')^`al1'*((`pline1'-`1')/`pline1')^`alpha'  if (`pline1'>`1') & (`pline2'>`2');


qui replace    `numi0' = -`alpha'/`pline1'*`hs';
qui replace    `numi0' = -`alpha'/`pline1'*`hs'*((`pline1'-`1')/`pline1')^`al1'  if (`pline1'>`1') ;
*/

/* if (`al1' == 0 )             qui replace    `numi' = -`alpha'/`pline1'*`hs'*(`pline2'> `2'); */
qui replace    `numi' = -`alpha'/`pline1'*`hs'*((`pline1'-`1')/`pline1')^`al1'*((`pline2'-`2')/`pline2')^`alpha'  if (`pline1'>`1') & (`pline2'>`2');


/* if (`al1' == 0 )             qui replace    `cnumi' = -`alpha'/`pline2'*`hs'*(`pline1'> `1'); */
qui replace    `cnumi' = -`alpha'/`pline2'*`hs'*((`pline2'-`2')/`pline2')^`al1'*((`pline1'-`1')/`pline1')^`alpha'  if (`pline1'>`1') & (`pline2'>`2');


*if (`al1' == 0 `pline1' ~= 0)             qui replace    `numi0' = -`alpha'/`pline1'*`hs';
qui replace    `numi0' = -`alpha'/`pline1'*`hs'*((`pline1'-`1')/`pline1')^`al1'  if (`pline1'>`1') ;



if ("`type'" == "prop" ) {;


qui replace    `numi'     = -`alpha'*`hs'* (  ((`pline1'-`1')/`pline1')^`al1'*((`pline2'-`2')/`pline2')^`alpha' -  ((`pline1'-`1')/`pline1')^`alpha'*((`pline2'-`2')/`pline2')^`alpha' ) if (`pline1'>`1') & (`pline2'>`2'); 
qui replace    `cnumi'    = -`alpha'*`hs'* (  ((`pline2'-`2')/`pline2')^`al1'*((`pline1'-`1')/`pline2')^`alpha' -  ((`pline2'-`2')/`pline2')^`alpha'*((`pline1'-`1')/`pline1')^`alpha' ) if (`pline1'>`1') & (`pline2'>`2'); 
qui replace    `numi0'    = `alpha'*`hs'*(  ((`pline1'-`1')/`pline1')^`alpha' -  ((`pline1'-`1')/`pline1')^`al1') if (`pline1'>`1') ;



};

};

/* IN PROGRESS */


if (`alpha' == 0) {;
tempvar fw;
qui gen `fw' =`hs'*`hweight';
qui su `1' [aw=`fw'], detail;           
local tmp = (`r(p75)'-`r(p25)')/1.34;                          
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
local h   = 0.9*`tmp'*_N^(-1.0/5.0);  
qui replace `numi' =  -`hs' *exp(-0.5* ( ((`pline1'-`1')/`h')^2  )   )/( `h'* sqrt(2*c(pi))) * (`pline2' <`2');  
qui replace `numi0' =  -`hs' *exp(-0.5* ( ((`pline1'-`1')/`h')^2  )  )/( `h'* sqrt(2*c(pi))) ;  
if ("`type'" == "prop") qui replace `numi'  = `numi'*`pline1';
if ("`type'" == "prop") qui replace `numi0' = `numi0'*`pline1';

qui su `2' [aw=`fw'], detail; 
local tmp = (`r(p75)'-`r(p25)')/1.34;                          
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
local h   = 0.9*`tmp'*_N^(-1.0/5.0);  
qui replace `cnumi' =  -`hs' *exp(-0.5* ( ((`pline2'-`2')/`h')^2  )   )/( `h'* sqrt(2*c(pi))) * (`pline1' <`1');  
if ("`type'" == "prop") qui replace `cnumi'  = `cnumi'*`pline2';
};




qui svy: ratio `hs'/`hsr'; 
cap matrix drop _aa;
matrix _aa=e(b);
local pop = el(_aa,1,1);
return scalar pop    = el(_aa,1,1);
cap matrix drop _vv;
matrix _vv=e(V);
local spop = el(_vv,1,1)^0.5;
return scalar spop  = `spop';



qui svy: ratio `num'/`hs'; 
cap matrix drop _aa;
matrix _aa=e(b);
local fgt = el(_aa,1,1);
return scalar fgt    = el(_aa,1,1);
cap matrix drop _vv;
matrix _vv=e(V);
local sfgt = el(_vv,1,1)^0.5;
return scalar sfgt  = `sfgt';



tempvar ccnumi;
gen  `ccnumi' = `numi'+`cnumi'*`so';


if ("`cnor'"=="no"){;

if ("`type'"~="prop"){;
qui svy: ratio `numi'/`hsr'; 
cap matrix drop _aa;
matrix _aa=e(b);
local impp = el(_aa,1,1)*`ampl';
return scalar impp    = `impp';
cap matrix drop _vv;
matrix _vv=e(V);
local simpp = el(_vv,1,1)^0.5*`ampl';
return scalar simpp  = `simpp';


qui svy: ratio `ccnumi'/`hsr'; 
cap matrix drop _aa;
matrix _aa=e(b);
local imppc = el(_aa,1,1)*`ampl';
return scalar imppc    = `imppc';
cap matrix drop _vv;
matrix _vv=e(V);
local simppc = el(_vv,1,1)^0.5*`ampl';
return scalar simppc  = `simppc';


qui svy: ratio `numi0'/`hsr'; 
cap matrix drop _aa;
matrix _aa=e(b);
local impp0 = el(_aa,1,1)*`ampl';
return scalar impp0    = `impp0';
cap matrix drop _vv;
matrix _vv=e(V);
local simpp0 = el(_vv,1,1)^0.5*`ampl';
return scalar simpp0  = `simpp0';

qui svy: mean `numi0' `num1' `hsr' `hs'; 
qui nlcom (_b[`numi0']*_b[`num1'])/(_b[`hsr']*_b[`hs']), iterate(50000);
cap matrix drop _aa;
matrix _aa=r(b);
local impp01 = el(_aa,1,1)*`ampl';
return scalar impp01    = `impp01' ;

cap matrix drop _vv;
matrix _vv=r(V);
local simpp01 = el(_vv,1,1)^0.5*`ampl';
return scalar simpp01  = `simpp01';


qui svy: ratio `numi'/`hs'; 
cap matrix drop _aa;
matrix _aa=e(b);
local impg = el(_aa,1,1)*`ampl';
return scalar impg    = `impg';
cap matrix drop _vv;
matrix _vv=e(V);
local simpg = el(_vv,1,1)^0.5*`ampl';
return scalar simpg  = `simpg';

};


if ("`type'"=="prop"){;
qui svy: ratio `numi'/`hsr'; 
cap matrix drop _aa;
matrix _aa=e(b);
local impp = el(_aa,1,1)*`ampl';
return scalar impp    = `impp';
cap matrix drop _vv;
matrix _vv=e(V);
local simpp = el(_vv,1,1)^0.5*`ampl';
return scalar simpp  = `simpp';


qui svy: ratio `ccnumi'/`hsr'; 
cap matrix drop _aa;
matrix _aa=e(b);
local imppc = el(_aa,1,1)*`ampl';
return scalar imppc    = `imppc';
cap matrix drop _vv;
matrix _vv=e(V);
local simppc = el(_vv,1,1)^0.5*`ampl';
return scalar simppc  = `simppc';


qui svy: ratio `numi0'/`hsr'; 
cap matrix drop _aa;
matrix _aa=e(b);
local impp0 = el(_aa,1,1)*`ampl';
return scalar impp0    = `impp0';
cap matrix drop _vv;
matrix _vv=e(V);
local simpp0 = el(_vv,1,1)^0.5*`ampl';
return scalar simpp0  = `simpp0';

qui svy: mean `numi0' `num1' `hsr' `hs'; 
qui nlcom (_b[`numi0']*_b[`num1'])/(_b[`hsr']*_b[`hs']), iterate(50000);
cap matrix drop _aa;
matrix _aa=r(b);
local impp01 = el(_aa,1,1)*`ampl';
return scalar impp01    = `impp01' ;

cap matrix drop _vv;
matrix _vv=r(V);
local simpp01 = el(_vv,1,1)^0.5*`ampl';
return scalar simpp01  = `simpp01';


qui svy: ratio `numi'/`hs'; 
cap matrix drop _aa;
matrix _aa=e(b);
local impg = el(_aa,1,1)*`ampl';
return scalar impg    = `impg';
cap matrix drop _vv;
matrix _vv=e(V);
local simpg = el(_vv,1,1)^0.5*`ampl';
return scalar simpg  = `simpg';

};
};


if ("`cnor'"=="yes"){;


if ("`type'" ~= "prop"){;
dis "OK.............";
qui svy: ratio `numi'/`hs'; 
cap matrix drop _aa;
matrix _aa=e(b);
local impp = el(_aa,1,1)*`ampl' ;
return scalar impp   = `impp' ;
cap matrix drop _vv ;
matrix _vv=e(V) ;
local simpp = el(_vv,1,1)^0.5*`ampl';
return scalar simpp  = `simpp';


qui svy: ratio `ccnumi'/`hs'; 
cap matrix drop _aa;
matrix _aa=e(b);
local imppc = el(_aa,1,1)*`ampl' ;
return scalar imppc   = `imppc' ;
cap matrix drop _vv ;
matrix _vv=e(V) ;
local simppc = el(_vv,1,1)^0.5*`ampl';
return scalar simppc  = `simppc';


qui svy: ratio `numi0'/`hs'; 
cap matrix drop _aa;
matrix _aa=e(b);
local impp0 = el(_aa,1,1)*`ampl' ;
return scalar impp0   = `impp0' ;
cap matrix drop _vv ;
matrix _vv=e(V) ;
local simpp0 = el(_vv,1,1)^0.5*`ampl';
return scalar simpp0  = `simpp0';



qui svy: mean `numi0' `num1' `hs'; 
qui nlcom (_b[`numi0']*_b[`num1'])/(_b[`hs']^2), iterate(50000);
cap matrix drop _aa;
matrix _aa=r(b);
local impp01 = el(_aa,1,1)*`ampl';
return scalar impp01    = `impp01' ;

cap matrix drop _vv;
matrix _vv=r(V);
local simpp01 = el(_vv,1,1)^0.5*`ampl';
return scalar simpp01  = `simpp01';


qui svy: mean `numi'  `hs' `hsr'; 
qui nlcom (_b[`numi']*_b[`hsr'])/(_b[`hs']^2), iterate(50000);
cap matrix drop _aa;
matrix _aa=r(b);
local impg = el(_aa,1,1)*`ampl';
return scalar impg    = `impg' ;

cap matrix drop _vv;
matrix _vv=r(V);
local simpg = el(_vv,1,1)^0.5*`ampl';
return scalar simpg  = `simpg';

};

if ("`type'"=="prop"){;

qui svy: ratio `numi'/`hsy'; 
cap matrix drop _aa;
matrix _aa=e(b);
local impp = el(_aa,1,1)*`ampl';
return scalar impp    = `impp';
cap matrix drop _vv;
matrix _vv=e(V);
local simpp = el(_vv,1,1)^0.5*`ampl';
return scalar simpp  = `simpp';


qui svy: ratio `ccnumi'/`hsy'; 
cap matrix drop _aa;
matrix _aa=e(b);
local imppc = el(_aa,1,1)*`ampl';
return scalar imppc    = `imppc';
cap matrix drop _vv;
matrix _vv=e(V);
local simppc = el(_vv,1,1)^0.5*`ampl';
return scalar simppc  = `simppc';


qui svy: ratio `numi0'/`hsy'; 
cap matrix drop _aa;
matrix _aa=e(b);
local impp0 = el(_aa,1,1)*`ampl';
return scalar impp0    = `impp0';
cap matrix drop _vv;
matrix _vv=e(V);
local simpp0 = el(_vv,1,1)^0.5*`ampl';
return scalar simpp0  = `simpp0';


qui svy: mean `numi0' `num1' `hsy' `hs'; 
qui nlcom (_b[`numi0']*_b[`num1'])/(_b[`hsy']*_b[`hs']), iterate(50000);
cap matrix drop _aa;
matrix _aa=r(b);
local impp01 = el(_aa,1,1)*`ampl';
return scalar impp01    = `impp01' ;

cap matrix drop _vv;
matrix _vv=r(V);
local simpp01 = el(_vv,1,1)^0.5*`ampl';
return scalar simpp01  = `simpp01';


qui svy: mean `numi'  `hs' `hsr' `hsy'; 
qui nlcom (_b[`numi']*_b[`hsr'])/(_b[`hs']*_b[`hsy']), iterate(50000);
cap matrix drop _aa;
matrix _aa=r(b);
local impg = el(_aa,1,1)*`ampl';
return scalar impg    = `impg';
cap matrix  drop _vv;
matrix _vv=r(V);
local simpg = el(_vv,1,1)^0.5*`ampl';
return scalar simpg  = `simpg';

};


};


/*restore;*/

if (`pos' != -1) {;
cap drop _s_hs_`pos';
qui gen _s_hs_`pos' = `hs';

cap drop _s_hsr_`pos';
qui gen _s_hsr_`pos' = `hsr';


cap drop _s_hsy_`pos';
qui gen _s_hsy_`pos' = `hsy';


cap drop _s_num1_`pos';
qui gen _s_num1_`pos' = `num1';

cap drop _s_numi_`pos';
qui gen _s_numi_`pos' = `numi';

cap drop _s_numi0_`pos';
qui gen _s_numi0_`pos' = `numi0';

cap drop _s_ccnumi_`pos';
qui gen _s_ccnumi_`pos' = `ccnumi';

};

sum _s_* ;
end;



capture program drop itargetg2d;
program define itargetg2d, rclass sortpreserve;
version 9.2;
syntax varlist(min=2)[,  
HSize(varname)  hgroup(varname)  ALpha(real 0) PLINE1(real 10000) PLINE2(real 10000)
IMPON(string)
cnor(string)
DEC(int 9)
DSTE(int 1)
type(string)  CONSTAM(real 1) PROP(real 1) LRES(int 0) SRES(string) DCI(string) SLEVEL(int 5) SO(real 0)];

_get_gropts , graphopts(`options') ;
	local options `"`s(graphopts)'"';

local dste = 1;

if ("`type'"=="")      local type="lump";
if ("`cnor'"=="")      local cnor="no";
if ("`dci'"=="" )      local dci ="no";
if ("`conf'"=="")      local conf="ts";
                       local ampl = `constam';
if ("`type'"=="prop")  local ampl = `prop'/100;
                       local slevel = `slevel' / 100;
					   local so = `so'/100;

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

if ("`hgroup'"!="") {;
preserve;
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
_nargs    `varlist';
preserve;
};

local hweight=""; 
cap qui svy: total `1'; 

cap if (`e(wvar)') local hweight=`"`e(wvar)'"';
if ("`e(wvar)'"~="`hweight'") dis as txt in blue " Warning: sampling weight is initialized but not found.";


local dgr = "no";

if ("`max'" ~= "" ) local dgr = "yes";

if ("`dgr'" == "no" ){;
tempvar Variable EST1 EST2 EST3 EST4 EST5 EST6 EST7 EST8  STE STE1 STE2 STE3 STE4  STE5 STE6 STE7 STE8;

qui gen `Variable'="";
qui gen `EST1'=0;
qui gen `STE1'=0;

qui gen `EST2'=0;
qui gen `STE2'=0;

qui gen `EST3'=0;
qui gen `STE3'=0;

qui gen `EST4'=0;
qui gen `STE4'=0;

qui gen `EST6'=0;
qui gen `STE6'=0;

qui gen `EST7'=0;
qui gen `STE7'=0;

qui gen `EST8'=0;
qui gen `STE8'=0;

local ll=10;

cap drop _okey;
qui gen      _okey=_n;

forvalues k = 1/$indica {;

if ("`hgroup'"=="") {;
local label`f'  =  "``k''";
};

if ("`hgroup'"!="") {;
local kk = gn1[`k'];
local k1 = gn1[1];
local label`f'  : label (`hgroup') `kk';
local labelg1   : label (`hgroup') `k1';
if ( "`label1'" == "")   local labelg1    = "Group: `k1'";
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";


 qui itargetg2d2 `1' `2', hweight(`hweight') 
hsize(`hsize') hgroup(`hgroup')  ngroup(`kk') alpha(`alpha') pline1(`pline1') pline2(`pline2')
type(`type') ampl(`ampl') impon(`impon') cnor(`cnor') so(`so') pos(`k');



qui replace `EST1'      = `r(pop)'  in `k';
qui replace `STE1'      = `r(spop)' in `k';

qui replace `EST2'      = `r(fgt)'   in `k';
qui replace `STE2'      = `r(sfgt)'  in `k';

qui replace `EST3'      = `r(impp)' in `k';
qui replace `STE3'      = `r(simpp)' in `k';

qui replace `EST4'      = `r(impg)' in `k';
qui replace `STE4'      = `r(simpg)' in `k';

qui replace `EST6'      = `r(impp0)' in `k';
qui replace `STE6'      = `r(simpp0)' in `k';


qui replace `EST7'      = `r(impp01)' in `k';
qui replace `STE7'      = `r(simpp01)' in `k';

qui replace `EST8'      = `r(imppc)' in `k';
qui replace `STE8'      = `r(simppc)' in `k';



local label`f'  : label (`hgroup') `kk';
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";
qui replace `Variable' = "`label`f''" in `k';

local ll=max(`ll',length("`label`f''"));



};

};




/**********************************************/



#delimit ;
local nlist  _A _B _C _D;

foreach c of local nlist {;
matrix	`c'=I($indica);
forvalues i=1/$indica {;
matrix `c'[`i',`i'] =0;
};

};


local comp  _s_hs_ _s_hsr_  _s_hsy_  _s_num1_ _s_numi_ _s_numi0_ _s_ccnumi_ ;
foreach c of local comp  {;
forvalues i=1/$indica {;
qui gen __cy_`c'`i'=`c'`i';
};
};


#delimit ;
tempvar rank;
qui egen float `rank' = rank( `EST6' ) in 1/$indica;
qui sort `EST6' in 1/$indica, stable;

local comp  _s_hs_ _s_hsr_  _s_hsy_  _s_num1_ _s_numi_ _s_numi0_ _s_ccnumi_ ;
foreach c of local comp  {;
forvalues i=1/$indica {;
local rr = _okey[`i'];
cap drop __r`c'`i';
qui gen __r`c'`i'=__cy_`c'`rr';
};
};
foreach c of  local comp  {;
forvalues i=1/$indica {;
qui replace `c'`i'=__r`c'`i';
};
};


forvalues i=1/$indica {;
local i1=`i'+1;
forvalues j=`i1'/$indica {;
if ("`cnor'"=="no"){;
qui svy: mean  _s_numi0_`i' _s_hsr_`i' _s_numi0_`j' _s_hsr_`j'; 
qui nlcom (_b[_s_numi0_`i']/_b[_s_hsr_`i']) - (_b[_s_numi0_`j']/_b[_s_hsr_`j'])  , iterate(50000);
cap matrix drop _vv;
matrix _vv=r(V);
local simpp0 = el(_vv,1,1)^0.5*`ampl';
return scalar simpp0  = `simpp0';
};
if ("`cnor'"=="yes"){;
if ("`type'"~="prop"){;

qui svy: mean  _s_numi0_`i' _s_hs_`i' _s_numi0_`j' _s_hs_`j'; 
qui nlcom (_b[_s_numi0_`i']/_b[_s_hs_`i']) - (_b[_s_numi0_`j']/_b[_s_hs_`j'])  , iterate(50000);
matrix _vv=r(V);
local simpp0 = el(_vv,1,1)^0.5*`ampl';
return scalar simpp0  = `simpp0';
cap matrix drop _aa;
};

if ("`type'"=="prop"){;
qui svy: mean  _s_numi0_`i' _s_hsy_`i' _s_numi0_`j' _s_hsy_`j';
qui nlcom (_b[_s_numi0_`i']/_b[_s_hsy_`i']) - (_b[_s_numi0_`j']/_b[_s_hsy_`j'])  , iterate(50000);
cap matrix drop _aa;
matrix _aa=r(b);
local impp0 = el(_aa,1,1)*`ampl';
return scalar impp0    = `impp0';
cap matrix drop _vv;
matrix _vv=r(V);
local simpp0 = el(_vv,1,1)^0.5*`ampl';
return scalar simpp0  = `simpp0';
};
};
matrix _A[`i',`j'] =`simpp0';
};
};




#delimit ;
tempvar rank;
qui egen float `rank' = rank( `EST7' ) in 1/$indica;
qui sort `EST7' in 1/$indica, stable;

local comp  _s_hs_ _s_hsr_  _s_hsy_  _s_num1_ _s_numi_ _s_numi0_ _s_ccnumi_ ;
foreach c of local comp  {;
forvalues i=1/$indica {;
local rr = _okey[`i'];
cap drop __r`c'`i';
qui gen __r`c'`i'=__cy_`c'`rr';
};
};
foreach c of  local comp  {;
forvalues i=1/$indica {;
qui replace `c'`i'=__r`c'`i';
};
};



forvalues i=1/$indica {;
local i1=`i'+1;
forvalues j=`i1'/$indica {;

if ("`cnor'"=="no"){;
qui svy: mean  _s_numi0_`i' _s_num1_`i' _s_hs_`i' _s_hsr_`i'   _s_numi0_`j' _s_num1_`j' _s_hs_`j' _s_hsr_`j'; 
qui nlcom (_b[_s_numi0_`i']*_b[_s_num1_`i'])/(_b[_s_hsr_`i']*_b[_s_hs_`i']) - (_b[_s_numi0_`j']*_b[_s_num1_`j'])/(_b[_s_hsr_`j']*_b[_s_hs_`j']), iterate(50000);
cap matrix drop _vv;
matrix _vv=r(V);
local simpp01 = el(_vv,1,1)^0.5*`ampl';
return scalar simpp01  = `simpp01';
};


if ("`cnor'"=="yes"){;
if ("`type'"~="prop"){;
qui svy: mean  _s_numi0_`i' _s_num1_`i' _s_hs_`i' _s_numi0_`j' _s_num1_`j' _s_hs_`j'; 
qui nlcom (_b[_s_numi0_`i']*_b[_s_num1_`i']/_b[_s_hs_`i']^2) - (_b[_s_numi0_`j']*_b[_s_num1_`j']/_b[_s_hs_`j']^2) , iterate(50000);
cap matrix drop _vv;
matrix _vv=r(V);
local simpp01 = el(_vv,1,1)^0.5*`ampl';
return scalar simpp01  = `simpp01';
};

if ("`type'"=="prop"){;
qui svy: mean  _s_numi0_`i' _s_num1_`i' _s_hs_`i' _s_hsy_`i'   _s_numi0_`j' _s_num1_`j' _s_hs_`j' _s_hsy_`j'; 
qui nlcom (_b[_s_numi0_`i']*_b[_s_num1_`i'])/(_b[_s_hsy_`i']*_b[_s_hs_`i']) - (_b[_s_numi0_`j']*_b[_s_num1_`j'])/(_b[_s_hsy_`j']*_b[_s_hs_`j']), iterate(50000);
cap matrix drop _vv;
matrix _vv=r(V);
local simpp01 = el(_vv,1,1)^0.5*`ampl';
return scalar simpp01  = `simpp01';
};
};
matrix _B[`i',`j']=`simpp01';
};
};





#delimit ;
tempvar rank;
qui egen float `rank' = rank( `EST3' ) in 1/$indica;
qui sort `EST3' in 1/$indica, stable;


local comp  _s_hs_ _s_hsr_  _s_hsy_  _s_num1_ _s_numi_ _s_numi0_ _s_ccnumi_ ;
foreach c of local comp  {;
forvalues i=1/$indica {;
local rr = _okey[`i'];
cap drop __r`c'`i';
qui gen __r`c'`i'=__cy_`c'`rr';
};
};
foreach c of  local comp  {;
forvalues i=1/$indica {;
qui replace `c'`i'=__r`c'`i';
};
};





forvalues i=1/$indica {;
local i1=`i'+1;
forvalues j=`i1'/$indica {;

if ("`cnor'"=="no"){;


qui svy: mean  _s_numi_`i' _s_hsr_`i' _s_numi_`j' _s_hsr_`j'; 

qui nlcom ( _b[_s_numi_`i']/_b[_s_hsr_`i'] - _b[_s_numi_`j']/_b[_s_hsr_`j'] ), iterate(50000);
cap matrix drop _aa;
matrix _aa=r(b);
local impp = el(_aa,1,1)*`ampl';
return scalar impp    = `impp';
cap matrix drop _vv;
matrix _vv=r(V);
local simpp = el(_vv,1,1)^0.5*`ampl';
return scalar simpp  = `simpp';
};


if ("`cnor'"=="yes"){;
if ("`type'"~="prop"){;
qui svy: mean  _s_numi_`i' _s_hs_`i' _s_numi_`j' _s_hs_`j'; 
qui nlcom (_b[_s_numi_`i']/_b[_s_hs_`i']) - (_b[_s_numi_`j']/_b[_s_hs_`j'])  , iterate(50000);
cap matrix drop _aa;
matrix _aa=r(b);
local impp = el(_aa,1,1)*`ampl' ;
return scalar impp   = `impp' ;
cap matrix drop _vv ;
matrix _vv=r(V) ;
local simpp = el(_vv,1,1)^0.5*`ampl';
return scalar simpp  = `simpp';
};

if ("`type'"=="prop"){;

qui svy: mean  _s_numi_`i' _s_hsy_`i' _s_numi_`j' _s_hsy_`j'; 

qui nlcom (_b[_s_numi_`i']/_b[_s_hsy_`i']) - (_b[_s_numi_`j']/_b[_s_hsy_`j'])  , iterate(50000);
cap matrix drop _aa;
matrix _aa=r(b);
local impp = el(_aa,1,1)*`ampl';
return scalar impp    = `impp';
cap matrix drop _vv;
matrix _vv=r(V);
local simpp = el(_vv,1,1)^0.5*`ampl';
return scalar simpp  = `simpp';
};
};
matrix  _C[`i',`j']=`simpp';
};
};




#delimit ;
tempvar rank;
qui egen float `rank' = rank( `EST8' ) in 1/$indica;
qui sort `EST8' in 1/$indica, stable;

local comp  _s_hs_ _s_hsr_  _s_hsy_  _s_num1_ _s_numi_ _s_numi0_ _s_ccnumi_  ;




foreach c of local comp  {;
forvalues i=1/$indica {;
cap drop __r`c'`i';
local rr = _okey[`i'];
qui gen __r`c'`i'=__cy_`c'`rr';
};
};

foreach c of  local comp  {;
forvalues i=1/$indica {;
qui replace `c'`i'=__r`c'`i';
};
};




forvalues i=1/$indica {;


local i1=`i'+1;
forvalues j=`i1'/$indica {;

if ("`cnor'"=="no"){;
qui svy: mean  _s_ccnumi_`i' _s_hsr_`i' _s_ccnumi_`j' _s_hsr_`j'; 


qui nlcom (_b[_s_ccnumi_`i']/_b[_s_hsr_`i']) - (_b[_s_ccnumi_`j']/_b[_s_hsr_`j'])  , iterate(50000);
cap matrix drop _vv;
matrix _vv=r(V);
local simppc = el(_vv,1,1)^0.5*`ampl';
return scalar simppc  = `simppc';
};


if ("`cnor'"=="yes"){;
if ("`type'"~="prop"){;
qui svy: mean  _s_ccnumi_`i' _s_hs_`i' _s_ccnumi_`j' _s_hs_`j'; 
qui nlcom (_b[_s_ccnumi_`i']/_b[_s_hs_`i']) - (_b[_s_ccnumi_`j']/_b[_s_hs_`j'])  , iterate(50000);
cap matrix drop _vv ;
matrix _vv=r(V) ;
local simppc = el(_vv,1,1)^0.5*`ampl';
return scalar simppc  = `simppc';
};

if ("`type'"=="prop"){;
qui svy: mean  _s_ccnumi_`i' _s_hsy_`i' _s_ccnumi_`j' _s_hsy_`j'; 
qui nlcom (_b[_s_ccnumi_`i']/_b[_s_hsy_`i']) - (_b[_s_ccnumi_`j']/_b[_s_hsy_`j'])  , iterate(50000);
cap matrix drop _vv;
matrix _vv=r(V);
local simppc = el(_vv,1,1)^0.5*`ampl';
return scalar simppc  = `simppc';
};
};
matrix _D[`i',`j']=`simppc';
};
};



 
/*********************************************/


local kk1 = $indica+1;


qui itargetg2d2 `1' `2', hweight(`hweight') 
hsize(`hsize')  alpha(`alpha') pline1(`pline1') pline2(`pline2')
type(`type') ampl(`ampl') impon(`impon') cnor(`cnor') so(`so') pos(-1);

qui replace `Variable' = "Population" in `kk1';
qui replace `EST1'      = `r(pop)' in `kk1';
qui replace `STE1'      = `r(spop)' in `kk1';

qui replace `EST2'      = `r(fgt)' in `kk1';
qui replace `STE2'      = `r(sfgt)' in `kk1';

qui replace `EST3'      = `r(impp)' in `kk1';
qui replace `STE3'      = `r(simpp)' in `kk1';

qui replace `EST4'      = `r(impg)' in `kk1';
qui replace `STE4'      = `r(simpg)' in `kk1';


qui replace `EST8'      = `r(imppc)'  in `kk1';
qui replace `STE8'      = `r(simppc)' in `kk1';




/*****RESULTS*****/
                     local targetg = "Whole population";
if ("`hgroup'"~="")  local targetg = "Groups => `hgroup' ";

                       local scheme = "Lump-sum (constant)";
if ("`type'"~="lump")  local scheme = "Proportional       ";

if ("`hgroup'"~="") {;
       tempname table;
	.`table'  = ._tab.new, col(4);
	.`table'.width |`ll'|16 20 16 |;
	.`table'.strcolor . . yellow . ;
	.`table'.numcolor yellow yellow . yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f ;
	di _n as text "{col 4} Targeting population groups and poverty";
       			    di as text     "{col 5}Targeting  groups   :  `targetg'";
                            di as text     "{col 5}Targeting  scheme   :  `scheme'";
                            di as text     "{col 5}Normalized by cost  :  `cnor'";
       if ("`hsize'"!="")   di as text     "{col 5}Household size      :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight     :  `hweight'";
                            di as text     "{col 5}Parameter alpha     : "  %5.2f `alpha'       ;
							di as text     "{col 5}Parameter Spill-Over: "  %5.2f `so'       ;
     			          di as text     "{col 5}Poverty line 1        : "  %5.2f `pline1'       ;	
						  di as text     "{col 5}Poverty line 2        : "  %5.2f `pline2'       ;
	.`table'.sep, top;
	.`table'.titles "Group  " "Population  " "Mutiplicative index"    "Impact on"  ;
	.`table'.titles "       " "  Share    "   "           "           "Population" ;
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/$indica{;
        
             .`table'.numcolor white yellow yellow yellow  ;
			 .`table'.row `Variable'[`i'] `EST1'[`i']  `EST2'[`i']  `EST8'[`i'] ;
             .`table'.numcolor white green  green green ;
		      if (`dste'== 1) .`table'.row "" `STE1'[`i']  `STE2'[`i']  `STE8'[`i'];
              	        
                };
  .`table'.sep, mid;
.`table'.numcolor white yellow yellow yellow  ;
.`table'.row `Variable'[`kk1'] `EST1'[`kk1']  `EST2'[`kk1']  `EST8'[`kk1'];
if (`dste'==1){;
.`table'.numcolor white green   green  green ;
.`table'.row "" `STE1'[`kk1']  `STE2'[`kk1']  `STE8'[`kk1'];
};


.`table'.sep,bot;

};



if ("`hgroup'"=="") {;

local kk1 = 1;
local kk2 = 2;
  tempname table;
	.`table'  = ._tab.new, col(2);
	.`table'.width |16 16|;
	.`table'.strcolor . .  ;
	.`table'.numcolor yellow yellow  ;
	.`table'.numfmt %16.`dec'f  %16.`dec'f  ;
	di _n as text "{col 1} Targeting population groups and poverty";
         
	.`table'.sep, top;
	.`table'.titles  "FGT index"  " Impact on "   ;
	.`table'.titles  "         "   "Population"  ;
	.`table'.numcolor yellow yellow  ;
      .`table'.row   `EST2'[`kk1'] `EST3'[`kk1']; 
if (`dste'==1){;
.`table'.numcolor green   green   ;
.`table'.row `EST2'[`kk2'] `EST3'[`kk2']; 
};

.`table'.sep,bot;
};




}; 


	  
/* Impact of the first dimension: -1/z*P0 */
	  
tempvar coda;
qui gen     `coda' = 6     ;
qui replace `coda' = 7 in 2;
qui replace `coda' = 3 in 3;
qui replace `coda' = 8 in 4;

tempvar      mname;
qui gen     `mname' = "_A"  ;
qui replace `mname' = "_B"  in 2;
qui replace `mname' = "_C"  in 3;
qui replace `mname' = "_D"  in 4;


tempvar tab_tit;
qui gen     `tab_tit'="";

qui replace `tab_tit'    = "Impact Based on the component -alpha/z* [P1(alpha-1)]"   in 1;
qui replace `tab_tit'    = "Impact Based on the component -alpha/z* [P1(alpha-1)*P2(alpha)] " in 2;
qui replace `tab_tit'    = "Total impact without spill-over : -alpha/z* [P1(alpha-1)P2(alpha) + Cov(.)]  "     in 3;
qui replace `tab_tit'    = "Total impact with spill-over"                  in 4;

if ("`type'"~="prop") {;

qui replace `tab_tit'    = "Impact Based on the component -alpha/z* [P1(alpha-1)]"   in 1;
qui replace `tab_tit'    = "Impact Based on the component -alpha/z* [P1(alpha-1)*P2(alpha)] " in 2;
qui replace `tab_tit'    = "Total impact without spill-over : -alpha/z* [P1(alpha-1)P2(alpha) + Cov(.)]  "     in 3;
qui replace `tab_tit'    = "Total impact with spill-over"                  in 4;
};

if ("`type'"=="prop") {;

if ("`cnor'"~="yes") {;
qui replace `tab_tit'    = "Impact Based on the component   :  alpha* [P1(alpha) - P1(alpha-1) ]"   in 1;
qui replace `tab_tit'    = "Impact Based on the component   :  alpha* [P1(alpha) - P1(alpha-1)*P2(alpha)] " in 2;
qui replace `tab_tit'    = "Total impact without spill-over : alpha* [P1(alpha) - P1(alpha-1)*P2(alpha)] + Cov(.)]  "     in 3;
qui replace `tab_tit'    = "Total impact with spill-over"                  in 4;
};

if ("`cnor'"=="yes") {;
qui replace `tab_tit'    = "Impact Based on the component   :  alpha* [P1(alpha) - P1(alpha-1) ]"   in 1;
qui replace `tab_tit'    = "Impact Based on the component   :  alpha* [P1(alpha) - P1(alpha-1)*P2(alpha)] " in 2;
qui replace `tab_tit'    = "Total impact without spill-over : alpha* [P1(alpha) - P1(alpha-1)*P2(alpha)] + Cov(.)]  "     in 3;
qui replace `tab_tit'    = "Total impact with spill-over"                  in 4;
};

};


forvalues h=1/4 {;
  
//qui {;
global drop $resas;
if ( `h' == 1) {;
local  coda  = 6     ; 
local  mname = "_A"  ;
};

if ( `h' == 2) {;
local coda = 7     ; 
local mname = "_B"  ;
};

if ( `h'==3 ) {;
local     coda = 3    ; 
local     mname = "_C"  ;
};

if ( `h' == 4) {;
local   coda = 8     ;
local  mname = "_D"  ;
};


tempvar rank;
qui egen float `rank' = rank( `EST`coda'' ) in 1/$indica;


qui itarg2d_test `EST`coda'' `STE`coda'' gn1, ng($indica) mname("`mname'") slev(`slevel');
local lista $resas;
tokenize `lista' ;
forvalues k = 1/$indica {;
local tres`k'="``k''";
};

*set trace on;
cap drop `tres' `groupg' `codeg'  `orde' `est' `ste';
tempvar tres groupg codeg orde est ste;
qui gen `tres'  =""; 
qui gen `groupg' ="";
qui gen `codeg' =0;
qui gen `orde' = _n;
qui gen `est' = 0;
qui gen `ste' = 0;
forvalues k = 1/$indica {;
local tt = `rank'[`k'];
qui {;
replace `tres'="`tres`k''  " in `k';
replace `codeg' =gn1[`k'] in `tt';
replace `groupg' =`Variable'[`k'] in `tt';
replace `est' =`EST`coda''[`k'] in `tt';
replace `ste' =`STE`coda''[`k'] in `tt';
};

};

//};

 

     tempname table;
	 local slevela =  100*`slevel';
	.`table'  = ._tab.new, col(6);
	.`table'.width |6| 6 | `ll'|16 16 | 20 |;
	
	.`table'.strcolor . . yellow . . .;
	.`table'.numcolor yellow yellow . yellow yellow yellow;
	.`table'.numfmt %6.0f %6.0f %16.0g  %16.`dec'f  %16.`dec'f  %-20s;
	  di _n as text "{col 4} "`tab_tit'[`h'] ;
	.`table'.sep, top;
	.`table'.titles "Rank  "     "Code " "Label "  "Estimated  "  "Standard"    "Test of difference" ;
	.`table'.titles "      "     "     "  "     "  "Impact     "  "Error     "  "Signif. = `slevela'% " ;
	.`table'.sep, mid;
	
	forvalues i=1/$indica{;
        
             .`table'.numcolor white yellow yellow yellow yellow yellow ;
			 .`table'.row `orde'[`i'] `codeg'[`i']  `groupg'[`i'] `est'[`i'] `ste'[`i'] `tres'[`i'];
			 return scalar est`i'  = `est'[`i'] ;
       };


      .`table'.sep,bot;
	
};

	  
matrix drop _A _B _C _D;
	  

end;




/*

*set trace on;
set tracedepth 1;
itargetg2d tot98eq haz, alpha(1) pline1(1790) pline2(8)  slevel(5) so(0)  cnor(yes)  hgroup(prov_mil_1);

*/
