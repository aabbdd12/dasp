/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 3.01)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2026)          */
/* Universite Laval , Quebec, Canada                                     */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : itargetg                                                     */
/*************************************************************************/

#delim ;



capture program drop itargetg2;
program define itargetg2, rclass;
version 9.2;
syntax varlist(min=1)[,  HWEIGHT(string) HSize(string) HGroup(string) NGroup(int 1) ALpha(real 0) PLINE(real 10000)
IMPON(string)
cnor(string)
type(string)
ampl(real 1)
];
preserve;
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

cap drop `num' `denum';
tempvar num denum numi;
qui gen    `num' = 0;
qui gen    `numi'= 0;
				    
if (`alpha' == 0)           qui replace    `num' = `hs'*(`pline'> `1');
if (`alpha' ~= 0 & `pline' ~= 0 )           qui replace    `num' = `hs'*((`pline'-`1')/`pline')^`alpha'  if (`pline'>`1');

if (`alpha' > 0) {;


if (`al1' == 0 `pline' ~= 0)             qui replace    `numi' = -`alpha'/`pline'*`hs'*(`pline'> `1');
if (`al1' ~= 0 `pline' ~= 0)             qui replace    `numi' = -`alpha'/`pline'*`hs'*((`pline'-`1')/`pline')^`al1'  if (`pline'>`1');


if ("`type'" == "prop") qui replace    `numi' = `alpha'*`num'+`pline'*`numi';


};

if (`alpha' == 0) {;
tempvar fw;
qui gen `fw' =`hs'*`hweight';
qui su `1' [aw=`fw'], detail;           
local tmp = (`r(p75)'-`r(p25)')/1.34;                          
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
local h   = 0.9*`tmp'*_N^(-1.0/5.0);  
qui replace `numi' =  -`hs' *exp(-0.5* ( ((`pline'-`1')/`h')^2  )  )/( `h'* sqrt(2*c(pi)));  
if ("`type'" == "prop") qui replace `numi' = `numi'*`pline';
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






if ("`cnor'"=="no"){;


qui svy: ratio `numi'/`hsr'; 
cap matrix drop _aa;
matrix _aa=e(b);
local impp = el(_aa,1,1)*`ampl';
return scalar impp    = `impp';
cap matrix drop _vv;
matrix _vv=e(V);
local simpp = el(_vv,1,1)^0.5*`ampl';
return scalar simpp  = `simpp';


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


if ("`cnor'"=="yes"){;



if ("`type'"~="prop"){;

qui svy: ratio `numi'/`hs'; 
cap matrix drop _aa;
matrix _aa=e(b);
local impp = el(_aa,1,1)*`ampl' ;
return scalar impp   = `impp' ;
cap matrix drop _vv ;
matrix _vv=e(V) ;
local simpp = el(_vv,1,1)^0.5*`ampl';
return scalar simpp  = `simpp';


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


restore;
end;




capture program drop gitargetg2;
program define gitargetg2, rclass;
version 9.2;
syntax varlist(min=1)[,  HWEIGHT(string) HSize(string) HGroup(string) NGroup(int 1) ALpha(real 0) 
MIN(real 0) MAX(real 10000)
cnor(string)
type(string)
ampl(real 1)
constam(real 1)
prop(real 1)
dci(string)
level(real 95)
conf(string)
label(string)
];
preserve;

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

                        local ampli = `constam';
if ("`type'" == "prop") local ampli = `ampli'/100;

local al1 = `alpha' - 1;

if ("`hgroup'"~="")    qui replace `hs'  =`hs'*(`hgroup'==`ngroup');

if ("`hweight'"=="")   {;
tempvar hweight;
gen `hweight' = 1;
};

gen `hsy'=`hs'*`1';
if ("`dci'"=="no") {;
qui replace `hs' = `hs'*`hweight';
qui replace `hsr'=`hsr'*`hweight';
qui replace `hsy'=`hsy'*`hweight';
};



tempvar ra vimpp _limpp _uimpp;

gen `vimpp'=0;
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

dis "Estimation for group: `label'";

forvalues j=1/101 {;

qui replace `ra'=`min'+(`j'-1)*`pas' in `j';
local pline = `min'+(`j'-1)*`pas';
cap drop `num' `numi';
tempvar   num denum numi;
qui gen    `num' = 0;
qui gen    `numi'= 0;
				    
if (`alpha' == 0)           qui replace    `num' = `hs'*(`pline'> `1');
if (`alpha' ~= 0)           qui replace    `num' = `hs'*((`pline'-`1')/`pline')^`alpha'  if (`pline'>`1');

if (`alpha' > 0) {;


if (`al1' == 0)             qui replace    `numi' = -`alpha'/`pline'*`hs'*(`pline'> `1');
if (`al1' ~= 0)             qui replace    `numi' = -`alpha'/`pline'*`hs'*((`pline'-`1')/`pline')^`al1'  if (`pline'>`1');

if (`pline'==0) {;
qui replace    `num' = 0 ;
qui replace    `numi'= 0 ;
};
if ("`type'" == "prop")     qui replace    `numi' = `alpha'*`num'+`pline'*`numi';

};

if (`alpha' == 0) {;
tempvar fw;
qui gen `fw' =`hs'*`hweight';
qui su `1' [aw=`fw'], detail;           
local tmp = (`r(p75)'-`r(p25)')/1.34;                          
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
local h   = 0.9*`tmp'*_N^(-1.0/5.0);  
qui replace `numi' =  -`hs' *exp(-0.5* ( ((`pline'-`1')/`h')^2  )  )/( `h'* sqrt(2*c(pi)));  
if ("`type'" == "prop") qui replace `numi' = `numi'*`pline';
};


 

qui sum `numi'; local snumi    = `r(sum)';
qui sum `hs';   local shs      = `r(sum)';
qui sum `hsr';  local shsr     = `r(sum)';
qui sum `hsy';  local shsy     = `r(sum)';

if ("`cnor'"=="no"){;


if ("`dci'"=="no") {;
local impp = `snumi'/`shsr'; 
};

if ("`dci'"=="yes"){;

qui svy: ratio `numi'/`hsr';
matrix _aa=e(b);
local impp = el(_aa,1,1);
cap matrix drop _vv;
matrix _vv=e(V);
local simpp = el(_vv,1,1)^0.5;
local limpp   = `impp' - `tt'*`simpp';
local uimpp   = `impp' + `tt'*`simpp';

};

};


if ("`cnor'"=="yes"){;
if ("`type'"~="prop"){;
if ("`dci'"=="no"){;
local impp    = `snumi'/`shs'; 
};

if ("`dci'"=="yes"){;
qui svy: ratio `numi'/`hs';
matrix _aa=e(b);
local impp = el(_aa,1,1);
cap matrix drop _vv;
matrix _vv=e(V);
local simpp = el(_vv,1,1)^0.5;
local limpp   = `impp' - `tt'*`simpp';
local uimpp   = `impp' + `tt'*`simpp';

};

};

if ("`type'"=="prop"){;

if ("`dci'"=="no"){;
local impp    = `snumi'/`shsy'; 
};

if ("`dci'"=="yes"){;
qui svy: ratio `numi'/`hsy';
matrix _aa=e(b);
local impp = el(_aa,1,1);
cap matrix drop _vv;
matrix _vv=e(V);
local simpp = el(_vv,1,1)^0.5;
local limpp   = `impp' - `tt'*`simpp';
local uimpp   = `impp' + `tt'*`simpp';
};

};
};

if ("`dci'"=="no") qui replace `vimpp'=`impp'*`ampl' in `j';
if ("`dci'"=="yes") {;
 qui replace `_limpp'=`limpp'*`ampl' in `j';
 qui replace `_uimpp'=`uimpp'*`ampl' in `j';
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





capture program drop itargetg;
program define itargetg, rclass;
version 9.2;
syntax varlist(min=1)[,  
HSize(varname)  hgroup(varname)  ALpha(real 0) PLINE(real 10000)
IMPON(string)
cnor(string)
DEC(int 9)
DSTE(int 1)
type(string)  CONSTAM(real 1) PROP(real 1) LRES(int 0) SRES(string) DCI(string) LEVEL(real 95) CONF(string)
DIF(string) MIN(string) MAX(string) DGRA(int 1) SGRA(string) EGRA(string) *];

_get_gropts , graphopts(`options') ;
	local options `"`s(graphopts)'"';

local dste = 1;

if ("`type'"=="")      local type="lump";
if ("`cnor'"=="")      local cnor="no";
if ("`dci'"=="" )      local dci ="no";
if ("`conf'"=="")      local conf="ts";
                       local ampl = `constam';
if ("`type'"=="prop")  local ampl = `prop'/100;  

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
tempvar Variable EST EST1 EST2 EST3 EST4 STE STE1 STE2 STE3 STE4;

qui gen `Variable'="";
qui gen `EST'=0;
qui gen `STE'=0;

qui gen `EST2'=0;
qui gen `STE2'=0;

qui gen `EST3'=0;
qui gen `STE3'=0;

qui gen `EST4'=0;
qui gen `STE4'=0;

local ll=10;

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


itargetg2 `1', hweight(`hweight') 
hsize(`hsize') hgroup(`hgroup')  ngroup(`kk') alpha(`alpha') pline(`pline')
type(`type') ampl(`ampl') impon(`impon') cnor(`cnor');


local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;
qui replace `EST'      = `r(pop)' in `k1';
qui replace `EST'      = `r(spop)' in `k2';

qui replace `EST2'      = `r(fgt)' in `k1';
qui replace `EST2'      = `r(sfgt)' in `k2';

qui replace `EST3'      = `r(impp)' in `k1';
qui replace `EST3'      = `r(simpp)' in `k2';

qui replace `EST4'      = `r(impg)' in `k1';
qui replace `EST4'      = `r(simpg)' in `k2';

local label`f'  : label (`hgroup') `kk';
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";
qui replace `Variable' = "`label`f''" in `k1';

local ll=max(`ll',length("`label`f''"));



};

};

local kk1 = `k2'+1;
local kk2 = `k2'+2;

itargetg2 `1', hweight(`hweight') 
hsize(`hsize')  alpha(`alpha') pline(`pline')
type(`type') ampl(`ampl') impon(`impon') cnor(`cnor');

qui replace `Variable' = "Population" in `kk1';
qui replace `EST'      = `r(pop)' in `kk1';
qui replace `EST'      = `r(spop)' in `kk2';

qui replace `EST2'      = `r(fgt)' in `kk1';
qui replace `EST2'      = `r(sfgt)' in `kk2';

qui replace `EST3'      = `r(impp)' in `kk1';
qui replace `EST3'      = `r(simpp)' in `kk2';

qui replace `EST4'      = `r(impg)' in `kk1';
qui replace `EST4'      = `r(simpg)' in `kk2';

/*****RESULTS*****/
                     local targetg = "Whole population";
if ("`hgroup'"~="")  local targetg = "Groups => `hgroup' ";

                       local scheme = "Lump-sum (constant)";
if ("`type'"~="lump")  local scheme = "Proportional       ";

if ("`hgroup'"~="") {;
       tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width |`ll'|16 16 16 16|;
	.`table'.strcolor . . yellow . . ;
	.`table'.numcolor yellow yellow . yellow yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f;
	di _n as text "{col 4} Targeting population groups and poverty";
       			    di as text     "{col 5}Targeting  groups  :  `targetg'";
                            di as text     "{col 5}Targeting  scheme  :  `scheme'";
                            di as text     "{col 5}Normalized by cost :  `cnor'";
       if ("`hsize'"!="")   di as text     "{col 5}Household size     :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight    :  `hweight'";
                            di as text     "{col 5}Parameter alpha    : "  %5.2f `alpha'       ;
     			          di as text     "{col 5}Poverty line       : "  %5.2f `pline'       ;		
	.`table'.sep, top;
	.`table'.titles "Group  " "Population  " "FGT index"  "Impact on "  "Impact on" ;
	.`table'.titles "       " "  Share    " "         "   "Group    "  "Population" ;
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor white yellow yellow yellow yellow ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green   green  green green ;
		  if (`dste'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i'] `EST'[`i']  `EST2'[`i'] `EST4'[`i'] `EST3'[`i'];
              	        
                };
  .`table'.sep, mid;
.`table'.numcolor white yellow yellow yellow yellow ;
.`table'.row `Variable'[`kk1'] `EST'[`kk1']  `EST2'[`kk1'] `EST4'[`kk1'] `EST3'[`kk1'];
if (`dste'==1){;
.`table'.numcolor white green   green  green green ;
.`table'.row `Variable'[`kk2'] `EST'[`kk2']  `EST2'[`kk2'] `EST4'[`kk2'] `EST3'[`kk2'];
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
local tit1="Impact`tits' on FGT"; 
local tit2="Impact`tits' on FGT"; 
local tit3="";
local tit4="";

if ("`type'"=="nor") {;
local tit3="";
local tit4="";
};

if ("`dif'"=="c1") local tit0 = "Difference between";
local ftitle = "`tit0'"+"`tit3'"+" `tit1' Curve`tits' (alpha=`alpha')";
                   local ytitle = "`tit4'`tit2'(z, alpha = `alpha')";
if ("`dif'"=="c1") local ytitle = "Differences";
if ("`hsize'"  ~="")      replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")      replace `fw'=`fw'*`hweight';
};

qui count;
qui sum `1';
if ("`min'"  =="")      local min =`r(min)';
if ("`max'"  =="")      local max =`r(max)';
if ("`type'"  =="")     local type ="yes";
if (r(N)<101) qui set obs 101;


local color1 blue;
local color2 red;
local color3 green;
local color4 yellow;
local color5 orange;
local color6 pink;


if ("`hgroup'"~="") {;

forvalues k = 1/$indica {;

                                     local _cory  = "`_cory'" + " _cory`k'"; 
if ("`dci'"=="yes" & "`conf'"=="ts") local mcmd  = "`mcmd'" + "(rarea  _coryl`k'  _coryu`k' _corx, fcolor(`color`k''%14 lcolor(none) ) lcolor(white%0)  graphregion(fcolor(white) margin(medlarge)) ) ";

local f=`k';

local kk = gn1[`k'];
local k1 = gn1[1];
local label`f'  : label (`hgroup') `kk';
local labelg1   : label (`hgroup') `k1';
if ( "`label1'" == "")   local labelg1    = "Group: `k1'";
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";
local titd="Impact on FGT";
if ("`dif'"=="c1") local label`f'= "`titd'_`label`f'' - `titd'_`labelg1'";

gitargetg2 `1', hweight(`hweight') 
hsize(`hsize') hgroup(`hgroup')  ngroup(`kk') alpha(`alpha') min(`min') max(`max')
type(`type') ampl(`ampl') cnor(`cnor') dci(`dci') level(`level') conf(`conf') label(`label`f'');


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

};

if ("`hgroup'"=="") {;



                                    local _cory  = "`_cory'" + " _cory";
if ("`dci'"=="yes" & "`conf'"=="ts") local mcmd  = "`mcmd'" + "(rarea  _coryl  _coryu _corx) ";


if ( "`label1'" == "")   local labelg1    = "Population";
local titd="Impact on FGT";


gitargetg2 `1', hweight(`hweight') 
hsize(`hsize')  alpha(`alpha') min(`min') max(`max')
type(`type') ampl(`ampl') cnor(`cnor') dci(`dci') level(`level') conf(`conf') label(population);


svmat float _xx;
cap matrix drop _xx;
if ("`dci'"=="no") rename _xx1 _cory;

if ("`dci'"=="yes"){;

if ("`conf'"=="ts") {;
 rename _xx1 _coryl;
 rename _xx2 _coryu;
};

if ("`conf'"=="lb"){;
rename _xx1 _cory;
};

if ("`conf'"=="ub"){;
 rename _xx2 _cory;
};

};



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
legend(size(medsmall))
 xlabel(, nogrid)
 ylabel(, nogrid)
 ylabel(, labsize(small))
plotregion(margin(zero))
legend(size(medsmall))
graphregion(fcolor(white) margin(medlarge))
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
/*`options'*/
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
graphregion(fcolor(white) margin(medlarge))
title(`ftitle')
subtitle("`typeb' bound(`level'%)")
ytitle(`ytitle')
xtitle(Poverty line (z)) 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
plotregion(margin(zero))
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

