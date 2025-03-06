*****10,5%
//Code stata pour l'exercice semaines 9_10_11

// Exercice 1*************4%

clear
set obs 6
qui input str10 Individu w_1 w_2 w_3
"Individu 1" 	2	10	6
"Individu 2"	4	6	0
"Individu 3"	8	8	12
"Individu 4" 	6	6	8
"Individu 5"	14	10	4
"Individu 6" 	12	8	6


//  Q1:

/*
Sous l'approche de l'union (the multidimensional union headcount index) : c'est la proportion d'individus avec au
au moins un attribut en dessous du seuil de pauvreté de cet attribut; Sous l'approche de l'intersection ( the multidimensional intersection headcount index): la proportion d'individus dont tous les attributs sont inférieurs aux seuils de pauvreté respectifs des attributs. (Duclos et Tiberti, 2016). Seules les personnes défavorisées dans toutes les dimensions sont considérées comme pauvres. 
*/

gen uhi_poor=0
replace uhi_poor=1 if w_1 <= 7|w_2 <= 7|w_3 <= 7
mean uhi_poor
imdp_uhi w_1 w_2 w_3, pl1(7) pl2(7) pl3(7)

//Q2

gen ihi_poor=1
replace ihi_poor=0 if w_1 >= 7|w_2 >= 7|w_3 >= 7
mean ihi_poor
imdp_ihi w_1 w_2 w_3, pl1(7) pl2(7) pl3(7)


//Q3
/* L'approche de l'union est la plus sensible à l'augmentation des privations multiples individuelles. */ 


//Q4

egen sum_w = rowtotal(w_*)       
gen sum_w3=sum_w/3
gen  af_poor= 1 if sum_w3>= 7 
replace af_poor=0 if sum_w3 < 7
mean af_poor

// Q5
imdp_afi w_1 w_2 w_3 , dcut(2) pl1(7) pl2(7) pl3(7)
imdp_uhi w_1 w_2 w_3, pl1(7) pl2(7) pl3(7)
imdp_ihi w_1 w_2 w_3, pl1(7) pl2(7) pl3(7)


// Q6


//Exercice 2**3,5%


clear
set obs 6
qui input str10 Individu w_1 w_2 w_3
"Individu 1" 	2	10	6
"Individu 2"	4	6	0
"Individu 3"	8	8	12
"Individu 4" 	6	6	8
"Individu 5"	14	10	4
"Individu 6" 	12	8	6


// Q1 

/* βi=1/3 ou βi=0.33 */
gen g1 = (7-w_1)/w_1
gen g2 = (7-w_2)/w_2  
gen g3 = (7-w_3)/w_3 

cap drop pi  // essayez d'abandonner la variable pi
/*gen pi = (βi*g1^1'+βi*g2^`ρ'+βi*g3^`ρ')^(`alpha'/`ρ') // nous générons la variable pi*/

gen pi = (0.33*g1^1+0.33*g2^1+0.33*g3^1)^(1/1)
replace pi=0 if g1==0 & g2==0 & g3==0  
replace pi=0 if pi==. 
qui sum pi 
scalar MDI_BC = r(mean) // Indice Bourguignon et Chakravarty 

dis "The MDI_BC Index =" MDI_BC


// Q2 

imdp_bci w_1 w_2 w_3 , pl1(7) pl2(7) pl3(7) alpha(1) b(0.33) gamma(1) 


// Q3 
gen nw_1 = (w_1+ w_2+w_3)/3 
gen nw_2 = (w_1+ w_2+w_3)/3
gen nw_3 = (w_1+ w_2+w_3)/3
summarize nw_*
imdp_bci nw_1 nw_2 nw_3 , pl1(7) pl2(7) pl3(7) alpha(1) b(0.33) gamma(1)



//Exercice 3****3%

clear
use "Canada_1996_2005_random_sample_2", clear

// Q1
preserve
tab year
keep if year==2005
cnpe T B N, xvar(X) type(dnp) min(1000) max(31000)
restore

//Q2	

preserve
keep if year>=1999
igini X N
local Gini_X=el(e(est),1,1)
local Gini_N=el(e(est),2,1)
igini N, rank(X)
local CONC_N=el(e(est),1,1)
dis "Difference (l’impact redistributif) = " `Gini_X' - `Gini_N'
restore


//Q3

iprog T B N, gobs(year) ginc(X) 

//Q4 : 

/*
L'impôt T est progressif par rapport à la redistribution fiscale (TR) si : 
CPROG (p) = L_X(p) - C_T(p) > 0 pour tout p dans ]0,1[.
En d'autres termes, la condition est que la part des revenus jusqu'à un groupe de p percentile donné (groupe p plus pauvre) 
doit être supérieure à leur part d'impôts. 

L'impôt T est progressif du point de vue de la redistribution des revenus (IR) si : 
CPROG (p) = C_[X-T](p) - L_X(p) > 0 pour tout p dans ]0,1[.
En d'autres termes, la condition est que la part des revenus nets après paiement de l'impôt pour un groupe donné de p-percentiles (p) soit supérieure à 0. 
groupe de p-percentiles (groupe de p-pauvres) doit être supérieure à la part de leurs revenus bruts.
*/

keep if year==2005
cprog T, rank(X) type(t) appr(ir)


// Q5

igini X T B N, rank(X) hgroup(province)
iprog T B N, gobs(province) ginc(X)

/*L'inégalité était la plus élevée en 2005 dans la province de Newfoundland. 
L’indice de progressivité fiscale de Kakwani était le plus élevé en 2005 dans la province de British_Columbia */

