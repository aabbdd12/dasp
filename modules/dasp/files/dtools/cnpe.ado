/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3  )          */
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


capture program drop gcnpquantile2l;
program define gcnpquantile2l, rclass sortpreserve;
version 9.2;
args www yyy min max gr ng;
preserve;
if ("`gr'" ~="") qui keep if (`gr'==gn1[`ng']);
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




capture program drop gcnpe2;
program define gcnpe2, rclass;
version 9.2;
args ww xxx yyy min max rtype band approach vgen  gr ng;
preserve;
tempvar www;
if ("`gr'" ~="") qui gen `www'=`ww'*(`gr'== _gn1[`ng']);
if ("`gr'" =="") qui gen `www'=`ww';
cap drop if `yyy'>=.;
cap drop if `www'>=.;
cap drop if `xxx'>=.;



tempvar _ra _npe  _t1 _t2  _kt5 _vy _vx _vx2 _vx3 _vx4;

cap drop `_ra' `_npe' ;
qui gen `_npe' =0;
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
if ("`approach'"=="nw") {;
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

};
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat `_npe' , matrix (_xx);
restore;

if ("`vgen'"=="yes") {; 
qui count;
local NN=`r(N)';
local stp0=`NN'/100;
set more off;
if (`NN'>100) dis "WAIT: Estimation of in progress: ==>>";
local stp=`stp0';
local jj=0;
local pr=10;
local sym = ":";

if ("`gr'" ~="") qui gen `www'=`ww'*(`gr'== _gn1[`ng']);
if ("`gr'" =="") qui gen `www'=`ww';


tempvar  _npe  _t1 _t2  _kt5 _vy _vx _vx2 _vx3 _vx4;
cap drop `_npe' ;
qui gen `_npe' = 0;
qui count;                   
forvalues j=1/`r(N)' {;

if ("`approach'"=="nw") {;
cap drop `_t1' `_t2' ; 
qui gen `_t1'=`www'*exp(-0.5* ( ((`xxx'[`j']-`xxx')/`band')^2  )  )*`yyy';
qui replace `_t1'=0  in `j';
qui gen `_t2' =`www'*exp(-0.5* ( ((`xxx'[`j']-`xxx')/`band')^2  )  );
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
qui gen `_kt5' = (exp(-0.5* ( ((`xxx'[`j']-`xxx')/`band')^2  )  )   )^0.5;
qui gen `_vy'=`_kt5'*`yyy';
qui gen `_vx'=`_kt5'*(`xxx'-`xxx'[`j']);
qui gen `_vx2'=0.5*`_kt5'*(`xxx'-`xxx'[`j'])^2;
qui regress `_vy'  `_kt5' `_vx' `_vx2'  [aw = `www'], noconstant;
cap matrix drop _cc;
matrix _cc = e(b);
qui replace `_npe'  = el(_cc,1,1) in `j';
};

if (`j'>=`stp' & (`NN'>=100)) {;
dis "`sym'", _continue ;
local stp = `stp'+`stp0';
local jj=`jj' + 1;
if (`jj'/2 == round(`jj'/2)) local sym = ":";
if (`jj'/2 != round(`jj'/2)) local sym = ".";
};
if (`jj'==10 ) {;
if (`NN'>=100) dis "`pr'%";
local jj=0;
local pr=`pr'+10;
};
};
if (`NN'>=100)  dis "<== END";
cap drop _npe;
gen _npe = `_npe';
};
end;





capture program drop gnpde2;
program define gnpde2, rclass;
version 9.2;
args ww xxx yyy min max rtype band approach vgen gr ng;

preserve;
tempvar www;
if ("`gr'" ~="") qui gen `www'=`ww'*(`gr'== _gn1[`ng']);
if ("`gr'" =="") qui gen `www'=`ww';
cap drop if `yyy'>=.;
cap drop if `www'>=.;
cap drop if `xxx'>=.;


tempvar _ra  _nped  pasA pasA1 pasB pasC pasC1 pasD _kt5 _vy _vx _vx2 _vx3 _vx4;

cap drop `_ra'  `_nped' ;
gen `_nped' =0;
gen `_ra' =0;


