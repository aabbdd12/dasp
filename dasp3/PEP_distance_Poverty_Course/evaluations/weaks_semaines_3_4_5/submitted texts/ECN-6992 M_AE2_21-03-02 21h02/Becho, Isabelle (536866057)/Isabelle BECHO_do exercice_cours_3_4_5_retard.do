************12%
/*
EXERCICE COURS 3, 4, 5 
*/
*********EXERCICE 1**********************************************************4%

input  group inc1 inc2 inc3
1 1 8 2
1 2 8 4
1 9 8 18
2 3 24 2
2 6 24 4
2 27 24 18
end

*** Q1.1*********
igini inc1 inc2 inc3, hgroup(group)

*** Q1.2*********
***Indice d’entropie periode 1***
dentropyg inc1, theta(0) hgroup(group)

***Indice d’entropie periode 2***
dentropyg inc2, hgroup(gr) theta(0)

***Indice d’entropie periode 2***
dentropyg inc3, hgroup(gr) theta(0)

*********************Q1.3***************
 igini inc*

 
 *********EXERCICE 2**************************************************************5%
 
input identifier pre_tax_income  hhsize nchild
1 240  4 2
2 600  5 3
3 230  3 1
4 1250  3 1
5 1900  4 1
6 280  4 2
7 620  3 1
8 880  4 3
end

************Q2.1**************************************
****revenu après impôt par habitant avec le scénario A******
gen pcincatA = pre_tax_income * (1.00-0.10)/hhsize
****revenu après impôt par habitant avec le scénario B******
gen pcincatB = pre_tax_income * (1.00-0.10)/hhsize
******revenu universel par habitant avec le scénario A******
******revenu universel par habitant avec le scénario A******
scalar revenu_garanti_hbttotalA= 0.60*(0.10*6000)/30
ge pcuincA= hhsize*revenu_garanti_hbttotalA
ta pcuincA
******revenu universel par habitant avec le scénario B******
scalar revenu_garanti_hbttotalB=0*(0.10*6000)/30
ge pcuincB= hhsize*revenu_garanti_hbttotalB
ta pcuincB
***************allocations familiales par enfant avec le scénario A*******************
scalar enfant_all_A = 0.04*(0.10*6000)/15
gen pcallowA = nchild*enfant_all_A/hhsize
ta pcallowA
***************allocations familiales par enfant avec le scénario B*******************
scalar enfant_all_B = (0.10*6000)/15
gen pcallowB = nchild*enfant_all_B/hhsize
ta pcallowB
ta pcallowA
ta pcuincA
*******revenu disponible par habitant avec le scénario A ********
gen dpcincA= pcincatA+pcuincA+pcallowA
*******revenu disponible par habitant avec le scénario B ********
gen dpcincB= pcincatB+pcuincB+pcallowB
ta dpcincA
ta dpcincB

**************Q2.2**********************************
igini dpcincA dpcincB , hsize(hhsize)

***************Q2.3******************************
***********Scenario A***************
diginis pcincatA pcuincA pcallowA, hsize(hhsize)
***********Scenario B***************
diginis pcincatB pcuincB pcallowB, hsize(hhsize)

***************Q2.5******************************
**générer le revenu par habitant sans taxe*****
gen pcinc = pre_tax_income/hhsize
difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(0)
sum pcinc
sum dpcincB

***************Q2.6******************************
difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(1)

/*Commentaire : attention les ménages qui reçoivent les allocations perçoivent bien une amélioration de leur bien être, toutefois cette amélioration n’est pas suffisante pour les sortir de la pauvreté */


 *********EXERCICE 3*************************************************************3%

 ***************Q3.1******************************
 svyset psu [pweight=sweight], strata(strata)
 
  ***************Q3.2******************************
ifgt ae_exp, pline(21000) hs( hsize)

***************Q3.3******************************

ifgt ae_exp, pline(21000) hs( hsize) hgroup(sex)

