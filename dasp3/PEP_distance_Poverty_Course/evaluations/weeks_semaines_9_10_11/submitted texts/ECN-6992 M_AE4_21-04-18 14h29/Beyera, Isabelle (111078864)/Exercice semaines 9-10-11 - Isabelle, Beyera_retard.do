*******11,5%
//Exercice 1 //****4%

//1.1	En utilisant l'approche de l’union, estimez la proportion d'individus pauvres
/* Nous entrons d'abord les données dans STATA à l'aide de la commande input:*/
clear
set obs 6
qui input  str10 Individu  w_1        w_2       w_3
"Individu 1" 2 10 6
"Individu 2" 4 6 0
"Individu 3" 8 8 12
"Individu 4" 6 6 8
"Individu 5" 14 10 4
"Individu 6" 12 8 6

/* Avec l'approche de l'union, un individu est dit pauvre signifie que ce dernier est pauvre dans au moins une dimension */ 
gen poor1=1 if w_1<=7| w_2<=7|w_3<=7
replace poor1=0 if poor1==.
sum poor1

/*Avec la commande DASP on a: */
imdp_uhi w_1 w_2 w_3, pl1(7) pl2(7) pl3(7)

//1.2	En utilisant l'approche par intersection, estimez la proportion d'individus pauvres. 
/* Avec l'approche par intersection, un individu est dit pauvre lorsque ce dernier est pauvre dans toutes les dimensions */
gen poor2=1 if w_1<=7 & w_2<=7 & w_3<=7
replace poor2=0 if poor2==.
sum poor2

/*Avec la commande DASP on a: */
imdp_ihi w_1 w_2 w_3, pl1(7) pl2(7) pl3(7)

tabdisp Individu , cellvar(poor1 poor2) //cette commande permet d'afficher les variables poor1 et poor2 dans un tableau.

//1.4	Estimez l’indice Alkire et Foster MPI(α=0) lorsque le seuil dimensionnel est égal à 2 (les pauvres sont ceux qui ont deux ou trois dimensions de privation).


//1.5	Estimez maintenant les mêmes indices à l'aide de la commande DASP appropriée. Discutez des résultats.

imdp_afi w_1 w_2 w_3, dcut(2) w1(1) pl1(7) w2(1) pl2(7) w3(1) pl3(7)


//Exercice 2//**3%

//2.1	Estimez l’indice de pauvreté de Bourguignon et Chakravarty (2003)


//2.2	Refaites l'estimation à l'aide de la commande DASP appropriée.
imdp_bci w_1 w_2 w_3, alpha(1) gamma(1) b1(0.33) pl1(7) b2(0.33) pl2(7) b3(0.33) pl3(7)

//2.3	Générez trois nouvelles variables (nw_ *) 
/* Génération des trois nouvelles variables (nw_ *) */
gen nw_1 = (w_1+ w_2+w_3)/3
gen nw_2 = (w_1+ w_2+w_3)/3
gen nw_3 = (w_1+ w_2+w_3)/3

/*réestimation de l’indice BC avec les nouveaux vecteurs du bien-être */
imdp_bci nw_1 nw_2 nw_3, alpha(1) gamma(1) b1(0.33) pl1(7) b2(0.33) pl2(7) b3(0.33) pl3(7)


//Exercice 3//*4%

/*3.1	A l'aide des observations de 2005, estimons l’espérance des taux marginaux d'impôts, de bénéfices et de revenus nets pour la plage de revenus bruts comprise entre 1 000 et 31 000 $*/ 
clear
use "C:\Users\LENOVO\OneDrive\Desktop\pep\2021 course\Assignments\devoirs\week 9 10 11\Canada_Incomes&Taxes_1996_2005_random_sample_2.dta"
preserve
keep if year==2005
cnpe T B N, xvar(X) hsize(hhsize) type(dnp) min(1000) max(31000)
restore

/*3.2	Estimons l’impact redistributif sur l’indice d’inégalité de Gini pour 1999, 2002 et 2005*/ 

/*Ceci nous emmène à estimer la différence entre deux indices de Gini de deux distributions données que sont le revenu brut X et le revenu net N, soit (X,N). Ainsi cet impact redistributif peut être exprimé comme une différence entre deux composantes principales :
Gini_X-Gini_N = VE- HI 
où : 
VE = (Gini_X - CONC_N) qui est la différence entre le Gini du revenu brut X et l'indice de concentration du revenu net N et qui exprime l'équité verticale;
HI = (Gini_N - CONC_N) qui exprime l'équité horizontale ;
*/
/* pour l'année 1999 */
preserve
keep if year==1999
igini X N, hsize(hhsize)
local Gini_X=el(e(est),1,1)
local Gini_N=el(e(est),2,1)
igini N, rank(X)hsize(hhsize)
local CONC_N=el(e(est),1,1)
dis "Difference = " `Gini_X' - `Gini_N'
dis "VE         = " `Gini_X' - `CONC_N'
dis "HI         = " `Gini_N' - `CONC_N'
restore

/* pour l'année 2002 */
preserve
keep if year==2002
igini X N, hsize(hhsize)
local Gini_X=el(e(est),1,1)
local Gini_N=el(e(est),2,1)
igini N, rank(X) hsize(hhsize)
local CONC_N=el(e(est),1,1)
dis "Difference = " `Gini_X' - `Gini_N'
dis "VE         = " `Gini_X' - `CONC_N'
dis "HI         = " `Gini_N' - `CONC_N'
restore

/* pour l'année 2005*/
preserve
keep if year==2005
igini X N, hsize(hhsize)
local Gini_X=el(e(est),1,1)
local Gini_N=el(e(est),2,1)
igini N, rank(X) hsize(hhsize)
local CONC_N=el(e(est),1,1)
dis "Difference = " `Gini_X' - `Gini_N'
dis "VE         = " `Gini_X' - `CONC_N'
dis "HI         = " `Gini_N' - `CONC_N'
restore

/*3.3	Estimation de l'indice de progressivité de Kakwani par an */

iprog T, ginc(X) hsize(hhsize) gobs(year) type(t) index(ka) //Progressivité des taxes
iprog B, ginc(X) hsize(hhsize) gobs(year) type(b) index(ka) //progressivité des bénéfices

/*3.4 vérifions la condition de TR progressivité pour la taxe T en 2005*/
preserve
keep if year==2005
cprog T, rank(X) hsize(hhsize) type(t) appr(tr)
restore

/*3.5 Estimons l'inégalité et l’indice de progressivité fiscale de Kakwani dans les provinces en 2005*/
preserve
keep if year==2005
igini X, hsize(hhsize) hgroup(province)
igini N, hsize(hhsize) hgroup(province)
iprog T, ginc(X) hsize(hhsize) gobs(province) type(t) index(ka)
restore
