/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 1.4)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2008)          */
/* Université Laval, Quebec, Canada                                    */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : cfgts                                                       */
/*************************************************************************/

#delim ;
capture program drop _nargs;
program define _nargs, rclass;
version 9.2;
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

capture program drop fgts2;
program define fgts2, rclass;
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

capture program drop cfgts;
program define cfgts, rclass;
version 9.2;
syntax varlist(min=1)[,  HSize(varname) HGroup(varname) NGroup(int 1) ALpha(real 0) 
type(string)  LRES(int 0) SRES(string) MIN(string) MAX(string) DGRA(int 1) SGRA(string) EGRA(string) CONF(string)
LEVEL(real 95) *];


if ("`type'"=="")  local type="nor";
if ("`conf'"=="")  local conf="ts";

  _get_gropts , graphopts(`options') getallowed(conf_area_opts conf_line_opts dif_line_opts);
        local options `"`s(graphopts)'"';
        local conf_area_opts `"`s(conf_area_opts)'"';
        local conf_line_opts `"`s(conf_line_opts)'"';
        local dif_line_opts `"`s(dif_line_opts)'"';


tokenize `varlist';
_nargs   `varlist';
preserve;
qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local ftitle = "FGT Curve (alpha=`alpha')";
local ytitle = "FGT(z, alpha = `alpha')";

tempvar hs;
gen `hs'=1;
if ("`hsize'"   ~="")      replace `hs'=`hsize';
if ("`hgroup'"  ~="")      replace `hs'=`hs'*(`hgroup'==`ngroup');

qui count;
qui sum `1';
if ("`min'"  =="")      local min =`r(min)';
if ("`max'"  =="")      local max =`r(max)';
if ("`type'"  =="")     local type ="yes";
if (r(N)<101) qui set obs 101;
dis "ESTIMATION IN PROGRESS";
fgts2 `hs' `1' `alpha' `type' `min' `max' `conf' `level';
dis "END: WAIT FOR THE GRAPH...";
svmat float _xx;
cap matrix drop _xx;

rename _xx1 _est;
rename _xx2 _std;
rename _xx3 _lb;
rename _xx4 _ub;


qui keep in 1/101;
gen _pline=0;
gen _nl=0;
local pas = (`max'-`min')/100;
local m5 = (`max'-`min')/5;

forvalues j=1/101 {;
qui replace _pline=`min'+(`j'-1)*`pas' in `j';
};

                   local mylist = "_pline _est _std _lb _ub";
if("`conf'"=="lb") local mylist = "_pline _est _std _lb";
if("`conf'"=="ub") local mylist = "_pline _est _std _ub"; 

if( `lres' == 1) {;
set more off;
list `mylist';
};



if (`dgra'!=0) {;


if("`conf'"=="ts") {;
twoway 
(rarea _lb _ub _pline, 
sort blcolor(ltbluishgray) 
blcolor(gs14) 
bfcolor(gs14) 
legend(order(1 "Confidence Interval"))
`conf_area_opts'

) 
(line _est _pline,
sort 
lcolor(black) 
lpattern(solid) 
legend(order(1 "Confidence interval (`level' %)" 2 "Estimate"))
title("FGT curve (alpha = `alpha')")
xtitle("Poverty line (z)") 
plotregion(margin(zero))
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
`dif_line_opts'
`options'
)
; 
};



if("`conf'"=="lb") {;
twoway 
(
line  _est _pline, 
legend(
label(1 "Estimate")
label(2 "Lower bound of `level'% confidence interval")
)
sort clcolor(black) 
lpattern(solid)
title("FGT curve (alpha = `alpha')")
xtitle("Poverty line (z)") 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max')
plotregion(margin(zero))
`dif_line_opts'
`options'
)
(
line  _lb _pline, 
sort 
lcolor(black) 
lpattern(dash)
`conf_line_opts'
)
;
};


if("`conf'"=="ub") {;
twoway 
(
line  _est _pline, 
legend(
label(1 "Estimate")
label(2 "Upper bound of `level'% confidence interval")
)
clcolor(black) 
lpattern(solid)
title("FGT curve (alpha = `alpha')")
xtitle("Poverty line (z)") 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max')
plotregion(margin(zero))
graphregion(margin(medlarge))
legend(size(medsmall))
`dif_line_opts'
`options'
)
(
line  _ub _pline, 
sort 
lcolor(black) 
lpattern(dash)
`conf_line_opts'
)
;
};

};

if( "`sres'" ~= "") {;
keep `mylist';
save `"`sres'"', replace;
};

if( "`sgra'" ~= "") {;
graph save `"`sgra'"', replace;
};

if( "`egra'" ~= "") {;
graph export `"`egra'"', replace;
};


end;





