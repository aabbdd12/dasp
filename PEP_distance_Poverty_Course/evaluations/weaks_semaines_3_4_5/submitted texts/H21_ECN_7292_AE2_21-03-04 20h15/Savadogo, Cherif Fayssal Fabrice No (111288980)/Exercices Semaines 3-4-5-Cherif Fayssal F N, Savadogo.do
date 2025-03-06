********11,5

//Exercice 1*4%
//1.1)	Pour la distribution inc1, indiquez si les affirmations suivantes sont vraies ou fausses, et pourquoi

// Saisie des données
clear
input group inc1 inc2 inc3
1 1 2 2
1 2 2 4
1 9 2 18
2 3 6 2
2 6 6 4
2 27 6 18
end

//a)  
igini inc1, hgroup(group)
//VRAI : Le coefficient de Gini du groupe 1 est égale à celui du groupe 2. Par conséquent l'inégalité de revenu du groupe 1 est égale à celle du groupe 2. 

//b)
igini inc1, hgroup(group)
// FAUX : Le coefficient de Gini du groupe 1 est différent de celui de la Population. Par conséquent l'inégalité de revenu du groupe 1 n'est pas égale à celle de la population totale. 

//c)
dentropyg inc1, hgroup(gr) theta(0)
dentropyg inc2, hgroup(gr) theta(0)
//FAUX : L'indice d'entropie de la population de inc1 est différent de celui de la population de inc2. Par conséquent l'inégalité entre les groupes de inc1 n'est pas égale à celle de inc2.


//1.2) En utilisant la commande DASP dentropyg, décomposez l'indice d’entropie (le paramètre theta = 0). Faites cela pour chacune des trois périodes.
dentropyg inc1, hgroup(gr) theta(0)
dentropyg inc2, hgroup(gr) theta(0)
dentropyg inc3, hgroup(gr) theta(0)


//1.3) Estimez l'inégalité de Gini pour chacune des trois distributions avec la commande DASP igini et discutez vos résultats.
igini inc1 inc2 inc3

//L'inégalité de revenu dans la premiere distribution est la plus grande. Vient ensuite celle de la troisieme distribution et enfin celle de la premiere distribution.







// Exercice 2***4,5%
clear
//Saisie des données
input identifier pre_tax_income hhsize nchild nelderly
1 240 4 2 1
2 600 5 3 1
3 230 3 2 0
4 1250 3 1 1
5 1900 4 1 1
6 280 4 2 0
7 620 3 1 1
8 880 4 3 0
end

//2.1) Générons les variables
generate pcincatA = pre_tax_income * (1-0.1)/hhsize
generate pcincatB = pre_tax_income * (1-0.1)/hhsize

scalar elderly_all_A = 6000 * 0.2 * 0.1/5

generate pceldA = nelderly * elderly_all_A/hhsize
generate pceldB = 0

qui sum nchild
scalar child_all_A = 6000 * 0.8 * 0.1/r(sum)
scalar child_all_B = 6000 * 0.1/r(sum)

generate pcallowA = nchild * child_all_A/hhsize
generate pcallowB = nchild * child_all_B/hhsize

generate dpcincA = pcincatA + pceldA + pcallowA
generate dpcincB = pcincatB + pceldB + pcallowB


//2.2) En utilisant la commande DASP igini, estimez l'inégalité dans la distribution du revenu disponible par habitant pour chacun des deux scénarios

igini dpcincA dpcincB , hsize(hhsize)

//2.3) En utilisant la commande DASP diginis, décomposez l'inégalité dans la distribution du revenu disponible par habitant pour chacun des deux scénarios (rappelez-vous que les trois sources de revenu sont pcincatA, pceldA et pcallowA pour le scénario A et pcincatB, pceldB et pcallowB pour le scénario B). 

diginis pcincatA pceldA pcallowA, hsize(hhsize)
diginis pcincatB pceldB pcallowB, hsize(hhsize)


//2.4) Le scénario A est l'ensemble des programmes de transfert qui réduira le plus l'inégalité des revenus possibles parce qu'il touche touche toutes les entités possibles, des enfants aux vieilles personnes.


//2.5) 	Estimez le changement du taux de pauvreté lorsque le scénario B est adopté (par rapport à la distribution initiale) et que le seuil de pauvreté est 100 (utilisez la commande DASP difgt)
//le revenu par habitant
generate pcinc = pre_tax_income/hhsize

difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(0)



//2.6) Estimez le changement dans l’intensité de la pauvreté lié au scénario B (par rapport à la distribution initiale) et lorsque le seuil de pauvreté est de 100 (utilisez la commande DASP difgt). Comparez les résultats trouvés ici avec ceux trouvés au point précédent (2.5).

difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(1)

//Nous remarquons que le niveau du taux de pauvreté reste inchangé tandis que l'indice de l'intensité de la pauvreté est sensible à toute amélioration du bien-être des pauvres.
//Nous pouvons donc conclure qu'il y'a une certaine amélioration du bien-être chez les ménages qui reçoivent des allocations familiales, bien que cette amélioration n'est pas suffisante pour sortir de la pauvreté.







//Exercice 3**3%

//3.1)	Chargez le fichier data_2, puis initialisez le plan d'échantillonnage avec les variables strata, psu et sweight
clear
use "data_prac.dta" , replace

svyset psu [pweight=sweight], strata(strata)

//3.2) 3.2	À l'aide de la commande DASP ifgt, estimez le taux de pauvreté lorsque la mesure du bien-être correspond aux dépenses par équivalent adulte, et lorsque le seuil de pauvreté est égal à 21 000

ifgt ae_exp, pline(21000) hs(hsize)


//3.3	Estimez maintenant le taux de pauvreté par groupes de population (définie par le sexe du chef de ménage) et discutez vos résultats

ifgt ae_exp, pline(21000) hs(hsize) hgroup(sex)

// Nous constatons que l'indice du taux de pauvreté chez le groupe des ménages dirigés par une femmes est supérieur à celui du groupe des ménages dirigés par un homme.

