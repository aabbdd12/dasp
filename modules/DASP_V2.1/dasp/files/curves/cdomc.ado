/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.1)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universite Laval , Quebec, Canada                                     */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : cdomc                                                     */
/*************************************************************************/




#delim ;



capture program drop cdomcc2;
program define cdomcc2, rclass;
version 9.2;
syntax varlist(min=1)[,  HWEIGHT(string) HSize(string) HGroup(varname) NGroup(int 1) prc(real 100) COMPonent(string) ALpha(real 1) PLINE(real 10000)
cnor(string)
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

local prc = `prc'/100;


if ("`hgroup'"~="")                           qui replace `hs'  =`hs'*(`hgroup'==`ngroup');
if ("`cnor'" ~= "yes" & "`component'"~="")    qui replace `hs'  =`hs'*(`component'!=0);

if ("`hweight'"=="")   {;
tempvar hweight;
gen `hweight' = 1;
};


local al1 = `alpha' - 1;

gen `hsy'=`hs'*`component';

cap drop if `1'>=.;

cap drop `num' `numi';
tempvar   num denum numi;
qui gen    `num' = 0;
qui gen    `numi'= 0;
				    
if (`alpha' == 0 )                        qui replace    `num' = `hs'*(`pline'> `1');
if (`alpha' ~= 0 & `pline' ~=0)           qui replace    `num' = `hs'*((`pline'-`1')/`pline')^`alpha'  if (`pline'>`1');

if ("`cnor'" ~= "yes") {;

if (`alpha' > 0) {;
if (`al1'   == 0 & `pline' ~=0)              qui replace    `numi' = `alpha'/`pline'*`hs'*(`pline'> `1');
if (`alpha' ~= 0 & `pline' ~=0)            qui replace    `numi' = `alpha'/`pline'*`hs'*((`pline'-`1')/`pline')^`al1'*`component'  if (`pline'>`1');
							 
};
};

if ("`cnor'" == "yes") {;
if (`alpha' > 0) {;
if (`al1' == 0 & `pline' ~=0)             qui replace    `numi' = `alpha'/`pline'*`hs'*(`pline'> `1');
if (`al1' ~= 0 & `pline' ~=0 )            qui replace    `numi' = `alpha'/`pline'*`hs'*((`pline'-`1')/`pline')^`al1'  if (`pline'>`1');
						      qui replace    `numi' = `numi'*`component';
};

};

if (`alpha' == 0) {;
tempvar fw;
qui gen `fw' =`hs'*`hweight';
qui su `1' [aw=`fw'], detail;           
local tmp = (`r(p75)'-`r(p25)')/1.34;                          
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
local h   = 0.9*`tmp'*_N^(-1.0/5.0);  
qui replace `numi' =  `hs' *exp(-0.5* ( ((`pline'-`1')/`h')^2  )  )/( `h'* sqrt(2*c(pi)));  
qui replace `numi' = `numi'*`component';
};



qui sum `numi'; local snumi    = `r(sum)';
qui sum `hs';   local shs      = `r(sum)';
qui sum `hsr';  local shsr     = `r(sum)';
qui sum `hsy';  local shsy     = `r(sum)';


qui svy: ratio `hs'/`hsr'; 
cap drop matrix _aa;
matrix _aa=e(b);
local pop = el(_aa,1,1);
return scalar pop    = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local spop = el(_vv,1,1)^0.5;
return scalar spop  = `spop';



qui svy: ratio `num'/`hs'; 
cap drop matrix _aa;
matrix _aa=e(b);
local fgt = el(_aa,1,1);
return scalar fgt    = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local sfgt = el(_vv,1,1)^0.5;
return scalar sfgt  = `sfgt';




if ("`cnor'"=="no"){;
qui svy: ratio `numi'/`hsr';
cap drop matrix _aa;
matrix _aa=e(b);
local impp = el(_aa,1,1);
return scalar impp    = `prc'*el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local simpp = `prc'*el(_vv,1,1)^0.5;
return scalar simpp  = `simpp';
};


if ("`cnor'"=="yes"){;

qui svy: ratio `numi'/`hsy';
cap drop matrix _aa;
matrix _aa=e(b);
local impp = el(_aa,1,1);
return scalar impp    = `prc'*el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local simpp = `prc'*el(_vv,1,1)^0.5;
return scalar simpp  = `simpp';
};




restore;
end;




capture program drop gcdomcc2;
program define gcdomcc2, rclass;
version 9.2;
syntax varlist(min=1)[,  HWEIGHT(string) HSize(string) HGroup(varname) NGroup(int 1) prc(real 100) COMPonent(string) ALpha(real 1) 
MIN(real 0) MAX(real 10000)
cnor(string)
type(string)
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

local prc = `prc'/100;

if ("`hgroup'"~="")    qui replace `hs'  =`hs'*(`hgroup'==`ngroup');

if ("`hweight'"=="")   {;
tempvar hweight;
gen `hweight' = 1;
};

gen `hsy'=`hs'*`component';

cap drop if `1'>=.;

cap drop `num' `denum';
tempvar num denum numi;
qui gen    `num' = 0;
qui gen    `numi'= 0;


local al1 = `alpha' - 1;

if ("`cnor'" ~= "yes" & "`component'"~="")    qui replace `hs'  =`hs'*(`component'!=0);

if ("`hweight'"=="")   {;
tempvar hweight;
gen `hweight' = 1;
};


if ("`dci'"=="no") {;
qui replace `hs' = `hs'*`hweight';
qui replace `hsr'=`hsr'*`hweight';
qui replace `hsy'=`hsy'*`hweight';
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

dis "Estimation for component: `label'";

forvalues j=1/101 {;

qui replace `ra'=`min'+(`j'-1)*`pas' in `j';
local pline = `min'+(`j'-1)*`pas';


cap drop `num' `numi';
tempvar   num denum numi;
qui gen    `num' = 0;
qui gen    `numi'= 0;
				    
if (`alpha' == 0 )                        qui replace    `num' = `hs'*(`pline'> `1');
if (`alpha' ~= 0 & `pline' ~=0)           qui replace    `num' = `hs'*((`pline'-`1')/`pline')^`alpha'  if (`pline'>`1');

if ("`cnor'" ~= "yes") {;

if (`alpha' > 0) {;
if (`al1'   == 0 & `pline' ~=0)              qui replace    `numi' = `alpha'/`pline'*`hs'*(`pline'> `1');
if (`alpha' ~= 0 & `pline' ~=0)            qui replace    `numi' = `alpha'/`pline'*`hs'*((`pline'-`1')/`pline')^`al1'*`component'  if (`pline'>`1');
							 
};
};

if ("`cnor'" == "yes") {;
if (`alpha' > 0) {;
if (`al1' == 0 & `pline' ~=0)             qui replace    `numi' = `alpha'/`pline'*`hs'*(`pline'> `1');
if (`al1' ~= 0 & `pline' ~=0 )            qui replace    `numi' = `alpha'/`pline'*`hs'*((`pline'-`1')/`pline')^`al1'  if (`pline'>`1');
						      qui replace    `numi' = `numi'*`component';
};

};

if (`alpha' == 0) {;
tempvar fw;
qui gen `fw' =`hs'*`hweight';
qui su `1' [aw=`fw'], detail;           
local tmp = (`r(p75)'-`r(p25)')/1.34;                          
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
local h   = 0.9*`tmp'*_N^(-1.0/5.0);  
qui replace `numi' =  `hs' *exp(-0.5* ( ((`pline'-`1')/`h')^2  )  )/( `h'* sqrt(2*c(pi)));  
qui replace `numi' = `numi'*`component';
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
cap drop matrix _vv;
matrix _vv=e(V);
local simpp = el(_vv,1,1)^0.5;
local limpp   = `impp' - `tt'*`simpp';
local uimpp   = `impp' + `tt'*`simpp';

};

};


if ("`cnor'"=="yes"){;

if ("`dci'"=="no"){;
local impp    = `snumi'/`shsy'; 
};

if ("`dci'"=="yes"){;
qui svy: ratio `numi'/`hsy';
matrix _aa=e(b);
local impp = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local simpp = el(_vv,1,1)^0.5;
local limpp   = `impp' - `tt'*`simpp';
local uimpp   = `impp' + `tt'*`simpp';
};

};

if ("`dci'"=="no") qui replace `vimpp'=`prc'*`impp' in `j';
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





capture program drop cdomc;
program define cdomc, rclass;
version 9.2;
syntax varlist(min=1)[,  
HSize(varname)  HGroup(varname)  inc(varname)  ORDER(real 1) PLINE(real 10000)
PRC(real 1)
cnor(string)
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

if ("`prc'"=="")     local prc=1;
	
if ("`hgroup'"!="") {;
preserve;
tokenize `varlist';
local com1="`1'";
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
cdomcc2 `inc', hweight(`hweight')  hsize(`hsize')  hgroup(`hgroup') ngroup(`kk') component(`com1') prc(`prc')  
 alpha(`alpha') pline(`pline') cnor(`cnor');
qui replace `EST'      = `r(pop)' in `k1';
qui replace `EST'      = `r(spop)' in `k2';

qui replace `EST2'      = `r(fgt)' in `k1';
qui replace `EST2'      = `r(sfgt)' in `k2';

qui replace `EST3'      = `r(impp)' in `k1';
qui replace `EST3'      = `r(simpp)' in `k2';

qui replace `Variable' = "`label`f''" in `k1';
local ll=max(`ll',length("`label`f''"));
};

if ("`hgroup'"=="") {;
qui replace `Variable' = "``k''" in `k1';
cdomcc2 `inc', hweight(`hweight') 
hsize(`hsize')  component(``k'') prc(`prc')   alpha(`alpha') pline(`pline') cnor(`cnor');


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

if ("`hgroup'"!="") {;
       tempname table;
	.`table'  = ._tab.new, col(4);
	.`table'.width |`ll'|16 16 16|;
	.`table'.strcolor . . yellow .  ;
	.`table'.numcolor yellow yellow . yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f;
                            di as text     "{col 4}Normalized by cost :  `cnor'";
       if ("`hsize'"!="")   di as text     "{col 4}Household size     :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 4}Sampling weight    :  `hweight'";
       if ("`hgroup'"!="") di as text      "{col 4}Group variable     :  `hgroup'";
	   
                            di as text     "{col 4}Parameter alpha    : "  %5.2f `alpha'       ;
     			          di as text       "{col 4}Poverty line       : "  %5.2f `pline'       ;
						   di as text      "{col 4}Component          : "  %5.2f "`com1'"       ;	  						  		
	.`table'.sep, top;
	.`table'.titles "Groups)  " "Population  " "FGT index"  "CD: Impact on "   ;
	.`table'.titles "       " "  Share    " "         "           "Population   "   ;
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor white yellow yellow yellow  ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green   green  green  ;
		  if (`dste'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i'] `EST'[`i']  `EST2'[`i'] `EST3'[`i'];
              	        
                };
  .`table'.sep,bot;

};



if ("`hgroup'"=="") {;

  tempname table;
	.`table'  = ._tab.new, col(2);
	.`table'.width |16 |16|;
	                         di as text     "{col 4}Normalized by cost :  `cnor'";
       if ("`hsize'"!="")   di as text     "{col 4}Household size     :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 4}Sampling weight    :  `hweight'";
 
                            di as text     "{col 4}Parameter alpha    : "  %5.2f `alpha'       ;
     			          di as text       "{col 4}Poverty line       : "  %5.2f `pline'       ;
						  
	.`table'.strcolor . .  ;
	.`table'.numcolor yellow yellow  ;
	.`table'.numfmt %16.`dec'f  %16.`dec'f  ;
	di _n as text "{col 1} targeting population groups and poverty";
         
	.`table'.sep, top;
	.`table'.titles  "Component(s)"  " CD: Impact on "   ;
	.`table'.titles  "         "   "Population    "  ;
	.`table'.numcolor yellow yellow  ;
	.`table'.sep,mid;
     forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor white  yellow  ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green  ;
		  if (`dste'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i']  `EST3'[`i'];
              	        
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
local tit1="Consumption Dominance"; 
local tit2="CD"; 
local tit3="";
local tit4="";

if ("`type'"=="nor") {;
local tit3="";
local tit4="Normalised ";
};


local ftitle = "Consunmption Dominance Curve`tits' (order = `order')";
                   local ytitle = "`tit4'`tit2'(z, s = `order')";
if ("`dif'"=="c1") local ytitle = "Differences";
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

gcdomcc2 `inc', hweight(`hweight') hgroup(`hgroup') ngroup(`kk') prc(`prc') 
hsize(`hsize') component(`com1') alpha(`alpha') min(`min') max(`max')
cnor(`cnor') dci(`dci') level(`level') conf(`conf') label(`label`f'');

};



if ("`hgroup'"=="") {;
if ( "`label1'" == "")   local labelg1    = "`1'";
if ( "`label`f''" == "") local label`f'   = "``k''";
local titd="Impact on FGT";
if ("`dif'"=="c1") local label`f'= "`titd'_`label`f'' - `titd'_`labelg1'";

gcdomcc2 `inc', hweight(`hweight') component(``k'') prc(`prc') 
hsize(`hsize')  alpha(`alpha') min(`min') max(`max')
cnor(`cnor') dci(`dci') level(`level') conf(`conf');

dis "KO HERE";

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
subtitle("Confidence interval (`level'%)")
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



