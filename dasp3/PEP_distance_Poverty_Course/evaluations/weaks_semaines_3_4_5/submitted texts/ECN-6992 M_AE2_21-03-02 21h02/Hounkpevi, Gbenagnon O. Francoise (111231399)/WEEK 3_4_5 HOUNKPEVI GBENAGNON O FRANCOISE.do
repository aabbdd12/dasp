********10,5%


//////////*****************WEEK 3 4 & 5*****************************///////////

*****Etudiante : HOUNKPEVI Gbenagnon O.Francoise*****************************

clear
set more off
net from http://dasp.ecn.ulaval.ca/modules/DASP_V2.3/dasp
net install dasp_p1, force
net install dasp_p2, force
net install dasp_p3, force
net install dasp_p4, force
 _daspmenu  

////////////////////////EXERCICE 1/////////////////////////////2.5%

******importation des données
import excel "C:\Users\lasta\OneDrive\Documents\PEP_2\ONLINE COURSE PAUVRETE\EXO PRATIQUE\Exo week
>  3_4_ 5.xlsx", sheet("Exercice 1") firstrow
(4 vars, 6 obs)

*********CORRECTION ET JUSTIFICATIONS POUR L'EXERCICE 1

/*


// Q1
//a
/*
Cette affirmation est vraie :
La distribution des revenus du groupe 2 est similaire à celle du premier groupe, 
sauf que les revenus sont mutlipliés par une échelle de 3. Puisque les indices d'inégalité relative, comme l'indice de Gini,
obéissent au principe d'invariance d'échelle, l'inégalité des deux groupes sera la même.
*/
clear
input group inc1 inc2 inc3
1 1 2 2
1 2 2 4
1 9 2 18
2 3 6 2
2 6 6 4
2 27 6 18
fin

igini inc1 , hg(group)

//b
/*
Cette affirmation est fausse :
Lorsque les moyennes des revenus des deux groupes sont différentes, il faut considérer la contribution de l'inégalité entre groupes à l'inégalité totale. 
*/

//c
/* 
Cette affirmation est vraie :
- Avec l'inc1, l'inégalité entre groupes est l'inégalité de la distribution : D1 : (4,4,4,12,12,12) 
- Avec l'inc2, l'inégalité entre groupes est l'inégalité de la distribution : D2 : (2,2,2,6,6,6) 
  Selon le principe d'invariance d'échelle (la distribution D2 est simplement celle de la moitié des revenus de D1),
  L'inégalité entre les groupes en inc1 est similaire à celle en inc2. 
 */
 dentropyg inc1, hg(groupe)
 dentropyg inc2, hg(groupe)

Traduit avec www.DeepL.com/Translator (version gratuite)


*/


// 1.2
dentropyg inc1, hgroup(gr) theta(0)
dentropyg inc2, hgroup(gr) theta(0)
dentropyg inc3, hgroup(gr) theta(0)

//1.3 
igini inc1 inc2 inc3


*****************************EXERCICE  2***********5%


********2.1	Dans Stata, entrez les données (les huit observations), puis générez les variables

///// IMPORTATION DES VARIABLES


clear
import excel "C:\Users\lasta\OneDrive\Documents\PEP_2\ONLINE COURSE PAUVRE
> TE\EXO PRATIQUE\Exo week 3_4_ 5.xlsx", sheet("Exercice 2") firstrow
(5 vars, 9 obs)

*****Génération des variables

gen pcincatA = pre_tax_income * (1.00-0.1)/hhsize
gen pcincatB = pre_tax_income * (1.00-0.1)/hhsize

//SCENARIO A: la taxe collectée dans le scenario A est 10% du revenu total (6000) ce qui correspond à : 0.1*6000 et seulement 20% de ce montant est redistribué aux personnes agées  et le restant   80%  va aux enfants. Nous avons  5 personnes agées  et 15 enfants au sein de la population totale. Donc la pension de vieillesse par habitant avec le scénario A : (0.1*6000*0.2)/5 et l'allocations familiales par enfant avec le scénario A .  (0.1*6000*0.8)/15   //********


***lSCENARIO B: la taxe collectée dans le scenario B est 10% du revenu total (6000) ce qui correspond à : 0.1*6000  et la totalité de ce montant est redistribué aux enfants. Nous avons 15 enfants au sein de la population totale. Donc l'allocations familiales par enfant avec le scénario B  est (0.1*6000)/15  et la pension de viellesse est nulle.


**** Suposons que la pension des personnes agées elderly_all et l'allocation familiale des enfants est child_all

////// Pour ce qui concerne les personnes agées 
scalar  elderly_all_A  = 0.1*6000*0.2/5
scalar  elderly_all_B  = 0*6000/5 

gen  pceldA = nelderly*elderly_all_A/hhsize
gen  pceldB = nelderly*elderly_all_B/hhsize


////// Pour ce qui concerne l'allocation familiales des enfants

scalar  child_all_A    = 0.1*6000*0.8/15

scalar  child_all_B    = 0.1*6000/15


gen  pcallowA = nchild*child_all_A/hhsize
gen  pcallowB = nchild*child_all_B/hhsize

*********** Revenu disponible par habitant à l'issue de chaque scénario
gen dpcincA= pcincatA+ pceldA+ pcallowA
gen dpcincB= pcincatB+ pceldB + pcallowB


*******2.2	En utilisant la commande DASP igini, estimez l'inégalité dans la distribution du revenu disponible par habitant pour chacun des deux scénarios.** 

igini dpcincA dpcincB , hsize(hhsize)


********2.3	En utilisant la commande DASP diginis, décomposez l'inégalité dans la distribution du revenu disponible par habitant pour chacun des deux scénarios**

diginis pcincatA  pceldA  pcallowA, hsize(hhsize)
diginis pcincatB  pceldB  pcallowB, hsize(hhsize)
 
/*COMMENT JUSTIFICATION: Le scénario B présente la plus forte réduction de l'inégalité des revenus disponibles.
Cela s'explique par le fait que dans le scénario A, le programme de retraite des personnes âgées bénéficie à toutes les personnes âgées, même si elles sont plus riches en général (dans cet exemple). */


 ************* 2.5	Estimez le changement
 
 *****générons le revenu par habitant sans appliquer de programme
 gen pcinc = pre_tax_income/hhsize
 

 
 difgt dpcincB pcinc, hsize1(hhsize)  hsize2(hhsize) pline1(100) pline2(100) alpha(0)
 
 **********2.6
 
  difgt dpcincB pcinc, hsize1(hhsize)  hsize2(hhsize) pline1(100) pline2(100) alpha(1)
  
  
  
  
  /////////////////EXERCICE 3////////////////////*3%
  
clear
use "C:\Users\lasta\OneDrive\Documents\PEP_2\data_2.dta"

/////3.1
*** Pour iniinitialiser le plan d'échantillonnage du fichier de données, la commande svyset nous le permet
  A titre d'exemple
//*1- sweight: Indique le niveau de représentativité de l'observation.
//*2- psu (abréviation des unités primaires d'échantillonnage).
//*3- strata

svyset psu [pweight=sweight], strata(strata)

/////3.2 
*** la commande ifgt nous permet d'estimer le taux de pauvreté

ifgt ae_exp, pline(21000) hs( hsize)


//// 3.3 
 **** Ici je dois ajouter la variable sexe pour refaire l'estimation 3.2
ifgt ae_exp, pline(21000) hs( hsize) hgroup(sex)



