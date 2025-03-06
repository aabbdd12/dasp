*************************11%

//Stata code for the Practical exercise 1-2*/ Catherine Manthalu


set more off

clear all

/*QUESTION 1**********   3.5%*/

/* Inserting the data */ 


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
12	3	338	3



end

// Q1.1

/* Generating the variable per capita income */ 
gen pcinc = income/hhsize

//  Q1.2: 

/* Estimating the average per capita income */ 
sum pcinc [aw=hhsize]

/*Estimating the total incomes */
sum income [aw=hhsize]

// *Q1.3
*Generating and estimating average of percapita poverty gap*/
gen     pline = 100
gen     pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
sum     pgap [aw=hhsize]

//*Q1.4 Generating and estimating average of percapita poverty gap using DASP*/
ifgt pcinc, pline(100) alpha(1) hsize(hhsize)

//* Q1.5 Generating variable deflator and real percapita income/hhsize*/

gen     deflator = 1
replace deflator = 0.90 if region == 2
replace deflator = 0.70 if region == 3
gen     rpcinc = pcinc/deflator


//* Q1.6 Generating and estimating average of real percapita income*/

sum rpcinc [aw=hhsize]
replace pline = 120
replace pgap  = (pline-rpcinc)/pline if (rpcinc < pline)
sum     pgap [aw=hhsize]
ifgt    rpcinc, pline(120) alpha(1) hsize(hhsize)


/*QUESTION 2**********3%*/ 

use "C:\Users\USER\Desktop\Exercise\data_1.dta", clear

/*Q 2.1 * Estimating the average per adult equivalent expenditure */ 
sum     ae_exp [aw=hhsize]
imean ae_exp, hsize(hhsize)
imean ae_exp, hsize(hhsize) hgroup(region)


gen fweight = sweight*hhsize

/*Q 2.2*/
sum  ae_exp [aw=sweight]
sum  ae_exp [aw=hhsize]
sum  ae_exp [aw=fweight]

/*Q 2.3*/
imean ae_exp, hsize(hhsize) hgroup(region)
di 2*26080.656250

/*Q 2.4 Estimating whether Adult per capita expenditure for male h/h head is higher than for female h/h head*/
dimean ae_exp ae_exp, hsize1(hhsize) test(0) cond1(sex==1 ) hsize2(hhsize) cond2(sex==2 )


//*QUESTION 3**********4.5%*//


use "C:\Users\USER\Desktop\Exercise\data_1.dta", clear
//*Q 3.1 Estimating population size*//
sum hhsize

//*Q 3.2 Ranking,  and generating variables*/
gen fweight = sweight*hhsize
// *Ranking percapica expenditure*/
sort pcexp 
list pcexp

// *generating populations share*/
sum pcexp [aw=fweight]
gen  ps  = fweight*pcexp
sum pcexp [aw=fweight]
replace  ps  =  ps/r(sum) 

// *generating the variable percentiles and quantiles */ 
gen p = sum(ps)
gen q = pcexp
list, sep(0)

//*Q3.3 Drawing Cumulative Distribution Curve
line  p pcexp, title(The cumulative distribution curve) xtitle(The per capita expenditure (y)) ytitle(F(y)) 

//*Q3.4 Plotting Quantile Curve
line  q p , title(The quantile curve)   xtitle(the percentile (p))  ytitle(The quantile Q(p))

//*Q 3.5 Plotting Quantile Curve using DASP
c_quantile pcexp, hsize(hhsize)

//*Q 3.6 Drawing Density Curves using DASP*/

cdensity pcexp, sex


 

