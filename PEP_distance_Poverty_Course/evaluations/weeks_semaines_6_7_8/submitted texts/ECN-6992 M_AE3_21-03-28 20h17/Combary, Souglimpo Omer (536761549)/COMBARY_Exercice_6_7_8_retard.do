**********12%
version 16.1 
capture clear
capture log close
log using "C:\Evaluation_3\COMBARY_Resultats_6_7_8.log", replace
set more off

//*EXERCICE PRATIQUE 1*//**3%

/*1.1	En utilisant le fichier de données data_b3_1.dta, estimez le seuil de pauvreté subjective en considérant les informations suivantes :
•	Le bien-être équivalent adulte observé est la variable :  ae_exp
•	Le bien-être équivalent-adulte perçu minimum pour échapper à la pauvreté est min_ae_exp.
•	L’unité d'analyse est l’individu (utilisez la variable de taille du ménage).*/

use "C:\Evaluation_3\COMBARY_data_b3_1.dta", clear

cnpe ae_exp min_ae_exp, xvar(ae_exp) hsize(hsize) min(0) max(60000) legend(order(1 "Bien-être observé"  ///
2 "Perception sur le niveau de bien-être minimum")) title(Seuil de pauvreté subjective) ///
xtitle(Bien-être observé) ytitle(Perceptions sur le niveau de bien-être minimum) vgen(yes)

cnpe ae_exp min_ae_exp, xvar(ae_exp) hsize(hsize) xval(0) legend(order(1 "Bien-être observé"  ///
2 "Perception sur le niveau de bien-être minimum")) title(Seuil de pauvreté subjective) ///
xtitle(Bien-être observé) ytitle(Perceptions sur le niveau de bien-être minimum) vgen(yes)

cap drop dif
gen dif=_npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) xval(0) vgen(yes)

cnpe ae_exp min_ae_exp, xvar(ae_exp) hsize(hsize) min(0) max(60000) legend(order(1 "Bien-être observé"  ///
2 "Perception sur le niveau de bien-être minimum")) title(Seuil de pauvreté subjective) xline(22914.478516)  ///
xtitle(Bien-être observé) ytitle(Perceptions sur le niveau de bien-être minimum) vgen(yes)

/*1.2	Estimez l’intensité de la pauvreté (avec les variables : ae_exp and hsize) pour chacun de ces trois cas, et discutez les résultats :*/

/*a) Le seuil de pauvreté subjective*/
ifgt ae_exp, alpha(0) hsize(hsize) pline(22914.478516)

/*b) Le seuil de pauvreté absolue (z=21000)*/
ifgt ae_exp, alpha(0) hsize(hsize) pline(21000)

/*c) Le seuil de pauvreté relative (z= moitié du revenu moyens).*/ 	
ifgt ae_exp, alpha(0) hsize(hsize) opl(mean) prop(50)

/*1.3 Selon vous, quelle est la méthode la plus appropriée pour mesurer la pauvreté dans les pays développés et pourquoi?*/

/*Le seuil de pauvreté absolue est le plus approprié pour mesurer la pauvreté pour deux raisons : 
i)	il permet d'obtenir des profils de pauvreté « cohérents » 
ii)	il permet de faire des comparaisons de pauvreté « cohérentes ».*/

//*EXERCICE PRATIQUE 2*//*4.5%

/*Les indices de pauvreté additive, comme l'indice FGT, permettent d'effectuer une décomposition analytique exacte de ces 
indices par sous-groupe de population. Ceci est utile pour montrer la contribution de chaque groupe à la pauvreté totale.*/

/*2.1 Utilisez le fichier data_b3_1.dta et décomposez la pauvreté (taux de pauvreté) selon le sexe du chef de ménage (sex) 
(le seuil de pauvreté est 21000). Que pouvons-nous conclure ?*/      

use "C:\Evaluation_3\COMBARY_data_b3_1.dta", clear
dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(21000) 

/*La contribution (à la pauvreté totale) de la pauvreté chez les ménages dirigés par des 
femmes est supérieure à la contribution qui vient de leur représentativité dans la 
population totale (0.389 VS 0.221). Comme connu, la contribution absolue à la pauvreté 
totale est donnée par le produit de ces deux composantes: la pauvreté dans le groupe x 
la part de la population dans le groupe. (Comparer la part de la population du groupe 
féminin et la contribution relative de ce groupe à la pauvreté totale)
Toutefois, bien évidemment, il faut noter que la contribution relative et absolue des 
ménages dirigés par des femmes est inférieure à celle des ménages dirigés par des 
hommes.*/ 