local pas = (`max'-`min')/100;
if (_N<101) qui set obs 101;                   
gen _s2 = sum( `www' ); 

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
if ("`approach'"=="nw") {;
            qui gen `pasA'=`www'*((`xxx'-`_ra' [`j'])/(`band'^2)*exp(-0.5*((`_ra' [`j']-`xxx')/`band')^2))*(`yyy');
            qui sum `pasA', meanonly;
            local supA=`r(mean)';
            
            qui gen `pasA1'=`www'*exp(-0.5*((`_ra' [`j']-`xxx')/`band')^2)*`yyy';
            qui sum `pasA1', meanonly;
            local supA1=`r(mean)';
            
            qui gen `pasB'=`www'*exp(-0.5*((`_ra' [`j']-`xxx')/`band')^2);
             qui sum `pasB', meanonly;
            local supB=`r(mean)';
        
            qui gen `pasC'=`www'*((`xxx'-`_ra' [`j'])/(`band'^2)*exp(-0.5*((`_ra' [`j']-`xxx')/`band')^2));
            qui sum `pasC', meanonly;
            local supC=`r(mean)';
     
            qui gen `pasC1'=`www'*exp(-0.5*((`_ra' [`j']-`xxx')/`band')^2);
             qui sum `pasC1', meanonly;
            local supC1=`r(mean)';
           
            qui gen `pasD'=`www'*exp(-0.5*((`_ra' [`j']-`xxx')/`band')^2)*`yyy';
            qui sum `pasD', meanonly;
            local supD=`r(mean)';
            
            local val=((`supA1'+`supA')/`supB')-((`supC1'+`supC')*`supD')/`supB'^2;
            qui replace `_nped'  = `val' in `j';
cap drop `pasA' `pasA1' `pasB' `pasC' `pasC1' `pasD' ;
};


if ("`approach'"=="lle") {;


cap drop `_kt5' `_vy' `_vx' `_vx2';
qui gen `_kt5' = (exp(-0.5* ( ((`_ra' [`j']-`xxx')/`band')^2  )  )   )^0.5;
qui gen `_vy' =`_kt5'*`yyy';
qui gen `_vx' =`_kt5'*(`xxx'-`_ra' [`j']);
qui gen `_vx2'=0.5*`_kt5'*(`xxx'-`_ra' [`j'])^2 ;
qui regress `_vy'   `_kt5' `_vx' `_vx2'  [aw=`www'], noconstant;
cap matrix drop cc;
matrix cc = e(b);
qui replace `_nped'  = el(cc,1,2) in `j';
};

};



qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat `_nped', matrix (_xx);
restore;

if ("`vgen'"=="yes") {; 


if ("`gr'" ~="") qui gen `www'=`ww'*(`gr'== _gn1[`ng']);
if ("`gr'" =="") qui gen `www'=`ww';


tempvar  _npe  _t1 _t2  _kt5 _vy _vx _vx2 _vx3 _vx4;
cap drop `_npe' ;
qui gen `_npe' = 0;
qui count;                   
forvalues j=1/`r(N)' {;

if ("`approach'"=="nw") {;
		            qui gen `pasA'=`www'*((`xxx'-`xxx' [`j'])/(`band'^2)*exp(-0.5*((`xxx' [`j']-`xxx')/`band')^2))*(`yyy');
            qui sum `pasA', meanonly;
            local supA=`r(mean)';
            
            qui gen `pasA1'=`www'*exp(-0.5*((`xxx' [`j']-`xxx')/`band')^2)*`yyy';
            qui sum `pasA1', meanonly;
            local supA1=`r(mean)';
            
            qui gen `pasB'=`www'*exp(-0.5*((`xxx' [`j']-`xxx')/`band')^2);
             qui sum `pasB', meanonly;
            local supB=`r(mean)';
        
            qui gen `pasC'=`www'*((`xxx'-`xxx' [`j'])/(`band'^2)*exp(-0.5*((`xxx' [`j']-`xxx')/`band')^2));
            qui sum `pasC', meanonly;
            local supC=`r(mean)';
     
            qui gen `pasC1'=`www'*exp(-0.5*((`xxx' [`j']-`xxx')/`band')^2);
             qui sum `pasC1', meanonly;
            local supC1=`r(mean)';
           
            qui gen `pasD'=`www'*exp(-0.5*((`xxx' [`j']-`xxx')/`band')^2)*`yyy';
            qui sum `pasD', meanonly;
            local supD=`r(mean)';
            
            local val=((`supA1'+`supA')/`supB')-((`supC1'+`supC')*`supD')/`supB'^2;
            qui replace `_nped'  = `val' in `j';
		cap drop `pasA' `pasA1' `pasB' `pasC' `pasC1' `pasD' ;

};

