***************11%


//do file for Assignment weeks 1&2 Helmis Cárdenas
//Assessment exercise 1*********4%
clear
log using "E:\PEP_Laval\PEP_2021_Course\Stata\Assessment weeks 1_2 Helmis Cardenas Salida.log" , replace

/* Inserting the data */ 
clear
input 	hhid 	region income hhsize
	1	1 	210 	4
	2	1   450 	6
	3	1 	300 	5
	4	1 	210 	3
	5	2 	560 	2
	6	2 	400 	4
	7	3	140		4
	8	3	250		2
	9	3	340		2
	10	3	220		2
	11	3	360		3
	12	3	338		3
end

//*  Q1.1: per capita income in Stata */
gen pcinc = income/hhsize
/* Q1.2: Average per capita income and total income */
sum pcinc [aw=hhsize]
egen suminc = sum(income)
display suminc

//*Q1.3 poverty gap and average pgap */
gen     pline = 100
gen     pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
sum     pgap [aw=hhsize]

//*Q1.4 pgap using DASP */
ifgt pcinc, pline(100) alpha(1) hsize(hhsize)

//* Q1.5 Real per capita income based on Region A price index */
gen     deflator = 1
replace deflator = 1.1 if region == 2
replace deflator = 1.3 if region == 3
gen     rpcinc = pcinc/deflator

//* Q1.6 Poverty gap and average gap by using rpinc and PL = 120 */
sum rpcinc [aw=hhsize]
replace pline = 120
replace pgap  = (pline-rpcinc)/pline if (rpcinc < pline)
sum     pgap [aw=hhsize]
//* pgap by using DASP */
ifgt rpcinc, pline(120) alpha(1) hsize(hhsize)
clear

//* Assessment exercise 2 ******2.5%
//* Q2.1 Aes_per adult without sw */
use "E:\PEP_Laval\PEP_2021_Course\Stata\data_1.dta"
imean ae_exp, hsize(hhsize)

//* Q2.2 CASE1: Aes_per adult initializing with strata only */
 svyset _n, strata(strata) vce(linearized) singleunit(missing)
 save "E:\PEP_Laval\PEP_2021_Course\Stata\datai_Case1_Strata.dta", replace
 use "E:\PEP_Laval\PEP_2021_Course\Stata\datai_Case1_Strata.dta" 
imean ae_exp, hsize(hhsize)
 
//* Q2.2 CASE2: Aes_per adult initializing with psu only */
 use "E:\PEP_Laval\PEP_2021_Course\Stata\data_1.dta"
 svyset psu, vce(linearized) singleunit(missing)
 save "E:\PEP_Laval\PEP_2021_Course\Stata\datai_Case2_PSU.dta", replace
 use "E:\PEP_Laval\PEP_2021_Course\Stata\datai_Case2_PSU.dta" 
imean ae_exp, hsize(hhsize)
 
 //* Q2.2 CASE3: Aes_per adult initializing with strata and PSU */
 use "E:\PEP_Laval\PEP_2021_Course\Stata\data_1.dta"
 svyset psu, strata(strata) vce(linearized) singleunit(missing)
 save "E:\PEP_Laval\PEP_2021_Course\Stata\datai_Case3_Strata_PSU.dta", replace
 use "E:\PEP_Laval\PEP_2021_Course\Stata\datai_Case3_Strata_PSU.dta"
imean ae_exp, hsize(hhsize)

//* Q2.2 CASE4: Aes_per adult initializing with strata, PSU and sw */
  use "E:\PEP_Laval\PEP_2021_Course\Stata\data_1.dta"
  svyset psu, strata(strata) weight(sweight) vce(linearized) singleunit(missing)
 save "E:\PEP_Laval\PEP_2021_Course\Stata\datai_Case4_Strata_PSU_sw.dta", replace
 imean ae_exp, hsize(hhsize)
 
//* Q2.3 Test whether avg ae_exp for region 1 is higher than the double of that of region3 */
gen ae_expr1 = ae_exp if region==1
gen ae_expr3 = ae_exp if region==3
gen ae_expr3d = (ae_expr3) * 2

ttest ae_expr1 == ae_expr3d, unpaired unequal 
 
//* Q2.4 By using dimean command, test whether avg ae_exp for male HH is higher than of female ones */
dimean ae_exp ae_exp, hsize1(hhsize) test(0) cond1(sex==1 ) hsize2(hhsize) cond2(sex==2 ) conf(ub)

 
  //Assessment exercise 3 *****5%
//* Q3.1 Population size of the sampled hh: Pending */
sum hhsize
gen popsize = 2000*7.347

//*Q3.2 generating percentiles (p) and quantiles (q) */
/* The variable pcexp is already in the data*/ 
/* sorting the data by the per capita expenditure */ 
sort pcexp

/* generating the variable of the proportion of population */
sum hhsize
gen ps = hhsize/r(sum)

/* generating the variable percentile and the quantiles */ 
gen p = sum(ps)
gen q = pcexp
**list, sep(0)

#delimit ;
//* Q3.3 Drawing the cumulative distrubution curve */
line  p pcexp, title(The cumulative distribution curve) xtitle(The per capita expenditure (y)) ytitle(F(y));

#delimit ;
//* Q3.4 Plotting the quantile curve */
line  q p , title(The quantile curve)   xtitle(the percentile (p))  ytitle(The quantile Q(p));

#delimit ;
//* Q3.5 Quantile curve for urban and rural regions, using DASP */ 
c_quantile ae_exp, hsize(hhsize) hgroup(zone) min(0.0) max(0.95);

#delimit ;
//* Q3.6 Density curve by sex of the household, using DASP */
cdensity ae_exp, hsize(hhsize) hgroup(sex) popb(1) min(0) max(1000000);

