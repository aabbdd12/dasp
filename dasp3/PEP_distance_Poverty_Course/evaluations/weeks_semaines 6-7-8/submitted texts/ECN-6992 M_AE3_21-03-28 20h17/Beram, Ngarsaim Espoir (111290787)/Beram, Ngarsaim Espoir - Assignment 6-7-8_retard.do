****************12.5%


//Stata code for Assignment weeks 6, 7 and 8
// Excercise 1**********3.5%
clear
cd "C:\Users\HP PROBOOK\Desktop\COURS PEP_LAVAL\POVERTY\Assignment Week 6, 7 and 8"
use data_b3_1.dta

// Q1.1
/* Let us use the nonparametric regression technique to predict the perceived minimum well-being */
cnpe ae_exp  min_ae_exp, xvar(ae_exp) hsize(hsize) min(0) max(60000)                      ///
legend(order( 1 "Perceived  minimum  well-being " 2 "Observed well-being"))  ///
subtitle("") title(The subjective poverty line)            ///
 xtitle(Observed well-being)                       /// 
 ytitle(Predicted level of the perceived  minimum  well-being )              ///
 vgen(yes)

/* Estimating the level of ae_exp when the difference between the predicted minimum well-being and the observed well-being is nil. */
cap drop dif
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) xval(0) hsize(hsize) vgen(yes)

/*
Showing the subjective poverty line  : Here we draw the similar two first curves, 
but in addition, we add the show the subjective poverty line with the option xline(22922.419922) 
*/
cnpe ae_exp  min_ae_exp, xvar(ae_exp) hsize(hsize) min(0) max(60000)                      ///
legend(order( 1 "Perceived  minimum  well-being " 2 "Observed well-being"))  ///
subtitle("") title(The subjective poverty line)            ///
xline(22922.419922) xtite(Observed well-being)            /// 
ytitle(Predicted level of the perceived  minimum  well-being ) 

// Q1.2
ifgt  ae_exp, alpha(1) hsize(hsize) pline(22922.42)
ifgt  ae_exp, alpha(1) hsize(hsize) pline(21000)
ifgt  ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)

// Q1.3
/*
The relative poverty line is the most appropriate method for measuring poverty in developed countries because between region inequality is most relevant than within region inequality in such countries 
*/ 



// Excercise 2***4.5%
clear
cd "C:\Users\HP PROBOOK\Desktop\COURS PEP_LAVAL\POVERTY\Assignment Week 6, 7 and 8"
use data_b3_1.dta

// Q2.1
dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(21000)
/*Based on the results above, one can say:
 1- The proportion of population of male-headed households is 77.47%, while female-headed households is 22.53 %.
 2- The total headcount poverty is equal to 35%. Male group contributes by  25.95 and the female group by 9.05 (25.95 + 9.05 = 35%). 
Likewise, in relative term, the contribution (to total poverty) of poverty among households headed by women is greater than the contribution that comes from their representativeness in the total population (0.741 VS 0.259).*/

// Q2.2
dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(21000)

// Q2.3
gen ae_exp2=ae_exp
replace ae_exp2=ae_exp*0.1 if region==3
replace ae_exp2=ae_exp*0.06 if region==2

// Q2.4
dfgtgr ae_exp ae_exp2, alpha(1) pline(21000)
/* Poverty gap increases between the two periods as a consequence of the increase in both growth and inequality*/

// Q2.5



// Exercise 3****4.5%
//  Q3.1:
clear
input identifier	weight	inc_t1	inc_t2
0	0.0	0	0
1	0.1	1.50	1.54
2	0.1	4.50	3.85
3	0.1	7.50	6.60
4	0.1	3.00	2.75
5	0.1	4.50	4.40
6	0.1	9.00	7.70
7	0.1	10.50	8.80
8	0.1	15.00	7.70
9	0.1	12.00	6.60
10	0.1	13.50	6.60
end

sort inc_t1
gen perc=sum(weight)

//  Q3.2:
qui sum inc_t1 [aw=weight]
scalar mean1=r(mean)
qui sum inc_t2 [aw=weight]
scalar mean2=r(mean)
scalar g_mean = (mean2-mean1)/mean1
gen g_mean  = (mean2-mean1)/mean1
dis "Mean 1              =" mean1
dis "Mean 2             = " mean2
dis "Growth in averages = " g_mean

//  Q3.3:
gen g_inc =(inc_t2-inc_t1)/inc_t1
replace g_inc = 0 in 1

//  Q3.4:
line g_inc g_mean perc, title(Growth Incidence Curve) yline(`g_mean') ///
legend(order( 1 "GIC curve" 2 "Growth in average income")) ///
xtitle(Percentiles (p)) ytitle(Growth in incomes)  ///
plotregion(margin(zero))
/* The growth between the two periods is relatively pro-poor for about the 75% poorest */ 

//  Q3.5:
drop in 1
cap drop temp
gen temp = g_inc
sum temp [aw=weight] if (inc_t1<10.2)
dis = r(mean)
ipropoor inc_t1 inc_t2, pline(10.2)
/* The Chen and Ravallion pro-poor index is -0.08 which is greater than the the growth rate in the average income. Thus, we are in the scheme of a relative pro-poor growth*/

//  Q3.6:
dfgtgr inc_t1 inc_t2, alpha(1) pline(10.2)
/* Despite a reduction in inequality, the poverty gap increase between the two periods as a consequence of economic growth*/

