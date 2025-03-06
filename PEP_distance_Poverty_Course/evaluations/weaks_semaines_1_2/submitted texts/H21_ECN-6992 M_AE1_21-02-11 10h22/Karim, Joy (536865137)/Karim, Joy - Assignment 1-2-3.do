**********************9.5%


//Q1*********3%
/*Inserting the data*/
clear
input identifier	region	income	hhsize
1	1	210	4
2	1	450	6
3	1	300	5
4	1	210	3
5	2	560	2
6	2	400	4
7	3	140	4
8	3	250	2
9	3	340	2
10	3	220	2
11	3	360	3
12	3	338	2
13	3	330	3
14	3	336	4
end
/*generate the variable per capita income*/
gen pcinc = income/hhsize
//  Q1.2: 
/* Estimating the average per capita income */ 
sum pcinc [aw=hhsize]
/*Estimating the total incomes */
sum income [aw=hhsize]

// Q1.3
/*Generating per capita poverty gap (pgap) nd estimating its average*/
gen pline = 120
gen pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
sum pgap [aw=hhsize]

//Q1.4
/*Q 1.4: Redo question Q 1.3 using DASP*/

ifgt pcinc, pline(120) alpha(1) hsize(hhsize)

//Q1.5 
/*generating a variable deflator index and generating the variable real per capita income*/

gen deflator = 1
replace deflator = 0.85 if region == 2 
replace deflator = 0.80 if region ==3
gen rpcinc = pcinc/deflator

//Q1.6
/* repeating 1.3 1nd 1.4 using real per capita income*/

sum rpcinc [aw=hhsize]
replace pline = 130
replace pgap = (pline-rpcinc)/pline if (rpcinc < pline)
sum pgap [aw=hhsize]
ifgt rpcinc, pline(130) alpha(1) hsize(hhsize) 

// EXERCISE 2*******1.5%
/*inserting the data*/
clear
input identifier	period	income	hhsize	na
1	1	29	4	   2
2	1	50	3	   2
3	1	36	4	3
1	2	30	4	2
2	2	48	3	3
3	2	46	5	2
end
//Q2.1
/*estimate the average per capita income and the average per adult-equivalent income for each period*/
gen nc = hhsize-na
gen aes = 1 + 0.6*(na - 1)+ 0.4*nc
gen perinc1 = income/ hhsize if period==1
gen perinc2 = income/ hhsize if period==2
gen peraesinc1 = income/ aes if period==1
gen peraesinc2 = income/ aes if period==2
sum perinc1 [aw=hhsize]
sum perinc2 [aw=hhsize]
sum peraesinc1 [aw= aes ]
sum peraesinc2 [aw= aes ]

// EXERCISE 3***********5%
/*inserting the data*/
use "C:\Users\Joy\Downloads\data_3.dta", clear
/*computing size of the sample*/
//Q3.1
sum
//Q3.2
/*Ranking per capita expenditure , generating the variable population share and percentiles and quantiles*/
sort pcexp
sum hhsize
gen ps = hhsize/r(sum)
gen p=sum(ps)
gen q= pcexp
//Q3.3
/* drawing a cumulative distribution curve*/
line p pcexp , title(The cumulative distribution curve) xtitle(The per capita expenditures (y))ytitle(F(y))
//Q3.4
/*drawing the quantile curve*/
line q p , title(The quantile curve) xtitle(the percentile (p)) ytitle(The quantile Q(p))
//Q3.5
/* using DASP to draw quantile curve*/
db c_quantile
c_quantile pcexp, hsize(hhsize) hgroup(zone) min(0.0) max(0.9)
//Q3.6
/* Using DASP drawing the density curves of the per capita expenditures by sex of household head*/
db cdensity
cdensity pcexp, hsize(hhsize) hgroup(sex) type(den) min(0) max(800000) 




