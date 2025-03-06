***********************12%
clear all

***Exercice 1

cd  "C:\Users\nyago\Documents\PERSO\PEP Laval\DEV3\"
use data_b3_1.dta,clear

svyset psu [pweight=sweight], strata(strata)

*** regression non paramétrique entre  ae_exp et min_ae_exp 

***Q1.1
cnpe ae_exp  min_ae_exp, xvar(ae_exp) hs(hsize) min(0) max(100000)                      ///
legend(order( 1 "bien-être équiv. ad.observé" 2 "bien-être équiv.ad. perçu min "))  ///
subtitle("") title(Ligne de pauvreté subjective)   xline(22922.419922)         ///
 xtitle(Observed well-being)                       /// 
 ytitle(valeurs prédites du bien-être min. perçu )              ///
 vgen(yes)
 

 *** calcul de la ligne de pauvreté subjective 
 cap drop dif
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) hs(hsize) xval(0) vgen(yes)

***calcul des taux de pauvreté 

**Q.12 
*a) pauvreté subjective 

ifgt  ae_exp, alpha(1) hsize(hsize) pline(22922.419922)

*b) Pauvreté objective 
ifgt  ae_exp, alpha(1) hsize(hsize) pline(21000)

*c)Pauvreté relative 
sum ae_exp [aw=sweight*hsize]
scalar moy=r(mean)
display moy

ifgt ae_exp, alpha(1)  hs(hsize) opl(mean) prop(50)


**Q1.3


***Exercice 2

*Q2.1 decomposition du taux de pauvreté en fonction du sex du chef de ménage

dfgtg ae_exp, hs(hsize) alpha(0) hg(sex) pline(21000)

*Q2.2  decomposition  du taux de pauvreté en fonction de la region 

dfgtg ae_exp, hs(hsize) alpha(0) hg(region) pline(21000)

***** Q2.3 creation de la variable ae_exp2

gen ae_exp2 =ae_exp
replace ae_exp2=ae_exp*(1.1) if region==3
replace ae_exp2=ae_exp*(0.94) if region==2

*Q2.4 decomposition du changement dans l'intensité de la pauvreté selon l'approche de Shapley en croissance/redistribution

dfgtgr ae_exp ae_exp2, alpha(1) hs(hsize) pline(21000)

gen neteffect=ae_exp2-ae_exp

 cnpe neteffect, xvar(ae_exp) min(2800) max(150000) xline(21000)


**Q2.5 Décomposition de la variation de l'intensité de la pauvreté  selon les régions: 


forvalues i=1/4 {
	preserve
	keep if region==`i'
	display "region =`i'"
	
	difgt ae_exp ae_exp2, pline1(21000) pline2(21000) hsize1(hsize)  hsize2(hsize) alpha(1) 

	dfgtgr ae_exp ae_exp2, hsize1(hsize) hsize2(hsize) alpha(1) pline(21000)

	restore
}
 
   
 ****Exercice 3
 
 clear all
 input Identifier weight inc_t1 inc_t2
 0 0 0 0
 1 0.1 1.5 1.54
 2 0.1 4.5 3.85
 3 0.1 7.5 6.6
 4 0.1 3  2.75
 5 0.1 4.5 4.4
 6 0.1 9 7.7
 7 0.1 10.5 8.8
 8 0.1 15 7.7
 9 0.1 12 6.6
 10 0.1 13.5 6.6
  end

  
 *Q3.1 **calcul du percentile

sort inc_t1
gen perc=sum(weight)

*Q3.2  calcul du taux de croissance des moyenne  de revenus
sum inc_t1 [aw=weight]
scalar moy_t1=r(mean)

sum inc_t2 [aw=weight]
scalar moy_t2=r(mean)

scalar g_mean=(moy_t2-moy_t1)/moy_t1

display g_mean 

**Q3.3 creation de la variable taux de croissance des revenus 
gen g_inc=(inc_t2-inc_t1)/inc_t1 if Identifier!=0
replace g_inc=0 if Identifier==0

*Q3.4	Dessin de la courbe d’incidence de la croissance 

gen poor=(inc_t1<10.2)
tab poor [aw=weight]

gen g_mean=g_mean

line g_inc g_mean perc, ///
title(courbe d’incidence de la croissance ) ///
yline(`g_mean') xline(0.6) ///
legend(order( 1 "CIC " 2 "Taux de croissance moyenne")) ///
xtitle(Percentiles (p)) ytitle(croissance des revenus)  ///
plotregion(margin(zero))

** Q3.5 Estimez l'indice pro-pauvres de Chen et Ravallion (2003)

*** Taux de croissance moyenne  chez les pauvres
sum g_inc [aw=weight]  if inc_t1<10.2
scalar   IP=r(mean)

display "Indice pro-pauvres de Chen et Ravallion (2003):" IP

**Q3.6  decomposition par methode de Shaplay de l'intensité en croissance et redistribution

dfgtgr inc_t1 inc_t2, alpha(1) pline(10.2)

