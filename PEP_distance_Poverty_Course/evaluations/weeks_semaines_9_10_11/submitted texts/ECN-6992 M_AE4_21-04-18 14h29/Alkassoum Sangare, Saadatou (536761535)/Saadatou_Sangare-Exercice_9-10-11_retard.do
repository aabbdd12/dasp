************9%

// Code Stata pour l'exercice pratique 2
//Q1:****2%
clear
set obs 6
qui input str10 Individu w_1 w_2 w_3
"Individu 1" 	1	5	3
"Individu 2"	2	3	0
"Individu 3"	4	4	6
"Individu 4" 	3	3	4
"Individu 5"	7	5	4
"Individu 6" 	6	4	3

//Supposons que le seuil de pauvreté pour chacune des trois dimensions soit de 3.5. Effectuer les calculs suivants avec Stata. 
//1.1	En utilisant l'approche de l’union, estimez la proportion d'individus pauvres. Refaites l'estimation à l'aide de la commande DASP appropriée

ifgt w_*, pline(3.5) alpha(1)
// Pour calculer différents indices de pauvreté avec DASP suivant l'approche de l’union 
scalar z = 3.5
gen np1 = (z-w_1)/z // la proportion de pauvre de dimension 1 : rappelons que (z1>w_1)=1 si z1>x1 et zéro sinon. 
gen np2 = (z-w_2)/z // la proportion de pauvre de dimension 1 : rappelons que (z1>w_2)=1 si z1>x1 et zéro sinon. 
gen np3 = (z-w_3)/z // la proportion de pauvre de dimension 1 : rappelons que (z1>w_3)=1 si z1>x1 et zéro sinon. 
                                                                                                                                                  
imdp_uhi w_*, pl1(1) pl6(1) alpha(0) level(0.95) conf(ts) dec(2)

//En utilisant l'approche par intersection, estimez la proportion d'individus pauvres. Refaites l'estimation à l'aide de la commande DASP appropriée. 
imdp_ihi w_*, pl1(1) pl6(1) alpha(0) level(0.95) conf(ts) dec(2)

//Quelle approche est la plus sensible à l'augmentation des privations multiples individuelles ?

//*Estimez l’indice Alkire et Foster MPI(α=0) lorsque le seuil dimensionnel est égal à 2 (les pauvres sont ceux qui ont deux ou trois dimensions de privation).
//La commande DASP imdp_afi peut être utilisée pour calculer l'estimation des indices d'Alkire et Foster (2007) (H0, M0, M1 et M2).*//

imdp_afi w_1 w_2 w_3, dcut(2) w1(1) pl1(1) w2(1) pl2(1) w3(1) pl3(1)

// Estimez maintenant les mêmes indices à l'aide de la commande DASP appropriée. Discutez des résultats.
imdp_mfi w_*, pl1(1) pl6(1) alpha(0) level(0.95) conf(ts) dec(2)


//* Exercice 2*3.5%
//	Estimation de l’indice de pauvreté de Bourguignon et Chakravarty (2003) lorsque β_i=1/3  ∀ i,〖 z〗_i=3.5 ∀ i,   α=1 et ρ=1. 

scalar beta = 1/3
// Calcul de l'écart de pauvreté de chaque dimension  
gen ngap1 = (z-w_1)/z*(z>w_1) 
gen ngap2 = (z-w_2)/z*(z>w_2) 
gen ngap3 = (z-w_3)/z*(z>w_3) 
forvalues alpha = 0/2   {
forvalues beta =  1/3 {
dis "Alpha = " `alpha' " and Beta = " `beta'"}}
Alpha = 0 and Beta = 1
Alpha = 0 and Beta = 2
Alpha = 0 and Beta = 3
Alpha = 1 and Beta = 1
Alpha = 1 and Beta = 2
Alpha = 1 and Beta = 3
Alpha = 2 and Beta = 1
Alpha = 2 and Beta = 2
Alpha = 2 and Beta = 3
end
cap drop pi  
forvalues e = 1.1(0.1)3 {
gen pi = (beta*ngap1^'e'+ (1-beta)*ngap2^'e')^('alpha'/'e')
if ngap1==0 & ngap2==0 replace pi=0 
qui sum pi in 1/2 
// Indice Bourguignon et Chakravarty pour le cas 1 (observations 1 et 2). 
scalar MDI_BC1 = r(mean) 
// Indice Bourguignon et Chakravarty pour le cas 2 (observations 3 et 4). 
qui sum pi in 3/4 
scalar MDI_BC2 = r(mean)
// Indice Bourguignon et Chakravarty pour le cas 3 (observations 5 et 6).  
qui sum pi in 5/6 
scalar MDI_BC3 = r(mean)
dis "The MDI_BC Index (alpha ="%4.2f 'alpha' ", epsilon ="%4.2f 'e' " ) : "  "CASE 1 = " _col(40) %6.4f  MDI_BC1  " ||  CASE 2 =" _col(40) %6.4f  MDI_BC2 " ||  CASE 3 =" _col(40) %6.4f  MDI_BC3}
}
dis _n
}
//2.2	Refaites l'estimation à l'aide de la commande DASP appropriée
imdp_bci w_*, pl1(1) pl6(1) alpha(0) gamma(1) level(0.95) conf(ts)

