*****************9.5%

clear
set more off
net from http://dasp.ecn.ulaval.ca/modules/DASP_V2.3/dasp
net install dasp_p1, force
net install dasp_p2, force
net install dasp_p3, force
net install dasp_p4, force
 _daspmenu
*********************EXERCICE1*************************2.5%
********1.1
*COMENTAIRE: revoir la commande cnpe

//   1.2.
***a)
ifgt  ae_exp, alpha(0) hsize(hsize) pline(22441.69)

****b)
ifgt  ae_exp, alpha(0) hsize(hsize) pline(20600)

****c)
ifgt  ae_exp, alpha(0) hsize(hsize) opl(mean) prop(50)


// Q3 :	
/*
COMMENTAIRE REPONSE: L'utilisation du seuil de pauvreté relative est plus appropriée pour les pays développés. 
Cela peut être justifié par l'augmentation rapide du bien-être en moyenne et du niveau de vie au fil du temps.
*/

*********************EXERCICE 2*************2.5%
clear
use "C:\Users\lasta\OneDrive\Desktop\EXO\data_b3_2.dta"

//  2.1 décomposez la pauvreté (taux de pauvreté) selon le sexe du chef de ménage (sex
dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20600)

/*COMMENTAIRE Reponse:
La pauvreté au sein des ménages dirigés par des femmes est plus prononcée.
Cependant, leur contribution relative et absolue à la pauvreté totale est inférieure à celle des ménages dirigés par des hommes.
Ceci est dû à la part de population beaucoup plus faible des ménages dirigés par des femmes dans la population totale.
*/

// 2.2Estimez la pauvreté totale (taux de pauvreté) en fonction de la région du chef de ménage (region). 
dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(20600)

//   2.3 Générez la variable ae_exp2 en vous basant sur les informations ci-dessus. 
gen ae_exp2 = ae_exp * (1.00+0.12) if region==3
replace  ae_exp2 = ae_exp * (1.00-0.06) if region==2
replace  ae_exp2 = ae_exp if region==1
replace  ae_exp2 = ae_exp if region==4


/*COMMENTAIRE REPONSE
//  Q4:
dfgtgr ae_exp ae_exp2, alpha(1) pline(20600) hsize1(hsize) hsize2(hsize)

//  Q5:
dfgtg2d ae_exp ae_exp2, alpha(1) hgroup(region) pline(20600) hsize1(hsize) hsize2(hsize) ref(0)

*/


**********************EXERCICE 3****************4.5%
//  3.1.
clear
***entrée des variables et de leur valeur
import excel "C:\Users\lasta\OneDrive\Desktop\EXO\fiche11.xlsx", sheet("EXO3") firstrow
(4 vars, 11 obs)
***génération des percentiles pour cela ordonnons d'abord

sort inc_t1
gen perc=sum(weight)
list perc

**list perc

     +------+
     | perc |
     |------|
  1. |    0 |
  2. |   .1 |
  3. |   .2 |
  4. |   .3 |
  5. |   .4 |
     |------|
  6. |   .5 |
  7. |   .6 |
  8. |   .7 |
  9. |   .8 |
 10. |   .9 |
     |------|
 11. |    1 |
     +------+

//  3.2	Initialisez le scalaire g_mean, qui est égal au taux de croissance du revenu moyen.
qui sum inc_t1 [aw=weight]   			// Pour calculer la moyenne des revenus en t1.
scalar mean1=r(mean)         			// Pour garder en mémoire le scalaire  mean1 = r(mean) in t1
qui sum Inc_t2 [aw=weight]
scalar mean2=r(mean)         			// Pour garder en mémoire le scalaire  mean2 = r(mean) in t2
scalar g_mean = (mean2-mean1)/mean1
gen g_mean  = (mean2-mean1)/mean1    	// Pour generer la variable g_mean, qui est égale à la croissance des moyennes. 
dis "Mean 1              =" mean1
dis "Mean 2             = " mean2
dis "Growth in averages = " g_mean

//  3.3	Générez la variable g_inc, comme la croissance des revenus individuels.
gen g_inc =(Inc_t2-inc_t1)/inc_t1 	
replace g_inc = 0 in 1 

//  3.4	Dessinez la courbe d’incidence de la croissance à l’aide des variables g_inc et perc. Discutez des résultats.

line g_inc g_mean perc, ///
title(Growth Incidence Curve) ///
yline(`g_mean') ///
legend(order( 1 "GIC curve" 2 "Growth in average income")) ///
xtitle(Percentiles (p)) ytitle(Growth in incomes)  ///
plotregion(margin(zero))


//  3.5. Supposons que le seuil de pauvreté est égal à 10.4. Estimez l'indice pro-pauvres de Chen et Ravallion (2003).

drop in 1
sum g_inc [aw=weight] if (inc_t1<10.4) 	// pour calculer la croissance moyenne des revenus des personnes pauvres. 
dis = r(mean)
ipropoor inc_t1 Inc_t2, pline(10.4)   	// Pour calculer différents indices de pauvreté avec DASP 

// 3.6 En utilisant l'approche de Shapley, décomposez le changement de l'intensité de la pauvreté en composantes de croissance et de redistribution.

dfgtgr inc_t1 Inc_t2, alpha(1) pline(10.4)