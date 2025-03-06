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

/*a- Entrons les données et confirmons notre justification en estimant le 
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

/*c- vérifions ceci en utilisant la commande dentropyg avec DASP (par exemple, pour theta = 0). */

* Périodes 1

dentropyg inc1, hgroup(Group) theta(0)

* Périodes 2

dentropyg inc2, hgroup(Group) theta(0)

/*Q1.2 En utilisant la commande DASP dentropyg, décomposons l'indice d’entropie 
(le paramètre theta = 0) pour chacune des trois périodes. */

* Périodes 1

dentropyg inc1, hgroup(Group) theta(0)

* Périodes 2

dentropyg inc2, hgroup(Group) theta(0)

* Périodes 3

dentropyg inc3, hgroup(Group) theta(0)


/*Q1.3 Estimons l'inégalité de Gini pour chacune des trois distributions avec la 
commande DASP igini.*/

* Périodes 1

igini inc1

* Périodes 2

igini inc2

* Périodes 3

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

/*Q2.1 Dans Stata, entrez les données (les huit observations), puis générez les variables */

/*-	pcincatA: revenu après impôt par habitant avec le scénario A */

gen pcincatA = (1-0.1)*pre_tax_income / hhsize

/*-	pcincatB: revenu après impôt par habitant avec le scénario B */

gen pcincatB = (1-0.1)*pre_tax_income / hhsize

/*-	pceldA:  pension de vieillesse par habitant avec le scénario A */

gen pceldA = (6000*.1*.2/5)*nelderly / hhsize

/*-	pceldB:  pension de vieillesse par habitant avec le scénario B */

gen pceldB = 0

/*-	pcallowA:  allocations familiales par enfant avec le scénario A*/

gen pcallowA = (6000*.1*.8/15)*nchild / hhsize

/*-	pcallowB:  allocations familiales par enfant avec le scénario B */

gen pcallowB = (6000*.1/15)*nchild / hhsize

/*-	dpcincA: revenu disponible par habitant avec le scénario A (pcincatA+ pceldA+ pcallowA) */

gen dpcincA = pcincatA+ pceldA+ pcallowA

/*-	dpcincB: revenu disponible par habitant avec le scénario B (pcincatB+ pceldB + pcallowB) */

gen dpcincB = pcincatB+ pceldB + pcallowB


/*Q2.2 En utilisant la commande DASP igini, estimons l'inégalité dans la distribution 
du revenu disponible par habitant pour chacun des deux scénarios. */

*scénarios A

igini dpcincA

*scénarios B

igini dpcincB


/*Q2.3En utilisant la commande DASP diginis, décomposons l'inégalité dans la distribution 
du revenu disponible par habitant pour chacun des deux scénarios */


*scénarios A

diginis pcincatA  pceldA pcallowA, hsize(hhsize)

*scénarios B

diginis pcincatB  pceldB pcallowB, hsize(hhsize)

/*Q2.5 Estimez le changement du taux de pauvreté lorsque le scénario B est adopt*/

generons d'abord le revenu par habitant en absence des senarios


gen pcinc = pre_tax_income / hhsize


difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(0)



/*Q2.6 Estimez le changement dans l’intensité de la pauvreté lié au scénario B */


difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(1)


*===============================================================================
*Exercice 3 ****************3%
*===============================================================================
clear 
use data_2, replace
*===============================================================================


/*Q3.1	Chargeons le fichier data_2, puis initialisons le plan d'échantillonnage 
avec les variables strata, psu et sweight.*/ 

svyset psu [pweight=sweight], strata(strata)

/*Q3.2 Estimez le taux de pauvreté lorsque la mesure du bien-être correspond aux 
dépenses par équivalent adulte, et lorsque le seuil de pauvreté est égal à 21 000.*/

ifgt ae_exp, pline(21000) hs( hsize)

/*Q3.3 Estimons maintenant le taux de pauvreté par groupes de population 
(définie par le sexe du chef de ménage) et discutez vos résultats.*/

ifgt ae_exp, pline(21000) hs( hsize) hgroup(sex)


*===============================================================================
****************************************fin*************************************
*===============================================================================

