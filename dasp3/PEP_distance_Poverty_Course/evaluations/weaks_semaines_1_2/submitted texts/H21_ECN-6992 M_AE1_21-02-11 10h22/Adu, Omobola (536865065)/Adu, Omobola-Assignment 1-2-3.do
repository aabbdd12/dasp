*********************7%

* Inserting the data ****************3%
clear
input 	hhid region income hhsize
1	1	210	4
2	1	450	6
3	1	300	5
4	1	210	3
5	2	560	2
6	2	400	4
7	3	140	4
8	3	250	2
9	3	340	2
10	3	220	3
11	3	360	3
12	3	338	3
end

/* Q1.1 generate per capita income */ 
gen pcinc = income/hhsize

/* Q1.2 average per capita income and total incomes */
sum pcinc [aw=hhsize]
sum income

/* Q1.3 per capita poverty gap */
gen pline = 100
gen pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
sum pgap [aw=hhsize]

/* Q1.4 DASP */
ifgt pcinc, pline(100) alpha(1) hsize(hhsize)

/* Q1.5 purchasing power *//***************/
gen deflator = 1
replace deflator = 0.9 if region == 2 /*replace deflator = 1.1 if region == 2 */
replace deflator = 0.7 if region == 3 /*replace deflator = 1.3 if region == 2 */
gen rpcinc = pcinc/deflator

/* Q1.6 pline is 120 */
sum rpcinc [aw=hhsize]
replace pline = 120
replace pgap = (pline-rpcinc)/pline if (rpcinc < pline)
sum pgap [aw=hhsize]
ifgt rpcinc, pline(120) alpha(1) hsize(hhsize)


********??? Exercice 2

/* Exercise 3 *************4%*/
/* 3.2 */
sort pcexp
sum hhsize
gen ps = hhsize/r(sum)
gen p = sum(ps)
gen q = pcexp
list, sep(0)
#delimit ;

/* 3.3 */
line p pcinc, title(The cumulative distribution
curve) xtitle(F(y))
ytitle(The per capita income (y)); /*line p pcexp if p<0.95, title(The cumulative distribution curve) xtitle(The per per capita income
> (y)) ytitle(F(y))*/

/* 3.4 */
#delimit ;
line q p /*if p<0.95,*/, title(The quantile curve) xtitle(the
percentile (p)) ytitle(The quantile Q(p));

/* 3.5 */
c_quantile pcexp, region(region);

************?Q6
