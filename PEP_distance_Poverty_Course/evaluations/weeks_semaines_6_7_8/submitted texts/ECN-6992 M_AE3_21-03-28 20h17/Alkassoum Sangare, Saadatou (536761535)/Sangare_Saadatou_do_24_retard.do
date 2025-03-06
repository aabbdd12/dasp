************11.5%

//Stata code for the Practical exercise 1****3%
//  Q1:
/* Estimation du seuil de pauvreté subjective en utilisant le fichier de données data_b3_1.dta et la technique de regression nonparametrique
*/
use data_b3_1.dta, replace
cnpe ae_exp  min_ae_exp, xvar(ae_exp) hsize(hsize) min(0) max(60000)         ///
legend(order( 1 " Observed well-being" 2 "Perceived  minimum  well-being"))  ///
subtitle("") title(The subjective poverty line)            ///
 xtitle(Observed well-being)                       /// 
 ytitle(Predicted level of the perceived  minimum  well-being )              ///
 vgen(yes)
 
/* 
Estimating the level of ae_exp when the difference between the predicted minimum well-being and the observed well-being is nil.
*/
cap drop dif
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) hsize(hsize) xval(0) vgen(yes)

/*
Showing the subjective poverty line  */
cnpe ae_exp  min_ae_exp, xvar(ae_exp) hsize(hsize)min(0) max(60000)        ///
legend(order( 1 "Observed well-being " 2 "Perceived  minimum  well-being"))  ///
subtitle("") title(The subjective poverty line)            ///
xline(22922.419922) xtitle(Observed well-being)            /// 
ytitle(Predicted level of the perceived  minimum  well-being ) 

// Q2: Estimation de l’intensité de la pauvreté (avec les variables : ae_exp and hsize) pour chacun des trois cas
/*a)	Le seuil de pauvreté subjective ;*/
ifgt ae_exp, alpha(0) hsize(hsize) pline(22922.419922)

/*Verification de la validité de ces résultats grâce à un ensemble de commandes Stata simples.*/
capture drop poor
gen poor = (22922.419922>ae_exp) // poor sera = 1 si (22922.419922>ae_exp) et 0 sinon
sum poor [aw=sweight*hsize] 
/*b)	Le seuil de pauvreté absolue (z=21000) ;*/
ifgt ae_exp, alpha(0) hsize(hsize) pline(22922.419922)
ifgt ae_exp, alpha(0) hsize(hsize) pline(21000)
/*c)	Le seuil de pauvreté relative (z= moitié du revenu moyens).	*/
ifgt ae_exp, alpha(0) hsize(hsize) opl(mean) prop(50)

capture drop poor // supprimer la variable poor si cette variable est déjà générée.
sum ae_exp [aw=sweight*hsize] 
dis "The relative poverty line = " 0.5*r(mean)
gen poor = (0.5*r(mean)>ae_exp) // poor sera = 1 si (22922.419922>ae_exp) et 0 sinon
sum poor [aw=sweight*hsize] 

*Exercice 2********4.5%
/*Décomposition de la pauvreté (taux de pauvreté) selon le sexe du chef de ménage (sex) (le seuil de pauvreté est 21000).  */
dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(21000)

/* Décomposition de la pauvreté totale selon la région du chef de ménage (region).*/ 
dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(21000)

/*Générez la variable ae_exp2*/
generate ae_exp2=ae_exp*1.1 if region==3
replace ae_exp2=ae_exp*1.06 if region==2
/*Decomposition de Shapley*/
dfgtgr ae_exp ae_exp2, alpha(1) pline(21000)
/*Decomposition sectorielle basee sur les groupe de region*/
dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(1) pline(21000)

*Exercice 3******4.5%
clear
input Identifier	weight	inc_t1	Inc_t2
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

/*Générez les centiles (basé sur le rang des revenus de la période initiale (variable perc)), et le premier centile doit être égal à zéro).*/
sort inc_t1
gen perc=sum(weight) 
list perc
/*Initialisez le scalaire g_mean, qui est égal au taux de croissance du revenu moyen*/
// Calcul de la moyenne des revenus en t1
qui sum inc_t1 [aw=weight] 
// Pour garder en mémoire le scalaire 
scalar mean1 = r(mean)
// Calcul de la moyenne des revenus en t2
qui sum Inc_t2 [aw=weight]
// Pour garder en mémoire le scalaire 
scalar mean2 = r(mean)
// Pour generer la variable g_mean, qui est égale à la croissance des moyennes. 
scalar g_mean = (mean2-mean1)/mean1
gen g_mean = (mean2-mean1)/mean1 
dis "Mean 1 =" mean1
dis "Mean 2 = " mean2
dis "Growth in averages = " g_mean
// Q3: Générez la variable g_inc, comme la croissance des revenus individuels.
gen g_inc =(Inc_t2-inc_t1)/inc_t1 
replace g_inc = 0 in 1  
// Q4:
/*Dessinez la courbe d’incidence de la croissance à l’aide des variables g_inc et perc*/
line g_inc g_mean perc, ///
title(Growth Incidence Curve) ///
yline(`g_mean') ///
legend(order( 1 "GIC curve" 2 "Growth in average income")) ///
xtitle(Percentiles (p)) ytitle(Growth in incomes)  ///
plotregion(margin(zero))
 
/ *Pour calculer la croissance moyenne des revenus des personnes pauvres.*/ 
drop in 1
sum g_inc [aw=weight] if (inc_t1<10.2)
dis = r(mean)
// Pour calculer différents indices de pauvreté avec DASP 
ipropoor inc_t1 Inc_t2, pline(10.2) 
// Q6:dDécomposition de la variation des indices FGT/*
dfgtgr inc_t1 Inc_t2, alpha(1) pline(10.2)


