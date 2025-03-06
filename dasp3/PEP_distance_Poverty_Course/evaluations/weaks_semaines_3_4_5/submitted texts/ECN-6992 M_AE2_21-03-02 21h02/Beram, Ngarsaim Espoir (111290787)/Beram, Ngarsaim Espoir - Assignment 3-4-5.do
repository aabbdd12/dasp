*********11,5%

//Stata code for Assignment weeks 3, 4 and 5
// Excercise 1*****4%
/* Inserting the data */ 
clear
input 	group 	inc1 inc2 inc3
	1	1 	8   2
	1	2   8 	4
	1	9 	8 	18
	2	3 	24 	2
	2	6 	24 	4
	2	27 	24 	18
end

// Q1.1
/* a-True because the distribution income inc1 in group2 is obtained by multiplying all income in group1 by 3 */
igini inc1, hgroup(group) 

/* b-False because the total distribution income inc1 does not include a replication of that in group1 */

/* c-True because the ratio between the average income of the two groups for the periods 1 and 2 is the same (12/4=24/8=3) */
dentropyg inc1, theta(0) hgroup(group) // Between inequality=0.143841
dentropyg inc2, theta(0) hgroup(group) // Between inequality=0.143841

// Q1.2
/* Decompsing the entropy index (the parameter theta = 0) for each of the three periods */
dentropyg inc1, theta(0) hgroup(group) 
dentropyg inc2, theta(0) hgroup(group) 
dentropyg inc3, theta(0) hgroup(group)

// Q1.3
igini inc* 
/* The second distribution is the one with the highest social welfare giving that the income of the majority of individuals (4/6) is higher than their income during the other periods */

// Excercise 2*********4,5%
clear
/* Inserting the data */ 
input identifier pre_tax_income  hhsize nchild
1 240  4 2
2 600  5 3
3 230  3 2
4 1250  3 1
5 1900  4 1
6 280  4 2
7 620  3 1
8 880  4 3
end



// Q2.1
/*
For a given household, the post_tax_income in Scenario A is equal to its pre_tax_income  minus 10% of the pre_tax_income.
Thus,  post_tax_income= pre_tax_income*(1-0.1)
Now, to compute the per capita post_tax_income (pcincatA), we have to divide by the household size.
This explains the form of the two following command lines.  
*/
gen pcincatA = pre_tax_income * (1.00-0.1)/hhsize
gen pcincatB = pre_tax_income * (1.00-0.1)/hhsize

/*
The collected tax revenue in scenario A is 10% of the total incomes : 0.1*6000, of which 60% is equally distributed across the population as a guaranteed universal income
*/
scalar  uinc_A  = 0.6*0.1*6000
scalar  uinc_B  = 0
/*
Generating the per capita universal income
*/
gen  pcuincA = uinc_A/hhsize
gen  pcuincB = uinc_B/hhsize

/*
The collected tax revenue in scenario A is 10% of the total incomes : 0.1*6000, of which 40% is equally distributed across the population of children, as allowances
We have 15 children in our population. Thus the child allowance is equal to : (0.4*0.1*6000)/15
*/
scalar  child_all_A  = (0.4*0.1*6000)/15

/*
The collected tax revenue in scenario B is 10% of the total incomes : 0.1*6000 
We have 15 children in our population. Thus the child allowance is equal to : (0.1*6000)/15
*/
scalar  child_all_B  = (0.1*6000)/15

/*
We generate the per capita child allowances
By household the total received allowances:
- In scenario A: nchild*child_all_A
- In scenario B: nchild*child_all_B
*/
gen  pcallowA = nchild*child_all_A/hhsize
gen  pcallowB = nchild*child_all_B/hhsize

/*
The per capita disposable income is equal to  the per capita pre_tax_income plus the per capita universal income plus the per capita child allowances plus 
*/
gen dpcincA= pcincatA+ pcuincA+ pcallowA
gen dpcincB= pcincatB+ pcuincB+ pcallowB

// Q2.2
igini dpcincA dpcincB , hsize(hhsize)

// Q2.3
diginis pcincatA pcuincA pcallowA, hsize(hhsize)
diginis pcincatB pcuincB pcallowB, hsize(hhsize)

// Q2.4
/* 
The set of transfer programs will reduced inequality in disposable incomes the most in scenario A because income sources are more diversified than in scenario B where the contribution of the per capita universal income is nil.
*/

// Q2.5
// generating the per capita income without applying any program 
gen pcinc = pre_tax_income/hhsize

difgt dpcincB pcinc, hsize1(hhsize)  hsize2(hhsize) pline1(100) pline2(100) alpha(0)

// Q2.6
difgt dpcincB pcinc, hsize1(hhsize)  hsize2(hhsize) pline1(100) pline2(100) alpha(1)

/*
The households that receive child allowances perceive some improvement in well-being, but this improvement is not enough to escape poverty.
This is what explains the unchanged level of headcount. On the opposite, the poverty gap index is sensitive to any improvement in the well-being encountering for the dependency rate. 
*/

// Exercise 3*********3%
clear
cd "C:\Users\HP PROBOOK\Desktop\COURS PEP_LAVAL\POVERTY\Assignment Week 3, 4 and 5"
use data_1.dta

// Q3.1
svyset psu [pweight=sweight], strata(strata) 

// Q3.2
/* Estimating the headcount when the measurement of well-being is the adult equivalent expenditures, and when the poverty line is equal to 21 000 */ 
ifgt ae_exp, hsize(hsize) pline(21000) alpha(0)

// Q3.3
ifgt ae_exp, alpha(0) hsize(hsize) hgroup(sex) pline(21000)
/*
------------------------------------------------------------------------------------------------
       Group   |       Estimate            STE             LB              UB         Pov. line
---------------+--------------------------------------------------------------------------------
1: Male        |        0.321482        0.014029        0.293949        0.349014        21000.00
2: Female      |        0.371593        0.035153        0.302603        0.440583        21000.00
---------------+--------------------------------------------------------------------------------
Population     |        0.332727        0.014759        0.303761        0.361694        21000.00
------------------------------------------------------------------------------------------------
Female-headed households are poorer than male-headed ones.
*/


