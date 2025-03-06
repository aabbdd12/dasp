****12%

clear all

/* EXERCICE 1 ****3.5%*/

// Données
input	igroup	inc1	inc2	inc3
1	1	8	2
1	2	8	4
1	9	8	18
2	3	24	2
2	6	24	4
2	27	24	18
end

// Q1.1 
//	a)
sort igroup inc1
qui sum inc1 if igroup==1
gen lp = sum(inc1)/r(sum) if igroup==1
gen temp = 0.5*(lp[_n]+lp[_n-1])/r(N) if igroup==1
qui sum temp if igroup==1
dis "Gini_group1 = "1-2*r(sum)

gsort -igroup inc1
qui sum inc1 if igroup==2
replace lp = sum(inc1)/r(sum) if igroup==2
replace temp = 0.5*(lp[_n]+lp[_n-1])/r(N) if igroup==2
qui sum temp if igroup==2
dis "Gini_group2 = "1-2*r(sum)
// As expected, Gini_group1 = Gini_group2 = .47222223


/*commentaire: Tu pourrais utiliser directement cette commande " igini inc1 , hg(group) "*/

//	b) False. A proof of my answer is given by the code in comment below. /*commentaire: Attention la moyenne du groupe 2 est double (pluot que le triple ( ?????)) de celle du groupe 1 (dans le word)) */
/*
sort inc1
qui sum inc1
replace lp = sum(inc1)/r(sum)
replace temp = 0.5*(lp[_n]+lp[_n-1])/r(N)
qui sum temp
dis "Gini_population = "1-2*r(sum)
*/

//	c)
dentropyg inc1, hgroup(igroup) theta(0)
dentropyg inc2, hgroup(igroup) theta(0)
// Il y a égalité entre les inégatilés entre les groupes de inc1 et inc2.
// pour theta==0, on obtient la valeur 0,143841.


// Q1.2
//dentropyg inc1, hgroup(igroup) theta(0)
//dentropyg inc2, hgroup(igroup) theta(0)
dentropyg inc3, hgroup(igroup) theta(0)

// Q1.3
igini inc*


clear all

/* EXERCICE 2 *********5.5%*/

// Données
input	identifier	pre_tax_income	hhsize	nchild
1	240	4	2
2	600	5	3
3	230	3	2
4	1250	3	1
5	1900	4	1
6	280	4	2
7	620	3	1
8	880	4	3
end

// Q2.1
scalar  impot = 0.1
scalar perc_uinc = 0.6
sum pre_tax_income
scalar impottotal = impot*r(sum)

gen pcincatA = (1-impot)*pre_tax_income/hhsize
gen pcincatB = pcincatA

qui sum hhsize
gen pcuincA = perc_uinc*impottotal/r(sum)
gen pcuincB = 0

qui sum nchild
gen pcallowA = (1-perc_uinc)*impottotal*(nchild/r(sum))/hhsize
gen pcallowB = impottotal*(nchild/r(sum))/hhsize

gen dpcincA = pcincatA+pcuincA+pcallowA
gen dpcincB = pcincatB+pcuincB+pcallowB

// Q2.2
igini dpcinc* , hsize(hhsize)

// Q2.3
diginis pcincatA pcuincA pcallowA, hsize(hhsize)
diginis pcincatB pcuincB pcallowB, hsize(hhsize)

/* 
SCENARIO A
	Decomposition of the Gini Index by Incomes Sources: Rao's (1969) Approach.
    Household size  :  hhsize
  +-------------------------------------------------------------------------------------+
  |          Sources   |      Income      Concentration      Absolute        Relative   |
  |                    |       Share       Index           Contribution    Contribution |
  |--------------------+----------------------------------------------------------------|
  |1: pcincatA         |        0.900000        0.395556        0.356000        1.008308|
  |                    |        0.028478        0.049440        0.042978        0.006154|
  |2: pcuincA          |        0.060000        0.000000        0.000000        0.000000|
  |                    |        0.015088        0.000000        0.000000        0.000000|
  |3: pcallowA         |        0.040000       -0.073333       -0.002933       -0.008308|
  |                    |        0.013684        0.077784        0.002248        0.006154|
  |--------------------+----------------------------------------------------------------|
  |              Total |        1.000000            ---         0.353067        1.000000|
  |                    |        0.000000            ---         0.042274        0.000000|
  +-------------------------------------------------------------------------------------+

SCENARIO B
    Decomposition of the Gini Index by Incomes Sources: Rao's (1969) Approach.
    Household size  :  hhsize
  +-------------------------------------------------------------------------------------+
  |          Sources   |      Income      Concentration      Absolute        Relative   |
  |                    |       Share       Index           Contribution    Contribution |
  |--------------------+----------------------------------------------------------------|
  |1: pcincatB         |        0.900000        0.395556        0.356000        1.021032|
  |                    |        0.033607        0.049440        0.044140        0.015775|
  |2: pcuincB          |        0.000000        0.000000        0.000000        0.000000|
  |                    |        0.000000               .        0.000000        0.000000|
  |3: pcallowB         |        0.100000       -0.073333       -0.007333       -0.021033|
  |                    |        0.033607        0.077784        0.005663        0.015775|
  |--------------------+----------------------------------------------------------------|
  |              Total |        1.000000            ---         0.348667        1.000000|
  |                    |        0.000000            ---         0.042336        0.000000|
  +-------------------------------------------------------------------------------------+
*/

// Q2.4
//more allowances. see word file.

// Q2.5
gen pcinc = pre_tax_income/hhsize
difgt dpcincB pcinc, hsize1(hhsize)  hsize2(hhsize) pline1(100) pline2(100) alpha(0)

// Q2.6
difgt dpcincB pcinc, hsize1(hhsize)  hsize2(hhsize) pline1(100) pline2(100) alpha(1)



clear all

/* EXERCICE 3 ****3%*/

// Données
//	file path to be updated if necessary
cd "~/Documents/Stata"
//	data import
use data_1

// Q3.1
svyset psu [pweight=sweight], strata(strata)

// Q3.2
ifgt ae_exp, hsize(hsize) pline(21000) alpha(0) /*we don't need alpha(0) for this question or the next question as well*/

// Q3.3
ifgt ae_exp, hsize(hsize) pline(21000) alpha(0) hgroup(sex)
