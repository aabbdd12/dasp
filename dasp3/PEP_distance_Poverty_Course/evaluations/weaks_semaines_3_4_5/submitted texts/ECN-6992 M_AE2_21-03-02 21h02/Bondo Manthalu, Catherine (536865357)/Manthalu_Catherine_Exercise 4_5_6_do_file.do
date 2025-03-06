********************11,5%

//Stata code for the Practical exercise 4-5-6*/ Catherine Bondo Manthalu


set more off

clear all

/*QUESTION 1********4%*/

/*Inserting the data */ 
/*I will use the Stata command input which allows me to type data directly into*/
/* the dataset in memory.*/ 
/*The command input is followed by my varnames*/.
/*I will then enter the values of variables. Each line represents one observation.*/ 
/* I add the command end to mark the end of insertion of values.*/
  

input group	inc1	inc2	inc3
1	1	8	2
1	2	8	4
1	9	8	18
2	3	24	2
2	6	24	4
2	27	24	18
end


/* question 1.1 a and b*/
/*estimating the Gini index by population group.*/
/* Scale variance principle and population principle */ 
igini inc1, hgroup(gr)


/* question 1.1 c. */
/*Estimating if between group inequality of inc1 is equal to that of inc2 by*/
/* using the dentropyg DASP command*/
/* (for instance, for theta=0).*/
dentropyg inc1, hgroup(gr) theta(0)
dentropyg inc2, hgroup(gr) theta(0)

/* question 1.2 */
/*decomposing the entropy index (the parameter theta = 0) for each of the three*/
/* periods using the DASP command dentropyg.*/ 
dentropyg inc1, hgroup(gr) theta(0)
dentropyg inc2, hgroup(gr) theta(0)
dentropyg inc3, hgroup(gr) theta(0)

/* question 1.3 */
/*Estimating the Gini inequality of each of the three distributions with the*/
/* igini DASP command.*/
/* The DASP command igini enables to compute the Gini inequality for a given
 variable or a set of variables.*/
/*The command line that follows:
 igini inc* is similar in our case to the command line: igini inc1 inc2 inc3
 Stata interprets the inc* as a list of varnames that they start by "inc"*/
 
igini inc*

//*QUESTION 3*//


use "C:\Users\USER\Desktop\Exercise\data_1 (1).dta", clear

//*Question 3.1*//
/*initializing the sampling design with the variables strata, psu and sweight.*/
svyset psu [pweight=sweight], strata(strata)

//	QUESTION 3.2
/*estimating the headcount when the measurement of well-being is the adult 
equivalent expenditures, and when the poverty line is equal to 21 000 using ifgt
DASP Command.*/

ifgt ae_exp, alpha(0) hsize(hsize) pline (21000)
	
//QUESTION 3.3.
/*estimating headcount poverty by population groups 
(defined by the sex of the household head)*/

ifgt ae_exp, alpha(0) hsize(hsize) hgroup(sex) pline (21000)


//*QUESTION 2*//

/* inputing data using the input command*/

input identifier	pre_tax_income hhsize	nchild
1	240	4	2
2	600	5	3
3	230	3	2
4	1250	3	1
5	1900	4	1
6	280	4	2
7	620	3	1
8	880	4	3
Total	6000	30	15
end

//EXERCISE 2//********5,5%
/*inputing data*/

clear all 
input  identifier	pre_tax_income hhsize	nchild
1	240	4	2
2	600	5	3
3	230	3	2
4	1250	3	1
5	1900	4	1
6	280	4	2
7	620	3	1
8	880	4	3

end

/*Question 2.1 generating variables*/
/*For a given household, the post_tax_income in Scenario A is equal to its 
pre_tax_income  minus 10% of the pre_tax_income. 
Thus,  post_tax_income= pre_tax_income*(1-0.1) 
Now, to compute the per capita post_tax_income (pcincatA), 
we have to divide by the household size. 
This explains the form of the two following command lines.   */ 

gen pcincatA = pre_tax_income * (1.00-0.1)/hhsize
gen pcincatB = pre_tax_income * (1.00-0.1)/hhsize


/*10% of the total income in A= : 0.1*6000=600.
60% of 600 (tax revenue) is equally distributed across the population: (0.60* 600)/hhsize = 360/30=12
We have 15 children in our population.
the remaining tax income is distrubuted equally among 15 chidren allowance: (600-360)/15 = 16 each.*/

/* storing the value of  child allowance
The command scalar can be used to the  child allowance in the instance child_all_A. Thus for Stata, 
the component child_all_A is equal to (600-360)/15 or 240/15.  */ 
scalar  Child_All_A = (600-360)/15

/*In scenario B 10 % of the total income is taxed and redistributed to children with zero universal income. 
Thus allowance to children in scenario B is (0.1*6000)/15* = 600/15=40  
 storing the value of universal income and child allowance*/

scalar Child_All_B =(600)/15

/*generating percapita Income Allowance and percapita child allowance in both scenarios A and B.*/

gen pcuincA = (360)/hhsize
gen pcuincB = (0)/hhsize
gen pcallowA= nchild*Child_All_A
gen pcallowB= nchild*Child_All_B

/*Generating Percapita disposable income in scenario A and B*/

gen dpcincA= pcincatA+ pcallowA + pcuincA
gen dpcincB= pcincatB+ pcallowB + pcuincB

// Question 2.2//
/*estimatING the inequality in the distribution of the per capita disposable 
income for each of the two scenarios using DASP command igini*/


igini dpcincA dpcincB , hsize(hhsize)

 
 /* QUESTION 2.3 and 2.4*/
 /* decomposing the inequality in the distribution of the per capita disposable income for each of the two scenarios Using the DASP command diginis*/
/* The DASP command diginis enables to compute the total Gini inequality, as well as, to decompose the total inequality by -disposable-income sources. */
 /*In our case the income sources for scenario A are pcincatA pceldA pcallowA and for scenario B are vpcincatB pceldB pcallowB */
 diginis pcincatA pcuincA pcallowA, hsize(hhsize)
 diginis pcincatB pcuincB pcallowB, hsize(hhsize)
 
 /* QUESTION 2.5*/
/* Estimating the change in the headcount related to the program B 
(with respect to the initial distribution) when the poverty line is 100 using the DASP command difgt.*/

gen pcinc = pre_tax_income/hhsize

difgt dpcincB pcinc, alpha(0) hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100)

//QUESTION 2.6//
/* Estimating Poverty gap*/

difgt dpcincB pcinc, alpha(1) hsize1(hhsize) test(0) hsize2(hhsize) pline1(100) pline2(100)



**eXERCICE 3******2%