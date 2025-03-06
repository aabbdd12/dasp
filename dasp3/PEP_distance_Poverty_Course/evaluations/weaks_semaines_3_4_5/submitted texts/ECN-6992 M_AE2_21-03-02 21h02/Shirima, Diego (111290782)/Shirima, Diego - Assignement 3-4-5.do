********************************11,5%
cls
clear
set more off
// net from http://dasp.ecn.ulaval.ca/modules/DASP_V2.3/dasp
// net install dasp_p1, force
// net install dasp_p2, force
// net install dasp_p3, force
// net install dasp_p4, force

cap log close

cd "Diego\Phase2\"

log using "Summary.smcl", replace
** Do file to answer Assignment 4,5,6 

/*=============================================================================
						EXERCISE 1        4%
==============================================================================*/
import excel exercises_tables.xlsx, sheet("exercise1") firstrow clear

*--> Question 1.1a
igini inc*
		** --> FALSE;	Because the mean difference of income inequality between first group and second group is different. While using Gini index, we found the estimate between the group vary, hereby we observe estimate of 0.500000, 0.166667 and 0.444444 for inc1, inc2 and inc3 respectively.


** Question 1.1c
dentropyg inc1, hgroup(group) theta(0)
dentropyg inc2, hgroup(group) theta(0)
		** --> YES;	Because the absolute contribution between the group group inequality is the same for inc1 and inc2.

** Question 1.2
forvalues i=1/3 {
dentropyg inc`i', theta(0) hgroup(group)
}

** Question 1.3
igini inc*
		** --> The income distribution is 50%, 16% and 44% for inc1, inc2 and inc3 respectively. This means inc1 individual receives more percentage of total income in the population.

/*=============================================================================
						EXERCISE 2    4,5%
==============================================================================*/
import excel exercises_tables.xlsx, sheet("exercise2") firstrow clear
drop if inlist(identifier,"","Total")
destring identifier, replace

** Question 2.1
gen	pcincatA = pre_tax_income * (1.00-0.1)/hhsize
gen	pcincatB = pre_tax_income * (1.00-0.1)/hhsize

gen pcuincA = pre_tax_income * ((1.00-0.9)*0.6)/hhsize
gen pcuincB = 0

scalar  child_all_A  = ((12000*0.1)*0.4)/15
scalar  child_all_B  = 12000*0.1/15

gen 	pcallowA = nchild*child_all_A/hhsize
gen 	pcallowB = nchild*child_all_B/hhsize

gen dpcincA= pcincatA + pcuincA + pcallowA
gen dpcincB= pcincatB + pcuincB + pcallowB

** Question 2.2
igini dpcincA dpcincB , hsize(hhsize)

** Question 2.3
diginis pcincatA  pcallowA, hsize(hhsize) 
diginis pcincatB  pcallowB, hsize(hhsize)

** Question 2.4
		** --> Case A is the mostly likely to reduce inequality in disposable income, since it has highest absolute contribution than case B. It gives contribution to both universal income of individual household and child allowance.

** Question 2.5
difgt dpcincB dpcincA, alpha(1) hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100)
		** --> Estimate change in the headcount is 0.79%

** Question 2.6
difgt dpcincB dpcincA, alpha(1) hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100)
		** --> Estimate change in povery gap is 5.5%
		
/*=============================================================================
						EXERCISE 3   3%
==============================================================================*/

use "data_3.dta", clear

** Question 3.1
svyset psu [pweight=sweight], strata(strata)

** Question 3.2 
ifgt ae_exp, pline(21000) hs(hsize) 

** Question 3.3
ifgt ae_exp, pline(21000) hs(hsize) hgroup(sex) 
		** --> For a given poverty line, majority of female are poorer than male.
