************11,5%

*EXERCISE 3****4%
use "C:\Users\DHN1\Downloads\data_3 (1).dta"
*Question 3.1*
* Initializing the sampling design with strata, psu and sweight*
svyset psu [pweight=sweight], strata(strata)
*The svyset command enables to initialize the sampling design of the data*
*sweight : Indicates the level of representativeness of the observation*
*psu (abbreviation of primary sampling units)*
*Question 3.2*
*estimating the headcount poverty when the measurement of well-being is the adult equivalent expenditures, and when the poverty line is equal to 21 000*
ifgt ae_exp, pline(21000) hs( hsize)
*Question 3.3*
*estimating the headcount poverty by population groups (defined by the sex of the household head) *
ifgt ae_exp, pline(21000) hs( hsize) hgroup(sex)

*EXERCISE 2* 4,5%
clear
*inputting data*
input id pre_tax_income hhsize nchild
1 480 8 4
2 1200 10 6
3 460 6 4
4 2500 6 2
5 3800 8 2
6 560 8 4
7 1240 6 2
8 1760 8 6
end
*For a given household, the post_tax_income in Scenario A is equal to its pre_tax_income  minus 10% of the pre_tax_income* post_tax_income= pre_tax_income*(1-0.1).Now, to compute the per capita post_tax_income (pcincatA), we have to divide by the household size.This explains the form of the two following command lines*  

gen pcincatA = pre_tax_income * (1.00-0.1)/hhsize

gen pcincatB = pre_tax_income * (1.00-0.1)/hhsize 

/* 10% total income in A= 0.1*12000=1200.
60% of 1200(tax revenue) is equally distributed across the population: (.60*1200)/hhsize
remaining tax income is ditributed equally among 8 children allowance:(1200-720)/ 8 which is 60 each.*/
/* storing the value of child allowance*/
scalar child_All_A=(480)/8
/* In scenario B 10% of the total income is taxed and redistributed to children with zero universal income. 
thus allowance to children in scenario B is (0.1*12000)/8 */
/* storing the value of universal income and child allowance*/
scalar child_All_B=(1200)/8
/* generating percapita income allowance and per capita child allowance in both scenarios A and B*/
gen pcuincatA=(720)/hhsize
gen pcuincatA=(720)/hhsize
gen pcuincatB=(0)/hhsize
gen pcallowA= nchild*child_All_A
gen pcallowB= nchild*child_All_B
/* generating per capita disposable income in both cases*/
gen dpcincA= pcincatA+ pcuincatA+ pcallowA
gen dpcincB= pcincatB+ pcuincatB+ pcallowB

/*Estimating per capita disposable income for both scenario A and B using DASP command igini*/
igini dpcincA dpcincB,hsize(hhsize)

/*decomposing using the diginis DASP command*/
diginis pcincatA pcuincatA pcallowA,hsize(hhsize)
diginis pcincatB pcuincatB pcallowB,hsize(hhsize)

/*generating headcount poverty*/
gen pcinc= pre_tax_income/ hhsize
difgt dpcincB pcinc,alpha(0)hsize1( hhsize)hsize2( hhsize)pline1(100)pline2(100)
/*estimating poverty gap*/
difgt dpcincB pcinc,alpha(1)hsize1( hhsize)test(0) hsize2( hhsize)pline1(100)pline2(100)


*EXERCISE 1*****4%
clear
*inputting data*
input group inc1 inc2 inc3
1 2 16 2
1 4 16 4
1 18 16 18
2 4 32 2
2 8 32 4
2 36 32 18
end
*Estimating the Gini index by population groups*
  igini inc1, hgroup(group)
*decompose the entropy index (theta = 0)*
dentropyg inc1, hgroup(group) theta(0) 
dentropyg inc2, hgroup(group) theta(0) 
dentropyg inc3, hgroup(group) theta(0)
*Estimate the Gini inequality for each of the three distributions with the igini DASP command *
igini inc1 inc2 inc3
