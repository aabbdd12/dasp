**************12,5%


//code sata pour les exercices du devoir semaine 3 4 5

//Exercice 1******4%
//Q 1.1
//a
/* Insertion des données */
clear

input  Group inc1 inc2 inc3
   1 1 2 2
   1 2 2 4
   1 9 2 18
   2 3 6 2
   2 6 6 4
   2 27 6 18
end

/* estimation du coefficient de Gini par groupe de population: nous utilisons la commande DASP igini */

//b
/*Cette affirmation est vrai car le revenu obtenu pour le groupe 2 est une simple reproduction du revenu du groupe 1 à la période 3 (principe de population), à la période 1 et 2 le revenu du groupe 2 est obtenu est multipliant par 3 le revenu du groupe 1 (principe d’invariance d’échelle) . */  

//c
/*Cette affirmation est vraie pour la contribution absolue et fausse pour la contribution relative. */  
/* Pour la période 1  */
dentropyg inc1, hgroup(Group) theta(0)
/* Pour la période 2*/
dentropyg inc2, hgroup(Group) theta(0)

//Q 1.2
/*Décompositon de l'indice d'entropie pour theta =0 à l'aide de la commande DASP dentropyg */
/* Pour la période 1*/
dentropyg inc1, hgroup(Group) theta(0)
/* Pour la période 2*/
dentropyg inc2, hgroup(Group) theta(0)
/* Pour la période 3*/
dentropyg inc3, hgroup(Group) theta(0) 

//*La commande DASP dentropyg permet de décomposer l'inégalité d'entropie totale par groupes de population et permet ainsi d'estimer les inégalités intragroupe et intergroupe. Pour la période 1, on obtient les résultats suivants : 
Au niveau de la population, l'indice d'entropie est égal à 0,566678 avec une erreur-type de 0.215967. Pour le groupe1, ainsi que pour le groupe2, l'indice d'entropie est égal à 0.422837 avec une erreur standard de 0.114650. La contribution relative et absolue des inégalités intragroupes est plus importante que celle des inégalités intergroupes. Ainsi à la période 1, l’inégalité intragroupe contribue relativement à 74.62% de l’inégalité totale. */


//Q 1.3
/*Estimation de l’inégalité de Gini pour chacune des trois distributions avec la commande DASP igini */
igini inc1 inc2 inc3
/*Le coefficient de Gini à la période 1 est le plus élevé, soit 0.53 et celui de la période 2 est le plus faible (0.25) ; Ainsi l’inégalité de revenu est plus importante à la période et plus moindre à la période 2 ; à la période 3, elle est relativement élevée.*/

// Exercice 2//**5,5%

clear
//Q 2.1

/*Insertion des données*/
input identifier pre_tax_income hhsize nchild nelderly
  1. 240 4 2 1
  2. 600 5 3 1
  3. 230 3 2 0
  4. 1250 3 1 1
  5. 1900 4 1 1
  6. 280 4 2 0
  7. 620 3 1 1
  8. 880 4 3 0
end

/*Génération des variables*/
/*Pour un ménage donné, son revenu après impôt dans le Scénario A ou B est égal à son revenu avant impôt (pre_tax_income) moins 10% de ce revenu c'est à dire: « post_tax_income=pre_tax_income*(1-0.10) ».  Ainsi, le revenu après impôt par habitant avec le scénario A ou B est obtenu en divisant le revenu après impôt par la taille du ménage, on a donc: */
gen pcincatA = pre_tax_income * (1.00-0.10)/hhsize
gen pcincatB = pre_tax_income * (1.00-0.10)/hhsize
list 
/* lorsqu'on affiche les données avec la commande 'list', on constate que ces deux revenus ‘pcincatA’ et ‘pcincatB’ sont identiques après prélèvement de la même proportion d'impôt proportionnel de 10% */

/*L'impôt collecté dans le scénario A et B est également identique, soit 10% du revenu total et il est de "0.1*6000". Cependant,la redistibution diffère pour chaque scénario.*/
/*  Dans le scénario A, nous avons 5 retraités qui bénéficient de 20% de l'impôt collecté pour la pension retraite, soit 0.2*(0.1*6000)/5 et 15 enfants bénéficiant du reste de l'impôt collecté sous forme d'allocations familiales, soit (1-0.2)*(0.1*6000)/15. Avec la commande scalar, nous pourrons stocker ces 2 valeurs dans la mémoire de Stata pour une utilisation ultérieure */ 
scalar eld_all_A = 0.2*(0.1*6000)/5
scalar child_all_A = (1-0.2)*(0.1*6000)/15

