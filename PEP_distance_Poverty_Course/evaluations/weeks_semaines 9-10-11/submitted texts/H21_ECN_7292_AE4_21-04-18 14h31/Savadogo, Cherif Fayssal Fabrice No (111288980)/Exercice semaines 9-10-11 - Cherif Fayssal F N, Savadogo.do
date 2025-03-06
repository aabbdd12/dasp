*************11%

//Exercice 1


clear
set obs 6
qui input str10	individus w1	w2	w3
"ind1" 	2	10	6
"ind2"	4	6	0
"ind3"	8	8	12
"ind4" 	6	6	8
"ind5"	14	10	4
"ind6" 	12	8	6

//1.1) 1.1	En utilisant l'approche de l’union, estimez la proportion d'individus pauvres

//Avec DASP
imdp_uhi w1 w2 w3,  pl1(7) pl2(7) pl3(7)


//1.2) 1.2	En utilisant l'approche par intersection, estimez la proportion d'individus pauvres

// Avec DASP
imdp_ihi w1 w2 w3, pl1(7) pl2(7) pl3(7)


//1.3)


//1.4)	Estimez l’indice Alkire et Foster MPI(α=0) lorsque le seuil dimensionnel est égal à 2 
egen sum_w          =  rowtotal(w*)
gen    af_poor        =  (sum_w>=2)
gen  w_af_poor        =  (sum_w /3)* af_poor
mean af_poor w_af_poor


//1.5) Avec DASP
imdp_afi w1 w2 w3 , dcut(2) w1(3) pl1(7) w2(3) pl2(7) w3(3) pl3(7)







//Exercice 2
clear
set obs 6
qui input str10	individus w1	w2	w3
"ind1" 	2	10	6
"ind2"	4	6	0
"ind3"	8	8	12
"ind4" 	6	6	8
"ind5"	14	10	4
"ind6" 	12	8	6


//2.1) 2.1	Estimez l’indice de pauvreté de Bourguignon et Chakravarty (2003) 


scalar beta1 = 1/3
gen z = 7

gen ngap1 = (z-w1)/z*(z>w1)  
gen ngap2 = (z-w2)/z*(z>w2)
gen ngap3 = (z-w3)/z*(z>w3)



cap drop pi  
gen pi = (beta1*ngap1) + (beta1*ngap2) + (beta1*ngap3) 


if ngap1==0 & ngap2==0 & ngap3==0 pi=0  
qui sum pi  
scalar MDI_BC1 = r(mean) 


//2.2) DASP

dis "The MDI_BC Index (alpha ="%4.2f `alpha' ", epsilon ="%4.2f `p' " ) : " _col(40) %6.4f  MDI_BC1  
dis _n



//2.3) 
// Générons les nouvelles variables
gen nw_1 = (w1+w2+w3)/3
gen nw_2 = (w1+w2+w3)/3
gen nw_3 = (w1+w2+w3)/3

//Calcilons la nouvelle valeur BC

gen ngapnw_1 = (z-nw_1)/z*(z>nw_1)  
gen ngapnw_2 = (z-nw_2)/z*(z>nw_2)
gen ngapnw_3 = (z-nw_3)/z*(z>nw_3)



cap drop pinw  
gen pinw = (beta1*ngapnw_1) + (beta1*ngapnw_2) + (beta1*ngapnw_3) 


if ngapnw_1==0 & ngapnw_2==0 & ngapnw_3==0 pinw=0  
qui sum pinw  
scalar MDI_BC2 = r(mean) 

dis "The MDI_BC Index (alpha ="%4.2f `alpha' ", epsilon ="%4.2f `p' " ) : " _col(40) %6.4f  MDI_BC2  
dis _n





//Exercice 3
clear 
use "Canada_Incomes&Taxes_1996_2005_random_sample_2.dta"


//3.1) estimez l’espérance des taux marginaux d'impôts
 preserve
 keep if year==2005
 cnpe T B N, xvar(X) min(1000) max(31000)
 restore
 
 
 //3.2) Indice de Gini
preserve
keep if year==1999 | year==2002 | year==2005 
igini X N
local Gini_X=el(e(est),1,1)
local Gini_N=el(e(est),2,1)
igini N, rank(X)
local CONC_N=el(e(est),1,1)
dis "Difference = " `Gini_X' - `Gini_N'
dis "VE = " `Gini_X' - `CONC_N'
dis "HI = " `Gini_N' - `CONC_N' 
restore


 
 //3.3)	Estimez l'indice de progressivité de Kakwani par an à l'aide de la commande DASP iprog 

iprog T B N, ginc(X) gobs(year) type(t) index(ka)
  
 
 //3.4)	À l'aide des observations de 2005, vérifiez la condition de TR progressivité pour la taxe T à l'aide de la commande DASP cprog
 preserve
 keep if year==2005 
 cprog T, rank(X) type(t) appr(ir)
 restore
 
 //3.5	Dans quelle province l'inégalité était-elle la plus élevée en 2005 ?
 preserve
 keep if year==2005 
 igini X, hgroup(province)  
 restore

