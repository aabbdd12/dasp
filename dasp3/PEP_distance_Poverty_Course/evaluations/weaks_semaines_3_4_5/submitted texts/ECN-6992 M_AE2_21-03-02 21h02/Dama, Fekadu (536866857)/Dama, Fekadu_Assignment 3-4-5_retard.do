77777777777777777777777777777777777777777777777777777777777777*****12%
set more off

*Exam 2

*Exercis 1********4%

*Inputing data to confirm that income inequality in groups 1 and 2 are similar, based on scale invariance principle

*(a) inputing data

input group inc1 inc2 inc3
1 1 8 2
1 2 8 4
1 9 8 18
2 3 24 2
2 6 24 4
2 27 24 18
end
* Question 1. Estimating Gini by population groups (groups 1 and 2) using the DASP command dentropyg to estimate between groups inequality
*Question 1.1

*Checking if, according to scale invariance principle, the income inequality of group1 is equal to that of group 2. We look at it by using data from the three periods (inc1, inc2, inc3)

dentropyg inc1, hgroup(group) theta (0)
dentropyg inc2, hgroup(group) theta (0)
dentropyg inc3, hgroup(group) theta (0)

*(b) checking if the income inequality of group1 is equal to that of the total population, for example, by using the igini DASP command

igini inc1, hgroup(group)
igini inc2, hgroup(group)
igini inc3, hgroup(group)


*(c)The between group inequality of inc1 is equal to that of inc2. This can be checked by using the dentropyg DASP command (for instance, for theta=0). 

/*Comment: be more explicit on why inequality of inc1 is equal to that of inc2. The detail answer should be: 
This affirmation is true:
 - With the inc1, the between group inequality is the inequality of the distribution: D1: (4,4,4,12,12,12)
 - With the inc2, the between group inequality is the inequality of the distribution: D2: (8,8,8,24,24,24)
Based on the scale invariance principle (the distribution D2 is simply that of the double of the incomes of D1),
The between group inequality in inc1 is therefore similar to that of inc2.*/

dentropyg inc1, hgroup(group) theta (0)
dentropyg inc2, hgroup(group) theta (0)

*Question 

*Question 1.2: decomposing the entropy index (the parameter theta = 0) using the DASP command dentropyg

dentropyg inc1, hgroup(group) theta (0)
dentropyg inc2, hgroup(group) theta (0)
dentropyg inc3, hgroup(group) theta (0)

*Question 1.3. Estimating the Gini inequality of each of the three distributions with the igini DASP command

igini inc1 inc2 inc3

*Exercise 2****5%

*Using Stata, Inputing the data using STATA and then generating the variables

input identifier pre_tax_income hhsize nchild
1 240 4 2
2 600 5 3
3 230 3 2
4 1250 3 1
5 1900 4 1
6 280 4 2
7 620 3 1
8 880 4 3
end
*generating per capita post-tax income with scenario A

gen pcincatA = pre_tax_income * (1-0.1)/hhsize


*generating per capita post-tax income with scenario B

gen pcincatB = pre_tax_income * (1-0.1)/hhsize


*generating per capita universal income with scenario A

*the total volume of univeral income is 0.6*0.1* total pre_tax_income (= 6000) = 0.6*0.1*6000 = 360

*per capita universal income (pcui)

scalar pcui = 0.6*0.1*6000/30

gen pcuincA = pcui*hhsize

*Under scenario B, there is no allocation for universal income, so the value is zero

gen pcuincB = 0

*generating per capita child allowance with scenario A. The total volume of child allowance is 0.4*0.1*6000. Per capita child allowance (pc_child_all) is total child allowance divided by total number of children.

scalar pc_child_allA = 0.4*0.1*6000/15

*per capita child allowance equals to total_child_all divided by total number of children

gen pcallowA = pc_child_allA*nchild

*generating per capita child allowance with scenario B

scalar pc_child_allB = 0.1*6000/15

gen pcallowB = pc_child_allB*nchild

*generating per capita disposable income with the scenario A (pcincatA+ pcuincA+ pcallowA)

gen dpcincA = pcincatA + pcuincA + pcallowA

*generating per capita disposable income with the scenario B

gen dpcincB = pcincatB+ pcuincB + pcallowB

*question 2.2. Estimating the inequality in the distribution of the per capita disposable income for each of the two scenarios using DASP command igini

igini dpcincA dpcincB

*Question 2.3. decomposing inequality: Using DASP command diginis

diginis pcincatA pcuincA pcallowA 
diginis pcincatB pcuincB pcallowB

*question 2.4 no STATA command needed

*question 2.5 Estimating the change in the headcount related to the program B (with respect to the initial distribution) when the poverty line is 100

*generate per capita income without putting the policy measures in place

gen pcinc = pre_tax_income/hhsize

difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(0)

*Question 2.6. Estimate the change in the poverty gap related to the program B (with respect to the initial distribution) when the poverty line is 100 (use the DASP command difgt). Discuss the found results in 2.5 and 2.6

difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(1) 

/*Comment: The households that receive child allowances have some improvement in well-being, but this improvement is not enough to make them escape poverty. This is what explains the unchanged level of headcount. In the inverse, the poverty gap index is sensitive to any improvement in the well-being of the poor, and this explains the reduction of this index.*/



*Exercise 3*****3%

use "data_1.dta", replace

*Question 3.1. initialize the sampling design with the variables strata, psu and sweight.

svyset psu [pweight=sweight], strata(strata)

*Question 3.2 Using the DASP ifgt command, estimate the headcount when the measurement of well-being is the adult equivalent expenditures, and when the poverty line is equal to 21 000.

ifgt ae_exp, pline(21000) hs(hsize)

*Question 3.3. estimating headcount poverty by population groups (defined by the sex of the household head)

 ifgt ae_exp, pline(21000) hs(hsize) hgroup(sex)
 
 *testing if the difference between the two groups is significant. We can use the following command to see if the difference is significant: 

difgt ae_exp ae_exp, alpha(0) hsize1(hsize) test(0) cond1(sex==1) hsize2(hsize) cond2(sex==2) pline(21000) pline(21000)












