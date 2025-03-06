**********12,5%

//code stata pour l'exercice des semaines 9-10-11
// Exercice 1
* insertion des données
clear 
input 	   w1	w2	w3
Individu1 	2	10	6
Individu2	4	6	0
Individu3	8	8	12
Individu4 	6	6	8
Individu5	14	10	4
Individu6 	12	8	6
end

//Q1.1
* commande stata
list
egen sum_dep  = rowtotal (w*)
gen  aver_dep = sum_dep*(sum_dep>=7) / (6*3)
table individu , content (sum  aver_dep)

* Commande DASP
imdp_uhi w1 w2 w3, pl1(7) pl2(7) pl3(7)

// Q1.2
*a.Commande Stata
egen sum_del = rowtotal(w*)
gen af_poor = (sum_del>=7)
gen w_af_poor1 = (sum_del /6)* af_poor

*b.Commande DASP
imdp_ihi w1 w2 w3, pl1(7) pl2(7) pl3(7)

// Q1.3
Voir document word

// Q1.4
imdp_afi w1 w2 w3, dcut(2) w1(7) pl1(7) w2(7) pl2(7) w3(7) pl3(7)

// Q1.5
imdp_afi w1 w2 w3, dcut(2) w1(7) pl1(7) w2(7) pl2(7) w3(7) pl3(7)
// Q1.6
dmdafs w1 w2 w3, dcut(2) w1(7) pl1(7) w2(7) pl2(7) w3(7) pl3(7)

//exercice 2

// Q2.1
scalar beta1 = 0.33333
forvalues alpha = 0 {
rho = 1
z* = 7
cap drop ngap*
gen ngap1 = (z1-x1)/z1*(z1>x1)
gen ngap2 = (z2-x2)/z2*(z2>x2)
gen ngap3 = (z3-x3)/z3*(z3>x3)
cap drop pi
gen pi = (beta1*ngap1^`rho' + (1-beta1)*ngap2^`rho'+ (1-beta1)*ngap3^`rho')^(`alpha'/`rho')
if ngap1==0 & ngap2==0 & ngap3==3 replace pi=0
qui sum pi in 1/2 
scalar MDI_BC1 = r(mean)

qui sum pi in 3/4 
scalar MDI_BC2 = r(mean)

dis "The MDI_BC Index (alpha ="%4.2f `alpha' ", rho ="%4.2f `rho' " ) : "  "CASE 1 = " _col(40) %6.4f  MDI_BC1  " ||  CASE 2 =" _col(40) %6.4f  MDI_BC2 ||  CASE 3 =" _col(40) %6.4f  MDI_BC3 
}
}
// Q2.2
imdp_bci w1 w2 w3, alpha(0) gamma(1) b1(0.3333) pl1(7) b2(0.3333) pl2(7)
>  b3(0.3333) pl3(7) 
// Q2.3
gen nw_1 = (w1+ w2+w3)/3
gen nw_2 = (w1+ w2+w3)/3
gen nw_3 = (w1+ w2+w3)/3

 imdp_bci nw_1 nw_2 nw_3, alpha(1) gamma(1) b1(0.3333) pl1(7) b2(0.3333) pl
> 2(7) b3(0.3333) pl3(7) 

// Exercice 3
*Importation des données
use use "C:\Users\MARIAM\Downloads\Canada_Incomes&Taxes_1996_2005_random_sample_3.dta"

// Q3.1
cnpe T B N, xvar(X) type(dnp) min(1000) max(31000) if year==2005

// Q3.2
igini X N if year ==1999
igini X N if year ==2002
igini X N if year ==2005

// Q3.3
 iprog T, ginc(X) type(t) index(ka) gobs(year)
 
// Q3.4
cprog T, rank(X) type(t) appr(tr) if year ==2005


// Q3.5
a. igini X N, hgroup(province) if year==2005
b. cprog T, rank(X) hgroup(province) type(t) appr(tr) if year ==2005