//2.3	Générez trois nouvelles variables (nw_ *) dans lesquelles les individus égalisent leurs dimensions de bien-être (exemple : gen nw_1 = (w_1+ w_2+w_3)/3) (c'est-à-dire, par exemple, l'individu 1 a 1, 5, 3 dans les trois dimensions respectivement. Après l’égalisation, nous aurons : 3, 3, 3.). Ensuite, en utilisant DASP, réestimez l’indice BC avec les nouveaux vecteurs du bien-être. Expliquez la direction du changement dans l'indice BC.

gen nw_1 = (w_1+ w_2+w_3)/3



//Exercice 3..3,5%

//  Q1:

//*estimez l’espérance des taux marginaux d'impôts, de bénéfices et de revenus nets pour la plage de revenus bruts comprise entre 1 000 et 31 000 $*/
keep if year ==2005
cnpe T X B N, xvar(X) type(dnp) min(1000) max(31000) 

/* En général, on observe que, si les prestations diminuent avec l'augmentation du revenu brut, et que les impôts augmentent.  */

//3.2	Estimez l’impact redistributif sur l’indice d’inégalité de Gini pour 1999, 2002 et 2005 (astuce : utilisez les commandes Stata preserve/restore conserver les données après avoir utilisé la commande Stata “keep if year==…”). 
preserve
keep if year==1999
igini X N 
local Gini_X=el(e(est),1,1)
local Gini_N=el(e(est),2,1)
igini N, rank(X)
local CONC_N=el(e(est),1,1)
dis "Difference = " `Gini_X' - `Gini_N'
dis "VE         = " `Gini_X' - `CONC_N'
dis "HI         = " `Gini_N' - `CONC_N'
restore

preserve
keep if year==2002
igini X N 
local Gini_X=el(e(est),1,1)
local Gini_N=el(e(est),2,1)
igini N, rank(X)
local CONC_N=el(e(est),1,1)
dis "Difference = " `Gini_X' - `Gini_N'
dis "VE         = " `Gini_X' - `CONC_N'
dis "HI         = " `Gini_N' - `CONC_N'
restore

preserve
keep if year==2005
igini X N 
local Gini_X=el(e(est),1,1)
local Gini_N=el(e(est),2,1)
igini N, rank(X)
local CONC_N=el(e(est),1,1)
dis "Difference = " `Gini_X' - `Gini_N'
dis "VE         = " `Gini_X' - `CONC_N'
dis "HI         = " `Gini_N' - `CONC_N'
restore

//3.3	Estimez l'indice de progressivité de Kakwani par an à l'aide de la commande DASP iprog (astuce : utilisez l’option gobs(year)). 
iprog T B, hsize(hhsize) gobs(year) ginc(X) type(t)

//3.4	À l'aide des observations de 2005, vérifiez la condition de TR progressivité pour la taxe T à l'aide de la commande DASP cprog.
preserve
keep if year==2005
cprog T, rank(X) type(t) appr(tr)
restore
//la part des revenus des 10% les plus pauvres est supérieure à leur part d'impôts.*/

//3.5	Dans quelle province l'inégalité était-elle la plus élevée en 2005 ? Dans quelle province l’indice de progressivité fiscale de Kakwani était-il le plus élevé de 2005 ?
preserve
keep if year==2005
igini X T B N, hsize(hhsize) hgroup(province) rank(X)
//L'inegalite est plus elevee a Alberta
preserve 
keep if year ==2005
iprog T B, hsize(hhsize) gobs(province) ginc(X) type(t)
//l’indice de progressivité fiscale de Kakwani est plus eleve a Manitoba