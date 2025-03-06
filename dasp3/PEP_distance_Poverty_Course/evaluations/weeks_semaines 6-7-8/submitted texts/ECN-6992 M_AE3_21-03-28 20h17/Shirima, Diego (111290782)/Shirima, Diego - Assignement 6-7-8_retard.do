*******12.5%
clear
set more off 
* Diego Shirima

/*==============================================================================
						EXERCISE 1
==============================================================================*/

** --> Question 1.1
use data_b3_3, clear 

cnpe ae_exp min_ae_exp, xvar(ae_exp) min(3374.894) max(583743.4) /// 
legend(order( 1 "Perceived  minimum  well-being " 2 "Observed well-being"))  /// 
subtitle("") title(The subjective poverty line) /// 
xtitle(Observed well-being) ///   
ytitle(Predicted level of the perceived  minimum  well-being ) vgen(yes)  
graph export "1.1 Subjective Poverty Line.png", as(png) name("Graph") replace

/* Note:
Estimating the level of ae_exp when the difference between the predicted minimum well-being  and the observed well-being is nil 
*/ 

cap drop dif 
gen dif = _npe_min_ae_exp- ae_exp 
cnpe ae_exp, xvar(dif) xval(0) vgen(yes) 

/*Showing the subjective poverty line  */ 
cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(3374.894) max(583743.4) /// 
legend(order( 1 "Perceived  minimum  well-being " 2 "Observed well-being"))  /// 
subtitle("") title(The subjective poverty line) /// 
xline(22692.876953) xtitle(Observed well-being) ///  
ytitle(Predicted level of the perceived  minimum  well-being )  

** --> Question 1.2: 
 
ifgt  ae_exp, alpha(0) hsize(hsize) pline(22692.876953) 
ifgt  ae_exp, alpha(0) hsize(hsize) pline(20900) 
ifgt  ae_exp, alpha(0) hsize(hsize) opl(mean) prop(50) 
 
** --> Question 1.3

/* Note:
Developing countries should use the relative approach since its easy to establish 
the cutting points for set of good and services received per person  */


 
/*==============================================================================
						EXERCISE 2
==============================================================================*/

** --> Question 2.1 

	use data_b3_3, clear 
	dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20900) 
	
/* Note:
The contribution of poverty among households headed by women is greater than the contribution that comes from their representativeness in the total population (0.45 VS 0.25) */


** --> Question 2.2

	dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(20900) 
	
** --> Question 2.3
	// ae_exp increased by 11% in region 3
	gen  ae_exp2=ae_exp
	replace ae_exp2=ae_exp+(ae_exp*0.11) if region==3
	
	//// ae_exp decreased by 6% in region 2
	replace ae_exp2=ae_exp-(ae_exp*0.06) if region==2
	
** --> Question 2.4
	dfgtgr ae_exp ae_exp2, alpha(1) pline(20900)
	
/* Note:
Using Shapley approach the growth estimate is  0.001021, and redestribution is 
-0.003068 lower than the rest. */


** --> Question 2.5
	dfgtgr  ae_exp ae_exp, alpha(1) pline(20900) cond1(region)

/*==============================================================================
						EXERCISE 3
==============================================================================*/

 ** Loading data
clear
input identifier	weight	inc_t1	inc_t2
0	0	0.00	0.00
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

** --> Question 3.1

	sort inc_t1
	gen perc=sum(weight)

** --> Question 3.2

	qui sum inc_t1 [aw=weight]
	scalar mean1=r(mean)
	qui sum inc_t2 [aw=weight]
	scalar mean2=r(mean)
	scalar g_mean = (mean2-mean1) / mean1
	gen g_mean  = (mean2-mean1) / mean1
	dis "Mean 1 =" mean1
	dis "Mean 2 =" mean2
	dis "Growth in averages = " g_mean

** --> Question 3.3
	gen g_inc =(inc_t2-inc_t1)/inc_t1
	replace g_inc = 0 in 1

** --> Question 3.4
	line g_inc g_mean perc, title(Growth Incidence Curve) yline(`g_mean') ///
	legend(order( 1 "GIC curve" 2 "Growth in average income")) ///
	xtitle(Percentiles (p)) ytitle(Growth in incomes)  ///
	plotregion(margin(zero))
	graph export "3.4 Growth Incidence Curve.png", as(png) name("Graph") replace

** --> Question 3.5
	drop in 1
	cap drop temp
	gen temp = g_inc
	sum temp [aw=weight] if (inc_t1<10.2)
	dis = r(mean)
	ipropoor inc_t1 inc_t2, pline(10.2)


** --> Question 3.6
	dfgtgr inc_t1 inc_t2, alpha(1) pline(10.2)
