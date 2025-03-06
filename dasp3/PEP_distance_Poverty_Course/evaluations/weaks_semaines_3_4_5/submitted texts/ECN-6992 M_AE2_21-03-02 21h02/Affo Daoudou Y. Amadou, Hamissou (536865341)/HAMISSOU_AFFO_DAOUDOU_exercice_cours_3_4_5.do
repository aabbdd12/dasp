
*********************12%


*===============================================================================
AFFO DAOUDOU Y. AMADOU Hamissou
*===============================================================================
clear all
drop _all
set more off 
*===============================================================================
cd "C:\Users\Kbir\Desktop\BUREAU\ANNEE2021\LAVAL2021\AFFO"

*===============================================================================
*Exercice 1********4%
*===============================================================================
/* Q1.1	Pour la distribution inc1, indiquez si les affirmations suivantes sont 
vraies ou fausses, et pourquoi */

/*a- Entrons les données et confirmons notre justification en estimant le 
coefficient de Gini par groupe de population.  */

/* Insersition dela base  */

clear
input 	Group	inc1	inc2	inc3

1	2	16	2
1	4	16	4
1	18	16	18
2	4	32	2
2	8	32	4
2	36	32	18


end

/* Confirmons notre justification en estimant le coefficient de Gini par groupe de population.  */

igini inc1, hgroup(Group)

/*c- vérifions ceci en utilisant la commande dentropyg avec DASP (par exemple, pour theta = 0). */

* Groupe 1

dentropyg inc1, hgroup(Group) theta(0)

* Groupe 2

dentropyg inc2, hgroup(Group) theta(0)

/*Q1.2 En utilisant la commande DASP dentropyg, décomposons l'indice d’entropie 
(le paramètre theta = 0) pour chacune des trois périodes. */

* Groupe 1

dentropyg inc1, hgroup(Group) theta(0)

* Groupe 2

dentropyg inc2, hgroup(Group) theta(0)

* Groupe 3

dentropyg inc3, hgroup(Group) theta(0)


/*Q1.3 Estimons l'inégalité de Gini pour chacune des trois distributions avec la 
commande DASP igini.*/

* Groupe 1

igini inc1

* Groupe 2

igini inc2

* Groupe 3

igini inc3

*===============================================================================
*Exercice 2*******5%
*===============================================================================

clear

input identifier	pre_tax_income hhsize	nchild	
1	480	    8	4
2	1200	10	6
3	460	    6	4
4	2500	6	2
5	3800	8	2
6	560	    8	4
7	1240	6	2
8	1760	8	6

end

/*Q2.1 Dans Stata, entrez les données (les huit observations), puis générez les variables */

/*-	pcincatA: revenu après impôt par habitant avec le scénario A */

gen pcincatA = (1-0.1)*pre_tax_income / hhsize

/*-	pcincatB: revenu après impôt par habitant avec le scénario B */

gen pcincatB = (1-0.1)*pre_tax_income / hhsize

/*-	pcuincA:  revenu universel par habitant avec le scénario A; */

gen pcuincA = (6000*.1*.6)*hhsize / 60

/*-	pcuincB:  revenu universel par habitant avec le scénario scenario B; */

gen pcuincB = 0

/*-	pcallowA:  allocations familiales par enfant avec le scénario A*/

gen pcallowA = (6000*.1*.4)*nchild / 60*hhsize

/*-	pcallowB:  allocations familiales par enfant avec le scénario B */

gen pcallowB = (6000*.1)*nchild / 60*hhsize

/*- dpcincA: revenu disponible par habitant avec le scénario A (pcincatA+ pcuincA+ pcallowA) */

gen dpcincA = pcincatA+ pcuincA+ pcallowA

/*-	-	dpcincB: revenu disponible par habitant avec le scénario B (pcincatB+ pcuincB + pcallowB) */

gen dpcincB = pcincatB+ pcuincB + pcallowB


/*Q2.2 En utilisant la commande DASP igini, estimons l'inégalité dans la distribution 
du revenu disponible par habitant pour chacun des deux scénarios. */

*scénarios A

igini dpcincA

*scénarios B

igini dpcincB


/*Q2.3 En utilisant la commande DASP diginis, décomposons l'inégalité dans la distribution 
du revenu disponible par habitant pour chacun des deux scénarios */


*scénarios A

diginis pcincatA pcuincA pcallowA , hsize(hhsize)

*scénarios B

diginis pcincatB pcuincB pcallowB, hsize(hhsize)

/*Q2.5 Estimez le changement du taux de pauvreté lorsque le scénario B est adopté */
* generons d'abord le revenu par habitant en absence des senarios


gen pcinc = pre_tax_income / hhsize


difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(0)



/*Q2.6 Estimez le changement dans l’intensité de la pauvreté lié au scénario B */


difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(1)


*===============================================================================
*Exercice 3******3%
*===============================================================================
clear 
use data_3, replace
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

