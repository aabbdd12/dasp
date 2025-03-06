
// EXERCICE 1

// Q1
/* Use the non parametric regression approach to predict the perceveid minimum well-being */
use data_b3_2.dta, replace
cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)     hs(hsize)       ///
legend(order( 1 "Perceived  minimum  well-being " 2 "Observed well-being"))  ///
subtitle("") title(The subjective poverty line) 						     ///
 xtitle(Observed well-being) 									             /// 
 ytitle(Predicted level of the perceived  minimum  well-being )              ///
 vgen(yes)
 
/* Estimate the level of ae_exp where the difference between the predicted minimum well-being 
and the observed well-being is nil */
cap drop dif
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, hs(hsize) xvar(dif) xval(0) vgen(yes)

/*Show the subjective poverty line  */
cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)    hs(hsize)        ///
legend(order( 1 "Perceived  minimum  well-being " 2 "Observed well-being"))  ///
subtitle("") title(The subjective poverty line) 						     ///
xline(22289.966797) xtitle(Observed well-being) 						     /// 
ytitle(Predicted level of the perceived  minimum  well-being )

 

//  Q2:

ifgt  ae_exp, alpha(1) hsize(hsize) pline(22289.966797)
ifgt  ae_exp, alpha(1) hsize(hsize) pline(20600)
ifgt  ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)


//  Q3:	
/*
The use of the relative poverty line is more appropriate for the developed countries. 
This can be justified by the rapid increase in well-being in average and the standard of livings over time.
*/



// EXERCICE 2


// Q1
use data_b3_2.dta, clear
dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20600)
/*
We can conclude that the poverty within the female-headed households is more pronounced.
However, their relative and absolute contribution to the total poverty is lower than man-headed households.
This is because of the much lower population share of female-headed households in the total population.
*/


//  Q3:
ifgt ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(20600)


//  Q3:
gen     ae_exp2=ae_exp
replace ae_exp2=ae_exp2*(1+0.12) if region==3
replace ae_exp2=ae_exp2*(1-0.06) if region==2


//  Q4:
dfgtgr ae_exp ae_exp2, alpha(1) pline(20600) hsize1(hsize) hsize2(hsize)

//  Q5:
dfgtg2d ae_exp ae_exp2, alpha(1) hgroup(region) pline(20600) hsize1(hsize) hsize2(hsize) ref(0)



// EXERCICE 3


//  Q1:
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

sort inc_t1
gen perc=sum(weight)

//  Q2:
qui sum inc_t1 [aw=weight]
scalar mean1=r(mean)
qui sum inc_t2 [aw=weight]
scalar mean2=r(mean)
scalar g_mean = (mean2-mean1)/mean1
gen g_mean  = (mean2-mean1)/mean1
dis "Mean 1              =" mean1
dis "Mean 2             = " mean2
dis "Growth in averages = " g_mean

//  Q3:
gen g_inc =(inc_t2-inc_t1)/inc_t1
replace g_inc = 0 in 1

//  Q4:
line g_inc g_mean perc, title(Growth Incidence Curve) yline(`g_mean') ///
legend(order( 1 "GIC curve" 2 "Growth in average income")) ///
xtitle(Percentiles (p)) ytitle(Growth in incomes)  ///
plotregion(margin(zero))


//  Q5:
drop in 1
cap drop temp
gen temp = g_inc
sum temp [aw=weight] if (inc_t1<10.4)
dis = r(mean)
ipropoor inc_t1 inc_t2, pline(10.4)


//  Q6:
dfgtgr inc_t1 inc_t2, alpha(1) pline(10.4)
