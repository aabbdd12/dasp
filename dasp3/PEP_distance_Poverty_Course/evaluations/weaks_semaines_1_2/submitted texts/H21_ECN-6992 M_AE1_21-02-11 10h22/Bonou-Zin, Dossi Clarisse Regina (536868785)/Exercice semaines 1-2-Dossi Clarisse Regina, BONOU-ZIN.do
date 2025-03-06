*****************10.5%


// Code stata pour l'exercice 1******3%

clear

/*Saisir de la base de donnees*/
clear
input		identif		region		income		hhsize
			1			1			310			4
			2			1			460			6
			3			1			300			5
			4			1			220			3
			5			2			560			2
			6			2			400			4
			7			3			140			3
			8			3			250			2
			9			3			340			2
			10			3			220			2
end

//Q1:
/* Generer le revenu par habtant pcinc*/

gen pcinc = income/hhsize

//Q2:
/* Estimation du revenu moyen par habitant avec stata*/

sum pcinc [aw=hhsize]

/* Estimation du revenu total de la population*/

total income

//Q3:
/* Generer la ligne de pauvrete*/

gen pline = 120

/* Generer la variable intensite de pauvrete*/

gen pgap = (pline-pcinc)/pline if (pcinc<pline)
replace pgap = 0 if pgap==.

/* Estimation moyenne de l'intensite de la pauvrete*/
sum pgap [aw=hhsize]

//Q4:
/* Estimation du seuil de pauvrete avec dasp*/
ifgt pcinc, pline(120) alpha(1) hsize(hhsize)

//Q5:
/* Generer la variable deflator*/

gen deflator = 1
replace deflator = 0.8 if region ==2
replace deflator = 0.6 if region==3

/* Generer le revenu reel rpcinc par habitant */
gen rpcinc = pcinc/deflator
sum rpcinc [aw=hhsize]


//Q6:
/* Estimation intensite de pauvrete*/
gen pline1 = 110
gen pgap1 = (pline1-rpcinc)/pline1 if (rpcinc<pline1)
replace pgap1 = 0 if pgap1==.
sum pgap1 [aw=hhsize]


/* Estimation intensite de pauvrete avec dasp*/

ifgt rpcinc, pline(110) alpha(1) hsize(hhsize)



// Code stata pour exercice 2***3%
clear
// charger la base de donnees data_2

use "D:\Cours  renforcement PEP\Analyse de la pauvrete\Evaluation\Evaluation semaine 1_2\data_2.dta" 


/*Q1: Estimation des dépenses moyennes en utilisant la commande imean de dasp*/


imean ae_exp, hsize(hhsize)

//Q2: Initialiser le plan d'echantillonnnage

svyset _n [pweight=sweight], strata(strata)
gen numerateur = hhsize*ae_exp
gen denominateur = hhsize
svy: ratio numerateur/denominateur

//Q3:
/* Estimation de la depense moyenne par equivalent adulte par region*/

imean ae_exp, hgroup(region)

/* verification si la depense moyenne par equivalent adulte dans la region 1 est superieur au double de la region 3*/
/* La moyenne de la region 1 est 56417.69  et celle de la region 3 est 22720.63*/
/*L'hypothèse revient à verifier si la difference de depense moyenne entre la region 1 et la region 3 est superieure à 22720.63*/

dimean ae_exp ae_exp, hsize1(hhsize) test(22720.63) cond1(region==3) hsize2(hhsize) cond2(region==1) conf(ub)

/* Le test statistique est 98.26 superieur à 5% donc nous acceptons l'hypothèse que la difference de depense moyenne est > 22720.63. Donc la depense moyenne par equivalent adulte dans la region 1 est superieur au double de la region 3*/

//Q4:
/*Verification si la depense des chefs de menage homme est plus eleve que celle des chefs menage femme*/
/* Cela revient à tester si la difference de revenu mean_homme - mean_homme >0*/

dimean ae_exp ae_exp, hsize1(hhsize) test (0) cond1(sex==2) hsize2(hhsize) cond2(sex==1) conf(ub)

/*Le test statistique est 63.21 supérieur à 5% donc lhypothese selon laquelle la difference est >0 est acceptée. Donc la depense moyenne par equivalent adulte des hommes est plus élevé que celle des femmes*/






// Code stata pour l'exercice 3****4.5%

//Q1: 
/*calculer la taille de la population des ménages echantillonne*/


total hhsize

//Q2:
/* Ordonner les depenses par habitant*/

sort pcexp

/* Generer la variable de la proportion de la population*/
sum hhsize
gen ps = hhsize/r(sum)

/* Generer la variable centiles p*/

gen p = sum(ps)

/*Generer la variable quantile q*/

gen q = pcexp


//Q3:
/* Dessiner la courbe de distribution cumulative*/

cnpe pcexp, xvar(p) type(npr) min(0) max(0.95) ytitle(Dépenses par habitant (F(p))) xtitle(Les centiles (p)) xscale(range(0 0.95)) title(Courbe de distribution cumulative);

//Q4:
/* la courbe des quantiles*/

c_quantile q, min(0.0) max(0.95) ytitle(Quantiles Q(p)) xtitle(Centiles (p)) title(Courbe des quantiles)

//Q5:
/* Courbes des quantiles selon le sexe de la tete du menage à l'aide de dasp*/
c_quantile q, hgroup(sex) min(0.0) max(0.95) ytitle(Quantiles (Q)) xtitle(Centiles (p)) xscale(range(0 0.95)) title(Courbe des quantiles)

//Q6:
/* Courbe de densité des dépenses par habitant*/
cdensity pcexp, hgroup(zone) min(0) max(1000000) title(Courbe de densité des dépenses par habitant)