if ("`approach'"=="lle") {;

cap drop `_kt5' `_vy' `_vx' `_vx2';
qui gen `_kt5' = (exp(-0.5* ( ((`xxx' [`j']-`xxx')/`band')^2  )  )   )^0.5;
qui gen `_vy' =`_kt5'*`yyy';
qui gen `_vx' =`_kt5'*(`xxx'-`xxx' [`j']);
qui gen `_vx2'=0.5*`_kt5'*(`xxx'-`xxx' [`j'])^2 ;
qui regress `_vy'   `_kt5' `_vx' `_vx2'  [aw=`www'], noconstant;
cap matrix drop cc;
matrix cc = e(b);
qui replace `_nped'  = el(cc,1,2) in `j';
};


};
cap drop _nped;
gen _nped = `_nped';
};
end;






capture program drop cnpquantile2l;
program define cnpquantile2l, rclass sortpreserve;
version 9.2;
args www yyy val gr ng;
local min=0;
preserve;
if ("`gr'" ~="") qui keep if (`gr'==gn1[`ng']);
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



capture program drop cnpe2;
program define cnpe2, rclass;
version 9.2;
args ww xxx yyy xval rtype band approach vgen  gr ng;
preserve;
tempvar www;
if ("`gr'" ~="") qui gen `www'=`ww'*(`gr'== _gn1[`ng']);
if ("`gr'" =="") qui gen `www'=`ww';
cap drop if `yyy'>=.;
cap drop if `www'>=.;
cap drop if `xxx'>=.;



tempvar _ra _npe  _t1 _t2  _kt5 _vy _vx _vx2 _vx3 _vx4;

cap drop  `_npe' ;
qui gen   `_npe' =0;

         

if ("`rtype'"=="prc") {;
cnpquantile2l `www' `xxx' `xval'  ;
local xval = `r(lqi)';
};


if ("`approach'"=="nw") {;
cap drop `_t1' `_t2' ; 
qui gen `_t1'=`www'*exp(-0.5* ( ((`xval'-`xxx')/`band')^2  )  )*`yyy';
qui replace `_t1'=0  in `j';
qui gen `_t2' =`www'*exp(-0.5* ( ((`xval'-`xxx')/`band')^2  )  );
qui replace `_t2' =0  in `j';
qui sum  `_t1',  meanonly ;
local su1 =  `r(sum)';
qui  sum `_t2' ,  meanonly ;
local su2 =  `r(sum)';
local _npe = `su1'/`su2';
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

return scalar npe = `_npe';
restore;

end;




capture program drop npde2;
program define npde2, rclass;
version 9.2;
args ww xxx yyy xval rtype band approach vgen gr ng;

preserve;
tempvar www;
if ("`gr'" ~="") qui gen `www'=`ww'*(`gr'== _gn1[`ng']);
if ("`gr'" =="") qui gen `www'=`ww';
cap drop if `yyy'>=.;
cap drop if `www'>=.;
cap drop if `xxx'>=.;


tempvar   _nped  pasA pasA1 pasB pasC pasC1 pasD _kt5 _vy _vx _vx2 _vx3 _vx4;

                 
gen _s2 = sum( `www' ); 

              

if ("`rtype'"=="prc") {;
gcnpquantile2l `www' `xxx'   `xval' ;
local xval = r(lqi);
};

