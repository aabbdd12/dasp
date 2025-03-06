***********12%

************************************************
* Assignment course 9 10 11 for Tony M. Kamninga
************************************************
**Exercise 1.......4%

//Question 1.1
clear

input Individual w_1	w_2	w_3
1 	2	10	6
2	4	6	0
3	8	8	12
4 	6	6	8
5	14	10	4
6 	12	8	6
end


imdp_uhi w_1 w_1 w_3, pl1(7) pl2(7) pl3(7) /*Union Approach*/
ifgt w_1 w_2 w_3, alpha(0) pline(7)

//Question 1.2
imdp_ihi w_1 w_2 w_3, pl1(7) pl2(7) pl3(7) /*Intersection approach*/
ifgt w_1 w_2 w_3, alpha(0) pline(7)

//Question 1.3

/*Comment: The Union Approach*/
// Qiestion 1.4
egen sum_w    =  rowtotal(w_*) 
gen  af_poor  =  (sum_w>=2) // Alkire and Foster H0 :  the dual cut-off is equal to 2.
gen  w_af_poor =  (sum_w /6)* af_poor // Alkire and Foster M0 
/* Alkire and Foster H0 and M0 */
mean af_poor w_af_poor


//Question 1.5
imdp_afi w_1 w_2 w_3, dcut(2) w1(1) pl1(7) w2(1) pl2(7) w3(1) pl3(7) /*Alkire and Foster index*/

// Question 1.6

gen w_1_1=( w_1+2) /*add 2 by getting an equal distribution across six indivuduals*/
gen w_2_1=( w_2+2)
gen w_3_1=( w_3+2)

imdp_uhi w_1_1 w_2_1 w_3_1 , pl1(7) pl2(7) pl3(7)
imdp_ihi w_1_1 w_2_1 w_3_1 , pl1(7) pl2(7) pl3(7) /*we observe that intesection index is zero-completely reduced */

imdp_uhi w_1_1 , pl1(7) pl2(7) pl3(7)
imdp_uhi w_2_1 , pl1(7) pl2(7) pl3(7)
imdp_uhi w_3_1 , pl1(7) pl2(7) pl3(7)
imdp_ihi w_1_1 , pl1(7) pl2(7) pl3(7)
imdp_ihi w_2_1 , pl1(7) pl2(7) pl3(7)
imdp_ihi w_3_1 , pl1(7) pl2(7) pl3(7)

/*We seee that the largest contributor is distribution 2. No poor person with the new transfer*/



****Exercise 2**4%


// Question 2.1

clear

input Individual w_1	w_2	w_3
1 	2	10	6
2	4	6	0
3	8	8	12
4 	6	6	8
5	14	10	4
6 	12	8	6
end



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

/*

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
          pi |          6    .1823572    .1936261          0   .5232857

*/
//Question 2.2
imdp_bci w_1 w_2 w_3, alpha(1) gamma(1) b1(0.333) pl1(7) b2(0.333) pl2(7) b3(0.333) pl3(7)

/* imdp_bci w_1 w_2 w_3, alpha(1) gamma(1) b1(0.333) pl1(7) b2(0.333) pl2(7) b3(0.333) pl3(7)

    M.D. Poverty index :  Bourguignon and Chakravarty (2003)             
-----------------------------------------------------------------------------+
            |       Estimate            STE             LB              UB   |
------------+----------------------------------------------------------------|
Population  |           0.182           0.079           0.023           0.342|
-----------------------------------------------------------------------------+

*/

// Question 2.3
gen nw_1 = ((w_1+ w_2+w_3)/3) 
gen nw_2 = ((w_1+ w_2+ (w_3*0.75))/3)
gen nw_3 = ((w_1*0.5) + (w_2*0.75)+ (w_3))/3

/*
imdp_bci nw_1 nw_2 nw_3, alpha(1) gamma(.1823572) b1(0.333) pl1(7) b2(0.333) pl2(7) b3(0.333) pl3(7)

    M.D. Poverty index :  Bourguignon and Chakravarty (2003)             
-----------------------------------------------------------------------------+
            |       Estimate            STE             LB              UB   |
------------+----------------------------------------------------------------|
Population  |           0.304           0.137           0.028           0.579|
-----------------------------------------------------------------------------+

With the same parameters held constant, we are experiencing that the poverty index increases

*/




***Exercise Three****4%

//Question 3.1
use Canada_Incomes&Taxes_1996_2005_random_sample_2.dta, clear
preserve 

keep if year==2005
cnpe T B N, xvar(X) min(1000) max(31000) type(dnp)

/* Comment: With respect to levels of gross incomes, the change on net incomes and benefits all increase at a decreasing rate and tend to flatten in a similar way. Marginal Taxes tend to increase much slower. At lower rates of gross incomes 130000 and below, marginal benefits grow at a higher rates compares to net incomes. This implies that individuals in a lower income bracket benefit more . */

//Question 3.2 
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

/*Comment: The difference between two Gini indices of two given distributions (X,N) is also called the redistribution effect on inequality and this can be expressed as a difference between two main components:  Gini_X-Gini_N  = VE- HI. We observe that over times the difference has been declining from  0.15134358 in 1999 to  0.14404753 in 2002 to 0.1349144 in 2005. That over time there has been a progressive redistribution*/

restore
//Question 3.3

iprog T , ginc(X) hsize(hhsize) gobs(year) type(t) index(ka) /*The Kekwani Tax index ranges from -1 to 1. We see that the index for all the years is greater than 0, thus we conclude that the tax system is progressive in this country. We also observe that the for apart from the year 1996 amnd 1997, there is a general rise in the in the Kekwani index, thus as years progress, the tax system becomes more progressive sinec the higher the Kakwani index, the more progressive the tax system */
iprog T , ginc(X) hsize(hhsize) type(t) index(ka) /* This command shows the general Kakwani for all the years which provide similar results to the the one found by the command below*/
igini X T B N , rank(X)
dis "Kakwani index of Tax T:    " el(e(est),2,1)-el(e(est),1,1)
preserve
//Questio 3.4

keep if year==2005

cprog T, rank(X) hsize(hhsize) hgroup(year) type(t) appr(tr)
/*We see that indeed this tax regime is progressive as tax T is Tax Redistribution (TR) progressive if : CPROG (p) = L_X(p) - C_T(p) > 0 for all p in ]0,1[. In some words, the condition is that the share of incomes until a give p-percentile group (p-poorer group.*/

//Question 3.5 

**a)
igini X, hsize(hhsize) hgroup(province)
igini X, rank(X) hsize(hhsize) hgroup(province)

/*All these commands provide the same results. Remember when we include the rank variable, what is computed is the concentration curve. We observe that Newfoundland has the highest (0.475471)  gross inequality index*/

**b)
iprog T , ginc(X) hsize(hhsize) gobs( province ) type(t) index(ka) 
/*We see that in Province British_Columbia, the Kakwani tax progressive index was highest (0.145633) compared to any other province   */
