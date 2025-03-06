************11.5%

clear
_daspmenu

***************************************************************************
//code Stata : Évaluation | Dias, Rafael | Exercice 1-2 | 2 février
***************************************************************************

//  Exercice 1:******3.5%
input hhid region income hhsize
	1	1	210		4
	2	1	450		6
	3	1	300		5
	4	1	210		3
	5	2	560		2
	6	2	400		4
	7	3	140		4
	8	3	250		2
	9	3	340		2
	10	3	220		2
	11	3	360		3
	12	3	338		3
end

// Q1.1
/* Générer la variable de revenu par habitant (pcinc) */
gen pcinc = income/hhsize

// Q1.2
/* Estimez le revenu total de notre population */
egen sum_income = sum(income)
disp sum_income
/* Estimez le revenu moyen par habitant */
sum pcinc [aw=hhsize]
*pour confirmer :
egen sum_hhsize = sum(hhsize)
disp sum_income/sum_hhsize

// Q1.3
// Estimer l'intensité de la pauvreté, seuil de pauvreté (pline) égale 100
gen pline = 100
/* Générer la variable d'intensité de la pauvreté par habitant (pgap) */
gen pgap = 0
replace pgap = (pline-pcinc)/pline if pcinc<pline
/* Estimer sa moyenne */
sum pgap [aw=hhsize]
*pour confirmer :
egen sum_pgap_hhsize = sum(pgap*hhsize)
disp sum_pgap_hhsize/sum_hhsize

// Q1.4
/* Refaire Q1.3 avec DASP (chemin: User>DAPS>Poverty>FGT and EDE-FGT indices) */
ifgt pcinc, alpha(1) hsize(hhsize) pline(100)

// Q1.5
//Pouvoir d'achat. A région de référence. B supérieur de 10%. C supérieur de 30%.
/* Générer la variable deflator */
gen deflator = 1
replace deflator = 1/1.1 if region==2
replace deflator = 1/1.3 if region==3
/* Générer la variable de revenu réel par habitant (rpcinc) */
gen rpcinc = pcinc/deflator

// Q1.6
// Refaire Q1.3 et Q1.4 en utilisant rpcinc lorsque le pline=120
replace pline = 120
/* Générer la variable d'intensité de la pauvreté par habitant (pgap) */
replace pgap = 0
replace pgap = (pline-rpcinc)/pline if rpcinc<pline
/* Estimer sa moyenne */
sum pgap [aw=hhsize]
/* Avec DASP (chemin: User>DAPS>Poverty>FGT and EDE-FGT indices) */
ifgt rpcinc, alpha(1) hsize(hhsize) pline(120)


***************************************************************************
clear

//  Exercice 2:**************3%
cd "/Users/rafaeldias/OneDrive - Université Laval/economia/2021/Pauvrete et inegalite ECN6992/data/"
use data_1.dta

// db svyset                              //'Main':PSU et stata _ 'Weights':sweight
// svydes

// Q2.1
/* Estimer les dépenses moyennes par équivalent adulte avec commande DASP imean */
svyset _n 
imean ae_exp, hsize(hhsize)
svydes

// Q2.2
// Estimer les dépenses moyennes par équivalent adulte en utilisant :
/* cas1: strata pour initialiser la variable de stratification de la population échantillonnée. */
svyset _n, strata(strata)
imean ae_exp, hsize(hhsize)
svydes
/* cas2: psu pour initialiser la variable d'unité primaire d’échantillonnage (primary sampling unit, PSU). */
svyset psu
imean ae_exp, hsize(hhsize)
svydes
/* cas3: strata et psu.  */
svyset psu, strata(strata)
imean ae_exp, hsize(hhsize)
svydes
/* cas4: strata, psu et le poids de sondage. */
svyset psu [pweight=sweight], strata(strata)
imean ae_exp, hsize(hhsize)
svydes

// Q2.3
/* Vérifier si les dépenses moyennes par équivalent adulte dans la région 1 sont supérieures au double de celles de la région 3 */
*gen mean_3 = mean ae_exp if regio==3

// #delimit;
// dimean ae_exp ae_exp,
// 	hsize1(hhsize) test(mean ae_exp) cond1(region==1 )
// 	hsize2(hhsize) cond2(region==3 ) conf(ub);

// Q2.4
/* Évaluer, avec DASP, si les dépenses moyennes par équivalent adulte pour les chefs de famille hommes sont plus élevées que celles des femmes chefs de famille */
// db dimean
#delimit;
dimean ae_exp ae_exp,
	hsize1(hhsize) test(0) cond1(sex==1)
	hsize2(hhsize) cond2(sex==2 ) conf(ub);

***************************************************************************
clear

//  Exercice 3:***********5%
cd "/Users/rafaeldias/OneDrive - Université Laval/economia/2021/Pauvrete et inegalite ECN6992/data/"
use data_1.dta

// Q3.1
// Calculer la taille de la population des ménages échantillonnés
/* nombre des ménages */
sum hhsize
/* nombre des personnes */
disp r(sum)
// Q 3.2
/* Ordonner les dépenses par habitant en ordre croissant */
sort pcexp

/* Générer ensuite la variable part de population (ps) qui comprend la proportion de la population échantillonnée avec les dépenses par habitant correspondantes */
gen ps = hhsize/r(sum)

/* Générer les variables centiles (p) et quantiles (q) */
gen p = sum(ps)   //p=percentile     
gen q = pcexp     //q=quantiles

// Q 3.3
/* Courbe de distribution cumulative (X: centiles et Y: dépenses par habitant) (domaine des centiles: min = 0 et max = 0,95). */
#delimit ;
line  pcexp p,
title(Courbe distribution cumulative (cdf)) 
xtitle(F(y)) xscale(range(0 0.95))
ytitle(Dépenses par habitant);

// Q 3.4
/* Courbe des quantiles (X: centiles et Y: quantiles) (domaine des centiles: min = 0 et max = 0,95) */
#delimit ;
line  q p ,    
title(Courbe des quantiles)
xtitle(Centile (p)) xscale(range(0 0.95))
ytitle(Quantile (q));

// Q 3.5
/* Courbe des quantiles (avec DASP) pour chacune des régions rurales et urbaines (domaine des centiles : min = 0 et max = 0,95) */
c_quantile pcexp, hsize(hhsize) hgroup(zone) min(0) max(0.95)

// Q 3.6 
/* Courbes de densité (avec DASP) des dépenses par habitant en fonction du sexe du chef de ménage (domaine des dépenses par habitant: min = 0 et maximum = 1000000) */
#delimit ;
cdensity pcexp, hsize(hhsize) hgroup(sex) popb(2) min(0) max(1000000)
;

