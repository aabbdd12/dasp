*****************12%

//*Assignment_3_4_5*//*********4%
//EXERCISE 1//
set more off
clear all
/*Uploading data*/
input group	inc1	inc2	inc3
1	2	16	2
1	4	16	4
1	18	16	18
2	4	32	2
2	8	32	4
2	36	32	18
end
/* Question 1.1 a and b (checking income inequality betweeen group 1 and 2; and between group 1 and the entire population)*/
igini inc1, hgroup(gr)

/* Question 1.1c assessing group inequality of inc1 and inc2*/ 
dentropyg inc1, hgroup(gr) theta(0)
dentropyg inc2, hgroup(gr) theta(0)

/* Question 1.2, decomposing the entropy index*/
dentropyg inc1, hgroup(gr) theta(0)
dentropyg inc2, hgroup(gr) theta(0)
dentropyg inc3, hgroup(gr) theta(0)

/*Question 1.3, estimating Gini equality for the three distributions*/
igini inc*

//EXERCISE 2//***********5%
/*uploading data*/
clear all 
input identifier pre_tax_income hhsize	nchild
1	480	8	4
2	1200	10	6
3	460	6	4
4	2500	6	2
5	3800	8	2
6	560	8	4
7	1240	6	2
8	1760	8	6
end
/*Question 2.1 generating variables*/
gen pcincatA = pre_tax_income * (1.00-0.1)/hhsize
gen pcincatB = pre_tax_income * (1.00-0.1)/hhsize


/*10% of the total income in A= : 0.1*12000=1200.
-60% of 1200 (tax revenue) is equally distributed across the population: (.60* 1200)/hhsize
-the remaining tax income is distrubuted equally among 8 chidren allowance: (1200-720)/8 which is 60 each.*/

/* storing the value of  child allowance*/

scalar  Child_All_A = (480)/30

/*In scenario B 10 % of the total income is taxed and redistributed to children with zero universal income. 
-Thus allowance to children in scenario B is (0.1*12000)/8*/ 
/* storing the value of universal income and child allowance*/

scalar Child_All_B =(1200)/30

/*we now generate percapita Income Allowance and percapita child allowance in both scenarios A and B.*/

gen pcuincA = (720)/hhsize
gen pcuincB = (0)/hhsize
gen pcallowA= nchild*Child_All_A
gen pcallowB= nchild*Child_All_B

/*Generating Percapita disposable income in both cases*/

gen dpcincA= pcincatA+ pcallowA + pcuincA
gen dpcincB= pcincatB+ pcallowB + pcuincB

// Question 2.2//
/*Estimating per capita disposable income for both scenario A and B using DASO command igini*/

igini dpcincA dpcincB , hsize(hhsize)

// Question 2.3 and 2.4//
/*Decomposing using the diginis DASP command */

diginis pcincatA pcuincA pcallowA, hsize(hhsize)
diginis pcincatB pcuincB pcallowB, hsize(hhsize)

//Question 2.5//

/* generating headcount poverty */
gen pcinc = pre_tax_income/hhsize

difgt dpcincB pcinc, alpha(0) hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100)


//Question 2.6//
/* Estimating Poverty gap*/

difgt dpcincB pcinc, alpha(1) hsize1(hhsize)  hsize2(hhsize) pline1(100) pline2(100)

//EXERCISE 3//********3%

// Question 3.1 //
clear
use "C:\Users\Joy\OneDrive - United Nations Development Programme\Documents\Joy\PEP\data_3 (1).dta

//Initializing sampling desgin of the data file using strata, psu and sweight//

svyset psu [pweight=sweight], strata(strata)

// Question 3.2//

/*Estimating the Poverty Head count (theta=0), wellfare variable= ae_exp and poverty line=21000*/
ifgt ae_exp, alpha(0) hsize(hsize) pline(21000)

//Question 3.3

/*Estimating the Poverty Head count (theta=0), wellfare variable= ae_exp,
 poverty line=21000 and subgrouped by sex*/
 
ifgt ae_exp, alpha(0) hsize(hsize) hgroup(sex) pline(21000)
 
// End

 