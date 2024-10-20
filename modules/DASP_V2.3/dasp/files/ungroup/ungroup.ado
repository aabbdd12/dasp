
/*************************************************************************/
/* ungroup module                                                        */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Université Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/


#delim ;
capture program drop ungroup;
program define ungroup, rclass;
version 9.2;
syntax varlist(min=2 max=2)[,  nobs(int 1000) pbot(real 0) ptop(real 0) bnobs(int 0)   tnobs(real 0) FNAME(string) ADJust(int 1) dist(string) LORenz(int 0)];
preserve;

 tokenize `varlist';
_nargs    `varlist';

if ("`dist'"=="") local dist = "lnorm";

local tb=0; if (`pbot'!=0 | `ptop' !=0)  local tb=1;
local pbot=`pbot'/100;  
local ptop=`ptop'/100; 

/* We do not consider missing values and negative incomes*/
qui drop if (`1'==. | `1' == 0  ); 
qui drop if (`2'==. | `2' <= 0  );
qui sort `1';
qui count;  local nclass   = `r(N)';
local nclass_1 = `nclass'-1;
qui replace `2'=`2'/`2'[`nclass'];  
          			
if  (`nclass' < `nobs')  qui set obs `nobs';

/* Checking the consistency of data and selected options */
 _expex `1' `2', nobs(`nobs') pbot(`pbot') ptop(`ptop') bnobs(`bnobs')   tnobs(`tnobs') nclass(`nclass');


/* Generating the cumulative distribution function */
 _cumdis anythi,  nobs(`nobs') pbot(`pbot') ptop(`ptop') bnobs(`bnobs')   tnobs(`tnobs');


tempvar       trueMu_k; 
qui gen      `trueMu_k'=.;
qui replace  `trueMu_k' = (`2'[1])/(`1'[1])                                in 1;
qui replace  `trueMu_k' = (`2'[_n]-`2'[_n-1])/(`1'[_n]-`1'[_n-1]) in 2/`nclass';

tempvar group tmuk; 
qui gen `group' = . ;
qui gen `tmuk'  = . ;
local gr1 = 1; local gr = 1;
forvalues i=1/`nobs' {;
                        if _perc[`i']>`1'[`gr']  local gr = `gr'+1;
                        local gr1=`gr';
                        qui replace `group' = `gr1'              in `i' ;
				qui replace `tmuk'  = `trueMu_k'[`gr1']  in `i' ;
                       };

/* Generating the distribution function according to its form */
tempvar  y;
_inidis `1' `2' _F _w, nclass(`nclass') dist(`dist');

/* Adjusting the distribution   */
if (`adjust'==1)  qui _expadj _y, group(`group') tmuk(`tmuk') weight(_w);

/* Plotting the Lorenz graph (DASP must be installed)  */
if (`lorenz'==1) clorenz `tmuk' _y , hweight(_w) legend(label(1 "line_45°"       ) label(2 "Aggregated data") label(3 "Ungrouped data"  ) ); 

/* Saving the generated data    */
if `tb'==0 keep _y ;
if `tb'==1 keep _w _y;
qui keep in 1/`nobs';
if("`fname'"=="") local fname = "ungroup_data";
save `"`fname'"', replace;

end;



