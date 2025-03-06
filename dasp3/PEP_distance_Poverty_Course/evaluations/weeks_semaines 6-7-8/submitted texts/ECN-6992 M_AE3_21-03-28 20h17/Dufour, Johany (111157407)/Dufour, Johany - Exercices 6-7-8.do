*******12%

****************************************************************
********** Dufour, Johany - Exercices 6-7-8

********** Exercice 1 ****************** 
clear
set more off 

** Question 1.1 ** 
*utilisons le fichier de données 
use "D:\Téléchargement Chrome\data_b3_1.dta", clear
svyset psu [pweight=sweight], strata(strata)

*traçons les deux courbes qui vont nous permettre de déterminer le seuil de pauvreté relative. 
cnpe ae_exp min_ae_exp, xvar(ae_exp) hsize(hsize) min(0) max(60000) legend(order( 1 " Observed well-being" 2 "Perceived minimum well-being" )) title(The subjective poverty line) xtitle(Observed well-being) ytitle(Predicted level of the perceived minimum well-being ) vgen(yes)
*trouvons maintenant le point où la différence entre le bien-être minimum perçu et le bien-être estimé est nulle (point d'intersection entre les deux courbes du graphique précédent)
cap drop dif
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) xval(0) vgen(yes)

* J'obtiens le seuil de pauvreté subjective suivant :  22914.478516. 

** Question 1.2 ** 
** a) le seuil de pauvreté subjective, qui vaut 22914.478516 selon mon estimation précédente. 
ifgt ae_exp, alpha(1) hsize(hsize) pline(22914.478516)

**b) le seuil de pauvreté absolue valant 21000
ifgt ae_exp, alpha(1) hsize(hsize) pline(21000)

**c) le seuil de pauvreté relative valant la moitié du revenu moyen
ifgt ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)

*voir la discussion dans le ficher word. 


********** Exercice 2 ****************** 

clear
set more off

** Question 2.1 ** 
*utilisons le fichier de données 
use "D:\Téléchargement Chrome\data_b3_1.dta", clear
svyset psu [pweight=sweight], strata(strata)

* Décomposition de la pauvreté par groupe donné par sex (sexe du chef de ménage)
dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(21000)

** Question 2.2 ** 
* Estimation de la pauvreté totale (alpha=0) en fonction de la région du chef de ménage. 
ifgt ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(21000)

** Question 2.3** 
* Modifions la répartition des dépenses en équivalent-adulte à travers la population : 
gen ae_exp2 = ae_exp 
replace ae_exp2 = 1.1*ae_exp if region ==3
replace ae_exp2 = 0.94*ae_exp if region ==2

** Question 2.4** 
* Décomposition du changement dans l'intensité de la pauvreté causé par la croissance et causé par la redistribution. 
dfgtgr ae_exp ae_exp2, alpha(1) pline(21000)

** Question 2.5** 
* Décomposition sectorielle de l'intensité de la pauvreté par groupe basé sur les régions - Décomposition de Shapley (aucune période de référence)

dfgtg2d ae_exp ae_exp2, alpha(1) hgroup(region) pline(21000) hsize1(hsize) hsize2(hsize) ref(0)


********** Exercice 3 ****************** 
** Mes réponses à cet exercices sont fortement inspirées du ficher d'exercices de la semaine 8. 
clear
set more off

** Question 3.1 ** 
*Ajoutons les données 
input identifier weight inc_t1 inc_t2
0 0.0 0 0
1 0.1 1.50 1.54
2 0.1 4.50 3.85
3 0.1 7.50 6.60
4 0.1 3.00 2.75
5 0.1 4.50 4.40
6 0.1 9.00 7.70
7 0.1 10.50 8.80
8 0.1 15.00 7.70
9 0.1 12.00 6.60
10 0.1 13.50 6.60
end

* On ordonne les observations en fonction des revenus 
sort inc_t1

*On génère les centiles 
gen perc=sum(weight)


** Question 3.2 ** 

*D'abord, je calcule la moyenne des revenus pour les deux périodes, que je garde en mémoire. 
* Pour la période 1
sum inc_t1 [aw=weight]
scalar mean1=r(mean) 
* Pour la période 2
sum inc_t2 [aw=weight]
scalar mean2=r(mean) 

* Générer la variable g_mean, qui est égale à la croissance des moyennes entre les deux périodes.
scalar g_mean = (mean2-mean1)/mean1
gen g_mean = (mean2-mean1)/mean1
dis "Mean 1 =" mean1
dis "Mean 2 = " mean2
dis "Growth in averages = " g_mean

** Question 3.3 ** 

* générer la croissance des revenus individuels. 
gen g_inc =(inc_t2-inc_t1)/inc_t1 
* Pour s'assurer que la croissance est de 0 lorsque le percentile =0. 
replace g_inc = 0 in 1 

** Question 3.4 ** 

*Tracer la courbe d'incidence de la croissance. 
line g_inc g_mean perc, title(Courbe Incidence de croissance) yline(`g_mean') legend(order( 1 "Courbe CIC" 2 "Croissance du revenu moyen")) xtitle(Percentiles (p)) ytitle(Croissance du revenu) plotregion(margin(zero))


** Question 3.5 ** 
*calculer différents indices de pauvreté avec DASP 
ipropoor inc_t1 inc_t2, pline(10.2) 


** Question 3.6 ** 
* Décomposition du changement dans l'intensité de la pauvreté causé par la croissance et causé par la redistribution. 
dfgtgr inc_t1 inc_t2, alpha(1) pline(10.2)


************** Fin du devoir ***************** 