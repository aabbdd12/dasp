/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.0  )          */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Université Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : expadj                                                      */
/* This sub routine was provided in part by M. Antony Shorrocks          */
/*************************************************************************/


#delim ;
cap program drop _expadj;
program define _expadj, rclass;
version 9.2;
syntax varlist(min=1 max=1)[,  group(string) tmuk(string) weight(string)];

tokenize `varlist';

qui tab `group'; local nclass=`r(r)'; local nclass_1 = `nclass'-1;
tempvar trueMu_k ge_muk; 
qui gen `ge_muk'   = .;
qui gen `trueMu_k' = .;
forvalues i=1/`nclass' {;
				 qui sum `1'    [aw=`weight']     if `group'==`i';
				 qui replace `ge_muk' = `r(mean)'   in `i'; 
				 qui sum `tmuk' [aw=`weight']  if `group'==`i';
				 qui replace `trueMu_k' = `r(mean)' in `i';
				};


/* First Adjustment */

tempvar ya1;     
gen    `ya1'=.;

/* Bottom */ 
qui replace `ya1' = (`trueMu_k'[1]/`ge_muk'[1])*(`1')                     if (`1'<`ge_muk'[1] );

/* Midlle */ 
forvalues i=1/`nclass_1' {;
				   local tangent_1 = ((`trueMu_k'[`i'+1]-`trueMu_k'[`i'])/(`ge_muk'[`i'+1]-`ge_muk'[`i']));
				   qui replace `ya1' = `trueMu_k'[`i']+`tangent_1'*(`1'-`ge_muk'[`i'])  if (`1'>=`ge_muk'[`i'] & `1'<`ge_muk'[`i'+1] );
				  };  
/* Top */ 
qui replace `ya1' = (`trueMu_k'[`nclass']/`ge_muk'[`nclass'])*(`1')       if (`1'>=`ge_muk'[`nclass'] );


/* Second Adjustment */
tempvar ck Ad1Mu_k; gen `ck' = .; 
qui replace `ck'= 0 in 1;
qui sum `ya1' if `group'== 1; 
forvalues i=2/`nclass' {;
				qui sum `ya1' [aw=`weight'] if `group'== (`i'-1);   local max= `r(max)';
				qui sum `ya1' [aw=`weight'] if `group'== (`i');     local min= `r(min)';
				qui replace `ck'= 0.5*(`max'+`min')   in `i'; 
				};

gen `Ad1Mu_k' = .;
forvalues i=1/`nclass' {;
				qui sum `ya1'     [aw=`weight']         if `group'==`i';     
				qui replace `Ad1Mu_k' = `r(mean)'   in `i';
			     };


tempvar ya2; qui gen `ya2'=.;
forvalues i=1/`nclass' {;
                          if (`trueMu_k'[`i'] > `Ad1Mu_k'[`i'] & `i'< `nclass') {;
                                  local tangent2 = ( `ck'[`i'+1] - `trueMu_k'[`i'] )/( `ck'[`i'+1] - `Ad1Mu_k'[`i'] ) ;
                                  qui replace `ya2' = `ck'[`i'+1] - `tangent2'* (`ck'[`i'+1]-`ya1')  if `group'==`i';
                                 };
			         else  {;
                                   local tangent2 = (  `trueMu_k'[`i'] - `ck'[`i'] )/( `Ad1Mu_k'[`i'] - `ck'[`i'] ) ;
                                   qui replace `ya2' = `ck'[`i'] + `tangent2'* (`ya1' - `ck'[`i'])   if `group'==`i';                
                                  };
                        };

sum `ya2' [aw=`weight']; 
qui replace _y=`ya2'/`r(mean)';
end;
