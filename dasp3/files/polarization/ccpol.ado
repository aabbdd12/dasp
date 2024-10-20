/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 1.2)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2008)          */
/* Laval   University, Quebec, Canada                                    */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : cplorenz                                                     */
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


#delim cr;
/***********************************************/
/* Intermediate program to compute f(y)^alpha  */
/***********************************************/



cap program drop opth                    
program define opth, rclass 
preserve             
args fw x                        
qui su `x' [aw=`fw'], detail            
local tmp = (`r(p75)'-`r(p25)')/1.34                           
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)'     
local h   = 0.9*`tmp'*_N^(-1.0/5.0)                            
return scalar h =  `h' 
restore 
end

cap program drop oph                    
program define oph, rclass  
args w y m alpha                     
qui su `y' [aw=`w'], detail      
local h  = 0 
      if (`m'==1)  local h = 4.7*_N^-0.5*`r(sd)'*`alpha'^(0.1) // is equal to25
else if  (`m'==2) {
local inter=(`r(p75)'-`r(p25)')
tempvar ly
gen `ly'=ln(`y')
qui sum `ly' [aw=`w']
local ls=`r(sd)'
local h = _N^-0.5 * `inter' * (3.76 + 14.7 *`ls')/((1+1.09*0.0001*`ls')^(7268+15323*`alpha'))
} // is equal to26                 
return scalar h = `h'
end


cap program drop fkerv                    
program define fkerv, rclass  
args w y h alpha                     
cap drop _fker
gen _fker=0
if (`alpha'==0) qui replace _fker=1

if (`alpha'>0) {
tempvar s1 s2
gen `s2' = sum( `w' )
local pi=3.141592653589793100
qui count
if (`r(N)'>1000) dis "WAIT / Treated:", _continue
forvalues i=1/`r(N)' {
cap drop `s1'
gen `s1' = sum( `w' *exp(-0.5* ( ((`y'[`i']-`y')/`h')^2  )  ))
qui replace _fker = (`s1'[_N]/( `h'* sqrt(2*`pi') * `s2'[_N] )) in `i'
if (`i'/1000==round(`i'/1000)) dis  "`i'", _continue 
}

qui replace _fker = _fker^`alpha'
if (`r(N)'>1000) dis "/ END"
}
end


cap program drop polas  
version 9.2                 
program define polas, rclass sortpreserve             
syntax varlist (min=1 max=1) [, RANK(varname) HSize(varname) HWeight(varname) HGroup(varname) GNumber(int 1)  ALpha(string) FAst(string) OPtion(int 1) ]
if ("`rank'"=="")        gsort `1'
if ("`rank'"~="")        gsort `rank'
tokenize `varlist'
qui drop if `1'>=.
qui drop if `1'==0
if ("`hsize'"!="")   qui drop if `hsize'>=.
if ("`hweight'"!="") qui drop if `hweight'>=.
tempvar  hs hw fw 
gen `hw'=1
gen `hs'=1
if ("`hsize'"!="")     qui replace `hs' = `hsize'
if ("`hgroup'" != "")  qui gen _in = (`hgroup' == `gnumber')
tempvar  fwo
qui gen `fwo' = `hs'
if ("`hweight'"!="")   qui replace `fwo'=`hs'*`hweight'
if ("`hgroup'" != "")  qui replace `hs' = `hs' * _in
if ("`hweight'"!="")   qui replace `hw'=`hweight'
gen `fw'=`hs'*`hw'
qui sum `fw', meanonly
local popg=`r(mean)'
tempvar smw smwy l1smwy a ca 
gen `smw'  =sum(`fw')
gen `smwy' =sum(`1'*`fw')
gen `l1smwy'=0
local mu=`smwy'[_N]/`smw'[_N]
local suma=`smw'[_N]
qui count
forvalues i=2/`r(N)' { 
qui replace `l1smwy'=`smwy'[`i'-1]  in `i'
}
gen `a'=`mu'+`1'*((1.0/`smw'[_N])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[_N])*(2.0*`l1smwy'+`fw'*`1') 
#delim ;
cap drop _ca;
gen _ca=0;
if ("`rank'"=="`1'") {;
qui replace _ca =   _fker*`a'/(2.0*`mu'^(1.0-`alpha'));
};


if ("`rank'"~="`1'") {;
qui sum `rank'  [aw=`fw'];
local mur = `r(mean)';
qui replace _ca =   _fker*`a'/(2.0*`mu'^(1.0-`alpha'))*(`mur'/`mu')^(`alpha');
};
end;



#delim ;
capture program drop plorenz2;
program define plorenz2, rclass;
version 9.2;
args www yyy rank type min max alpha gr ng;
preserve;
if ("`gr'" ~="") qui keep if (`gr'==gn1[`ng']);
cap drop if `yyy'>=.;
cap drop if `yyy'>==0;
cap drop if `www'>=.;
sort `rank';
if (_N<101) qui set obs 101;
cap drop _ww;
cap drop _lp;
gen _ww = sum(`www');
cap drop _pc;
qui sum _ww;
gen _pc=_ww/r(max);
if (`rank'!=-1) polas `yyy' , hweight(`www') rank(`rank') alpha(`alpha');
if (`rank'==-1) polas `yyy' , hweight(`www') alpha(`alpha');
qui sum _ca;
gen _lp=sum(_ca)/`r(sum)';
cap drop _finlp;
gen _finlp=0;
local i = 1;
local step=(`max'-`min')/100;
local i = 1;
forvalues j=0/100 {;
local pcf=`min'+`j' *`step';
local av=`j'+1;
while (`pcf' > _pc[`i']) {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) local lpi=_lp[`ar']+((_lp[`i']-_lp[`ar'])/(_pc[`i']-_pc[`ar']))*(`pcf'-_pc[`ar']);
if (`i'==1) local lpi=0+((_lp[`i'])/(_pc[`i']))*(`pcf');
qui replace _finlp=`lpi' in `av';
};
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat _finlp, matrix (_xx);
restore;
end;

capture program drop ccpol;
program define ccpol, rclass;
version 9.2;
syntax varlist(min=1)[, HWeight(varname) HSize(varname) HGroup(varname)
 RANK(varname) MIN(real 0) MAX(real 1) ALpha(real 0.0) type(string) DIF(string)
 LRES(int 0)  SRES(string) DGRA(int 1) SGRA(string) EGRA(string) *];

if (`min' < 0) {;
 di as err "min should be >=0"; exit;
};
if (`max' > 1) {;
 di as err "max should be <=1"; exit;
};

if (`max' <= `min') {;
 di as err "max should be greater than min"; exit;
};
if ("`dif'"=="no") local dif="";

_get_gropts , graphopts(`options') ;
	local options `"`s(graphopts)'"';
	
if ("`hgroup'"!="") {;
preserve;
capture {;
local lvgroup:value label `hgroup';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , replace;
qui count;
forvalues i=1/`r(N)' {;
local tem=value[`i'];
local grlab`tem' = label[`i'];
};
};
};
restore;
preserve;
qui tabulate `hgroup', matrow(gn);
svmat int gn;
global indica=r(r);
tokenize `varlist';
};
if ("`hgroup'"=="") {;
tokenize `varlist';
_nargs    `varlist';
preserve;
};



qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 


local l45=$indica+1;
local _cory  = "";
local label = "";
if ("`dif'"=="" & "`type'"~="gen" & "`type'"~="abs") local label1 =  "45° line";
local cl=1;
if ("`rank'"!=""){;
forvalues k = 1/$indica {;
 local cl = `cl'*("``k''"!="`rank'");
};
};
if (($indica==1|"`hgroup'"~="") & "`rank'"=="`1'") local cl=2;
 /* quietly{; */
local tit1="Cumulative Polarization"; 
local tit2="CP"; 
local tit3="";
local tit4="";
if ("`rank'"!="" & `cl'!=2) {;
local tit1="Concentration";
local tit2="CC";
if (`cl'==0 & "`hgroup'"=="" )  local tit1="Cumulative and Concentration Polarizartion";
};
if ("`type'"=="gen") {;
local tit3="Generalised ";
local tit4="G";
};
if ("`type'"=="abs") {;
local tit4="A";
local tit3="Absolute ";
};
if ("`dif'"=="c1") {;
local tit0="Difference Between ";
};
local tit_s="";
if ($indica>1) local tit_s="s";
local ftitle = "`tit0'`tit3'"+"`tit1' Curve`tit_s'";
local ytitle = "`tit4'`tit2'(p)";
if (`cl'==0 & "`hgroup'"=="") local ytitle = "`tit4'CP(p) & `tit4'CC(p)";
if (("`dif'"=="ds") & ("`type'"~="gen") & ("`type'"~="abs")  & ("`group'"=="") ) {;
local ftitle = "Deficit share curve`tit_s'";
local ytitle = "p - `tit4'`tit2'(p)";
if (`cl'==0 & "`hgroup'"=="" )  local ytitle = "p - `tit4'CP(p) & p - `tit4'CC(p) ";
};
if ("`dif'"=="c1") local ytitle ="Difference";
if ("`ctitle'"  ~="")     local ftitle ="`ctitle'";
tempvar fw;
gen `fw'=1;
if ("`hsize'"   ~="")     replace `fw'=`fw'*`hsize';
if ("`hweight'" ~="")     replace `fw'=`fw'*`hweight';
local xtitle = "Percentiles (p)";
if ("`cytitle'"  ~="") local ytitle ="`cytitle'";
if ("`cxtitle'"  ~="") local xtitle ="`cxtitle'";

qui count;
gen _hh=0;
if (r(N)<101) set obs 101;
if ("`dif'"=="" & "`type'"~="gen" & "`type'"~="abs" ) local _cory = "`_cory'" + " _hh";
forvalues k = 1/$indica {;
local _cory  = "`_cory'" + " _cory`k'";
local f=`k'+1;
if ("`dif'"!="" | "`type'"=="gen" | "`type'"=="abs")  local f =`k';
if ("`rank'"=="") local rank = -1;
if ("`type'"=="") local type = "no";
if ("`min'"=="")  local min  = 0;
if ("`max'"=="")  local max  = 1;
if ("`hgroup'"=="") {;
local label`f'  =  "``k''";

local titd="L";
if ("``k''"=="`rank'" & "`rank'"!="-1" ) local titd="CP";
if ("``k''"!="`rank'" & "`rank'"!="-1")  local titd="CC";
local titd1="L";
if ("`1'"=="`rank'" & "`rank'"!="-1") local titd1="CP";
if ("`1'"!="`rank'" & "`rank'"!="-1") local titd1="CC";

if (("`dif'"=="ds") & ("`type'"~="gen") & ("`type'"~="abs")  & ("`group'"=="")) local comt="p-";
if ("`dif'"=="c1") local comt="-`tit4'`titd1'_`1'";
if (`cl'==0 ) local adtit="`comt'`tit4'`titd'(p):";
local label`f'  ="`adtit' ``k''";

if ("`dif'"=="c1") local adtit="`comt'";
if ("`dif'"=="c1") local label`f'  = "`tit4'`titd'_``k'' `adtit'";
local opt = 1;

tempvar _ran;
if `rank' != -1 qui gen `_ran' = `rank';
if `rank' == -1 qui gen `_ran' = ``k'';
oph `fw' `_ran' `opt' `alpha';
local h = `r(h)';
fkerv `fw' `_ran' `h' `alpha';

plorenz2 `fw' ``k'' `_ran' `type' `min' `max' `alpha' ;
};
if ("`hgroup'"!="") {;
local kk = gn1[`k'];
local k1 = gn1[1];
local label`f'  : label (`hgroup') `kk';
local labelg1   : label (`hgroup') `k1';
if ( "`label1'" == "")   local labelg1    = "Group: `k1'";
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";



local titd="L";
if ("`1'"!="`rank'" & "`rank'"!="-1") local titd="C";
if ("`dif'"=="c1") {;
local adtit="`tit4'`titd'_`label`f'' - `tit4'`titd'_`labelg1'";
local label`f'  ="`adtit'";
};
plorenz2 `fw' `1' `rank' `type' `min' `max' `alpha' `hgroup' `k';
};
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _cory`k';
};
local m5=(`max'-`min')/5;
local step=(`max'-`min')/100;
gen _corx = `min'+(_n-1)*`step';
qui keep in 1/101;
if (("`dif'"=="ds") & ("`type'"~="gen") & ("`type'"~="abs") ) {;
foreach var of varlist _cory* {;
if ("`dif'"=="ds")  qui replace `var' =  _corx - `var';
};
};
 /* }; // end of quietly */

 
if ("`dif'"=="c1") {;
gen _dct=_cory1;
forvalues k = 1/$indica {;
qui replace _cory`k'=_cory`k'-_dct;
};
local label1  ="Null horizontal line";
};

local legend legend(nodraw);
	
if( `lres' == 1) {;
set more off;
list _corx _cory*;
};
/*quietly {;*/
if (`dgra'!=0) {; 
line `_cory'  _corx, 
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
title(`ftitle')
ytitle(`ytitle')
xtitle(`xtitle') 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
plotregion(margin(zero))
legend(size(small))
`options'		
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
/*}; // end of quietly*/
end;
