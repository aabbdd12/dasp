************11%

*** Dufour, Johany - Exercices 1-2

**************** EXERCICE 1 ******************* 3.5%
clear
set more off

* Ajouter les données 
** À noter que pour les régions, A=1, B=2, C=3. 
input hhid region income hhsize
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


* Q1.1 : Générer le revenu par habitant à l'aide de Stata

gen pcinc = income/hhsize

* Q1.2 : Estimer le revenu moyen par habitant à l'aide de Stata, ainsi que le revenu total de la population

sum pcinc [aw = hhsize]
egen sum_inc = sum(income)

* Q 1.3 : Générer la variable pgap (intensité de la pauvreté par habitant) puis estimer sa moyenne. 

gen pline = 100
gen pgap = 0 
replace pgap = (pline-pcinc)/pline if (pcinc < pline)

sum pgap [aw = hhsize]

* Q 1.4 Refaites 1.3 avec DASP 

ifgt pcinc, alpha(1) hsize(hhsize) pline(100)


* Q 1.5 : Générer la variable deflator en tant qu'indice de déflation des prix, puis générer la variable de revenu réel par habitant rpcinc. 

gen deflator = 1 
replace deflator = 0.9 if region == 2 
replace deflator = 0.7 if region == 3

gen rpcinc = pcinc/deflator

* Q 1.6 : Refaites 1.3 et 1.4 en utilisant le revenu réel par habitant lorsque le seuil de pauvreté est de 120. 

sum rpcinc [aw =hhsize]

replace pline = 120
replace pgap = (pline-rpcinc)/pline if (rpcinc < pline)
sum pgap [aw = hhsize]

ifgt rpcinc, alpha(1) hsize(hhsize) pline(120)




**************** EXERCICE 2 ******************* 3%
clear
set more off


** D'abord, utilisons le fichier de données fourni : 

use "D:\Téléchargement Chrome\data_1.dta", clear

* Q 1.1 : Estimer les dépenses moyennes par équivalent adulte sans utiliser le poids de sondage et en utilisant la commande DASP imean. 

imean ae_exp, hsize(hhsize)

* Q 1.2 : Pour chacun des 4 cas, estimer les dépenses moyennes par équivalent adulte. 

*** CAS 1 : 
svyset _n, strata(strata) clear
imean ae_exp, hsize(hhsize)
svydes

*** CAS 2 : 
svyset psu clear
svydes
imean ae_exp, hsize(hhsize)

*** CAS 3 : 
svyset psu, strata(strata) clear
svydes
imean ae_exp, hsize(hhsize)

*** CAS 4 : 
svyset psu, strata(strata) weight(sweight) clear
svydes
imean ae_exp, hsize(hhsize)


* Q 1.3 : Vérifiez si les dépenses moyennes par équivalent adulte dans la région 1 sont supérieures au double de celles de la région 3. 

* On veut tester l'hypothèse Ho : mean_region1 > 2*mean_region3
* C'est équivalent à tester mean_region1 - mean_region3 > mean_region3

* Je trouve les dépenses moyennes dans la région 3 :  mean_region3

sum ae_exp [aw = hhsize] if region==3
** vaut environ 26080.66. J'utilise dimean avec ce nombre. 

dimean ae_exp ae_exp, hsize1(hhsize) test(26080.66) cond1(region==3 ) hsize2(hhsize) cond2(region==1 ) conf(ub)

* Q 1.4 : À l'aide de dimean, évaluer si les dépenses moyennes par équivalent adulte pour les chefs de famille hommes sont plus élevées que celles des femmes chefs de famille. 

tab sex
tab sex, nolabel 

*alors, sex =1 pour les hommes et sex=2 pour les femmes 

*Je teste si la différence entre les dépenses moyennes pour les chefs de famille homme et les dépenses moyennes pour les chefs de famille femme est égale à zéro. 
dimean ae_exp ae_exp, hsize1(hhsize) test(0) cond1(sex==2 ) hsize2(hhsize) cond2(sex==1 ) conf(ub)



**************** EXERCICE 3 ******************* 5%
clear
set more off

*Q 3.1 : 
** D'abord, utilisons le fichier de données fourni : 

use "D:\Téléchargement Chrome\data_1.dta", clear

* Calculer la taille de la population des ménages échantillonnés : 
egen sum_hhs = sum(hhsize)
sum sum_hhs



* Q 3.2 : 

*Ordonner les dépenses par habitant en ordre croissant 
sort pcexp

* Générer la variable ps part de la population 

gen ps = hhsize/sum_hhs

* Générer les centiles (p)
gen p = sum(ps)

* Générer les quantiles (q)
gen q = pcexp 


* Q 3.3 : Dessiner la courbe de distribution cumulative 
*J'ai inversé les variables sur les axes selon un message publié sur le forum. À ma connaissance, dans une courbe de distribution cumulative, les centiles sont en y et les dépenses par habitant (ou autre variable) sont en x. 

line p pcexp, title(The cumulative distribution curve) ytitle(Centiles (p)) xtitle(Dépenses par habitant(pcexp)) xscale(range(0 0.95))



* Q 3.4 : Tracer la courbe des quantiles. 

line q p, title(The quantile curve) xtitle(Centiles (p)) ytitle(Quantiles (Q(p))) xscale(range(0 0.95))
*Avec DASP
c_quantile pcexp, hsize(hhsize) min(0.0) max(0.95)


* Q 3.5 : utiliser DASP pour tracer la courbe des quantiles pour chacune des zones (rurale et urbaine)

c_quantile pcexp, hsize(hhsize) hgroup(zone) min(0.0) max(0.95)


* Q 3.6 : Utiliser DASP pour dessiner les courbes de densité des dépenses par habitant en fonction du sexe du chef de ménage. 

cdensity pcexp, hsize(hhsize) hgroup(sex) popb(1) min(0) max(1000000) ytitle(Densité f(y)) xtitle(Dépenses par habitant (pcexp))





