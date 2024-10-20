

#delimit ;
capture program drop mbasicgini2;
program define mbasicgini2, eclass;  
version 15;   
syntax varlist (min=1 max=2) [, HSize1(varname) RANK1(varname)  HSize2(varname) RANK2(varname)  HWeight(varname) HGroup(varname) conf(real 5)  LEVEL(real 95) XRNAMES(string) TYPE(string)];
preserve;
tokenize `varlist';
_nargs   `varlist';
version 15 ;
if "`hsize'" == "" {;
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
if ("`hsize1'"!="")   qui drop if `hsize1'>=.;
if ("`hweight1'"!="") qui drop if `hweigh1t'>=.;

                     qui drop if `2'>=. ;
if ("`hsize2'"!="")   qui drop if `hsize2'>=.;
if ("`hweight2'"!="") qui drop if `hweight2'>=.;


tempvar  hs1 sw1 fw1 ;
qui gen double `sw1'=1.0;
qui gen double `hs1'=1.0;
if ("`hweight1'"!="")   qui replace `sw1'=`hweight1';
if ("`hsize1'"!="")     qui replace `hs1' = `hsize1';

gen double `fw1'=`hs1'*`sw1';

tempvar  hs2 sw2 fw2 ;
qui gen double `sw2'=1.0;
qui gen double `hs2'=1.0;
if ("`hweight2'"!="")   qui replace `sw2'=`hweight2';
if ("`hsize2'"!="")     qui replace `hs2' = `hsize2';

gen double `fw2'=`hs2'*`sw2';


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

if ("`rank`i''"=="") sort `hgroup' ``i''      , stable;
if ("`rank`i''"!="") sort `hgroup' `rank`i''  , stable;


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
qui replace `smw'  =sum(`fw`i'')        if `hgroup' == `x';
qui replace `smwy' =sum(``i''*`fw`i'')  if `hgroup' == `x';
};



foreach x of local mygr { ;
local mu`x'  =`smwy'[`EN`x'']/`smw'[`EN`x''];
local suma`x'=`smw'[`EN`x''];
qui replace `l1smwy'=`smwy'[_n-1]   if `hgroup' == `x';
qui replace `l1smwy' = 0 in `FN`x'' if `hgroup' == `x'; 
qui replace `ca'=`mu`x''+``i''*((1.0/`smw'[`EN`x''])*(2.0*`smw'-`fw`i'')-1.0) - (1.0/`smw'[`EN`x''])*(2.0*`l1smwy'+`fw`i''*``i'') if `hgroup' == `x'; 
qui sum `ca' [aw=`fw`i'']  if `hgroup' == `x', meanonly; 
local gini_`x'=`r(mean)'/(2.0*`mu`x'');
if  ("`type'" == "abs") local gini_`x'=`r(mean)'/(2.0);
local xi`x' = `r(mean)';
};

tempvar vec_a_`i' vec_b_`i' theta v1 v2 sv1 sv2;

gen `v1'=`fw`i''*``i'';
gen `v2'=`fw`i'';

gen `sv1'=0;
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
qui replace `vfx' = sum(`fw`i''*``i'')  if `hgroup' == `x';
local fx_`x' = `vfx'[`EN`x'']/`suma`x''; 
qui replace    `theta'=(`v1'-`v2'*``i'')*(2.0/`suma`x'')  if `hgroup' == `x';
qui replace `vec_a_`i'' = `hs`i''*((1.0)*`ca'+(``i''-`fx_`x'')+`theta'-(1.0)*(`xi`x'')) if `hgroup' == `x';
};

qui  replace  `vec_b_`i'' =  2*`hs`i''*``i'';

if  ("`type'" == "abs") qui replace `vec_b_`i''  =  2*`hs`i'';
qui  svy: ratio (`vec_a_`i''/`vec_b_`i'') , over(`hgroup'); 

if (`i' == 1) {;
forvalues v=1/`ngr' {;
matrix `aa'[1,`v'] = el(e(b), 1 , `v');
matrix `aa'[2,`v'] = el(e(V), `v' , `v')^0.5;
};
matrix __aa_1 = `aa';
};
if (`i' == 2) {;
forvalues v=1/`ngr' {;
matrix `aa'[1,`v'] = el(e(b), 1 , `v');
matrix `aa'[2,`v'] = el(e(V), `v' , `v')^0.5;
};
matrix __aa_2 = `aa';
matrix __ms = __aa_1\__aa_2;
};

if (`i'== 2) {;
local v = 1;
 foreach x of local mygr { ;
 qui svy:mean `vec_a_1' `vec_b_1' `vec_a_2' `vec_b_2' if (`hgroup'==`x'); 
	qui nlcom (_b[`vec_a_2']/_b[`vec_b_2']) - (_b[`vec_a_1']/_b[`vec_b_1'])  ;
	matrix `aa'[1,`v'] = el(r(b), 1 , 1);
    matrix `aa'[2,`v'] = el(r(V), 1 , 1)^0.5;
	local v=`v'+1;
 };
matrix __aa = `aa';
matrix __bb = `bb';
matrix __ms = __ms\__aa;
};



};

ereturn matrix mmss  = __ms   ;


cap matrix drop __aa;
cap matrix drop __bb;
cap matrix drop __ms;
*ereturn clear ;
end;    
