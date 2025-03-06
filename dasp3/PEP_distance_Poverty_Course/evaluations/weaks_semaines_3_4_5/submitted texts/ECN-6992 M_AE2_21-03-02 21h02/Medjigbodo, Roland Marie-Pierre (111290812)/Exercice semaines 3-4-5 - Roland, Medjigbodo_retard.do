********12,5%


clear
// Exercices semaines 3,4 et 5
// Exercice 1*****4%

/*1.1	Pour la distribution inc1, indiquez si les affirmations suivantes sont vraies ou fausses, et pourquoi.*/

/*a-	Basé sur le principe d'invariance d'échelle, l'inégalité de revenu du groupe 1 est égale à celle du groupe 2.*/

/* Cette affirmation est vraie. Les revenus ont été multipliés par un même scalaire : 3.*/

/*Entrez les données et confirmez vos justifications en estimant le coefficient de Gini par groupe de population.  
*/

/*Insertion des données*/
clear
input group inc1 inc2 inc3
1 1 8 2
1 2 8 4
1 9 8 18
2 3 24 2
2 6 24 4
2 27 24 18
end

/*b-	En considérant le principe d'invariance d'échelle et le principe de population, l'inégalité de revenu du groupe 1 est égale à celle de la population totale.*/

/*R : Cette affirmation est fausse.
Le maintien du niveau d’inégalité en présence des deux axiomes : principe d'invariance d'échelle et le principe de population n’est pas prouvé. */

 digini inc1 inc1, cond1(group==1 ) 
 
/*Les résultats de comparaison des indices dans les deux cas indiquent une différence significative. Il y a donc une différence d’inégalité de revenu du groupe 1 et celle de la population totale.*/


/*c-	L'inégalité entre les groupes de inc1 est égale à celle de inc2. En outre, vérifiez ceci en utilisant la commande dentropyg dans DASP (par exemple, pour theta = 0).*/

/*Cette affirmation est fausse. Par le principe de l'invariance d'échelle les inégalités entre les groupes de inc2  seront  nulles. */

dentropyg inc1  , theta(0) hgroup(group)
dentropyg inc2  , theta(0) hgroup(group)

/*Les coefficients ne sont pas identiques; les coefficients de la deuxième période sont nuls, alors qu'ils sont non nul en première période*/

/*1.2 En utilisant la commande DASP dentropyg, décomposez l’indice d’entropie (le paramètre theta = 0). Faites ceci pour chacune des trois périodes. */


dentropyg inc1  , theta(0) hgroup(group)
dentropyg inc2  , theta(0) hgroup(group)
dentropyg inc3  , theta(0) hgroup(group)


/*1.3	Estimez l'inégalité de Gini de chacune des trois distributions avec la commande igini sur DASP et discutez vos résultats.*/
 
igini inc1 inc2 inc3
 
  /*Les indices sont respectivement 0.54 ; 0.25 ; 0.44 respectivement pour les périodes selon les rangs. Il apparait que la première période est celle au cours de laquelle l’inégalité est plus grande suivie de  la troisième période. Les écarts types  indiquent une faible fluctuation autour des moyennes respectives. Les intervalles de confiance des indices sont indiqués. 
Ces résultats corroborent ceux obtenus à la question précédente qui était liée à la décomposition de l’indice d’Entropy.
*/


cls
clear
// Exercice 2************5,5%

// Supposons que la population est composée de huit ménages. 
//Dans Stata, entrez les données (les huit observations)


input identifier	pre_tax_income	hhsize	nchild
1	240	4	2
2	600	5	3
3	230	3	2
4	1250	3	1
5	1900	4	1
6	280	4	2
7	620	3	1
8	880	4	3
end

// Vérification
total ( pre_tax_income hhsize nchild )

/*2.1 suite  
Générer des variables
-	pcincatA: revenu après impôt par habitant avec le scénario A; 
-	pcincatB: revenu après impôt par habitant avec le scénario B;
-	pcuincA:  revenu universel par habitant avec le scénario A;
-	pcuincB:  revenu universel par habitant avec le scénario B;
-	pcallowA:  allocations familiales par enfant avec le scénario A;
-	pcallowB:  allocations familiales par enfant avec le scénario B;
-	dpcincA: revenu disponible par habitant avec le scénario A (pcincatA+ pcuincA+ pcallowA);
-	dpcincB: revenu disponible par habitant avec le scénario B (pcincatB+ pcuincB + pcallowB).*/


