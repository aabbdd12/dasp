/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 1.5  )          */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Université Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : _cumdis                                                     */
/*************************************************************************/

#delim ;
capture program drop _cumdis;
program define _cumdis, rclass;
version 9.2;
syntax anything [,  nobs(int 1000) pbot(real 0) ptop(real 0) bnobs(int 0)  mnobs(int 0)   tnobs(real 0)];

tempvar sw;
qui gen double `sw' = 0;
tempvar  perc;
qui gen `perc'   = 0;
local mnobs = `nobs'-`bnobs'-`tnobs';
local  pathm          = (1 - `pbot' - `ptop')/`mnobs';
if (`pbot'!=0 & `bnobs' !=0) {;
local trbobs = `pbot'/(1-`pbot'-`ptop')*`mnobs';
local pathb          =  `pathm'*(`trbobs'/`bnobs');
qui replace `perc'   = _n*`pathb' in 1/`bnobs';
qui replace `sw'     = `pathb'    in 1/`bnobs';
};

local bm = `bnobs' +  1;
local em = `bnobs'   + `mnobs';
tempvar vr; 
qui gen double     `vr' = 0;
qui replace        `vr' = `pathm'               in `bm'/`em';
qui replace `perc'      = `pbot'+ sum(`vr')     in `bm'/`em';
qui replace `sw'        = `pathm'               in `bm'/`em';

if (`ptop'!=0 & `tnobs' !=0) {;
local trtobs = `ptop'/(1-`pbot'-`ptop')*(`mnobs');
local patht           =  `pathm'*(`trtobs'/`tnobs');
qui replace     `vr'  = 0;
local bt     = `nobs'-`tnobs' +  1;
local et     = `nobs' ;
qui replace   `vr' = `patht'            in `bt'/`et';
qui replace `perc'   = (1-`ptop')+ sum(`vr')  in `bt'/`et';
qui replace `sw'     =            `patht' in `bt'/`et';
};


tempvar       F ;
qui gen      `F' = 0;
qui {;
cap replace  `F' = `perc' - 0.5*`pathb' in 1/`bnobs';
cap replace  `F' = `perc' - 0.5*`pathm' in `bm'/`em' ;
cap replace  `F' = `perc' - 0.5*`patht' in `bt'/`et' ;
};
cap drop _w;    qui gen _w = `sw';
cap drop _F;    qui gen _F = `F';
cap drop _perc; qui gen _perc = `perc';

end;
