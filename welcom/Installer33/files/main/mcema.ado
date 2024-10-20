/*************************************************************************/
/* mcema: Market	Competition	and	the	Extensive	Margin	Analysis	 */
/*************************************************************************/
/* Conceived  by :                                                       */
/*     Abdelkrim Araar                                                   */
/*     Eduardo Malasquez                                                 */
/*     Sergio Olivieri                                                   */
/*     Carlos Rodriguez-Castelan                                         */
/* email : aabd@ecn.ulaval.ca                                            */
/*   August/2019                                                        */
/*************************************************************************/
/* mcema.ado                                                             */
/*************************************************************************/
/* Description:                                                          */
/* The mcema module is designed to the impact of change in welfare or price*/ 
/* the proportion of consumers or users.                                 */
/* Intermediatelly, the estimation is based on a probit model            */
/*************************************************************************/


/* 
varlist (one dycotomic variable): 1 if the consumption of the good is higher than zero and 0 otherwise 
*/

#delimit ;
cap program drop mcema;
program define mcema, rclas;
syntax varlist(min=2 max=2)[, 
welfare(varname)
hsize(varname)
price(varname)
ICHANGE(varname)
PCHANGE(varname)
INCPAR(varname)
HGROUP(varname)
indcon(string) 
indcat(string) 
PSWP(real 1.0)
PSWE(real 1.0)
DEC(int  4)
DREG(int 0)
EXPSHARE(varname)
XFIL(string)
DGRA(int 0)   
UM(int 0)
EWGR(varname)
MAPPR(int 1)
GRMOD(varname)
FEX(int 1)
FPR(int 1)
FIN(int 1)
OOPT(string)
CINDCAT(string)
CINDCON(string) 
INISAVE(string)
*];

version 12;
set matsize 800;


/* To put all of the user graph options in the local goptions */
_get_gropts , graphopts(`options') ; local goptions `"`s(graphopts)'"';	
if ("`expshare'" == "") {;
tempvar expshare ;
qui gen `expshare' = 1.0 ;
};

tokenize `varlist' ;
if ("`expshare'" ~= "") {;
qui replace `expshare' = 1.0  if `1' == 0;
};
tempvar vchangea ;
if ("`ichange'" == "" ) {;
if "`price'" == "" {;
      di in r "You must indicate the price variable.";
	  exit 198;
};
qui gen `vchangea' = `pchange' ;
};

if ("`price'" == "" | "`ichange'" ~= "" ) {;
qui gen `vchangea' = `ichange' ;
if ("`expshare'" ~= "") {;
qui replace `expshare' = 1.0  if `1' == 0;
qui replace `vchangea' = `ichange'/`expshare' ;
};
};

/* IN PROGRESS : Apdate the swe prob*/
 
/* To capture the name of the variable sampling weight if the user declare it with the command svyset */
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear;

 if ("`inisave'" ~="") {;
  qui asdbsave_mcema `0' ;
 };

/* The final weight = sampling weight if declared or 1 (by default)   */

tempvar   sw;
qui gen `sw'=1;
if ("`hweight'"~="")        qui replace `sw'=`sw'*`hweight';
if ("`hsize'"~="")          qui replace `sw'=`sw'*`hsize';

/* 
Starting from the categorical variable hgroup, the following routine will:
1- Find the number of groups and store it in $indicag;
2- If they are declared, put the label values in local macros : grlab`g' and `g' is the group value;
3- generate the variable gn1 that contains the group values (short vector) example : 1,3 to indicate two groups with the codes 1 and 3. 
*/




if ("`ewgr''"!="") {;

preserve;
capture {;
local lvgroup:value label  `ewgr' ;
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , clear;
qui count;
forvalues i=1/`r(N)' {;
local tem=value[`i'];
local grlabm`tem' =  substr(label[`i'],1, 26);
};
};
};
restore;
qui tabulate  `ewgr', matrow(gm);
global indicagm=r(r);
tokenize `varlist';
};


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


/*
Replacing the spaces by _ in the label values;
If the label values are not declared, we give the label `hgroup'_`gr', example : rururb_0 rururb_1
*/
if ("`hgroup'"!="") {;
forvalues i=1/$indicag {;
local gr = gn1[`i'];
local sgrlab`gr' = "`hgroup'_`gr'" ;
if "`grlab`gr''"  == "" local grlab`gr' = "`hgroup'_`gr'" ;
local tmps =  subinstr("`grlab`gr''", " ", "_", .);
if  "`tmps'"  ~= "" local grlab`gr' = "`tmps'" ;
};
};


/* 
If the user selects the stepwise estimation instead of simple probit model, 
the probit command must be preceded by the prefix:  stepwise, options: probit..
The options are:
1- pr(`psw') : example pr(0.1) // keep if the P-Value is 0.1 or lower;
2- lockterm1 : keep the first term for any level of P-Value. 
*/   
if `pswp'!=1.0 local stp stepwise, pr(`pswp') lockterm1: ;

/*
The following temporary variables will contain:
elap       : The probability elasticity with respect to price or welfare;
prop_change: The proportion of change in welfare (in %);
dif        : The estimated change in the probability of use -or consumption- of the good;
*/
tempvar elap;
qui gen `elap'  = 0;
tempvar prop_ch;
qui gen `prop_ch' = 0;
tempvar prop_change;
qui gen `prop_change' = 0;
tempvar dif prdif;
qui g `dif' = 0 ;
qui g `prdif' = 0 ;


/*  
If we have categorical variables, the following routine generates new dichotomious variables.
Example : categorical variable 1  (educ )is the education level with the modalities 1,2 and 3, 
          we generate the variables educ_1, educ_2 and educ_3. 
The local `lnindcat' will contain a set of variables designed according to the modalities of the categorical variables, 
ex: educ_1, educ_2, educ_3, socio_1, socio_2... etc.  
*/

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


/* If the sampling design is not initialized, we set it to its default status (a Random Sampling) */
qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

/* We create the name of the xfil with its extention */
tokenize "`xfil'" ,  parse(".");
local tname `1'.xml;


/* 
If we have results with tables,
1- we try to erase the excel or xml file;
2- we try to close the excel tool. This will help to reopen Excel with our xml  file 
*/


if ( "`tjobs'"~="off" ) {;
if "`xfil'" ~= ""  { ;
tokenize "`xfil'" ,  parse(".");
local xfil `1'.xml ;
cap erase  `1'.xml ;
};
};
estimates drop _all;

