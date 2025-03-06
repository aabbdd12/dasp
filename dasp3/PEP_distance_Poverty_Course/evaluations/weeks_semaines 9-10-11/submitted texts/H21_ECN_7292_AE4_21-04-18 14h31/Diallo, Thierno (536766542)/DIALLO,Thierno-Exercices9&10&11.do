**********8,5%

// Utilisation des derniers fichiers DASP mis à jour

set more off
net from http://dasp.ecn.ulaval.ca/modules/DASP_V2.3/dasp
net install dasp_p1, force
net install dasp_p2, force
net install dasp_p3, force
net install dasp_p4, force
addDMenu profile.do _daspmenu 
 
***************************** EXERCICE 1*****1%
clear
input w1 w2 w3
 4 20 12
 8 12 0 
 16 16 24
 12 12 16
 28 20 8
 24 16 12
end
//// QUESTION 1.1

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
// via DASP
imdp_afi w1 w2 w3 , pl1(14) pl2(14) pl3(14)

///// QUESTION 1.2
// proportion de pauvre par l'approche d'intersection
gen poor_int=0
 replace poor_int=1 if (poorp1 ==1 & poorp2 ==1 & poorp3 ==1)
sum poor_int
// via DASP
imdp_afi w1 w2 w3 , pl1(14) pl2(14) pl3(14)

///// QUESTION 1.4
clear all
set obs 6
qui input str10 individu del_1 del_2 del_3
 "individu1" 1 0 1
 "individu2" 1 1 1
 "individu3" 0 0 0
 "individu4" 1 1 0
 "individu5" 0 0 0
 "individu6" 0 0 1
egen sum_del = rowtotal(del_*)
gen af_poor = (sum_del>=2)
gen w_af_poor = (sum_del /3)* af_poor

table individu , content (sum  w_af_poor)



****************************** EXERCICE 2****3%



///// QUESTION 2.1
clear all
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

////// QUESTION 2.2
imdp_bci w1 w2 w3 , pl1(14) pl2(14) pl3(14) alpha(1) beta(0.33)


////// QUESTION 2.3
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



***************************** EXERCICE 3*********3%


clear
use "Canada_Incomes&Taxes_1996_2005_random_sample_3.dta", clear

///// QUESTION 3.1
preserve
keep if year==2005
cnpe T B N, xvar(X) hsize(hhsize) min(1000) max(31000) 
restore

///// QUESTION 3.2
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

///// QUESTION 3.3
iprog T, ginc(X) gobs(year)

////// QUESTION 3.4
cprog T, rank(X) type(t) appr(tr)

////// QUESTION 3.5
preserve
keep if year==2005
igini X T B N , rank(X) hgroup(province)
restore 

preserve
keep if year==2005
cprog T, rank(X) type(t)  hgroup(province) appr(tr)
restore 
