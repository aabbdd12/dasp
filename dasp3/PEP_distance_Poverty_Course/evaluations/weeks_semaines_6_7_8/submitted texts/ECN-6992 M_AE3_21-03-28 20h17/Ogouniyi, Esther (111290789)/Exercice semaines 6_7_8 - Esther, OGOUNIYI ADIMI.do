**********11.5%

clear all
drop _all
set more off
cd "C:\Users\Kbir\Desktop\BUREAU\ANNEE2021\LAVAL2021\Exercice\Semaine6-8\Exercice_cours6_7_8"
use data_b3_2
*===============================================================================
*Exercice 1 

/* estimez le seuil de pauvreté subjective en considérant les informations*/

cnpe ae_exp min_ae_exp, xvar(ae_exp) min(0) max(60000) ///
legend(order( 1 "Perceived minimum well-being " 2 "Observed well-being")) ///
subtitle("") title(The subjective poverty line) ///
xtitle(Observed well-being) ///
ytitle(Predicted level of the perceived minimum well-being ) ///
vgen(yes)

cap drop dif
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) xval(0) vgen(yes)


cnpe ae_exp min_ae_exp, xvar(ae_exp) min(0) max(60000) ///
legend(order( 1 "Perceived minimum well-being " 2 "Observed well-being")) ///
subtitle("") title(The subjective poverty line) ///
xline(22327.773438) xtitle(Observed well-being) ///
ytitle(Predicted level of the perceived minimum well-being )

/* 1.2	Estimez l’intensité de la pauvreté (avec les variables : ae_exp and hsize) ///
pour chacun de ces trois cas, et discutez les résultats :*/

*a)	Le seuil de pauvreté subjective ;

ifgt ae_exp, alpha(0) hsize(hsize) pline(22327.773438)

*b)	Le seuil de pauvreté absolue (z=20600) 

ifgt ae_exp, alpha(0) hsize(hsize) pline(20600)

*c)	Le seuil de pauvreté relative (z= moitié du revenu moyens).

ifgt ae_exp, alpha(0) hsize(hsize) opl(mean) prop(50)

*===============================================================================
*Exercice 2

/* 2.1	Utilisons le fichier data_b3_2.dta et décomposons la pauvreté (taux de pauvreté)///
 selon le sexe du chef de ménage (sex) (le seuil de pauvreté est 20600)*/

 dfgtg ae_exp, hgroup(sex) hsize(hhid) alpha(0) pline(20600)
 
 /* 2.2 Estimons la pauvreté totale (taux de pauvreté) en fonction de la région du chef ///
 de ménage (region).  */
 
  dfgtg ae_exp, hgroup(region) hsize(hhid) alpha(0) pline(20600)

 /*2.3 Générez la variable ae_exp2 en vous basant sur les informations ci-dessus*/
  
  gen ae_exp2 = ae_exp
  
  replace ae_exp2 = 1.12*ae_exp if region == 3
  
  replace ae_exp2 = .94*ae_exp if region == 2
  
  
 /* 2.4	En utilisant l'approche de Shapley, décomposez le changement de l'intensité ///
 de la pauvreté en croissance et redistribution. Puis discutez des résultats.*/
 
dfgtgr ae_exp ae_exp2, alpha(0) pline(20600)
 
/*2.5	Effectuez une décomposition sectorielle (basée sur les groupes de régions) ///
de la variation de l'intensité de la pauvreté totale. Discutez des résultats.*/

*Central (Central)

dfgtgr ae_exp ae_exp2, alpha(0) pline(20600) cond1(region==1 ) cond2(region==1 )

*Est (Eastern)

dfgtgr ae_exp ae_exp2, alpha(0) pline(20600) cond1(region==2 ) cond2(region==2 )

*Nord (Northern)

dfgtgr ae_exp ae_exp2, alpha(0) pline(20600) cond1(region==3 ) cond2(region==3 )

*Ouest (Western)

dfgtgr ae_exp ae_exp2, alpha(0) pline(20600) cond1(region==4 ) cond2(region==4 )
 

 *==============================================================================
 
 *RXERCICE 3
 
 /* 3.1 Insérez les données, puis générez les centiles (basé sur le rang des revenus ///
 de la période initiale (variable perc)), et le premier centile doit être égal à zéro).*/

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

sort inc_t1

gen perc=sum(weight)

/* 3.2	Initialisez le scalaire g_mean, qui est égal au taux de croissance du revenu moyen.*/

qui sum inc_t1 [aw=weight]

scalar mean1=r(mean)

qui sum Inc_t2 [aw=weight]

scalar mean2=r(mean)

scalar g_mean = (mean2-mean1)/mean1

gen g_mean = (mean2-mean1)/mean1


dis "Mean 1 =" mean1
dis "Mean 2 = " mean2
dis "Growth in averages = " g_mean


/*Générez la variable g_inc, comme la croissance des revenus individuels.*/

gen g_inc =(Inc_t2-inc_t1)/inc_t1
replace g_inc = 0 in 1

/*3.4	Dessinez la courbe d’incidence de la croissance à l’aide des variables ///
g_inc et perc. Discutez des résultats.*/

line g_inc g_mean perc, ///
title(Growth Incidence Curve) ///
yline(`g_mean') ///
legend(order( 1 "GIC curve" 2 "Growth in average income")) ///
xtitle(Percentiles (p)) ytitle(Growth in incomes) ///
plotregion(margin(zero))

/* 3.5 Supposons que le seuil de pauvreté est égal à 10.4. Estimez l'indice pro-pauvres ///
de Chen et Ravallion (2003) */

drop in 1
sum g_inc [aw=weight] if (inc_t1<10.4) 

dis = r(mean)
ipropoor inc_t1 Inc_t2, pline(10.4)

/* En utilisant l'approche de Shapley, décomposez le changement de l'intensité de 
la pauvreté en composantes de croissance et de redistribution */

dfgtgr inc_t1 Inc_t2, alpha(1) pline(10.4)
