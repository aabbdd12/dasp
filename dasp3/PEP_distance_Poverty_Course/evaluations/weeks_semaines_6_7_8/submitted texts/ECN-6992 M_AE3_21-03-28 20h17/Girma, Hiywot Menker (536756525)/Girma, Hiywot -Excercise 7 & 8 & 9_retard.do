*****11,5%

svyset psu [pweight=sweight], strata(strata)
gen N= hsize* sweight

*Q 1.1*3,5%
cap drop dif
gen dif =min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) xval(0) vgen(yes)

*Q 1.2
ifgt ae_exp, alpha(1) hsize(hsize) pline(25305)
ifgt ae_exp, alpha(1) hsize(hsize) pline(20600)
ifgt ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)

*Q 2.1 ****4%
dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20600)

*Q 2.2
dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(20600)

*Q 2.3
gen ae_exp2=ae_exp
replace ae_exp2=1.12*ae_exp if region==3
replace ae_exp2=1.06*ae_exp if region==2

*Q 2.4
dfgtgr ae_exp ae_exp2,pline(20600)

*Q 2.5
dfgtgr ae_exp ae_exp2, pline(20600) alpha(1)cond(region==1)
dfgtgr ae_exp ae_exp2, pline(20600)alpha(1) cond(region==2)
dfgtgr ae_exp ae_exp2, pline(20600) alpha(1)cond(region==3)
dfgtgr ae_exp ae_exp2, pline(20600) alpha(1)cond(region==4)

*Q 3.1 ***4%
sort inc_t1
gen perc=sum(weight)
replace p=p/p[_N]

*Q 3.2
qui sum inc_t1 [aw=weight]
scalar mean1=r(mean)
qui sum inc_t2 [aw=weight]
scalar mean2=r(mean)
scalar g_mean = (mean2-mean1)/mean1
gen g_mean = (mean2-mean1)/mean1
dis "Mean 1 =" mean1
dis "Mean 2 = " mean2
dis "Growth in averages = " g_mean

*Q 3.3
gen g_inc =(inc_t2-inc_t1)/inc_t1
replace g_inc = 0 in 1


*Q 3.4
line g_inc g_mean perc, title(Growth Incidence Curve) yline(`g_mean') ///
legend(order( 1 "GIC curve" 2 "Growth in average income")) ///
xtitle(Percentiles (p)) ytitle(Growth in incomes) ///
plotregion(margin(zero))

*Q 3.5
drop in 1
cap drop temp
gen temp = g_inc
sum temp [aw=weight] if (inc_t1<10.4)
dis = r(mean)
ipropoor inc_t1 inc_t2, pline(10.4)

*Q 3.6
dfgtgr inc_t1 inc_t2, alpha(1) pline(10.4)

