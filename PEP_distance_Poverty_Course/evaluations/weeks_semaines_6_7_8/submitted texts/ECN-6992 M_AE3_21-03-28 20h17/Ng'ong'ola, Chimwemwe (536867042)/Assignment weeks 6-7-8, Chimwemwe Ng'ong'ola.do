*******11.5%

* Exercise 3*
* 3.1 inserting the data and generating the percentiles*
sort inc_t1
gen perc= sum(weight)
*3.2 initiliaze the scalar g_mean, which is equal to the growth rate in the average income*qui sum inc_t1 [aw=weight]
scalar mean1=r(mean)
qui sum inc_t2 [aw=weight]
scalar mean2=r(mean)
scalar g_mean = (mean2-mean1)/mean1
gen g_mean = (mean2-mean1)/mean1
dis "Mean 1 =" mean1
dis "Mean 2 = " mean2
dis "Growth in averages = " g_mean
*3.3 generate the variable g_inc, as the growth in individuals incomes*
gen g_inc =(inc_t2-inc_t1)/inc_t1
replace g_inc = 0 in 1
*3.4 Draw the Growth Incidence Curve using the variables g_inc and perc. Discuss the results*
line g_inc g_mean perc, title(Growth Incidence Curve) yline(`g_mean')legend(order( 1 "GIC curve" 2 "Growth in average income"))xtitle(Percentiles (p)) ytitle(Growth in incomes)plotregion(margin(zero))
*3.5 Assume that the poverty line is equal to 10.4. Estimate the Chen and Ravallion (2003) pro-poor index (IP=1/q ∑_(i=1)^q▒〖γ^t (p_i ) 〗)*
drop in 1
cap drop temp
gen temp = g_inc
sum temp [aw=weight] if (inc_t1<10.4)
dis = r(mean)
ipropoor inc_t1 inc_t2, pline(10.4)
*3.6 Using the Shapley approach decompose the change in the poverty gap into growth and redistribution components*
dfgtgr inc_t1 inc_t2, alpha(1) pline(10.4)
* Exercise 2*
clear
use "C:\Users\DHN1\Downloads\data_b3_3.dta"
*2.1 Use the file data_b3_3.dta and decompose poverty (headcount index) by the gender of the household head (sex) (the poverty line is 20900).  What can we conclude?*   
dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20900)
*2.2 Estimate the total poverty (headcount) according to the region of the household head (region)*
dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(20900)
*2.3 Generating the variable ae_exp2, based on the information*
 gen ae_exp2= ae_exp*0.94 if region==2
replace ae_exp2= ae_exp*1.11 if region==3
replace ae_exp2= ae_exp if ae_exp2==.
*2.4 By using the Shapley approach, decompose the poverty gap change into growth and redistribution*
dfgtgr ae_exp ae_exp2,alpha(1) pline(20900)
*2.5 Perform a sectoral decomposition (based on region groups) of the change in total poverty gap. Discuss the results*
dfgtg ae_exp2 , hgroup(region) hsize(hsize) alpha(1) pline(20900)

*Exercise 1*
*1.1. Using the data file data_b3_3.dta, estimate the subjective poverty line*
use data_b3_3.dta, replace
cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)legend(order( 1 " Observed well-being" 2 "Perceived  minimum  well-being"))subtitle("") title(The subjective poverty line)xtitle(Obser ved well-being)ytitle(Predicted level of the perceived  minimum  well-being )vgen(yes)
cap drop dif
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) xval(0) vgen(yes)
cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)legend(order( 1 "Observed well-being " 2 "Perceived  minimum  well-being"))subtitle("") title(The subjective poverty line)xline(22692.876953) xtitle(Observed well-being)ytitle(Predicted level of the perceived  minimum  well-being )
*1.2 Estimate the poverty gap (using the variables: ae_exp and hsize) for each of the three cases, and then discuss the results*
*a.the subjective poverty line;*
ifgt  ae_exp, alpha(1) hsize(hsize) pline( 22692.876953)
*b.the absolute poverty line (z=20900)*
ifgt  ae_exp, alpha(1) hsize(hsize) pline(20900)
* c.the relative poverty line (z= half of average income)*
ifgt  ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)


