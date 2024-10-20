/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.1  )          */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : cnpe                                                        */
/*************************************************************************/


#delim ;
capture program drop _nargs;
program define _nargs, rclass;
version 9.2;
syntax varlist(min=0);
quietly {;
tokenize `varlist';
local k = 1;
mac shift;
while "``k''" ~= "" {; 
local k = `k'+1;
};
};
global indica=`k';
end;

capture program drop cnpquantile2l;
program define cnpquantile2l, rclass sortpreserve;
version 9.2;
args www yyy val gr ng;
local min=0;
preserve;
if ("`gr'" ~="") qui keep if (`gr'==_gn1[`ng']);
sort `yyy';
cap drop if `yyy'>=.;
cap drop if `www'>=.;

tempvar   _ww _qup _pc;
qui gen `_ww'=sum(`www');
qui gen `_pc'=`_ww'/`_ww'[_N];
qui gen `_qup' = `yyy' ;
local ff=0;
local i = 1;
while (`val' > `_pc'[`i']) {;
local i=`i'+1;
};

local ar=`i'-1;
if (`i'> 1) local lqi=`_qup'[`ar']+((`_qup'[`i']-`_qup'[`ar'])/(`_pc'[`i']-`_pc'[`ar']))*(`val'-`_pc'[`ar']);
if (`i'==1) local lqi=`ff'+(max(0,`_qup'[`i'])/(`_pc'[`i']))*(`val');



if(`val'==0) local lqi = 0 ;
if(`val'==1) {;
qui sum `yyy';
local lqi = r(max) ;
};
return scalar lqi=`lqi';
restore;
end;



capture program drop gcnpquantile2l;
program define gcnpquantile2l, rclass sortpreserve;
version 9.2;
args www yyy min max gr ng;
preserve;
if ("`gr'" ~="") qui keep if (`gr'==_gn1[`ng']);
sort `yyy';
cap drop if `yyy'>=.;
cap drop if `www'>=.;
if (_N<101) qui set obs 101;
tempvar  _finqp _ww _qup _pc;
qui gen `_ww'=sum(`www');
qui gen `_pc'=`_ww'/`_ww'[_N];
qui gen `_qup' = `yyy' ;
qui sum `yyy' [aw=`www'];
qui sum  [aw=`www'];
local mina=`r(min)';
local maxa=`r(max)';
local ff=`mina';
if(`min'==0 & `mina'>0) local ff=0;
qui gen  `_finqp'=0;
local step=(`max'-`min')/100;
local i = 1;
forvalues j=0/100 {;
local pcf=`min'+`j' *`step';
local av=`j'+1;
while (`pcf' > `_pc'[`i']) {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) local lqi=`_qup'[`ar']+((`_qup'[`i']-`_qup'[`ar'])/(`_pc'[`i']-`_pc'[`ar']))*(`pcf'-`_pc'[`ar']);
if (`i'==1) local lqi=`ff'+(max(0,`_qup'[`i'])/(`_pc'[`i']))*(`pcf');
qui replace `_finqp'=`lqi' in `av';
};

if(`min'==0 & `mina'>0) qui replace `_finqp' = 0 in 1;
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat `_finqp', matrix (_xx);
restore;
end;




capture program drop cnpe2s;
program define cnpe2s, rclass;
version 9.2;
args ww xxx yyy xval rtype type band approach vgen  gr ng;
preserve;
tempvar www;
if ("`gr'" ~="") qui gen `www'=`ww'*(`gr'== _gn1[`ng']);
if ("`gr'" =="") qui gen `www'=`ww';
cap drop if `yyy'>=.;
cap drop if `www'>=.;
cap drop if `xxx'>=.;
tempvar _ra _npe ste lb ub  _t0 _t1 _t2  _kt5 _vy _vx _vx2 _vx3 _vx4;

cap drop  `_npe' ;
cap drop  `ste' ;
cap drop  `lb' ;
cap drop  `ub' ;
qui gen   `_npe' =0;
qui gen   `ste' =0;
qui gen   `lb' =0;
qui gen   `ub' =0;

if ("`rtype'"=="prc") {;
cnpquantile2l `www' `xxx' `xval'  ;
local xval = `r(lqi)';
};


if ("`approach'"=="nw" & "`type'"=="npe") {;
cap drop `_t1' `_t2' ; 
qui gen `_t1' =`www'*exp(-0.5* ( ((`xval'-`xxx')/`band')^2  )  )*`yyy';
qui gen `_t2' =`www'*exp(-0.5* ( ((`xval'-`xxx')/`band')^2  )  );
qui sum  `_t1',  meanonly ;
local su1 =  `r(sum)';
qui  sum `_t2' ,  meanonly ;
local su2 =  `r(sum)';
local  _npe  = `su1'/`su2';
};





if ("`approach'"=="lle") {;
cap drop `_kt5' `_vy' `_vx' `_vx2';
qui gen `_kt5' = (exp(-0.5* ( ((`xval'-`xxx')/`band')^2  )  )   )^0.5;
qui gen `_vy'=`_kt5'*`yyy';
qui gen `_vx'=`_kt5'*(`xxx'-`xval');
qui gen `_vx2'=0.5*`_kt5'*(`xxx'-`xval')^2;
qui regress `_vy'  `_kt5' `_vx' `_vx2'  [aw = `www'],noconstant;
cap matrix drop _cc;
matrix _cc = e(b);
local _npe = el(_cc,1,1);
};



cap drop `_t1' `_t2' ; 
tempvar _t1 _t2;

qui gen `_t1' =`www'*exp(-0.5* ( ((`xval'-`xxx')/`band')^2  )  )*`yyy';
qui gen `_t2' =`www'*exp(-0.5* ( ((`xval'-`xxx')/`band')^2  )  );
qui sum  `_t1',  meanonly ;
local su1 =  `r(sum)';
qui  sum `_t2' ,  meanonly ;
local su2 =  `r(sum)';
local ey = `su1'/`su2';
cap drop `_t1' `_t2' ; 
tempvar _t1 _t2;
qui gen `_t1' =`www'*exp(-0.5* ( ((`xval'-`xxx')/`band')^2  )  )*(`yyy'-`ey')^2;
qui gen `_t2' =`www'*exp(-0.5* ( ((`xval'-`xxx')/`band')^2  )  )^2;
qui sum  `_t1',  meanonly ;
local su1 =  `r(sum)';
qui  sum `_t2' ,  meanonly ;
local su2 =  `r(sum)';
local cond_var = (`su1'/`su2');
cap drop `_t0' ; 
tempvar _t0 ;
qui gen `_t0'=`www';
qui  sum `_t0' ,  meanonly ;
local su0 =  `r(sum)';
local cond_sd= (`su1'/`su2');
local f_x = `su2'/( `band'* sqrt(2*c(pi)) * `su0' ) ;
local R_k = `su2'/`su0' ;
local ste = (`R_k'*`cond_sd'/(`f_x'*`band'*`su0'))^0.5;

restore;
return scalar npe = `_npe';
return scalar ste =  `ste' ;
end;


capture program drop gcnpe2s;
program define gcnpe2s, rclass;
version 9.2;
args ww xxx yyy min max rtype type band approach vgen tt gr ng ;
preserve;


tempvar www;
if ("`gr'" ~="") qui gen `www'=`ww'*(`gr'== _gn1[`ng']);
if ("`gr'" =="") qui gen `www'=`ww';
cap drop if `yyy'>=.;
cap drop if `www'>=.;
cap drop if `xxx'>=.;

tempvar _ra _npe ste lb ub _t0 _t1 _t2  _kt5 _vy _vx _vx2 _vx3 _vx4;

cap drop `_ra' `_npe' ;
qui gen `_npe' =0;
qui gen  `ste' =0;
qui gen   `lb' =0;
qui gen   `ub' =0;
qui gen `_ra'  =0;
local pas = (`max'-`min')/100;
if (_N<101) qui set obs 101; 

forvalues j=1/101 {;
qui replace `_ra'=`min'+(`j'-1)*`pas' in `j';
};
                  

if ("`rtype'"=="prc") {;
gcnpquantile2l `www' `xxx'   `min' `max' ;
svmat float _xx;
cap matrix drop _xx;
qui replace `_ra'=_xx1; drop _xx1;
};

forvalues j=1/101 {;
if ("`approach'"=="nw" & "`type'"=="npr") {;
cap drop `_t1' `_t2' ; 
qui gen `_t1'=`www'*exp(-0.5* ( ((`_ra'[`j']-`xxx')/`band')^2  )  )*`yyy';
qui replace `_t1'=0  in `j';
qui gen `_t2' =`www'*exp(-0.5* ( ((`_ra'[`j']-`xxx')/`band')^2  )  );
qui replace `_t2' =0  in `j';
qui sum  `_t1',  meanonly ;
local su1 =  `r(sum)';
qui  sum `_t2' ,  meanonly ;
local su2 =  `r(sum)';
local temp = `su1'/`su2';
qui replace `_npe'  = `temp' in `j';
};

if ("`approach'"=="lle") {;
cap drop `_kt5' `_vy' `_vx' `_vx2';
qui gen `_kt5' = (exp(-0.5* ( ((`_ra'[`j']-`xxx')/`band')^2  )  )   )^0.5;
qui gen `_vy'=`_kt5'*`yyy';
qui gen `_vx'=`_kt5'*(`xxx'-`_ra'[`j']);
qui gen `_vx2'=0.5*`_kt5'*(`xxx'-`_ra'[`j'])^2;
qui regress `_vy'  `_kt5' `_vx' `_vx2'  [aw = `www'],noconstant;
cap matrix drop _cc;
matrix _cc = e(b);
qui replace `_npe'  = el(_cc,1,1) in `j';

};

cap drop `_t1' `_t2' ; 
tempvar _t1 _t2 ;
qui gen `_t1'=`www'*exp(-0.5* ( ((`_ra'[`j']-`xxx')/`band')^2  )  )*`yyy';
qui replace `_t1'=0  in `j';
qui gen `_t2' =`www'*exp(-0.5* ( ((`_ra'[`j']-`xxx')/`band')^2  )  );
qui replace `_t2' =0  in `j';
qui sum  `_t1',  meanonly ;
local su1 =  `r(sum)';
qui  sum `_t2' ,  meanonly ;
local su2 =  `r(sum)';
local ey = `su1'/`su2';
cap drop `_t1' `_t2' ; 
qui gen `_t1'=`www'*exp(-0.5* ( ((`_ra'[`j']-`xxx')/`band')^2  )  )*(`yyy'-`ey')^2;
qui replace `_t1'=0  in `j';
qui gen `_t2' =`www'*exp(-0.5* ( ((`_ra'[`j']-`xxx')/`band')^2  )  )^2;
qui replace `_t2' =0  in `j';
qui sum  `_t1',  meanonly ;
local su1 =  `r(sum)';
qui  sum `_t2' ,  meanonly ;
local su2 =  `r(sum)';
local cond_var = (`su1'/`su2');
cap drop `_t0' ; 
qui gen `_t0'=`www';
qui  sum `_t0' ,  meanonly ;
local su0 =  `r(sum)';
local cond_sd= (`su1'/`su2');
local f_x = `su2'/( `band'* sqrt(2*c(pi)) * `su0' ) ;
local R_k = `su2'/`su0' ;
local temp = (`R_k'*`cond_sd'/(`f_x'*`band'*`su0'))^0.5;
qui replace `ste'   = `temp' in `j';
local est = `_npe'[`j'];
qui replace  `lb'   = `est' - `tt'*`temp'  in `j';
qui replace  `ub'   = `est' + `tt'*`temp'  in `j';

if (`j'!=101)  dis "." ,  _continue;
if (`j'/10==round(`j'/10)) dis " "  %4.2f `j' " %";


};
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat `_ra' `_npe' `ste' `lb' `ub', matrix (_xx);
restore;

end;



capture program drop cnpeci;
program define cnpeci, rclass sortpreserve;
version 9.2;
syntax varlist(min=1)[, 
XVAR(varname) 
HWeight(varname) 
HSize(varname) 
HGroup(varname) 
BAND(real 0) 
TYPE(string)
APProach(string) 
MIN(string) 
MAX(string)
RTYPE(string)
XVAL(string)
CONF(string) LEVEL(real 95)
LRES(int 0)  SRES(string) VGEN(string) DGRA(int 1) SGRA(string) EGRA(string) *];


if ("`conf'"=="")  local conf="ts";

  _get_gropts , graphopts(`options') ;
        local options `"`s(graphopts)'"';
/* Errors */

if ("`xvar'"=="") {;
disp as error "You need to specify the varname of xvar (see the help).";
exit;
};

if ("`vgen'"=="") local vgen="no";
if ("`type'"== "ksd") local approach = "nw";

cap drop _cor*; 
cap drop _xx*;	
if ("`hgroup'"!="") {;
preserve;
capture {;
local lvgroup:value label `hgroup';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , clear;
qui count;
forvalues i=1/`r(N)' {;
local grlab`i' = label[`i'];
};
};
};
restore;
qui tabulate `hgroup', matrow(_gn);
cap drop _gn1;
svmat int _gn;
global indica=r(r);
tokenize `varlist';
matrix drop _gn;
};
if ("`hgroup'"=="") {;
tokenize  `varlist';
_nargs    `varlist';
};

