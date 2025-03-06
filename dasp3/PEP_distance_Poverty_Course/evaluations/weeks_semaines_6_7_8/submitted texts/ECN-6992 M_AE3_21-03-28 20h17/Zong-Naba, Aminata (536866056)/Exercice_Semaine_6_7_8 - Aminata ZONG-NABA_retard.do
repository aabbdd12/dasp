*************12%

//EXERCICE1//
//Q1.1//
cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)

//Q1.2//
ifgt  ae_exp, alpha(0) hsize(hsize) pline(24000)
ifgt  ae_exp, alpha(0) hsize(hsize) pline(20900)
ifgt  ae_exp, alpha(0) hsize(hsize) opl(mean) prop(50)

//EXERCICE2//
//Q2.1//

dfgtg ae_exp, hgroup(sex) alpha(0) pline(20900)

//Q2.2//

ifgt  ae_exp, alpha(0) hsize( region ) pline(20900)

//Q2.3//

//EXERCICE3//
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
8	0.1	15.00	7.70
9	0.1	12.00	6.60
10	0.1	13.50	6.60
end

//Q3.1//

sort inc_t1
gen perc=sum(weight)
list perc

//Q3.2//

qui sum inc_t1 [aw=weight]
scalar mean1=r(mean)
qui sum Inc_t2 [aw=weight]
scalar mean2=r(mean)
scalar g_mean = (mean2-mean1)/mean1
gen g_mean  = (mean2-mean1)/mean1 
dis "Mean 1              =" mean1
dis "Mean 2             = " mean2
dis "Growth in averages = " g_mean

//Q3.3//

gen g_inc =(Inc_t2-inc_t1)/inc_t1
replace g_inc = 0 in 1

//Q3.4//

line g_inc g_mean perc,
title(Growth Incidence Curve)
yline(`g_mean')
legend(order( 1 "GIC curve" 2 "Growth in average income"))
xtitle(Percentiles (p)) ytitle(Growth in incomes)
plotregion(margin(zero))

//Q3.5//

drop in 1
sum g_inc [aw=weight] if (inc_t1<10.4)
dis = r(mean)
ipropoor inc_t1 Inc_t2, pline(10.4)

//Q3.6//

dfgtgr inc_t1 Inc_t2, alpha(1) pline(10.4)
