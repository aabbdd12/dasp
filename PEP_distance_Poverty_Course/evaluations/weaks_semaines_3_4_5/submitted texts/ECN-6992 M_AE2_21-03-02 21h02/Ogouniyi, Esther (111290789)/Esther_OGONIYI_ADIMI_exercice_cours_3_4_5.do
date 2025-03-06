*********12,5%


clear all
drop _all
set more off 
*===============================================================================
cd "C:\Users\Kbir\Desktop\BUREAU\ANNEE2021\LAVAL2021\Exercice\Semaine3-5"

*===============================================================================
*Exercice 1   4%
*===============================================================================
/* Q1.1	Pour la distribution inc1, indiquez si les affirmations suivantes sont 
vraies ou fausses, et pourquoi */

/*a- Entrons les donn�es et confirmons notre justification en estimant le 
coefficient de Gini par groupe de population.  */

/* Insersition dela base  */

clear
input 	Group	inc1	inc2	inc3

1	1	2	2
1	2	2	4
1	9	2	18
2	3	6	2
2	6	6	4
2	27	6	18

end

/* Confirmons notre justification en estimant le coefficient de Gini par groupe de population.  */

igini inc1, hgroup(Group)

/*c- v�rifions ceci en utilisant la commande dentropyg avec DASP (par exemple, pour theta = 0). */

* P�riodes 1

dentropyg inc1, hgroup(Group) theta(0)

* P�riodes 2

dentropyg inc2, hgroup(Group) theta(0)

/*Q1.2 En utilisant la commande DASP dentropyg, d�composons l'indice d�entropie 
(le param�tre theta = 0) pour chacune des trois p�riodes. */

* P�riodes 1

dentropyg inc1, hgroup(Group) theta(0)

* P�riodes 2

dentropyg inc2, hgroup(Group) theta(0)

* P�riodes 3

dentropyg inc3, hgroup(Group) theta(0)


/*Q1.3 Estimons l'in�galit� de Gini pour chacune des trois distributions avec la 
commande DASP igini.*/

* P�riodes 1

igini inc1

* P�riodes 2

igini inc2

* P�riodes 3

igini inc3

*===============================================================================
*Exercice 2 5.5%
*===============================================================================

clear

input identifier	pre_tax_income hhsize	nchild	nelderly
1	240	4	2	1
2	600	5	3	1
3	230	3	2	0
4	1250	3	1	1
5	1900	4	1	1
6	280	4	2	0
7	620	3	1	1
8	880	4	3	0
end

/*Q2.1 Dans Stata, entrez les donn�es (les huit observations), puis g�n�rez les variables */

/*-	pcincatA: revenu apr�s imp�t par habitant avec le sc�nario A */

gen pcincatA = (1-0.1)*pre_tax_income / hhsize

/*-	pcincatB: revenu apr�s imp�t par habitant avec le sc�nario B */

gen pcincatB = (1-0.1)*pre_tax_income / hhsize

/*-	pceldA:  pension de vieillesse par habitant avec le sc�nario A */

gen pceldA = (6000*.1*.2/5)*nelderly / hhsize

/*-	pceldB:  pension de vieillesse par habitant avec le sc�nario B */

gen pceldB = 0

/*-	pcallowA:  allocations familiales par enfant avec le sc�nario A*/

gen pcallowA = (6000*.1*.8/15)*nchild / hhsize

/*-	pcallowB:  allocations familiales par enfant avec le sc�nario B */

gen pcallowB = (6000*.1/15)*nchild / hhsize

/*-	dpcincA: revenu disponible par habitant avec le sc�nario A (pcincatA+ pceldA+ pcallowA) */

gen dpcincA = pcincatA+ pceldA+ pcallowA

/*-	dpcincB: revenu disponible par habitant avec le sc�nario B (pcincatB+ pceldB + pcallowB) */

gen dpcincB = pcincatB+ pceldB + pcallowB


/*Q2.2 En utilisant la commande DASP igini, estimons l'in�galit� dans la distribution 
du revenu disponible par habitant pour chacun des deux sc�narios. */

*sc�narios A

igini dpcincA

*sc�narios B

igini dpcincB


/*Q2.3En utilisant la commande DASP diginis, d�composons l'in�galit� dans la distribution 
du revenu disponible par habitant pour chacun des deux sc�narios */


*sc�narios A

diginis pcincatA  pceldA pcallowA, hsize(hhsize)

*sc�narios B

diginis pcincatB  pceldB pcallowB, hsize(hhsize)

/*Q2.5 Estimez le changement du taux de pauvret� lorsque le sc�nario B est adopt*/

generons d'abord le revenu par habitant en absence des senarios


gen pcinc = pre_tax_income / hhsize


difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(0)



/*Q2.6 Estimez le changement dans l�intensit� de la pauvret� li� au sc�nario B */


difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(1)


*===============================================================================
*Exercice 3 ****************3%
*===============================================================================
clear 
use data_2, replace
*===============================================================================


/*Q3.1	Chargeons le fichier data_2, puis initialisons le plan d'�chantillonnage 
avec les variables strata, psu et sweight.*/ 

svyset psu [pweight=sweight], strata(strata)

/*Q3.2 Estimez le taux de pauvret� lorsque la mesure du bien-�tre correspond aux 
d�penses par �quivalent adulte, et lorsque le seuil de pauvret� est �gal � 21 000.*/

ifgt ae_exp, pline(21000) hs( hsize)

/*Q3.3 Estimons maintenant le taux de pauvret� par groupes de population 
(d�finie par le sexe du chef de m�nage) et discutez vos r�sultats.*/

ifgt ae_exp, pline(21000) hs( hsize) hgroup(sex)


*===============================================================================
****************************************fin*************************************
*===============================================================================

