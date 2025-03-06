*****11,5%

*****************************************************************FATOUMATA DIENG, IDUL:FADIE6****************************************************


// Using the latest updated DASP files
set more off
net from http://dasp.ecn.ulaval.ca/modules/DASP_V2.3/dasp
net install dasp_p1, force
net install dasp_p2, force
net install dasp_p3, force
net install dasp_p4, force
addDMenu profile.do _daspmenu 


***************************************************************************************************************************************************************
******                                                     EXERCICE 1**3.5%
***************************************************************************************************************************************************************


***:1.1	En utilisant le fichier de données data_b3_3.dta, estimez le seuil de pauvreté subjective en considérant les informations suivantes :

use "C:\Users\data_b3_3.dta", clear

cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)                      ///                  
legend(order( 1 "Perceived  minimum  well-being " 2 "Observed well-being"))  ///
subtitle("") title(The subjective poverty line) 						     ///
 xtitle(Observed well-being) 									             /// 
 ytitle(Predicted level of the perceived  minimum  well-being )              ///
 vgen(yes) 
 
 /* Estimer le niveau de ae_exp lorsque la différence entre le bien-être minimum prévu et le bien-être observé est nulle. */
cap drop dif  
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) xval(0) vgen(yes) 

/*Showing the subjective poverty line  */
cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)                      ///
legend(order( 1 "Perceived  minimum  well-being " 2 "Observed well-being"))  ///
subtitle("") title(The subjective poverty line) 						     ///
xline( 22692.876953) xtitle(Observed well-being) 						     ///
ytitle(Predicted level of the perceived  minimum  well-being ) 

//  1.2: Estimez l’intensité de la pauvreté (avec les variables : ae_exp and hsize) pour chacun de ces trois cas :

//a) Le seuil de pauvreté subjective:
ifgt  ae_exp, alpha(0) hsize(hsize) pline(22692.876953)
//b) Le seuil de pauvreté absolue (z=20900) 
ifgt  ae_exp, alpha(0) hsize(hsize) pline(20900)
//c) Le seuil de pauvreté relative (z= moitié du revenu moyens).
ifgt  ae_exp, alpha(0) hsize(hsize) opl(mean) prop(50)


***************************************************************************************************************************************************************
******                                                     EXERCICE 2*****4%
***************************************************************************************************************************************************************

//2.1) Utilisez le fichier data_b3_3.dta et décomposez la pauvreté (taux de pauvreté) selon le sexe du chef de ménage (sex) (le seuil de pauvreté est 20900). Que pouvons-nous conclure ?  

dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20900)

//2.2) Estimez la pauvreté totale (taux de pauvreté) en fonction de la région du chef de ménage (region). 

dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(20900)

//2.3) La répartition des dépenses en équivalent-adultes est similaire à celle de la période initiale (ae_exp), avec les légères différences suivantes
*•	Les dépenses en équivalent-adultes ont augmenté de 11% dans la région 3;
*•	Les dépenses en équivalent-adultes ont diminué de 6% dans la région 2;
*Générez la variable ae_exp2 en vous basant sur les informations ci-dessus. 

scalar ae_expregion1=ae_exp*(region==1)
scalar ae_expregion2=ae_exp*(region==2)*0.94
scalar ae_expregion3=ae_exp*(region==3)*1.11 
scalar ae_expregion4=ae_exp*(region==4)
gen ae_exp2=  ae_expregion1 + ae_expregion2 + ae_expregion3+ ae_expregion4

//2.4) En utilisant l'approche de Shapley, décomposez le changement de l'intensité de la pauvreté en croissance et redistribution. Puis discutez des résultats.

dfgtgr ae_exp ae_exp2, alpha(1) pline(20900)

//2.5) Effectuez une décomposition sectorielle (basée sur les groupes de régions) de la variation de l'intensité de la pauvreté totale. Discutez des résultats.

dfgtgr ae_exp ae_exp2,cond(activity & region) alpha(1) pline(20900)



***************************************************************************************************************************************************************
******                                                     EXERCICE 3****4.5%
***************************************************************************************************************************************************************


//3.1)Insérez les données, puis générez les centiles (basé sur le rang des revenus de la période initiale (variable perc)), et le premier centile doit être égal à zéro).

clear
input identifier	weight	inc_t1	inc_t2
0 0 0 0
1	0.1	1.50	1.54
2	0.1	4.50	3.85
3	0.1	7.50	6.60
4	0.1	3.00	2.75
5	0.1	4.50	4.40
6	0.1	9.00	7.70
7	0.1	10.50	8.80
8	0.1	15.00	7.70
9	0.1	11.00	6.60
10	0.1	13.50	6.60
end
sort inc_t1
gen perc=sum(weight)

//3.2) Initialisez le scalaire g_mean, qui est égal au taux de croissance du revenu moyen.

qui sum inc_t1 [aw=weight] 
scalar mean1=r(mean) 
qui sum inc_t2 [aw=weight]
scalar mean2=r(mean)
scalar g_mean = (mean2-mean1)/mean1
gen g_mean  = (mean2-mean1)/mean1
dis "Mean 1              =" mean1
dis "Mean 2             = " mean2
dis "Growth in averages = " g_mean

//3.3) Générez la variable g_inc, comme la croissance des revenus individuels.

gen g_inc =(inc_t2-inc_t1)/inc_t1
replace g_inc = 0 in 1

//3.4)Dessinez la courbe d’incidence de la croissance à l’aide des variables g_inc et perc. Discutez des résultats.

line g_inc g_mean perc, title(Growth Incidence Curve) yline(`g_mean') ///
legend(order( 1 "GIC curve" 2 "Growth in average income")) ///
xtitle(Percentiles (p)) ytitle(Growth in incomes)  ///
plotregion(margin(zero))

//  3.5)Supposons que le seuil de pauvreté est égal à 10.4. Estimez l'indice pro-pauvres de Chen et Ravallion (2003) (IP=1/q ∑_(i=1)^q▒〖γ^t (p_i ) 〗). Discutez des résultats.

drop in 1
cap drop temp
gen temp = g_inc
sum temp [aw=weight] if (inc_t1<10.2)
dis = r(mean)
ipropoor inc_t1 inc_t2, pline(10.2) // donne le meme resultat que la commande precedente

//  3.6) En utilisant l'approche de Shapley, décomposez le changement de l'intensité de la pauvreté en composantes de croissance et de redistribution. Discutez des résultats.

dfgtgr inc_t1 inc_t2, alpha(1) pline(10.2)