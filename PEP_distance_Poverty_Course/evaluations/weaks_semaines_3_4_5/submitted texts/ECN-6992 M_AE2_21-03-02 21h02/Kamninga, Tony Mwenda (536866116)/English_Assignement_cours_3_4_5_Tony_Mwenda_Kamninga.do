**************12,5%

********************************************************************************
* Measuring and Alleviating Poverty and Inequality- Assignment Two							   *
*					~Tony Mwenda Kamninga									   *
********************************************************************************
*Exercise 1*****4%
clear
//Question 1.1 

*	a) Answer (TRUE)
/*inputing data*/

input Group	inc1	inc2	inc3
1	1	2	2
1	2	2	4
1	9	2	18
2	3	6	2
2	6	6	4
2	27	6	18
end

/*Explaination: It is true that income inequality in group 1 and 2 are the same. First, we should know that using relative measure of inequality, multiplying all income by the same scaler would not change the relative differences. In the same vein, the scale invariance principle says that an inequality index should not change if all incomes are scaled by a common factor. In our case incomes in group 1 are multplied by 3 to get corresponding incomes for group 2.*/

igini inc1, hgroup(Group)

/*
. igini inc1, hgroup(Group)

    Index            :  Gini index
    Group variable   :  Group
-------------------------------------------------------------------------------------------
                  Group   |       Estimate            STE             LB              UB  
--------------------------+----------------------------------------------------------------
1: 1                      |        0.444444        0.100411        0.186331        0.702558
2: 2                      |        0.444444        0.100411        0.186331        0.702558
--------------------------+----------------------------------------------------------------
Population                |        0.534722        0.080462        0.327888        0.741557
-------------------------------------------------------------------------------------------


By Estimating Gini coefficient by sub-group, we find that indeed the estimate is 0.444444 for both sub-groups 1 and 2 confirming the scale invariance principle*/

*	b) Answer  (FALSE)

/*The population principle that states that the inequality should remain the same to replication of the population and in our case, scaling does not necessarily mean replication as such we are bound to find differences in inequality index.*/

igini inc1, hgroup(Group) /*Indeed the results confirm that the population is different from the group 1 inequality*/

*   c) Answer (TRUE)
/*
Explanation: The ratio between the average income of the two groups in the periods 1 was 4/12=1/3. And similarry the ration of average income of the two groups in period 2 was 2/6=1/3 that shows that the between group inequality are the same.
*/

dentropyg inc1, hgroup(Group) theta(0)
dentropyg inc2, hgroup(Group) theta(0)
/*We can see from these estimates that  indeed the between group inequality for both inc1 and inc2 are the same= 0.143841

Here are results for the inc1. In the similar vein we can compute for inc2
 dentropyg inc1, hgroup(Group) theta(0)

    Decomposition of the Generalised Entropy Index by Groups
    Group variable  :  Group
    Parameter theta :  0.00
  +---------------------------------------------------------------------------------------------+
  |    Group   |  Entropy index     Population  (mu_k/mu)^theta      Absolute        Relative   |
  |            |                       share                       contribution    contribution |
  |------------+--------------------------------------------------------------------------------|
  |1: Group_1  |        0.422837        0.500000        1.000000        0.211419        0.373084|
  |            |        0.114650        0.223607        0.000000        0.110570        0.211759|
  |2: Group_2  |        0.422837        0.500000        1.000000        0.211419        0.373084|
  |            |        0.114650        0.223607        0.000000        0.110570        0.237621|
  |------------+--------------------------------------------------------------------------------|
  |Within      |            ---             ---             ---         0.422837        0.746168|
  |            |            ---             ---             ---         0.081070        0.266067|
  |------------+--------------------------------------------------------------------------------|
  |Between     |            ---             ---             ---         0.143841        0.253832|
  |            |            ---             ---             ---         0.200174        0.266067|
  |------------+--------------------------------------------------------------------------------|
  |Population  |        0.566678        1.000000            ---         0.566678        1.000000|
  |            |        0.215967        0.000000            ---         0.215967        0.000000|
  +---------------------------------------------------------------------------------------------+


*/

//Question 1.2 

/*Decomposing entropy index*/ 
dentropyg inc1, hgroup(Group) theta(0)
dentropyg inc2, hgroup(Group) theta(0)
dentropyg inc3, hgroup(Group) theta(0)

//Question 1.3
igini inc*
/*
. igini inc*

    Index            :  Gini index
-------------------------------------------------------------------------------------------
               Variable   |       Estimate            STE             LB              UB  
--------------------------+----------------------------------------------------------------
1: GINI_inc1              |        0.534722        0.080462        0.327888        0.741557
2: GINI_inc2              |        0.250000        0.055902        0.106300        0.393700
3: GINI_inc3              |        0.444444        0.071001        0.261930        0.626958
-------------------------------------------------------------------------------------------


- The first distribution is the one that seem to have a higher social welfare. This is so because that the income of each individual is higher than their incomes during the other periods.
- It is clear that we cannot draw a normative judgment about the level of inequality without considering the specific context of each country.
-- For instance, in developed countries, where each individual can be better off even with the increase in inequality, we may be less averse to the increase in the inequality.
-- In another case, e.g., where the country is very poor, it may be better to reduce the inequality to improve the opportunities of everybody.  
*/