if ("`approach'"=="nw") {;
            qui gen `pasA'=`www'*((`xxx'-`xval')/(`band'^2)*exp(-0.5*((`xval'-`xxx')/`band')^2))*(`yyy');
            qui sum `pasA', meanonly;
            local supA=`r(mean)';
            
            qui gen `pasA1'=`www'*exp(-0.5*((`xval'-`xxx')/`band')^2)*`yyy';
            qui sum `pasA1', meanonly;
            local supA1=`r(mean)';
            
            qui gen `pasB'=`www'*exp(-0.5*((`xval'-`xxx')/`band')^2);
             qui sum `pasB', meanonly;
            local supB=`r(mean)';
        
            qui gen `pasC'=`www'*((`xxx'-`xval')/(`band'^2)*exp(-0.5*((`xval'-`xxx')/`band')^2));
            qui sum `pasC', meanonly;
            local supC=`r(mean)';
     
            qui gen `pasC1'=`www'*exp(-0.5*((`xval'-`xxx')/`band')^2);
             qui sum `pasC1', meanonly;
            local supC1=`r(mean)';
           
            qui gen `pasD'=`www'*exp(-0.5*((`xval'-`xxx')/`band')^2)*`yyy';
            qui sum `pasD', meanonly;
            local supD=`r(mean)';
            
            local val=((`supA1'+`supA')/`supB')-((`supC1'+`supC')*`supD')/`supB'^2;
            local _npe  = `val';
cap drop `pasA' `pasA1' `pasB' `pasC' `pasC1' `pasD' ;
};


if ("`approach'"=="lle") {;
cap drop `_kt5' `_vy' `_vx' `_vx2';
qui gen `_kt5' = (exp(-0.5* ( ((`xval'-`xxx')/`band')^2  )  )   )^0.5;
qui gen `_vy' =`_kt5'*`yyy';
qui gen `_vx' =`_kt5'*(`xxx'-`xval');
qui gen `_vx2'=0.5*`_kt5'*(`xxx'-`xval')^2 ;
qui regress `_vy'   `_kt5' `_vx' `_vx2'  [aw=`www'], noconstant;
cap matrix drop cc;
matrix cc = e(b);
local _npe  = el(cc,1,2);
};


return scalar npe = `_npe';
restore;



end;






capture program drop cnpe;
program define cnpe, rclass sortpreserve;
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
LRES(int 0)  SRES(string) VGEN(string) DGRA(int 1) SGRA(string) EGRA(string) *];

_get_gropts , graphopts(`options') ;
	local goptions `"`s(graphopts)'"';
/* Errors */

if ("`xvar'"=="") {;
disp as error "You need to specify the varname of xvar (see the help).";
exit;
};
if ("`vgen'"=="") local vgen="no";

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
dis "In progress ...";

tempvar Variable EST ;

qui gen `Variable'="";
qui gen `EST'=0;
local ll=16;

forvalues k = 1/$indica {;

if ("`hgroup'"=="") {;
local label`f'  =  "``k''";

if ("`type'"=="npr") {;
cnpe2 `fw' `xvar' ``k'' `xval'  `rtype' `band'  `approach' `vgen' ;
};
if ("`type'"=="dnp") {;
npde2 `fw' `xvar' ``k'' `xval' `rtype' `band' `approach' `vgen';
};

qui replace `EST'      = `r(npe)' in `k';
return scalar est`k' = `r(npe)';
qui replace `Variable' = "`label`f''" in `k';
local ll=max(`ll',length("`label`f''"));
};

if ("`hgroup'"!="") {;

local kk = _gn1[`k'];
local label`f'  : label (`hgroup') `kk';
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";
if ("`type'"=="npr") {;
cnpe2 `fw' `xvar'  `1' `xval'  `rtype' `band' `approach' `vgen'  `hgroup' `k';
};
if ("`type'"=="dnp") {;
npde2 `fw' `xvar'  `1' `xval'  `rtype' `band' `approach' `vgen'  `hgroup' `k';
};
qui replace `EST'      = `r(npe)' in `k';
qui replace `Variable' = "`label`f''" in `k';
local ll=max(`ll',length("`label`f''"));
};

};


if ("`hgroup'"!="") {;
local k = $indica+1;
if ("`type'"=="npr") {;
cnpe2 `fw' `xvar'  `1' `xval'  `rtype' `band' `approach' `vgen'  ;
};
if ("`type'"=="dnp") {;
npde2 `fw' `xvar'  `1' `xval'  `rtype' `band' `approach' `vgen'  ;
};
qui replace `EST'      = `r(npe)'     in `k';
qui replace `Variable' = "Population" in `k';
};



local dec = 6;
local comp = "Variable(s)";
if ("`hgroup'"!="") local comp = "Groups(s)";
      tempname table;
	.`table'  = ._tab.new, col(2);
	.`table'.width |`ll'|16 |;
	.`table'.strcolor . .   ;
	.`table'.numcolor yellow yellow  ;
	.`table'.numfmt %16.0g  %16.`dec'f  ;
  
       if ("`hsize'"!="")   di as text     "{col 4}Household size     :  `hsize'"  ;
       if ("`hweight'"!="") di as text     "{col 4}Sampling weight    :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 4}Group variable     :  `hgroup'" ;
  						  		
	.`table'.sep, top;
	.`table'.titles "`comp' " "Estimated value"    ;

	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/$indica{;
             .`table'.numcolor white yellow   ;
		     .`table'.row `Variable'[`i'] `EST'[`i']  ; 	        
             };
  if ("`hgroup'"=="") {;			 
  .`table'.sep,bot;
  };
  if ("`hgroup'"!="") {;
  .`table'.sep, mid;
    local i = $indica+1;
  .`table'.numcolor white yellow   ;
  .`table'.row `Variable'[`i'] `EST'[`i']  ; 
  .`table'.sep,bot;
  };


}; //DGRAPH NO




if ("`dgr'" ~= "no" ){;



if ($indica>1) local tits="s";
                     local ftitle = "Non parametric regression";
if ("`type'"=="dnp") local ftitle = "Non parametric derivative regression";


if (`band' >= 1 ) local ba = round(`band'*100)/100;
if (`band'  < 1 ) local ba = round(`band'*100000)/100000;

if ("`approach'"=="nw")  local stitle = "(Nadaraya-Watson Estimation Approach | Bandwidth = `ba' )";
if ("`approach'"=="lle") local stitle = "(Linear Locally Estimation Approach  | Bandwidth = `ba' )";                      local ytitle = "E(Y|X)";
if ("`type'"=="dnp")  local ytitle = "dE[Y|X]/dX";
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

forvalues k = 1/$indica {;

local _cory  = "`_cory'" + " _cory`k'";
local f=`k';
if ("`hgroup'"=="") {;
local label`f'  =  "``k''";
if ("`type'"=="npr") {;
gcnpe2 `fw' `xvar' ``k'' `min' `max'  `rtype' `band'  `approach' `vgen' ;
qui svmat float _xx;
cap matrix drop _xx;
rename _xx1 _cory`k';

if ("`vgen'"=="yes") {;
cap drop _npe_``k'';
qui gen _npe_``k''=_npe  ;
};
};
if ("`type'"=="dnp") {;
 gnpde2 `fw' `xvar' ``k'' `min' `max'  `rtype' `band' `approach' `vgen';
qui svmat float _xx;
cap matrix drop _xx;
rename _xx1 _cory`k';

if ("`vgen'"=="yes") {;
cap drop _nped_``k'';
qui gen  _nped_``k''=_nped  ;
};
};

};

if ("`hgroup'"!="") {;
local kk = _gn1[`k'];
local label`f'  : label (`hgroup') `kk';
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";
if ("`type'"=="npr") {;
gcnpe2 `fw' `xvar'  `1' `min' `max'  `rtype' `band' `approach' `vgen'  `hgroup' `k';
qui svmat float _xx;
cap matrix drop _xx;
rename _xx1 _cory`k';

if ("`vgen'"=="yes") {;
cap drop _npe_`label`f'';
qui gen _npe_`label`f''=_npe;
};
};
if ("`type'"=="dnp") {;
gnpde2 `fw' `xvar'  `1' `min' `max'  `rtype' `band' `approach' `vgen'  `hgroup' `k';
qui svmat float _xx;
cap matrix drop _xx;
rename _xx1 _cory`k';

if ("`vgen'"=="yes") {;
cap drop _nped_`label`f'';
qui gen _nped_`label`f''=_nped  ;
};
};

};

};

