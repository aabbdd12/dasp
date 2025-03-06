**********10%

//Stata code for Assignment weeks 9, 10 and 11
// Excercise 1*4%
clear
input ind	w1	w2	w3
1	1	5	3
2	2	3	0
3	4	4	6
4	3	3	4
5	7	5	4
6	6	4	3
end


// Q1.1
imdp_uhi w1 w2 w3, pl1(3.5) pl2(3.5) pl3(3.5)

// Q1.2
imdp_ihi w1 w2 w3, pl1(3.5) pl2(3.5) pl3(3.5)

// Q1.3

// Q1.4

// Q1.5

imdp_afi w1 w2 w3, dcut(2) w1(1) pl1(3.5) w2(1) pl2(3.5) w3(1) pl3(3.5)

// Q1.6


// Excercise 2*****3%

// Q2.1
scalar alpha = 1
scalar rho = 1
scalar beta = 1/3
scalar z=3.5

gen ngap1 = (z-w1)/z*(z>w1)  
gen ngap2 = (z-w2)/z*(z>w2)  
gen ngap3 = (z-w3)/z*(z>w3)  

cap drop pi  // try to drop the variable pi
gen pi = (beta*ngap1^rho + beta*ngap2^rho + beta*ngap3^rho)^(alpha/rho) // we generate the pi variable
if ngap1==0 & ngap2==0 & ngap3==0 replace pi=0 // If the gasps in dimensions 1, 2 and 3 are nil, then pi is equal to zero. 
qui sum pi  
scalar MDI_BC = r(mean) 

dis "The MDI_BC Index : "  =   MDI_BC 


// Q2.2
imdp_bci w1 w2 w3, alpha(1) gamma(1) b1(0.33) pl1(3.5) b2(0.33) pl2(3.5) b3(0.33) pl3(3.5)

// Q2.3
gen nw_1=(w1+ w2+w3)/3
gen nw_2=(w1+ w2+w3)/3
gen nw_3=(w1+ w2+w3)/3

imdp_bci nw_1 nw_2 nw_3, alpha(1) gamma(1) b1(0.33) pl1(3.5) b2(0.33) pl2(3.5) b3(0.33) pl3(3.5)

// Exercise 3*******3%
clear
cd "C:\Users\HP PROBOOK\Desktop\COURS PEP_LAVAL\POVERTY\Assignment Week 9, 10 and 11"

use "Canada_Incomes&Taxes_1996_2005_random_sample_1.dta", clear

//  Q3.1: 
preserve
keep if year==2005
cnpe T B N, xvar(X) min(1000) max(31000) type(dnp)
/* In general, we observe that, benefits and taxes increase with the increase of per capita gross income. As we move to higher per capita gross income, benefits increase more than taxes, resulting in a positive net income rate.  */
restore

//  Q3.2:
preserve
keep if year==1999
igini X N
local Gini_X=el(e(est),1,1)
local Gini_N=el(e(est),2,1)
igini N, rank(X)
local CONC_N=el(e(est),1,1)
dis "Difference = " `Gini_X' - `Gini_N'
dis "VE         = " `Gini_X' - `CONC_N'
dis "HI         = " `Gini_N' - `CONC_N'
restore

preserve
keep if year==2002
igini X N
local Gini_X=el(e(est),1,1)
local Gini_N=el(e(est),2,1)
igini N, rank(X)
local CONC_N=el(e(est),1,1)
dis "Difference = " `Gini_X' - `Gini_N'
dis "VE         = " `Gini_X' - `CONC_N'
dis "HI         = " `Gini_N' - `CONC_N'
restore

preserve
keep if year==2005
igini X N
local Gini_X=el(e(est),1,1)
local Gini_N=el(e(est),2,1)
igini N, rank(X)
local CONC_N=el(e(est),1,1)
dis "Difference = " `Gini_X' - `Gini_N'
dis "VE         = " `Gini_X' - `CONC_N'
dis "HI         = " `Gini_N' - `CONC_N'
restore
/*
the redistributive impact on the Gini inequality index is higher in 1999
*/

//  Q3.3:
/* Estimating the Kakwani progressivity index per year */
iprog T, ginc(X) hsize(hhsize) gobs(year) type(t) index(ka)

//  Q3.4:
preserve
keep if year==2005
cprog T, rank(X) hsize(hhsize) type(t) appr(tr)
restore

//  Q3.5:
preserve 
keep if year==2005
iprog T, ginc(X) hsize(hhsize) gobs(province) type(t) index(ka)
igini X, hsize(hhsize) hgroup(province)
restore
/* the Kakwani tax progressivity index is highest in Manitoba while inequality on gross incomes is highest in Newfoundland */





