******9,5%

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
******                                                     EXERCICE 1****1%
***************************************************************************************************************************************************************


*** 1.1	En utilisant l'approche de l’union, estimez la proportion d'individus pauvres. Refaites l'estimation à l'aide de la commande DASP appropriée:

clear
input w1 w2 w3
 4 20 12
 8 12 0
 16 16 24
 12 12 16
 28 20 8
 24 16 12
end
 
gen pline = 14 
gen pgap1 = 0
gen pgap2 = 0
gen pgap3 = 0
replace pgap1 = (pline-w1)/pline if (w1 < pline)
replace pgap2 = (pline-w2)/pline if (w2 < pline)
replace pgap3 = (pline-w3)/pline if (w3 < pline)
gen poorp1=0
gen poorp2=0
gen poorp3=0
 replace poorp1= 1 if (pgap1 != 0)
 replace poorp2= 1 if (pgap2 != 0)
 replace poorp3= 1 if (pgap3 != 0)
 list
 gen poor_un=0
 replace poor_un=1 if (poorp1 ==1 | poorp2 ==1 | poorp3 ==1)
sum poor_un


*** avec la commande DASP
imdp_uhi w1 w2 w3 , pl1(14) pl2(14) pl3(14) //union

*** 1.2 En utilisant l'approche par intersection, estimez la proportion d'individus pauvres. Refaites l'estimation à l'aide de la commande DASP appropriée. 

gen poor_int=0
 replace poor_int=1 if (poorp1 ==1 & poorp2 ==1 & poorp3 ==1)
sum poor_int

*** avec la commande DASP
imdp_ihi w1 w2 w3 , pl1(14) pl2(14) pl3(14)


*** 1.4	Estimez l’indice Alkire et Foster MPI(α=0) lorsque le seuil dimensionnel est égal à 2 (les pauvres sont ceux qui ont deux ou trois dimensions de privation).


clear
set obs 6
qui input str10 individu del_1 del_2 del_3
 "individu1" 1 0 1
 "individu2" 1 1 1
 "individu3" 0 0 0
 "individu4" 1 1 0
 "individu5" 0 0 1
 "individu6" 0 0 1
egen sum_del = rowtotal(del_*) 
gen af_poor = (sum_del>=2)
gen w_af_poor = (sum_del /3)* af_poor

/* Alkire et Foster H0 et M0 */
rename (af_poor w_af_poor) (H0 M0)
mean H0 M0

mean af_poor w_af_poor if individu=="individu1"
mean af_poor w_af_poor if individu=="individu2"
mean af_poor w_af_poor if individu=="individu3"
mean af_poor w_af_poor if individu=="individu4"
mean af_poor w_af_poor if individu=="individu5"
mean af_poor w_af_poor if individu=="individu6"

table individu , content (sum  w_af_poor)

*** question 4
clear
input w1 w2 w3
4 20 12
8 12 0
16 16 24
12 12 16
28 20 8
24 16 12
end
imdp_afi w1 w2 w3 , dcut(2) pl1(1) pl2(1) pl3(1)

**** question 5

gen transf=24/6
gen w1post=w1+transf
gen w2post=w2+transf
gen w3post=w3+transf

imdp_uhi w1post w2 w3 , pl1(14) pl2(14) pl3(14) //union
imdp_ihi w1post w2 w3 , pl1(14) pl2(14) pl3(14) //inter

imdp_uhi w2post w1 w3 , pl1(14) pl2(14) pl3(14) //union
imdp_ihi w2post w1 w3 , pl1(14) pl2(14) pl3(14) //inter

imdp_uhi w3post w2 w1 , pl1(14) pl2(14) pl3(14) //union
imdp_ihi w3post w2 w1 , pl1(14) pl2(14) pl3(14) //inter

imdp_uhi w3 w2 w1 , pl1(14) pl2(14) pl3(14) //union
imdp_ihi w3 w2 w1 , pl1(14) pl2(14) pl3(14) //inter



***************************************************************************************************************************************************************
******                                                     EXERCICE 2  3%
***************************************************************************************************************************************************************

*** 	Estimez l’indice de pauvreté de Bourguignon et Chakravarty (2003) lorsque β_i=1/3  ∀ i,〖 z〗_i=14 ∀ i,   α=1 et ϵ=1. 

clear
input w1 w2 w3
 4 20 12
 8 12 0
 16 16 24
 12 12 16
 28 20 8
 24 16 12
end

gen beta1=0.33
 gen z=14
 gen alpha=1
 gen rho=1
gen ngap1 = (z-w1)/z*(z>w1)
gen ngap2 = (z-w2)/z*(z>w2)
gen ngap3 = (z-w3)/z*(z>w3)
gen pi =(beta1*ngap1 + beta1*ngap2 + beta1*ngap3)
if ngap1==0 & ngap2==0 & ngap3==0 replace pi=0
sum pi  
scalar MDI_BC = r(mean)
display MDI_BC

*** 2.2	Refaites l'estimation à l'aide de la commande DASP appropriée.

imdp_bci w1 w2 w3,pl1(14)pl2(14)pl3(14)alpha(1)beta(0.33)

*** 2.3

gen new_1= (w1 + w2 + w3)/3
gen bes1=max(0,new_1 - w1)
gen bes2=max(0,new_1 - w2)
gen bes3=max(0,new_1 - w3)

gen tras1=max(0,w1 - new_1)
gen tras2=max(0,w2 - new_1)
gen tras3=max(0,w3 - new_1)

replace w1= w1 + bes1 - tras1
replace w2= w2 + bes2 - tras2
replace w3= w3 + bes3 - tras3

imdp_bci w1 w2 w3 , pl1(14) pl2(14) pl3(14) alpha(1) beta(0.33)


***************************************************************************************************************************************************************
******                                                     EXERCICE 3*****3,5%
***************************************************************************************************************************************************************

use "Canada_Incomes&Taxes_1996_2005_random_sample_3.dta", clear

*** 3.1	A l'aide des observations de 2005, estimez l’espérance des taux marginaux d'impôts, de bénéfices et de revenus nets pour la plage de revenus bruts comprise entre 1 000 et 31 000 $ (astuces : utilisez la commande DASP cnpe avec l'option : type(dnp)).  

preserve
keep if year==2005
cnpe T B N, xvar(X) hsize(hhsize) min(1000) max(31000) 
restore


*** 3.2	Estimez l’impact redistributif sur l’indice d’inégalité de Gini pour 1999, 2002 et 2005 (astuce : utilisez les commandes Stata preserve/restore conserver les données après avoir utilisé la commande Stata “keep if year==…”). 

preserve
keep if year==1999
igini X T B N , rank(X)
restore

preserve
keep if year==2002
igini X T B N , rank(X)
restore

preserve
keep if year==2005
igini X T B N , rank(X)
restore

*** 3.3	Estimez l'indice de progressivité de Kakwani par an à l'aide de la commande DASP iprog (astuce : utilisez l’option gobs(year)). 

iprog T, ginc(X) gobs(year)


*** 3.4	À l'aide des observations de 2005, vérifiez la condition de TR progressivité pour la taxe T à l'aide de la commande DASP cprog.

cprogbt T, rank(X) appr(tr)
cprog T, rank(X) type(t) appr(tr)

*** 3.5	Dans quelle province l'inégalité était-elle la plus élevée en 2005 ? Dans quelle province l’indice de progressivité fiscale de Kakwani était-il le plus élevé de 2005 ?

preserve
keep if year==2005
igini X T B N , rank(X) hgroup(province)
restore 

preserve
keep if year==2005
cprog T, rank(X) type(t)  hgroup(province) appr(tr)
restore 
