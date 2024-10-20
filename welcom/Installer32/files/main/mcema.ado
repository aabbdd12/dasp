


#delimit ;
cap program drop mcema;
program define mcema, rclas;
syntax varlist(min=1 max=1)[, 
income(varname)
price(varname)
vchange(varname)
INCPAR(varname)
HGROUP(varname)
indcon(string) 
indcat(string) 
PSW(string)
DEC(int  6)
DREG(int 0)
XFIL(string)
DGRA(int 0)   
INCINT(int 0) *
UM(int 0)
];
version 12;
set matsize 800;
_get_gropts , graphopts(`options') ;
	local goptions `"`s(graphopts)'"';	

tokenize `varlist' ;
/* Copying  the sampling weight */
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear;

/* The final weight         */
tempvar   sw;
qui gen `sw'=1;
if ("`hweight'"~="")        qui replace `sw'=`sw'*`hweight';

	
if ("`hgroup'"!="") {;
preserve;
capture {;

local lvgroup:value label `hgroup';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , clear;
qui count;
forvalues i=1/`r(N)' {;
local tem=value[`i'];
local grlab`tem' =  substr(label[`i'],1, 26);
};
};
};
restore;
preserve;
qui tabulate `hgroup', matrow(gn);
svmat int gn;
global indicag=r(r);
tokenize `varlist';
};


if ("`hgroup'"=="") {;
preserve;
tokenize `varlist';
};



if ("`hgroup'"!="") {;
forvalues i=1/$indicag {;
local gr = gn1[`i'];
local sgrlab`gr' = "`hgroup'_`gr'" ;
if "`grlab`gr''"  == "" local grlab`gr' = "`hgroup'_`gr'" ;
local tmps =  subinstr("`grlab`gr''", " ", "_", .);
if  "`tmps'"  ~= "" local grlab`gr' = "`tmps'" ;
};
};



if "`psw'" != "" local stp stepwise, pr(`psw') lockterm1: ;

tempvar elap;
gen `elap'  = 0;
tempvar prop_ch;
qui gen `prop_ch' = 0;
tempvar prop_change;
qui gen `prop_change' = 0;
tempvar dif ;
qui g `dif' = 0 ;



#delimit ; 
if ("`indcat'"~="") {;
foreach var of varlist `indcat' {;
local posa = 1;
qui sum  `var';
local rmi = r(min);
local rma = r(max);
forvalues i= `rmi'/`rma' {;
qui count if `var' == `i';
if `r(N)' !=0 {;
cap drop `var'_`i';
qui gen `var'_`i' = `var' == `i';
local name "`var'_`i'";
local uname = proper("`name'");
if "`uname'" == "" { ;
local uname = proper("`var'_`i'");
local uname `uname';
};

lab var `var'_`i' "`uname'";

if `posa' != 1 local lnindcat `lnindcat' `var'_`i';
local posa = `posa'+1 ;
};
};
};
};



qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);


tokenize "`xfil'" ,  parse(".");
local tname `1'.xml;

if ( "`tjobs'"~="off" ) {;
if "`xfil'" ~= ""  { ;
tokenize "`xfil'" ,  parse(".");
local xfil `1'.xml ;
cap erase  `1'.xml ;
cap winexec   taskkill /IM excel.exe ;
};
};
estimates drop _all;

tokenize `varlist';
cap drop if `1' ==. ; 



                             local disprobit = "";
