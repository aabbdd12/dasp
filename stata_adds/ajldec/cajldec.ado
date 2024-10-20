/********************************************/
/* By: Araar Abdelkrim : aabd@ecn.ulaval.ca */
/* JEL decomposition  : 19/08/2005          */
/********************************************/

cap program drop sgini
program define sgini, rclass
args  fw inc gr indi
#delim ;
qui {;
preserve;
if ("`fw'" == "") {;
cap drop fw;
gen fw = 1;
};

sum `fw'; 
local tm1 = r(sum);
sum `inc' [aw=`fw']; 
local tm2 = r(sum);


if ("`gr'" != "") {;
keep if(`gr' == `indi');
};

sum `fw';
local tmg1 = r(sum);
sum `inc' [aw=`fw'];
local tmg2 = r(sum);
local mug = r(mean);
local propop = `tmg1'/`tm1';
local proinc = `tmg2'/`tm2';


};
local gini = 0;
qui count;
if (`r(N)' == 0){;
local propop=0;
local proinc=0;
};
if (`r(N)' > 1) {;
qui {;
cap drop if `inc'>=. | `fw'>=.;
gsort -`inc';
gen vr = sum(`fw')^2; gen p = vr  - vr[_n-1];
replace p = vr[1] in 1; replace p = p / vr[_N];
gen  xi = sum(p*`inc');  local xi = xi[_N];
sum `inc' [aw=`fw']; local mu = `r(mean)';
local gini = 1 - (`xi'/`mu');
};

};
restore; 
return scalar gini   = `gini';
return scalar proinc = `proinc';
return scalar propop = `propop';
return scalar mug    = `mug';
end;



#delim cr
cap program drop sconc
program define sconc, rclass
args  fw tax inc gr indi
#delim ;
cap drop if `tax'>=. |`inc'>=. | `fw'>=.;
qui {;
preserve;
if ("`fw'" == "") {;
cap drop fw;
gen fw = 1;
};

qui sum `fw'; 
local tm1 = r(sum);
qui sum `tax' [aw=`fw']; 
local tm2 = r(sum);


if ("`gr'" != "") {;
keep if(`gr' == `indi');
};

sum `fw';
local tmg1 = r(sum);
sum `tax' [aw=`fw'];
local tmg2 = r(sum);
local mug = r(mean);
local propop = `tmg1'/`tm1';
local proinc = `tmg2'/`tm2';


};
local conc = 0;
qui count;
if (`r(N)' == 0){;
local propop=0;
local proinc=0;
};
if (`r(N)' > 1) {;
qui {;
gsort -`inc';
gen vr = sum(`fw')^2; gen p = vr  - vr[_n-1];
replace p = vr[1] in 1; replace p = p / vr[_N];
gen  xi = sum(p*`tax');  local xi = xi[_N];
sum `tax' [aw=`fw']; local mu = `r(mean)';
local conc = 1 - (`xi'/`mu');
};

};
restore; 
return scalar conc   = `conc';
return scalar proinc = `proinc';
return scalar propop = `propop';
return scalar mug    = `mug';
end;






set more off;
#delim ;
cap program drop cajldec;
program define cajldec, rclass;
syntax varlist(min=3 max=3) [, 
intmin(real 0) intmax(real 10000)  step(real 1000)   
HSize(string)  STRata(string) PSU(string) PWeight(string) 
GRoup(string) sg(int 1) detail(string) ];
preserve;
qui tokenize `varlist';
#delim cr

tempvar pw hs fw 


gen `pw'=1 
gen `hs'=1
if ("`pweight'" != "") qui replace `pw' = `pweight'
if ("`hsize'"   != "") qui replace `hs' = `hsize'
if ("`group'"    != "") qui replace `hs' = `hs'*(`group'==`sg')
qui gen `fw'=`pw'*`hs'
qui svyset, clear(all)
qui svyset [pweight=`pw']
if ("`strata'" != "") qui svyset [pweight=`pw'], strata(strata)
if ("`psu'"!="")      qui svyset [pweight=`pw'], strata(strata) psu(`psu')
cap drop lb ub
gen lb=0
gen ub=0
sort `1'
qui drop if (`1'<`intmin')
qui drop if (`1'>`intmax')
qui sgini `fw' `1'

global gx=`r(gini)'

qui sgini `fw' `2'
global gn=`r(gini)'

qui sum `1' [aw=`fw']
local tem1 = `r(mean)'
tempvar tax
gen `tax' = `1' - `2'

qui sum `tax' [aw=`fw']
local tem2 = `r(mean)'
global g = `tem2'/`tem1'

sconc `fw' `tax' `1'
global ct=`r(conc)'


//dis "Concentration index = " $ct



gen group = `3'
global nc=floor((`intmax'-`intmin')/`step')
qui count
if (`r(N)'<$nc) set obs $nc
qui count
forvalues i=1/$nc {
	qui replace lb =`intmin'+`step'*(`i'-1) in `i'
        qui replace ub =`intmin'+`step'*(`i')   in `i'
     
}

tempvar tem mung wincn ww

gen  `wincn' =`fw'*`2'
egen `tem'   = mean(`wincn'), by(group)
egen `ww'    = mean(`fw')   , by(group)
gen  `mung'  = `tem'/`ww'
sgini `fw' `mung'
global g0=`r(gini)'



cap drop gax 
gen gax=0
qui gen propop=0
qui gen proinc=0
forvalues i=1/$nc {
sgini `fw' `2' group `i'
qui replace gax=`r(gini)' in `i'
qui replace propop=`r(propop)' in `i'
qui replace proinc=`r(proinc)' in `i'
}
qui gen alx=propop*proinc
if ("`detail'"=="yes") list group lb ub gax propop proinc alx `1' `2'  in 1/$nc
// qui keep in 1/$nc
qui gen gal=gax*alx
qui sum gal
global RE =($gx-$gn)
global H  = `r(sum)'
global V  = $gx-$g0
global R  = $RE - $V + $H 
global K_T = $ct-$gx
global V_chk = $g/(1-$g)*$K_T

return scalar res1 =  $gx           
return scalar res2 =  $gn           
return scalar res3 =  $RE           
return scalar res4 =  $g0           
return scalar res5 =  $H            
return scalar res6 =  $V            
return scalar res7 =  $R           
return scalar res8 =  $g            
return scalar res9 =  $K_T          
return scalar res10 =  $V_chk  
restore
end 
