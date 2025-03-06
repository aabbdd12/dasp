*******11,5%

/*code stata pour l'exercice pratique 1*/
//Q1
/*insertion des données*****4%*/
clear
input group inc1 inc2 inc3
        1     1    2    2
        1     2    2    4
        1     9    2    18
        2     3    6    2
		2     6    6    4
		2     27   6    18
end		
//estimation du coefficient de gini par groupe de population
igini inc1, hgroup(group)
//verification de l'inégalité entre les groupes icl
dentropyg inc1, hgroup(group) theta(0)
dentropyg inc2, hgroup(group) theta(0)

//Q2

dentropyg inc1, hgroup(gr) theta(0)
dentropyg inc2, hgroup(gr) theta(0)
dentropyg inc3, hgroup(gr) theta(0)
//Q3
igini inc1, hgroup(group)
igini inc2, hgroup(group)
igini inc3, hgroup(group)


/*code stata pour l'exercice pratique 2*********4,5%*/
/*insertion des données*/
// Q1
clear
input identifier pre_tax_income hhsize nchild nelderly
          1       240            4         2     1
          2       600            5         3     1
          3       230            3         2     0
          4       1250           3         1     1
          5       1900           4         1     1
          6       280            4         2     0
		  7       620            3         1     1
		  8       880            4         3     0
end

gen pcincatA = pre_tax_income * (1.00-0.1)/hhsize
gen pcincatB = pre_tax_income * (1.00-0.1)/hhsize

scalar  nelderly_all_A  = 6000*0.2/5
gen	pceldA = hhsize*nelderly_all_A/hhsize
gen	pceldB = 0

scalar child_all_A  = 6000*0.8/15
scalar child_all_B  = 6000*0.10/15

gen pcallowA = nchild*child_all_A/hhsize
gen pcallowB = nchild*child_all_B/hhsize 

 
gen dpcincA= pcincatA+ pcallowA+ pceldA
gen dpcincB= pcincatB+ pcallowB+ pceldB
// Q2
igini dpcincA dpcincB , hsize(hhsize)
//Q3
diginis pcincatA pceldA pcallowA, hsize(hhsize)
diginis pcincatB pceldB pcallowB, hsize(hhsize)
//Q4
//Q5
gen pcinc = pre_tax_income/hhsize
difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(0)
//Q6
difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(1)

/*code pour l'exercice pratique 3********3%*/ 
//Q1
clear
// chargement des données
use "C:\Users\MARIAM\Desktop\cours ulaval\cours sur la pauvrété\TP\data_2 (3) Exercice semaine 3,4,5- Mariam, BULUMBA.dta"
svyset psu [pweight=sweight], strata(strata)
//Q2
ifgt ae_exp, pline(21000) hs( hsize)

//Q3
ifgt ae_exp, pline(21000) hs( hsize) hgroup(sex)


