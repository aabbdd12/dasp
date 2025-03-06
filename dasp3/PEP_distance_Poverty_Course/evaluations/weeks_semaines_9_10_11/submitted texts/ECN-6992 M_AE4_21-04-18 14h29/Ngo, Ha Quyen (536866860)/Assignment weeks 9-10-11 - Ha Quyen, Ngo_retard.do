***********12,5%

// WEEKS 9-10-11 ASSIGNMENT
// NGO, HA QUYEN


// EXERCISE 1 ==================================================================

// Q1.1: Union approach

clear
input id w1 w2 w3
1	4	20	12
2	8	12	0
3	16	16	24
4	12	12	16
5	28	20	8
6	24	16	12
end

gen mdp_uni = 1
replace mdp_uni = 0 if w1 > 14 & w2 > 14 & w3 > 14
sum mdp_uni

imdp_uhi w1 w2 w3, pl1(14) pl2(14) pl3(14) 

// Q1.2: Intersection approach

gen mdp_ihi = 0
replace mdp_ihi = 1 if w1 < 14 & w2 < 14 & w3 < 14
sum mdp_ihi

imdp_ihi w1 w2 w3, pl1(14) pl2(14) pl3(14) 

// Q1.3:

* Intersection approach is more sensitive to the increase in individual multiple deprivations.

* Example: 

preserve
clear
input id w1 w2 w3
1	4	20	12
2	8	12	0
3	16	16	24
4	12	12	12
5	28	20	8
6	24	16	12
end

imdp_uhi w1 w2 w3, pl1(14) pl2(14) pl3(14) 
imdp_ihi w1 w2 w3, pl1(14) pl2(14) pl3(14) 

restore

// Q1.4:

forvalues i=1/3 {
	gen del_`i' = 0 if w`i' >= 14
	replace del_`i' = 1 if w`i' < 14 
	}
	
egen sum_del = rowtotal(del_*) 
gen  af_poor = (sum_del>=2)                                                     
gen  w_af_poor = (sum_del /3)* af_poor

mean af_poor w_af_poor 
drop del_*
	
// Q1.5:

imdp_afi w1 w2 w3, dcut(2) pl1(14) pl2(14) pl3(14) 


// Q1.6:

* Targeting w1

preserve
replace w1 = w1+6
forvalues i=1/3 {
	gen del_`i' = 0 if w`i' >= 14
	replace del_`i' = 1 if w`i' < 14 
	}
imdp_uhi w1 w2 w3, pl1(14) pl2(14) pl3(14) 
imdp_ihi w1 w2 w3, pl1(14) pl2(14) pl3(14) 
restore

* Targeting w2

preserve
replace w2 = w2+6
forvalues i=1/3 {
	gen del_`i' = 0 if w`i' >= 14
	replace del_`i' = 1 if w`i' < 14 
	}
imdp_uhi w1 w2 w3, pl1(14) pl2(14) pl3(14) 
imdp_ihi w1 w2 w3, pl1(14) pl2(14) pl3(14) 
restore

* Targeting w3

preserve
replace w3 = w3+6
forvalues i=1/3 {
	gen del_`i' = 0 if w`i' >= 14
	replace del_`i' = 1 if w`i' < 14 
	}
imdp_uhi w1 w2 w3, pl1(14) pl2(14) pl3(14) 
imdp_ihi w1 w2 w3, pl1(14) pl2(14) pl3(14) 
restore

* Targeting dimension 3 would most reduce the union index since the union index counts individuals as poor even if they are deprived in one dimension. By targeting dimension 3, the government effectively helps individual 5 and individual 6 to escape poverty, who are only deprived in only one dimension pre-transfer. Other individuals are poor in multiple dimension (except for individual 3 who is non-poor) so targeting other individuals through other dimensions would not help reducing the union index.  

* On another hand, targeting dimension 1 or 2 would most reduce the intersection index. Before transfers, there is only one individual (individual 2) who is classified as poor, as she is poor in all dimensions. By targeting either dimension 1 or dimension 2, individual 2 is no longer classified as poor, thus reducing the intersection index to 0. 


// EXERCISE 2 ==================================================================


// Q2.1:

scalar beta = 1/3
scalar e = 1
scalar alpha = 1

forvalues i=1/3 {
	gen z`i' = 14
	gen ngap`i' = (z`i'-w`i')/z`i'*(z`i'>w`i')
	}
	
gen pi = (beta*ngap1^e + beta*ngap2^e + beta*ngap3^e)^(alpha/e) 
replace pi=0 if ngap1==0 & ngap2==0 & ngap3==0
sum pi
scalar MDI_BC = r(mean) 
dis MDI_BC

// Q2.2: 

imdp_bci w1 w2 w3, pl1(14) b1(0.333) pl2(14) b2(0.333) pl3(14) b3(0.333) alpha(1) beta(0.333) gamma(1)

// Q2.3:

gen nw1 = (w1+ w2+w3)/3
gen nw2 = nw1
gen nw3 = nw1
imdp_bci nw1 nw2 nw3, pl1(14) b1(0.333) pl2(14) b2(0.333) pl3(14) b3(0.333) alpha(1) beta(0.333) gamma(1)

* After equalisation, the BC index decreases because there are two individuals (5 and 6) who are better-off and are able to escape poverty. 

// EXERCISE 3 ==================================================================

use "/Users/partsofqueenie/Downloads/Canada_Incomes&Taxes_1996_2005_random_sample_3.dta", clear

// Q3.1:

cnpe T B N, xvar(X) min(1000) max(31000) type(dnp)

// Q3.2:

foreach num of numlist 1999 2002 2005 {
	preserve
	keep if year == `num'
	dis `num'
	igini X N
	local Gini_X=el(e(est),1,1)
	local Gini_N=el(e(est),2,1)
	dis "Difference = " `Gini_X' - `Gini_N'
	restore
	}

// Q3.3:

iprog T, ginc(X) gobs(year)

// Q3.4:

keep if year == 2005
cprog T, rank(X) 
* T is progressive since L-C>=0 for all percentiles.

// Q3.5: 

igini X, hgroup(province)
* In 2005, inequality (pre-tax) was highest in Newfoundland. 
iprog T, ginc(X) gobs(province)
* Alberta has the highest Kakwani tax progressivity index in 2005.


