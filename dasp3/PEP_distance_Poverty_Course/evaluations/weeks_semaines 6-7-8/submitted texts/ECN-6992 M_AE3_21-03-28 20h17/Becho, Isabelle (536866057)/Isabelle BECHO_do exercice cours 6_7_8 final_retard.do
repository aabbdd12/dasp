***********************12.5%
clear
use "C:\Users\Isabelle BECHO\Dropbox\Mon PC (DESKTOP-PJCJ5KR)\Documents\COURS PEP\cours et homework pauvreté\Devoir 3 pauvrete\data_b3_1.dta" 
preserve
log using "C:\Users\Isabelle BECHO\Dropbox\Mon PC (DESKTOP-PJCJ5KR)\Documents\COURS PEP\cours et homework pauvreté\Devoir 3 pauvrete\log devoir3 exo 1.smcl"
*Exercice 1 (3.5%):  3.5%

*Q1.1 Estimez le seuil de pauvreté subjective 

sum ae_exp min_ae_exp

cnpe ae_exp min_ae_exp, xvar(ae_exp) hsize(hsize) min(0) max(60000) legend(order( 1 " Bien-être observé" 2 "Perception minimum du Bien-être")) subtitle("") title(Le seuil de pauvreté subjectif) xtitle(Bien-être observé) ytitle(Niveau prédit du bien-être minimum perçu) vgen(yes)

cap drop dif
gen dif = _npe_min_ae_exp- ae_exp

**Seuil de pauvreté relatif*********
cnpe ae_exp, xvar(dif) xval(0) hsize(hsize) vgen(yes)

**************************

cnpe ae_exp  min_ae_exp, xvar(ae_exp) hsize(hsize) min(0) max(60000) legend(order( 1 " Bien-être observé" 2 "Perception minimum du Bien-être")) subtitle("") title(Le seuil de pauvreté subjectif) xline(22922.419922) xtitle(Bien-être observé) ytitle(Niveau prédit du bien-être minimum perçu) vgen(yes)

*Q1.2.Estimez l’intensité de la pauvreté

*a) Le seuil de pauvreté subjective ;
ifgt ae_exp, alpha(1) hsize(hsize) pline(22922.419922)
*b) Le seuil de pauvreté absolue (z=21000)
ifgt  ae_exp, alpha(1) hsize(hsize) pline(21000)
*c)Le seuil de pauvreté relative (z= moitié du revenu moyens).
ifgt ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)

*Q1.3 Selon vous, quelle est la méthode la plus appropriée pour mesurer la pauvreté dans les pays développés et pourquoi ? 


*****EXERCICE 2***********************************************4.5%

*Q2.1.Utilisez le fichier data_b3_1.dta et décomposez la pauvreté (taux de pauvreté) selon le sexe du chef de ménage (sex) (le seuil de pauvreté est 21000).

dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(21000)

*Q2.2 Estimez la pauvreté totale (taux de pauvreté) en fonction de la région du chef de ménage (region)

ifgt ae_exp, hgroup(region) hs(hsize) alpha(0) pline(21000)

*Q2.3 Générez la variable ae_exp2

ge ae_exp2 = ae_exp*1.1 if region==3
replace ae_exp2 = ae_exp*0.94 if region==2
replace ae_exp2 = ae_exp if ae_exp2==.
sum ae_exp ae_exp2

*Q2.4 l'approche de Shapley, décomposez le changement de l'intensité de la pauvreté en croissance et redistribution.

dfgtgr ae_exp ae_exp2 , alpha(1) pline(21000)

*Q2.5 Effectuez une décomposition sectorielle (basée sur les groupes de régions) de la variation de l'intensité de la pauvreté totale

dfgtg ae_exp2, hgroup(region) hsize(hsize) alpha(1) pline(21000)


**************EXERCICE 3************************4%

*Q3.1 Insérez les données, puis générez les centiles (basé sur le rang des revenus de la période initiale (variable perc)), et le premier centile doit être égal à zéro).


input Identifier weight inc_t1 inc_t2
0 0.0 0.00 0.00
1 0.1 1.50 1.54
2 0.1 4.50 3.85
3 0.1 7.50 6.60
4 0.1 3.00 2.75
5 0.1 4.50 4.40
6 0.1 9.00 7.70
7 0.1 10.50 8.80
8 0.1 15.00 7.70
9 0.1 12.00 6.60
10 0.1 13.50 6.60
end


sort inc_t1

gen perc=sum(weight)

list perc

*Q3.2	Initialisez le scalaire g_mean, qui est égal au taux de croissance du revenu moyen.

qui sum inc_t1 [aw=weight]
scalar mean1=r(mean)
qui sum inc_t2 [aw=weight]
scalar mean2=r(mean)
scalar g_mean = (mean2-mean1)/mean1
gen g_mean  = (mean2-mean1)/mean1
dis "Mean 1  =" mean1
dis "Mean 2  = " mean2
dis "Growth in averages = " g_mean

*Q3.3 Générez la variable g_inc, comme la croissance des revenus individuels.

gen g_inc =(inc_t2-inc_t1)/inc_t1

list g_inc

replace g_inc = 0 if g_inc==.

list g_inc

*Q3.4 Dessinez la courbe d’incidence de la croissance à l’aide des variables g_inc et perc. Discutez des résultats.

line g_inc g_mean perc,title(Courbe d’incidence de la croissance) yline(`g_mean') legend(order( 1 "GIC curve" 2 "Growth in average income")) xtitle(Percentiles (p)) ytitle(Growth in incomes) plotregion(margin(zero))

*Q3.5 Supposons que le seuil de pauvreté est égal à 10.2. Estimez l'indice pro-pauvres de Chen et Ravallion (2003). Discutez des résultats.
drop in 1
sum g_inc [aw=weight] if (inc_t1<10.2)
dis = r(mean)
ipropoor inc_t1 inc_t2, pline(10.2)

*Q3.6 En utilisant l'approche de Shapley, décomposez le changement de l'intensité de la pauvreté en composantes de croissance et de redistribution. Discutez des résultats

dfgtgr inc_t1 inc_t2, alpha(1) pline(10.2)

*******Fin du devoir***********************************