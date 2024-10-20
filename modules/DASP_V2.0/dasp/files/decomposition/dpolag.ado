/*************************************************************/
/* program to decompose the DER Index by population groups   */
/* by groups                                   			 */
/* By: Araar Abdelkrim:  02_10_2007           	             */
/* First version                              	             */
/*************************************************************/



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

cap program drop opth ;                  
program define opth, rclass ; 
version 9.2;
args w y m alpha ;                    
qui su `y' [aw=`w'], detail   ; 
 if (`r(skewness)'>6) local m = 2  ;
local h  = 0 ;
      if (`m'==1)  local h = 4.7*_N^-0.5*`r(sd)'*`alpha'^(0.1) ; // equals25
else if  (`m'==2) {;
local inter=(`r(p75)'-`r(p25)');
tempvar ly;
gen `ly'=ln(`y');
qui sum `ly' [aw=`w'];
local ls=`r(sd)';
local h = _N^-0.5 * `inter' * (3.76 + 14.7 *`ls')/((1+1.09*0.0001*`ls')^(7268+15323*`alpha'));
};  // equals26               
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

/***************************************/
/* DER Index (Version 1.0)             */
/***************************************/

cap program drop pola ; 
version 9.2 ;             
program define pola, rclass ;             
syntax varlist (min=1 max=1) [, HSize(varname) HWeight(varname) HGroup(varname) GNumber(int 1)  ALpha(real 0.5) FAst(int 0) OPtion(int 1) dname(string) ];
preserve;
sort `1';

tokenize `varlist';
qui drop if `1'>=.;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;
tempvar  hs hw fw ;
gen `hw'=1;
gen `hs'=1;
qui gen _in=1;

if ("`hsize'"  != "")     qui replace `hs' = `hsize';
if ("`hgroup'" != "")     qui replace _in = _in*(`hgroup' == `gnumber');

tempvar  fwo;
qui gen `fwo' = `hs';
if ("`hweight'"!="")   qui replace `fwo'=`hs'*`hweight';
qui sum `fwo', meanonly;
local pop=`r(mean)';

if ("`hgroup'" != "")   qui replace `hs' = `hs' * _in;
if ("`hweight'"!= "")   qui replace `hw' = `hweight';
gen `fw'=`hs'*`hw';

qui sum `fw', meanonly;
local popg=`r(mean)';

tempvar smw smwy l1smwy a ca ca0;

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
#delim ;
opth `fw' `1' `option' `alpha';
local h = `r(h)';

if (`fast'!=1 & "`dname'" ~= "population" )  fkerv `fw' `1' `h' `alpha' "`dname'";
if (`fast'==1 & "`dname'" ~= "population" )  ckfkerv  `1' , weight(`fw') h(`h') alpha(`alpha') dname(`dname');

if ( "`dname'" == "population" ) {;
cap drop _fker; gen _fker=__fker;
};

gen `ca0' = __fker*`a';
gen `ca' =   _fker*`a'; 

qui sum `ca0' [aw=`fwo'], meanonly;  
local tder=r(mean)/(2.0*`mu'^(1.0-`alpha'));
return scalar tder = `tder';


qui sum `ca' [aw=`fw'], meanonly; 
local der=r(mean)/(2.0*`mu'^(1.0-`alpha'));
return scalar der = `der';
local m1 = r(mean);
qui sum `ca0' [aw=`fw'], meanonly; 
local m2 = r(mean);
return scalar mu    = `mu';
return scalar spop  = `popg'/`pop';

return scalar rg  = `m2'/`m1';

qui sum __fker [aw=`fw'], meanonly;
local s1= `r(sum)';
qui sum __fker [aw=`fwo'], meanonly;
local s2= `r(sum)';
return scalar vg = `s1'/`s2';

restore;
end;


cap program drop poldep;
program define poldep, rclass sortpreserve;
syntax varlist(min=1 max=1) [, HWeight(varname) HSize(varname) HGroup(varname) NGroup(string) RAnk(varname) alpha(real 0.5)];
version 8.0;
tokenize `varlist';
set more off;
tempvar fw;
qui gen `fw'=1;
if ("`hsize'"  ~="")    qui replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")   qui  replace `fw'=`fw'*`hweight';
if ("`hgroup'"~="")    qui  replace `fw'=`fw'*(`hgroup'==`ngroup');


qui sum `1' [aw=`fw']; 
local mu = `r(mean)';
gsort `1';
cap drop _ww;
cap drop _wy;
cap drop _dp;
cap drop _sp;

cap drop _dp2;
cap drop _sp2;

qui gen _ww = sum(`fw');
qui gen _wy = sum(`fw'*`1');
local suma = _wy[_N];
local sumw = _ww[_N] ; 
local norm=1;

gen _dp=(_wy[_N]-_wy[_n]-(_ww[_N]-_ww[_n])*`1'[_n])/(`sumw');
gen _sp=(`1'[_n]*_ww[_n]-_wy[_n])/(`sumw');


if (`alpha'>0){;
qui replace _dp=_dp*__fker;
qui replace _sp=_sp*__fker;
};
qui sum _dp  [aw=`fw'];
local D=`r(mean)';
qui sum _sp [aw=`fw'];
local S=`r(mean)';

local der=(`D'+`S')/(2*`mu'^(1-`alpha'));

cap drop _ww;
cap drop _wy;

return scalar cd = (`D')/(2*`mu'^(1-`alpha'));
return scalar cs = (`S')/(2*`mu'^(1-`alpha'));
end;





cap program drop dpolag;
program define dpolag, rclass sortpreserve;

syntax varlist (min=1 max=1) [, HGroup(varname) HSize(varname) ALpha(real 0.5) FAst(int 0) DEC(int 3) OPtion(int 1)];
version 9.2;
if ("`hgroup'"=="")  {;
disp as error " You need to specify the group variable with option hgroup(varname)";
exit;
};
local hweight="";
cap qui svy: total `1';
local hweight=`"`e(wvar)'"';
cap ereturn clear;



if ("`hgroup'"!="") {;
preserve;
capture {;
local lvgroup:value label `hgroup';
uselabel `lvgroup' , clear;
qui count;
forvalues i=1/`r(N)' {;
local grlab`i' = label[`i'];
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
nargs    `varlist';
preserve;
};


tempvar Variable POPS INCS ABSC RELC ABSCR RELCR  ABS_CR REL_CR POLG RATG WITH BETW ;
tempvar fw;
quietly{;
gen `fw'=1;
if ("`hsize'"  ~="")    qui replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")    qui replace `fw'=`fw'*`hweight';
};
tokenize `varlist';
opth `fw' `1' `option' `alpha';
local h = `r(h)';
if (`fast'!=1)  fkerv `fw' `1' `h' `alpha' population;
if (`fast'==1 )  ckfkerv  `1' , weight(`fw') h(`h') alpha(`alpha') dname(population);
cap drop __fker;
qui gen __fker=_fker;



pola `1',  hw(`hweight') hs(`hsize') alpha(`alpha') fast(`fast') option(`option') dname(population);
local tder  = `r(tder)';
global mu = `r(mu)';
poldep `1', hs(`hsize')  hw(`hweight') alpha(`alpha');
local TD = `r(cd)';
local TS = `r(cs)';

qui gen _muk  = 0;
qui gen _phik = 0;


qui sum `fw';
local suma = `r(sum)';

cap drop  `POPS' `RELCR' `ABSCR' Total;



cap gen _component="";
cap gen `POLG'    =0;
cap gen `RATG'      =0;
cap gen V_g      =0;
cap gen `POPS'=0;
cap gen `INCS'=0;
cap gen Inc_k    =0;
cap gen ef_k     =0;
cap gen contr    =0;
cap gen `RELCR'=0;
cap gen `ABSCR'=0;

cap gen `REL_CR'=0;
cap gen `ABS_CR'=0;

cap gen `RELC'=0;
cap gen `ABSC'=0;
qui gen `Variable'="";

cap gen D_Cont   = 0;
cap gen S_Cont   = 0;
cap gen RATIO_DS = 0;

cap gen adit = 0;
local t1=0;
local t2=0;
local t3=0;
local t4=0;
local t5=0;
qui sum `fw';
local tot=`r(sum)';
local nobsa=$indica+1;
forvalues k = 1/$indica {;
local kk = gn1[`k'];
if ( "`grlab`k''" == "") local grlab`k' = "Group_`kk'";

qui replace `Variable' = " `grlab`k''" in `k';
local gg=gn1[`k'];
 pola `1',  hw(`hweight') hs(`hsize') hgroup(`hgroup') gn(`gg') alpha(`alpha') fast(`fast') option(`option') dname("`grlab`k''" );
qui replace `POLG' = `r(der)' in `k';
qui replace `RATG'   = `r(rg)'  in `k' ;
qui replace V_g   = `r(vg)'  in `k';
local t1=`t1'+`POLG'[`k'];
qui replace _muk=`r(mu)'              if (`hgroup'==gn1[`k']) ;
local ttem=(`r(spop)'/`tot')^`alpha';
qui replace _phik=`ttem'               if (`hgroup'==gn1[`k']);

qui replace `POPS' =`r(spop)'                      in `k';
qui replace `INCS' = `POPS'[`k']*`r(mu)'/$mu    in `k';

qui replace Inc_k = `r(mu)'   in `k';
qui replace ef_k =  `r(vg)'   in `k';

local t2=`t2'+`POPS'[`k'];
local t3=`t3'+`INCS'[`k'];

qui replace  `ABSC' = `INCS'[`k']^( 1-`alpha')*`POPS'[`k']^(1+`alpha')*`RATG'[`k']*`POLG'[`k']   in `k';

