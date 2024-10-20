
/*************************************************************************/
/* Programmed by Dr. Araar Abdelkrim                                     */
/* Universite Laval, Quebec, Canada                                       */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : dspol                                                       */
/*************************************************************************/


#delim cr;
cap program drop opth                    
program define opth, rclass 
version 9.2
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
version 9.2
args w y m alpha                     
qui su `y' [aw=`w'], detail    
 if (`r(skewness)'>6) local m = 2  
local h  = 0 
      if (`m'==1)  local h = 4.7*_N^-0.5*`r(sd)'*`alpha'^(0.1) // equals25
else if  (`m'==2) {
local inter=(`r(p75)'-`r(p25)')
tempvar ly
gen `ly'=ln(`y')
qui sum `ly' [aw=`w']
local ls=`r(sd)'
local h = _N^-0.5 * `inter' * (3.76 + 14.7 *`ls')/((1+1.09*0.0001*`ls')^(7268+15323*`alpha'))
} // equals26                 
return scalar h = `h'
end


cap program drop fkerv                    
program define fkerv, rclass  sortpreserve
version 9.2
args w y h alpha dname   
            
cap drop _fker
gen _fker=0
if (`alpha'==0) qui replace _fker=1

local condfk=1

qui sum `y' if `w' != 0
if ( `r(N)'==1 | `r(min)'==`r(max)') {
qui sum `w' 
qui replace _fker=1/`r(sum)'
local condfk=0
}

if (`alpha'>0 & `condfk'==1) {
tempvar s1 s2
gen `s2' = sum( `w' )
local pi=3.141592653589793100
qui count
if (`r(N)'>100) dis "WAIT: Estimation of density (`dname') ==>>"

local stp0=`r(N)'/100
local stp=`stp0'
local j=0
local pr=10
local sym = ":"
forvalues i=1/`r(N)' {
cap drop `s1'
gen `s1' = sum( `w' *exp(-0.5* ( ((`y'[`i']-`y')/`h')^2  )  ))
qui replace _fker = (`s1'[_N]/( `h'* sqrt(2*`pi') * `s2'[_N] ))^(`alpha') in `i'
if (`i'>=`stp') {
if `r(N)'>=100 dis    "`sym'", _continue 
 local stp = `stp'+`stp0'
local j=`j' + 1
if (`j'/2 == round(`j'/2)) local sym = ":"
if (`j'/2 != round(`j'/2)) local sym = "."
}
if (`j'==10 ) {
if `r(N)'>=100 dis "`pr'%"
local j=0
local pr=`pr'+10
}
}
if (`r(N)'>=100) dis "<== END"
}


end


cap program drop ckfkerv                    
program define ckfkerv, rclass   sortpreserve   
version 9.2        
syntax varlist(min=1 max=1) [, wgt(varname) band(real -1) h(real -1) alpha(real 0) dname(string)]
tokenize `varlist'
cap drop _fker
qui gen _fker=0.0

qui replace _fker = 1 if `alpha'==0
local condfk=1

