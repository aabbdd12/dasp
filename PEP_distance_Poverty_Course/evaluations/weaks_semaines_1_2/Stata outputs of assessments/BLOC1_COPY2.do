
// EXERCICE 1
// Q1

clear
/* Inserting the data */ 
clear
input 	hhid 	region income hhsize
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


/* Generating variable the variable per capita income */ 
gen pcinc = income/hhsize

/* listing the variables */
list, separator(0)

/* Estimating the average per capita income */ 
sum   pcinc [aw=hhsize]
scalar mean_inc = r(mean)

/* Estimating the total incomes of the population */ 
/* method 1 */ 
total hhsize

/* method 2 */ 
sum hhsize
scalar pop_size = r(sum)
dis " The population size =" pop_size

//  Q3: 
gen     pline = 120
gen     pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
sum     pgap [aw=hhsize]

//  Q4:
ifgt pcinc, pline(120) alpha(1) hsize(hhsize)


//  Q5:
gen     deflator = 1
replace deflator = 0.8 if region == 2
replace deflator = 0.6 if region == 3
gen     rpcinc = pcinc/deflator

// Q6
sum rpcinc [aw=hhsize]

replace pline = 110
replace pgap  = (pline-rpcinc)/pline if (rpcinc < pline)
sum     pgap [aw=hhsize]
ifgt    rpcinc, pline(110) alpha(1) hsize(hhsize)


// EXERCICE 2

// Q1
clear

/* Opening the data data_2.dta*/ 
use "C:\Users\lutib\Dropbox\PEP_distance_Poverty Course (Exercises)\2020\evaluations\weaks_semaines 1-2-3\Stata outputs of assessments\data_2.dta" 
imean ae_exp // This statistic can be refered to the sampled households. 

// Q2
svyset psu [pweight=sweight], strata(strata)
imean ae_exp , hsize(hhsize)

// Q3
imean ae_exp , hsize(hhsize) hg(region)
// double of region 3 = 2*21087.664063 = 42175.328
datest  42175.328, est(49773.925781) ste(4247.191895)
// We cannot reject the H0:mean_1>   42175.328, because that the level of the error with the rejection is 96.32%

// Q4
dimean ae_exp ae_exp, hsize1(hhsize) test(0) cond1(sex==2 ) hsize2(hhsize) cond2(sex==1 )
// We cannot reject the H0:(mean_male -  mean_female)>0, because that the level of the error with the rejection is 81.56%


// EXERCICE 3

// Q1
clear
/* Opening the data bkf98I.dta*/ 
use "C:\Users\lutib\Dropbox\PEP_distance_Poverty Course (Exercises)\2020\evaluations\weaks_semaines 1-2-3\Stata outputs of assessments\data_2.dta" 
svydes


// Q2
/* sorting the data by the per capita income */ 
sort pcexp

/* generating the variable of the proportion of popultion */
sum hhsize
gen ps = hhsize/r(sum)

/* generating the variable percentile and the quantiles */ 
gen p = sum(ps)
gen q = pcexp



// Q3
line  p pcexp if p<0.95, title(The cumulative distribution curve) xtitle(The per per capita income (y)) ytitle(F(y))
   

// Q4
line  q p if p<0.95, title(The quantile curve)   xtitle(the percentile (p))  ytitle(The quantile Q(p))


// Q5
c_quantile pcexp, hsize(hhsize) min(0) max(0.95) hgroup(sex)


// Q6
cdensity pcexp , hs(hhsize) band(25000) min(0) max(1000000) hg(zone)
