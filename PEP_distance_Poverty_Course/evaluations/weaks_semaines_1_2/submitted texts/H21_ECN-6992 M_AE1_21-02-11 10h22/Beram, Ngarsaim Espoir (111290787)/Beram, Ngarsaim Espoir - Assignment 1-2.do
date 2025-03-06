****************11.5%


//Stata code for Assignment weeks 1 and 2
// Excercise 1******************3.5%
clear
/* Inserting the data */ 
clear
input 	hhid 	region income hhsize
	1	1 	210     4
	2	1   450 	6
	3	1 	300 	5
	4	1 	210 	3
	5	2 	560 	2
	6	2 	400 	4
	7   3   140     4
	8   3   250     2
	9   3   340     2
	10  3   220     2
	11  3   360     3
	12  3   338     3
end

// Q1.1
/* Generating per capita income (pcinc) */
gen pcinc=income/hhsize

// Q1.2
/* Estimating the average per capita income and the total incomes of our population */
sum pcinc [aw=hhsize]
total income

// Q1.3
/* Generating the variable "per capita poverty gap (pgap)" assuming that the poverty line is equal to 100 and estimating its average */
gen pline=100
gen pgap=0
replace pgap=(pline-pcinc)/pline if (pcinc<pline)
sum pgap [aw=hhsize]

// Q1.4
/* Redoing question 1.3 using DASP */
ifgt pcinc, pline(100) alpha(1) hsize(hhsize) 

// Q1.5
/* Generating the variable real per capita income (rpcinc) */
gen deflator=1
replace deflator=0.9 if region==2 /*replace deflator=1.1 if region==2*/
replace deflator=0.7 if region==3
gen rpcinc=pcinc/deflator

// Q1.6
/* Redoing the question 1.3 and 1.4 using the real per capita income when the poverty line is 120 */
replace pline=120
replace pgap=(pline-rpcinc)/pline if (rpcinc<pline)
sum pgap [aw=hhsize]

ifgt rpcinc, pline(120) alpha(1) hsize(hhsize)

// Excercise 2************3%
clear
cd "C:\Users\HP PROBOOK\Desktop\COURS PEP_LAVAL\POVERTY\Assignment Week 1 and 2"
use data_1.dta

// 1.1
/* Estimating the average per adult equivalent expenditures without using the sampling weight and by using the DASP command imean */
imean ae_exp, hsize(hhsize) // ste=1701.506958
/*
This statistic refers to the average per adult equivalent expenditure in a simple-random sampling scheme.
*/

// 1.2
/* Estimating the average per adult equivalent expenditures */
/* Case 1: Only by using the variable strata to initialise the stratification variable of the sampled population */
svyset, strata(strata)
imean ae_exp, hsize(hhsize) // the ste (1702.926636) is larger than that of the question 1.1, case 2 and case 3. However it is lower than that of case 4.

svyset, clear
/* Case 2: Only by using the variable psu to initialise the primary sampling unit variable */
svyset psu
imean ae_exp, hsize(hhsize) // the ste(1693.014282) is the lowest one.

svyset, clear
/* Case 3: Only by using the variable strata and psu */
svyset psu, strata(strata) 
imean ae_exp, hsize(hhsize) // the ste(1699.352783) is larger than that of case 2 and lower than that of all the remaning cases including that of question 1.1.

svyset, clear
/* Case 4: Only by using the variable strata, psu and the sampling weight variable */
svyset psu [pweight=sweight], strata(strata) 
imean ae_exp, hsize(hhsize) // the ste(2213.284668) is the largest one.

// 1.3
/*  Testing whether the average per adult equivalent in region 1 is higher than the double of that of region 3 */
imean ae_exp, hsize(hhsize) hgroup(region) // mean_1=59713.667969 and mean_3=22984.812500, and ste=sqrt(ste_1^2+4*ste_3^2)

datest 0, est(13744.04297) ste(6758.71740)
// We cannot reject H0: mean_1-2*mean_3 > 0. This is because the statistical error that we make if we reject H0 = 97.90% is greater than the critical level of 5.00%.

// 1.4
/* Testing whether the average per adult equivalent expenditures for male household heads is higher than that of female households headed */

dimean ae_exp ae_exp, hsize1(hhsize) test(0) cond1(sex==2) hsize2(hhsize) cond2(sex==1 ) conf(ub)
// We cannot reject H0: difference = > 0. This is because the statistical error that we make if we reject H0 = 99.94% is greater than the critical level of 5.00%.

// Exercise 3*********5%
clear
cd "C:\Users\HP PROBOOK\Desktop\COURS PEP_LAVAL\POVERTY\Assignment Week 1 and 2"
use data_1.dta
// Q3.1
/* Computing the population size of the sampled households */
total hhsize [pw=sweight]
// The 2,000 sampled households represent a population size of 5,578,466

// Q3.2
/* sorting the data by the per capita expenditures */ 
sort pcexp

/* generating the variable of popultion share (ps) */
sum hhsize
gen ps = hhsize/r(sum)

/* generating the variable percentiles and the quantiles */ 
gen p = sum(ps)
gen q = pcexp


// Q3.3
line  p pcexp, title(The cumulative distribution curve) xtitle(The per capita expenditures (y)) ytitle(F(y)) yscale(range(0 .95))

// Q3.4
c_quantile pcexp, hsize(hhsize) min(0) max(0.95)
// 95% of households have a total expenditures of less than 400,000

// Q3.5
c_quantile pcexp, hsize(hhsize) hgroup(zone) min(0) max(0.95)
// The average per capita expenditure in urban area is greater than that in rural area 

// Q3.6
c_quantile pcexp, hsize(hhsize) hgroup(sex) yscale(range(0 1000000))
// The average per capita expenditure for female headed households is greater than that of male headed households


