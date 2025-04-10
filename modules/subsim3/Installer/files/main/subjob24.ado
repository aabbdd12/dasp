*! version 3.00  15-December-2014   M. Araar Abdelkrim & M. Paolo verme
/*************************************************************************/
/* SUBSIM: Subsidy Simulation Stata Toolkit  (Version 3.0)               */
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
capture program drop subjob24;
program define subjob24, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) HGroup(varname) LAN(string) XRNAMES(string)  AGGRegate(string) PCEXP(varname) IPSCH(varname)  FPSCH(varname) elas(varname) UNIT(varname) GVQNT( int 0)];

tokenize `varlist';
_nargs    `varlist';


forvalues i=1/$indica {;
tempvar Variable EST`i';
qui gen `EST`i''=0;
local tipsch = ""+`ipsch'[`i'];
imq0sub ``i'' , ipsch(`tipsch') hsize(`hsize');
tempvar imq0sub_``i'' ;

qui gen  `imq0sub_``i''' = __imq0sub;
if (`gvqnt'==1) {;
cap drop _qnt_``i'' ;
qui gen  _qnt_``i''  = __imq0sub ;
if "`unit'[`i']"~="" local qtem = "( in "+`unit'[`i']+")";
lab var _qnt_``i''  "Per capita quantity of ``i'' `qtem'";
};
local nlist `nlist' `imq0sub_``i''' ;
cap drop __imq0sub;
};

 
aggrvar `nlist' , xrnames(`xrnames') aggregate(`aggregate');

local  slist  `r(slist)';
local  flist  `r(flist)';
local drlist  `r(drlist)';

subjobstat `flist',   hs(`hsize') hgroup(`hgroup') lan(`lan')   xrnames(`slist')  stat(exp_tt) unit(`unit') ;
cap drop `drlist';
tempname mat24 ;
matrix `mat24'= e(est);
local rowsize = rowsof(`mat24');
local colsize = colsof(`mat24') - 1 ;
matrix `mat24' = `mat24'[1..`rowsize', 1..`colsize'];
ereturn matrix est = `mat24';

end;