gen pcincatA = pre_tax_income * (1.00-0.1)/hhsize
gen pcincatB = pre_tax_income * (1.00-0.1)/hhsize

gen  pcuincA =   6000* 0.1*0.6/30

gen pcuincB =   6000* 0.1*0.0/30

gen  pcallowA = 6000 * 0.1 * 0.4/15
gen pcallowB = 6000*0.1/15

gen dpcincA   = pcincatA+ pcuincA*hhsize+ pcallowA*nchild
gen dpcincB   =  pcincatB+ pcuincB*hhsize + pcallowB*nchild

/*2.2 En utilisant la commande DASP igini, estimez l'inégalité dans la distribution du revenu disponible par habitant pour chacun des deux scénarios. */


igini dpcincA dpcincB , hsize(hhsize)

/*2.3  En utilisant la commande diginis dans DASP, décomposez l'inégalité dans la distribution du revenu disponible par habitant pour chacun des deux scénarios (rappelez-vous que les trois sources de revenu sont pcincatA, pcuincA et pcallowA pour le scénario A et pcincatB, pcuincB et pcallowB le scénario B). */


diginis pcincatA pcuincA pcallowA , hsize(hhsize)
diginis pcincatB pcuincB pcallowB , hsize(hhsize)


 /*2.4  Sur la base des résultats de 2.2 et de 2.3, dans quel cas l'ensemble des programmes de transfert réduira-t-il le plus l'inégalité des revenus disponibles ? Pourquoi ? */
 
 /* Pour comparer  le niveau d'inégalité de la distribution intiale et des deux programmes de transfert*/
 
 //calcul du revenu par habitant avant impôt
 
gen revhbt = pre_tax_income/ hhsize
 
// Comparaison
igini revhbt dpcincA dpcincB , hsize(hhsize)

 
/*Les indices de Gini calculés par rapport aux revenus disponibles indiquent que le scénario B est celui qui réduit le plus l’inégalité des revenus disponibles. 

 
Le scénario B a un coefficient de Gini de 0.25 alors que celui A a un coefficient de 0.2.  Cependant, il convient de souligner que les deux distributions réduisent l’inégalité initiale constatée avec le revenu avant impôt qui était de 0.39. Mais le scénario B réduit plus l’inégalité.
*/
 
 
//2.5  générer le revenu par habitant sans appliquer de programme
gen pcinc = pre_tax_income/hhsize
difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(0)
 
 
 
 cls
  clear
 //Exercice 3***********3%
 
 
 use "C:\Documents\Laval 2021\ECN-6992 Measuring and Alleviating Poverty and Inequality Mesure et allègement de la pauvreté et inégalité H21\Exercices semaines 3,4 et 5\data_1.dta"
 
 //Initialisation du plan d'échantillonnage
 
  svyset psu [pweight=sweight], strata(strata)
  /*3.2	À l'aide de la commande DASP ifgt, estimez le taux de pauvreté lorsque la mesure du bien-être correspond aux dépenses par équivalent adulte et lorsque le seuil de pauvreté est égal à 21 000.*/
  
  ifgt ae_exp, pline(21000) hs( hsize)
  
  /*3.3	Estimez maintenant le taux de pauvreté par groupes de population (définie par le sexe du chef de ménage)*/
  
  ifgt ae_exp, pline(21000) hs( hsize) hgroup(sex) 

  /*Discussions des réultats

Lorsque la mesure du bien-être correspond aux dépenses par équivalent adulte et lorsque le seuil de pauvreté est égal à 21 000, les indices de pauvreté IFGT estimés indiquent le taux de pauvreté est de 33.27% avec un écart type de 0.014. Environ le tiers de la population est considéré comme pauvre avec un seuil de pauvreté de 21 000. 

La proportion des ménages dirigés par les femmes est plus grande sous le seuil de pauvreté. En d’autres termes, 37.15% des ménages dirigés par les femmes sont pauvres contre 32.14% pour les ménages dirigés par les hommes. Le taux des femmes est plus élevé que le taux national.   
*/
  
  
  
  
  
  
  