input 1-1 cnpe ae_exp min_ae_exp, xvar(ae_exp) min(0) max(60000)
1-2 ifgt ae_exp, alpha(0) hsize(hsize) pline(22441.69)
    ifgt ae_exp, alpha(0) hsize(hsize) pline(20600)
	 ifgt  ae_exp, alpha(0) hsize(hsize) opl(mean) prop(50)
	 
	 
	 exo3
	 identifier	weight	inc_t1	inc_t2
1	.1	1.5	1.54
4	.1	3	2.75
2	.1	4.5	3.85
5	.1	4.5	4.4
3	.1	7.5	6.6
6	.1	9	7.7
7	.1	10.5	8.8
9	.1	12	6.6
10	.1	13.5	6.6
8	.1	15	7.7

3-1 
sort inc_t1
gen perc=sum(weight)
3-2
sum inc_t1 [aw=weight]
scalar mean1=r(mean)
sum inc_t2 [aw=weight]
scalar mean2=r(mean)
scalar g_mean = (mean2-mean1)/mean1
gen g_mean = (mean2-mean1)/mean1
3-3
gen g_inc =(inc_t2-inc_t1)/inc_t1
replace g_inc = 0 in 1
3-4
line g_inc g_mean perc,
3-5
drop in 1
sum g_inc [aw=weight] if (inc_t1<10.4)
dis = r(mean)
ipropoor inc_t1 inc_t2, pline(10.4)
3-6
dfgtgr inc_t1 inc_t2, alpha(1) pline(10.4)

exo2
2-1
dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20600)
2-2
dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(20600)

