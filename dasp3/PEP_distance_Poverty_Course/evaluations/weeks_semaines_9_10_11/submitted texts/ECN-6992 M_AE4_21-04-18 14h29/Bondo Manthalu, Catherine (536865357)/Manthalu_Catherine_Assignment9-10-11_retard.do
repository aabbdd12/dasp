**********10,5%

* Assignment 9 10 11 for Catherine Manthalu
************************************************
**Exercise 1********2%

//Q 1.1
clear

input 	Individual w_1	w_2	w_3
1 	1	5	3
2	2	3	0
3	4	4	6
4 	3	3	4
5	7	5	4
6 	6	4	3
end

imdp_uhi w_1 w_1 w_3, pl1(3.5) pl2(3.5) pl3(3.5) /*Union Approach*/
ifgt w_1 w_2 w_3, alpha(0) pline(3.5)

//Q 1.2
imdp_ihi w_1 w_2 w_3, pl1(3.5) pl2(3.5) pl3(3.5) /*Intersection approach*/
ifgt w_1 w_2 w_3, alpha(0) pline(3.5)

//Q1.3

//Q1.4
imdp_afi w_1 w_2 w_3, dcut(2) w1(1) pl1(3.5) w2(1) pl2(3.5) w3(1) pl3(3.5) /*Alkire and Foster index*/

//Q1.5

//Q1.6

****Exercise 2*******3%

// Q 2.1

clear

input Individual w_1	w_2	w_3
1 	1	5	3
2	2	3	0
3	4	4	6
4 	3	3	4
5	7	5	4
6 	6	4	3
end


scalar beta1 = 0.333
scalar beta2 = 0.333
scalar beta3 = 0.333

scalar z=3.5
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

//Q 2.2
imdp_bci w_1 w_2 w_3, alpha(1) gamma(1) b1(0.333) pl1(3.5) b2(0.333) pl2(3.5) b3(0.333) pl3(3.5)

// Q 2.3

****Exercise 3*********2.5%

//Q 3.1

use Canada_Incomes&Taxes_1996_2005_random_sample_1.dta, clear
preserve 

keep if year==2005
cnpe T B N, xvar(X) min(1000) max(31000) type(dnp)

//Q 3.2 
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

//Q 3.3

iprog T , ginc(X) hsize(hhsize) gobs(year) type(t) index(ka) 

/*The Kekwani Tax index ranges from -1 to 1. The index for all the years is greater than 0, we conclude that the tax system is progressive in this country. Apart from the year 1996 and 1997, there is a general rise in the Kekwani index, as years progress, the tax system becomes more progressive since the higher the Kakwani index, the more progressive the tax system */

iprog T , ginc(X) hsize(hhsize) type(t) index(ka) 

/* This command shows the general Kakwani for all the years which provide similar results to the one found by the command below*/
igini X T B N , rank(X)
dis "Kakwani index of Tax T:    " el(e(est),2,1)-el(e(est),1,1)
preserve

//Q 3.4
keep if year==2005
cprog T, rank(X) hsize(hhsize) hgroup(year) type(t) appr(tr)


//Q 3.5 

**a)
igini X, hsize(hhsize) hgroup(province)
igini X, rank(X) hsize(hhsize) hgroup(province)

/*All these commands provide the same results. Remember when we include the rank variable, what is computed is the concentration curve. We observe that Newfoundland has the highest (0.497669 )  gross inequality index*/

**b)
iprog T , ginc(X) hsize(hhsize) gobs( province ) type(t) index(ka) 
/*We see that in Province Manitoba, the Kakwani tax progressive index was highest (0.137435) compared to any other province   */
