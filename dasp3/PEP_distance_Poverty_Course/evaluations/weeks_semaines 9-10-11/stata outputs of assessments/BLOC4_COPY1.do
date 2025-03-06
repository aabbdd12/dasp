
// EXERCICE 1

// Q1

clear
input w_1 w_2 w_3
1 5 3
2 3 0
4 4 6
3 3 4
7 5 4
6 4 3
end

gen poor_union = (w_1<3.5) | (w_2<3.5) | (w_3<3.5)
mean  poor_union 
imdp_uhi w_1 w_2 w_3, pl1(3.5) pl2(3.5) pl3(3.5)
// Q2
gen poor_inter = (w_1<3.5) & (w_2<3.5) & (w_3<3.5)
mean  poor_inter
imdp_ihi w_1 w_2 w_3, pl1(3.5) pl2(3.5) pl3(3.5)

// Q3 
/* 
The intersection headcount index is more sensitive, since we count only those with full multiple deprivation.
*/

// Q4

gen dep_1 = (w_1<3.5) 
gen dep_2 = (w_2<3.5) 
gen dep_3 = (w_3<3.5) 
egen sum_dep          =  rowtotal(dep_*) 
gen    af_poor        =  (sum_dep>=2)
gen  w_af_poor        =  (sum_dep /3)* af_poor

/* Alkire and Foster H0 and M0 */
mean af_poor w_af_poor


// Q5
imdp_afi w_1 w_2 w_3, dcut(2) w1(1) pl1(3.5) w2(1) pl2(3.5) w3(1) pl3(3.5)


// Q6

gen poor_union_targ1 = (w_1+1<3.5) | (w_2<3.5)   | (w_3<3.5)
gen poor_union_targ2 = (w_1<3.5)   | (w_2+1<3.5) | (w_3<3.5)
gen poor_union_targ3 = (w_1<3.5)   | (w_2<3.5)   | (w_3+1<3.5)

gen poor_inter_targ1 = (w_1+1<3.5) & (w_2<3.5)   & (w_3<3.5)
gen poor_inter_targ2 = (w_1<3.5)   & (w_2+1<3.5) & (w_3<3.5)
gen poor_inter_targ3 = (w_1<3.5)   & (w_2<3.5)   & (w_3+1<3.5)

mean  poor_union* 
mean  poor_inter* 

/* With the union approach, we focus on less deprived individuals  (the case of individual number 6, the only deprived in dimension 3) */
/* With the intersection approach, we focus on most deprived individuals (the case of individual number 3, and we target dimension 2) */



// EXERCICE 2

// Q1

clear
input w_1 w_2 w_3
1 5 3
2 3 0
4 4 6
3 3 4
7 5 4
6 4 3
end

cap drop ngap*
gen ngap1 = (3.5-w_1)/3.5*(3.5>w_1)
gen ngap2 = (3.5-w_2)/3.5*(3.5>w_2)
gen ngap3 = (3.5-w_3)/3.5*(3.5>w_3)
gen pi = ( (1/3)*ngap1^1 + (1/3)*ngap2^1 + (1/3)*ngap3^1 )^(1/1)
if ngap1==0 & ngap2==0 & ngap3==0  replace pi=0
qui sum pi 
scalar BC_0 = `r(mean)'
dis  "The B&C index = " %6.3f BC_0


// Q2
imdp_bci w_1 w_2 w_3, alpha(1) gamma(1) b1(0.3333333) pl1(3.5) b2(0.3333333) pl2(3.5) b3(0.3333333) pl3(3.5)

// Q3
 gen nw_1 = (w_1+ w_2+w_3)/3
 gen nw_2 = (w_1+ w_2+w_3)/3
 gen nw_3 = (w_1+ w_2+w_3)/3
 imdp_bci nw_1 nw_2 nw_3, alpha(1) gamma(1) b1(0.3333333) pl1(3.5) b2(0.3333333) pl2(3.5) b3(0.3333333) pl3(3.5)
 /*
 The BC index decreases because the expenditure share of each dimension of each individual (1/3) 
 matches with the normative imposed expenditure shares (the parameter beta = 1/3).
 Thus, the generated utility is high and gap is low.
 */
 
***additional questions (not included in the exam)
// Q4
gen b1=w_1/(w_1+w_2+w_3)
gen b2=w_2/(w_1+w_2+w_3)
gen b3=w_3/(w_1+w_2+w_3)

replace pi = ( b1*ngap1^1 + b2*ngap2^1 + b3*ngap3^1 )^(1/1)
qui sum pi 
scalar BC_0 = `r(mean)'
dis  "The B&C index = " %6.3f BC_0
/*
 The BC index decreases because now the beta parameters of each individual matches with their observed expenditure shares
 and this optimizes the utility. 
*/

