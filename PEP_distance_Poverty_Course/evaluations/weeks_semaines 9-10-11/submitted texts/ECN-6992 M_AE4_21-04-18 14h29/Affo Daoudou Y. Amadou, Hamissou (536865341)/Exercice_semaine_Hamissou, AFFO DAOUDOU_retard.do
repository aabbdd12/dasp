***********8,5%

*==============================================================================
*AFFO DAOUDOU Y.AMADOU Hamissou 
*==============================================================================
clear all
drop _all
set more off
*===============================================================================
*Exercice1***********1,5%

clear

input Individu	w_1	w_2	w_3
 1 	4	20	12
 2	8	12	0
 3	16	16	24
 4 	12	12	16
 5	28	20	8
 6 	24	16	12

end

*1.1	En utilisant l'approche de l’union, estimez la proportion d'individus pauvres. 
/*Refaites l'estimation à l'aide de la commande DASP appropriée.*/

 
imdp_uhi w_1 w_1 w_3, pl1(14) pl2(14) pl3(14)

/*1.2	En utilisant l'approche par intersection, estimez la proportion d'individus pauvres. 
Refaites l'estimation à l'aide de la commande DASP appropriée.*/
imdp_ihi w_1 w_2 w_3, pl1(14) pl2(14) pl3(14)

*1.3

*1.4

/*1.5	Estimez maintenant les mêmes indices à l'aide de la commande DASP 
appropriée. Discutez des résultats.*/


imdp_afi w_1 w_2 w_3, dcut(2) w1(1) pl1(14) w2(1) pl2(14) w3(1) pl3(14)

 
*Exercice 2******3,5%

*2.1

/*2.2	Refaites l'estimation à l'aide de la commande DASP appropriée.*/

imdp_bci w_1 w_2 w_3, alpha(1) gamma(1) b1(1) pl1(7) b2(1) pl2(7) b3(1) pl3(7)

/*2.3	Générez trois nouvelles variables (nw_ *) dans lesquelles les individus 
égalisent leurs dimensions de bien-être (exemple : gen nw_1 = (w_1+ w_2+w_3) /3) 
(c'est-à-dire, par exemple, l'individu 1 a 2, 10, 6 dans les trois dimensions 
respectivement. Après l’égalisation, nous aurons : 6, 6, 6.). */
 
gen nw_1 = (w_1+ w_2+w_3) /3
 
gen nw_2 = nw_1

gen nw_3 = nw_1

list nw_1 nw_2 nw_3


/*Ensuite, en utilisant DASP, réestimez l’indice BC avec les nouveaux vecteurs 
du bien-être. Expliquez la direction du changement dans l'indice BC.*/

imdp_bci nw_1 nw_2 nw_3, alpha(1) gamma(1) b1(1) pl1(14) b2(1) pl2(14) b3(1) pl3(14)





clear all
drop _all
set more off
*Exercice 3*********3,5%
*===============================================================================
cd "C:\Users\Kbir\Desktop\BUREAU\ANNEE2021\LAVAL2021\AFFO\Examen"
 use Canada_Incomes&Taxes_1996_2005_random_sample_3  
 preserve 
*===============================================================================



/*3.1	A l'aide des observations de 2005, estimons l’espérance des taux marginaux 
d'impôts, de bénéfices et de revenus nets pour la plage de revenus bruts comprise 
entre 1 000 et 31 000 $ */

keep if year==2005

cnpe T B N, xvar(X) type(npr) min(0) max(10000) 

restore

keep if year==1999|year==2002|year==2005 

igini X N
local Gini_X=el(e(est),1,1)
local Gini_N=el(e(est),2,1)
igini N, rank(X)
local CONC_N=el(e(est),1,1)
dis "Difference " =  `Gini_X' - `Gini_N'
dis "VE"  = `Gini_X' - `CONC_N'
dis "HI"  = `Gini_N' - `CONC_N'

/*3.3	Estimons l'indice de progressivité de Kakwani par an à l'aide de la commande
 DASP iprog.*/
 
  iprog N, ginc(X) type(t) index(ka) gobs(year)
  
  /*3.4	À l'aide des observations de 2005, vérifions la condition de TR progressivité 
  pour la taxe T à l'aide de la commande DASP cprog.*/
 
 keep if year==2005
 cprog T, rank(X) type(t) appr(tr)
 
 /*3.5	Dans quelle province l'inégalité était-elle la plus élevée en 2005 ? */
 
 imdp_mfi X, hgroup(province) al1(0) pl1(7)

 
 /*Dans quelle province l’indice de progressivité fiscale de Kakwani était-il le 
 plus élevé de 2005 ?*/
 
 
iprog T, ginc(X) gobs(province) type(t) index(ka)

