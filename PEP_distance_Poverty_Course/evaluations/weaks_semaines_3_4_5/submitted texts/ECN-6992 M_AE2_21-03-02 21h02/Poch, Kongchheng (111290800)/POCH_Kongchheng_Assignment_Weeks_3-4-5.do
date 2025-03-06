*************12,5%

//Stata Code for Assignment Weeks 3,4,5//

set more off

//**Exercise 1**//********4%

//Q1.1:

input  group inc1 inc2 inc3
1 2  16 2
1 4  16 4
1 18 16 18
2 4  32 2
2 8  32 4
2 36 32 18
end

dentropyg inc1, hgroup(gr) theta(0)
dentropyg inc2, hgroup(gr) theta(0)

//Q.1.2:
dentropyg inc1, hgroup(gr) theta(0)
dentropyg inc2, hgroup(gr) theta(0)
dentropyg inc3, hgroup(gr) theta(0)

//Q1.3:
igini inc*

/*
. igini inc*

    Index            :  Gini index
-------------------------------------------------------------------------------------------
               Variable   |       Estimate            STE             LB              UB  
--------------------------+----------------------------------------------------------------
1: GINI_inc1              |        0.500000        0.069166        0.322203        0.677797
2: GINI_inc2              |        0.166667        0.024845        0.102800        0.230533
3: GINI_inc3              |        0.444444        0.071001        0.261930        0.626958
-------------------------------------------------------------------------------------------

/*The income inequality of Inc1 is the highest (0.500000), followed by Inc3 (0.444444) and Inc2 (0.166667).*/

*/
**************************************
//**Exercise 2**//*********5.5%
clear

/* Inserting the data */ 

input identifier pre_tax_income  hhsize nchild
1 480  8  4
2 1200 10 6
3 460  6  4
4 2500 6  2
5 3800 8  2
6 560  8  4
7 1240 6  2
8 1760 8  6
end

// Q2.1:

//Scenario A//
/*For a given household, the post_tax_income in Scenario A is equal to its pre_tax_income minus 10% of the pre_tax_income.
Thus, the post_tax_income = pre_tax_income*(1-0.10)
To compute the per capita post_tax_income (pcincatA), we have to divide the post_tax_income by the household size.*/

gen pcincatA = pre_tax_income * (1.00-0.10)/hhsize

/*The collected tax revenue is 10% of the total incomes : 0.10*12,000.
We have a population of 60 people. The guaranteed universal income is: 0.60*0.10*12,000. Thus, the per capita guaranteed universal income (pcuincA) is: (0.60*0.10*12,000)/60.
The command scalar is used to store the universal income to be used later.*/

scalar uinc_A = (0.60*0.10*12000)/60

/*The per capita universal income in scenario A*/

gen pcuincA = uinc_A / hhsize

/*Child allowance is 40% of the collected tax revenue: 0.40*0.10*12,000.
There are 30 children in the population. Thus the child allowance is equal to: (0.40*0.10*12,000)/30.
The command scalar can be used to store the child allowance in the memory to be used later.*/

scalar child_all_A = (0.40*0.10*12000)/30
gen  pcallowA  = nchild * child_all_A /hhsize

//*The per capita disposable income in the scenario A: dpcincA = pcincatA + pcuincA + pcallowA.*//

gen dpcincA = pcincatA + pcuincA + pcallowA

//Scenario B//
/*In scenario B, the per capita post_tax_income (pcincatB) is the same as that of scenario A: pre_tax_income*(1-0.10).*/

gen pcincatB = pre_tax_income * (1.00-0.10)/hhsize

/* The guaranteed universal income in scenario B is equal to zero.
Thus, the per capita universal income is zero.*/

gen pcuincB = 0

/*Child allowance in scenario B is the collected tax revenue divided by the total number of children: (0.10*12,000)/30.
The command scalar can be used to store the child allowance.*/

scalar child_all_B = (0.10*12000)/30
gen pcallowB = nchild * child_all_B /hhsize

//*The per capita disposable income in the scenario B: dpcincB = pcincatB + pcuincB + pcallowB.*//

gen dpcincB = pcincatB + pcuincB + pcallowB


// Q2.2:
/*
The DASP command igini enables to compute the Gini inequality for a given variable or a set of variables.
*/
igini dpcincA dpcincB , hsize(hhsize)


// Q2.3
/*
The DASP command diginis enables to compute the total Gini inequality, as well as, to decompose the total inequality by disposable income sources.
For instance in the command line that follows, we write the Stata command "diginis" followed by  varnames of the three disposable income components (post tax income, guaranteed universal income and child allowances).
For both scenarios A and B, the following stata commands are used*/

diginis pcincatA pcuincA pcallowA, hsize(hhsize)
diginis pcincatB pcuincB pcallowB, hsize(hhsize)

