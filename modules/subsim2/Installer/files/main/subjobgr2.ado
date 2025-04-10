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
capture program drop subjobgr2;
program define subjobgr2, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) HGroup(varname) LAN(string) XRNAMES(string) AGGRegate(string) PCEXP(varname) IPSCH(varname) MIN(real 0) MAX(real 1000) OGR(string) ];

tokenize `varlist';
_nargs    `varlist';

forvalues i=1/$indica {;
tempvar Variable EST`i';
qui gen `EST`i''=0;
local tipsch = ""+`ipsch'[`i'];
incsub ``i'' , ipsch(`tipsch') hsize(`hsize');
tempvar sub_``i'' ;
qui gen  `sub_``i''' = __esub;
local nlist `nlist' `sub_``i''' ;
cap drop __esub;
};

aggrvar `nlist' , xrnames(`xrnames') aggregate(`aggregate');
local  slist = r(slist);
local  flist = r(flist);
local drlist = r(drlist);





local glegend legend(order( ;
if ("`slist'"~="") {;
local xrna  "`slist'";
local xrna : subinstr local xrna " " ",", all ;
local xrna : subinstr local xrna "|" " ", all ;
local count : word count `xrna';
tokenize "`xrna'";
forvalues i = 1/`count' {;
	local `i': subinstr local `i' "," " ", all ;
	local glegend `"`glegend' `i' "``i''""';
	
};

};

local glegend `"`glegend' ))"';



gropt 2 `lan' ;
curvnpe `flist', xvar(`pcexp') hsize(`hsize') 
title(`r(gtitle)')  
xtitle(`r(gxtitle)')
ytitle(`r(gytitle)') 
`glegend'
`r(gstyle)' 
min(`min')
max(`max')
`ogr'
  ;
cap drop `flist';

end;


