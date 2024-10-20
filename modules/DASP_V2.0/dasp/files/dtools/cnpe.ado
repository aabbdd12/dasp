/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 1.5  )          */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universit Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : cnpe                                                        */
/*************************************************************************/


#delim ;





capture program drop cnpe2;
program define cnpe2, rclass;
version 9.2;
args www xxx yyy min max band approach gr ng;
preserve;
if ("`gr'" ~="") qui keep if (`gr'==gn1[`ng']);
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
end;




capture program drop npde2;
program define npde2, rclass;
version 9.2;
args www xxx yyy min max band approach gr ng;

preserve;

if ("`gr'" ~="") qui keep if (`gr'==gn1[`ng']);
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

qui replace `_ra' =`min'+(`j'-1)*`pas' in `j';
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
end;




capture program drop cnpe;
program define cnpe, rclass;
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
LRES(int 0)  SRES(string) DGRA(int 1) SGRA(string) EGRA(string) *];

/* Errors */

if ("`xvar'"=="") {;
disp as error "You need to specify the varname of xvar (see the help).";
exit;
};

_get_gropts , graphopts(`options') ;
	local options `"`s(graphopts)'"';
	
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
preserve;
qui tabulate `hgroup', matrow(gn);
svmat int gn;
global indica=r(r);
tokenize `varlist';
matrix drop gn;
};
if ("`hgroup'"=="") {;
tokenize  `varlist';
_nargs    `varlist';
preserve;
};

if ("`type'"=="") local type = "npr";

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 



tempvar fw;
local _cory  = "";
local label = "";
qui gen `fw'=1;

if ("`ctitle'"   ~="")     local ftitle ="`ctitle'";
if ("`cstitle'"  ~="")     local stitle ="`cstitle''";
if ("`hsize'"  ~="")       qui replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")       qui replace `fw'=`fw'*`hweight';
if ("`approach'"=="")      local approach="nw";
qui su `xvar' [aw=`fw'], detail;            
local tmp = (`r(p75)'-`r(p25)')/1.34;                           
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)';     
                       local h   =     0.9*`tmp'*_N^(-1.0/5.0); 
if ("`type'"=="dnp")   local h   = 1.00927*`tmp'*_N^(-1.0/7.0);  
if (`band'==0) local band=`h';   


if ($indica>1) local tits="s";
                     local ftitle = "Non parametric regression";
if ("`type'"=="dnp") local ftitle = "Non parametric derivative regression";


if (`band' >= 1 ) local ba = round(`band'*100)/100;
if (`band'  < 1 ) local ba = round(`band'*100000)/100000;

if ("`approach'"=="nw")  local stitle = "(Nadaraya-Watson Estimation Approach | Bandwidth = `ba' )";
if ("`approach'"=="lle") local stitle = "(Linear Locally Estimation Approach  | Bandwidth = `ba' )";                      local ytitle = "E(Y|X)";
if ("`type'"=="dnp")  local ytitle = "dE[Y|X]/dX";
local xtitle = "X values";
if ("`cytitle'"  ~="") local ytitle ="`cytitle'";
if ("`cxtitle'"  ~="") local xtitle ="`cxtitle'";
qui count;
qui sum `1';
if ("`min'"  =="")      local min =`r(min)';
if ("`max'"  =="")      local max =`r(max)';
if ("`type'"  =="")     local type ="yes";
if ("`approach'"=="")   local approach = "nw";

if (r(N)<101) set obs 101;

forvalues k = 1/$indica {;

local _cory  = "`_cory'" + " _cory`k'";
local f=`k';
if ("`hgroup'"=="") {;
local label`f'  =  "``k''";
if ("`type'"=="npr") cnpe2 `fw' `xvar' ``k'' `min' `max' `band' `approach' ;
if ("`type'"=="dnp") npde2 `fw' `xvar' ``k'' `min' `max' `band' `approach' ;
};

if ("`hgroup'"!="") {;
local kk = gn1[`k'];
local label`f'  : label (`hgroup') `kk';
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";

if ("`type'"=="npr") cnpe2 `fw' `xvar'  `1' `min' `max' `band' `approach' `hgroup' `k';
if ("`type'"=="dnp") npde2 `fw' `xvar'  `1' `min' `max' `band' `approach' `hgroup' `k';
};
qui svmat float _xx;
cap matrix drop _xx;
rename _xx1 _cory`k';
};



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
`options'		
;
};



cap matrix drop _xx;
if( "`sres'" ~= "") {;
keep _perc _cory*;
save `"`sres'"', replace;
};

if( "`sgra'" ~= "") {;
graph save `"`sgra'"', replace;
};

if( "`egra'" ~= "") {;
graph export `"`egra'"', replace;
};

restore;
}; // end of quietly

end;