qui sum `1' if `wgt' != 0
if ( `r(N)'==1 | `r(min)'==`r(max)') {
qui sum `wgt' 
qui replace _fker=1/`r(sum)'
local condfk=0
}
dis "`dname'"
if (`alpha'>0 & `condfk'==1) {
qui drop if `1'>=. 
tempvar mrk
    qui gen `mrk' = 2
qui replace `mrk' = 1 if `wgt' != 0
qui count if `wgt'!=0
local NB=`r(N)'
sort `mrk'
tempvar fwe
gen `fwe' = 1
if ("`wgt'"!="") qui replace `fwe'=`wgt'
opth `fwe' `1'
if (`band'==-1) {
local band=r(h)/2
}
if (`h'==-1) {
local h=r(h)
}
local prc = 2
tempvar group
gen `group'=round(`1'/(`prc'*`band'))+1

qui tab `group' in 1/`NB'
local ng=r(r) 
tempvar mu gr std pshare
sort `group' in 1/`NB'
qui tabstat `1' [aw=`fwe' ], statistics( mean sd ) by(`group') columns(variables) save
cap drop `mu' 
cap drop `gr'
cap drop `std'
cap drop `pshare'
gen `mu'  = 0
gen `gr' = 0
gen `std' = 0
gen `pshare'=0
forvalues i=1/`ng' {
if `i'<=`NB' {
qui replace `gr'=`r(name`i')' in `i'
matrix _re = r(Stat`i')
qui replace `mu'  =el(_re, 1, 1) in `i'
qui replace `std' =el(_re, 2, 1) in `i'
qui replace `std' = 0 in `i' if `std'[`i']>=.
cap _drop _matrix _re
}
}

qui sum `fwe' 
local suma = r(sum)
qui tabstat `fwe' in 1/`NB', statistics(sum) by(`group') columns(variables) save
forvalues i=1/`ng' {
matrix _re = r(Stat`i')
qui replace `pshare'=el(_re, 1, 1)/`suma' in `i'
cap drop matrix _re
}
local pi=3.141592653589793100


local stp0=`NB'/100
set more off
if (`NB'>100) dis "WAIT: Estimation of density (`dname') ==>>"
tempvar ck

local stp=`stp0'
local j=0
local pr=10
local sym = ":"
forvalues i=1/`NB' {

qui gen `ck' = sum( `pshare'/((2*`pi')^0.5*(`std'^2+`h'^2)^0.5)*exp((-(`1'[`i']-`mu')^2)/(2*(`std'^2+`h'^2))) ) in 1/`ng'
qui replace _fker=`ck'[`ng']^`alpha' in `i'
cap drop `ck'
if (`i'>=`stp' & (`NB'>=100)) {
dis "`sym'", _continue 
local stp = `stp'+`stp0'
local j=`j' + 1
if (`j'/2 == round(`j'/2)) local sym = ":"
if (`j'/2 != round(`j'/2)) local sym = "."

}
if (`j'==10 ) {
if (`NB'>=100) dis "`pr'%"
local j=0
local pr=`pr'+10
}
}
if (`NB'>=100)  dis "<== END"
}
qui replace _fker = 0 if `wgt'>=. | `wgt'==0
end


#delim ;
cap program drop dspol2;  
program define dspol2, rclass sortpreserve;    
version 9.2;         
syntax varlist (min=1 max=1) [, HSize(varname) HWeight(varname) 
HGroup(varname) ALpha(real 0.5) FAST(int 0) 
GNumber(int -1) dname(string) GLV(int 1) TGR(int 1)];

tokenize `varlist';
sort `1', stable;
                     qui drop if `1'>=. ;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;
if ("`hgroup'"!="")  qui drop if `hgroup'>=.;
tempvar  hs sw fw fwp fwc;
gen `sw'=1;
gen `hs'=1;

if ("`hsize'"!="")     qui replace `hs' = `hsize';
tempvar hsp hsc;
qui gen `hsp'=`hs';
qui gen `hsc'= 0;
tempvar _in;
if ("`hgroup'" != "")  qui gen    `_in'  = (`hgroup' == `gnumber');
if ("`hgroup'" != "")  qui replace `hs'  = `hs' * `_in';
if ("`hgroup'" != "")  qui replace `hsc' = `hsp' * (`hgroup' != `gnumber');
if ("`hweight'"!="")   qui replace `sw'=`hweight';

qui gen `fw' =`hs'*`sw' ;
qui gen `fwp'=`hsp'*`sw';
qui gen `fwc'=`hsc'*`sw';

qui sum `fw',  meanonly; local sum1= `r(mean)'; 
qui sum `fwp', meanonly; local sum2= `r(mean)';
local ps = `sum1'/`sum2';

tempvar smw smwy l1smwy aa ca;
qui gen `smw'  =sum(`fw');
qui gen `smwy' =sum(`1'*`fw');
qui gen `l1smwy'=0;
local mu=`smwy'[_N]/`smw'[_N];
local suma=`smw'[_N];
qui count;
forvalues i=2/`r(N)' { ;
qui replace `l1smwy'=`smwy'[`i'-1]  in `i';
};

qui gen `aa'=`mu'+`1'*((1.0/`smw'[_N])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[_N])*(2.0*`l1smwy'+`fw'*`1'); 
oph `fw' `1' 1 `alpha';
local h = `r(h)';

if (`fast'!=1)  fkerv `fw' `1' `h' `alpha' "`dname'";
if (`fast'==1)  ckfkerv  `1' , wgt(`fw') h(`h') alpha(`alpha') dname(`dname');

