***************10.5%



******2.5%
use data_b3_1.dta, clear
/* Q1.1
estimate the subjective poverty line.
*/
cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)                      ///
legend(order( 1 "Perceived  minimum  well-being " 2 "Observed well-being"))  ///
subtitle("") title(The subjective poverty line)            ///
 xtitle(Observed well-being)                       /// 
 ytitle(Predicted level of the perceived  minimum  well-being )              ///
 vgen(yes)
 
cap drop dif
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) xval(0) vgen(yes)

cnpe ae_exp min_ae_exp, xvar(ae_exp) min(0) max(60000) ///
legend(order( 1 "Perceived minimum well-being " 2 "Observed well-being")) ///
subtitle("") title(The subjective poverty line) ///
xline(22622.398438) xtitle(Observed well-being) ///
ytitle(Predicted level of the perceived minimum well-being )
 
/* Q1.2
estimate the poverty gap. This is done using the ifgt command and alpha is set to 1
*/ 
ifgt ae_exp, alpha(1) hsize(hsize) pline(22622.398438)
ifgt ae_exp, alpha(1) hsize(hsize) pline(21000)
ifgt ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)

**************************4%
/* Q2.1
Decompose poverty by gender of the household.
*/
dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(21000)

/* Q2.2
Estimate poverty (headcount) by region. Therefore, alpha is set to 0
*/
ifgt ae_exp, alpha(0) hsize(hsize) hgroup(region) pline(21000)

/* Q2.3
adult equivalent expenditures have increased and reduced by 10% and 6% in region 3 (ae_expr3) and region 2 (ae_expr2) respectively. Then Generate the variable ae_exp2 based on the changes
*/
gen ae_expr3 = ae_exp*1.1*(region==3)
gen ae_expr2 = ae_exp*0.94*(region==2)
gen ae_exp2 = ae_exp+ae_expr3+ae_expr2

/* Q2.4
Using the Shapley approach, decompose the poverty gap change into growth and redistribution
*/
dfgtgr ae_exp ae_exp2, alpha(1) pline(21000)



*****************4%
clear
input identifier weight inc_t1 inc_t2
0 0 0.00 0.00
1 0.1 1.50 1.54
2 0.1 4.50 3.85
3 0.1 7.50 6.60
4 0.1 3.00 2.75
5 0.1 4.50 4.40
6 0.1 9.00 7.70
7 0.1 10.50 8.80
8 0.1 15.00 7.70
9 0.1 12.00 6.60
10 0.1 13.50 6.60
end


/* Q3.1
generate the percentiles based on the rank of incomes of the initial period (variable perc)) and the first percentile must be equal to zero)
*/
sort inc_t1
gen perc=sum(weight)
list perc

/* Q3.2
Initialize the scalar g_mean
*/
qui sum inc_t1 [aw=weight]   			
scalar mean1=r(mean)         	
qui sum inc_t2 [aw=weight]
scalar mean2=r(mean)         			
scalar g_mean = (mean2-mean1)/mean1
gen g_mean  = (mean2-mean1)/mean1    	
dis "Mean 1              =" mean1
dis "Mean 2             = " mean2
dis "Growth in averages = " g_mean

/* Q3.3
Generating the variable g_inc, as the growth in individual incomes
*/
gen g_inc =(inc_t2-inc_t1)/inc_t1 		
replace g_inc = 0 in 1 

/* Q3.4
Drawing the Growth Incidence Curve using the variables g_inc and perc
*/
line g_inc g_mean perc, ///
title(Growth Incidence Curve) ///
yline(`g_mean') ///
legend(order( 1 "GIC curve" 2 "Growth in average income")) ///
xtitle(Percentiles (p)) ytitle(Growth in incomes)  ///
plotregion(margin(zero))

/* Q3.5
Estimating the Chen and Ravallion when poverty line is equal to 10.2
*/
drop in 1
sum g_inc [aw=weight] if (inc_t1<10.2) 	
dis = r(mean)
ipropoor inc_t1 inc_t2, pline(10.2)

/* Q3.6
Using the Shapley approach, decompose the change in the poverty gap into growth and redistribution components
*/
dfgtgr inc_t1 inc_t2, alpha(1) pline(10.2)