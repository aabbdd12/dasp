****************11.5%


version 16.1 
capture clear
capture log close
log using "C:\Evaluation_1\COMBARY_Resultats_1_2_3.log", replace
set more off

//*EXERCICE PRATIQUE 1*//


**********3.5%
clear
input identifier region income hhsize
1	1	210	4
2	1	450	6
3	1	300	5
4	1	210	3
5	2	560	2
6	2	400	4
7	3	140	4
8	3	250	2
9	3	340	2
10	3	220	2
11	3	360	3
12	3	338	3
end 
save "C:\Evaluation_1\COMBARY_Data_0.dta", replace  

//*Q 1.1: À l’aide de Stata, générez le revenu par habitant (pcinc)*//
gen pcinc=income/hhsize

//*Q 1.2: À l'aide de Stata, estimez le revenu moyen par habitant et le revenu total de notre population*//

//*Revenu moyen par habitant*//
sum pcinc [aw=hhsize] 

//*Revenu total de la population*//
egen total_inc=sum(income) 

//*Q 1.3: Supposons que le seuil de pauvreté soit égal à 100. Générez la variable « intensité de la pauvreté 
//*par habitant (pgap) », puis estimez sa moyenne (l’intensité de la pauvreté par habitant devrait être normalisée 
//*par le seuil de pauvreté)  

//*Intensité de la pauvreté par habitant (pgap)*//
gen pline=100
gen pgap=0
replace pgap=(pline-pcinc)/pline if (pcinc<pline)

//*Moyenne de l'intensité de la pauvreté par habitant*//
sum pgap [aw=hhsize]

//*Q 1.4: Refaites la question Q 1.3 avec DASP*//
ifgt pcinc, pline(100) alpha(1) hsize(hhsize)

//*Q 1.5: Supposons que le pouvoir d'achat dans la région B soit supérieur de 10% à celui de la région A et que celui de la région C soit supérieur de 30% à celui de la région A. Dans le cas où la région A est la région de référence, générez la variable (deflator) en tant qu'indice de déflation des prix, puis générez la variable de revenu réel par habitant (rpcinc)*//

//*Déflateur*//
gen deflator=1
replace deflator=0.9 if region==2
replace deflator=0.7 if region==3

//*Revenu réel par habitant*//
gen rpcinc=pcinc/deflator 

//*Q 1.6: Refaites les questions 1.3 et 1.4 en utilisant le revenu réel par habitant lorsque le seuil de pauvreté est de 120*//

//*questions 1.3*//
 //*Intensité de la pauvreté par habitant (pgap)*//
sum rpcinc [aw=hhsize]
replace pline = 120
replace pgap=(pline-rpcinc)/pline if (rpcinc<pline)

//*Moyenne de l'intensité de la pauvreté par habitant*//
sum pgap [aw=hhsize]

//*questions 1.4*//
ifgt rpcinc, pline(120) alpha(1) hsize(hhsize)



//*EXERCICE PRATIQUE 2*//*********3%

use "C:\Evaluation_1\COMBARY_Data_1.dta", clear

//*1.1	À l'aide du fichier data_1, estimez les dépenses moyennes par équivalent adulte 
//*sans utiliser le poids de sondage et en utilisant la commande DASP imean. À quoi réfère 
//*cette statistique?*//

imean ae_exp, hsize(hhsize)

//*1.2	Supposez différents cas d'initialisation du plan d'échantillonnage*//

//*CAS1: Seulement en utilisant la variable strata pour initialiser la variable de stratification de la population échantillonnée.

svyset, strata(strata)
imean ae_exp, hsize(hhsize)

//*CAS2 : Seulement en utilisant la variable psu pour initialiser la variable d'unité primaire d’échantillonnage (primary sampling unit, PSU).

svyset psu
imean ae_exp, hsize(hhsize)

//*CAS3: En utilisant la variable strata et psu. 

svyset psu, strata(strata)
imean ae_exp, hsize(hhsize)

//*CAS4: En utilisant la variable strata, psu et la variable de poids de sondage. 

svyset psu [pweight=sweight], strata(strata)
imean ae_exp, hsize(hhsize)


//*1.3	Vérifiez si les dépenses moyennes par équivalent adulte dans la région 1 sont 
//*supérieures au double de celles de la région 3. Discutez brièvement ce résultat*//
 
dimean ae_exp ae_exp, hsize1(hhsize) test(45969.62) cond1(region==3) hsize2(hhsize) cond2(region==1) 

//*1.4	À l'aide de la commande DASP dimean, évaluez si les dépenses moyennes par équivalent 
//*adulte pour les chefs de famille hommes sont plus élevées que celles des femmes chefs de 
//*famille. Discutez brièvement ce résultat.

dimean ae_exp ae_exp, hsize1(hhsize) cond1(sex==2) hsize2(hhsize) cond2(sex==1) 


//*EXERCICE PRATIQUE 3*********5%*//

//*Q 3.1 Utilisez le fichier de données data_1.dta, puis calculez la taille de la population 
//*des ménages échantillonnés*//   

egen taille_ech=sum(hhsize) 

//*Q 3.2 Ordonnez les dépenses par habitant en ordre croissant et générez ensuite la variable 
//*part de population (ps) qui comprend la proportion de la population échantillonnée avec les 
//*dépenses par habitant correspondantes. Sur cette base, générez les variables centiles (p) et 
//*quantiles (q)*//

sort pcexp
sum hhsize
gen ps=hhsize/r(sum)
gen p=sum(ps)
gen q=pcexp
list, sep(0)

//*Q 3.3 Dessinez la courbe de distribution cumulative (Axe X: les centiles et axe Y: les dépenses 
//*par habitant correspondantes) (domaine des centiles: min = 0 et max = 0,95)*//

cdf pcexp, hsize(hhsize) min(0) max(1000000) ytitle(les centiles) xtitle(les dépenses par habitant) title(courbe de distribution cumulative)

//*Q 3.4 Tracez la courbe des quantiles (Axe X: centiles et axe Y: quantiles) (domaine des centiles: 
//*min = 0 et max = 0,95), et commentez brièvement les résultats*//

c_quantile pcexp, hsize(hhsize) min(0) max(0.95) title(courbe des quantiles) xtitle(les centiles (p)) ytitle(les dépenses par habitant q(p)) 

//*Q 3.5 En utilisant DASP, dessinez la courbe des quantiles pour chacune des régions rurales et urbaines 
//*(domaine des centiles : min = 0 et max = 0,95), et discutez brièvement des résultats*//

c_quantile pcexp, hsize(hhsize) hgroup(zone) min(0) max(0.95) 

//*Q 3.6 À l'aide de DASP, dessinez les courbes de densité des dépenses par habitant en fonction du sexe du 
//*chef de ménage (domaine des dépenses par habitant: min = 0 et maximum = 1000000) et discuter brièvement 
//*des résultats*//

cdensity pcexp, hs(hhsize) hgroup(sex) min(0) max(1000000)













