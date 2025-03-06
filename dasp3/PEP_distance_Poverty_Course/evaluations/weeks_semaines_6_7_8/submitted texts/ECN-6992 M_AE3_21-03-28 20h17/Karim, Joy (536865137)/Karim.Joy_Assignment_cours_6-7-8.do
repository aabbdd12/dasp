*****12.5%

set more off 
//Exercise 1//
//Q1.1
/*Inserting the data*/
use "C:\Users\Joy\Downloads\data_b3_3.dta",clear

/* To use the Individual as the unit of analysis  we multiply household weight by household size and initialise analysis with the individual weight*/
gen fweight = sweight*hsize
svyset psu [pweight=fweight], strata(strata) vce(linearized) singleunit(missing)

/* using nonparametric regresssion to predict the minimum well-being*/

cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)                      ///
legend(order( 1 " Observed well-being" 2 "Perceived  minimum  well-being"))  ///
subtitle("") title(The subjective poverty line)            ///
 xtitle(Observed well-being)                       /// 
 ytitle(Predicted level of the perceived  minimum  well-being )              ///
 vgen(yes)
 
/* 
Estimating the level of ae_exp when the difference between the predicted minimum well-being and the observed well-being is nil. 
*/
cap drop dif
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) xval(0) vgen(yes)

/*
Showing the subjective poverty line
*/
cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)                      ///
legend(order( 1 "Observed well-being " 2 "Perceived  minimum  well-being"))  ///
subtitle("") title(The subjective poverty line)            ///
xline(22828.025391) xtitle(Observed well-being)            /// 
ytitle(Predicted level of the perceived  minimum  well-being ) 

//Q1.2
/*Estimating the poverty gap (using the variables: ae_exp and hsize) for each of the three cases, and then discuss the results
*/
ifgt ae_exp, alpha(1) hsize(hsize) pline(22828.025391)
ifgt ae_exp, alpha(1) hsize(hsize) pline(20900)
ifgt ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)

//Q1.3
/* Please refer to the word document*/

//Exercise 2
//Q 2.1
/* Decomposing povert*/
dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20900)

// Q2.2
/* Estimating the total poverty (head count) according to region of household head*/

dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(20900)

// Q 2.3
/*The distribution of the adult equivalent expenditures is similar to that of the initial period (ae_exp), with the following slight differences
*/

gen ae_exp2= ae_exp*0.94 if region==2
replace ae_exp2= ae_exp*1.11 if region==3
replace ae_exp2= ae_exp if ae_exp2==.

//Q 2.4 
/*Decomposing the poverty gap change into growth and redistribution using Shapley approach
*/
dfgtgr ae_exp ae_exp2, alpha(1) pline(20900)

//Q 2.5
/*Perform a sectoral decomposition (based on region groups) of the change in total poverty gap
*/

dfgtg ae_exp2, hgroup(region) hsize(hsize) alpha(1) pline(20900)
dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(1) pline(20900)

//Excerise 3
clear
input Identifier	weight	inc_t1	Inc_t2
0	0	0.00	0.00
1	0.1	1.50	1.54
2	0.1	4.50	3.85
3	0.1	7.50	6.60
4	0.1	3.00	2.75
5	0.1	4.50	4.40
6	0.1	9.00	7.70
7	0.1	10.50	8.80
end
//Q 3.1 

/*generating the percentiles (based on the rank of incomes of the initial period (variable perc)), and the first percentile must be equal to zero).
*/
sort inc_t1
gen perc=sum(weight)
list perc

//Q3.2
/*Initialize the scalar g_mean, which is equal to the growth rate in the average income
*/

qui sum inc_t1 [aw=weight]   			
scalar mean1=r(mean)         			
qui sum Inc_t2 [aw=weight]
scalar mean2=r(mean)         			
scalar g_mean = (mean2-mean1)/mean1
gen g_mean  = (mean2-mean1)/mean1    	 
dis "Mean 1              =" mean1
dis "Mean 2             = " mean2
dis "Growth in averages = " g_mean

// Q 3.3 
/*Generate the variable g_inc, as the growth in individual incomes.
*/

gen g_inc =(Inc_t2-inc_t1)/inc_t1 		
replace g_inc = 0 in 1             		

// Q 3.4
/*Drawing the Growth Incidence Curve using the variables g_inc and perc. Discuss the results
*/

line g_inc g_mean perc, ///
title(Growth Incidence Curve) ///
yline(`g_mean') ///
legend(order( 1 "GIC curve" 2 "Growth in average income")) ///
xtitle(Percentiles (p)) ytitle(Growth in incomes)  ///
plotregion(margin(zero))

// Q 3.5
/*. Estimate the Chen and Ravallion (2003) pro-poor index
*/
drop in 1
sum g_inc [aw=weight] if (inc_t1<10.4) 	
dis = r(mean)
ipropoor inc_t1 Inc_t2, pline(10.4)   	

// Q 3.6
/*decomposing the change in the poverty gap*/

dfgtgr inc_t1 Inc_t2, alpha(1) pline(10.4)




