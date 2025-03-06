**************************10.5%

//Stata Code for Practical excersise 


set more off

clear all

*Exercise 1************3%

*Inputting data*
input identifier	region	income	hhsize
1	1	310	4
2	1	460	6
3	1	300	5
4	1	220	3
5	2	560	2
6	2	400	4
7	3	140	3
8	3	250	2
9	3	340	2
10	3	220	2

end

// Q1.1

/* Generating variable the variable per capita income */ 
gen pcinc = income/hhsize

//  Q1.2: 

/* Estimating the average per capita income */ 
sum pcinc [aw=hhsize]

/*Estimating the total incomes */
total income

//  Q1.3: 

/*generating a new variable per capita poverty gap(pgap)assuming poverty line is equal to 120*/
gen     pline = 120
gen     pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
/*estimating the average poverty gap*/
sum     pgap [aw=hhsize]

//  Q1.4: *using DASP*
ifgt pcinc, pline(120) alpha(1) hsize(hhsize)


//  Q1. 5

/*generating a deflator*/*************************/* Comment: mistake in the deflator*/
gen     deflator = 1                    /*should be: */
replace deflator = 0.80 if region == 2          /* deflator = 1.2 if region == 2 */
replace deflator = 0.60 if region == 3         /* deflator = 1.4 if region == 3 */

/*generating a variable real per capita income(rpinc)*/ 
gen     rpcinc = pcinc/deflator


// Q1. 6

/*re-doing question 1.3 and 1.4 using real per capita income when the poverty line is 110*/

sum rpcinc [aw=hhsize]
replace pline = 110
replace pgap  = (pline-rpcinc)/pline if (rpcinc < pline)
sum     pgap [aw=hhsize]
ifgt    rpcinc, pline(110) alpha(1) hsize(hhsize)
 
**Question 2***********2.5%

use "C:\Users\Hp User\Downloads\data_2.dta", clear 

// Q2.1

/*Estimating Average per adult eqaivalent expenditure*/
sum ae_exp [aw=hhsize]
imean ae_exp, hsize(hhsize) /*The statistic is the average household welafe taking into account or adujusting for individual differences such as age and gender and also the economies of scale */

*Comment: /*imean ae_exp // This statistic can be refered to the sampled households./


// Q2.2 

/*Initializing sampling design*/
svyset psu [pweight=sweight], strata(strata) vce(linearized) singleunit(missing)
svydes
gen fweight = sweight*hhsize
/*Estimating average per adult equivalent expenditure*/
sum  ae_exp [aw=fweight]

/*Comment: Better use this comment imean ae_exp , hsize(hhsize) directly*/

//Q2.3 

/*Estimating average expenditure by region*/
imean ae_exp, hsize(hhsize) hgroup(region)

/*Doubling the estimated expenditure in region3*/
di 2*21073.082031

/*Testing if 50474.214844 is greater than 42146.164*/
datest 42146.164, est(50474.214844) ste(2973.246582)

//Q2.4 

/*Testing whether AE expenditure is higher for male than the female*/
dimean ae_exp ae_exp, hsize1(hhsize) test(0) cond1(sex==1 ) hsize2(hhsize) cond2(sex==2 )
/*Brief discussion: This dasp command estimates three  test. 1 whether the differences between means of males and females is lower that zero 2. the difference between means of men and females is equal to 0 and lastly the difference betwween means of males and females is greater than zero. Our interest is on the the estimates 3 that is to see if the diffrence between means of men is greater that the means for women. From the results, we see that at P-value of 0.3672 we fail to reject the null hypothesis that the difference between males and females means is greater than 0.*/

**Excersise 3*******************5%

// Q3.1

use "C:\Users\Hp User\Downloads\data_2.dta", clear


// 3.1
/* to calculate population size of sampled households*/
count
sum psu /*both these show the number of the observations to be 2,000*/


//3.2
gen fweight = sweight*hhsize
// Step 1- Ranking percapica expenditure in ascending order
sort pcexp 
list pcexp
// step 2- generating populations share (ps)
sum pcexp [aw=fweight]
gen  ps  = fweight*pcexp
sum pcexp [aw=fweight]
replace  ps  =  ps/r(sum) 


// Step 3- generating the variable percentile and the quantiles */ 
gen p = sum(ps)
gen q = pcexp
list, sep(0)


//Q3.3
line  p pcexp /*if p<0.95,*/, title(The cumulative distribution curve) xtitle(The per capita expenditure (y)) ytitle(F(y))

//Q3.4 
line  q p /*if p<0.95,*/, title(The quantile curve)   xtitle(the percentile (p))  ytitle(The quantile Q(p))

// Q 3.5
db c_quantile
c_quantile pcexp, hsize(hhsize) hgroup(zone) min(0.0) max(0.95)
 
 //Q 3.6
 db cdensity
cdensity pcexp, hsize(hhsize) hgroup(zone) popb(1) type(den) min(0) max(1000000)