*Exercise 2**********5.5%
clear


/*inputing data*/
input identifier	pre_tax_income hhsize nchild nelderly			
1	240	 4	2	1
2	600	 5	3	1
3	230	 3	2	0
4	1250 3	1	1
5	1900 4	1	1
6	280	 4	2	0
7	620	 3	1	1
8	880	 4	3	0
end
list



/*
For a given household, the post_tax_income in Scenario A is equal to its pre_tax_income  minus 10% of the pre_tax_income.
Thus,  post_tax_income= pre_tax_income*(1-0.1)
Now, to compute the per capita post_tax_income (pcincatA), we have to divide by the household size.
This explains the form of the two following command lines.  
*/
gen pcincatA = pre_tax_income * (1.00-0.1)/hhsize

gen pcincatB = pre_tax_income * (1.00-0.1)/hhsize /*we also do the same for post_tax_income in scenario B)*/

/*
The collected tax revenue in scenario A is 10% of the total incomes : 0.1*6000=600.
-20% of 600 (tax revenue) is equally distributed among 5 elderly in the population: ((0.1*6000)*0.2)/5 =120/5.
-the remaining tax income is distributed equally among 15 chidren allowance: (600-120)/15 

-We would like to store the value of eldery allowance and child allowance in scenario A in the memory to be used latter.
-The command scalar can be used to the  elderly allowance in the instance Elder_all_A.
-The command scalar can be used to the  child allowance in the instance child_all_A.

Thus for Stata, the component child_all_A is equal to (600-120)/15. 
*/

scalar  elder_Pens_A= 120/5
scalar  child_all_A  = (600-120)/15


/*
In scenario B 10 % of the total income is taxed and redistributed to children with none given to the eldery pension. 

-Thus allowance to children in scenario B is (0.1*6000)/15 while for eldery its zero 
using the same scalar principle, we keep these components as below*/

scalar elder_Pens_B=0
scalar child_all_B=(0.1*6000)/15

/*we now generate percapita eldery pension and percapita child allowance in both scenarios A and B.

By household, the total received allowances:
	-In scenario A: nchild*child_all_A + nelderly*elder_Pens_A
	-In scenario B: nchild*child_all_B
Thus we compute percapita eldery pension and child allowance for the household:
*/
gen pceldA= (nelderly*elder_Pens_A)/hhsize
gen pceldB= (nelderly*elder_Pens_B)/hhsize
gen pcallowA= (nchild*child_all_A)/hhsize
gen pcallowB= (nchild*child_all_B)/hhsize

/*
Recall that the per capita disposable income is equal to  the per capita pre_tax_income plus the per capita child allowances and plus the percapita eldery pension. It is the same as addition zero for the for eldery pension in scenario B.
*/

gen dpcincA= pcincatA+ pcallowA + pceldA
gen dpcincB= pcincatB+ pcallowB + pceldB



// Question 2.2
/*
Estimating per capita disposable income for both scenario A and B. We are using the DASP command igini that enables us to compute the Gini inequality for a given variable or a set of variables.
*/
igini dpcincA dpcincB , hsize(hhsize)
/*
. igini dpcincA dpcincB , hsize(hhsize)

    Index            :  Gini index
    Household size   :  hhsize
----------------------------------------------------------------------------------------------
                  Variable   |       Estimate            STE             LB              UB  
-----------------------------+----------------------------------------------------------------
1: GINI_dpcincA              |        0.352933        0.042583        0.252241        0.453626
2: GINI_dpcincB              |        0.348667        0.042336        0.248557        0.448776
----------------------------------------------------------------------------------------------



The results show that scenario B has the highest reduction in inequality in disposable income as the gini estimate is  0.348667compared to  0.352933 in scenario A. This implies that giving allowance to children is a much better policy ti help reduce inequality than sharing the tax income allowance for children and the elderly*/

