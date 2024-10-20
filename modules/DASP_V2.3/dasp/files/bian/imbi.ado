
// Programmed by Araar Abdelkrim (04-2010)
// Estimating the MBI with the nonlinear parametric regression
// Approach: Ajwad and Quentin (2007)

#delim ;
capture program drop imbi;
program define imbi, eclass;
version 9.2;
preserve;
set more off;
syntax varlist(min=2 max=2)[, 
HRegion(varname) 
WELfare(varname)  
APPR(string) 
dec(int 6) 

BAND(real 0.1) 
MIN(real 0) 
MAX(real 1)

drr(int 1) ];


qui tab `hregion';
local nreg = `r(r)';
tokenize `varlist';

tempvar sw;
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear;
qui gen `sw'=1;
if ("`hweight'"~="")       qui replace `sw'=`sw'*`hweight';

cap drop quin;
gen quin=0;
forvalues r=1/`nreg' {;
cap drop hs; 
cap drop qt;
gen hs=(`hregion' == `r');
/*qui quinsh `welfare', vname(qt) partition(5) hsize(hs); */
xtile qt = `welfare' [aweight = hs*`sw']   if `hregion' == `r' , nquantiles(5);
qui replace quin = qt if `hregion' == `r';
*dis `r' ;
};
cap label drop lequin;
label define lequin  
1 "Quintile_1" 
2 "Quintile_2" 
3 "Quintile_3" 
4 "Quintile_4" 
5 "Quintile_5"
;
label val quin lequin;

if ("`appr'"=="aq") {;
cap drop avr_`hregion'_q;
gen avr_`hregion'_q=0;
cap drop _ww;
gen _ww=0;
forvalues j=1/5 {;
cap drop avr_`hregion'_l`j';
gen  avr_`hregion'_l`j'=0;
cap drop alpha`j';
gen alpha`j'=0;
local b = (`j'-1)*`nreg'+1;
local e = `j'*`nreg';
local p = (`j'-1)*`nreg';
qui replace alpha`j'=1 in `b'/`e';
forvalues i=1/`nreg' {;
local pos = `p'+`i';
qui sum `1' [aw=`sw'] if `hregion'==`i' & quin==`j';
local a = `r(mean)';
qui sum `2' [aw=`sw'] if `hregion'==`i' & quin==`j';
local b = `r(mean)';
qui replace avr_`hregion'_q=`a'/`b' in `pos';
qui sum `1' [aw=`sw'] if `hregion'==`i' & quin!=`j';
local a = `r(mean)';
qui sum `2' [aw=`sw'] if `hregion'==`i' & quin!=`j';
local b = `r(mean)';
qui replace avr_`hregion'_l`j'=`a'/`b' in `pos';
qui sum `sw' if `hregion'==`i' & quin==`j';
qui replace _ww=`r(sum)' in `pos';
};

};

local dr;
if (`drr'==0) local dr = "qui";

local kp = 5*`nreg';
qui keep in 1/`kp';



`dr' regress  avr_`hregion'_q  alpha1 alpha2 alpha3 alpha4 alpha5
avr_`hregion'_l1 avr_`hregion'_l2 avr_`hregion'_l3 avr_`hregion'_l4 avr_`hregion'_l5 [aw=_ww], nocons
;

`dr' nl (avr_`hregion'_q = 
{a1}*alpha1+{a2}*alpha2+{a3}*alpha3+{a4}*alpha4+{a5}*alpha5+        
{b1}*avr_`hregion'_l1 +{b2}*avr_`hregion'_l2+{b3}*avr_`hregion'_l3+{b4}*avr_`hregion'_l4
+ 
(

( 4*(  1 - {b1}/(4+{b1}) -{b2}/(4+{b2}) -{b3}/(4+{b3}) -{b4}/(4+{b4})  ) )
/
( {b1}/(4+{b1})+{b2}/(4+{b2})+{b3}/(4+{b3})+{b4}/(4+{b4}) )
)*avr_`hregion'_l5
 
) [aw=_ww], 
initial(a1 _b[alpha1] a2 _b[alpha2] a3 _b[alpha3]  a4 _b[alpha4] a5 _b[alpha5] 
b1 _b[avr_`hregion'_l1] b2 _b[avr_`hregion'_l2]  b3 _b[avr_`hregion'_l3]  b4 _b[avr_`hregion'_l4]
 );
 
 
 cap matrix drop aa;
 matrix aa = e(b);
 local temp = 0;
 forvalues i=1/4 {;
 local j = `i'+5;
 local b`i' = el(aa,1,`j');
 local temp = `temp' + `b`i''/(4+`b`i'');
 };
 
local b5 = 4*(1-`temp')/`temp';

cap drop marginBen;
qui gen marginBen = 0;

cap drop alpha;
qui gen alpha = 0;

cap drop beta;
qui gen beta = 0;

cap drop Group;
qui gen Group = "";
 forvalues i=1/5 {;
 qui replace Group = "Quantile_`i'" in `i';
 qui replace alpha = el(aa,1,`i') in `i';
 qui replace beta = `b`i'' in `i';
 qui replace marginBen = 5*`b`i''/(4+`b`i'') in `i';
 };
 
 disp in green "{hline 70}";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight    :  `hweight'";
       if ("`hregion'"!="")  di as text     "{col 5}Regional variable  :  `hregion'";
	   if ("`hregion'"!="")  di as text     "{col 5}Number of regions  :  `nreg'";
disp in green "{hline 70}";

dis "Marginal Benefit Incidence"; 
dis  "Estimated with the Ajwad & Quentin approach";
tabdis Group in 1/5, cellvar(alpha beta marginBen) concise format(%16.6f) cellwidth(16);



local est = "(";
forvalues i=1/5{;
local tem1=marginBen[`i'];
 if (`i'!=5) local est = "`est'"+ "`tem1'\";
 if (`i'==5) local est = "`est'"+ "`tem1')";
};
tempname ES;
matrix define `ES'=`est';
ereturn matrix mbi = `ES';
};

if ("`appr'"=="dlle") {;

tempvar u_sta  e_sta ;
gen `u_sta' =  `sw'*`1';
gen `e_sta' =  `sw'*`2';

qui sum `u_sta' ;
local s1=r(sum);
qui sum `e_sta' ;
local s2=r(sum);

local ave_rate = `s1'/`s2';

tempvar s1 s2;
by `hregion', sort : egen float `s1' = sum(`u_sta') ;
by `hregion', sort : egen float `s2' = sum(`e_sta') ;

tempvar av_pr_regi;
gen    `av_pr_regi' = `s1'/`s2';

cap drop `s1' `s2';
tempvar s1 s2;
by `hregion' quin, sort : egen float `s1' = sum(`u_sta');
by `hregion' quin, sort : egen float `s2' = sum(`e_sta');

tempvar av_pr_regi_quin;
gen    `av_pr_regi_quin' = `s1'/`s2';


cnpe `av_pr_regi_quin', xvar(`av_pr_regi') hgroup(quin) type(dnp) 
min(`min') max(`max')  band(`band')
xline(`ave_rate')
yline(1)
title("Marginal benefit incidence:")
subtitle("Quintiles are defined at regional level")
xtitle("Average Benefit")
ytitle("MBI")
;
};

end;

 