if ("`rtype'"=="") local rtype = "lvl";
if ("`type'"=="")  local type = "npr";
if ("`appr'"=="")  local appr = "lle";

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);


qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

local dgr = "no";

if ("`max'" ~= "" ) local dgr = "yes";



tempvar fw;
local _cory  = "";
local label = "";
qui gen `fw'=1;

if ("`hweight'"~="")   {;
 qui sum `hweight';
 qui replace `hweight' =  `hweight' / `r(mean)' ;
};   

if ("`hsize'"  ~="")       qui replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")       qui replace `fw'=`fw'*`hweight';
if ("`approach'"=="")      local approach="lle";
qui su `xvar' [aw=`fw'], detail;            
local tmp = (`r(p75)'-`r(p25)')/1.34;                           
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)';     
                       local h   =     0.9*`tmp'*_N^(-1.0/5.0); 
if ("`type'"=="dnp")   local h   = 1.00927*`tmp'*_N^(-1.0/7.0);  
if (`band'==0) local band=`h';   


if ("`ctitle'"   ~="")     local ftitle ="`ctitle'";
if ("`cstitle'"  ~="")     local stitle ="`cstitle''";

if ("`dgr'" == "no" ){;

tempvar Variable EST STE LL UL ;

qui gen `Variable'="";
qui gen `EST'=0;
qui gen `STE'=0;
qui gen `LL'=0;
qui gen `UL'=0;
local ll=16;

forvalues k = 1/$indica {;

if ("`hgroup'"=="") {;
local label`f'  =  "``k''";
cnpe2s `fw' `xvar' ``k'' `xval'  `rtype' `type' `band'  `approach' `vgen' ;
qui replace `EST'      = `r(npe)' in `k';
qui replace `STE'      = `r(ste)' in `k';
qui replace `LL'      = `r(npe)' -  `tt'*`r(ste)' in `k';
qui replace `UL'      = `r(npe)' +  `tt'*`r(ste)' in `k';

return scalar est`k' = `r(npe)';
qui replace `Variable' = "`label`f''" in `k';
local ll=max(`ll',length("`label`f''"));
};

if ("`hgroup'"!="") {;
local kk = _gn1[`k'];
local label`f'  : label (`hgroup') `kk';
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";
cnpe2s `fw' `xvar'  `1' `xval'  `rtype' `type' `band' `approach' `vgen'  `hgroup' `kk';
qui replace `EST'      = `r(npe)' in `k';
qui replace `STE'      = `r(ste)' in `k';
qui replace `LL'      = `r(npe)' -  `tt'*`r(ste)' in `k';
qui replace `UL'      = `r(npe)' +  `tt'*`r(ste)' in `k';
qui replace `Variable' = "`label`f''" in `k';
local ll=max(`ll',length("`label`f''"));
};

};


if ("`hgroup'"!="") {;
local k = $indica+1;
cnpe2s `fw' `xvar'  `1' `xval'  `rtype' `type' `band' `approach' `vgen'  ;
qui replace `EST'      = `r(npe)'     in `k';
qui replace `STE'      = `r(ste)' in `k';
qui replace `LL'       = `r(npe)' -  `tt'*`r(ste)' in `k';
qui replace `UL'       = `r(npe)' +  `tt'*`r(ste)' in `k';
qui replace `Variable' = "Population" in `k';
};



local dec = 6;
                    local comp = "Variable(s)";
if ("`hgroup'"!="") local comp = "Groups(s)";
      tempname table;
    .`table'  = ._tab.new, col(5)  separator(0) lmargin(0);
    .`table'.width  `ll'|16 16 20 20 ;
	.`table'.strcolor . . . . .  ;
	.`table'.numcolor yellow yellow yellow  yellow  yellow  ;
	.`table'.numfmt %16.0g  %16.`dec'f %16.`dec'f %16.`dec'f %16.`dec'f ;
  
       if ("`hsize'"!="")   di as text     "{col 4}Household size     :  `hsize'"  ;
       if ("`hweight'"!="") di as text     "{col 4}Sampling weight    :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 4}Group variable     :  `hgroup'" ;
  						  		
	.`table'.sep, top;
	.`table'.titles "`comp' " "Estimated value"   "  STE  "  "Lower Band of CI" "Upper Band of CI";

	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/$indica{;
             .`table'.numcolor white yellow  yellow  yellow  yellow  ;
		  if ("`conf'"=="ts")   .`table'.row `Variable'[`i'] `EST'[`i']  `STE'[`i']  `LL'[`i']  `UL'[`i'] ; 
		  if ("`conf'"=="lb")   .`table'.row `Variable'[`i'] `EST'[`i']  `STE'[`i']  `LL'[`i']  "Infinity" ; 
		  if ("`conf'"=="ub")   .`table'.row `Variable'[`i'] `EST'[`i']  `STE'[`i']  "Infinity"  `UL'[`i'] ; 
             };
  if ("`hgroup'"=="") {;			 
  .`table'.sep,bot;
  };
  if ("`hgroup'"!="") {;
  .`table'.sep, mid;
    local i = $indica+1;
  .`table'.numcolor white yellow  yellow  yellow  yellow   ;
		  if ("`conf'"=="ts")   .`table'.row `Variable'[`i'] `EST'[`i']  `STE'[`i']  `LL'[`i']  `UL'[`i'] ; 
		  if ("`conf'"=="lb")   .`table'.row `Variable'[`i'] `EST'[`i']  `STE'[`i']  `LL'[`i']  "Infinity" ; 
		  if ("`conf'"=="ub")   .`table'.row `Variable'[`i'] `EST'[`i']  `STE'[`i']  "Infinity"  `UL'[`i'] ; 
  .`table'.sep,bot;
  };


}; //DGRAPH NO




if ("`dgr'" ~= "no" ){;




if ($indica>1) local tits="s";
                     local ftitle = "Non parametric regression";


if (`band' >= 1 ) local ba = round(`band'*100)/100;
if (`band'  < 1 ) local ba = round(`band'*100000)/100000;

if ("`approach'"=="nw")  local stitle = "(Nadaraya-Watson Estimation Approach | Bandwidth = `ba' )";
if ("`approach'"=="lle") local stitle = "(Linear Locally Estimation Approach  | Bandwidth = `ba' )";  
    
local ytitle = "E(Y|X)";
local xtitle = "X values";
if ("`rtype'"=="prc") local xtitle = "Percentiles (p)";
if ("`cytitle'"  ~="") local ytitle ="`cytitle'";
if ("`cxtitle'"  ~="") local xtitle ="`cxtitle'";
qui count;
qui sum `1';
if ("`min'"  =="")      local min =`r(min)';
if ("`max'"  =="")      local max =`r(max)';
if ("`type'"  =="")     local type ="yes";
if ("`approach'"=="")   local approach = "lle";

if (r(N)<101) set obs 101;



dis "ESTIMATION IN PROGRESS";

local color1 blue;
local color2 red;
local color3 green;
local color4 yellow;
local color5 maroon;
local color6 gray;

forvalues k = 1/$indica {;
                                     local _cory  = "`_cory'" + " _cory`k'";
if ("`conf'"=="ts") local mcmd   = "`mcmd'" + "(rarea  _coryl`k'  _coryu`k' _corx , fcolor(`color`k''%30) lcolor(white) lwidth(none)) ";
if ("`conf'"=="ts") local mcmd2  = "`mcmd2'" + "(line  _cory`k' _corx, lcolor(black) lwidth(thin)) ";


dis "`mylabel'" ;
if ("`hgroup'"=="") {;
local label`k'   = "``k''";
dis "Computation for variable -> ``k''"; 
gcnpe2s `fw' `xvar' ``k'' `min' `max'  `rtype' `type' `band'  `approach' `vgen' `tt';
};


if ("`hgroup'"!="") {;
local kk = _gn1[`k'];
local label`k'   = "Group: `kk'";
local labelv  : label (`hgroup') `kk';
if (length("`labelv'")>2) local label`k'="`labelv'";
dis "Computation for the group -> `label`k''"; 
gcnpe2s `fw' `xvar' `1'  `min' `max'  `rtype' `type' `band'  `approach' `vgen' `tt'  `hgroup' `kk';
};

svmat float _xx;
if ("`conf'"=="ts") {;
 rename _xx2 _cory`k';
 rename _xx4 _coryl`k';
 rename _xx5 _coryu`k';
};

if ("`conf'"=="lb"){;
rename _xx4 _cory`k';
};

if ("`conf'"=="ub"){;
 rename _xx5 _cory`k';
};

cap drop _xx*;


};

dis "END: WAIT FOR THE GRAPH...";


cap drop _nl;
qui gen _nl=0;
local pas = (`max'-`min')/100;
local m5 = (`max'-`min')/5;
local step=(`max'-`min')/100;
cap drop _corx;
qui gen _corx = `min'+(_n-1)*`step';



if( `lres' == 1) {;
set more off;
list _corx _cory* in 1/101;
};

if ($indica>1) local tits="s";
                     local ftitle = "Non parametric regression";
if ("`type'"=="dnp") local ftitle = "Non parametric derivative regression";
if ("`type'"=="ksd") local ftitle = "Conditional standard deviation";

if (`band' >= 1 ) local ba = round(`band'*100)/100;
if (`band'  < 1 ) local ba = round(`band'*100000)/100000;

if ("`approach'"=="nw")  local stitle = "(Nadaraya-Watson Estimation Approach | Bandwidth = `ba' )";
if ("`approach'"=="lle") local stitle = "(Linear Locally Estimation Approach  | Bandwidth = `ba' )";  
if ("`type'"=="ksd")     local stitle = "(Kernel estimator | Bandwidth = `ba' )";      
local ytitle = "E(Y|X)";
if ("`type'"=="ksd")  local ytitle = "STD(Y|X)";
if ("`type'"=="dnp")  local ytitle = "dE[Y|X]/dX";
local xtitle = "X values (`xvar' variable)";
if ("`rtype'"=="prc") local xtitle = "Percentiles (p)";
if ("`cytitle'"  ~="") local ytitle ="`cytitle'";
if ("`cxtitle'"  ~="") local xtitle ="`cxtitle'";

                      local typeb = "Lower";
if ("`conf'"=="ub")   local typeb = "Upper";

if (`dgra'!=0) {;
if ("`conf'"=="ts"){;

forvalues k = 1/$indica {;
local mylabel `mylabel' label(`k' `label`k'')  ;
local mylo `mylo' `k' ;
};

twoway `mcmd' `mcmd2'  in 1/101, 
legend(order(`mylo'))
legend(`mylabel')
title("`ftitle' Curve(s)")
subtitle("Confidence interval(`level'%)")
xtitle(`xtitle')
ytitle(`ytitle')
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
plotregion(margin(zero))
graphregion(margin(medlarge))
legend(size(medsmall))
graphregion(fcolor(white) ifcolor(white))
`options'
;
};

if ("`conf'"~="ts") {;
forvalues k = 1/$indica {;
local mylabel `mylabel' label(`k' `label`k'')  ;
local mylo `mylo' `k' ;
};
twoway (line `_cory'  _corx in 1/101) , 
legend(order(`mylo'))
legend(`mylabel')
title("`titcur' Curve(s)")
subtitle("`typeb' bound(`level'%)")
xtitle(`xtitle') 
ytitle(`typeb' " band of " `ytitle')
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max')
plotregion(margin(zero))
graphregion(margin(medlarge))
legend(size(medsmall))
graphregion(fcolor(white) ifcolor(white))
`options'
;
};
};
};
cap matrix drop _xx;
if( "`sres'" ~= "") {;
preserve;
keep _corx _cory*;
save `"`sres'"', replace;
restore;
};

if( "`sgra'" ~= "") {;
graph save `"`sgra'"', replace;
};

if( "`egra'" ~= "") {;
graph export `"`egra'"', replace;
};

cap drop _gn1;
cap drop _cor*;
cap drop _nl;


end;

