******12,5%

*Exercices 3,4,5 - Dufour, Johany 

clear
set more off

**************************************** Exercice 1 *******************4%

* Commençons par ajouter les données 
input group inc1 inc2 inc3
1 1 8 2
1 2 8 4
1 9 8 18
2 3 24 2
2 6 24 4
2 27 24 18
end

** Question 1.1 a)

igini inc1, hgroup(group)
* Le coefficient de Gini pour le groupe 1 vaut 0,444 et le coefficient pour le groupe 2 parmi la distribution inc1 vaut également 0,444. Cela confirme que le principe d'invariance s'applique. 

** Question 1.1 b)
igini inc1 
igini inc1, hgroup(group)

* On voit bien que le coefficient de Gini du groupe 1 est de 0,444 tandis que le coefficient de Gini pour la population totale (dans l'échantillon inc1) est de 0,535. Ainsi, l'inégalité est plus important lorsque l'on considére la population totale que lorsqu'on regarde les groupes séparément. 

** Question 1.1 c)

* On veut regarder si l'entropie entre les groupes de inc1 est égale à l'entropie entre les groupes de inc2. 
dentropyg inc1, hgroup(group) theta(0)
dentropyg inc2, hgroup(group) theta(0)

*On voit que l'indice d'entropie entre les groupes pour la première période (inc1) vaut 0.143841 avec une erreur-type de 0.200174. On voit également que l'indice d'entropie entre les groupes pour la seconde période (inc2) vaut 0.143841 avec une erreur-type de 0.02205. Ainsi, l'erreur-type change légèrement, mais l'énoncé est vrai. 

** Question 1.2

*On utilise dentropyg pour décomposer l'indice d'entropie pour chacune des trois périodes

dentropyg inc1, hgroup(group) theta(0)
dentropyg inc2, hgroup(group) theta(0)
dentropyg inc3, hgroup(group) theta(0)

** Pour la première période (inc1) : L'indice d'entropie du groupe 1 est égal à l'indice d'entropie du groupe 2, soit 0,422837 avec une erreur-type de 0,11465. Les contributions relatives et absolues de chacun des groupes à l'entropie totale sont égales. L'entropie au sein des groupes vaut 0.422837 avec une erreur-type de 0.081070, soit la même entropie que pour chacun des groupes, mais avec une erreur-type moins élevée. L'entropie entre les groupes vaut 0.143841 avec une erreur-type de 0.200174. L'entropie de la population (tous groupes) est composée de l'entropie au sein des groupes et de l'entropie entre les groupes et vaut 0,566678 avec une erreur-type de 0,215967. 

** Pour la deuxième période (inc2) : L'indice d'entropie du groupe 1 est égal à l'indice d'entropie du groupe 2, mais elles sont nulles. L'entropie (ou l'inégalité) au sein des groupes est nulle, mais il y a de l'inégalité entre les groupes. L'indice d'entropie entre les groupes est de 0.143841 avec une erreur-type de 0.02205. L'entropie de la population (tous groupes) est composée uniquement de l'entropie entre les groupes et vaut alors 0.143841 avec une erreur-type de 0.02205. 

** Pour la troisième période (inc3) : L'indice d'entropie du groupe 1 est égal à l'indice d'entropie du groupe 2, soit 0.422837 avec une erreur-type de 0.11465. Les contributions absolues et relatives de chacun des groupes à l'entropie totale sont égales. L'entropie (ou l'inégalité) entre les groupes est nulle, mais il y a de l'inégalité au sein des groupes. L'indice d'entropie au sein des groupes est égale à l'entropie des groupes, naturellement, mais avec une erreur-type moins élevée. L'entropie de la population (tous groupes) est composée uniquement de l'entropie au sein des groupes et vaut alors 0.422837 avec une erreur-type de 0.08107. 


** Question 1.3 

igini inc*

* Cette commande estime l'inégalité de chacune des trois distributions, soit pour chacune des périodes. Plus l'indice de Gini est près de zéro, plus les revenus sont égaux ou plus l'inégalité est faible. À l'inverse, plus l'indice de Gini est près de 1, plus l'inégalité est forte. On remarque que l'inégalité est la plus forte lors de la première période, soit une valeur d'indice de Gini de 0.534722 pour inc1. L'inégalité est la plus faible pour la deuxième période (inc2) avec une valeur de l'indice de Gini de 0.25. Ainsi, les revenus sont mieux distribuées (de manière plus égale) lors de la deuxième période. La troisième période a un indice de Gini de 0.4444 et se situe ainsi entre les deux en matière d'inégalité des revenus. 




**************************************** Exercice 2 *********************5%
clear 
set more off 

*Commençons par entrer les données. 

input id pre_tax_income hhsize nchild
1 240 4 2
2 600 5 3
3 230 3 2
4 1250 3 1
5 1900 4 1
6 280 4 2
7 620 3 1
8 880 4 3
end

*** Question 2.1 *** 

gen pcincatA = pre_tax_income * (1.00-0.10)/hhsize
gen pcincatB = pre_tax_income * (1.00-0.10)/hhsize

scalar pcu_all_A = 0.10 * 6000 
gen pcuincA = 0.6 * pcu_all_A
gen pcuincB = 0

scalar child_all_B = 6000 * 0.10 / 15
gen pcallowB = nchild * child_all_B / hhsize
gen pcallowA = nchild * 0.4 * pcu_all_A / hhsize

gen dpcincA = pcincatA + pcuincA + pcallowA
gen dpcincB = pcincatB + pcuincB + pcallowB


*** Question 2.2 ******

igini dpcincA dpcincB , hsize(hhsize)

* Cette commande nous donne les coefficients de Gini pour la scénario A et pour le scénario B. On obtient que le coefficient de Gini vaut 0.094545 avec une erreur-type de 0.014664 pour le scénario A et que le coefficient de gini vaut 0.348667 avec une erreur-type de 0.248557 pour le scénario B. 


*** Question 2.3 ***** 

diginis pcincatA pcuincA pcallowA, hsize(hhsize)
diginis pcincatB pcuincB pcallowB, hsize(hhsize)

* Voir le document word pour une interprétation. 

*** Question 2.4 ***** 
* Voir le document word


*** Question 2.5 ***** 
* Nous devons d'abord générer le revenu par habitant sans scénario (avant les scénario)

gen pcinc = pre_tax_income / hhsize

*ensuite on compare les indices de pauvreté dans le cas sans scénario et dans le scénario B. 
difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(0) test(0)

* Les taux de pauvreté avec le scénario B et sans programme sont égaux. 

*** Question 2.6 ***** 

*Je suis le corrigé des exercices de la semaine 5 pour estimer la variation de l'intensité de la pauvreté suite à l'introduction du programme B. 
difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(1) test(0)



**************************************** Exercice 3 *********************3%
clear 
set more off 

*** Question 3.1 ********

* Charger le fichier de données * 
use "D:\Téléchargement Chrome\data_1_2.dta", clear

*Initialiser le plan d'échantillonnage
svyset psu [pweight=sweight], strata(strata)


*** Question 3.2 ********

*Estimer le taux de pauvreté avec la variable ae_exp comme mesure du bien-être et avec un seuil de pauvreté de 21 000. J'utilise la taille du ménage ajusté pour l'échelle de l'adulte équivalent, soit equiv au lieu de hsize
ifgt ae_exp, pline(21000) hs(equiv)



*** Question 3.3 ********

* J'estime le taux de pauvreté par groupe de population en séparant les ménages selon le sexe du chef de ménage. 

ifgt ae_exp, pline(21000) hs(equiv) hgroup(sex)


*** Fin du do-file, merci ! ** 

