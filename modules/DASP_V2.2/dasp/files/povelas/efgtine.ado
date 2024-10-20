/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.2)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Universite Laval, Quebec, Canada                                       */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : efgtin                                                      */
/*************************************************************************/



#delim ;
cap program drop erfz;
program define erfz, rclass;
args z;
local t = 1.0 / (1.0 + 0.5 * abs(`z'));
        local erf = 1 - `t' * exp( -`z'*`z'   -   1.26551223 +
                                            `t' * ( 1.00002368 +
                                            `t' * ( 0.37409196 + 
                                            `t' * ( 0.09678418 + 
                                            `t' * (-0.18628806 + 
                                            `t' * ( 0.27886807 + 
                                            `t' * (-1.13520398 + 
                                            `t' * ( 1.48851587 + 
                                            `t' * (-0.82215223 + 
                                            `t' * ( 0.17087277))))))))));
        if (`z' >= 0) return scalar erf =  `erf';
        else          return scalar erf = -`erf';
    
end;


/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.0  )          */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universit Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : cdensity10000                                                */
/*************************************************************************/

#delim ;

capture program drop borderrec;
program define borderrec, rclass;
version 9.2;
args y ll ul min max band order;
preserve;

cap drop _corr1; 
qui gen  double _corr1=0;
cap drop _corr2; 
qui gen  double _corr2=0;
cap drop _corr3; 
qui gen  double _corr3=0;

tempvar ra;
qui gen `ra'=`min'+(_n-1)*(`max'-`min')/600 in 1/601;

local raf=4000;
qui count;
if `r(N)' < `raf' qui set obs `raf';
qui keep in 1/`raf';
tempvar d xd xxd xxxd xxxxd;

cap drop _x_;
qui gen   double  _x_= -50+(_n-1)*100/`raf';


qui gen  double `xd'     = _x_*exp(-0.5*_x_^2)/(sqrt(2*c(pi)));
qui gen  double `xxd'    = _x_*_x_*exp(-0.5*_x_^2)/(sqrt(2*c(pi)));
qui gen  double `xxxd'   = _x_*_x_*_x_*exp(-0.5*_x_^2)/(sqrt(2*c(pi)));
qui gen  double `xxxxd'  = _x_*_x_*_x_*_x_*exp(-0.5*_x_^2)/(sqrt(2*c(pi)));

tempname _aa _bb;
cap drop `_aa';
cap drop `_bb';
qui gen  double  `_aa' = (`ra'-`ul')/`band'; 
qui gen  double `_bb' = (`ra'-`ll')/`band';

qui sum `_x_';
local mina = r(min); 
local maxa = r(max); 

 forvalues i=1/601 {; 
 local t1=`_aa'[`i']; 
 local t2=`_bb'[`i'];

 local int11 =  normal(`_bb'[`i']) - normal(`_aa'[`i']); 
 qui integ `xd'  _x_  if (_x_ >= `t1' & _x_<= `t2') ;
 local int12= r(integral);
 local int21 = `int12';
 qui integ `xxd'  _x_ if (_x_ >= `t1' & _x_<= `t2') ;
 local int22= r(integral); 
 local int13=`int22'/2;
 local int31=`int13';
 qui integ `xxxd' _x_ if (_x_ >= `t1' & _x_<= `t2') ;
 local int23 = r(integral)/2;
 local int32 = `int23';
 qui integ `xxxxd' _x_ if (_x_ >= `t1' & _x_<= `t2') ;
 local int33 = r(integral)/4;
 matrix M=(
          `int11',`int12', `int13'\
          `int21',`int22', `int23'\
          `int31',`int32', `int33'
          );
 matrix IM = inv(M);
 qui replace _corr1=el(IM,1,1) in `i'; 
 qui replace _corr2=el(IM,1,2) in `i'; 
 qui replace _corr3=el(IM,1,3) in `i';  
 local posa = `i'/6;
 if ( `i'/6 ==round(`i'/6)    & `i/6'!=601)  dis "." ,  _continue;
 if ( `i'/60==round(`i'/60)) dis " "  %4.2f `posa' " %";

 };     

 
set matsize 800;
qui keep in 1/601;
mkmat _corr1 _corr2 _corr3, matrix(_corr);
restore;
end;










capture program drop numimp;
program define numimp, rclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) BAND(real 0)  AL(real 0) PL(real 10000) perc(real 1)  HGroup(string) GNumber(int -1) glabel(string)] ;

preserve;

tokenize  `varlist';


qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local hweight=""; 
cap qui svy: total `1'; 
cap local hweight=`"`e(wvar)'"';
cap ereturn clear; 

tempvar fw;
qui gen `fw'= 1;
if ("`hsize'"  ~="")      qui replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")      qui replace `fw'=`fw'*`hweight';


local _cory  = "";
local label = "";


