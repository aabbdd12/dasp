**************12%



//Code stata exercice 1*****4%

clear

/*Q1: Insection des donnees*/

input	group	inc1	inc2	inc3
		1		1		2		2
		1		2		2		4
		1		9		2		18
		2		3		6		2
		2		6		6		4
		2		27		6		18
end

*a: Estimation de l'indice de gini par groupe pour la première période
igini inc1, hgroup(group)

*c: utilisation de la commande dentropyg

dentropyg inc1, hgroup(group) theta(0)
dentropyg inc2, hgroup(group) theta(0)

/*Q2: Décomposition de l'indice d'entropie à l'aide de la commande dentropyg*/
dentropyg inc1, hgroup(group) theta(0)
dentropyg inc2, hgroup(group) theta(0)
dentropyg inc3, hgroup(group) theta(0)

/*Q3: Estimation de l'inégalité de Gini pour chacune des trois distributions*/

igini inc*



********************************Code stata exercice 2**************************************5%
clear

//Q1:
*Insection des données

input	ident	pre_tax_income	hhsize	nchild	nelderly
		1		240				4		2		1
		2		600				5		3		1
		3		230				3		2		0	
		4		1250			3		1		1
		5		1900			4		1		1
		6		280				4		2		0
		7		620				3		1		1
		8		880				4		3		0
end

*Les revenus après impots par habitant avec les scénario A et B
*Le revenu après taxe pour le scénario A est identique à celui du scénario 2 car l'impot appliquer est de 10% dans chacune des 2 scénario. Le revenu après taxe est obtenir en soustrayant les taxes perçues (pre_taxe_income*0.1) du revenu avant taxe.

gen pcincatA = pre_tax_income*(1-0.1)/hhsize

gen pcincatB = pre_tax_income*(1-0.1)/hhsize

*Les pensions de vieillesse par habitant avec les scénarios A et B
*Pour le scénario A, seulement 20% du total des taxes perçues (6000*0.1) est redistribué sous forme de pension de vieillesse. Le nombre total de vieillard étant 5, la pension pour chaque individus est alors (6000*0.1)*0.2/5. Le revenu issu de la pension est alors égale à la pension individuelle que multiplie le nombre de vieillard.

scalar eld_A = (6000*0.10)*0.20/5
gen pceldA = nelderly*eld_A/hhsize

*Pour le scéario B, la pension de vieillesse universelle est nulle

gen pceldB = 0

*Les allocations familiales par habitant avec les scenarios A et B
*Pour le scénario A, 20% des taxes (6000*0.1) étant affectée à la pension, la part affectée aux allocations familiales est (6000*0.1)*(1-0.2). Cette part est divisée par 15 (nombre total d'enfant pour avoir la part qui revient à chaque enfant). Pour avoir l'allocation par ménage il faut multiplié la part de chaque enfant par le nombre d'enfant dans chaque ménage.

scalar child_A = (6000*0.10)*(1-0.2)/15

*Le scénario B n'ayant pas de pension toute la taxe collectée (6000*0.1) est réverser pour allocation familale

scalar child_B = 6000*0.1/15

gen pcallowA = nchild*child_A/hhsize
gen pcallowB = nchild*child_B/hhsize

*Les revenus disponible par habitant avec les scenarios A et B

gen dpcincA = pcincatA + pceldA + pcallowA
gen dpcincB = pcincatB + pceldB + pcallowB

list pcincatA pcincatB pceldA pceldB pcallowA pcallowB dpcincA dpcincB

/*Q2: Estimation de l'inégalité dans la distribution du revenu suivant les scenario*/

igini dpcincA dpcincB, hsize(hhsize)

/*Q3: Décomposition de l'inégalité dans la distribution du revenu*/

diginis pcincatA pceldA pcallowA, hsize(hhsize)
diginis pcincatB pceldB pcallowB, hsize(hhsize)

/*Estimation du changement du taux de pauvreté lorsque le scénario B est adopté*/
* Le revenu par habitant pcinc de la situation initiale
gen pcinc = pre_tax_income/hhsize

*Changement du taux de pauvreté

difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(0) test(0)

/*Q5: Estimation du changement dans l'intensité de la pauvreté*/

difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(1) test(0)


******************Code stata exercice 3****************************3%

clear 

use "D:\Cours  renforcement PEP\Analyse de la pauvrete\Evaluation\Evaluation semaine 3_4_5\data_2.dta"

/*Q1: Initialisation du plan d'échantillonnage*/

svyset psu [pweight=sweight], strata(strata)

/*Q2: Estimation du taux de pauvreté*/

ifgt ae_exp, alpha(0) hsize(hsize) pline(21000)

/*Q3: Estimation du taux de pauvreté par groupe de population*/

ifgt ae_exp, alpha(0) hsize(hsize) hg(sex) pline(21000)

*Test de différence entre homme et femmes

difgt ae_exp ae_exp, alpha(0) hsize1(hsize) test(0) cond1(sex==1 ) hsize2(hsize) cond2(sex==2 ) pline1(21000) pline2(21000)


