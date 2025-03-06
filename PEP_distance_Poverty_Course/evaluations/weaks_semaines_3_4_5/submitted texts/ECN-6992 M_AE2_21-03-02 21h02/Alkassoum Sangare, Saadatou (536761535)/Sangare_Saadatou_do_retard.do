*************9.5%


//Stata code for the Practical exercise 3, 4, 5

***********4%
/* En insérant les données */
input group inc1 inc2 inc3
1  1  8 2
1  2  8 4
1  9  8 18
2  3 24 2
2  6 24 4
2 27 24 18
end

/*1.1. Estimation du coefficient de Gini par groupe de population
igini inc1, hgroup(gr)*/

dentropyg inc1, hgroup(gr) theta(0) 
dentropyg inc2, hgroup(gr) theta(0)

/*1.2. Décomposition de l’indice d’entropie (le paramètre theta = 0) pour les 3 periodes*/  
dentropyg inc1, hgroup(gr) theta(0) 
dentropyg inc2, hgroup(gr) theta(0) 
dentropyg inc3, hgroup(gr) theta(0) 

/*1.3. Estimation de l'inegalite de Gini de chacue des 3 distributions*/

igini inc*


//Stata code for the Practical Exercice 2 **********5.5%
clear
/*Insertion des données*/

input identifier pre_tax_income hhsize nchild
1  240  4  2
2  600  5  3
3  230  3  2
4  1250 3  1
5  1900 4  1
6  280  4  2
7  620  3  1
8  880  4  3
end
/*2.1. Creation des variables*/
/*
Pour un menage donne, le revenu apres impot par habitant dans les 2 scenario  est egal au revenu avant impot moins 10% du revenu avant impot divise par la taille.
*/
gen pcincatA = pre_tax_income * (1.00-0.1)/hhsize
gen pcincatB = pre_tax_income * (1.00-0.1)/hhsize

/*
Le revenu universel par habitant est egal dans le scenario A a 10% du revenu total divise par la taille.*/
qui sum hhsize
gen pcuincA = (pre_tax_income*0.1*0.6)/r(sum)
gen pcuincB = (pre_tax_income*0.1*0)/r(sum)
/*
Nous avons 15 enfants dans notre population. Donc les allocations familiales par enfant dans le scenario A representent 40% du budget divise par le nombre d'enfants*/
qui sum nchild
gen pcallowA = (pre_tax_income*0.1*0.4)/r(sum)

/*Les allocations familiales par enfant dans le scenario B representent 40% des revenus generes divise par le nombre d'enfants*/
gen pcallowB = (pre_tax_income*0.1)/r(sum)

/*Le revenu disponible par habitant est egal a la somme du revenu apres impot, du revenu universel et des allocations familiales par enfant.*/
gen dpcincA = pcincatA + pcuincA + pcallowA
gen dpcincB = pcincatB + pcuincB + pcallowB

/*2.2. Calcul de l'inegalite de Gini*/
igini dpcincA dpcincB, hsize(hhsize)

//Q2.3.Décomposition de l'inégalité dans la distribution du revenu disponible par habitant pour chacun des deux scénarios 
diginis pcincatA pcuincA pcallowA, hsize(hhsize)
diginis pcincatB pcuincB pcallowB, hsize(hhsize)

// Q2.5 Estimation du changement du taux de pauvreté lié au programme B (par rapport à la distribution initiale) lorsque le seuil de pauvreté est 100
gen pcinc = pre_tax_income/hhsize
difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(0)

// Q2.6 Estimation de l'intensite du taux de pauvreté lié au programme B (par rapport à la distribution initiale) lorsque le seuil de pauvreté est 100
difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(1)
/*
Les ménages qui reçoivent des allocations familiales perçoivent une certaine
amélioration du bien-être, mais cette amélioration n'est pas suffisante pour échapper à la pauvreté.
C'est ce qui explique le niveau inchangé du taux de pauvreté. À l'opposé, l'indice de l’intensité de la pauvreté est sensible à toute amélioration du bien-être des pauvres.
*/


