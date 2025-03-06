*****************12.5%

***************** DIALLO Thierno Madjou*********
  
 clear
/*Exercice 1:  *********4%*/

clear 
input identifer region income hhsize
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
12 3 338 2
13 3 330 3
14 3 336 4
end
/* Question 1.1 : Générez le revenu par habitant (pcinc) */

gen pcinc = income/hhsize

/* Question 1.2 : estimez le revenu moyen par habitant et 
le revenu total de notre population*/

/* Revenu moyen par habitant */
sum pcinc [aw=hhsize]

/*Revenu total de la popultaion*/
total(income)

/* Question 1.3 : Générez la variable « intensité de la pauvreté par habitant (pgap) », 
puis estimez sa moyenne (l’intensité de la pauvreté par habitant 
devrait être normalisée par le seuil de pauvreté)*/

gen pline = 120
gen pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
sum pgap [aw=hhsize] 

/* Question 1.4 : Refaites la question Q 1.3 avec DASP*/

ifgt pcinc, pline(120) alpha(1) hsize(hhsize)

/* Question 1.5 : Dans le cas où la région A est la région de référence, 
générez la variable (deflator) en tant qu'indice de déflation des prix, 
puis générez la variable de revenu réel par habitant (rpcinc) */

gen deflator = 1
replace deflator = 1.15 if region == 2
replace deflator = 1.20 if region == 3
gen rpcinc = pcinc/deflator

**** Question 1.6 : Refaites la question 1.3 et 1.4 en utilisant le revenu réel par habitant lorsque le seuil de pauvreté est de 130*****

sum rpcinc [aw=hhsize]
replace pline = 130
replace pgap = (pline-rpcinc)/pline if (rpcinc < pline)
sum pgap [aw=hhsize]
ifgt rpcinc, pline(130) alpha(1) hsize(hhsize)



// Exercice 2 :*********3%

clear
input identifier period income hhsize na
1 1 29 4 2
2 1 50 3 2
3 1 36 4 3
1 2 30 4 2
2 2 48 3 3
3 2 46 5 2
end
/*Question 2.1 : A l'aide de Stata, estimez le revenu moyen par habitant et 
le revenu moyen par équivalent-adulte pour chaque période*/

/*Estimation du revenu par habitant*/

gen pcinc = income/hhsize

/* Estimation du revenu moyen par habitant: period 1 */ 

sum pcinc [aw=hhsize] if period == 1

/* Estimation du revenu moyen par habitant: period 2 */ 

sum pcinc [aw=hhsize] if period == 2

/* Generez la taille equivalent-adulte et revenu par equivalent adulte*/
gen aes = 1 + 0.6 * (na-1) + 0.4 * (hhsize-na) 
gen eainc = income/aes

/* Estimation du revenu moyen par equivalent adulte: period 1 */ 
sum  eainc [aw=hhsize]  if period == 1
/* Estimation du revenu moyen par equivalent adulte: period 2 */ 
sum  eainc [aw=hhsize]  if period == 2

//Exercice 3 : 5.5%


**** Question 3.1 : Utilisez le fichier de données data_3.dta, puis calculez la taille de la population des ménages échantillonnés *********

clear all
cd "C:\Users\Desktop\Hiver2021\Mesure&AllegementDeLaPauvrete\Sem1&2"
use data_3.dta, clear
gen fweight=psu*hhsize
total (fweight)

**** Question 3.2 : Ordonnez les dépenses par habitant en ordre croissant et générez ensuite la variable part de population (ps) qui comprend la proportion de la population échantillonnée avec les dépenses par habitant correspondantes. Sur cette base, générer les variables centiles (p) et quantiles (q)*****

/*Ordonnez en ordre croissant les dépenses par habitant*/
sort pcexp

/*Générez la variable ps, proportion de la population échantillonnée*/
sum hhsize
gen ps=hhsize/r(sum)

/*Générez les variables percentiles et quantiles*/
gen p = sum(ps)
gen q = pcexp
list, sep(0)

*** Question 3.3 : Dessinez la courbe de distribution cumulative (Axe X: les centiles et axe Y: les dépenses par habitant correspondantes) (domaine des centiles: min = 0 et max = 0,90)****

line p pcexp, title(La courbe de distribution cumulative ) xtitle(dépenses par habitant correspondantes (pcexp))
ytitle(F(y),(min = 0, max = 0,90))


*** Question 3.4 : Tracez la courbe des quantiles (Axe X: centiles et axe Y: quantiles) (domaine des centiles: min = 0 et max = 0,90), et commentez brièvement les résultats****

c_quantile pcexp, hsize(hhsize) min(0.0) max(0.90)

*** Question 3.5 : En utilisant DASP, dessinez la courbe des quantiles pour chacune des régions rurales et urbaines (domaine des centiles : min = 0 et max = 0,90), et discutez brièvement des résultats****

c_quantile pcexp, hsize(hhsize) hgroup(zone) min(0.0) max(0.90)

*** Question 3.6 : A l'aide de DASP, dessinez les courbes de densité des dépenses par habitant en fonction du sexe du chef de ménage (domaine des dépenses par habitant : min = 0 et maximum = 800000) et discuter brièvement des résultats****

cdensity pcexp, hsize(hhsize) hgroup(sex) min(0) max(800000)





