****************10.5%


//Résolution des exercices semaines 1 et 2*****
//  Q1:*************3,5%
/* Entrée des données */
clear
input identifier region income hhsize
1 1 210 4
2 1 450 6
3 1 300 5
4 1 210 3
5 2 560 2
6 2 400 4
7 3 140 4
8 3 250 2
9 3 340 2
10 3 220 2
11 3 360 3
12 3 338 3
end

/* Generer la variable ''revenu par tête'' */ 
gen pcinc = income/hhsize


/*Q 1.2: À l'aide de Stata, estimez le revenu moyen par habitant et le revenu total de notre population*/
sum pcinc [aw=hhsize]
total income /* COMMENTAIRE: ==> total pcinc [pw=hhsize]*/

/*Q 1.3: Supposons que le seuil de pauvreté soit égal à 100. Générez la variable « intensité de la pauvreté par habitant (pgap) », puis estimez sa moyenne (l’intensité de la pauvreté par habitant devrait être normalisée par le seuil de pauvreté).*/

gen     pline = 100
gen     pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
sum     pgap [aw=hhsize]

/*Q 1.4: Refaites la question Q 1.3 avec DASP.*/

ifgt pcinc, pline(100) alpha(1) hsize(hhsize)

/*Q 1.5: Supposons que le pouvoir d'achat dans la région B soit supérieur de 10% à celui de la région A et que celui de la région C soit supérieur de 30% à celui de la région A. Dans le cas où la région A est la région de référence, générez la variable (deflator) en tant qu'indice de déflation des prix, puis générez la variable de revenu réel par habitant (rpcinc).*/

gen     deflator = 1
replace deflator = 0.9 if region == 2
replace deflator = 0.7 if region == 3
gen     rpcinc = pcinc/deflator

/*Q 1.6: Refaites les questions 1.3 et 1.4 en utilisant le revenu réel par habitant lorsque le seuil de pauvreté est de 120.*/
sum rpcinc [aw=hhsize]
replace pline = 120
replace pgap  = (pline-rpcinc)/pline if (rpcinc < pline)
sum     pgap [aw=hhsize]
ifgt    rpcinc, pline(120) alpha(1) hsize(hhsize)





clear
/*Exercice 2 *************2%*/

use "C:\Documents\Laval 2021\ECN-6992 Measuring and Alleviating Poverty and Inequality Mesure et allègement de la pauvreté et inégalité H21\Exercices 1 et 2\data_1 bonne base.dta"
/*1.1	À l'aide du fichier data_1, estimez les dépenses moyennes par équivalent adulte sans utiliser le poids de sondage et en utilisant la commande DASP imean. À quoi réfère cette statistique?*/

imean ae_exp

/*1.2	Supposez différents cas d'initialisation du plan d'échantillonnage*/

/*•	CAS1: Seulement en utilisant la variable strata pour initialiser la variable de stratification de la population échantillonnée.*/

svyset _n, strata(strata) vce(linearized) singleunit(missing)
imean ae_exp /*COMMENTAIRE ==> imean ae_exp , hsize(hhsize)*/

/*•	CAS2 : Seulement en utilisant la variable psu pour initialiser la variable d'unité primaire d’échantillonnage (primary sampling unit, PSU).*/
svyset psu, strata(strata) vce(linearized) singleunit(missing)
imean ae_exp /*COMMENTAIRE ==> imean ae_exp , hsize(hhsize)*/


/*•	CAS3: En utilisant la variable strata et psu. */
svyset psu, strata(strata) vce(linearized) singleunit(missing)
imean ae_exp /*COMMENTAIRE ==> imean ae_exp , hsize(hhsize)*/


/*•	CAS4: En utilisant la variable strata, psu et la variable de poids de sondage. */

svyset psu, strata(strata) weight(sweight) vce(linearized) singleunit(missing)
imean ae_exp /*COMMENTAIRE ==> imean ae_exp , hsize(hhsize)*/

/*COMMENTAIRE
// Q3
imean ae_exp , hsize(hhsize) hg(region)
// Le double DE region 3 = 2*20045.771484  = 40091.543
datest  40091.543, est(47992.410156) ste(3910.776855)
// On ne peut pas rejeter  l'hypothèse H0:moyenne_1>  40091.543, car le risque d'erreur serait de 97.83%

*/

/*1.4	À l'aide de la commande DASP dimean, évaluez si les dépenses moyennes par équivalent adulte pour les chefs de famille hommes sont plus élevées que celles des femmes chefs de famille. Discutez brièvement ce résultat.*/

dimean ae_exp ae_exp, hsize1(hhsize) /*test(0)*/ cond1(sex==1 ) hsize2(hhsize) cond2(sex==2 )
 /*COMMENTAIRE:  Nous ne pouvons pas rejeter l'Hypothèse H0 :(moyenne_homme - moyenne_femme)>0, car le niveau d'erreur en rejettant serait de 97.36%.*/

clear
/*Exercice 3***********************5%*/

use "C:\Documents\Laval 2021\ECN-6992 Measuring and Alleviating Poverty and Inequality Mesure et allègement de la pauvreté et inégalité H21\Exercices 1 et 2\data_1 bonne base.dta"

/*Q 3.1 Utilisez le fichier de données data_1.dta, puis calculez la taille de la population des ménages échantillonnés.   */


gen poppsu = psu* sweight
total (poppsu)

/*Ordonnez les dépenses par habitant en ordre croissant et générez ensuite la variable part de population (ps) qui comprend la proportion de la population échantillonnée avec les dépenses par habitant correspondantes. Sur cette base, générez les variables centiles (p) et quantiles (q).*/

/* Ordonnacement des données par le revenu per capita */ 
 sort pcexp
 
 //* generer la variable de proportion de la  popultion */
 
sum hhsize
gen ps = hhsize/r(sum)


/* generer les  percentile et  les  quantiles */ 
gen p = sum(ps)
gen q =  pcexp
list, sep(0)
#delimit ;

/*Q 3.3 Dessinez la courbe de distribution cumulative (Axe X: les centiles et axe Y: les dépenses par habitant correspondantes) (domaine des centiles: min = 0 et max = 0,95).

*/

line  p pcexp /* if p<0.95*/, title(The cumulative distribution curve) xtitle(Centiles (y)) ytitle(F(y))

/*Q 3.4 Tracez la courbe des quantiles (Axe X: centiles et axe Y: quantiles) (domaine des centiles: min = 0 et max = 0,95), et commentez brièvement les résultats.*/


line  q p /* if p<0.95*/ , title(The quantile curve)   xtitle(the percentile (p))  ytitle(The quantile Q(p))

/*Q 3.5 En utilisant DASP, dessinez la courbe des quantiles pour chacune des régions rurales et urbaines (domaine des centiles : min = 0 et max = 0,95), et discutez brièvement des résultats.*/

 c_quantile q, hgroup(zone) min (0)  max (0.95)
/*Q 3.6 À l'aide de DASP, dessinez les courbes de densité des dépenses par habitant en fonction du sexe du chef de ménage (domaine des dépenses par habitant: min = 0 et maximum = 1000000) et discuter brièvement des résultats.*/

cdensity ae_exp, hsize(hhsize) hgroup(sex) popb(1) min(0) max(1000000)








