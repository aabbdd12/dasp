*************10.5%

//Stata code for the Assignment Weeks 1&2

//Stata code for exercise 1******4%
//  Q1.1: 
clear
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
	12	3	338		2
	13	3	330		3
	14	3	336		4
end



/* Generating variable the variable per capita income */ 
gen pcinc = income/hhsize

//  Q1.2: 
/* Estimating the average per capita income */ 
sum pcinc [aw=hhsize]

/* Estimating the total income of population*/ 
sum income [aw=hhsize]
egen sumincome = sum(income)
sum sumincome [aw=hhsize]

//  Q1.3: 
gen     pline = 120
gen     pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
sum     pgap [aw=hhsize]

//  Q1.4:
ifgt pcinc, pline(120) alpha(1) hsize(hhsize)

//  Q1.5:
gen     deflator = 1
replace deflator = 1.15 if region == 2
replace deflator = 1.20 if region == 3
gen     rpcinc = pcinc/deflator

// Q1.6
sum rpcinc [aw=hhsize]
replace pline = 130
replace pgap  = (pline-rpcinc)/pline if (rpcinc < pline)
sum     pgap [aw=hhsize]
ifgt    rpcinc, pline(130) alpha(1) hsize(hhsize)


 
//Stata code for exercise 2******1.5%
clear
input period	income hhsize	na
1		29	4	2
1		50	3	2
1		36	4	3
2		30	4	2
2		48	3	3
2		46	5	2
end

/* Generating the Per Capita INCome variables */ 
gen pcinc = income/hhsize


/* Estimating the average Per Capita INCome: period 1 */ 
sum pcinc [aw=hhsize] if period == 1

/* Estimating the average per capita income: period 2 */ 
sum pcinc [aw=hhsize] if period == 2

/* Generating the Adult Equivalent Size and the Adult Equivalent INCome */
gen aes = 1 + 0.6 * (na-1) + 0.4 * (hhsize-na) 
gen aeinc = income/aes

/* Estimating the average per adult-equivalent income: period 1 */ 
sum  aeinc [aw=hhsize]  if period == 1

/* Estimating the average per adult-equivalent income: period 2 */ 
sum  aeinc [aw=hhsize]  if period == 2



//Stata code for exercise 3***5%
clear
use "C:\Users\kongchheng.poch\Documents\KC Training\PEP MAPI_20210118\MAPI_M2\Assignment W1-2\data_3.dta"

// Q3.1
/* computing the population size of the sampled households */ 
svydes
/*Population size is 4,000,000 households (2,000 PSU x 2,000 Obs)*/

// Q3.2
/* sorting the data by the per capita expenditures */ 
sort pcexp

/* generating the variable of the proportion of popultion */
sum hhsize
gen ps = hhsize/r(sum)

/* generating the variable percentile and the quantiles */ 
gen p = sum(ps)
gen q = pcexp
list, sep(0)

// Q3.3
#delimit ;
line pcexp p if p <= 0.9, title(The cumulative distribution curve) xtitle(The percentile (p)) ytitle(The per capita expenditures);

// Q3.4
#delimit ;
line q p if p <= 0.9, title(The quantile curve)  xtitle(The percentile (p))  ytitle(The quantile Q(p));

// Q3.5
c_quantile pcexp, hgroup(zone) min(0.0) max(0.9) title(The Quantile Curves);

// Q3.6
cdensity pcexp, hgroup(sex) min(0) max(800000) xtitle(The per capita expenditures) title(The Density Curves);

