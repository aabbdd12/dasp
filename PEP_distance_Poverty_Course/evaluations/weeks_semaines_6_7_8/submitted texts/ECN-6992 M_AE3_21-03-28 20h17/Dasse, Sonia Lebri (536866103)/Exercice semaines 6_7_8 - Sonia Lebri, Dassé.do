******************12%

//Code stata pour l'exercice semaines 6_7_8

// Exercice 1

//  Q1:
/* Utilisation de la technique de régression non paramétrique pour prédire le bien-être minimum perçu */
/*
La commande Stata :
cnpe ae_exp min_ae_exp, xvar(ae_exp) min(0) max(60000) ...
va dessiner deux courbes.
- La première courbe montrera la relation entre la variable Y : ae_exp et la variable X ae_exp.
- La seconde courbe montrera la relation entre la variable Y : min_ae_exp et la variable X ae_exp.
La plage de l'axe X est comprise entre 0 et 600000.
*/

use data_b3_2.dta, clear 
cnpe ae_exp  min_ae_exp, xvar(ae_exp) hsize(hsize) min(0) max(60000)                      ///
legend(order( 1 "Perceived  minimum  well-being " 2 "Observed well-being"))  ///
subtitle("") title(The subjective poverty line)            ///
 xtitle(Observed well-being)                       /// 
 ytitle(Predicted level of the perceived  minimum  well-being )              ///
 vgen(yes)
 
/* 
Estimer le niveau de ae_exp lorsque la différence entre le bien-être minimum prévu et le bien-être observé est nulle.
En ajoutant l'option xval(0) au lieu des deux options min() et max(), le cnpe effectue la prédiction pour une seule valeur de X (dif dans notre cas) , à savoir E[ae_exp|dif==0]. 
*/
cap drop dif
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) hsize(hsize) xval(0) vgen(yes)

/*
Afficher le seuil de pauvreté subjectif : Ici nous traçons les deux premières courbes, mais, en plus, nous montrons le seuil de pauvreté subjectif avec l'option xline(22289.966797) 
*/
cnpe ae_exp  min_ae_exp, xvar(ae_exp) hsize(hsize) min(0) max(60000)                      ///
legend(order( 1 "Perceived  minimum  well-being " 2 "Observed well-being"))  ///
subtitle("") title(The subjective poverty line)            ///
xline(22289.966797) xtitle(Observed well-being)            /// 
ytitle(Predicted level of the perceived  minimum  well-being ) 

//  Q2:

ifgt  ae_exp, alpha(1) hsize(hsize) pline(22289.966797)
ifgt  ae_exp, alpha(1) hsize(hsize) pline(20600)
ifgt  ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)


//  Q3: 
/*
L'intensité de la pauvreté permet de percevoir l’éloignement entre le niveau de vie de la population pauvre et le seuil de pauvreté. Dans le cas des pays développés, la méthode la plus appropriée pour mesurer le seuil de pauvreté est la pauvreté relative,  parce ce qu’il considère le niveau de vie du pays et est calculé avec un seuil fixé à 50% du revenu moyen.
*/


// Exercice 2
use data_b3_2.dta, clear 

// Q1:

dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20600)
/*
La contribution (à la pauvreté totale) de la pauvreté chez les ménages dirigés par des femmes (0.361)est supérieure à la contribution qui vient de leur représentativité dans la population totale. La contribution relative et absolue des ménages dirigés par des femmes est inférieure à celle des ménages dirigés par des hommes. 
*/

//  Q2:
 
dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(20600)

// Q3:
gen ae_exp2 = ae_exp
replace ae_exp2 = ((ae_exp*0.12)+ae_exp)  if region == 3
replace ae_exp2 = (ae_exp-(ae_exp*0.06))  if region == 2
sum ae_exp*

// Q4:

dfgtgr ae_exp ae_exp2, alpha(1) pline(20600)


// Q5:
dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(1) pline(20600)
dfgtg ae_exp2, hgroup(region) hsize(hsize) alpha(1) pline(20600)


/* On pourrait à tort cibler le groupe qui présente le plus haut niveau de pauvreté, qui est la région du nord. La procédure exacte qui consiste à rechercher le groupe ayant une forte concentration autour du seuil de pauvreté est effectuée. Avec un transfert marginal d'une unité monétaire au groupe g, la diminution attendue est la suivante : la part de la population du groupe g fois la densité de ce groupe au seuil de pauvreté. */

itargetg ae_exp ae_exp2, alpha(1) pline(20600) hsize(hsize) hgroup(region) constam(1)

/* Sur cette base, il est confirmé que le groupe à cibler est la région du Nord. */


// Exercice 3
//  Q1:

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
list perc


//  Q2:
qui sum inc_t1 [aw=weight]   			
scalar mean1=r(mean)         			
qui sum Inc_t2 [aw=weight]
scalar mean2=r(mean)         			
scalar g_mean = (mean2-mean1)/mean1
gen g_mean  = (mean2-mean1)/mean1    	 
dis "Mean 1              =" mean1
dis "Mean 2             = " mean2
dis "Growth in averages = " g_mean

//  Q3:
gen g_inc =(Inc_t2-inc_t1)/inc_t1 		 
replace g_inc = 0 in 1      
sum g_inc
list g_inc       		  

//  Q4:

line g_inc g_mean perc, ///
title(Courbe d’incidence de la croissance) ///
yline(`g_mean') ///
legend(order( 1 "Courbe CIC" 2 "Taux de croissance du revenu moyen")) ///
xtitle(Percentiles (p)) ytitle(Croissance du revenu)  ///
plotregion(margin(zero))

/*
La pente décroissante (négative) de la courbe d’incidence de la croissance indique que les inégalités diminuent et donc qu’une croissance pro pauvre peut être perçue. Cette courbe montre graphiquement,  comment les percentiles d'une population donnée bénéficient de la croissance pendant une certaine période.
*/

//  Q5:

/*
L'indice pro-pauvre de Chen et Ravallion (2003) est simplement la moyenne de la croissance des revenus des individus pauvres.  
*/

drop in 1
sum g_inc [aw=weight] if (inc_t1<10.4) 	 
dis = r(mean)
ipropoor inc_t1 Inc_t2, pline(10.4)   	 

/*
L’indice Ravallion et Chen (2003) est concerné par la croissance absolue entre les pauvres. Si une personne initialement pauvre au-dessus de la moyenne échappe à la pauvreté, alors le taux de croissance de la moyenne pour les pauvres sera négatif; la pauvreté a diminuée (Ravallion and Chen, 2003).
*/

//  Q6:

dfgtgr inc_t1 Inc_t2, alpha(1) pline(10.4)