/*  Dans le scénario B, seuls les enfants bénéficient de la totalité de l'impôt collecté sous forme d'allocations familiales, soit (0.1*6000)/15; il n'y a pas de pension retraite dans ce scénario B*/ 
scalar eld_all_B = 0*(0.1*6000)/5
scalar child_all_B = 0.1*6000/15

/* La pension de vieillesse par habitant avec le scénario A et B est comme suit: */
gen pceldA= nelderly*eld_all_A/hhsize
gen pceldB= nelderly*eld_all_B/hhsize
 
/*allocations familiales par enfant avec le scénario A et B */
gen  pcallowA = nchild*child_all_A/hhsize
gen  pcallowB = nchild*child_all_B/hhsize 

/*revenu disponible par habitant avec le scénario A et B */
gen dpcincA= pcincatA+ pceldA+ pcallowA
gen dpcincB= pcincatB+ pceldB+ pcallowB

//Q2.2
/*estimation de l'inégalité dans la distribution du revenu disponible par habitant pour chacun des deux scénarios*/
igini dpcincA dpcincB, hsize(hhsize) 
/* on constate que l'indice de Gini dans le scénario B est plus faible, ce qui traduit que l’inégalité dans le scénario B est moins accentuée que celle du scénario A, soit 0.348667< 0.352933 */

//Q2.3
/* décomposition de l'inégalité dans la distribution du revenu disponible par habitant pour chacun des deux scénarios */
/* scénario A */
diginis pcincatA pceldA pcallowA, hsize(hhsize)
/* scénario B */
diginis pcincatB pceldB pcallowB, hsize(hhsize)

//Q2.4
/* Sur la base des résultats de 2.2 et 2.3, on constate que le scénario B est celui qui a le plus réduit l'inégalité des revenus disponibles. La redistribution dans ce programme concerne exclusivement les allocations familiales. De plus, par sources de revenu c’est-à-dire pcincatA pceldA pcallowA, la source de revenu pcallowA qui est celle des allocations familiales contribue à réduire l’inégalité totale dans les 2 scénarios A et B. On peut ainsi conclure que la redistribution par les allocations familiales est une bonne politique de réduction des inégalités. */

//Q2.5
/* génération du revenu par habitant sans programme de redistribution*/
gen pcinc = pre_tax_income/hhsize
/* estimation du changement du taux de pauvreté lorsque le scénario B est adopté */
difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(0)

/* Sans allocations familiales c’est-à-dire pour la distribution sans programme de transfert (distribution initiale), le taux de pauvreté est de 36.87% et est identique à celui du scénario B c’est-à-dire avec allocations familiales; ainsi, l’adoption du scénario B n’a pas réduit le taux de pauvreté ; la différence nulle est statistiquement significative au seuil de 10% */

//Q2.6
/* Estimation du changement dans l’intensité de la pauvreté liée au scénario B */
difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(1)

/* Ici l’intensité de la pauvreté a baissé en présence d’allocation familiale en comparaison à la distribution initiale sans politique de transfert. Ainsi, on constate que sans allocation familiale, l’intensité de pauvreté qui était de 11.67% est passé à 6.17% en présence du scénario B (avec allocation familiale). La différence ou la baisse est ainsi de 5.5% et est statistiquement significatif au taux de 10%. On peut conclure que l’intensité de la pauvreté est sensible à toute amélioration du bien-être du ménage ; a contrario, le taux de pauvreté inchangé montre que cette amélioration du bien-être à travers les allocations a été insuffisant pour réduire le taux de pauvreté initial. */


// Exercice 3//*******3%

clear
//Q 3.1
/*Chargement du fichier de données. */
use " data_2" , replace

/*La commande svyset nous permet d'initialiser le plan d'échantillonnage du fichier de données. */
svyset psu [pweight=sweight], strata(strata)

//Q 3.2
: /* estimation du taux de pauvreté */
ifgt ae_exp, pline(21000) hs( hsize)
 /*Le taux de pauvreté est de 33.67% */

//Q 3.3
/*Estimation du taux de pauvreté par groupes de population (définie par le sexe du chef de ménage) */
ifgt ae_exp, pline(21000) hs( hsize) hgroup(sex) 
/* ici, l'option hgroup(sex) est intégré avec: 1- Groupe de ménages dirigés par des hommes; 2-Groupe de ménages dirigés par une femme. */ 
/* le taux de pauvreté chez les hommes chefs de ménage est de 32.49% et il est de 37.94% chez les femmes chefs de ménages ; on voit bien que le taux de pauvreté chez les chefs de ménages femmes est plus élevé que celui des chefs de ménage hommes. Ainsi, toute politique de réduction de ce taux doit aussi tenir compte de la variable genre*/




