/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 1.5  )          */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : _expex                                                      */
/*************************************************************************/


#delim ;
capture program drop _expex;
program define _expex, rclass;
version 9.2;
syntax varlist(min=2 max=2)[,  nobs(int 1000) pbot(real 0) ptop(real 0) bnobs(int 0)   tnobs(real 0) nclass(int 0)];
preserve;

 tokenize `varlist';
_nargs    `varlist';
if (`1'[`nclass']==1 & `2'[`nclass']!=1 ) {;
        di in r "Data inconsistency: 100 % of the population must have 100% of total income.";
	  exit 198;
exit;
};

if (`1'[`nclass']!=1 & `2'[`nclass']==1 ) {;
        di in r "Data inconsistency: 100 % of the population must have 100% of total income .";
	  exit 198;
exit;
};

local nbt=`bnobs'+`tnobs';
if (`nbt'>=`nobs' ) {;
        di in r "The number of bottom-tail observations plus that of the top-tail observations must be lower than the total number of observations.";
	  exit 198;
exit;
};

local pbt=`pbot'+`ptop';
if (`pbt'>=1-`pbt' ) {;
        di in r "The proportion of bottom group plus that of the top group must be lower than 100%.";
	  exit 198;
exit;
};
tempvar chk2;
qui gen `chk2'=0;
qui replace `chk2'=`2'[_n]-`2'[_n-1] in 2 / `nclass' ;
qui sum `chk2';
if (`r(min)'<0 ) {;
        di in r "Data inconsistency: income shares must increase with the cumulative proportions of the groups.";
	  exit 198;
exit;
};


end;
