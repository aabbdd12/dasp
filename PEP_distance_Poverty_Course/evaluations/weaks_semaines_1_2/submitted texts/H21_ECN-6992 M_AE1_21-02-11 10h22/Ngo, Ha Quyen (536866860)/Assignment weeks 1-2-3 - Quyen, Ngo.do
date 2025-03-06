*********************11.5%


// WEEKS 1-2-3 ASSIGNMENT

set more off

// EXERCISE 1 ==================================================================
clear
/* Inserting the data *************4%*/ 
clear
input 	hhid 	region income hhsize
	1	1	210		4
	2	1	450		6
	3	1	300		5
	4	1	210		3
	5	2	560		2
	6	2	400		4
	7	3	140		4
	8	3	250		2
	9	3	340		2
	10	3	220		2
	11	3	360		3
	12	3	338		2
	13	3	330		3
	14	3	336		4
end

// Q1.1:
/* Generating per capita income variable */ 
gen pcinc = income/hhsize

// Q1.2:
/* Estimating the average per capita income */
sum pcinc [aw=hhsize]

// Q1.3:
/* Estimating the average poverty gap */
gen     pline = 120
gen     pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
sum     pgap [aw=hhsize]

// Q1.4:
ifgt pcinc, pline(120) alpha(1) hsize(hhsize)

// Q1.5:
/* Generating real per capita income */ 
gen     deflator = 1
replace deflator = 1.15 if region == 2
replace deflator = 1.2 if region == 3
gen     rpcinc = pcinc/deflator

// Q1.6:
/* Estimating the average of real per capita income */
sum rpcinc [aw=hhsize]

/* Redo Q1.3 */
replace	pline = 130
replace pgap = 0
replace pgap = (pline-rpcinc)/pline if (rpcinc < pline)
sum     pgap [aw=hhsize]

/* Redo Q1.4 */
ifgt rpcinc, pline(130) alpha(1) hsize(hhsize)


// EXERCISE 2 ===============================================================2.5%
clear
/* Inserting the data */ 
clear
input	hhid	period	income	hhsize	na
	1	1	29	4	2
	2	1	50	3	2
	3	1	36	4	3
	1	2	30	4	2
	2	2	48	3	3
	3	2	46	5	2
end

// Q2.1:
/* Generating per capita income variable */ 
gen pcinc = income/hhsize

/* Estimating the average Per Capita Income: period 1 */ 
sum pcinc [aw=hhsize] if period == 1

/* Estimating the average per capita income: period 2 */ 
sum pcinc [aw=hhsize] if period == 2


/* Generating the Adult Equivalent Size and the Adult Equivalent Income */
gen aes = 1 + 0.6 * (na-1) + 0.4 * (hhsize-na) 
gen eainc = income/aes

/* Estimating the average per adult-equivalent income: period 1 */ 
sum  eainc [aw=hhsize]  if period == 1

/* Estimating the average per adult-equivalent income: period 2 */ 
sum  eainc [aw=hhsize]  if period == 2

	
// EXERCISE 3 ================================================================5%
clear

/* Seting directory */
global input " " //to add the URL to the data location here

/* Importing data */	
use "$input\data_3.dta", clear
	
// Q3.1:
/* Computing the population size */
total hhsize

// Q3.2:
/* Sorting the data by per capita expenditure */ 
sort pcexp

/* Generating the variable of the proportion of population */
sum hhsize
gen ps = hhsize/r(sum)

/* Generating the variable percentile and the quantiles */ 
gen p = sum(ps)
gen q = pcexp
list, sep(0)

// Q3.3:
/* Drawing the cumulative distribution curve */
line pcexp p, title(The cumulative distribution curve) ///
			ytitle(The per capita expenditure) xtitle(F(y)) ///
			xscale(range(0 0.9)) xlabel(0 (0.1) 0.9)

// Q3.4:
/* Plotting the quantile curve */
line  q p , title(The quantile curve) ///
			xtitle(the percentile (p)) ytitle(The quantile Q(p)) ///
			xscale(range(0 0.9)) xlabel(0 (0.1) 0.9)
			
// Q3.5:
/* Drawing the quantile curve for the rural and urban regions using DASP */
c_quantile pcexp, hsize(hhsize) hgroup(zone) min(0) max(0.9)

// Q3.6:
/* Drawing the density curve using DASP */
cdensity pcexp, hsize(hhsize) hgroup(sex) min(0) max(800000)








	