local t4=`t4'+`ABSC'[`k'];
qui replace  `RELC' =`ABSC'[`k']/`tder' in `k';
local t5=`t5'+`RELC'[`k'];
tempvar fwg;
gen `fwg' = `fw'*(`hgroup'==`gg');
qui sum _dp [aw=`fwg'];
qui replace D_Cont =  `r(mean)'/(2*$mu^(1-`alpha'))*`POPS'[`k']   in `k';
qui sum _sp [aw=`fwg'];
qui replace S_Cont =  `r(mean)'/(2*$mu^(1-`alpha'))*`POPS'[`k']   in `k';
qui replace RATIO_DS =  D_Cont[`k']/S_Cont[`k']   in `k' ;

};


local pbar=0;
forvalues k = 1/$indica {;
local tmp=0;
forvalues v = 1/$indica {;
local tmp=`tmp'+`POPS'[`v']*abs(Inc_k[`k']/$mu - Inc_k[`v']/$mu);
};
local pbar  = `pbar'   + (`POPS'[`k'])^(1+`alpha')*`tmp';
};
local pbar=`pbar'/2.0;


qui replace adit = `pbar'     in 1;
qui replace adit = `TD'       in 2;
qui replace adit = `TS'       in 3;




qui replace  `POLG'  =    . in `nobsa';
qui replace  `POPS'   =`t2' in `nobsa';
qui replace  `INCS'   =`t3' in `nobsa';
qui replace  `ABSC'   =`t4' in `nobsa';
qui replace  `RELC'   =`t5' in `nobsa';

