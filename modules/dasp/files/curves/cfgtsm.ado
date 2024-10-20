/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Universite Laval, Quebec, Canada                                       */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : cfgtsm                                                      */
/*************************************************************************/

#delim ;


capture program drop fgtsm2;
program define fgtsm2, rclass;
version 9.2;
args hs yyy al type min max conf level;
preserve;
cap drop if `yyy'>=.;
tempvar ra ga est std lb ub;

gen `est'=0; gen `std'=0; gen `lb'=0; gen `ub'=0;
gen `ra'=0;
local pas = (`max'-`min')/100;
if (_N<101) qui set obs 101;
qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');

forvalues j=1/101 {;
qui replace `ra'=`min'+(`j'-1)*`pas' in `j';
cap drop `ga';
gen `ga' = 0;
if (`al'== 0)                     qui replace `ga' = `hs'*(`ra'[`j']>`yyy');
if (`al' ~= 0  & "`type'"=="nor") qui replace `ga' = `hs'*((`ra'[`j']-`yyy')/`ra'[`j'])^`al' if (`ra'[`j']>`yyy');
if (`al' ~= 0  & "`type'"!="nor") qui replace `ga' = `hs'*((`ra'[`j']-`yyy'))^`al'           if (`ra'[`j']>`yyy');



qui svy: ratio `ga'/`hs';
cap drop matrix _aa;
matrix _aa=e(b);
local estim = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local stdev = el(_vv,1,1)^0.5;
   
qui replace  `est'  =`estim'              in `j';
qui replace  `std'  = `stdev'             in `j';
qui replace  `lb'   = `est' - `tt'*`std'  in `j';
qui replace  `ub'   = `est' + `tt'*`std'  in `j';

if (`j'!=101)  dis "." ,  _continue;
if (`j'/10==round(`j'/10)) dis " "  %4.2f `j' " %";


};
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat `est' `std' `lb' `ub', matrix (_xx);
restore;
end;


capture program drop cfgtsm;
program define cfgtsm, rclass;
version 9.2;
syntax varlist [,  
HSize(varname) HGroup(varname)   
type(string) 
ALpha(real 0)  
LRES(int 0) SRES(string) 
MIN(real 0) MAX(real 10000)
CONF(string) LEVEL(real 95)
DGRA(int 1) 
SGRA(string) EGRA(string) *];

set more off;
if ("`type'"=="")  local type="nor";
if ("`conf'"=="")  local conf="ts";

  _get_gropts , graphopts(`options') ;
        local options `"`s(graphopts)'"';



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




if (`max' <= `min') {;
 di as err "max should be greater than min"; exit;
};



qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

tempvar hs;
gen `hs'=1;
if ("`hsize'"    ~="")      qui replace `hs'=`hsize';


if ("`min'"  =="")          local min =0;
if ("`max'"  =="")          local max =1;
if ("`type'"  =="")         local type ="yes";
qui count;
if (r(N)<101) qui set obs 101;

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

tempvar fw;
gen `fw'=`hs';
if (`"`hweight'"'~="") qui replace `fw'=`fw'*`hweight';


dis "ESTIMATION IN PROGRESS";

qui count;
if (r(N)<101) qui set obs 101;

forvalues k = 1/$indica {;
                                     local _cory  = "`_cory'" + " _cory`k'";
if ("`conf'"=="ts") local mcmd  = "`mcmd'" + "(rarea  _coryl`k'  _coryu`k' _corx) ";

if ("`hgroup'"=="") {;
local label`k'   = "``k''";
dis "Computation for variable -> ``k''"; 
tempvar hs;
gen `hs'=1;
if ("`hsize'"   ~="")      replace `hs'=`hsize';
if ("`hgroup'"  ~="")      replace `hs'=`hs'*(`hgroup'==`ngroup');
fgtsm2 `hs' ``k'' `alpha' `type' `min' `max' `conf' `level';
};


if ("`hgroup'"!="") {;
local kk = gn1[`k'];
local label`k'   = "Group: `kk'";
local labelv  : label (`hgroup') `kk';
if (length("`labelv'")>2) local label`k'="`labelv'";
dis "Computation for the group -> `label`k''"; 
tempvar  hst; 
qui gen `hst'=`hs'*(`hgroup'==`kk');
fgtsm2 `hst' `1' `alpha' `type' `min' `max' `conf' `level';
};

svmat float _xx;
if ("`conf'"=="ts") {;
 rename _xx3 _coryl`k';
 rename _xx4 _coryu`k';
};

if ("`conf'"=="lb"){;
rename _xx3 _cory`k';
};

if ("`conf'"=="ub"){;
 rename _xx4 _cory`k';
};

cap drop _xx*;


};

dis "END: WAIT FOR THE GRAPH...";

qui keep in 1/101;
gen _nl=0;
local pas = (`max'-`min')/100;
local m5 = (`max'-`min')/5;
local step=(`max'-`min')/100;
gen _corx = `min'+(_n-1)*`step';



if( `lres' == 1) {;
set more off;
list _corx _cory*;
};

                      local titcur = "FGT";
                      local typeb =  "Lower";
if ("`conf'"=="ub")   local typeb =  "Upper";

if (`dgra'!=0) {;

if ("`conf'"=="ts"){;
twoway `mcmd' , 
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
title("`titcur' Curve(s)")
ytitle("")
xtitle("Percentiles")
subtitle("Confidence interval(`level'%)")
xtitle("Poverty line") 
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
title("`titcur' Curve(s)")
ytitle("")
subtitle("`typeb' bound(`level'%)")
xtitle("Poverty line") 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
plotregion(margin(zero))
graphregion(margin(medlarge))
legend(size(medsmall))
`options'
;
};

if("`conf'"=="ub") {;
twoway 
(
line  `_cory' _corx, 
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
title("`titcur' Curve(s)")
subtitle("`typeb' bound(`level'%)")
xtitle("Percentiles") 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max')
plotregion(margin(zero))
graphregion(margin(medlarge))
legend(size(medsmall))
`dif_line_opts'
`options'
)
;
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





end;







