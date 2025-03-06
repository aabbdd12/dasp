********************************10,5%
clear
input Individual w_1	w_2	w_3
1 	4	20	12
2	8	12	0
3	16	16	24
4 	12	12	16
5	28	20	8
6 	24	16	12
end

//Question 1.1 Estimating the proportion of poor Individuals

/*Using union Approach*/
imdp_uhi w_1 w_1 w_3, pl1(7) pl2(7) pl3(7)

/*Using DASP Approach*/
ifgt w_1 w_2 w_3, alpha(0) pline(7)

//Question 1.2 Estimating the proportion of poor Individuals

/*Using intersection approach*/
imdp_ihi w_1 w_2 w_3, pl1(7) pl2(7) pl3(7)

/*Using DASP Approach*/ 
ifgt w_1 w_2 w_3, alpha(0) pline(7)

//Question 1.3 The approach that is more sensitive to the increase in individual multiple deprivations?
/*See word Document*/

// Qiestion 1.4	Estimating the Alkire and Foster (2007) index 

egen sum_w    =  rowtotal(w_*) 
gen  af_poor  =  (sum_w>=2) 
gen  w_af_poor =  (sum_w /6)* af_poor 
mean af_poor w_af_poor


//Question 1.5 estimating the indices using the appropriate DASP command
imdp_afi w_1 w_2 w_3, dcut(2) w1(1) pl1(7) w2(1) pl2(7) w3(1) pl3(7) 

// Question 1.6 Checking which targeted dimension would most reduce the union index, and the intersection index

gen w_1_1=( w_1+4) 
gen w_2_1=( w_2+4)
gen w_3_1=( w_3+4)

imdp_uhi w_1_1 w_2_1 w_3_1 , pl1(7) pl2(7) pl3(7)
imdp_ihi w_1_1 w_2_1 w_3_1 , pl1(7) pl2(7) pl3(7) 

imdp_uhi w_1_1 , pl1(7) pl2(7) pl3(7)
imdp_uhi w_2_1 , pl1(7) pl2(7) pl3(7)
imdp_uhi w_3_1 , pl1(7) pl2(7) pl3(7)
imdp_ihi w_1_1 , pl1(7) pl2(7) pl3(7)
imdp_ihi w_2_1 , pl1(7) pl2(7) pl3(7)
imdp_ihi w_3_1 , pl1(7) pl2(7) pl3(7)

**Exercise 2**
clear
input Individual w_1	w_2	w_3
1 	4	20	12
2	8	12	0
3	16	16	24
4 	12	12	16
5	28	20	8
6 	24	16	12
end

// Question 2.1	Estimating the Bourguignon and Chakravarty (2003) poverty index 

scalar beta1 = 0.333
scalar beta2 = 0.333
scalar beta3 = 0.333

scalar z=7
scalar alpha=1
scalar rho=1

gen ngap1 = (z-w_1)/z*(z>w_1)
gen ngap2=  (z-w_2)/z*(z>w_2)
gen ngap3=  (z-w_3)/z*(z>w_3)


gen pi = (beta1*ngap1^rho + (beta2)*ngap2^rho + (beta3)*ngap3^rho)^(alpha/rho)

if ngap1==0 & ngap2==0 & ngap2==0 replace pi=0
sum pi 
scalar MDI_BC = r(mean) in 1/6
dis "The MDI_BC Index (alpha ="%4.2f alpha ", epsilon ="%4.2f rho " ) :  " _col(40) %6.4f  MDI_BC  "


//Question 2.2 Redoing  the estimation using the appropriate DASP command.

imdp_bci w_1 w_2 w_3, alpha(1) gamma(1) b1(0.333) pl1(7) b2(0.333) pl2(7) b3(0.333) pl3(7)



***Exercise Three

//Question 3.1 estimating the expected marginal tax, benefit and net income rates
use "C:\Users\Joy\Downloads\Canada_Incomes&Taxes_1996_2005_random_sample_3.dta", clear
preserve 
keep if year==2005
cnpe T B N, xvar(X) min(1000) max(31000) type(dnp)

//Question 3.2 	Estimating the redistributive impact on the Gini inequality index for the years of 1999, 2002 and 2005 
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

//Question 3.3 	Estimating the Kakwani progressivity index 

restore
iprog T , ginc(X) hsize(hhsize) gobs(year) type(t) index(ka) 
iprog T , ginc(X) hsize(hhsize) type(t) index(ka) 
igini X T B N , rank(X)
dis "Kakwani index of Tax T:    " el(e(est),2,1)-el(e(est),1,1)
preserve

//Questio 3.4 checking the TR progressivity condition for the tax T 

keep if year==2005

cprog T, rank(X) hsize(hhsize) hgroup(year) type(t) appr(tr)


//Question 3.5 Checking in which province was inequality the highest in 2005
/*Option A*/
igini X, hsize(hhsize) hgroup(province)
igini X, rank(X) hsize(hhsize) hgroup(province)

/*Option B*/

iprog T , ginc(X) hsize(hhsize) gobs( province ) type(t) index(ka) 
