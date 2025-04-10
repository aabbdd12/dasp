*! version 1.00  03-Mayo-2017   M. Araar Abdelkrim & M. Paolo verme
/*************************************************************************/
/* TAXSIM: TAX Simulation Stata Toolkit  (Version 1.0)               */
/*************************************************************************/
/* Conceived by Dr. Araar Abdelkrim[1] and Dr. Paolo Verme[2]            */
/* World Bank Group (2012-2016)		                                 */
/* 									 */
/* [1] email : aabd@ecn.ulaval.ca                                        */
/* [1] Phone : 1 418 656 7507                                            */
/*									 */
/* [2] email : pverme@worldbank.org                                      */
/*************************************************************************/




#delimit;
capture program drop itjob45;
program define itjob45, eclass;
version 9.2;
syntax varlist(min=1)[,  HHID(varname) HSize(varname) HGroup(varname) LAN(string) XRNAMES(string) PCEXP(varname) ITSCH(string)  FTSCH(string)  GVIMP(int 0)];

tokenize  `varlist';
_nargs    `varlist';


tempvar Variable EST;
qui gen `EST'=0;

imwit `1' , itsch(`itsch') ftsch(`ftsch') hsize(`hsize');
tempvar suma pcimp ;
cap drop ___suma;
by `hhid', sort : egen float ___suma = total(__imwit) ;


gen `pcimp' = ___suma / `hsize' ;

cap drop ___suma;

itjobineq  `pcimp',   hhid(`hhid')  hs(`hsize')  lan(`lan')   xrnames(`slist')  pcexp(`pcexp')  ;
cap drop `drlist';
tempname mat45 ;
matrix `mat45'= e(est);
/*
if (`wappr'==2) {;
local rowsize = rowsof(`mat47');
local colsize = colsof(`mat47');
forvalues i=1/`rowsize' {;
 matrix `mat47'[ `i',`colsize'] = el(`mat47tot',`i',1);
};

};
*/
ereturn matrix est = `mat45';

end;