tokenize `varlist';
cap drop if `1' ==. ; 

/* We add the prefix "qui" if the user did not like to display the results of the probit models */

                            local disprobit  = "";
if  (`dreg' == 0)           local disprobit  = "qui" ;
qui replace `1' = 0 if `1'==. ;

/* We generate the variables log(price) and log(welfare) */


if ("`welfare'" ~= "" ) {;
cap drop  Ln_Inc ;
qui gen   Ln_Inc  = ln(`welfare');
};

if ("`price'" ~= "" ) {;
cap drop    LnPrice ;
qui gen     LnPrice  = ln(`price');
qui replace LnPrice  = 0 if LnPrice ==. ;
};

/* The basic name  of the welfare partition variable: example, if the welfare group modules are 1,2,3,4 and 5, we have quintiles i.e., basic name is: Quintile_ */ 
if "`incpar'" ~= "" {;
qui tab `incpar';
local nigr = `r(r)';
if `nigr' == 10 local iname = "Decile" ;
if `nigr' ==  5 local iname = "Quintile" ;
if `nigr' ==  4 local iname = "Quartile" ;
if `nigr' != 10 & `nigr' != 5 & `nigr' != 4   local iname = "IncGr" ;

											 local grgname = "`iname'";
if `nigr' != 10 & `nigr' != 5 & `nigr' != 4  local grgname = "welfare_Partition (`nigr')";
};

eststo clear;


/*
All of the precent code is to prepare the variables to perform the estimations.
In what follow, we will have two main cases.
1- The variable price is not available: in that case what is is estimated is the probablity elasticity with respect to welfare.
2- The variable price is available    : in that case what is is estimated is the probablity elasticity with respect to price. // prior estimation. 

*/

/* The case where the price is not available */ 

if ("`price'" == "" | "`ichange'" ~= "" ) {;
/* The um() option indicates the desired model to be used to estimate the changes in the probabilities */ 
/* Remember that the model 1 (M1) is the simple one (no interaction between the group variable of interest and welfare */
/* If the user would like to use the coefficient of the first model, he must add the option um(1) */

 if (`um'!=0) {;
 /*
 the temp variables will contain the probabilities before and after the change in welfare;
 the temp variable  prop_ch is the proportional change  
 */

cap drop `pr1';
cap drop `pr2';
tempvar pr1 pr2; 

if ("`price'" ~= "" ) {;
cap drop    LnPrice ;
qui gen     LnPrice  = ln(`price');
qui replace LnPrice  = 0 if LnPrice ==. ;
};

if "`price'"~= "" local modp = "LnPrice" ;


qui  `stp' probit `1'  Ln_Inc `modp' `lnindcat' `indcon' [pw=`sw'];
qui predict `pr1';
qui replace Ln_Inc=log(exp(Ln_Inc)+`vchangea');
qui predict `pr2' ;
qui replace Ln_Inc=log(exp(Ln_Inc)-`vchangea');
qui margins [aw=`sw'] , dydx(Ln_Inc) atmeans ;
local mar1 = el(r(table),1,1) ;
qui sum `1' [aw=`sw'];
local elap1 = `mar1' / r(mean) ;
replace `elap' = `elap1'; 
qui sum `vchangea'  [aw=`sw'], meanonly;      local mu1 = r(mean);
qui sum `welfare'   [aw=`sw'],   meanonly;      local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 ; 

qui sum `pr1'  [aw=`sw']  , meanonly;         local mu1 = r(mean);
qui sum `pr2'  [aw=`sw']  , meanonly;         local mu2 = r(mean);

qui replace `prdif' = `pr2'-`pr1'            ; 
qui replace `dif' = `mu2'-`mu1'            ; 
qui replace `prop_ch' = `dif'/`mu1'*100    ; 
};

/* If the user does not indicate the welfares partition (ex: incpar(decile), the local macro subcom contains only the varname: Ln_Inc */

if  ("`incpar'" =="") local subcom  Ln_Inc;

`disprobit'  `stp' probit `1'  Ln_Inc `modp' `lnindcat' `indcon' [pw=`sw'];

/*We estimate the model M1 if "`incpar'" =="" | `um'==1 */
if ("`incpar'" =="" | `um'==1) {;
cap drop `pr1';
cap drop `pr2';
tempvar pr1 pr2; 
qui predict `pr1';
qui replace Ln_Inc=log(exp(Ln_Inc)+`vchangea');
qui predict `pr2' ;
qui replace Ln_Inc=log(`welfare');
qui replace Ln_Inc=log(`welfare');
qui margins [aw=`sw'] , dydx(Ln_Inc) atmeans ;
local mar1 = el(r(table),1,1) ;
qui sum `1' [aw=`sw'];
local elap1 = `mar1' / r(mean) ;
qui replace `elap' = `elap1'; 
qui sum `vchangea'  [aw=`sw'], meanonly;      local mu1 = r(mean);
qui sum `welfare' [aw=`sw'], meanonly; local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 ; 

qui sum `pr1'  [aw=`sw'] , meanonly;      local mu1 = r(mean);
qui sum `pr2' [aw=`sw']  , meanonly;      local mu2 = r(mean);
qui replace `prdif' = `pr2'-`pr1'            ; 
qui replace `dif' = `mu2'-`mu1'            ; 
qui replace `prop_ch' = `dif'/`mu1'*100    ; 
 
};

/* We store the results in m1 (for the Stata display) and mod1 for the excel storage */
eststo m1;
local est_m1 = _b[Ln_Inc];
return scalar est = _b[Ln_Inc];
return scalar se  = _se[Ln_Inc];
estimates store mod1, title(Model 1) ;
local models `models' mod1 ; 



 /* 
The Model M2 is that when the Ln_Inc interacts with the welfare partition. 
 Here, we can estimate the elasticities for each welfare partition.    
 The interaction variable that we generate are:
 Ln_Inc_0`j'  if j <= 9 and Ln_Inc_`j'  if j >= 10 : example ....  Ln_Inc_08,  Ln_Inc_09,  Ln_Inc_10, ... 
 Also, note that the macro subcom  is now: Ln_Inc_Num1, Ln_Inc_2... 
 */

if ("`incpar'" ~="" ) {;
forvalues i=1/`nigr' {;
cap drop Ln_Inc_0`i';
cap drop Ln_Inc_`i';
if `i' <=  9  qui gen Ln_Inc_0`i'     =  Ln_Inc*(`i'==`incpar');
if `i' >= 10  qui gen Ln_Inc_`i'      =  Ln_Inc*(`i'==`incpar');
if `i' <=  9   local subcom `subcom'  Ln_Inc_0`i';
if `i' >= 10   local subcom `subcom'  Ln_Inc_`i';
};

 `disprobit'  `stp' probit `1'  `subcom' `modp' `lnindcat' `indcon' [pw=`sw'];
 eststo m2;
 estimates store mod2, title(Model 2) ;
 local models `models' mod2;
 /* Remember that if um(1), we estimate the probabilities with the model M1 */
 if (`um'!=1) {;
 cap drop `pr1';
cap drop `pr2';
tempvar pr1 pr2; 
qui predict `pr1';
forvalues j=1/`nigr' {;
if `j' <=  9  qui replace Ln_Inc_0`j'     =  log(exp(Ln_Inc)+`vchangea')*(`j'==`incpar');
if `j' >= 10  qui replace Ln_Inc_`j'      =  log(exp(Ln_Inc)+`vchangea')*(`j'==`incpar');
};
cap drop `pr2';
qui predict `pr2';



forvalues j=1/`nigr' {;
if `j' <=  9  qui replace Ln_Inc_0`j'     =  log(`welfare')*(`j'==`incpar');
if `j' >= 10  qui replace Ln_Inc_`j'      =  log(`welfare')*(`j'==`incpar');
};
};


forvalues j=1/`nigr' {;
if `j' <=  9  local myvar Ln_Inc_0`j';
if `j' >= 10  local myvar  Ln_Inc_`j';   
cap qui margins [aw=`sw'], dydx(`myvar') atmeans ;
cap local mar`j' = el(r(table),1,1) ;
if "`mar`j''" == "" local mar`j' = 0;
qui sum `1' [aw=`sw'] if (`j'==`incpar') ;
local elap1 = `mar`j'' / r(mean)  ;
qui replace `elap' = `elap1' if (`j'==`incpar'); 

qui sum `vchangea'  [aw=`sw'] if (`j'==`incpar'), meanonly;      local mu1 = r(mean);
qui sum `welfare' [aw=`sw'] if (`j'==`incpar'), meanonly; local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 if (`j'==`incpar') ; 

qui sum `pr1'  [aw=`sw'] if (`j'==`incpar'),  meanonly;      local mu1 = r(mean);
qui sum `pr2'  [aw=`sw']  if (`j'==`incpar'), meanonly;      local mu2 = r(mean);
qui replace `prdif' = `pr2'-`pr1'            ; 
qui replace `dif' = `mu2'-`mu1'            if (`j'==`incpar') ; 
qui replace `prop_ch' = `dif'/`mu1'*100    if (`j'==`incpar') ; 

};



};

/* The estimation of M3 : the case where the population group of interest is indicated (option hgroup()) 

A- The case where "`incpar'" ~="" & "`hgroup'" ~="" , the Ln_Inc interacts with the hgroup and also the incpar : example one can find the variable.. Ln_Inc_decile3_educ_2
B- The case where "`incpar'" =="" & "`hgroup'" ~="" , the Ln_Inc interacts with the hgroup : example one can find the variable.. Ln_Inc_educ_2
*/

/* What follows is only a repetition of the steps with the new interaction components */
if ("`incpar'" ~="" & "`hgroup'" ~="" ) {;
forvalues g=1/$indicag {;
local gr = gn1[`g'];
local lvgroup:value label `hgroup';
forvalues i=1/`nigr' {;
if `i' <=  9  qui gen Ln_Inc_`iname'_0`i'_`sgrlab`gr'' =  Ln_Inc*(`i'==`incpar')*(`gr'==`hgroup');
if `i' >= 10  qui gen Ln_Inc_`iname'_`i'_`sgrlab`gr''  =  Ln_Inc*(`i'==`incpar')*(`gr'==`hgroup');
if `i' <=  9   local inc_group `inc_group'  Ln_Inc_`iname'_0`i'_`sgrlab`gr'';
if `i' >= 10   local inc_group `inc_group'  Ln_Inc_`iname'_`i'_`sgrlab`gr'';
};
};
 

`disprobit'  `stp' probit `1'  `inc_group' `modp'  `lnindcat' `indcon' [pw = `sw'] ;
 if (`um'!=1) {;
cap drop `pr1';
cap drop `pr2';
tempvar pr1 pr2; 
qui predict `pr1' ;
forvalues g=1/$indicag {;
local gr = gn1[`g'];
local lvgroup:value label `hgroup';
forvalues i=1/`nigr' {;
if `i' <  10 qui replace Ln_Inc_`iname'_0`i'_`sgrlab`gr''=log(exp(Ln_Inc_`iname'_0`i'_`sgrlab`gr'')+`vchangea')*(`i'==`incpar')*(`gr'==`hgroup');
if `i' >= 10 qui replace Ln_Inc_`iname'_`i'_`sgrlab`gr'' =log(exp(Ln_Inc_`iname'_`i'_`sgrlab`gr'') +`vchangea')*(`i'==`incpar')*(`gr'==`hgroup');
};
};

qui predict `pr2';
forvalues g=1/$indicag {;
local gr = gn1[`g'];
local lvgroup:value label `hgroup';
forvalues i=1/`nigr' {;
if `i' <  10 qui replace Ln_Inc_`iname'_0`i'_`sgrlab`gr''=log(`welfare')*(`i'==`incpar')*(`gr'==`hgroup');
if `i' >= 10 qui replace Ln_Inc_`iname'_`i'_`sgrlab`gr'' =log(`welfare')*(`i'==`incpar')*(`gr'==`hgroup');
};
};


forvalues g=1/$indicag {;
local gr = gn1[`g'];
forvalues j=1/`nigr' {;
if `j' <  10 local myvar Ln_Inc_`iname'_0`j'_`sgrlab`gr'';
if `j' >= 10 local myvar Ln_Inc_`iname'_`j'_`sgrlab`gr'' ;  
cap qui margins [aw=`sw'], dydx(`myvar') atmeans ;
cap local mar_`g'_`j' = el(r(table),1,1) ;
if "`mar_`g'_`j''" == ""  local mar_`g'_`j' = 0;
qui sum `1' [aw=`sw'] if (`j'==`incpar') & (`gr'==`hgroup') ;
local elap1 = `mar_`g'_`j'' / r(mean)  ;
qui replace `elap' = `elap1' if (`j'==`incpar') & (`gr'==`hgroup') ;

qui sum `vchangea'  [aw=`sw'] if (`j'==`incpar') & (`gr'==`hgroup'), meanonly;      local mu1 = r(mean);
qui sum `welfare' [aw=`sw'] if (`j'==`incpar') & (`gr'==`hgroup'), meanonly; local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 if (`j'==`incpar') & (`gr'==`hgroup') ; 

qui sum `pr1'  [aw=`sw'] if (`j'==`incpar') & (`gr'==`hgroup'), meanonly;      local mu1 = r(mean);
qui sum `pr2' [aw=`sw']  if (`j'==`incpar') & (`gr'==`hgroup'), meanonly;      local mu2 = r(mean);
qui replace `prdif' = `pr2'-`pr1'            ; 
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
cap drop Ln_Inc_`sgrlab`gr'';
qui gen Ln_Inc_`sgrlab`gr'' =  Ln_Inc*(`gr'==`hgroup');
local inc_group `inc_group'  Ln_Inc_`sgrlab`gr'';
};
`disprobit'  `stp' probit `1'  `inc_group' `modp'  `lnindcat' `indcon' [pw = `sw'] ;
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
qui replace Ln_Inc_`sgrlab`gr''=log(exp(Ln_Inc_`sgrlab`gr'')+`vchangea')*(`g'==`hgroup');
};

qui predict `pr2';
forvalues g=1/$indicag {;
local gr = gn1[`g'];
qui replace Ln_Inc_`sgrlab`gr''=log(exp(Ln_Inc_`sgrlab`gr'')-`vchangea')*(`g'==`hgroup');
};
};


forvalues g=1/$indicag {;
local gr = gn1[`g'];
local myvar Ln_Inc_`sgrlab`gr'';
cap qui margins [aw=`sw'], dydx(`myvar') atmeans ;
cap local mar_`g' = el(r(table),1,1) ;
if "`mar_`g''" == "" local  local mar_`g' = 0;
qui sum `1' [aw=`sw'] if  (`gr'==`hgroup') ;
local elap1 = `mar_`g'' / r(mean)  ;
qui replace `elap' = `elap1' if  (`gr'==`hgroup') ;

qui sum `vchangea'  [aw=`sw'] if (`gr'==`hgroup'), meanonly;      local mu1 = r(mean);
qui sum `welfare' [aw=`sw'] if (`gr'==`hgroup'), meanonly; local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 if (`gr'==`hgroup') ; 


qui sum `pr1'  [aw=`sw'] if (`gr'==`hgroup'), meanonly;      local mu1 = r(mean);
qui sum `pr2' [aw=`sw']  if (`gr'==`hgroup'), meanonly;      local mu2 = r(mean);
qui replace `prdif' = `pr2'-`pr1'            ; 
qui replace `dif' = `mu2'-`mu1'            if (`gr'==`hgroup') ; 
qui replace `prop_ch' = `dif'/`mu1'*100    if (`gr'==`hgroup') ; 


};

};

};



/* The case where the price is indicated 
   1- Similar to the case of welfare;
   2- the Lnwelfare becomes only a explanatory variable;
   3- 
   
 */


if ("`price'" ~= "" & "`ichange'" == "" ) {;
if  ("`incpar'" =="") local subpri  LnPrice;
if  ("`welfare'" ~="") local subcom  Ln_Inc;

 if (`um'!=0) {;
cap drop `pr1';
cap drop `pr2';
tempvar pr1 pr2; 
qui `stp' probit `1'  LnPrice `subcom' `lnindcat' `indcon'  [pw=`sw'];
local est_m1 = _b[LnPrice];
qui predict `pr1';
qui replace LnPrice=log(exp(LnPrice)+`vchangea');
qui predict `pr2' ;
qui replace LnPrice=log(exp(LnPrice)-`vchangea');

qui margins [aw=`sw'], dydx(LnPrice) atmeans ;
local mar1 = el(r(table),1,1) ;
qui sum `1' [aw=`sw'];
local elap1 = `mar1' / r(mean) ;
qui replace `elap' = `elap1'; 
qui sum `vchangea'  [aw=`sw'], meanonly;      local mu1 = r(mean);
qui sum `price' [aw=`sw'], meanonly; local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 ; 

qui sum `pr1'  [aw=`sw'] , meanonly;      local mu1 = r(mean);
qui sum `pr2' [aw=`sw']  , meanonly;      local mu2 = r(mean);
qui replace `prdif' = `pr2'-`pr1'            ; 
qui replace `dif' = `mu2'-`mu1'            ; 
qui replace `prop_ch' = `dif'/`mu1'*100    ; 
 };




`disprobit' `stp' probit `1'  LnPrice `subcom' `lnindcat' `indcon'  [pw=`sw'];

if ("`incpar'" =="" | `um'==0) {;
cap drop `pr1';
cap drop `pr2';
tempvar pr1 pr2; 
qui predict `pr1';
qui replace LnPrice=log(exp(LnPrice)+`vchangea');
qui predict `pr2' ;
qui replace LnPrice=log(exp(LnPrice)-`vchangea');
qui margins [aw=`sw'], dydx(LnPrice) atmeans ;
local mar1 = el(r(table),1,1) ;
qui sum `1' [aw=`sw'];
local elap1 = `mar1' / r(mean) ;
qui replace `elap' = `elap1'; 
qui sum `vchangea'  [aw=`sw'], meanonly;      local mu1 = r(mean);
qui sum `price' [aw=`sw'], meanonly; local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 ; 

qui sum `pr1'  [aw=`sw'] , meanonly;      local mu1 = r(mean);
qui sum `pr2'  [aw=`sw']  , meanonly;      local mu2 = r(mean);
qui replace `prdif' = `pr2'-`pr1'            ; 
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
qui replace LnPrice=log(exp(LnPrice)+`vchangea');
qui predict `pr2' ;
qui replace LnPrice=log(exp(LnPrice)-`vchangea');
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
if `j' <=  9  qui replace LnPrice_0`j'     =  log(exp(LnPrice)+`vchangea')*(`j'==`incpar');
if `j' >= 10  qui replace LnPrice_`j'      =  log(exp(LnPrice)+`vchangea')*(`j'==`incpar');
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

qui sum `vchangea' [aw=`sw'] if (`j'==`incpar'), meanonly;      local mu1 = r(mean);
qui sum `price' [aw=`sw'] if (`j'==`incpar'), meanonly; local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 if (`j'==`incpar') ; 


qui sum `pr1'  [aw=`sw'] if (`j'==`incpar'), meanonly;      local mu1 = r(mean);
qui sum `pr2' [aw=`sw']  if (`j'==`incpar'), meanonly;      local mu2 = r(mean);
qui replace `prdif' = `pr2'-`pr1'            ; 
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
if `i' <  10 qui replace LnPrice_`iname'_0`i'_`sgrlab`gr''=log(exp(LnPrice_`iname'_0`i'_`sgrlab`gr'')+`vchangea')*(`i'==`incpar')*(`gr'==`hgroup');
if `i' >= 10 qui replace LnPrice_`iname'_`i'_`sgrlab`gr'' =log(exp(LnPrice_`iname'_`i'_`sgrlab`gr'') +`vchangea')*(`i'==`incpar')*(`gr'==`hgroup');
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

qui sum `vchangea'[aw=`sw'] if (`j'==`incpar') & (`gr'==`hgroup'), meanonly;      local mu1 = r(mean);
qui sum `price'  [aw=`sw'] if (`j'==`incpar') & (`gr'==`hgroup'), meanonly; local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 if (`j'==`incpar') & (`gr'==`hgroup') ; 

qui sum `pr1'  [aw=`sw'] if (`j'==`incpar') & (`gr'==`hgroup'), meanonly;      local mu1 = r(mean);
qui sum `pr2' [aw=`sw']  if (`j'==`incpar') & (`gr'==`hgroup'), meanonly;      local mu2 = r(mean);
qui replace `prdif' = `pr2'-`pr1'            ; 
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
qui replace LnPrice_`sgrlab`gr''=log(exp(LnPrice_`sgrlab`gr'')+`vchangea')*(`g'==`hgroup');
};

qui predict `pr2';
forvalues g=1/$indicag {;
local gr = gn1[`g'];
qui replace LnPrice_`sgrlab`gr''=log(exp(LnPrice_`sgrlab`gr'')-`vchangea')*(`g'==`hgroup');
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
qui sum `vchangea'     [aw=`sw'] if (`gr'==`hgroup');      local mu1 = r(mean);
qui sum `price'       [aw=`sw'] if (`gr'==`hgroup');      local mu2 = r(mean);
qui replace `prop_change' = `mu1'/`mu2'*100 if (`gr'==`hgroup') ;

qui sum `pr1'  [aw=`sw'] if (`gr'==`hgroup'), meanonly;      local mu1 = r(mean);
qui sum `pr2'  [aw=`sw']  if (`gr'==`hgroup'), meanonly;      local mu2 = r(mean);
qui replace `prdif' = `pr2'-`pr1'            ; 
qui replace `dif' = `mu2'-`mu1'            if (`gr'==`hgroup') ; 
qui replace `prop_ch' = `dif'/`mu1'*100    if  (`gr'==`hgroup') ; 
};


};

};



/* All of the possible estimated probit models are reported in table 01 */
dis _n "Table 01: Estimates of probability of consumption model(s)" ;
if ("`incpar'" =="" & "`hgroup'" =="")                             esttab m1, not pr2    mtitle("(Model 01)" ) nodepvars nonumbers b(`dec') varwidth(34) label;
if ("`incpar'" ~="" & "`hgroup'" =="")           esttab m1 m2, not pr2 mtitle("(Model 01)" "(Model 02)") nodepvars nonumbers b(`dec') varwidth(34) label;
if ("`incpar'" ~="" & "`hgroup'" ~="")            esttab m1 m2 m3, not pr2 mtitle("(Model 01)" "(Model 02)" "(Model 03)") nodepvars nonumbers b(`dec') varwidth(34) label;
if ("`incpar'" =="" & "`hgroup'" ~="")            esttab m1 m3, not pr2 mtitle("(Model 01)" "(Model 03)") nodepvars nonumbers b(`dec') varwidth(34) label;






cap matrix drop _cc; 
cap matrix drop bb1; 
cap matrix drop bb2; 
cap matrix drop bb3; 
cap matrix drop bb4; 
cap matrix drop aa; 
cap matrix drop gn; 

/* incpar and hgroup can be 1 by default */

if  ("`incpar'"=="" & "`hgroup'" == "" ) {;
tempvar incpar;
cap drop `incpar';
qui gen  `incpar' = 1;
};

if "`hgroup'"  == "" {;
tempvar hgroup ;
cap drop  `hgroup' 
g `hgroup' = 1; 
};

/* capturing the label values of the hgroup variable*/ 
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


/* mcjobstat command estimates the averages of the variables by groups (_fgroup) */
/* the rest of the code is to use the returned matrix of the mcjobstat command to display and save the results */
qui mcjobstat `prop_change' `elap' `1' `pr1' `pr2'  `dif' `prop_ch',    hgroup( _fgroup) lan(`lan')    stat(exp_hh) ;
tempname  mat00 ; 
matrix `mat00'= e(est);
local nc = colsof(`mat00') -1;
local nr = rowsof(`mat00');
if `nr' == 2 local nr = 1;
tabtitmc 00; 
local tabtit = "`r(tabtit)'";
matrix aaa= `mat00'[1..`nr', 1..`nc'] ;
if `nr' == 1 matrix rownames aaa = "Population" ;
local compo welfare;
if "`price'" ~= "" & "`ichange'"=="" local compo price ;

local Compo welfare;
if "`price'" ~= "" & "`ichange'"==""  local Compo Price ;
if ("`expshare'"~="") & "`ichange'"~="" local isinf  = "(adjusted by share)" ;

tempvar coltit1 coltit2 coltit3;
qui gen     `coltit1' = ""; qui gen     `coltit2' = ""; qui gen     `coltit3' = "";
qui replace `coltit1' = "[1] Proportion of  "  in 1 ; 
qui replace `coltit2' = "     change in `compo'    "           in 1 ;  
qui replace `coltit3' = "    `isinf' (in %)  "     in 1 ;

qui replace `coltit1' = "[2] `Compo'        "  in 2 ; qui replace `coltit2' = "      Elasticity  "           in 2 ; 

qui replace `coltit1' = "[3] Observed         " 			in 3 ; 
qui replace `coltit2' = "     proportion of   " 			in 3 ;
qui replace `coltit3' = "     consumers/users " 			in 3 ;

qui replace `coltit1' = "[4] Predicted          "      in 4 ;
qui replace `coltit2' = "     probability with  "      in 4 ;
qui replace `coltit3' = "     initial `compo'(s)"      in 4 ;

qui replace `coltit1' = "[5] Predicted           "      in 5 ;
qui replace `coltit2' = "     probability with   "      in 5 ;
qui replace `coltit3' = "     final `compo'(s)   "       in 5 ;


qui replace `coltit1' = "[6] Absolute change" 		        in 6 ;
qui replace `coltit2' = "    in probability " 		        in 6 ;
qui replace `coltit3' = "    ([5] - [4])    " 		            in 6 ;

qui replace `coltit1' = "[7] Relative change      " 		        in 7 ;
qui replace `coltit2' = "    in probability (in %)" 		in 7 ;
qui replace `coltit3' = "    ([6]/[4])*100        " 		in 7 ;

matrix colnames aaa = "[1] Prop. if change in `compo' (in %)" " [2] `Compo' Elasticity" "[3] Obs. prop. of consumers" " [4] Predicted  prob. (intial values)" " [5] Predicted  prob. (final values)" " [6] Absolute change" "[7] Relative change in (%)" ;
dis _n "Table 02: Estimated impact on the proportions of consummers" ;
if `nr' == 1  distable2 aaa, dec(`dec') atit(`langr')	head1(`r(tabtit)')  head2(`head2') coltit1(`coltit1')  coltit2(`coltit2')  coltit3(`coltit3');
if `nr' > 1   distable  aaa, dec(`dec') atit(`langr')	head1(`r(tabtit)')  head2(`head2') coltit1(`coltit1')  coltit2(`coltit2')  coltit3(`coltit3');
dis "Notes:";
dis " [1]- Estimated based on averages of the population/groups." ;
dis " [2]- Estimated based on the reference individual (at means of X covariates)." ;
dis " [3]- Estimated based on population/groups." ;
dis " [4]- Based on predicted individual -household- probabilities with  initial  `compo's." ;
dis " [5]- Based on predicted individual -household- probabilities with  final  `compo's."  ;
dis " [6]- Based on [4] and [5] Statistics." ;
dis " [7]- Based on [4] and [6] Statistics." ; 
*cap matrix drop aaa;


/*****/
/* Expenditure regression */
/*
set trace on ;
set tracedepth 1;
*/
tempvar pred_exp;

if (`mappr' == 1) {;
tempvar var1 var2 nomi denomi ;
qui gen `var1' = `sw'*`2' ; 
qui gen `var2' = `sw' ; 
qui by `grmod', sort : egen float `nomi'   = total(`var1');
qui by `grmod', sort : egen float `denomi' = total(`var2');
qui gen `pred_exp' =  `nomi'/`denomi' ;
};

if (`mappr'  == 2) {;
if `pswe'!=1.0 local stpe stepwise, pr(`pswe'): ;
if "`2'"~="Expenditure" qui gen Expenditure = `2' ; 
                       local  vexp Expenditure ; 
if `fex' == 2 {;
 qui gen LnExpend = log(`2') ; 
 local  vexp LnExpend ; 
 };
local model_expend `model_expend' `vexp' ;
if "`welfare'"~="_Inc" qui gen _Inc = `welfare' ; 
               local  vexp _Inc ; 
if `fin' == 2  local  vexp Ln_Inc ; 
if `fin' == 3  local  vexp "" ; 
local model_expend `model_expend' `vexp' ;

if ("`price'"~="")  {;
if "`price'" ~="Price " qui gen Price = `price' ; 
               local  vexp Price ; 
if `fpr' == 2  local  vexp LnPrice ; 
if `fpr' == 3  local  vexp "" ; 
local model_expend `model_expend' `vexp' ;
};

#delimit ; 
if ("`cindcat'"~="") {;
foreach var of varlist `cindcat' {;
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
if `posa' != 1 local clnindcat `clnindcat' `var'_`i';
local posa = `posa'+1 ;
};
};
};
};

local model_expend `model_expend' `clnindcat'  ;
xi: `disprobit' `stpe' regress `model_expend' `cindcon'  [pw=`sw'] , `oopt' ;
eststo modexp;
qui predict `pred_exp' , xb;
if `fex' == 2 qui replace `pred_exp' = exp(`pred_exp') ;

dis _n "Table 03: Estimates of the expenditures model" ;
esttab modexp, not r2    mtitle("(Model 01)" ) nodepvars nonumbers b(`dec') varwidth(34) label;


};



tempvar _fexpen benif tbenifo   ;
qui      gen `_fexpen' = `pred_exp' if `1' == 0; 
qui replace  `_fexpen' = `2'        if `1' == 1; 

qui gen `benif  ' = -`_fexpen' * `pchange'  ;
qui gen `tbenifo' = -`2' * `pchange'*(`1'==1)  ;




tempvar res0 ;
qui gen `res0' = "";
forvalues i=1/8 {;
tempvar res`i' ;
qui gen `res`i'' = 0;
};


if ("`ewgr'" ~= "") {;
svmat int gm;
forvalues i=1/$indicagm {;

local k = gm1[`i'];

if ( "`grlabm`i''" == "") local grlabm`i' = "Group_`k'";

qui replace `res0' = "`k': `grlabm`k''" in `i';

qui sum `2' [aw=`sw'] if  `ewgr'==`k' & `1' == 1 ;
qui replace `res1' = r(mean) in `i';

qui sum `pred_exp' [aw=`sw'] if  `ewgr'==`k' & `1' == 0 ;
qui replace `res2' = r(mean) in `i';

qui sum `1' [aw=`sw']  if `ewgr'==`k'  ;
qui replace `res3' = r(mean)*100 in `i';


qui sum `prdif' [aw=`sw']   if  `ewgr'==`k' ;
qui replace `res4' = r(mean)*100 in `i';


qui sum `benif' [aw=`sw'] if  `ewgr'==`k' & `1' == 1 ;
qui replace `res5' = r(mean) in `i';

qui sum `benif' [aw=`sw'] if  `ewgr'==`k' & `1' == 0 ;
qui replace `res6' = r(mean) in `i';

qui sum `tbenifo' [aw=`sw'] if  `ewgr'==`k' ;
qui replace `res7' = r(mean) in `i';

qui replace `res8' = `res7'[`i'] + `res4'[`i']/100*`res6'[`i'] in `i';

};
};

global indicagm1 = $indicagm +1;
local i = $indicagm1 ;


qui replace `res0' = "Population" in `i';

qui sum `2' [aw=`sw'] if   `1' == 1 ;
qui replace `res1' = r(mean) in `i';

qui sum `pred_exp' [aw=`sw'] if   `1' == 0 ;
qui replace `res2' = r(mean) in `i';

qui sum `1' [aw=`sw'] ;
qui replace `res3' = r(mean)*100 in `i';

qui sum `prdif' [aw=`sw']    ;
qui replace `res4' = r(mean)*100 in `i';

qui sum `benif' [aw=`sw'] if  `1' == 1 ;
qui replace `res5' = r(mean) in `i';

qui sum `benif' [aw=`sw'] if  `1' == 0 ;
qui replace `res6' = r(mean) in `i';

qui sum `tbenifo' [aw=`sw']  ;
qui replace `res7' = r(mean) in `i';

qui replace `res8' = `res7'[`i'] + `res4'[`i']/100*`res6'[`i']  in `i';

tempname resmat4t resmat4 ;
qui mkmat `res1' `res2' `res3' `res4' `res5' `res6' `res7' `res8' in 1/$indicagm1 , matrix(`resmat4t') rownames(`res0');
matrix `resmat4' = `resmat4t'';

matrix rownames `resmat4' = 
"[1] Expenditures (old users)" 
"[2] Predicted expend. (new users)" 
"[3] Proportion of old users"
"[4] Proportion of new users"
"[5] Imp. on well. old_users" 
"[6] Imp. on well. new_users" 
"[7] Imp. on well. without entrants" 
"[8] Imp. on well. with entrants" 
;


dis _n "Table 04: Estimated impact on well-being" ;
   tempname table;
        .`table'  = ._tab.new, col(9);
        .`table'.width |30|16 16 | 16 16 | 16 16 || 20  23|;
        .`table'.strcolor . . .  yellow . . . . . ;
        .`table'.numcolor yellow yellow yellow . yellow yellow yellow yellow  yellow  ;
        .`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f  %16.`dec'f %20.`dec'f %23.`dec'f;
        .`table'.sep, top;
        .`table'.titles "Group  " "[1] Expenditures " "[2] Predicted "   "[3] Proportion "   "[4] Proportion "  "[5] Impact on "  "[6] Impact on  "     "[7] Impact on        "   "[8] Impact on  "      ;
	    .`table'.titles "       " "     (old users)" "   expenditures" "  of old users"   "   of new users"  "  well-being"  " well-being  "       " well-being   "    "  well-being    " ;
        .`table'.titles "       " "                " "   (new users) " "  in (%)      "   "   in (%)     "  "  (old users)"  " (new users) "        "  without new users"    "  with new users"  ;
        .`table'.sep, mid;
        local nalt = "ddd";
        forvalues i=1/$indicagm {;
		.`table'.row `res0'[`i']  `res1'[`i']  `res2'[`i']  `res3'[`i']  `res4'[`i']  `res5'[`i']  `res6'[`i']  `res7'[`i'] `res8'[`i'];
		 };
local i = $indicagm1;		 
.`table'.sep, mid;
.`table'.row `res0'[`i']  `res1'[`i']  `res2'[`i']  `res3'[`i']  `res4'[`i']  `res5'[`i']  `res6'[`i']  `res7'[`i'] `res8'[`i'];
.`table'.sep,bot;

dis "Notes:";
dis " [1]- Estimated based on average expenditures of old consumers by population/groups." ;
dis " [2]- Estimated based on average usage (expenditures>0) by population/groups." ;
dis " [3]- Estimated based on average predicted expenditures of the new consumers by population/groups." ;
dis " [4]- Estimated based on the predicted expected change in proportion of consumers by population/groups." ;
dis " [5]- Estimated average impact on well-being of the old consumers by population/groups." ;
dis " [6]- Estimated average impact on well-being of the new consumers by population/groups." ;
dis " [7]- ([3]/100)*[5]." ;
dis " [8]- [7] + ([4]/100)*[6]." ; 

/*****/
/* Saving results in the excel file */ 
if  ("`xfil'" ~= "") {;

xml_tab `models',  format(sclb0 ncrr3 nccr3) stats(N pr2) ///
save(`xfil') replace  ///
cblanks(2) cwidth(0 220, 3 4)  font("Cambria" 10)   ///
sheet(Table_01,  nogridlines)  ///
lines(_cons 2 LAST_ROW 13 COL_NAMES 2 EST_NAMES 2) ///
title("Table 01: Estimates of probability of consumption model(s)");


matrix taaa = aaa' ;
qui xml_tab taaa,  format(sclb0 nccr`dec' nccr`dec' nccr`dec' nccr`dec' nccr`dec' nccr`dec' nccr`dec' nccr`dec') ///
save(`xfil')    cwidth(0 210,1 90, 2 90, 3 90, 4 90, 5 90, 6 90, 7 90, . 90) font("Cambria" 10)  ///
sheet(Table_02,  nogridlines)  ///
lines(0 13 COL_NAMES 2 LAST_ROW 13)  ///
title("Table 02: Estimated impact on the proportions of consummer")  newappend;

if  (`mappr'  == 2) {;
qui xml_tab modexp,  format(sclb0 ncrr3 nccr3) stats(N r2) ///
save(`xfil') append  ///
cblanks(2) cwidth(0 220, 3 4) font("Cambria" 10)  ///
sheet(Table_03,  nogridlines)  ///
lines(_cons 2 LAST_ROW 13 COL_NAMES 2 EST_NAMES 2) ///
title("Table 03: Estimates of the expenditures model");
};


qui xml_tab `resmat4',  format(sclb0 nccr`dec' nccr`dec' nccr`dec' nccr`dec' nccr`dec' nccr`dec' nccr`dec' nccr`dec') ///
save(`xfil')    cwidth(0 220, . 60) font("Cambria" 10) ///
sheet(Table_04,  nogridlines)  ///
lines(0 13 COL_NAMES 2 LAST_ROW 13)  ///
title("Table 04: Estimated impact on well-being")  newappend;

};

/* to display automatically the excel file */
if  ("`xfil'" ~= "") {;
di as txt `"(output written to {browse `xfil'})"' ; 
};
cap drop  _fgroup; 
end;

