**********12.5%

// WEEKS 6-7-8 ASSIGNMENT
// NGO, HA QUYEN


// EXERCISE 1 ==================================================================

// Q1.1:

use data_b3_3.dta, replace

cnpe ae_exp  min_ae_exp, xvar(ae_exp) hsize(hsize) min(0) max(60000)                      ///
legend(order( 1 " Observed well-being" 2 "Perceived  minimum  well-being"))  ///
subtitle("") title(The subjective poverty line)            ///
 xtitle(Observed well-being)                       /// 
 ytitle(Predicted level of the perceived  minimum  well-being )              ///
 vgen(yes)
 
cap drop dif
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) hsize(hsize) xval(0) vgen(yes)

cnpe ae_exp  min_ae_exp, xvar(ae_exp) hsize(hsize) min(0) max(60000)                      ///
legend(order( 1 "Observed well-being " 2 "Perceived  minimum  well-being"))  ///
subtitle("") title(The subjective poverty line)            ///
xline(22828.025391) xtitle(Observed well-being)            /// 
ytitle(Predicted level of the perceived  minimum  well-being ) 

// Q1.2:

ifgt  ae_exp, alpha(1) hsize(hsize) pline(22828.025391)
ifgt  ae_exp, alpha(1) hsize(hsize) pline(20900)
ifgt  ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)



// EXERCISE 2 ==================================================================

// Q2.1: 

use data_b3_3.dta, replace

dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20900)

// 2.2:

dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(20900)

// Q2.3:

gen ae_exp2 = ae_exp
replace ae_exp2 = ae_exp * 1.11 if region == 3
replace ae_exp2 = ae_exp * 0.94 if region == 2

// Q2.4:

dfgtgr ae_exp ae_exp2, alpha(1) pline(20900)


// Q2.5:

dfgtg2d ae_exp ae_exp2, hgroup(region) alpha(1) pline(20900) ref(0)


// EXERCISE 3 ==================================================================

// Q3.1:

clear
input identifier weight inc_t1 inc_t2
0 0.0 0 	0
1 0.1 1.5 	1.54
2 0.1 4.5 	3.85
3 0.1 7.5	6.6
4 0.1 3		2.75
5 0.1 4.5 	4.4
6 0.1 9		7.7
7 0.1 10.5 	8.8
8 0.1 15 	7.7	
9 0.1 12 	6.6
10 0.1 13.5 	6.6
end

sort inc_t1
gen perc=sum(weight)
list perc


// Q3.2:

qui sum inc_t1 [aw=weight]   			
scalar mean1=r(mean)         			
qui sum inc_t2 [aw=weight]
scalar mean2=r(mean)         			
scalar g_mean = (mean2-mean1)/mean1
gen g_mean  = (mean2-mean1)/mean1    	 
dis "Mean 1              =" mean1
dis "Mean 2             = " mean2
dis "Growth in averages = " g_mean


// Q3.3:

gen g_inc =(inc_t2-inc_t1)/inc_t1 
replace g_inc = 0 in 1   

// Q3.4:

line g_inc g_mean perc, ///
title(Growth Incidence Curve) ///
yline(`g_mean') ///
legend(order( 1 "GIC curve" 2 "Growth in average income")) ///
xtitle(Percentiles (p)) ytitle(Growth in incomes)  ///
plotregion(margin(zero))


// Q3.5:

drop in 1
sum g_inc [aw=weight] if (inc_t1<10.4) 	
dis = r(mean)
ipropoor inc_t1 inc_t2, pline(10.4)   	


// Q3.6:

dfgtgr inc_t1 inc_t2, alpha(1) pline(10.4)









