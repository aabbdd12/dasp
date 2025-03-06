
// EXERCICE 1

// Q1
//a
/*
This affirmation is true:
The distribution of incomes of the group 2 is similar to that of the first group, 
except that incomes are multiplied by a scale of 3. Since the relative inequality indices, as the Gini index,
obey to the scale invariance principle, the inequality of the two groups will be the same.
*/
clear
input group inc1 inc2 inc3
1 1 8 2
1 2 8 4
1 9 8 18
2 3 24 2
2 6 24 4
2 27 24 18
end

igini inc1 , hg(group)

//b
/*
This affirmation is false:
When the averages of  incomes of the two groups are different, 
we also must consider the contribution of the between group inequality to the total inequality. 
*/

//c
/* 
This affirmation is true:
- With the inc1, the between group inequality is the inequality of the distribution: D1: (4,4,4,12,12,12) 
- With the inc2, the between group inequality is the inequality of the distribution: D2: (8,8,8,24,24,24) 
  Based on the scale invariance principle (the distribution D2 is simply that of the double of the incomes of D1),
  The between group inequality in inc1 is similar to that of inc2. 
 */
 dentropyg inc1, hg(group)
 dentropyg inc2, hg(group)

// Q2
clear
input group inc1 inc2 inc3
1 1 8 2
1 2 8 4
1 9 8 18
2 3 24 2
2 6 24 4
2 27 24 18
end

dentropyg inc1, hg(group) theta(0)
dentropyg inc2, hg(group) theta(0)
dentropyg inc3, hg(group) theta(0)

// Q3
igini inc1 inc2 inc3



// EXERCICE 2

// Q1
clear
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

/* Scenario A */
gen pcincatA = pre_tax_income * (1.00-0.10)/hhsize

scalar  un_revenu_A  = 6000*0.06/30
scalar  child_all_A  = 6000*0.04/15
gen     pcuincA  = hhsize*un_revenu_A/hhsize
gen  pcallowA = nchild*child_all_A/hhsize
gen dpcincA= pcincatA+ pcuincA+ pcallowA

/* Scenario B */
gen pcincatB = pre_tax_income * (1.00-0.10)/hhsize
scalar  un_revenu_B  = 0
scalar  child_all_B  = 6000*0.10/15
gen     pcuincB  = hhsize*un_revenu_B/hhsize
gen  pcallowB = nchild*child_all_B/hhsize
gen dpcincB= pcincatB+ pcuincB+ pcallowB


// Q2
igini dpcincA dpcincB , hsize(hhsize)

// Q3
diginis pcincatA pcuincA pcallowA, hsize(hhsize)
diginis pcincatB pcuincB pcallowB, hsize(hhsize)

// Q4
/*
The scenario B is with the highest reduction in inequality in disposable incomes.
This is because, this programme targets well the deprived or poor households, which are characterized by a large number of children. 
*/

// Q5
// generating the per capita income without applying any program 
gen pcinc = pre_tax_income/hhsize
difgt dpcincB pcinc, hsize1(hhsize)  hsize2(hhsize) pline1(100) pline2(100) alpha(0)

// Q6
difgt dpcincB pcinc, hsize1(hhsize)  hsize2(hhsize) pline1(100) pline2(100) alpha(1)
/*
The households that receive child allowances have some improvement in well-being, but this improvement is not enough to make them escape poverty.
This is what explains the unchanged level of headcount. In the inverse, the poverty gap index is sensitive to any improvement in the well-being of the poor, and this explains the reduction of this index. 
*/


// EXERCICE 3

//Stata code for the Practical exercise 3 - BLOC3
 
 // Q1
clear
cd "C:\PDATA\PEP\Exercises_2018\bloc3\"
use "data_1.dta" , replace
svyset psu [pweight=sweight], strata(strata)


// Q2
ifgt ae_exp, pline(21000) hs(hsize)

// Q3
ifgt ae_exp, pline(21000) hs(hsize) hgroup(sex)
