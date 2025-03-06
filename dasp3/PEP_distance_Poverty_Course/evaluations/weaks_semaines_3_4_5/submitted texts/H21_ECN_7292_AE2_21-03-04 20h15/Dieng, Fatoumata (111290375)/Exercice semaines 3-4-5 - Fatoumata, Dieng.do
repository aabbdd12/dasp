****12%

*****************************************************************FATOUMATA DIENG, IDUL:FADIE6****************************************************


***************************************************************************************************************************************************************
******                                                     EXERCICE 1 4%
***************************************************************************************************************************************************************
input group inc1 inc2 inc3
1 2 16 2
1 4 16 4
1 18 16 18
2 4 32 2
2 8 32 4
2 36 32 18
end

*1.1	Pour la distribution inc1, indiquez si les affirmations suivantes sont vraies ou fausses, et pourquoi.

*a-	Basé sur le principe d'invariance d'échelle, l'inégalité de revenu du groupe 1 est égale à celle du groupe 2. Entrez les données et confirmez vos justifications en estimant le coefficient de Gini par groupe de population.  

 igini inc1, hgroup(gr)

*b-	En considérant le principe d'invariance d'échelle et le principe de population, l'inégalité de revenu du groupe 1 est égale à celle de la population totale.

igini inc1, hgroup(gr)

*c-	L'inégalité entre les groupes de inc1 est égale à celle de inc2. En outre, vérifiez ceci en utilisant la commande dentropyg dans DASP (par exemple, pour theta = 0).

dentropyg inc1, hgroup(gr) theta(0) // pour la periode 1
dentropyg inc2, hgroup(gr) theta(0) // pour la periode 2

*1.2	En utilisant la commande DASP dentropyg, décomposez l'indice d'entropie (theta = 0). Faites cela pour chacune des trois périodes. 

dentropyg inc1, hgroup(gr) theta(0)
dentropyg inc2, hgroup(gr) theta(0)
dentropyg inc3, hgroup(gr) theta(0)

*Estimer l'inégalité de Gini pour chacune des trois distributions avec la commande DASP igini et discutez vos résultats.

 igini inc1 inc2 inc3

*************************************************************************************************************************************************************
******                                                     EXERCICE 2   5%
*************************************************************************************************************************************************************


 input identifier pre_tax_income  hhsize nchild
 1 480 8 4
 2 1200 10 6
 3 460 6 4
 4 2500 6 2
 5 3800 8 2
 6 560 8 4
 7 1240 6 2
 8 1760 8 6
 end

/*En utilisant Stata, entrez les données (les huit observations), puis générez les variables :
-	pcincatA: revenu après impôt par habitant avec le scénario A; 
-	pcincatB: revenu après impôt par habitant avec le scénario B;
-	pcuincA:  revenu universel par habitant avec le scénario A;
-	pcuincB:  revenu universel par habitant avec le scénario scenario B;
-	pcallowA:  allocations familiales par enfant avec le scénario A;
-	pcallowB:  allocations familiales par enfant avec le scénario B;
-	dpcincA: revenu disponible par habitant avec le scénario A (pcincatA+ pcuincA+ pcallowA);
-	dpcincB: revenu disponible par habitant avec le scénario B (pcincatB+ pcuincB + pcallowB).
*/

gen pcincatA=(pre_tax_income - pre_tax_income*0.1)/hhsize
gen	pcincatB=(pre_tax_income - pre_tax_income*0.1)/hhsize

// taxe proportionnelle dans scenario A 
scalar taxeA=12000*0.1  

//revenu universel par habitant dans le scenario A
gen pcuincA=taxeA*0.6/60 

// allocation par enfant scenario A
scalar child_per_A =taxeA*0.4/30 

// allocation pour enfant
gen pcallowA=nchild*child_per_A/hhsize 

//revenu disponible par habitant avec le scénario A
gen dpcincA=pcincatA + pcuincA + pcallowA

// taxe proportionnelle dans scenario B
scalar taxeB=12000*0.1 

// revenu universel par habitant dans le scenario B 
gen pcuincB=0 

// allocation par enfant scenario B
scalar child_per_B=taxeB/30

// allocation pour enfant
gen pcallowB=nchild*child_per_B/hhsize 

//revenu disponible par habitant avec le scénario B
gen dpcincB=pcincatB + pcuincB + pcallowB

/*2.2.*En utilisant la commande DASP igini, estimez l'inégalité dans la distribution du revenu disponible par habitant pour chacun des deux scénarios. 
*/

igini dpcincA dpcincB , hsize(hhsize)

/*2.3. En utilisant la commande DASP diginis, décomposez l'inégalité dans la distribution du revenu disponible par habitant pour chacun des deux scénarios (rappelez-vous que les trois sources de revenu sont pcincatA, pcuincA et pcallowA pour le scénario A et pcincatB, pcuincB et pcallowB pour le scénario B). */

diginis pcincatA pcuincA pcallowA, hsize(hhsize)
diginis pcincatB pcuincB pcallowB, hsize(hhsize)

/*2.5. 2.5	Estimez le changement dans le taux de pauvreté pour le scénario B (par rapport à la distribution initiale) lorsque le seuil de pauvreté est 100 (utiliser la commande DASP difgt).
*/

gen pcinc = pre_tax_income/hhsize
difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(0)



/*2.6. Avec une pauvreté égale à 100, estimez le changement dans l’intensité de la pauvreté pour le scénario B (par rapport à la distribution initiale) (utilisez la commande DASP difgt). Discutez les résultats trouvés en 2.5 et 2.6.*/

difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(1)


*************************************************************************************************************************************************************
******                                                     EXERCICE 3*3%
*************************************************************************************************************************************************************


cd "C:\fatou\admissions\LAVAl\cours\pauvrete\evaluations\exam2"

/*
3.1	Chargez le fichier data_3, puis initialisez le plan d'échantillonnage avec les variables strata, psu et sweight. 
*/
use "data_3.dta",clear
svyset psu [pweight=sweight], strata(strata)

/*3.2	À l'aide de la commande DASP ifgt, estimez le taux de pauvreté lorsque la mesure du bien-être correspond aux dépenses par équivalent adulte, et lorsque le seuil de pauvreté est égal à 21 000.*/
ifgt ae_exp, pline(21000) hs( hsize)

/*3.3	Estimez maintenant le taux de pauvreté par groupes de population (définie par le sexe du chef de ménage) et discutez vos résultats.*/
ifgt ae_exp, pline(21000) hs( hsize) hgroup(sex)