qui replace D_Cont   =   `TD'  in `nobsa';
qui replace S_Cont   =   `TS'  in `nobsa';
qui replace RATIO_DS =   `TD'/`TS'       in  `nobsa';

local nobsa = $indica+1;
qui count;
if(`r(N)' < $indica) qui set obs `nobsa';

cap gen Component   ="";
cap gen `ABS_CR'   =0;
cap gen `REL_CR'   =0;
qui replace Component = "A: Intra-group" in 1;
qui replace Component = "B: Inter-group" in 2;
qui replace Component = "Total         " in 3;

qui replace _component = "P_BAR          "  in 1;
qui replace _component = "Lambda         "  in 2;
qui replace _component = "TOT_DEPRIV. (D)"  in 3;
qui replace _component = "TOT_SURPLU. (S)"  in 4;


qui replace `ABS_CR' = `t4'                      in 1;
qui replace `ABS_CR' = `tder'-`t4'               in 2;
qui replace `ABS_CR' = `tder'                    in 3;


qui replace `REL_CR' = `t4'/`tder'                     in 1;
qui replace `REL_CR' = (`tder'-`t4')/`tder'            in 2;
qui replace `REL_CR' = `tder'/`tder'                   in 3;


tempname table;
	.`table'  = ._tab.new, col(3);
	.`table'.width |16|16 16|;
	.`table'.strcolor . . yellow ;
	.`table'.numcolor yellow yellow .  ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f ;
	di _n as text "{col 4} Decomposition of the DER Index of Polarisation by Population Groups: Araar's (2008) Approach.";
      
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";
                            di  as text "{col 5}Parameter alpha : "  %5.2f `alpha'       ;
                            di  as text "{col 5}Pure between-group polarisation index : "  %8.`dec'f `pbar'       ;
     
      .`table'.sep, top;
	.`table'.titles "Component  " "Absolute"       "Relative " ;
	.`table'.titles "       "     "Contribution"   "Contribution  " ;
	.`table'.sep, mid;
	local nalt = "ddd";
	
        
             .`table'.numcolor white yellow yellow  ;
		 .`table'.row "Intra-Group" `ABS_CR'[1]  `REL_CR'[1];
		 .`table'.row "Inter-Group" `ABS_CR'[2]  `REL_CR'[2];	        
		 .`table'.sep, mid;
		 .`table'.numcolor white yellow yellow;
		 .`table'.row "Total"       `ABS_CR'[3]  `REL_CR'[3];
		 .`table'.sep,bot;


