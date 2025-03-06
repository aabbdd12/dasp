****************12,5%



*Exercice 1******4%

/* Inserting the data */ 
clear
input 	group inc1 inc2 inc3
1	1	8	2
1	2	8	4
1	9	8	18
2	3	24	2
2	6	24	4
2	27	24	18
end

/* Q1.1A estimate the Gini index by population group */ 
igini group*
/* alternatively, which should produce the same result */
igini group, hgroup(group)

/* Inserting the data */ 
clear
input 	group inc1 inc2 inc3
1	1	8	2
1	2	8	4
1	9	8	18
2	3	24	2
2	6	24	4
2	27	24	18
end

/* Q1.1C estimate the Gini index by population group */ 
dentropyg inc1, hgroup(group) theta(0)
dentropyg inc2, hgroup(group) theta(0)

/* Q1.2A estimate the Gini index by population group */ 
dentropyg inc1, hgroup(group) theta(0)
dentropyg inc2, hgroup(group) theta(0)
dentropyg inc3, hgroup(group) theta(0)

/* Q1.3 estimate the Gini index by population group */ 
igini inc*

// Question 2*****5,5%
clear

/* Inserting the data */
input identifier pre_tax_income  hhsize nchild
1 240  4 2
2 600  5 3
3 230  3 2
4 1250 3 1
5 1900 4 1
6 280  4 2
7 620  3 1
8 880  4 3
end

/* Q2.1A
Given a 10% income tax for Scenario A and B
post_tax_income= pre_tax_income*(1-0.1)
To compute the per capita post_tax_income (pcincatA and pcincatB), we divide by the household size.
*/
gen pcincatA = pre_tax_income * (1.00-0.1)/hhsize
gen pcincatB = pre_tax_income * (1.00-0.1)/hhsize

/*
The collected tax revenue in scenario A is 10% of the total incomes: 0.1*6000
60% of the collected tax revenue as guaranteed universal income implies: (0.6*0.1*6000)
Across total population of 30 implies: 0.6*0.1*6000/30
The command scalar to be used for guaranteed universal income is guaranteed_inc_A.
Therefore, stata command for guaranteed_inc_A is equal to (0.6*0.1*6000/30) 
*/
scalar guaranteed_inc_A = 6000*0.1*0.6/30

/*
Since the guaranteed universal income for scenario B is equal to zero 
*/
scalar guaranteed_inc_B = 0

/* generating per capita guaranteed univeral income (pcuincA and pcuincB) */ 
gen pcuincA = hhsize*guaranteed_inc_A/hhsize
gen pcuincB = hhsize*guaranteed_inc_B/hhsize

/*
The collected tax revenue in scenario A is 10% of the total incomes: 0.1*6000
60% of collected tax revenue is meant to be used for guaranteed universal income and the rest as child allowance implies (1-0.6=0.4): 0.4*0.1*6000
We have 15 children in our population. Therefore, the child allowance is equal to: (0.04*0.1*6000)/15
The command scalar to be used for child allowance is child_all_A.
Therefore, stata command for child_all_A is equal to (0.04*0.1*6000)/15.  
*/
scalar child_all_A = 6000*0.1*0.04/15

/*
The collected tax revenue in scenario B is 10% of the total incomes: 0.1*6000
We have 15 children in our population. Therefore, the child allowance is equal to: (0.1*6000)/15 given that guaranteed universal income is zero
The command scalar to be used for child allowance is child_all_B.
Therefore, stata command for child_all_B is equal to (0.1*6000)/15  
*/
scalar child_all_B = 6000*0.1/15

/* generating per capita child allowances (pcallowA and pcallowB) */ 
gen pcallowA = nchild*child_all_A/hhsize
gen pcallowB = nchild*child_all_B/hhsize

/*
Recall that the per capita disposable income is equal to the per capita pre_tax_income plus the guaranteed universal income plus the per capita child allowances
*/
gen dpcincA = pcincatA + pcuincA + pcallowA
gen dpcincB = pcincatB + pcuincB + pcallowB

/* Q2.2 generate the total income inequality */ 
igini dpcincA dpcincB , hsize(hhsize)

/* Q2.3 decomposing income inequality for all the scenarios */ 
diginis pcincatA  pcuincA  pcallowA, hsize(hhsize)
diginis pcincatB  pcuincB  pcallowB, hsize(hhsize)

/* Q2.5 generating the per capita income without applying any program */
gen pcinc = pre_tax_income/hhsize
/* poverty headcount */
difgt dpcincB pcinc, hsize1(hhsize)  hsize2(hhsize) pline1(100) pline2(100) alpha(0)

/* Q2.6 change in poverty gap */
difgt dpcincB pcinc, hsize1(hhsize)  hsize2(hhsize) pline1(100) pline2(100) alpha(1)

// Question 3********3%
clear
use "data_prac.dta" , replace

/* Q3.1
Using the svyset command we can initialize the sampling design of the data file.
*/
svyset psu [pweight=sweight], strata(strata)

/* Q3.2 estimate the headcount when the measurement of well-being is the adult equivalent expenditures
and when the poverty line is equal to 21000
*/
ifgt ae_exp, pline(21000) hs( hsize)

/* Q3.3 estimate headcount poverty by population groups defined by sex of the household */
ifgt ae_exp, pline(21000) hs( hsize) hgroup(sex)