// Question 2.3
/*We decompose inequality by using the diginis DASP command that  enables to compute the total Gini inequality, as well as, to decompose the total inequality by -disposable-income sources. In our case the income sources for scenario A are pcincatA pceldA pcallowA and for scenario B are pcincatB pceldB pcallowB */
diginis pcincatA pceldA pcallowA, hsize(hhsize)
diginis pcincatB pceldB pcallowB, hsize(hhsize)
/*


. diginis pcincatA pceldA pcallowA, hsize(hhsize)

    Decomposition of the Gini Index by Incomes Sources: Rao's (1969) Approach.
    Household size  :  hhsize
  +-------------------------------------------------------------------------------------+
  |          Sources   |      Income      Concentration      Absolute        Relative   |
  |                    |       Share       Index           Contribution    Contribution |
  |--------------------+----------------------------------------------------------------|
  |1: pcincatA         |        0.900000        0.395556        0.356000        1.008689|
  |                    |        0.029346        0.049440        0.043554        0.011153|
  |2: pceldA           |        0.020000        0.140000        0.002800        0.007934|
  |                    |        0.005877        0.163075        0.002990        0.008386|
  |3: pcallowA         |        0.080000       -0.073333       -0.005867       -0.016623|
  |                    |        0.027309        0.077784        0.004499        0.012348|
  |--------------------+----------------------------------------------------------------|
  |              Total |        1.000000            ---         0.352933        1.000000|
  |                    |        0.000000            ---         0.042583        0.000000|
  +-------------------------------------------------------------------------------------+


For scenarion A,
The total Gini inequality is equal to     0.352933  
For the first component (per capita post tax income ), we have that:
- Its income share (mu_k/mu)     =   0.900000 
- Its concentration index (C_k)   =  0.395556  
- Based on the  Rao's (1969) approach, its absolute contribution to total Gini inequality is (mu_k/mu) * C_k =    0.356000 

We should note that for scenario B,

per capita eldery person is 0 throughout as we have noticed from the initial defintion of the scenario that no pension is geiven to the eldery.
 */

//Question 2.4 

/*
Scenario B is the one with the highest reduction in inequality in disposable incomes.
This is because this program effectively targets children who may be in need morre tha the eldery.
This also makes the contribution of the source Child Allowances more effective in reducing inequality.
*/

//Question 2.5

/* generating the per capita income for the initial distribution without applying any program */
gen pcinc = pre_tax_income/hhsize

difgt dpcincB pcinc, alpha(0) hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100)
/*

. difgt dpcincB pcinc, alpha(0) hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100)
------------------------------------------------------------------------------------------
Variable |   Estimate   Std. Err.       t     P>|t|       [95% Conf. interval]  Pov. line
---------+--------------------------------------------------------------------------------
 dpcincB |  .3666667    .1835415   1.99773   0.0859        -.06734    .8006734       100
   pcinc |  .3666667    .1835415   1.99773   0.0859        -.06734    .8006734       100
---------+--------------------------------------------------------------------------------
    diff.|         0           0         .        .              0           0      ---
------------------------------------------------------------------------------------------


Without child allowances, the poverty head count is : .3666667
With child allowances, the poverty headcount is    : .3666667
Child allowances does not reduce the poverty head count as the difference between previous headcount and current head ciunt is just equal to 0. This difference is significant by about 10% (i.e. P>|t| = 0.1)


*/

//Question 2.6
/* Estimating Poverty gap*/

difgt dpcincB pcinc, alpha(1) hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100)

/*
. difgt dpcincB pcinc, alpha(1) hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100)
------------------------------------------------------------------------------------------
Variable |   Estimate   Std. Err.       t     P>|t|       [95% Conf. interval]  Pov. line
---------+--------------------------------------------------------------------------------
 dpcincB |  .0616667    .0374656   1.64596   0.1438      -.0269254    .1502588       100
   pcinc |  .1166667     .061366   1.90116   0.0990      -.0284408    .2617742       100
---------+--------------------------------------------------------------------------------
    diff.|      .055     .027522    1.9984   0.0858      -.0100792    .1200792      ---
------------------------------------------------------------------------------------------


Without child allowances, the poverty gap is : .1166667 
With child allowances, the poverty gap is    : 0.0616667 
Child allowances reduce the poverty gap from .1166667 to 0.0616667  or by .055.
This difference is significant by about 10% (i.e. P>|t| = 0.1)

The results are showing the difference in poverty measures. Poverty headcount is not sensitive to income transfers among the poor as it still recodes no difference in terms of poverty while the poverty gap has shown that even though people have not moved above the poverty line, the tax policy has helped those who were so poor to catch up close to the poverty line. 
*/




*Exercise 3********3%

// Question 3.1 
clear
use "data_2.dta" , replace

//Initializing sampling desgin of the data file using strata, psu and sweight

svyset psu [pweight=sweight], strata(strata)

// Question 3.2

/*Estimating the Poverty Head count (theta=0), wellfare variable= a_e and poverty line=21000*/
ifgt ae_exp, alpha(0) hsize(hsize) pline(21000)

//Question 3.3

/*Estimating the Poverty Head count (theta=0), wellfare variable= a_e,
 poverty line=21000 and subgrouped by sex*/
 
ifgt ae_exp, alpha(0) hsize(hsize) hgroup(sex) pline(21000)
 
/*Discussion: Total population poverty head count is 33.7% implying that these are total number of individuals below the poverty line. The results show that more females are are poor compared to males. About 37.9% of females are poor while 32.5% of males are poor. The imolication is that there is income differentials between males and females in this country*/

// End