/*2.2 Estimez la pauvreté totale (taux de pauvreté) en fonction de la région du chef de ménage (region).*/ 

dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(21000) 

/*2.3 La répartition des dépenses en équivalent-adultes est similaire à celle de la période initiale (ae_exp), avec les légères différences suivantes
• Les dépenses en équivalent-adultes ont augmenté de 10% dans la région 3;
• Les dépenses en équivalent-adultes ont diminué de 6% dans la région 2;
Générez la variable ae_exp2 en vous basant sur les informations ci-dessus.*/ 

gen ae_exp2=ae_exp
replace ae_exp2=(1+0.1)*ae_exp if region==3 
replace ae_exp2=(1-0.06)*ae_exp if region==2 

/*2.4 En utilisant l'approche de Shapley, décomposez le changement de l'intensité de la pauvreté en croissance et redistribution. Puis discutez des résultats.*/

dfgtgr ae_exp ae_exp2, alpha(1) pline(21000) hsize1(hsize) hsize2(hsize) 

/*2.5 Effectuez une décomposition sectorielle (basée sur les groupes de régions) de la variation de l'intensité de la pauvreté totale. Discutez des résultats.*/ 

dfgtg2d ae_exp ae_exp2, alpha(1) hgroup(region) pline(21000) hsize1(hsize) hsize2(hsize)

//*EXERCICE PRATIQUE 3*//*4.5%

/*Supposons que la population est composée de dix individus. Le tableau suivant montre la distribution des revenus pour deux périodes successives.
3.1	Insérez les données, puis générez les centiles (basé sur le rang des revenus de la période initiale (variable perc)), et le premier centile doit être égal à zéro).*/

clear
input identifier weight inc_t1 inc_t2 
0	0	0.00	0.00
1	0.1	1.50	1.54
2	0.1	4.50	3.85
3	0.1	7.50	6.60
4	0.1	3.00	2.75
5	0.1	4.50	4.40
6	0.1	9.00	7.70
7	0.1	10.50	8.80
8	0.1	15.00	7.70
9	0.1	12.00	6.60
10	0.1	13.50	6.60
end 
save "C:\Evaluation_3\COMBARY_Data_0.dta", replace  

sort inc_t1
gen perc=sum(weight) 
list perc

*3.2 Initialisez le scalaire g_mean, qui est égal au taux de croissance du revenu moyen.

qui sum inc_t1 [aw=weight] 
scalar mean1=r(mean) 
qui sum inc_t2 [aw=weight]
scalar mean2=r(mean)

scalar g_mean = (mean2-mean1)/mean1
gen g_mean  = (mean2-mean1)/mean1  
dis "Mean 1 = " mean1
dis "Mean 2 = " mean2
dis "Growth in averages = " g_mean

*3.3	Générez la variable g_inc, comme la croissance des revenus individuels.

gen g_inc =(inc_t2-inc_t1)/inc_t1
replace g_inc = 0 in 1 

*3.4 Dessinez la courbe d’incidence de la croissance à l’aide des variables g_inc et perc. Discutez des résultats.

line g_inc g_mean perc, title(Growth Incidence Curve) yline(`g_mean') legend(order(1 "GIC curve" 2 "Growth in average income")) ///
xtitle(Percentiles (p)) ytitle(Growth in incomes) plotregion(margin(zero))

*3.5 Supposons que le seuil de pauvreté est égal à 10.2. Estimez l'indice pro-pauvres de Chen et Ravallion (2003). Discutez des résultats.

drop in 1
sum g_inc [aw=weight] if (inc_t1<10.2) 	
dis = r(mean)
ipropoor inc_t1 inc_t2, pline(10.2)   	

*3.6 En utilisant l'approche de Shapley, décomposez le changement de l'intensité de la pauvreté en composantes de croissance et de redistribution. Discutez des résultats.

dfgtgr inc_t1 inc_t2, alpha(1) pline(10.2) 