// Q2.4
/*
Scenario B shows the highest reduction in inequality in disposable incomes. 
This is because the scenario B targets the transfer to support households with children. It effectively helps reduce the livelihood burdens of the households with high number of children.
Based on the results, the Child Allowances contribute to the reduction in inequality for both scenarios A and B. Hence, the result indicates that the Child Allowances is an effective program in reducing inequality.
*/

// Q2.5
// generating the per capita income without applying any program 
gen pcinc = pre_tax_income/hhsize

/*
The DASP command difgt enables to estimate FGT poverty indices of two distributions/variables as well as their difference.
For instance, the following Stata command is used to estimate poverty headcount (alpha=0) and poverty gap (alpha=1).*/

difgt dpcincB pcinc, hsize1(hhsize)  hsize2(hhsize) pline1(100) pline2(100) alpha(0)

// Q2.6
difgt dpcincB pcinc, hsize1(hhsize)  hsize2(hhsize) pline1(100) pline2(100) alpha(1)

/*. difgt dpcincB pcinc, hsize1(hhsize)  hsize2(hhsize) pline1(100) pline2(100) alpha(1)
------------------------------------------------------------------------------------------
   Index |   Estimate   Std. Err.       t     P>|t|       [95% Conf. interval]  Pov. line
---------+--------------------------------------------------------------------------------
 dpcincB |  .0616667    .0374656   1.64596   0.1438      -.0269254    .1502588       100
   pcinc |  .1166667     .061366   1.90116   0.0990      -.0284408    .2617742       100
---------+--------------------------------------------------------------------------------
    diff.|      .055     .027522    1.9984   0.0858      -.0100792    .1200792      ---
------------------------------------------------------------------------------------------

Without child allowances, the poverty gap is : .1166667
With child allowances, the poverty gap is    : .0616667
Child allowances reduce the poverty gap from .1166667 to .0616667 or by .055.
This difference is statistically significant at 10% level (i.e. P>|t| = 0.0858).
*/

/*The households that receive child allowances perceive some improvement in well-being, but this improvement is not enough to escape poverty.
This is what explains the unchanged level of headcount poverty. However, the poverty gap is reduced because an improvement in the well-being of the poor can decrease the poverty gap. 
*/

**************************************
//**Exercise 3**//*3%
clear

use "C:\Users\kongchheng.poch\Documents\KC Training\PEP MAPI_20210118\MAPI_AssignW3-4-5\data_3.dta" , replace

// Q3.1
/* 
The svyset command enables to initialize the sampling design of the data file.
For instance, we can indicate the variables:
1- sampling weight : Indicates the level of representativeness of the observation.
2- psu (abbreviation of primary sampling units).
3- strata.
*/
svyset psu [pweight=sweight], strata(strata)

// Q3.2
/* ifgt is a DASP command that can be used to estimate the FGT poverty indices.
*/
ifgt ae_exp, pline(21000) hs( hsize)

/* The DASP command ifgt should be followed by a varname of the welfare variable, which is the per adult equivalent expenditures in our case.
Among their options we find:
1- pline: to indicate the poverty line;
2- hsize: to indicate the varname of the household size.
3- alpha: the FGT alpha parameter:
- alpha(0) : the headcount poverty;
- alpha(1) : the poverty gap poverty;
- alpha(2) : the squared poverty gap poverty.

By using the above stata command, the result is as follows:

 . ifgt ae_exp, pline(21000) hs( hsize)

    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  sweight
    Parameter alpha :  0.00
-----------------------------------------------------------------------------------------------
   Variable   |       Estimate            STE             LB              UB         Pov. line
--------------+--------------------------------------------------------------------------------
ae_exp        |        0.316088        0.013949        0.288713        0.343464        21000.00
-----------------------------------------------------------------------------------------------
*/


// Q3.3
/* Now, the option hgroup(sex) is added to produce the results by population in two groups:
1-  Group of female headed households;
2-  Group of male headed households. 
*/

ifgt ae_exp, pline(21000) hs( hsize) hgroup(sex)

/*By using the above stata command, the result is as follows:
. ifgt ae_exp, pline(21000) hs( hsize) hgroup(sex)

    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  sweight
    Group variable  :  sex
    Parameter alpha :  0.00
------------------------------------------------------------------------------------------------
       Group   |       Estimate            STE             LB              UB         Pov. line
---------------+--------------------------------------------------------------------------------
1: Male        |        0.301265        0.013811        0.274160        0.328370        21000.00
2: Female      |        0.370129        0.033178        0.305014        0.435243        21000.00
---------------+--------------------------------------------------------------------------------
Population     |        0.316088        0.013949        0.288713        0.343464        21000.00
------------------------------------------------------------------------------------------------
*/
//*The poverty headcount for the female-headed households is higher than the male-headed households and the whole population. This may imply that female-headed households are disproportionately more struggling than the male-headed households in moving out of poverty.*//