// Q5
/*
In this context, it is rational to impose the normative beta parameters, especially when the dimensions of well-being
are the usual public services (education, health, etc), and where some households are deprived from these services.
*/

// Q6

cap drop tngap*
gen tngap1 = (3.5-(w_1+1))/3.5*(3.5>(w_1+1))
gen tngap2 = (3.5-(w_2+1))/3.5*(3.5>(w_2+1))
gen tngap3 = (3.5-(w_3+1))/3.5*(3.5>(w_3+1))

gen pi1 = ( (1/3)*tngap1^1 + (1/3)* ngap2^1 + (1/3)* ngap3^1 )^(2/1)
gen pi2 = ( (1/3)* ngap1^1 + (1/3)*tngap2^1 + (1/3)* ngap3^1 )^(2/1)
gen pi3 = ( (1/3)* ngap1^1 + (1/3)* ngap2^1 + (1/3)*tngap3^1 )^(2/1)

if tngap1==0 &  ngap2==0 &  ngap3==0  replace pi1=0
if  ngap1==0 & tngap2==0 &  ngap3==0  replace pi2=0
if  ngap1==0 &  ngap2==0 & tngap3==0  replace pi3=0

qui sum pi1 
scalar BC_1 = `r(mean)'
qui sum pi2 
scalar BC_2 = `r(mean)'
qui sum pi3 
scalar BC_3 = `r(mean)'
dis  "The B&C index (targ_dim_1) = " %6.3f BC_1
dis  "The B&C index (targ_dim_2) = " %6.3f BC_2
dis  "The B&C index (targ_dim_3) = " %6.3f BC_3

/*
Targeting the dimension 1 is the policy which reduces the most of the MD poverty.
This is also conform with the data and where the extent of deprivations are high for the first dimension.
*/


// EXERCICE 3

// Q1
use "C:\Users\abara\Desktop\exercises_10&11_\Canada_Incomes&Taxes_1996_2005_random_sample_1.dta", replace


preserve
keep if year==2005
#delimit ;
cnpe T B N, xvar(X) hsize(hhsize) type(dnp) min(1000) max(31000)
title(Marginal rates of taxes and benefits)
subtitle(Canada 2005)
xtitle(Gross income)
ytitle(Estimated marginal rates)
;
#delimit cr
restore

// Q2
preserve
keep if year==1999 
digini X N,  hs(hhsize)
restore

preserve
keep if year==2002 
digini X N,  hs(hhsize)
restore

preserve
keep if year==2005 
digini X N,  hs(hhsize)
restore
/*
The results show that the fiscal system was more progressive in 2002, 
as the inequality reduction between the gross and the net income is 
larger in that year.
*/

// Q3
iprog T, ginc(X) hsize(hhsize) gobs(year) type(t) index(ka)
 
// Q4
preserve
keep if year==2005 
cprog T, rank(X) hsize(X) type(t) appr(tr)
restore

// Q5
preserve
keep if year==2005 
iprog T, ginc(X) hsize(hhsize) gobs(province) type(t) index(ka)
igini X,  hs(hhsize) hg(province)
restore

/* 
The highest inequality in Gross incomes in 2005 was in  Newfoundland.
The highest progressivity in Taxes in 2005 was in British_Columbia.
*/

***additional questions (not included in the exam)

// Q6
/*
i)  FALSE:  In the example below, the two poorer persons have a share of paid taxes of (5/20) and a lower share of gross income of (30/140). 
*/
clear
set obs 5
input X T
10 2 
20 3 
30 4 
40 5 
50 6 
list
iprog T , ginc(X)

/*
ii) FALSE:  An increasing tax rate is a sufficient condition of the tax progressivity. 
*/
clear
set obs 5
input X tax_rate
10 0.12
20 0.14
30 0.16
40 0.18
50 0.20
list
gen T2 = X*tax_rate
iprog  T , ginc(X)

/*
iii) TRUE: The progressivity indices are sensitive the distribution of incomes. 
           The lower is the inequality, the lower is the progressivity index.
     See the example below:
*/
clear
set obs 6
input X1 X2 tax_rate1  tax_rate2
10 20 0.12 0.14
20 20 0.14 0.14
30 20 0.16 0.14
30 40 0.18 0.20
40 40 0.20 0.20
60 40 0.22 0.20

list
gen T1 = X1*tax_rate1
gen T2 = X2*tax_rate2
iprog T1 , ginc(X1)
iprog T2 , ginc(X2)