qui cap drop if `1'>=.;
qui cap drop if `fw'>=.;


qui sum `1' [aw=`fw'];
local mu = r(mean);
if(`gnumber'!=-1) qui keep if `hgroup'==`gnumber';
 
qui sum `1'; 
local ll =`r(min)' ; 
local ul =`r(max)';


qui count;
if (`r(N)'<601) qui set obs 601;


qui count;
qui sum `1';
local min =`r(min)';

if (`al' == 0 & `pl'<= `mu')  local max = (`pl'+`perc'/100*`mu')/(1+`perc'/100);
if (`al' == 0 & `pl' > `mu')  local max = (`pl');


if (`al' == 1 & `pl'<= `mu')  local max = (`pl'+`perc'/100*`mu')/(1+`perc'/100);
if (`al' == 1 & `pl' > `mu')  local max = (`pl');


if (`al' == 2 & `pl'<= `mu')  local max = (`pl'+`perc'/100*`mu')/(1+`perc'/100);
if (`al' == 2 & `pl' > `mu')  local max = (`pl');

tempvar  _density _ra;

qui gen double `_ra'=0;
qui gen double `_density' = 0;





local pas = (`max'-`min')/600;
if (_N<601) qui set obs 601;
qui su `1' [aw=`fw'], detail;            
local tmp = (`r(p75)'-`r(p25)')/1.34;                           
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)';     
local h   = 0.9*`tmp'*_N^(-1.0/5.0); 
if (`band'==0) local band=`h'; 

tempvar _s2;
qui gen `_s2' = sum( `fw' ); 
dis "ESTIMATION IN PROGRESS";
dis "Estimation for component: `glabel'";
borderrec `1' `ll' `ul' `min' `max' `band' 3;
svmat _corr; 

forvalues j=1/601 {;
cap drop `_s1'; 
tempvar  _s1;
qui replace `_ra'=`min'+(`j'-1)*`pas' in `j';
qui gen `_s1' =   `fw'*exp(-0.5* ( ((`_ra'[`j']-`1')/`band')^2  )  ); 
qui replace `_s1'= ( _corr1[`j'] + ((`_ra'[`j']-`1')/`band')*_corr2[`j'] + ((`_ra'[`j']-`1')/`band')^2/2*_corr3[`j'] )*`_s1';
if ( `_ra'[`j']<`ll' | `_ra'[`j'] > `ul' ) qui replace `_s1'=0; 

qui sum `_s1'; 
local sum1=`r(sum)';
local sum1=max(0,`r(sum)');
qui replace `_density'= `sum1'/( `band'* sqrt(2*c(pi)) * `_s2'[_N] )  in `j';
};
cap drop _density;








local g= 1+`perc'/100;
local gr = `perc'/100;
qui gen _corxx = `_ra';
qui gen _coryy = `_density';
sum _coryy;

sort _corx;
local est = .;


if (`al' == 0) {;
tempvar comp;
if (`pl'<=`mu')  {;
local mn = `pl';
local mx = (`pl'+`gr'*`mu')/(`g');
gen `comp' = _coryy *(`mn'<_corxx)*(_corxx<`mx') ;
};
if (`pl'>`mu')  {;
local mn = (`pl'+`gr'*`mu')/(`g');
local mx = `pl';
gen `comp' = _coryy *(`mn'<_corxx)*(_corxx<`mx') ;
};

qui integ `comp' _corxx;
local imp = r(integral) ;
};

if (`al' == 1) {;

tempvar comp1 comp2 comp3;
if ( `pl' <= `mu' )  {;

local mn1 =  0;
local mx1 = `pl';

local mn2 = `pl';
local mx2 = (`pl'+`gr'*`mu')/(`g');

gen double `comp1' = `gr'* (`mu' /`pl' - _corxx/`pl')*(`mn1'<=_corxx)*(_corxx<=`mx1') ;
gen double `comp2' = ( (`pl'-`mu')+`g'*(`mu'-_corxx) ) / `pl' *(`mn2'<=_corxx)*(_corxx<=`mx2') ;
gen double `comp3' = 0;

};

if ( `pl' > `mu' )  {;



local mn1 =  0;
local mx1 = `mu';

local mn2 = `mu';
local mx2 = (`pl'+`gr'*`mu')/(`g');

local mn3 = (`pl'+`gr'*`mu')/(`g');
local mx3 =  `pl';


gen double `comp1' = `gr'*(`mu'-_corxx)/`pl' *(`mn1'<_corxx)*(_corxx<`mx1') ;
gen double `comp2' = `gr' *(`mu'-_corxx)/(`pl') *(`mn2'<_corxx)*(_corxx<`mx2') ;
gen double `comp3' =       (_corxx/`pl' -1) *(`mn3'<_corxx)*(_corxx<`mx3') ;;

};



cap drop __y;
qui gen  __y  =_coryy*(`comp1' + `comp2' + `comp3');
qui integ __y _corxx;
local imp = r(integral);
};


if (`al' == 2) {;
tempvar comp1 comp2 comp3;
if (`pl'<=`mu')  {;

local mn1 =  0;
local mx1 = `pl';

local mn2 = `pl';
local mx2 = (`pl'+`gr'*`mu')/(`g');

gen double `comp1' = 1/(`pl'^2)*( (`pl' -(`g'*_corxx-`gr'*`mu'))^2 - (`pl' -_corxx)^2  )*(`mn1'<=_corxx)*(_corxx<=`mx1') ;
gen double `comp2' = 1/(`pl'^2)* (`pl' -_corxx)^2  *(`mn2'<=_corxx)*(_corxx<=`mx2') ;

gen double `comp3' = 0;

//sum `comp1' `comp2' ;

};



if (`pl'>`mu')  {;

local mn1 =  0;
local mx1 = (`pl'+`gr'*`mu')/(`g');

local mn2 = (`pl'+`gr'*`mu')/(`g');
local mx2 =  `pl';


gen double `comp1' =  1/(`pl'^2)*( (`pl' -(`g'*_corxx-`gr'*`mu'))^2 - (`pl' -_corxx)^2  )*(`mn1'<=_corxx)*(_corxx<=`mx1') ;
gen double `comp2' = -1/(`pl'^2)*( (`pl' -_corxx)^2  ) *(`mn2'<=_corxx)*(_corxx<=`mx2') ;
gen double `comp3' = 0;

};

cap drop __y;
qui gen  __y =_coryy*(`comp1' + `comp2' + `comp3');
qui integ __y _corxx;
local imp = r(integral);

};

return scalar est = `imp' ;


restore;
end;





capture program drop gnumimp;
program define gnumimp, rclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) BAND(real 0)  AL(real 0) PL(real 10000) mina(real 0) maxa(real 100)  HGroup(string) GNumber(int -1) glabel(string)] ;

preserve;

tokenize  `varlist';


qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local hweight=""; 
cap qui svy: total `1'; 
cap local hweight=`"`e(wvar)'"';
cap ereturn clear; 

tempvar fw;
qui gen `fw'= 1;
if ("`hsize'"  ~="")      qui replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")      qui replace `fw'=`fw'*`hweight';


local _cory  = "";
local label = "";


qui cap drop if `1'>=.;
qui cap drop if `fw'>=.;


qui sum `1' [aw=`fw'];
local mu = r(mean);

if(`gnumber'!=-1) qui keep if `hgroup'==`gnumber';
 
qui sum `1'; 
local ll =`r(min)' ; 
local ul =`r(max)';


qui count;
if (`r(N)'<601) qui set obs 601;


qui count;
qui sum `1';
local min =`r(min)';
local max =`pl'*(1+`maxa'/100);


tempvar  _density _ra impo;

qui gen `_ra'=0;
qui gen `_density'=0;
qui gen `impo'=0;





local pas = (`max'-`min')/600;
if (_N<601) qui set obs 601;
qui su `1' [aw=`fw'], detail;            
local tmp = (`r(p75)'-`r(p25)')/1.34;                           
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)';     
local h   = 0.9*`tmp'*_N^(-1.0/5.0); 
if (`band'==0) local band=`h'; 

tempvar _s2;
qui gen `_s2' = sum( `fw' ); 
dis "ESTIMATION IN PROGRESS";
dis "Estimation for component: `glabel'";
borderrec `1' `ll' `ul' `min' `max' `band' 3;


svmat _corr; 



forvalues j=1/601 {;
cap drop `_s1'; 
tempvar  _s1;
qui replace `_ra'=`min'+(`j'-1)*`pas' in `j';
qui gen `_s1' =   `fw'*exp(-0.5* ( ((`_ra'[`j']-`1')/`band')^2  )  ); 
qui replace `_s1'= ( _corr1[`j'] + ((`_ra'[`j']-`1')/`band')*_corr2[`j'] + ((`_ra'[`j']-`1')/`band')^2/2*_corr3[`j'] )*`_s1';
if ( `_ra'[`j']<`ll' | `_ra'[`j'] > `ul' ) qui replace `_s1'=0; 

qui sum `_s1'; 
local sum1=`r(sum)';
local sum1=max(0,`r(sum)');
qui replace `_density'= `sum1'/( `band'* sqrt(2*c(pi)) * `_s2'[_N] )  in `j';
};
cap drop _density;
qui gen _density=`_density';

tempvar ra imp;
gen `ra'=0;
gen `imp'=0;

qui gen _corxx = `_ra';
qui gen _coryy = `_density';
sort    _corxx;

local est = .;

local pas = (`maxa'-`mina')/100;

forvalues k=2/101 {;

local tt = `mina'+(`k'-1)*`pas';
local g = 1 +  `tt' / 100;
local gr =     `tt' / 100;





if (`al' == 0) {;
tempvar comp;
if (`pl'<=`mu')  {;
local mn = `pl';
local mx = (`pl'+`gr'*`mu')/(`g');
gen `comp' = _coryy *(`mn'<_corxx)*(_corxx<`mx') ;
};
if (`pl'>`mu')  {;
local mn = (`pl'+`gr'*`mu')/(`g');
local mx = `pl';
gen `comp' = _coryy *(`mn'<_corxx)*(_corxx<`mx') ;
};

qui integ `comp' _corxx;
local imp = r(integral) ;
};

if (`al' == 1) {;

tempvar comp1 comp2 comp3;
if (`pl'<=`mu')  {;

local mn1 =  0;
local mx1 = `pl';

local mn2 = `pl';
local mx2 = (`pl'+`gr'*`mu')/(`g');

gen double `comp1' = `gr'* (`mu' /`pl' - _corxx/`pl')*(`mn1'<=_corxx)*(_corxx<=`mx1') ;
gen double `comp2' = ( (`pl'-`mu')+`g'*(`mu'-_corxx) ) / `pl' *(`mn2'<=_corxx)*(_corxx<=`mx2') ;
gen double `comp3' = 0;

};

if (`pl'>`mu')  {;



local mn1 =  0;
local mx1 = `mu';

local mn2 = `mu';
local mx2 = (`pl'+`gr'*`mu')/(`g');

local mn3 = (`pl'+`gr'*`mu')/(`g');
local mx3 =  `pl';


gen double `comp1' = `gr'*(`mu'-_corxx)/`pl' *(`mn1'<_corxx)*(_corxx<`mx1') ;
gen double `comp2' = `gr' *(`mu'-_corxx)/(`pl') *(`mn2'<_corxx)*(_corxx<`mx2') ;
gen double `comp3' =       (_corxx/`pl' -1) *(`mn3'<_corxx)*(_corxx<`mx3') ;;

};



cap drop __y;
qui gen  __y =_coryy*(`comp1' + `comp2' + `comp3');
qui integ __y _corxx;
local imp = r(integral);
};


if (`al' == 2) {;
tempvar comp1 comp2 comp3;
if (`pl'<=`mu')  {;

local mn1 =  0;
local mx1 = `pl';

local mn2 = `pl';
local mx2 = (`pl'+`gr'*`mu')/(`g');

gen double `comp1' = 1/(`pl'^2)*( (`pl' -(`g'*_corxx-`gr'*`mu'))^2 - (`pl' -_corxx)^2  )*(`mn1'<=_corxx)*(_corxx<=`mx1') ;
gen double `comp2' = 1/(`pl'^2)* (`pl' -_corxx)^2  *(`mn2'<=_corxx)*(_corxx<=`mx2') ;

gen double `comp3' = 0;

//sum `comp1' `comp2' ;

};



if (`pl'>`mu')  {;

local mn1 =  0;
local mx1 = (`pl'+`gr'*`mu')/(`g');

local mn2 = (`pl'+`gr'*`mu')/(`g');
local mx2 =  `pl';


gen double `comp1' =  1/(`pl'^2)*( (`pl' -(`g'*_corxx-`gr'*`mu'))^2 - (`pl' -_corxx)^2  )*(`mn1'<=_corxx)*(_corxx<=`mx1') ;
gen double `comp2' = -1/(`pl'^2)*( (`pl' -_corxx)^2  ) *(`mn2'<=_corxx)*(_corxx<=`mx2') ;
gen double `comp3' = 0;

};


qui gen part = `comp1' + `comp2' + `comp3';

cap drop __y;
qui gen  __y =_coryy*(`comp1' + `comp2' + `comp3');
qui integ __y _corxx;
local imp = r(integral);

};

qui replace `impo' = `imp' in `k';




};

mkmat `impo' in 1/101 , matrix(_nn) ;
restore;
end;



capture program drop efgtin2;
program define efgtin2, rclass;
version 9.2;
syntax varlist [,  FWeight(string) HSize(string) HGroup(varname)
 GNumber(int -1) glabel(string) AL(real 0) PL(string)  APR(string) EST(string) PERC(real 1)];
preserve;
tokenize `varlist';
tempvar hs hst;
gen `hs' =`hsize';
gen `hst'=`hsize';


if (`gnumber'!=-1)    qui replace `hs'  =`hs'*(`hgroup'==`gnumber');

                        local hweight="";  cap qui svy: total `1'; 
                        local hweight=`"`e(wvar)'"'; cap ereturn clear; 
                        tempvar sw;
					    qui gen `sw' = 1;     
                        if (`"`hweight'"'~="") qui replace `sw' =     `hweight';
						
						tempvar fw;
                        qui gen `fw' =`hs';
					    if (`"`hweight'"'~="") qui replace `fw' =`hs'*`hweight';
						
						tempvar fwt;
                        qui gen `fwt' =`hst';
					    if (`"`hweight'"'~="") qui replace `fwt' =`hst'*`hweight';
						
qui sum `1' [aw=`fw'];
local mu = `r(mean)';						
tempvar   num;
qui gen   `num'=0;
if (`al' == 0)   qui replace    `num' = (`pl'> `1');
if (`al' >  0)   qui replace    `num' = (1 - `1' / `pl' )^`al'      if (`pl'>`1');
qui sum `num'    [aw=`fwt'],   
 meanonly; local ptot =r(mean);

if("`est'" == "smelas") local ptot = 1;
						

if("`apr'" == "analytic" |  "`apr'" == "all" ) {;
cap drop `num' `cnum' `denum';
tempvar num cnum denum;
qui gen   `num'=0;
qui gen  `cnum'=0;
qui gen  `denum'=0;
local al1=`al'-1;

if (`al' == 0)         {;
                       
                                qui su `1' [aw=`fw'], detail;           
                                local tmp = (`r(p75)'-`r(p25)')/1.34;                          
                                local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
                                local h   = 0.9*`tmp'*_N^(-1.0/5.0);  
                                qui replace   `num' = `hs' *(`mu'-`pl')*exp(-0.5* ( ((`pl'-`1')/`h')^2  )  )/( `h'* sqrt(2*c(pi)));  
                                qui replace `denum' = `hst'*(`pl'> `1');
	                            if("`est'" == "smelas") qui replace   `denum' = `hst';   
                       };
if (`al' > 0)  {;
                        if (`al1' == 0) qui replace    `cnum' = `hs'*(`pl'> `1');
                        if (`al1' >  0) qui replace    `cnum' = `hs'*(1 - `1' / `pl' )^`al1'     if (`pl'>`1');

                    qui replace    `num'    = `hs'*(1 - `1' / `pl' )^`al' + (`mu'/`pl'-1)*`cnum'            if (`pl'>`1');
                    qui replace    `num'    = `al'*`num';
                    qui replace    `denum'  = `hst'*(1 - `1' / `pl' )^`al'                    if (`pl'>`1');
					if("`est'" == "smelas") qui replace   `denum' = `hst';   
                    };



qui sum `num'   [aw=`sw'],   meanonly; local m1=r(mean);
qui sum `hs'    [aw=`sw'],   meanonly; local m2=r(mean);
qui sum `denum' [aw=`sw'],   meanonly; local m3=r(mean);
qui sum `hst'   [aw=`sw'],   meanonly; local m4=r(mean);

local est=(`m1'*`m4')/(`m2'*`m3'); 
                    return scalar est  = `est'*`perc'/(100);
if "`apr'" == "all" return scalar est1 = `est'*`perc'/(100);

};


if("`apr'" == "simulated" |  "`apr'" == "all" ) {;

tempvar sy num1 num2;

gen `sy'=`1'+ (`perc'/100)*(`1'-`mu');
qui gen   `num1'=0;
qui gen   `num2'=0;


              if (`al' == 0)   qui replace    `num1' = (`pl'> `1');
			  if (`al' == 0)   qui replace    `num2' = (`pl'> `sy');
              if (`al' >  0)   qui replace    `num1' = (1 - `1' / `pl' )^`al'      if (`pl'>`1');
			  if (`al' >  0)  qui replace     `num2' = (1 - `sy' / `pl' )^`al'     if (`pl'>`sy');

qui sum `num1'    [aw=`fw'],   meanonly; local m1=r(mean);
qui sum `num2'    [aw=`fw'],   meanonly; local m2=r(mean);



local est = (`m2'-`m1')/ `ptot'  ;

return scalar est = `est';
if "`apr'" == "all" return scalar est2 = `est';

};




if ("`apr'" == "numeric" |  "`apr'" == "all" ) {;
numimp `1' , pl(`pl') al(`al') hsize(`hs') perc(`perc')  hgroup(varname) gnumber(-1) glabel(`glabel');
local est = (r(est)/`ptot');
return scalar est = `est' ;
if "`apr'" == "all" return scalar est3 = `est';

};

restore;

end;






capture program drop gefgtin2;
program define gefgtin2, rclass;
version 9.2;
syntax varlist [,  FWeight(string) HSize(string) HGroup(varname)
 GNumber(int -1) glabel(string) AL(real 0) PL(string)  APR(string)  EST(string) MIN(real 0) MAX(real 100)];
preserve;
tokenize `varlist';
tempvar hs hst;
gen `hs' =`hsize';
gen `hst'=`hsize';


if (`gnumber'!=-1)    qui replace `hs'  =`hs'*(`hgroup'==`gnumber');

                        local hweight="";  cap qui svy: total `1'; 
                        local hweight=`"`e(wvar)'"'; cap ereturn clear; 
                        tempvar sw;
					    qui gen `sw' = 1;     
                        if (`"`hweight'"'~="") qui replace `sw' =     `hweight';
						
						tempvar fw;
                        qui gen `fw' =`hs';
					    if (`"`hweight'"'~="") qui replace `fw' =`hs'*`hweight';
						
						tempvar fwt;
                        qui gen `fwt' =`hst';
					    if (`"`hweight'"'~="") qui replace `fwt' =`hst'*`hweight';
						
qui sum `1' [aw=`fw'];
local mu = `r(mean)';						
						
						
tempvar   num;
qui gen   `num'=0;
if (`al' == 0)   qui replace    `num' = (`pl'> `1');
if (`al' >  0)   qui replace    `num' = (1 - `1' / `pl' )^`al'      if (`pl'>`1');
qui sum `num'    [aw=`fwt'],   
 meanonly; local ptot =r(mean);
if("`est'" == "smelas") local ptot =1;


tempvar ra imp imp1 imp2 imp3 imp4;
qui gen `ra'=0;
qui gen `imp'=0;
qui gen `imp1'=0;
qui gen `imp2'=0;
qui gen `imp3'=0;
qui gen `imp4'=0;
local pas = (`max'-`min')/100;
if (_N<101) qui cap set obs 101;
forvalues j=1/101 {;
qui replace `ra'=`min'+(`j'-1)*`pas' in `j';
};




if("`apr'" == "analytic" |  "`apr'" == "all"  ) {;


forvalues i=2/101 {;

cap drop `num' `cnum' `denum';
tempvar num cnum denum;
qui gen   `num'=0;
qui gen  `cnum'=0;
qui gen  `denum'=0;
local al1=`al'-1;

if (`al' == 0)         {;
                       
                                qui su `1' [aw=`fw'], detail;           
                                local tmp = (`r(p75)'-`r(p25)')/1.34;                          
                                local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
                                local h   = 0.9*`tmp'*_N^(-1.0/5.0);  
                                qui replace   `num' = `hs' *(`mu'-`pl')*exp(-0.5* ( ((`pl'-`1')/`h')^2  )  )/( `h'* sqrt(2*c(pi)));  
                                qui replace `denum' = `hst'*(`pl'> `1');
	                            if("`est'" == "smelas") qui replace   `denum' = `hst';   
                       };
if (`al' > 0)  {;
                        if (`al1' == 0) qui replace    `cnum' = `hs'*(`pl'> `1');
                        if (`al1' >  0) qui replace    `cnum' = `hs'*(1 - `1' / `pl' )^`al1'     if (`pl'>`1');

                    qui replace    `num'    = `hs'*(1 - `1' / `pl' )^`al' + (`mu'/`pl'-1)*`cnum'            if (`pl'>`1');
                    qui replace    `num'    = `al'*`num';
                    qui replace    `denum'  = `hst'*(1 - `1' / `pl' )^`al'                    if (`pl'>`1');
					if("`est'" == "smelas") qui replace   `denum' = `hst';   
                    };
					
					



qui sum `num'   [aw=`sw'],   meanonly; local m1=r(mean);
qui sum `hs'    [aw=`sw'],   meanonly; local m2=r(mean);
qui sum `denum' [aw=`sw'],   meanonly; local m3=r(mean);
qui sum `hst'   [aw=`sw'],   meanonly; local m4=r(mean);

local est=(`m1'*`m4')/(`m2'*`m3'); 

qui replace `imp' = `est'*`ra'[`i']/100 in `i';




};


};

if "`apr'" == "all" qui replace `imp1' = `imp';

if("`apr'" == "simulated" |  "`apr'" == "all" ) {;

forvalues i=2/101 {;
tempvar sy num1 num2;
gen `sy'=`1'+ (`ra'[`i']/100)*(`1'-`mu');
qui gen   `num1'=0;
qui gen   `num2'=0;


              if (`al' == 0)   qui replace    `num1' = (`pl'> `1');
			  if (`al' == 0)   qui replace    `num2' = (`pl'> `sy');
              if (`al' >  0)   qui replace    `num1' = (1 - `1' / `pl' )^`al'      if (`pl'>`1');
			  if (`al' >  0)  qui replace     `num2' = (1 - `sy' / `pl' )^`al'     if (`pl'>`sy');

qui sum `num1'    [aw=`fw'],   meanonly; local m1=r(mean);
qui sum `num2'    [aw=`fw'],   meanonly; local m2=r(mean);



local est = (`m2'-`m1')/ `ptot'  ;

qui replace `imp' = `est' in `i';



 };

};

if "`apr'" == "all" qui replace `imp2' = `imp';



if("`apr'" == "numeric" |  "`apr'" == "all" ) {;
gnumimp `1' , pl(`pl') al(`al') hsize(`hs') mina(`min') maxa(`max')   hgroup(varname) gnumber(-1) glabel(`glabel');

svmat float _nn;
qui replace `imp' = _nn1/`ptot' in 1/101;
cap matrix drop _nn;
cap drop _nn1;
};

if "`apr'" == "all" qui replace `imp3' = `imp';

qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat `imp', matrix(_xx);

if "`apr'" == "all" {;
cap matrix drop _xx;
mkmat `imp1' `imp2' `imp3' , matrix(_xx);
};
restore;
end;






capture program drop efgtin;
program define efgtin, rclass;
version 9.2;
syntax varlist [,   
HSize(string) 
HGroup(varname)
ALpha(real 0) 
PLine(string)  
APR(string) 
EST(string)
PERC(real 1)
DEC(int 6)
MIN(string) 
MAX(string)
LRES(int 0)  
SRES(string) 
DGRA(int 1) 
SGRA(string) 
EGRA(string) *
];
_get_gropts , graphopts(`options') ; local options `"`s(graphopts)'"';


if ("`apr'" =="")          local apr ="analytic";
if ("`est'" =="")          local est ="elas";
if ("`est'" =="elas")      local perc = 1;


local ll=0;

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);




/* ERRORS */



if ("`hgroup'"!="") {;

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

if (`"`apr'"'=="all" & "`dgr'"	== "yes" ) {;
global indicas = 4;
global indica  = 1;

};

tempvar Variable Estimate Estimate1 Estimate2 Estimate3 Estimate4 PL;
qui gen `Variable'="";
qui gen `Estimate'=0;
qui gen `Estimate1'=0;
qui gen `Estimate2'=0;
qui gen `Estimate3'=0;
qui gen `PL'=0;

tempvar _ths _fw;

qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';
qui gen `_fw'=`_ths';
if (`"`hweight'"'~="") qui replace `_fw'=`_fw'*`hweight';


local dgr =	"no";

if ("`max'"	~= "" )	local	dgr	=	"yes";




if ("`dgr'"	== "no"	){;


local ll=length("`1': `grlab`1''");
local component = "Variable";

forvalues k = 1/$indica {;

                      local multi = 1;
if ("`est'" =="elas") local multi = 100;


if ("`hgroup'"=="")     {;
qui replace `Variable' = "``k''" in `k';
efgtin2 ``k'' ,  hsize(`_ths') pl(`pline') al(`alpha') apr(`apr') est(`est') perc(`perc')  gnumber(-1) glabel("``k''") ;


qui replace `Estimate' = `r(est)'*`multi' in `k';


if "`apr'" == "all" {;
qui replace `Estimate1' = `r(est1)'*`multi' in `k';
qui replace `Estimate2' = `r(est2)'*`multi' in `k';
qui replace `Estimate3' = `r(est3)'*`multi' in `k';

};

};

if ("`hgroup'"!="") {;
local kk = gn1[`k'];

if ( "`grlab`kk''" == "") local grlab`kk' = "Group_`kk'";
qui replace `Variable' = "`kk': `grlab`kk''" in `k';

efgtin2 `1' ,   hsize(`_ths') pl(`pline') al(`alpha')  hgroup(`hgroup') gnumber(`kk') apr(`apr') est(`est') perc(`perc') glabel(`grlab`k'');
qui replace `Estimate' = `r(est)'*`multi' in `k';
if "`apr'" == "all" {;
qui replace `Estimate1' = `r(est1)'*`multi' in `k';
qui replace `Estimate2' = `r(est2)'*`multi' in `k';
qui replace `Estimate3' = `r(est3)'*`multi' in `k';

};
local ll=max(`ll',length("`kk': `grlab`k''"));
local component = "Group";
};

};

local ll=`ll'+6;


if ("`hgroup'"!="") {;
efgtin2 `1' ,   hsize(`_ths') pl(`pline') al(`alpha') apr(`apr') est(`est') perc(`perc') glabel("Population");
local kk =$indica + 1;
qui replace `Variable' = "Population" in `kk';
qui replace `Estimate' = `r(est)'*`multi' in `kk';
if "`apr'" == "all" {;
qui replace `Estimate1' = `r(est1)'*`multi' in `kk';
qui replace `Estimate2' = `r(est2)'*`multi' in `kk';
qui replace `Estimate3' = `r(est3)'*`multi' in `kk';

};
};

local 1kk = $indica;
if ("`hgroup'"!="") local  1kk=`kk'-1;

if "`apr'" ~= "all" {;
tempname table;
        .`table'  = ._tab.new, col(2)  separator(0) lmargin(0);
        .`table'.width  `ll'|16   ;
        .`table'.strcolor . . ;
        .`table'.numcolor yellow yellow  ;
        .`table'.numfmt %16.0g  %16.`dec'f  ;
                              di _n as text in white "{col 5}Elasticity of total poverty with respect to average income growth.";
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";
       
        di  as text "{col 5}Parameter alpha : "  %5.2f `alpha'       ;
      .`table'.sep, top;
        .`table'.titles "`component'  " "Estimate"   ;
        
        .`table'.sep, mid;
        local nalt = "ddd";
        forvalues i=1/`1kk'{;
                        .`table'.row `Variable'[`i'] `Estimate'[`i']  ; 
        };
 if ("`hgroup'"=="")  .`table'.sep,bot;
if ("`hgroup'"!="") {;
  .`table'.sep, mid;
  .`table'.numcolor white green    ;
  .`table'.row `Variable'[`kk'] `Estimate'[`kk']   ;
  .`table'.sep,bot;
};

};


if "`apr'" == "all" {;
tempname table;
        .`table'  = ._tab.new, col(4)  separator(0) lmargin(0);
        .`table'.width  `ll'|16|16|16   ;
        .`table'.strcolor . . . . ;
        .`table'.numcolor yellow yellow yellow yellow   ;
        .`table'.numfmt %16.0g  %16.`dec'f %16.`dec'f  %16.`dec'f    ;
                            di _n as text in white "{col 5}Elasticity of total poverty with respect to average income growth.";
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";
       
        di  as text "{col 5}Parameter alpha : "  %5.2f `alpha'       ;
      .`table'.sep, top;
        .`table'.titles "`component'  " "Estimate  "  "Estimate  "    "Estimate  "   ;
		.`table'.titles "`component'  " "Analytical"  "Semulated "    "Numerical " ;
        
        .`table'.sep, mid;
        local nalt = "ddd";
        forvalues i=1/`1kk'{;
                        .`table'.row `Variable'[`i'] `Estimate1'[`i']  `Estimate2'[`i'] `Estimate3'[`i']  ; 
        };
 if ("`hgroup'"=="")  .`table'.sep,bot;
if ("`hgroup'"!="") {;
  .`table'.sep, mid;
  .`table'.numcolor white green green green     ;
  .`table'.row `Variable'[`kk'] `Estimate1'[`kk'] `Estimate2'[`kk'] `Estimate3'[`kk']   ;
  .`table'.sep,bot;
};

};





cap ereturn clear;

};

if ("`dgr'"	== "yes"){;
dis "IN PROGRESS to draw curves";


local _cory  = "";
local label = "";
// quietly{;
local tit1="FGT"; 
local tit2="FGT"; 
local tit3="";
local tit4="";
local tits="";
if ($indica>1) local tits="s";



local ftitle = "Semi-Elasticity of poverty FGT with respect to Gini Inequality: (alpha=`alpha')";
                   local ytitle = "Semi-Elasticity";



qui count;
qui sum `1';
if ("`min'"  =="")      local min =`r(min)';
if ("`max'"  =="")      local max =`r(max)';
if ("`type'"  =="")     local type ="yes";
if (r(N)<101) qui cap set obs 101;

forvalues k = 1/$indica {;
local _cory  = "`_cory'" + " _cory`k'";
local f=`k';
if ("`hgroup'"=="") {;
local label`f'  =  "``k''";
gefgtin2 ``k'' ,  hsize(`_ths') pl(`pline') al(`alpha') apr(`apr')  gnumber(-1) glabel("``k''")  min(`min') max(`max');
};


if ("`hgroup'"!="") {;

local kk = gn1[`k'];
local k1 = gn1[1];
local label`f'  : label (`hgroup') `kk';
local labelg1   : label (`hgroup') `k1';
if ( "`label1'" == "")   local labelg1    = "Group: `k1'";
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";
gefgtin2 `1' ,   hsize(`_ths') pl(`pline') al(`alpha')  hgroup(`hgroup') gnumber(`kk') apr(`apr')  glabel(`grlab`k'') min(`min') max(`max');

};
  svmat float _xx;

 rename _xx1 _cory`k';
 
 if ("`apr'" == "all" ) {;
 rename _xx2 _cory2;
 rename _xx3 _cory3;
 
 };

cap matrix drop _xx;
};

qui keep in 1/101;
gen _corx=0;
local pas = (`max'-`min')/100;
local m5 = (`max'-`min')/5;
forvalues j=1/101 {;
qui replace _corx=`min'+(`j'-1)*`pas' in `j';
};



//}; qui

if( `lres' == 1) {;
set more off;
list _corx _cory*;
};

if ( "`apr'" == "all" ) {;
local label1 = "Analytical";
local label2 = "Simulated";
local label3 = "Numerical";

 };
quietly {;

if (`dgra'!=0) {; 
line _cory*  _corx, 
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
title(`ftitle',  size(medium))
ytitle(`ytitle')
xtitle(Increase in Gini (in %)) 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
plotregion(margin(zero))
graphregion(margin(medlarge))
legend(size(medsmall))
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


};



};// end

end;
