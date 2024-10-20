/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.2)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/

#delim ;

cap program drop opthn;                    
program define opthn, rclass ;
version 9.2;
preserve ;            
args fw x ;                       
qui su `x' [aw=`fw'], detail ;           
local tmp = (`r(p75)'-`r(p25)')/1.34 ;                          
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
local h   = 0.9*`tmp'*_N^(-1.0/5.0)  ;                          
return scalar h =  `h' ;
restore; 
end;

cap program drop opth  ;                  
program define opth, rclass ; 
version 9.2;
args w y m alpha ;                    
qui su `y' [aw=`w'], detail   ; 
 if (`r(skewness)'>6) local m = 2  ;
local h  = 0 ;
      if (`m'==1)  local h = 4.7*_N^-0.5*`r(sd)'*`alpha'^(0.1) ; // eq 25
else if  (`m'==2) {;
local inter=(`r(p75)'-`r(p25)');
tempvar ly;
gen `ly'=ln(`y');
qui sum `ly' [aw=`w'];
local ls=`r(sd)';
local h = _N^-0.5 * `inter' * (3.76 + 14.7 *`ls')/((1+1.09*0.0001*`ls')^(7268+15323*`alpha'));
}; // equals26                
return scalar h = `h';
end;

cap program drop fkerv  ;                  
program define fkerv, rclass  sortpreserve;
version 9.2;
args w y h alpha dname;                    
cap drop _fker;
gen _fker=0;
if (`alpha'==0) qui replace _fker=1;

if (`alpha'>0) {;
qui drop if `w' == 0;
tempvar s1 s2;
gen `s2' = sum( `w' );
local pi=3.141592653589793100;
qui count;
if (`r(N)'>100) dis "WAIT: Estimation of density (`dname') ==>>";

local stp0=`r(N)'/100;
local stp=`stp0';
local j=0;
local pr=10;
local sym = ":";
forvalues i=1/`r(N)' {;
cap drop `s1';
gen `s1' = sum( `w' *exp(-0.5* ( ((`y'[`i']-`y')/`h')^2  )  ));
qui replace _fker = (`s1'[_N]/( `h'* sqrt(2*`pi') * `s2'[_N] ))^(`alpha') in `i';
if (`i'>=`stp') {;
if `r(N)'>=100 dis    "`sym'", _continue ;
 local stp = `stp'+`stp0';
local j=`j' + 1;
if (`j'/2 == round(`j'/2)) local sym = ":";
if (`j'/2 != round(`j'/2)) local sym = ".";

};
if (`j'==10 ) {;
if `r(N)'>=100 dis "`pr'%";
local j=0;
local pr=`pr'+10;
};
};
if (`r(N)'>=100) dis "<== END";
};
end;


cap program drop ckfkerv  ;                  
program define ckfkerv, rclass   sortpreserve  ; 
version 9.2    ;    
syntax varlist(min=1 max=1) [, weight(varname) band(real -1) h(real -1) alpha(real 0) dname(string)];
tokenize `varlist';
cap drop _fker;
gen _fker=1.0;
if (`alpha'>0) {;
qui drop if `1'>=. ;
if ("`weight'"~="" ) qui drop if `weight'>=. | `weight'==0;
tempvar fw;
gen `fw' = 1;
if ("`weight'"!="") qui replace `fw'=`weight';
opth `fw' `1' 1 `alpha';
if (`band'==-1) {;
local band=r(h)/2;
};
if (`h'==-1) {;
local h=r(h);
};
local prc = 1;
tempvar group;
gen `group'=round(`1'/(`prc'*`band'))+1;
qui tab `group';
local ng=r(r) ;
tempvar mu gr std pshare;
sort `group';
qui tabstat `1' [aweight=`fw' ], statistics( mean sd ) by(`group') columns(variables) save;
cap drop `mu' ;
cap drop `gr';
cap drop `std';
cap drop `pshare';
gen `mu'  = 0;
gen `gr' = 0;
gen `std' = 0;
gen `pshare'=0;
forvalues i=1/`ng' {;
qui replace `gr'=`r(name`i')' in `i';
matrix _re = r(Stat`i');
qui replace `mu'=el(_re, 1, 1) in `i';
qui replace `std' =el(_re, 2, 1) in `i';
qui replace `std' = 0 in `i' if `std'[`i']>=.;
cap _drop _matrix _re;
};

qui sum `fw';
local suma = r(sum);
qui tabstat `fw', statistics(sum) by(`group') columns(variables) save;
forvalues i=1/`ng' {;
matrix _re = r(Stat`i');
qui replace `pshare'=el(_re, 1, 1)/`suma' in `i';
cap drop matrix _re;
};
local pi=3.141592653589793100;
qui count;
local NN=`r(N)';
local stp0=`NN'/100;
set more off;
if (`NN'>100) dis "WAIT: Estimation of density (`dname') ==>>";
tempvar ck;

local stp=`stp0';
local j=0;
local pr=10;
local sym = ":";
forvalues i=1/`NN' {;

qui gen `ck' = sum( `pshare'/((2*`pi')^0.5*(`std'^2+`h'^2)^0.5)*exp((-(`1'[`i']-`mu')^2)/(2*(`std'^2+`h'^2))) ) in 1/`ng';
qui replace _fker=`ck'[`ng']^`alpha' in `i';
cap drop `ck';

if (`i'>=`stp' & (`NN'>=100)) {;
dis "`sym'", _continue ;
local stp = `stp'+`stp0';
local j=`j' + 1;
if (`j'/2 == round(`j'/2)) local sym = ":";
if (`j'/2 != round(`j'/2)) local sym = ".";
};
if (`j'==10 ) {;
if (`NN'>=100) dis "`pr'%";
local j=0;
local pr=`pr'+10;
};
};
if (`NN'>=100)  dis "<== END";

};
end;

cap program drop polas;  
version 9.2;                 
program define polas, rclass;              
syntax varlist (min=1 max=1) [, RANK(varname) HSize(varname) HWeight(varname) HGroup(varname) GNumber(int 1)  ALpha(string) FAst(int 0) OPtion(int 1) ];
preserve;
if ("`rank'"=="")        gsort `1';
if ("`rank'"~="")        gsort `rank';
tokenize `varlist';
qui drop if `1'>=.;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;
tempvar  hs hw fw ;
gen `hw'=1;
gen `hs'=1;

if ("`hsize'"!="")     qui replace `hs' = `hsize';
if ("`hgroup'" != "")  qui gen _in = (`hgroup' == `gnumber');

tempvar  fwo;
qui gen `fwo' = `hs';
if ("`hweight'"!="")   qui replace `fwo'=`hs'*`hweight';
qui sum `fwo', meanonly;
local pop=`r(mean)';

if ("`hgroup'" != "")  qui replace `hs' = `hs' * _in;
if ("`hweight'"!="")   qui replace `hw'=`hweight';
gen `fw'=`hs'*`hw';

qui sum `fw', meanonly;
local popg=`r(mean)';


tempvar smw smwy l1smwy a ca ;

gen `smw'  =sum(`fw');
gen `smwy' =sum(`1'*`fw');
gen `l1smwy'=0;

local mu=`smwy'[_N]/`smw'[_N];
local suma=`smw'[_N];
qui count;
forvalues i=2/`r(N)' { ;
qui replace `l1smwy'=`smwy'[`i'-1]  in `i';
};
gen `a'=`mu'+`1'*((1.0/`smw'[_N])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[_N])*(2.0*`l1smwy'+`fw'*`1') ;

tempvar ca;
gen `ca' =   _fker*`a';  
qui sum `ca' [aw=`fw'], meanonly; 

if ("`rank'"=="") {;
local der=r(mean)/(2.0*`mu'^(1.0-`alpha'));
return scalar der   = `der';
return scalar mu    = `mu';
};

if ("`rank'"~="") {;
local der=r(mean)/(2.0*`mu'^(1.0-`alpha'))*($mu/`mu')^(`alpha');
return scalar der   = `der';
return scalar mu    = `mu';
return scalar incs    = `mu'/$mu;

local absc = (`mu'/$mu)*`der';
return scalar absc    = `absc';
return scalar relc    = `absc'/$der;

};
restore;
end;



capture program drop dpolas;
program define dpolas, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname)  HGroup(varname)  APPR(string)  DEC(int 6) DSTE(int 1) ALpha(real 0.5) OPtion(int 1) FAst(int 0) ];
preserve;
local ll=0;
qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
if ("`appr'"=="") local appr="rao";
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 



tokenize  `varlist';
_nargs    `varlist';




tempvar Variable Variable2 INCS  CONC  ABSC  RELC GIC GIK;
qui gen `Variable'="";
qui gen `Variable2'="";
qui gen `INCS'=0;
qui gen `CONC'=0;
qui gen `ABSC'=0;
qui gen `RELC'=0;

qui gen `GIC'=0;
qui gen `GIK'=0;

tempvar MINS  VAEF  COEF ;
qui gen `MINS'=0;
qui gen `VAEF'=0;
qui gen `COEF'=0;

qui count;
local minobs=$indica+2;
if (`r(N)'<`minobs') qui set obs `minobs'; 

tempvar totinc totince;
qui gen `totinc'=0;
qui gen `totince'=0;
forvalues k = 1/$indica {;
qui replace `totinc' = `totinc' + ``k'';
};


tempvar _ths;
qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';

tempvar ww;
qui gen `ww' = `_ths';
if ("`hweight'"~="") qui replace `ww' = `_ths'*`hweight';
qui sum `totinc' [aw=`ww'], meanonly;
local mu = `r(mean)';


opth `ww' `totinc' `option' `alpha';
local h = `r(h)';
if (`fast'!=1)  fkerv `ww' `totinc' `h' `alpha' population ;
if (`fast'==1)  ckfkerv  `totinc' , weight(`ww') h(`h') alpha(`alpha') dname(population);
gen __fker=_fker;


global der=1;
polas `totinc',  hw(`hweight') hs(`hsize') alpha(`alpha') fast(`fast') option(`option');

local tder  =  `r(der)';
global der  =  `r(der)';
global mu    =  `r(mu)';


local k1=$indica+1;



local ll=length("`1': `grlab`1''");
local component = "Variable";

qui count;
local mobs = 2*$indica+2;
if (`r(N)'< `mobs' ) qui set obs `mobs';
local check = 0;
if ("`appr'"=="rao" | "`appr'"=="lay") {;

forvalues k = 1/$indica {;
qui replace `Variable' = "`k': ``k''" in `k';
polas ``k'' , hweight(`hweight') rank(`totinc') hsize(`_ths') alpha(`alpha') fast(`fast') option(`option');
qui replace `INCS'         = `r(incs)'    in `k';
qui replace `CONC'         = `r(der)'     in `k';
qui replace `ABSC'         = `r(absc)'    in `k';
qui replace `RELC'         = `r(relc)'    in `k';
};
};
local ll=`ll'+10;




	tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width |`ll'|16 16 16 16 |;
	.`table'.strcolor . . . yellow .  ;
	.`table'.numcolor yellow yellow yellow . yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f ;
	di _n as text "{col 4} Decomposition of the DER Index of polarization by Incomes Sources: Araar's (2008) Approach.";
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
	.`table'.sep, top;
	.`table'.titles "Sources  "  "Income   "   "Concentration"  "  Absolute  " "  Relative  " ;
	.`table'.titles "         "  " Share   "   " Index       "  "Contribution" "Contribution" ;
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/$indica{;
        

		     .`table'.row `Variable'[`i'] `INCS'[`i']  `CONC'[`i'] `ABSC'[`i'] `RELC'[`i'];	        
              };
                     
  .`table'.sep, mid;
.`table'.numcolor white yellow yellow  yellow yellow  ;
.`table'.row  "Total " 1.0   "---" $der   1.0;
	.`table'.sep,bot;
cap ereturn clear;
restore;
end;




