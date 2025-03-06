*******12%

*********Exercice pratique semaine 6_7_8*******************

// Code stata exercice 1*********3.5%

clear

 use "D:\Cours  renforcement PEP\Analyse de la pauvrete\Evaluation\Evaluation semaine 6_7_8\data_b3_2.dta" 


/* 1: Estimation du seuil de pauvreté subjective*/

**** Relation entre le bien-être équivalent adulte et le bien-être équivalent adulte perçu minimum et génération de leur valeure prédictes*****

cnpe ae_exp min_ae_exp, xvar(ae_exp) hsize(hsize) min(0) max(60000) ///
legend(order( 1 "Bien-être minimum perçu " 2 "Bien-être observé")) ///
subtitle("") title(Seuil de pauvreté subjective) ///
xtitle(Bien-être observé) ///
ytitle(Niveau prédit du bien-être minimum) ///
vgen(yes)

************Estimation du seuil de pauvreté subjective************

gen diff = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(diff) hsize(hsize) xval(0) vgen(yes)

***************Affichage du seuil de pauvreté sur la courbe*************
***Tracer du seuil de pauvreté subjective en utilisant l'option xline(22289.966797)

cnpe ae_exp min_ae_exp, xvar(ae_exp) min(0) max(60000) ///
legend(order( 1 "Bien-être minimum perçu" 2 "Bien-être observé")) ///
subtitle("") title(Seuil de pauvreté subjective) ///
xline(22289.966797) xtitle(Bien-être observé) ///
ytitle(Niveau prédict du bien-être minimum )


/* 2: Estimation de l'intensité de la pauvreté*/

***********Seuil de pauvreté subjective********

ifgt ae_exp, alpha(1) hsize(hsize) pline(22289.966797)
 
************ Seuil de pauvreté absolue*************
ifgt ae_exp, alpha(1) hsize(hsize) pline(20600)
 
************ Seuil de pauvreté relative*************

ifgt ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)




***********************************************Exercice 2*********************************4%

// Code stata exercice 2

clear

use "D:\Cours  renforcement PEP\Analyse de la pauvrete\Evaluation\Evaluation semaine 6_7_8\data_b3_2.dta" 

/*1: Décomposition du taux de pauvreté en fonction du sexe du chef de ménage*/

dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20600)

/*2: Décomposition du taux de pauvreté en fonction de la région*/

dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(20600)

itargetg ae_exp, alpha(0) pline(20600) hsize(hsize) hgroup(region) constam(1)


/*Générer la variable ae_exp2*/
*******Dans la région 3 ae_exp est augmenté de ae_exp*0.12 donc ae_exp2 = ae_exp*(1+0.12) dans la région 2 ae_exp est diminuer de ae_exp*0.06 donc ae_exp2 = ae_exp*(1-0.06)****

gen ae_exp2 = ae_exp

replace ae_exp2 = ae_exp*1.12 if region==3

replace ae_exp2 = ae_exp*0.94 if region==2
**************Pour lister toutes les observations de ae_exp et ae_exp2***********
list ae_exp ae_exp2 region

************Pour afficher les 10 premières observations***************

list ae_exp ae_exp2 region in 1/10, fvall 

/*4: Décomposition du changement de l'intensité de la pauvreté par l'approche de Shapley*/

 dfgtgr ae_exp ae_exp2, alpha(1) pline(20600) hsize1(hsize) hsize2(hsize)
 
/*5: Décomposition sectorielle de la variation de l'intensité de la pauvreté*/

dfgtg2d ae_exp ae_exp2, alpha(1) hgroup(region) pline(20600) hsize1(hsize) hsize2(hsize)
 
 
 
 **************************Exercice 3***************************************4.5%
 
 
 // Code stata exercice 3
 
 clear
 
 /*1: Insection des données*/
 
 input ident	weight	inc_t1	inc_t2
		0		0		0.00	0.00
		1		0.1		1.50	1.54
		2		0.1		4.50	3.85
		3		0.1		7.50	6.60
		4		0.1		3.00	2.75
		5		0.1		4.50	4.40
		6		0.1		9.00	7.70
		7		0.1		10.50	8.80
		8		0.1		15.00	7.70
		9		0.1		12.00	6.60
		10		0.1		13.50	6.60
end

***************Ordonner les données suivant le revenu de la première période*************
sort inc_t1

**********Générer les centiles************
gen perc = sum(weight)

list perc

/*2: Initialisation du taux de croissance du revenu*/

************** Calculer la moyenne des revenu en t1***********
qui sum inc_t1 [aw=weight]
scalar mean1 = r(sum)

************** Calcul de la moyenne des revenus de la période 2***********
qui sum inc_t2 [aw=weight]
scalar mean2 = r(sum)

***********Initialisation du scalaire g_mean***********
scalar g_mean = (mean2 - mean1)/mean1

**********Génégrer le taux de croissance du revenu g_mean************
gen g_mean = (mean2 - mean1)/mean1
list g_mean

dis "Mean1 = " mean1
dis "Mean2 = " mean2
dis "croissance des moyennes = " g_mean 

/*3: Générer la croissance des revenus individuels g_inc*/
gen g_inc = (inc_t2 - inc_t1)/inc_t1
replace g_inc = 0 in 1
list g_inc perc

/*4: Courbe d'incidence de la croissance*/

line g_inc g_mean perc, ///
title(Courbe d'incidence de croissance) ///
yline(`g_mean') ///
legend(order(1 "Croissance revenu individuel" 2 "Croissance du revenu moyen")) ///
xtitle(Percentiles (p)) ytitle(Croissance des revenus) ///
plotregion(margin(zero))



/*5: Estimation de l'indice pro-pauvre de Ravalion*/
drop in 1
sum g_inc [aw=weight] if (inc_t1<10.4)
dis = r(mean)

ipropoor inc_t1 inc_t2, alpha(0) pline(10.4)
list inc_t1 inc_t2 perc

/*6: Décomposition du changement de l'intensité de la pauvreté*/

dfgtgr inc_t1 inc_t2, alpha(1) pline(10.4)