local ll = 20;
local nobsa_1 = `nobsa' - 1 ; 

tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width |`ll'|16 16 16 16|;
	.`table'.strcolor . . yellow . . ;
	.`table'.numcolor yellow yellow . yellow yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f;
	      .`table'.sep, top;
	.`table'.titles "Group  " "Population"  "Income "  "Polarisation" "Ratio R" ;
	.`table'.titles "       " "Share     "  "Share  "  "index   "     " " ;
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`nobsa_1'{;
        
             .`table'.numcolor white yellow yellow yellow yellow ;
		 .`table'.row `Variable'[`i'] `POPS'[`i']  `INCS'[`i'] `POLG'[`i'] `RATG'[`i'];	        
             };
.`table'.sep,bot;

	 di _n as text "{col 4} Intra-Group Polarisation";


tempname table;
	.`table'  = ._tab.new, col(6);
	.`table'.width |`ll'|16 16 16 16 16|;
	.`table'.strcolor . . yellow . . . ;
	.`table'.numcolor yellow yellow . yellow yellow yellow;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f %16.`dec'f;
	      .`table'.sep, top;
	.`table'.titles "Group  " "Absolute     "  "Relative    "  "The deficit"    "The suplus"   "The ratio ";
	.`table'.titles "       " "Contribution "  "Contrbution "  "Component (D) " " Component (S) "  " (D/S)";
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`nobsa_1'{;
        
             .`table'.numcolor white yellow yellow yellow yellow yellow ;
		 .`table'.row `Variable'[`i'] `ABSC'[`i']  `RELC'[`i'] D_Cont[`i'] S_Cont[`i'] RATIO_DS[`i'];	        
             };
 .`table'.sep, mid;
	
             .`table'.numcolor white yellow yellow yellow yellow yellow ;
		 .`table'.row "Total" `ABSC'[`nobsa']  `RELC'[`nobsa'] D_Cont[`nobsa'] S_Cont[`nobsa'] RATIO_DS[`nobsa'];	        
             .`table'.sep,bot;

drop __fker;
drop _fker;

restore;


end;

