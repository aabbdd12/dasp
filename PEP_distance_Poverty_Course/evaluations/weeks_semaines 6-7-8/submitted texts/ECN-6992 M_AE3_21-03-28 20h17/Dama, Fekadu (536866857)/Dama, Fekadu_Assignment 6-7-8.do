*****************12.5%


*Assignment 6-7-8

use "C:\data_b3_1", clear

*question 1.1. Estimating subjective poverty line

cnpe ae_exp min_ae_exp, xvar(ae_exp) min(0) max(60000) legend(order(1 "perceived minimum well-being" 2 "observed well-being")) title(the subjective poverty line) xtitle(Observed wellbeing) ytitle(predicted level of perceived minimum well-being) vgen(yes)

cap drop dif
gen dif = _npe_min_ae_exp-ae_exp

cnpe ae_exp, hsize(hsize) xvar(dif) xval(0) vgen(yes)
*this command yields the subjective poverty line of  22621.578125

cnpe ae_exp min_ae_exp, xvar(ae_exp) min(0) max(60000) legend(order(1 "perceived minimum well-being" 2 "observed well-being")) subtitle("") title(The Subjective Poverty Line) xline( 22621.578125) xtitle(Observed Well-being) ytitle(Predicted Level of Perceived Minimum Well-being)

*question 1.2 Estimating poverty gap
*1.2 (a) according to subjective poverty line

ifgt ae_exp, alpha(1) hsize(hsize) pline(22621.578125)

*1.2 (b) absolute poverty line

ifgt ae_exp, alpha(1) hsize(hsize) pline(21000)

*1.2 (c) relative poverty line
ifgt ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)


*EXERCISE 2

* Question 2.1: decomposition of sex of household head: decompose poverty (headcount index) by the gender of the household head (sex) (the poverty line is 21000).  What can we conclude?   

dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(21000)

*Question 2.2. Estimate the total poverty (headcount) according to the region of the household head (region). 

dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(21000)

* Question 2.3 
*The distribution of the adult equivalent expenditures is similar to that of the initial period (ae_exp), with the following slight differences
*the adult equivalent expenditures have increased by 10% in region 3;
*the adult equivalent expenditures have decrease by 6% in region 2;

*Generate the variable ae_exp2, based on the information above. 

generate ae_exp2 = ae_exp
replace ae_exp2 = ae_exp*1.1 if region==3
replace ae_exp2 = ae_exp*1.06 if region==2

*Question 2.4. By using the Shapley approach, decompose the poverty gap change into growth and redistribution. Then discuss the results

dfgtgr ae_exp ae_exp2, alpha(1) pline(21000)

*Question 2.5 Perform a sectoral decomposition (based on region groups) of the change in total poverty gap. Discuss the results.

dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(1) pline(21000)
  *This gives the poverty gap for the initial distribution by region 
  *Total poverty gap is 0.102046
 
dfgtg ae_exp2, hgroup(region) hsize(hsize) alpha(1) pline(21000)
*This gives the poverty gap for the initial distribution by region
*Total poverty gap is 0.327031
 
* The change in total poverty gap, disaggregated by region is the difference between the poverty gap for the second distribution and the poverty gap for the first distribution, i.e., 0.327031-0.102046 = 22.50



stop

*Exercise 3

*3.1 Inserting  data and then generating the percentiles (based on the rank of incomes of the initial period (variable perc)), and the first percentile must be equal to zero).
clear
input identifier weight inc_t1 inc_t2
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

*3.2 Initializing the scalar g_mean, which is equal to the growth rate in the average income.
qui sum inc_t1 [aw=weight]
scalar mean1=r(mean)
qui sum inc_t2 [aw=weight]
scalar mean2=r(mean)
scalar g_mean = (mean2-mean1)/mean1
gen g_mean = (mean2-mean1)/mean1
dis "mean1 = " mean1
dis "mean2 = " mean2
dis "Growth in averages =" g_mean

*3.3 Generating the variable g_inc, as the growth in individual incomes
gen g_inc = (inc_t2-inc_t1)/inc_t1
replace g_inc = 0 in 1

*3.4 Drawing the Growth Incidence Curve using the variables g_inc and perc

line g_inc g_mean perc, title(Growth Incidence Curve) yline(`g_mean') legend(order(1 "GIC curve") 2 "Growth in average income")) xtitle(Percentiles (p)) ytitle(Growth in incomes) plotregion(margin(zero))

*Note: running the above command, STATA returns "plotregion(margin(zero)) ) is not a twoway plot type"

*3.5 Estimating the Chen and Ravallion (2003) pro-poor index 
drop in 1
cap drop temp
gen temp = g_inc
sum temp [aw=weight] if (inc_t1<10.2)
dis = r(mean)
ipropoor inc_t1 inc_t2, alpha(1) pline(10.2)

*3.6 Decomposing the change in the poverty gap into growth and redistribution components by using the Shapley approach

dfgtgr inc_t1 inc_t2, alpha(1) pline(10.2)

