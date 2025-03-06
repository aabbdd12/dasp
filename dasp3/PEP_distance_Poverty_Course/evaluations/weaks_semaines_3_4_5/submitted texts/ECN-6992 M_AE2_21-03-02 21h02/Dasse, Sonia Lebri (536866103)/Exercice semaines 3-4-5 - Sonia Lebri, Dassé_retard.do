********12%

* Exercice 1*********3.5%

input Group	inc1	inc2	inc3
1	1	2	2
1	2	2	4
1	9	2	18
2	3	6	2
2	6	6	4
2	27	6	18
end

*Q1.1  */Commentaire: justifier vos réponses*/

*a/Vrai */Commentaire: justification: La distribution des revenus du groupe 2 est similaire à celle du premier groupe, sauf que les revenus sont mutpliés sur une échelle de 3. Comme les indices d'inégalité relative, comme l'indice de Gini, obéissent au principe de l'invariance d'échelle, l'inégalité des deux groupes sera la même.*/
igini inc1 inc2 inc3,hgroup(Group)
/* On peut également utiliser la commande: igini inc*,hgroup(Group)*/

*b/Faux /*Commentaire Justification: Lorsque les moyennes des revenus des deux groupes sont différentes, nous devons considérer la contribution de l'inégalité entre les groupes à l'inégalité totale. 
*c/Faux 
/* Commentaire Justification: - Avec l'inc1, l'inégalité entre groupes est l'inégalité de la répartition : D1 : (4,4,4,12,12,12) 
- Avec l'inc2, l'inégalité entre groupes est l'inégalité de la répartition : D2 : (2,2,2,6,6,6) 
  Basé sur le principe de l'invariance d'échelle (la distribution D2 est simplement celle de la moitié des revenus de D1),
  L'inégalité entre les groupes dans l'inc1 est donc similaire à celle de l'inc2. */
dentropyg inc1, hgroup(Group) theta(0)
dentropyg inc2, hgroup(Group) theta(0)

*Q1.2
dentropyg inc1, hgroup(Group) theta(0)
dentropyg inc2, hgroup(Group) theta(0)
dentropyg inc3, hgroup(Group) theta(0)

*Q1.3
igini inc*

/*
Dans la première répartition (inc1) le bien-être social est élevé et est égal à celui de la répartition 3 (inc3). Le revenu donc de chaque individu dans cette première répartition (inc1) est plus élevé que ses revenus à la seconde répartition. 
Cependant c’est pour cette première répartition (inc1) que l’inégalité de Gini est la plus grande. De ce fait :
-  Nous ne pouvons pas porter un jugement normatif sur le niveau d'inégalité sans tenir compte du contexte spécifique de chaque pays. 
-- Dans les pays développés, où chaque individu peut être mieux loti même avec l'augmentation des inégalités, nous pouvons être moins réticents à l'augmentation des inégalités. 
-- Dans les pays très pauvres, il peut être préférable de réduire les inégalités pour améliorer les chances de chacun. 
*/

*Exercice 2***********5.5%
clear 
input identifier pre_tax_income hhsize	nchild	nelderly
1	240	4	2	1
2	600	5	3	1
3	230	3	2	0
4	1250	3	1	1
5	1900	4	1	1
6	280	4	2	0
7	620	3	1	1
8	880	4	3	0
end

*Q2.1
gen pcincatA = pre_tax_income * (1.00-0.01)/hhsize
gen pcincatB = pre_tax_income * (1.00-0.01)/hhsize

scalar elderly_all_A = 6000*0.02/5
scalar elderly_all_B = 6000*0/5 
gen pceldA = nelderly*elderly_all_A/hhsize
gen pceldB = nelderly*elderly_all_B/hhsize

scalar child_all_A = 6000*0.08/15
scalar child_all_B = 6000*0.1/15
gen pcallowA = nchild*child_all_A/hhsize
gen pcallowB = nchild*child_all_B/hhsize 

gen dpcincA= pcincatA+ pceldA+ pcallowA
gen dpcincB= pcincatB+ pceldB + pcallowB

*Q2.2
igini dpcincA dpcincB , hsize(hhsize)

*Q2.3
diginis pcincatA  pcallowA, hsize(hhsize)
diginis pcincatB  pcallowB, hsize(hhsize)

*Q2.4
** Commenter 
/*
Le scénario B est celui qui a le plus réduit l'inégalité des revenus disponibles.
En effet, ce programme cible efficacement les enfants, et les revenus générés qui leurs sont redistribués ne sont pas diminuées ou réduites par la pension de vieillesse. 
Cela rend également la contribution des allocations familiales plus efficace pour réduire les inégalités.
*/

*Q2.5
// générer le revenu par habitant sans appliquer de programme
gen pcinc = pre_tax_income/hhsize

difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(0)

*Q2.6
difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(1)
/*
Les ménages qui reçoivent des allocations familiales perçoivent une certaine amélioration du bien-être, et cette amélioration est suffisante pour échapper à la pauvreté puisque le programme B a permis la réduction du niveau du taux de pauvreté. Ce taux de pauvreté a été réduit de 0,1 par rapport à la distribution initiale et lorsque le seuil de pauvreté est 100. 
Egalement, l'indice de l’intensité de la pauvreté est sensible à toute amélioration du bien-être des pauvres.
*/

*Ecercice 3******3%
*Q3.1
// Q1
clear
use "data_2.dta" , replace

svyset psu [pweight=sweight], strata(strata)

*Q3.2
ifgt ae_exp, pline(21000) hs(hsize)

*Q3.3
ifgt ae_exp, pline(21000) hs(hsize) hgroup(sex)

/*Le groupe féminin (femmes chefs de ménages) est plus pauvre que le groupe masculin. Egalement, le taux de pauvreté des femmes est plus élevé que pour l’ensemble de la population.
*/
