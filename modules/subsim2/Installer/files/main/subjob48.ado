/*************************************************************************/
/* SUBSIM: Subsidy Simulation Stata Toolkit  (Version 2.0)               */
/*************************************************************************/
/* Conceived by Dr. Araar Abdelkrim[1] and Dr. Paolo Verme[2]            */
/* World Bank Group (2012-2014)		                                 */
/* 									 */
/* [1] email : aabd@ecn.ulaval.ca                                        */
/* [1] Phone : 1 418 656 7507                                            */
/*									 */
/* [2] email : pverme@worldbank.org                                      */
/*************************************************************************/




#delimit;
capture program drop subjob48;
program define subjob48, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) HGroup(varname) LAN(string) XRNAMES(string)  AGGRegate(string) PCEXP(varname) IPSCH(varname)  FPSCH(varname) PLINE(varname) WAPPR(int 1)];

tokenize `varlist';
_nargs    `varlist';

tempvar price_def;
qui gen `price_def' =1;
forvalues i=1/$indica {;
tempvar Variable EST`i';
qui gen `EST`i''=0;
local tipsch = ""+`ipsch'[`i'];
local tfpsch = ""+`fpsch'[`i'];

if (`wappr'==1) imwsub ``i'' , ipsch(`tipsch') fpsch(`tfpsch') hsize(`hsize');
if (`wappr'==2) {;
                  imwsub_cob_doug ``i'' , ipsch(`tipsch') fpsch(`tfpsch') hsize(`hsize') pcexp(`pcexp');
				  qui replace `price_def' = `price_def' * __tdef;
				};
tempvar imwsub_``i'' ;
qui gen  `imwsub_``i''' = __imwsub;
local nlist `nlist' `imwsub_``i''' ;
cap drop __imwsub;
cap drop __tdef;
};
 
 
if (`wappr'==2) {;
tempvar tot_imp;
qui gen `tot_imp' =( 1 / `price_def' -  1 )*`pcexp' ;
subjobpov  `tot_imp',   hs(`hsize')  lan(`lan')   xrnames(total)  pcexp(`pcexp')  pline(`pline') alpha(1) ;
tempname mat48tot ;
matrix `mat48tot'= e(est); 
};
 
aggrvar `nlist' , xrnames(`xrnames') aggregate(`aggregate');

local slist = r(slist);
local flist = r(flist);
local drlist = r(drlist);
subjobpov `flist',   hs(`hsize')  lan(`lan')   xrnames(`slist')  pcexp(`pcexp')  pline(`pline')  alpha(1) ;
cap drop `drlist';
tempname mat48 ;

matrix `mat48'= e(est);
/*
if (`wappr'==2) {;
local rowsize = rowsof(`mat48');
local colsize = colsof(`mat48');
forvalues i=1/`rowsize' {;
 matrix `mat48'[ `i',`colsize'] = el(`mat48tot',`i',1);
};
};
*/
ereturn matrix est = `mat48';

end;



