
#delimit ;
capture program drop mbasicgini;
program define mbasicgini, eclass;  
version 15;   
syntax varlist (min=1) [, HSize(varname) HWeight(varname) RANK(varname) HGroup(varname) conf(real 5)  LEVEL(real 95) XRNAMES(string) TYPE(string)];
preserve;
tokenize `varlist';
_nargs   `varlist';
version 15 ;
                    local popa = 0;
if "`hgroup'" == "" local popa = 1;


if ("`hsize'"=="") {;
tempvar hsize; qui g `hsize' = 1;
};

if "`hgroup'" == "" {;
tempvar hgroup; qui g `hgroup' = 1;
};


qui levelsof `hgroup', local(mygr);
local mystr `r(levels)';
local ngr `: word count `mystr'';
tempname aa bb cc dd ee ff aabb;
matrix `aa' =J($indica,`ngr',.) ;
matrix `bb' =J($indica,`ngr',.) ;
matrix `cc' =J($indica,`ngr',.) ;
matrix `dd' =J($indica,`ngr',.) ;
matrix `ee' =J($indica,`ngr',.) ;
matrix `ff' =J($indica,`ngr',.) ;

qui levelsof `hgroup', local(mygr);
local mystr `r(levels)';
local ngr `: word count `mystr'';
local i = 1;

                     qui drop if `1'>=. ;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;


tempvar  hs sw fw ;
qui gen double `sw'=1.0;
qui gen double `hs'=1.0;
if ("`hweight'"!="")   qui replace `sw'=`hweight';
if ("`hsize'"!="")     qui replace `hs' = `hsize';

gen double `fw'=`hs'*`sw';

local tpos = 0; 
foreach x of local mygr { ;
qui count  if `hgroup' == `x';
local  N`x' = `r(N)';
local  FN`x'  = `tpos' + 1;
local  FN2`x' = `tpos' + 2;
local  EN`x' = `tpos'+`r(N)';
local  tpos  = `tpos'+`r(N)';
/* dis `x' "   " `FN`x'' "   " `EN`x''  ; */
} ;

tempvar ngrroup;
gen `ngrroup' = `hgroup' ;

forvalues i = 1/$indica { ;
if ("`rank'"=="") sort `hgroup' ``i''   , stable;
if ("`rank'"!="") sort `hgroup' `rank'  , stable;


local list1 smw smwy l1smwy ca vec_a vec_b theta v1 v2 sv1 sv2 v1 v2 vfx theta; 
foreach name of local list1 {;
cap drop ``name'' ;
};
cap drop `smw';
cap drop `smwy';
cap drop `llsmwy';
cap drop `ca';
tempvar smw smwy l1smwy ca;
gen  double `smw'  =0;
gen  double `smwy' =0;
qui gen double `l1smwy'=0;
qui gen double  `ca'= 0;
//gen suma = 0;

foreach x of local mygr { ;
qui replace `smw'  =sum(`fw')        if `hgroup' == `x';
qui replace `smwy' =sum(``i''*`fw')  if `hgroup' == `x';
};



foreach x of local mygr { ;
local mu`x'  =`smwy'[`EN`x'']/`smw'[`EN`x''];
local suma`x'=`smw'[`EN`x''];
qui replace `l1smwy'=`smwy'[_n-1]   if `hgroup' == `x';
qui replace `l1smwy' = 0 in `FN`x'' if `hgroup' == `x'; 
qui replace `ca'=`mu`x''+``i''*((1.0/`smw'[`EN`x''])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[`EN`x''])*(2.0*`l1smwy'+`fw'*``i'') if `hgroup' == `x'; 
qui sum `ca' [aw=`fw']  if `hgroup' == `x', meanonly; 
local gini_`x'=`r(mean)'/(2.0*`mu`x'');
if  ("`type'" == "abs") local gini_`x'=`r(mean)'/(2.0);
local xi`x' = `r(mean)';
};

tempvar vec_a_`i' vec_b_`i' theta v1 v2 sv1 sv2;


gen `v1'=`fw'*``i'';
gen `v2'=`fw';

gen `sv1'= 0;
gen `sv2'= 0;

tempvar vfx ;
cap drop `vfx' ;
qui gen `vfx' =0;
cap drop `vec_a_`i'';
cap drop `vec_b_`i'';
cap drop `theta';
qui  gen `vec_a_`i'' = 0 ;
qui  gen `vec_b_`i'' = 0 ;
qui  gen `theta' = 0; 
foreach x of local mygr { ;
qui replace `sv1'=sum(`v1') if `hgroup' == `x';
qui replace `sv2'=sum(`v2') if `hgroup' == `x';

qui replace `v1'=`sv1'[`EN`x'']   in `FN`x''    if `hgroup' == `x';
qui replace `v2'=`sv2'[`EN`x'']   in `FN`x''    if `hgroup' == `x';     
qui replace `v1'=`sv1'[`EN`x'']-`sv1'[_n-1] in `FN2`x''/`EN`x'' if `hgroup' == `x';
qui replace `v2'=`sv2'[`EN`x'']-`sv2'[_n-1] in `FN2`x''/`EN`x'' if `hgroup' == `x';
qui replace `vfx' = sum(`fw'*``i'')  if `hgroup' == `x';
local fx_`x' = `vfx'[`EN`x'']/`suma`x''; 
qui replace    `theta'=(`v1'-`v2'*``i'')*(2.0/`suma`x'')  if `hgroup' == `x';
qui replace `vec_a_`i'' = `hs'*((1.0)*`ca'+(``i''-`fx_`x'')+`theta'-(1.0)*(`xi`x'')) if `hgroup' == `x';
};

qui  replace  `vec_b_`i'' =  2*`hs'*``i'';

if  ("`type'" == "abs") qui replace `vec_b_`i''  =  2*`hs';
qui  svy: ratio (`vec_a_`i''/`vec_b_`i'') , over(`hgroup'); 

forvalues v=1/`ngr' {;
matrix `aa'[`i',`v'] = el(e(b), 1 , `v');
matrix `bb'[`i',`v'] = el(e(V), `v' , `v')^0.5;
};
matrix __aa = `aa';
matrix __bb = `bb';
matrix __ms = __aa\__bb;
ereturn matrix mmss_``i'' = __ms  ;
};

matrix __aa = `aa';
matrix __bb = `bb';
matrix __ms = __aa\__bb;
if (`popa'==1) {;
matrix __ms = __aa,__bb;
matrix __ms = __ms';
};
ereturn matrix mmss = __ms  ;
cap matrix drop __aa;
cap matrix drop __bb;
cap matrix drop __ms;
*ereturn clear ;

end;    