if   (`dreg' == 0)         local disprobit  = "qui" ;

qui replace `1' = 0 if `1'==. ;
cap drop  LnPrice ;
if ("`price'"!="") qui gen   LnPrice  = ln(`price');

if ("`income'" ~= "" ) {;
cap drop  LnHH_Inc ;
qui gen   LnHH_Inc  = ln(`income');
};

if ("`price'" ~= "" ) {;
cap drop  LnPrice ;
qui gen   LnPrice  = ln(`price');
qui replace LnPrice =0 if LnPrice ==. ;
};

if "`incpar'" ~= "" {;
qui tab `incpar';
local nigr = `r(r)';
if `nigr' == 10 local iname = "Decile" ;
if `nigr' ==  5 local iname = "Quintile" ;
if `nigr' ==  4 local iname = "Quartile" ;
if `nigr' != 10 & `nigr' != 5 & `nigr' != 4   local iname = "IncGr" ;

											 local grgname = "`iname'";
if `nigr' != 10 & `nigr' != 5 & `nigr' != 4  local grgname = "Income_Partition (`nigr')";
};



eststo clear;

if ("`price'" =="") {;
 if (`um'!=0) {;
cap drop `pr1';
cap drop `pr2';
tempvar pr1 pr2; 
qui  `stp' probit `1'  LnHH_Inc `lnindcat' `indcon' [pw=`sw'];
qui predict `pr1';
qui replace LnHH_Inc=log(exp(LnHH_Inc)+`vchange');
qui predict `pr2' ;
qui margins [aw=`sw'] , dydx(LnHH_Inc) atmeans ;
local mar1 = el(r(table),1,1) ;
qui sum `1' [aw=`sw'];
local elap1 = `mar1' / r(mean) ;
replace `elap' = `elap1'; 
qui sum `vchange'  [aw=`sw'], meanonly;      local mu1 = r(mean);
qui sum `income' [aw=`sw'],   meanonly;      local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 ; 

qui sum `pr1'  [aw=`sw'] , meanonly;      local mu1 = r(mean);
qui sum `pr2' [aw=`sw']  , meanonly;      local mu2 = r(mean);

qui replace `dif' = `mu2'-`mu1'            ; 
qui replace `prop_ch' = `dif'/`mu1'*100    ; 
};

if  ("`incpar'" =="") local subcom  LnHH_Inc;

`disprobit'  `stp' probit `1'  LnHH_Inc `lnindcat' `indcon' [pw=`sw'];

if ("`incpar'" =="" | `um'==0) {;
cap drop `pr1';
cap drop `pr2';
tempvar pr1 pr2; 
qui predict `pr1';
qui replace LnHH_Inc=log(exp(LnHH_Inc)+`vchange');
qui predict `pr2' ;
qui replace LnHH_Inc=log(`income');
qui replace LnHH_Inc=log(`income');
qui margins [aw=`sw'] , dydx(LnHH_Inc) atmeans ;
local mar1 = el(r(table),1,1) ;
qui sum `1' [aw=`sw'];
local elap1 = `mar1' / r(mean) ;
qui replace `elap' = `elap1'; 
qui sum `vchange'  [aw=`sw'], meanonly;      local mu1 = r(mean);
qui sum `income' [aw=`sw'], meanonly; local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 ; 

qui sum `pr1'  [aw=`sw'] , meanonly;      local mu1 = r(mean);
qui sum `pr2' [aw=`sw']  , meanonly;      local mu2 = r(mean);
qui replace `dif' = `mu2'-`mu1'            ; 
qui replace `prop_ch' = `dif'/`mu1'*100    ; 
 
};

eststo m1;
local est_m1 = _b[LnHH_Inc];
return scalar est = _b[LnHH_Inc];
return scalar se  = _se[LnHH_Inc];
estimates store mod1, title(Model 1) ;
local models `models' mod1 ; 



if ("`incpar'" ~="" ) {;

forvalues i=1/`nigr' {;
cap drop LnHH_Inc_0`i';
cap drop LnHH_Inc_`i';
if `i' <=  9  qui gen LnHH_Inc_0`i'     =  LnHH_Inc*(`i'==`incpar');
if `i' >= 10  qui gen LnHH_Inc_`i'      =  LnHH_Inc*(`i'==`incpar');
if `i' <=  9   local subcom `subcom'  LnHH_Inc_0`i';
if `i' >= 10   local subcom `subcom'  LnHH_Inc_`i';
};

 `disprobit'  `stp' probit `1'   `subcom' `lnindcat' `indcon' [pw=`sw'];
 eststo m2;
 estimates store mod2, title(Model 2) ;
 local models `models' mod2;
 if (`um'!=1) {;
 cap drop `pr1';
cap drop `pr2';
tempvar pr1 pr2; 
qui predict `pr1';
forvalues j=1/`nigr' {;
if `j' <=  9  qui replace LnHH_Inc_0`j'     =  log(exp(LnHH_Inc)+`vchange')*(`j'==`incpar');
if `j' >= 10  qui replace LnHH_Inc_`j'      =  log(exp(LnHH_Inc)+`vchange')*(`j'==`incpar');
};
cap drop `pr2';
qui predict `pr2';



forvalues j=1/`nigr' {;
if `j' <=  9  qui replace LnHH_Inc_0`j'     =  log(`income')*(`j'==`incpar');
if `j' >= 10  qui replace LnHH_Inc_`j'      =  log(`income')*(`j'==`incpar');
};
};


forvalues j=1/`nigr' {;
if `j' <=  9  local myvar LnHH_Inc_0`j';
if `j' >= 10  local myvar  LnHH_Inc_`j';   
cap qui margins [aw=`sw'], dydx(`myvar') atmeans ;
cap local mar`j' = el(r(table),1,1) ;
if "`mar`j''" == "" local mar`j' = 0;
qui sum `1' [aw=`sw'] if (`j'==`incpar') ;
local elap1 = `mar`j'' / r(mean)  ;
qui replace `elap' = `elap1' if (`j'==`incpar'); 

qui sum `vchange'  [aw=`sw'] if (`j'==`incpar'), meanonly;      local mu1 = r(mean);
qui sum `income' [aw=`sw'] if (`j'==`incpar'), meanonly; local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 if (`j'==`incpar') ; 

qui sum `pr1'  [aw=`sw'] if (`j'==`incpar'),  meanonly;      local mu1 = r(mean);
qui sum `pr2'  [aw=`sw']  if (`j'==`incpar'), meanonly;      local mu2 = r(mean);
qui replace `dif' = `mu2'-`mu1'            if (`j'==`incpar') ; 
qui replace `prop_ch' = `dif'/`mu1'*100    if (`j'==`incpar') ; 

};



};

if ("`incpar'" ~="" & "`hgroup'" ~="" ) {;
forvalues g=1/$indicag {;
local gr = gn1[`g'];
local lvgroup:value label `hgroup';
forvalues i=1/`nigr' {;
if `i' <=  9  qui gen LnHH_Inc_`iname'_0`i'_`sgrlab`gr'' =  LnHH_Inc*(`i'==`incpar')*(`gr'==`hgroup');
if `i' >= 10  qui gen LnHH_Inc_`iname'_`i'_`sgrlab`gr''  =  LnHH_Inc*(`i'==`incpar')*(`gr'==`hgroup');
if `i' <=  9   local inc_group `inc_group'  LnHH_Inc_`iname'_0`i'_`sgrlab`gr'';
if `i' >= 10   local inc_group `inc_group'  LnHH_Inc_`iname'_`i'_`sgrlab`gr'';
};
};
 

`disprobit'  `stp' probit `1' `inc_group'  `lnindcat' `indcon' [pw = `sw'] ;
 if (`um'!=1) {;
cap drop `pr1';
cap drop `pr2';
tempvar pr1 pr2; 
qui predict `pr1' ;
forvalues g=1/$indicag {;
local gr = gn1[`g'];
local lvgroup:value label `hgroup';
forvalues i=1/`nigr' {;
if `i' <  10 qui replace LnHH_Inc_`iname'_0`i'_`sgrlab`gr''=log(exp(LnHH_Inc_`iname'_0`i'_`sgrlab`gr'')+`vchange')*(`i'==`incpar')*(`gr'==`hgroup');
if `i' >= 10 qui replace LnHH_Inc_`iname'_`i'_`sgrlab`gr'' =log(exp(LnHH_Inc_`iname'_`i'_`sgrlab`gr'') +`vchange')*(`i'==`incpar')*(`gr'==`hgroup');
};
};

qui predict `pr2';
forvalues g=1/$indicag {;
local gr = gn1[`g'];
local lvgroup:value label `hgroup';
forvalues i=1/`nigr' {;
if `i' <  10 qui replace LnHH_Inc_`iname'_0`i'_`sgrlab`gr''=log(`income')*(`i'==`incpar')*(`gr'==`hgroup');
if `i' >= 10 qui replace LnHH_Inc_`iname'_`i'_`sgrlab`gr'' =log(`income')*(`i'==`incpar')*(`gr'==`hgroup');
};
};


forvalues g=1/$indicag {;
local gr = gn1[`g'];
forvalues j=1/`nigr' {;
if `j' <  10 local myvar LnHH_Inc_`iname'_0`j'_`sgrlab`gr'';
if `j' >= 10 local myvar LnHH_Inc_`iname'_`j'_`sgrlab`gr'' ;  
cap qui margins [aw=`sw'], dydx(`myvar') atmeans ;
cap local mar_`g'_`j' = el(r(table),1,1) ;
if "`mar_`g'_`j''" == ""  local mar_`g'_`j' = 0;
qui sum `1' [aw=`sw'] if (`j'==`incpar') & (`gr'==`hgroup') ;
local elap1 = `mar_`g'_`j'' / r(mean)  ;
qui replace `elap' = `elap1' if (`j'==`incpar') & (`gr'==`hgroup') ;

qui sum `vchange'  [aw=`sw'] if (`j'==`incpar') & (`gr'==`hgroup'), meanonly;      local mu1 = r(mean);
qui sum `income' [aw=`sw'] if (`j'==`incpar') & (`gr'==`hgroup'), meanonly; local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 if (`j'==`incpar') & (`gr'==`hgroup') ; 

qui sum `pr1'  [aw=`sw'] if (`j'==`incpar') & (`gr'==`hgroup'), meanonly;      local mu1 = r(mean);
qui sum `pr2' [aw=`sw']  if (`j'==`incpar') & (`gr'==`hgroup'), meanonly;      local mu2 = r(mean);
qui replace `dif' = `mu2'-`mu1'            if (`j'==`incpar') & (`gr'==`hgroup') ; 
qui replace `prop_ch' = `dif'/`mu1'*100    if (`j'==`incpar') & (`gr'==`hgroup') ; 
};
};

};
eststo m3;
estimates store mod3, title(Model 3) ;
local models `models' mod3 ;  
};
 

if ("`incpar'" =="" & "`hgroup'" ~="" ) {;
forvalues g=1/$indicag {;
local gr = gn1[`g'];
local lvgroup:value label `hgroup';
cap drop LnHH_Inc_`sgrlab`gr'';
qui gen LnHH_Inc_`sgrlab`gr'' =  LnHH_Inc*(`gr'==`hgroup');
local inc_group `inc_group'  LnHH_Inc_`sgrlab`gr'';
};
`disprobit'  `stp' probit `1' `inc_group'  `lnindcat' `indcon' [pw = `sw'] ;
eststo m3;
estimates store mod3, title(Model 3) ;
local models `models' mod3 ;
 if (`um'!=1) {;
cap drop `pr1';
cap drop `pr2';
tempvar pr1 pr2; 



qui predict `pr1' ;
forvalues g=1/$indicag {;
local gr = gn1[`g'];
qui replace LnHH_Inc_`sgrlab`gr''=log(exp(LnHH_Inc_`sgrlab`gr'')+`vchange')*(`g'==`hgroup');
};

qui predict `pr2';
forvalues g=1/$indicag {;
local gr = gn1[`g'];
qui replace LnHH_Inc_`sgrlab`gr''=log(exp(LnHH_Inc_`sgrlab`gr'')-`vchange')*(`g'==`hgroup');
};
};


forvalues g=1/$indicag {;
local gr = gn1[`g'];
local myvar LnHH_Inc_`sgrlab`gr'';
cap qui margins [aw=`sw'], dydx(`myvar') atmeans ;
cap local mar_`g' = el(r(table),1,1) ;
if "`mar_`g''" == "" local  local mar_`g' = 0;
qui sum `1' [aw=`sw'] if  (`gr'==`hgroup') ;
local elap1 = `mar_`g'' / r(mean)  ;
qui replace `elap' = `elap1' if  (`gr'==`hgroup') ;

qui sum `vchange'  [aw=`sw'] if (`gr'==`hgroup'), meanonly;      local mu1 = r(mean);
qui sum `income' [aw=`sw'] if (`gr'==`hgroup'), meanonly; local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 if (`gr'==`hgroup') ; 


qui sum `pr1'  [aw=`sw'] if (`gr'==`hgroup'), meanonly;      local mu1 = r(mean);
qui sum `pr2' [aw=`sw']  if (`gr'==`hgroup'), meanonly;      local mu2 = r(mean);
qui replace `dif' = `mu2'-`mu1'            if (`gr'==`hgroup') ; 
qui replace `prop_ch' = `dif'/`mu1'*100    if (`gr'==`hgroup') ; 


};

};

};








if ("`price'"!="") {;



if  ("`incpar'" =="") local subpri  LnPrice;
if  ("`income'" ~="") local subcom  LnHH_Inc;

 if (`um'!=0) {;
cap drop `pr1';
cap drop `pr2';
tempvar pr1 pr2; 
qui `stp' probit `1'  LnPrice `subcom' `lnindcat' `indcon'  [pw=`sw'];
local est_m1 = _b[LnPrice];
qui predict `pr1';
qui replace LnPrice=log(exp(LnPrice)+`vchange');
qui predict `pr2' ;
qui replace LnPrice=log(exp(LnPrice)-`vchange');

qui margins [aw=`sw'], dydx(LnPrice) atmeans ;
local mar1 = el(r(table),1,1) ;
qui sum `1' [aw=`sw'];
local elap1 = `mar1' / r(mean) ;
qui replace `elap' = `elap1'; 
qui sum `vchange'  [aw=`sw'], meanonly;      local mu1 = r(mean);
qui sum `price' [aw=`sw'], meanonly; local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 ; 

qui sum `pr1'  [aw=`sw'] , meanonly;      local mu1 = r(mean);
qui sum `pr2' [aw=`sw']  , meanonly;      local mu2 = r(mean);
qui replace `dif' = `mu2'-`mu1'            ; 
qui replace `prop_ch' = `dif'/`mu1'*100    ; 
 };




`disprobit' `stp' probit `1'  LnPrice `subcom' `lnindcat' `indcon'  [pw=`sw'];

if ("`incpar'" =="" | `um'==0) {;
cap drop `pr1';
cap drop `pr2';
tempvar pr1 pr2; 
qui predict `pr1';
qui replace LnPrice=log(exp(LnPrice)+`vchange');
qui predict `pr2' ;
qui replace LnPrice=log(exp(LnPrice)-`vchange');
qui margins [aw=`sw'], dydx(LnPrice) atmeans ;
local mar1 = el(r(table),1,1) ;
qui sum `1' [aw=`sw'];
local elap1 = `mar1' / r(mean) ;
qui replace `elap' = `elap1'; 
qui sum `vchange'  [aw=`sw'], meanonly;      local mu1 = r(mean);
qui sum `price' [aw=`sw'], meanonly; local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 ; 

qui sum `pr1'  [aw=`sw'] , meanonly;      local mu1 = r(mean);
qui sum `pr2'  [aw=`sw']  , meanonly;      local mu2 = r(mean);
qui replace `dif' = `mu2'-`mu1'            ; 
qui replace `prop_ch' = `dif'/`mu1'*100    ; 
};
eststo m1;
estimates store mod1, title(Model 1) ;
local models `models' mod1 ; 

if ("`incpar'" =="" ) {;
if (`um'!=1) {;
cap drop `pr1';
cap drop `pr2';
tempvar pr1 pr2; 
qui predict `pr1';
qui replace LnPrice=log(exp(LnPrice)+`vchange');
qui predict `pr2' ;
qui replace LnPrice=log(exp(LnPrice)-`vchange');
};
};




if ("`incpar'" ~="" ) {;
forvalues i=1/`nigr' {;
cap drop LnPrice_0`i';
cap drop LnPrice_`i';
if `i' <=  9  qui gen LnPrice_0`i'     =  LnPrice*(`i'==`incpar');
if `i' >= 10  qui gen LnPrice_`i'      =  LnPrice*(`i'==`incpar');
if `i' <=  9  qui replace LnPrice_0`i' = 0 if LnPrice_0`i'==. ;
if `i' >= 10  qui replace LnPrice_`i' = 0 if LnPrice_`i'==. ;
if `i' <=  9   local subpri `subpri'  LnPrice_0`i';
if `i' >= 10   local subpri `subpri'  LnPrice_`i';
};


`disprobit'  `stp' probit `1'   `subpri' `subcom' `lnindcat' `indcon' [pw=`sw'];
 eststo m2;
 estimates store mod2, title(Model 2) ;
 local models `models' mod2;
 
 
 
 
 if (`um'!=1) {;
cap drop `pr1';
cap drop `pr2';
tempvar pr1 pr2; 
qui predict `pr1';
forvalues j=1/`nigr' {;
if `j' <=  9  qui replace LnPrice_0`j'     =  log(exp(LnPrice)+`vchange')*(`j'==`incpar');
if `j' >= 10  qui replace LnPrice_`j'      =  log(exp(LnPrice)+`vchange')*(`j'==`incpar');
if `j' <=  9  qui replace LnPrice_0`j' = 0 if LnPrice_0`j'==.;
if `j' >= 10  qui replace LnPrice_`j' = 0 if LnPrice_`j'==.;
};
cap drop `pr2';
qui predict `pr2';
forvalues j=1/`nigr' {;
if `j' <=  9  qui replace LnPrice_0`j'     =  log(`price')*(`j'==`incpar');
if `j' >= 10  qui replace LnPrice_`j'      =  log(`price')*(`j'==`incpar');
};
};

forvalues j=1/`nigr' {;
if `j' <=  9  local myvar  LnPrice_0`j';
if `j' >= 10  local myvar   LnPrice_`j';   
cap qui margins [aw=`sw'], dydx(`myvar') atmeans ;
cap local mar`j' = el(r(table),1,1) ;
if "`mar`j''" == "" local mar`j' = 0;
qui sum `1' [aw=`sw'] if (`j'==`incpar') ;
local elap1 = `mar`j'' / r(mean)  ;
qui replace `elap' = `elap1' if (`j'==`incpar'); 

qui sum `vchange' [aw=`sw'] if (`j'==`incpar'), meanonly;      local mu1 = r(mean);
qui sum `price' [aw=`sw'] if (`j'==`incpar'), meanonly; local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 if (`j'==`incpar') ; 


qui sum `pr1'  [aw=`sw'] if (`j'==`incpar'), meanonly;      local mu1 = r(mean);
qui sum `pr2' [aw=`sw']  if (`j'==`incpar'), meanonly;      local mu2 = r(mean);
qui replace `dif' = `mu2'-`mu1'            if (`j'==`incpar') ; 
qui replace `prop_ch' = `dif'/`mu1'*100    if (`j'==`incpar') ; 


};

};




if ("`incpar'" ~="" & "`hgroup'" ~="" ) {;
forvalues g=1/$indicag {;
local gr = gn1[`g'];
local lvgroup:value label `hgroup';
forvalues i=1/`nigr' {;
if `i' <=  9  qui gen LnPrice_`iname'_0`i'_`sgrlab`gr'' =     LnPrice*(`i'==`incpar')*(`gr'==`hgroup');              
if `i' >= 10  qui gen LnPrice_`iname'_`i'_`sgrlab`gr''  =     LnPrice*(`i'==`incpar')*(`gr'==`hgroup');
if `i' <=  9  qui replace LnPrice_`iname'_0`i'_`sgrlab`gr'' = 0 if LnPrice_`iname'_0`i'_`sgrlab`gr''==.;
if `i' >= 10  qui replace LnPrice_`iname'_`i'_`sgrlab`gr'' = 0  if LnPrice_`iname'_`i'_`sgrlab`gr''==.;
  
if `i' <=  9   local pri_group `pri_group'  LnPrice_`iname'_0`i'_`sgrlab`gr'';
if `i' >= 10   local pri_group `pri_group'  LnPrice_`iname'_`i'_`sgrlab`gr'';
};
};





`disprobit'  `stp' probit `1' `pri_group'  `subcom' `lnindcat' `indcon' [pw = `sw'] ;
eststo m3;
estimates store mod3, title(Model 3) ;
local models `models' mod3 ; 
if (`um'!=1) {;
cap drop `pr1';
cap drop `pr2';
tempvar pr1 pr2; 
qui predict `pr1' ;
forvalues g=1/$indicag {;
local gr = gn1[`g'];
local lvgroup:value label `hgroup';
forvalues i=1/`nigr' {;
if `i' <  10 qui replace LnPrice_`iname'_0`i'_`sgrlab`gr''=log(exp(LnPrice_`iname'_0`i'_`sgrlab`gr'')+`vchange')*(`i'==`incpar')*(`gr'==`hgroup');
if `i' >= 10 qui replace LnPrice_`iname'_`i'_`sgrlab`gr'' =log(exp(LnPrice_`iname'_`i'_`sgrlab`gr'') +`vchange')*(`i'==`incpar')*(`gr'==`hgroup');
if `i' <  10  qui replace LnPrice_`iname'_0`i'_`sgrlab`gr'' = 0 if LnPrice_`iname'_0`i'_`sgrlab`gr'' ==.;
if `i' >= 10 qui replace LnPrice_`iname'_`i'_`sgrlab`gr'' = 0 if LnPrice_`iname'_`i'_`sgrlab`gr'' ==.;
};
};

qui predict `pr2';
forvalues g=1/$indicag {;
local gr = gn1[`g'];
local lvgroup:value label `hgroup';
forvalues i=1/`nigr' {;
if `i' <  10 qui replace LnPrice_`iname'_0`i'_`sgrlab`gr''=log(`price')*(`i'==`incpar')*(`gr'==`hgroup');
if `i' >= 10 qui replace LnPrice_`iname'_`i'_`sgrlab`gr'' =log(`price')*(`i'==`incpar')*(`gr'==`hgroup');
};
};
};


forvalues g=1/$indicag {;
local gr = gn1[`g'];
forvalues j=1/`nigr' {;
if `j' <  10 local myvar LnPrice_`iname'_0`j'_`sgrlab`gr'';
if `j' >= 10 local myvar LnPrice_`iname'_`j'_`sgrlab`gr'' ;  
cap qui margins [aw=`sw'], dydx(`myvar') atmeans ;
cap local mar_`g'_`j' = el(r(table),1,1) ;
if "`mar_`g'_`j''" == "" local mar_`g'_`j' = 0;
qui sum `1' [aw=`sw'] if (`j'==`incpar') & (`gr'==`hgroup') ;
local elap1 = `mar_`g'_`j'' / r(mean)  ;
qui replace `elap' = `elap1' if (`j'==`incpar') & (`gr'==`hgroup') ;

qui sum `vchange'[aw=`sw'] if (`j'==`incpar') & (`gr'==`hgroup'), meanonly;      local mu1 = r(mean);
qui sum `price'  [aw=`sw'] if (`j'==`incpar') & (`gr'==`hgroup'), meanonly; local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 if (`j'==`incpar') & (`gr'==`hgroup') ; 

qui sum `pr1'  [aw=`sw'] if (`j'==`incpar') & (`gr'==`hgroup'), meanonly;      local mu1 = r(mean);
qui sum `pr2' [aw=`sw']  if (`j'==`incpar') & (`gr'==`hgroup'), meanonly;      local mu2 = r(mean);
qui replace `dif' = `mu2'-`mu1'            if (`j'==`incpar') & (`gr'==`hgroup') ; 
qui replace `prop_ch' = `dif'/`mu1'*100    if (`j'==`incpar') & (`gr'==`hgroup') ; 

};
};


};


if ("`incpar'" =="" & "`hgroup'" ~="" ) {;
forvalues g=1/$indicag {;
local gr = gn1[`g'];
local lvgroup:value label `hgroup';
cap drop LnPrice_`sgrlab`gr'';
qui gen LnPrice_`sgrlab`gr'' =  LnPrice*(`gr'==`hgroup');
qui replace LnPrice_`sgrlab`gr''=0 if LnPrice_`sgrlab`gr''==.;
local pri_group `pri_group'  LnPrice_`sgrlab`gr'';
};



`disprobit'  `stp' probit `1' `pri_group'  `subcom' `lnindcat' `indcon' [pw = `sw'] ;
eststo m3;
estimates store mod3, title(Model 3) ;
local models `models' mod3 ; 

if (`um'!=0) {;
cap drop `pr1';
cap drop `pr2';
tempvar pr1 pr2; 

qui predict `pr1' ;
forvalues g=1/$indicag {;
local gr = gn1[`g'];
qui replace LnPrice_`sgrlab`gr''=log(exp(LnPrice_`sgrlab`gr'')+`vchange')*(`g'==`hgroup');
};

qui predict `pr2';
forvalues g=1/$indicag {;
local gr = gn1[`g'];
qui replace LnPrice_`sgrlab`gr''=log(exp(LnPrice_`sgrlab`gr'')-`vchange')*(`g'==`hgroup');
};
};

forvalues g=1/$indicag {;
local gr = gn1[`g'];
local myvar LnPrice_`sgrlab`gr'';
cap qui margins [aw=`sw'], dydx(`myvar') atmeans ;
cap local mar_`g' = el(r(table),1,1) ;
if "`mar_`g''" == "" local mar_`g' = 0;
qui sum `1' [aw=`sw'] if  (`gr'==`hgroup') ;
local elap1 = `mar_`g'' / r(mean)  ;
replace `elap' = `elap1' if  (`gr'==`hgroup') ;

qui sum `vchange'     [aw=`sw'] if (`gr'==`hgroup');      local mu1 = r(mean);
qui sum `price'       [aw=`sw'] if (`gr'==`hgroup');      local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 if (`gr'==`hgroup') ;

qui sum `pr1'  [aw=`sw'] if (`gr'==`hgroup'), meanonly;      local mu1 = r(mean);
qui sum `pr2'  [aw=`sw']  if (`gr'==`hgroup'), meanonly;      local mu2 = r(mean);
qui replace `dif' = `mu2'-`mu1'            if (`gr'==`hgroup') ; 
qui replace `prop_ch' = `dif'/`mu1'*100    if  (`gr'==`hgroup') ; 
};


};

};




dis _n " Table 01: Estimats of model(s):" ;
if ("`incpar'" =="" & "`hgroup'" =="")                             esttab m1, not pr2    mtitle("(Model 01)" ) nodepvars nonumbers b(`dec') varwidth(34) label;
if ("`incpar'" ~="" & "`hgroup'" =="")           esttab m1 m2, not pr2 mtitle("(Model 01)" "(Model 02)") nodepvars nonumbers b(`dec') varwidth(34) label;
if ("`incpar'" ~="" & "`hgroup'" ~="")            esttab m1 m2 m3, not pr2 mtitle("(Model 01)" "(Model 02)" "(Model 03)") nodepvars nonumbers b(`dec') varwidth(34) label;
if ("`incpar'" =="" & "`hgroup'" ~="")            esttab m1 m3, not pr2 mtitle("(Model 01)" "(Model 03)") nodepvars nonumbers b(`dec') varwidth(34) label;


if  ("`xfil'" ~= "") {;
xml_tab `models',  format(sclb0 ncrr3 nccr3) stats(N pr2) ///
save(`xfil') replace  ///
cblanks(2) cwidth(0 200, 3 4) ///
sheet(Results, color(2) nogridlines)  ///
lines(_cons 2 LAST_ROW 13 COL_NAMES 2 EST_NAMES 2) ///
title("Estimated Results");
};



cap matrix drop _cc; 
cap matrix drop bb1; 
cap matrix drop bb2; 
cap matrix drop bb3; 
cap matrix drop bb4; 
cap matrix drop aa; 
cap matrix drop gn; 



if  ("`incpar'"=="" & "`hgroup'" == "" ) {;
tempvar incpar;
cap drop `incpar';
qui gen `incpar' = 1;
};
/*
table `incpar' [aw=sw] , c( mean `1' mean `pr1' mean `pr2' mean `dif');
*/

if "`hgroup'"  == "" {;
tempvar hgroup ;
cap drop  `hgroup' 
g `hgroup' = 1; 
};

cap drop gn1;
cap drop _fgroup;
if "`incpar'"~="" {;
gen  _fgroup = `incpar';
local lvgroup:value label `incpar';
if "`lvgroup'" ~= "" lab val  _fgroup `lvgroup' ;
};
if ("`incpar'"=="") & ("`hgroup'" ~=  "") {;
gen  _fgroup = `hgroup';
local lvgroup:value label `hgroup';
if "`lvgroup'" ~= "" lab val  _fgroup `lvgroup' ;
};



if qui mcjobstat `prop_change' `elap' `1' `pr1' `pr2'  `dif' `prop_ch',    hgroup( _fgroup) lan(`lan')    stat(exp_hh) ;
tempname  mat00 ; 
matrix `mat00'= e(est);
local nc = colsof(`mat00') -1;
local nr = rowsof(`mat00');
if `nr' == 2 local nr = 1;
tabtitmc 00; 
local tabtit = "`r(tabtit)'";
matrix aaa= `mat00'[1..`nr', 1..`nc'] ;
if `nr' == 1 matrix rownames aaa = "Population" ;
local compo income;
if "`price'" ~= "" local compo price ;
local Compo Income;
if "`price'" ~= "" local Compo Price ;
matrix colnames aaa = "[1] Prop change in `compo' (in %)" " [2] `Compo' Elasticity" "[3] Obs Prop of Consumers" " [4] Predicted (intial values)" " [5] Predicted (final values)" " [6] Absolute Change" "[7] Change in (%)" ;
dis _n " Table 02: Estimated impact on proportions of consummers:" ;
if `nr' == 1  distable2 aaa, dec(`dec') atit(`langr')	head1(`r(tabtit)')  head2(`head2')	;
if `nr' > 1   distable  aaa, dec(`dec') atit(`langr')	head1(`r(tabtit)')  head2(`head2')	;
dis "Notes:";
dis " [1]- Estimated based on averages of population/groups." ;
dis " [2]- Estimated based on the reference individual (at means of X covariates)." ;
dis " [3]- Estimated based on population/groups." ;
dis " [4]- Based on the initial  predicted individual/household probablilites." ;
dis " [5]- Based on the final    predicted individual/household probablilites."  ;
dis " [6]- Based on [4] and [5] Statistics." ;
dis " [7]- Based on [4] and [6] Statistics." ; 
*cap matrix drop aaa;

if  ("`xfil'" ~= "") {;
matrix taaa = aaa' ;
xml_tab taaa,  format(sclb0 nccr`dec' nccr`dec' nccr`dec' nccr`dec' nccr`dec' nccr`dec' nccr`dec' nccr`dec') ///
save(`xfil')    cwidth(0 200,1 90, 2 90, 3 90, 4 90, 5 90, 6 90, 7 90, . 90) ///
sheet(Estimated changes, color(3) nogridlines)  ///
lines(0 13 COL_NAMES 2 LAST_ROW 13)  ///
title("Estimated Changes")  newappend;
};


if  ("`xfil'" ~= "") {;
cap !start "" /min "`xfil'" ; 
};
cap drop  _fgroup; 
end;

