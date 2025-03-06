************12,5%

clear
set more off

cap log close

** Do file to answer Assignment 1,2,3 

cd "C:\Users\ThinkPad\Dropbox (MASSA)\PEP Online Course\ECN-6992 Measuring and Alleviating Poverty and Inequality\Evaluation\Exercise Course 1, 2 and 3\Diego\phase2\"

/*=============================================================================
						EXERCISE 1*****4%
==============================================================================*/

clear
import excel "exercise_data_book.xlsx", sheet("exerc1") firstrow

** --> Q1.1
gen pcinc=income/hhsize

** --> Q1.2
sum pcinc [aw=hhsize]

gen totalincome=sum(income)

** --> Q1.3
gen pline=120
gen pgap=0
replace pgap=(pline-pcinc)/pline if pline>pcinc
sum pgap [aw=hhsize]

** --> Q1.4
ifgt pcinc, pline(120) alpha(1) hsize(hhsize)

** --> Q1.5
gen     deflator = 1
replace deflator = 1.15 if region == "B"
replace deflator = 1.2 if region == "C"
gen     rpcinc = pcinc/deflator


** --> Q1.6
* --> 
replace pline=130
replace pgap=0
replace pgap=(pline-rpcinc)/pline if pline>rpcinc

sum pgap [aw=hhsize]

* --> 
ifgt rpcinc, pline(130) alpha(1) hsize(hhsize)


/*=============================================================================
						EXERCISE 2  3%
==============================================================================*/

import excel "exercise_data_book.xlsx", sheet("exerc2") firstrow clear

* --> Per capita Income (Household level)
gen pcinc = income/hhsize

** --> Average per capita income (Period 1)
sum pcinc [aw=hhsize] if period == 1

** --> Average per capita income (Period 2)
sum pcinc [aw=hhsize] if period == 2

** --> Adult Equivalent size & Adult Equivalent Income
gen aes = 1 + 0.6*(na - 1)+ 0.4*(hhsize-na)
gen eainc = income/aes

** --> Average per adult-equivalent income (Period 1)
/* Estimating the average per adult-equivalent income: period 1 */
sum eainc [aw=hhsize] if period == 1

** --> Average per adult-equivalent income (Period 2)
sum eainc [aw=hhsize] if period == 2



/*=============================================================================
						EXERCISE 3*********5.5%
==============================================================================*/

use "data_3", clear

* --> Q3.1
	// Note: I guess weight variable is missing to compute estimated population size.

* --> Q3.2
		* Rank per capital expenditure
sort pcexp

		* Population share (ps)
sum hhsize
gen ps = hhsize/r(sum)

		* Percentile (p)
gen p = sum(ps)

		* Quantiles (q)
gen q = pcexp


* --> Q3.3
line  p pcexp if inrange(p,0,0.90), title(The cumulative distribution curve) xtitle(Per capita expenditure) ytitle(Percentiles)
graph export "ppcexp.png", as(png) name("Graph") replace


* --> Q3.4
line  q p if inrange(p,0,0.90), title(The quantile curve) xtitle(Percentile (p))  ytitle(Quantile Q(p))
graph export "lineqp.png", as(png) name("Graph") replace

* --> Q3.5
sort zone
c_quantile pcexp, hsize(hhsize) hgroup (zone) max(0.90)
graph export "c_quantile.png", as(png) name("Graph") replace

* --> Q3.6

cdensity pcexp, hsize(hhsize) hgroup(sex) type(den) min(0) max(800000) xtitle(Per capital expenditure)
graph export "densitycurve.png", as(png) name("Graph") replace
log close

