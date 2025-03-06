**********9,5%

*Exercise 3*
*question 3.1*
use "C:\Users\DHN1\Downloads\Canada_Incomes&Taxes_1996_2005_random_sample_3.dta",clear
preserve
keep if year==2005
cnpe T B N, xvar(X) min(1000) max(31000) type(dnp)

*question 3.2*
restore
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

*question 3.3*
iprog T , ginc(X) hsize(hhsize) gobs(year) type(t) index(ka)
iprog T , ginc(X) hsize(hhsize) type(t) index(ka)
igini X T B N , rank(X)
dis "Kakwani index of Tax T:    " el(e(est),2,1)-el(e(est),1,1)
preserve

*question 3.4*
keep if year==2005

*QUESTION 3.5*
iprog T , ginc(X) hsize(hhsize) gobs( province ) type(t) index(ka)
igini X, hsize(hhsize) hgroup(province)
igini X, rank(X) hsize(hhsize) hgroup(province)
iprog T , ginc(X) hsize(hhsize) gobs( province ) type(t) index(ka)

*EXCERCISE  2*
clear
input individual w_1 w_2 w_3
1 4 20 12
2 8 12 0
3 16 16 24
4 12 12 16
5 28 20 8
6 24 16 12
end

*question 2.1*
scalar beta1=0.333
scalar beta2=0.333
scalar beta3=0.333
scalar z=14
scalar alpha=1
scalar rho=1
gen ngap1 = (z-w_1)/z*(z>w_1)
gen ngap2=  (z-w_2)/z*(z>w_2)
gen ngap3=  (z-w_3)/z*(z>w_3)
gen pi = (beta1*ngap1^rho + (beta2)*ngap2^rho + (beta3)*ngap3^rho)^(alpha/rho)
if ngap1==0 & ngap2==0 & ngap2==0 replace pi=0
sum pi
scalar MDI_BC = r(mean) in 1/6
dis "The MDI_BC Index (alpha ="%4.2f alpha ", epsilon ="%4.2f rho " ) :  " _col(40) %6.4f  MDI_BC

*question 2.2*
imdp_bci w_1 w_2 w_3, alpha(1) gamma(1) b1(0.333) pl1(14) b2(0.333) pl2(14) b3(0.333) pl3(14)

*question 2.3*
gen nw_1 = ((w_1+ w_2+w_3)/3)

*EXCERCISE 1*
clear
input individual w_1 w_2 w_3
1 4 20 12
2 8 12 0
3 16 16 24
4 12 12 16
5 28 20 8
6 24 16 12
end

*question 1.1*
ifgt w_1 w_2 w_3, alpha(0) pline(14)
imdp_uhi w_1 w_1 w_3, pl1(14) pl2(14) pl3(14)

*question 1.2*
imdp_ihi w_1 w_2 w_3, pl1(14) pl2(14) pl3(14)

*question 1.3*
*the intersection approach*

*question 1.4*
imdp_afi w_1 w_2 w_3, dcut(2) w1(1) pl1(14) w2(1) pl2(14) w3(1) pl3(14)

