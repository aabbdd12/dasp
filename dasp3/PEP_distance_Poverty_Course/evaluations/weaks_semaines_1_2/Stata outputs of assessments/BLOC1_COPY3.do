
// EXERCICE 1
// Q1

clear
/* Inserting the data */ 
clear
input 	hhid 	region income hhsize
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


/* Generating variable the variable per capita income */ 
gen pcinc = income/hhsize

/* listing the variables */
list, separator(0)

/* Estimating the average per capita income */ 
sum   pcinc [aw=hhsize]
scalar mean_inc = r(mean)

/* Estimating the total incomes of the population */ 
/* method 1 */ 
total pcinc [pw=hhsize]

/* method 2 */ 
sum hhsize
scalar pop_size = r(sum)
dis " total incomes of the population =" pop_size*mean_inc

//  Q3: 
gen     pline = 120
gen     pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
sum     pgap [aw=hhsize]

//  Q4:
ifgt pcinc, pline(120) alpha(1) hsize(hhsize)

//  Q5:
gen     deflator = 1.00
replace deflator = 0.85  if region == 2
replace deflator = 0.80 if region == 3
gen     rpcinc = pcinc/deflator

// Q6
sum rpcinc [aw=hhsize]

replace pline = 130
replace pgap  = (pline-rpcinc)/pline if (rpcinc < pline)
sum     pgap [aw=hhsize]
ifgt    rpcinc, pline(130) alpha(1) hsize(hhsize)



// EXERCICE 2
/* Inputting the panel data */ 
clear
input id period	income hhsize	na
1	1	29	4	2
2	1	50	3	2
3	1	36	4	3
1	2	30	4	2
2	2	48	3	3
3	2	46	5	2

end

/* Generating the Per Capita INCome variables */ 
gen pcinc = income/hhsize



/* Estimating the average Per Capita INCome: period 1 */ 
sum pcinc [aw=hhsize] if period == 1

/* Estimating the average per capita income: period 2 */ 
sum pcinc [aw=hhsize] if period == 2

/* Generating the Adut Equivalent Size and the Adult Equivalent INCome */
gen aes = 1 + 0.6 * (na-1) + 0.4 * (hhsize-na) 
gen eainc = income/aes

/* Estimating the average per adult-equivalent income: period 1 */ 
sum  eainc [aw=hhsize]  if period == 1

/* Estimating the average per adult-equivalent income: period 2 */ 
sum  eainc [aw=hhsize]  if period == 2


// EXERCICE 3

// Q1
clear
/* Opening the data bkf98I.dta*/ 
use "C:\Users\lutib\Dropbox\PEP_distance_Poverty Course (Exercises)\2020\evaluations\weaks_semaines 1-2-3\Stata outputs of assessments\data_3.dta" 


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
line  p pcexp if p<0.90, title(The cumulative distribution curve) xtitle(The per per capita income (y)) ytitle(F(y))
   

// Q4
line  q p if p<0.90, title(The quantile curve)   xtitle(the percentile (p))  ytitle(The quantile Q(p))


// Q5
c_quantile pcexp, hsize(hhsize) min(0) max(0.90) hgroup(zone)


// Q6
cdensity pcexp , hs(hhsize) band(25000) min(0) max(800000) hg(sex)