qui gen `ca' = _fker*`aa';  

qui sum `1' [aw=`fwp']; 
local mup=`r(mean)';

qui sum `ca' [aw=`fw'], meanonly; 
local tempo = r(mean);

tempvar vec_a vec_b vec_c vec_d vec_e vec_f vec_g vec_h theta v1 v2 sv1 sv2;
qui count;

            local mfx=0;
            local fx=0;
            qui gen `v1'=`fw'*_fker*`1';
            qui gen `v2'=`fw'*_fker;
            qui gen `sv1'=sum(`v1');
            qui gen `sv2'=sum(`v2') ;
            qui replace `v1'=`sv1'[`r(N)']   in 1;
            qui replace `v2'=`sv2'[`r(N)']   in 1;
            qui replace `v1'=`sv1'[`r(N)']-`sv1'[_n-1]   in 2/`r(N)';
            qui replace `v2'=`sv2'[`r(N)']-`sv2'[_n-1]   in 2/`r(N)';

            qui gen `theta'=`v1'-`v2'*`1';
            qui replace `theta'=`theta'*(2.0/`suma') ;

            tempvar yfker; qui gen `yfker' = `1'*_fker;
            qui sum _fker   [aw=`fw'];   local mfx = `r(sum)'/`suma';
            qui sum `yfker' [aw=`fw'];   local fx  = `r(sum)'/`suma';
            
              
            qui gen `vec_a'= `hs'*((1.0+`alpha')*`ca'+(`1'*`mfx'-`fx')+`theta'-(1.0+`alpha')*(`tempo'));
            qui gen `vec_b'= `hsp'*`1'   ;                                                                    
            qui gen `vec_c'= `hs' ;  
            qui gen `vec_d'= `hsp' ; 
            qui gen `vec_e'= `hsc' ;  
            qui gen `vec_f'= `hsc'*`1' ; 
            qui gen `vec_g'= `hs'*(`mfx'+(1+`alpha')*(_fker-    `mfx')) ;  
            qui gen `vec_h'= `hs'*(`fx' +(1+`alpha')*(_fker*`1'-`fx' )) ;  

 
qui svy:mean `vec_a' `vec_b' `vec_c' `vec_d' `vec_e' `vec_f' `vec_g' `vec_h';
matrix res=e(b);
local s1=el(res,1,1);
local s2=el(res,1,2);
local s3=el(res,1,3);
local s4=el(res,1,4);
local s5=el(res,1,5);
local s6=el(res,1,6);
local s7=el(res,1,7);
local s8=el(res,1,8);

local with = `s1'*`s2'^(`alpha'-1)*`s3'^(1+`alpha')*`s4'^(-1*(1+2*`alpha'));

local v1=`s2'^(`alpha'-1)*`s3'^(1+`alpha')*`s4'^(-1*(1+2*`alpha'));
local v2=(`alpha'-1)*`s1'*`s2'^(`alpha'-2)*`s3'^(1+`alpha')*`s4'^(-1*(1+2*`alpha'));
local v3=(1+`alpha')*`s1'*`s2'^(`alpha'-1)*`s3'^(`alpha')*`s4'^(-1*(1+2*`alpha'));
local v4=(-1*(1+2*`alpha'))*`s1'*`s2'^(`alpha'-1)*`s3'^(1+`alpha')*`s4'^(-1*(2+2*`alpha'));
local v5=0;
local v6=0;
local v7=0;
local v8=0;

local betw = `s2'^(`alpha'-1)*`s3'^(`alpha')*`s4'^(-1*(1+2*`alpha'))*(`s6'*`s7'+`s5'*`s8');

local vv1=0;
local vv2=(`alpha'-1)*`s2'^(`alpha'-2)*`s3'^(`alpha')*`s4'^(-1*(1+2*`alpha'))*(`s6'*`s7'+`s5'*`s8');
local vv3=(`alpha')*`s2'^(`alpha'-1)*`s3'^(`alpha'-1)*`s4'^(-1*(1+2*`alpha'))*(`s6'*`s7'+`s5'*`s8');
local vv4=(-1*(1+2*`alpha'))*`s2'^(`alpha'-1)*`s3'^(`alpha')*`s4'^(-1*(2+2*`alpha'))*(`s6'*`s7'+`s5'*`s8');
local vv5= `s2'^(`alpha'-1)*`s3'^(`alpha')*`s4'^(-1*(1+2*`alpha'))*(`s8');
local vv6= `s2'^(`alpha'-1)*`s3'^(`alpha')*`s4'^(-1*(1+2*`alpha'))*(`s7');
local vv7= `s2'^(`alpha'-1)*`s3'^(`alpha')*`s4'^(-1*(1+2*`alpha'))*(`s6');
local vv8= `s2'^(`alpha'-1)*`s3'^(`alpha')*`s4'^(-1*(1+2*`alpha'))*(`s5');

forvalues r=1/8{;
local psv`r'=0; local isv`r'=0;
};

local psv3 = 1/`s4';
local psv4 = -`s3'/(`s4'^2);
local psh  = `s3'/`s4';

local isv2 = `s6'/(`s2'^2);
local isv6 = -1/`s2';
local ish = 1-`s6'/`s2';


cap drop _v1`glv' _v2_`glv' _v3_`glv' _v4_`glv';
qui gen _v1_`glv' = `vec_a';
qui gen _v2_`glv' = `vec_b';
qui gen _v3_`glv' = `vec_c';
qui gen _v4_`glv' = `vec_d';
cap drop _v5`glv' _v5_`glv' _v6_`glv' _v8_`glv';
qui gen _v5_`glv' = `vec_e';
qui gen _v6_`glv' = `vec_f';
qui gen _v7_`glv' = `vec_g';
qui gen _v8_`glv' = `vec_h';

global lvec`glv' ="_v1_`glv' _v2_`glv' _v3_`glv' _v4_`glv' _v5_`glv' _v6_`glv' _v7_`glv' _v8_`glv'";

matrix grdps = (`psv1',`psv2',`psv3',`psv4',`psv5',`psv6',`psv7',`psv8');
matrix vv=grdps*e(V)*grdps';
local spsh= el(vv,1,1)^0.5 ;

matrix grdis = (`isv1',`isv2',`isv3',`isv4',`isv5',`isv6',`isv7',`isv8');
matrix vv=grdis*e(V)*grdis';
local sish= el(vv,1,1)^0.5 ;

matrix grdw = (`v1',`v2',`v3',`v4',`v5',`v6',`v7',`v8');
matrix vv=grdw*e(V)*grdw';
local swith= el(vv,1,1)^0.5 ;

matrix grdb = (`vv1',`vv2',`vv3',`vv4',`vv5',`vv6',`vv7',`vv8');
matrix vv=grdb*e(V)*grdb';
local sbetw= el(vv,1,1)^0.5 ;

return scalar psh  = `psh'; return scalar spsh  = `spsh';
return scalar ish  = `ish'; return scalar sish  = `sish';

return scalar with  = `with'; return scalar swith  = `swith';
return scalar betw  = `betw'; return scalar sbetw  = `sbetw';

forvalues r=1/8{;
local vv`r'=`vv`r'';
local vvv`r'=`v`r''+`vv`r'';
local t`r'=(`glv'-1)*8+`r';
qui replace _gradw = `v`r''   in `t`r''; 
qui replace _gradb = `vv`r''  in `t`r''; 
qui replace _gradt = `vvv`r'' in `t`r'';
};

if (`glv'==$indica) {;
set matsize 600;
local tmp = 8*$indica;

mkmat _gradb in 1/`tmp', matrix(GRB);
mkmat _gradw in 1/`tmp', matrix(GRW);
mkmat _gradt in 1/`tmp', matrix(GRT);



qui svy:mean 
$lvec1  $lvec2  $lvec3  $lvec4  $lvec5  $lvec6
$lvec7  $lvec8  $lvec9  $lvec10 $lvec11 $lvec12
$lvec13 $lvec14 $lvec15 $lvec16 $lvec17 $lvec18
$lvec19 $lvec20 $lvec21 $lvec22 $lvec23 $lvec24
$lvec25 $lvec26 $lvec27 $lvec28 $lvec29 $lvec30
;

more;
matrix vv=GRB'*e(V)*GRB;
local stdtb= el(vv,1,1)^0.5 ;

matrix vv=GRW'*e(V)*GRW;
local stdtw= el(vv,1,1)^0.5 ;

matrix vv=GRT'*e(V)*GRT;
local stdtt= el(vv,1,1)^0.5 ;

return scalar stdtw  = `stdtw';
return scalar stdtb  = `stdtb';
return scalar stdtt  = `stdtt';

forvalues i=1/$indica {; mac drop lvec`i';  };

};
end;     



capture program drop dspol;
program define dspol, rclass;
version 9.2;
set more off;
syntax varlist(min=1)[, HSize(varname)  HGroup(varname)
ALpha(real 0.5) FAST(int 0) DSTE(int 1) DEC(int 6)
XFIL(string) XSHE(string) XLAN(string) XTIT(string)];

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 



/* ERRORS */

if "`hgroup'"==""{;
        di in r "The group variable must be indicated with the option: hgroup";
	  exit 198;
exit;
};

preserve;
capture {;
local lvgroup:value label `hgroup';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , clear;
qui count;
forvalues i=1/`r(N)' {;
local tem=value[`i'];
local grlab`tem' = label[`i'];
};
};
};
restore;


preserve;
qui tabulate `hgroup', matrow(_dgn);
cap drop _dgn1;
svmat int _dgn;
global indi=r(r);
forvalues i=1/$indi {;
qui count if `hgroup'==_dgn1[`i'];
if (`r(N)'==1) qui drop if `hgroup'==_dgn1[`i'];
};
cap drop _dgn1;
mac drop indi;



qui tabulate `hgroup', matrow(gn);
svmat int gn;
global indica=r(r);
tokenize `varlist';

tempvar Variable POPS INCS WITH BETW ;
qui gen `Variable'="";
qui gen `POPS'=0;
qui gen `INCS'=0;
qui gen `WITH'=0;
qui gen `BETW'=0;

tempvar _ths;
qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';

cap drop _gradw; gen double _gradw=0;
cap drop _gradb; gen double _gradb=0;
cap drop _gradt; gen double _gradt=0;

local ll=length("`1': `grlab`1''");
local ttbetw = 0;
local ttwith = 0;

forvalues k = 1/$indica {;
local kk = gn1[`k'];
local  label`k'  : label (`hgroup') `kk';

if ( "`grlab`kk''" == "") local label`k'   = "Group: `kk'";
dspol2 `1' ,  hweight(`hweight')   hsize(`_ths')  fast(`fast') alpha(`alpha')   dname(`label`k'') 
 hgroup(`hgroup') gnumber(`kk')  glv(`k') tgr($indica);

local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;
qui replace `POPS'      = `r(psh)'  in `k1';
qui replace `POPS'      = `r(spsh)' in `k2';

qui replace `INCS'      = `r(ish)'  in `k1';
qui replace `INCS'      = `r(sish)' in `k2';

qui replace `WITH'      = `r(with)'  in `k1';
qui replace `WITH'      = `r(swith)' in `k2';
local ttwith            = `ttwith'+ `r(with)';

qui replace `BETW'      = `r(betw)'  in `k1';
qui replace `BETW'      = `r(sbetw)' in `k2';
local ttbetw            = `ttbetw'+ `r(betw)';

qui replace `Variable' = "`label`k''" in `k1';
local ll=max(`ll',length("`label`k''"));

};

local stdtt = `r(stdtt)';
local stdtb = `r(stdtb)';
local stdtw = `r(stdtw)';

local ll=`ll'+10;


local kk1 = `k2'+1;
local kk2 = `k2'+2;
qui replace `Variable' = "Total" in `kk1';
qui replace `POPS'      = 1.0  in `kk1';
qui replace `POPS'      = 0.0  in `kk2';

qui replace `INCS'      = 1.0 in `kk1';
qui replace `INCS'      = 0.0 in `kk2';

qui replace `WITH'      = `ttwith'   in `kk1';
qui replace `WITH'      = `stdtw' in `kk2';

qui replace `BETW'      = `ttbetw'   in `kk1';
qui replace `BETW'      = `stdtb' in `kk2';



tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width |`ll'|16 16 16 16|;
	.`table'.strcolor . . yellow . . ;
	.`table'.numcolor yellow yellow . yellow yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f;
	 di _n as text "{col 4} Decomposition of the social polarization index by population groups";

       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";
                            di  as text "{col 5}Parameter alpha : "  %5.2f `alpha'       ;
     
 
       di  as text "{col 5}Social polarization index : "  %10.8f `ttwith'+`ttbetw'  " (" %10.8f  `stdtt' ") "       ;
	.`table'.sep, top;
	.`table'.titles "Group  " "Population"  "Income "  "Within-Group" "Between-Group" ;
	.`table'.titles "       " "Share     "  "Share  "  "Component   " "Component    " ;
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor white yellow yellow yellow yellow ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green   green  green green ;
		 if (`dste'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i'] `POPS'[`i']  `INCS'[`i'] `WITH'[`i'] `BETW'[`i'];	        
             };

.`table'.sep, mid;
.`table'.numcolor white yellow yellow yellow yellow ;
.`table'.row `Variable'[`kk1'] `POPS'[`kk1']  `INCS'[`kk1'] `WITH'[`kk1'] `BETW'[`kk1'];
if (`dste'==1){;
.`table'.numcolor white green   green  green green ;
.`table'.row `Variable'[`kk2'] `POPS'[`kk2']  `INCS'[`kk2'] `WITH'[`kk2'] `BETW'[`kk2'];
};

.`table'.sep,bot;

cap ereturn clear;

cap drop __compna;
qui gen  __compna=`Variable';

local lng = ($indica*2+2);
qui keep in 1/`lng';


local rnam;
forvalues i=1(2)`lng'  {;
local temn=__compna[`i'];
               local rnam `"`rnam' "`temn'""';
if (`dste'~=0) local rnam `"`rnam' " ""';
};

global rnam `"`rnam'"';
if (`dste'==0) {;
local bf=`lng'/2+1;
forvalues j=2(1)`bf'{;
qui drop in `j';
};
};
tempname zz;

qui mkmat	 `POPS'  `INCS' `WITH' `BETW',	matrix(`zz');


                    local index = "Social polarization index"; 
if ("`xlan'"=="fr") local index = "Indice de polarisation social";

local cnam;

if ("`xlan'"~="fr")  local cnam `"`cnam' "Population share""';
if ("`xlan'"=="fr")  local cnam `"`cnam' "Proportion de la population""';
if ("`xlan'"~="fr")  local cnam `"`cnam' "Income share""';
if ("`xlan'"=="fr")  local cnam `"`cnam' "Proportion du revenue""';
if ("`xlan'"~="fr")  local cnam `"`cnam' "Within group""';
if ("`xlan'"=="fr")  local cnam `"`cnam' "intra-group""';
if ("`xlan'"~="fr")  local cnam `"`cnam' "Between group""';
if ("`xlan'"=="fr")  local cnam `"`cnam' "Inter-group""';

global cnam `"`cnam'"';

                     local xtit = "Table ##: Decomposition of social polarization index by...";
if ("`xlan'"=="fr")  local xtit = "Tableau ##: Dcomposition de l'indice de polarisation sociale selon...";
if ("`xtit'"~="")    local xtit = "`xtit'";
if ("`xfil'" ~="") {;
mk_xtab_m1 `1' ,  matn(`zz') dec(`dec') xfil(`xfil') xshe(`xshe') xtit(`xtit') xlan(`xlan') dste(`dste');
};

restore;
mac drop indica;
end;