preserve;
qui keep in 1/101;
gen _corx=0;
local m5  = (`max'-`min')/5;
local pas = (`max'-`min')/100;
forvalues j=1/101 {;
qui replace _corx=`min'+(`j'-1)*`pas' in `j';
};

if( `lres' == 1) {;
set more off;
list _corx _cory*;
};

quietly {;
if (`dgra'!=0) {; 
line `_cory'  _corx, 
title(`ftitle')
subtitle(`stitle', size(small))
ytitle(`ytitle')
xtitle(`xtitle') 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
plotregion(margin(zero))
legend(
label(1 `label1')
label(2 `label2')
label(3 `label3')
label(4 `label4')
label(5 `label5')
label(6 `label6')
label(7 `label7')
label(8 `label8')
label(9 `label9')
label(10 `label10')
label(11 `label11')
label(12 `label12')
)
`goptions'		
;
};



cap matrix drop _xx;
if( "`sres'" ~= "") {;
keep _corx _cory*;
save `"`sres'"', replace;
};

if( "`sgra'" ~= "") {;
graph save `"`sgra'"', replace;
};

if( "`egra'" ~= "") {;
graph export `"`egra'"', replace;
};

restore;
cap drop _cor*;
cap drop _npe;
cap drop _nped;
cap drop _gn1;
}; // end of quietly

}; // GRAPH YES

end;

