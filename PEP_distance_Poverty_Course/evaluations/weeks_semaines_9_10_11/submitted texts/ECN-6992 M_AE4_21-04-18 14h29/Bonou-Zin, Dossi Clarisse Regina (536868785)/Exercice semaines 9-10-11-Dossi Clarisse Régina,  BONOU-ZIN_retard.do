*******12,5%

////Assignement_9_10_11

// Code stata exercice 1********4,5%
clear
/*Introduction des données*/

input individu	w_1	w_2	w_3
		1		2	10	6
		2		4	6	0
		3		8	8	12
		4		6	6	8
		5		14	10	4
		6		12	8	6
end


/*Q1: Etimation de la proportion d'individus pauvre selon l'approche de l'union*/


/*Selon l'approche de l'union, un individu est considéré comme pauvre s'il est pauvre dans au moins 1 dimension
 */
*********Selon l'apprcohe de l'union avec stata*******

****Construction de trois indicateurs poor_w1 poor_w2 et poor_w3 en utilisant le seuil de pauvreté pour chacune des dimentions. Ces variables permettent d'estimer la proportion de pauvre pour chaque dimension*******

gen poor_w1 = (w_1 < 7)
gen poor_w2 = (w_2 < 7)
gen poor_w3 = (w_3 < 7)

list w_1 w_2 w_3 poor_w1 poor_w2 poor_w3

/*Nous avons générer la variable sum_poor qui est le nombre de dimension dans lequel un individus est pauvre.
 La variable poor_union est générer et prend la valeur 1 si un individu est pauvre dans au moins une dimension*/

egen sum_poor = rowtotal(poor_*)

gen poor_union = (sum_poor>=1)
mean poor_union

*************Approche union avec dasp****

imdp_uhi w_1 w_2 w_3, pl1(7) pl2(7) pl3(7) alpha(0)

/*Q2: Etimation de la proportion d'individus pauvre selon l'approche de l'intersection*/

**********Selon l'approche de l'intersection, un individu est pauvre s'il est pauvre dans toutes les dimension. Nous alors générer la variable poor_inter qui prend la valeur 1 si l’individu est pauvre dans les trois dimension et 0 si non

 ***************Approche de l'intersection avec stata********
 gen poor_int = (sum_poor>=3)
mean poor_int

**** Approche de l'intersection avec dasp********

imdp_ihi w_1 w_2 w_3, pl1(7) pl2(7) pl3(7) alpha(0)

/*Q4: Estimation de l'indice Alkire et Foster MPI*/

**********Avec stata*********

****Générer af_poor = 1 l'individu est pauvre dans 2 ou 3 dimension et 0 sinon et la variable mpi qui est la Proportion de pauvre pondérées par les dimensions avec privation****
gen af_poor = (sum_poor>=2)

mean af_poor

gen mpi = (sum_poor/3)*af_poor

mean mpi

**********Estimation de mdpi avec dasp*************
imdp_afi w_1 w_2 w_3, dcut(2) w1(1) pl1(7) w2(1) pl2(7) w3(1) pl3(7)







///Code stat exercice 2*********4%

/*Q1: Estimation de l'indice de pauvreté de Bourguignon et chakravaty, (2003)*/

********Estimation de l'écart de pauvreté des trois dimension*******
scalar zi = 7

scalar alpha = 1
scalar rho = 1
scalar beta_i = 1/3


gen ngap_w1 = (zi-w_1)/zi*(zi>w_1)
gen ngap_w2 = (zi-w_2)/zi*(zi>w_2)
gen ngap_w3 = (zi-w_3)/zi*(zi>w_3)
 

****Générer la variable pi*******
/* pi = (beta_i*ngap_w1^`rho' + (beta_i)*ngap_w2^`rho' + (beta_i)*ngap_w3^`rho')^(`alpha/rho')
or rho=1 et alpha=1 donc pi devient alors pi= betai*ngap_w1 + beta_i*ngap_w2 + beta_i*ngap_w3*/
cap drop pi

gen pi = beta_i*ngap_w1 + beta_i*ngap_w2 + beta_i*ngap_w3


*****Remplaçons la valeur de pi par 0 si les écarts dans les dimention 1, 2 et 3 sont nuls*****

if ngap_w1==0 & ngap_w2==0 & ngap_w3==0 replace pi=0

qui sum pi
scalar MDI_BC = r(mean) // Indice Bourguignon et Chakravarty 

dis MDI_BC

/* Q2: Indice avec dasp*/

imdp_bci w_1 w_2 w_3, alpha(1) beta(0.3) gamma(1) pl1(7) pl2(7) pl3(7) 

************Toutefois Il faut noter que l'indice BC est bidimentionnel, Donc nous estimons pour les dimentions 2 à 2********

imdp_bci w_1 w_2, alpha(1) beta(0.3) gamma(1) pl1(7) pl2(7)

imdp_bci w_1 w_3, alpha(1) beta(0.3) gamma(1) pl1(7) pl2(7)

imdp_bci w_2 w_3, alpha(1) beta(0.3) gamma(1) pl1(7) pl2(7)


/* Q3: Générer trois nouvelles variables et estimation de l'indice BC*/

******Création ges variable nw_1; nw_2 et nw_3******
gen nw_1 = (w_1 + w_2 + w_3 )/3
gen nw_2 = nw_1
gen nw_3 = nw_1

list nw_1 nw_2 nw_3

*********Nouvel indice BC*******

imdp_bci nw_1 nw_2 nw_3, alpha(1) beta(0.3) gamma(1) pl1(7) pl2(7)  pl3(7) 

imdp_bci nw_1 nw_2, alpha(1) beta(0.3) gamma(1) pl1(7) pl2(7) 

imdp_bci nw_1 nw_3, alpha(1) beta(0.3) gamma(1) pl1(7) pl2(7)

imdp_bci nw_2 nw_3, alpha(1) beta(0.3) gamma(1) pl1(7) pl2(7)



////Code stata exercice 3*********4%

clear 
use "C:\Users\asus\Desktop\DC\Pauvreté\Exercice 4\Canada_Income&taxes_1996_2005_random_sample_2.dta" 


/*Q1: Estimation de l'expérance des taux marginaux d'impot de bénéfices et de revenu nets**************/

cnpe X T B N, xvar(X) min(1000) max(31000) hsize(hhsize) type(dnp) vgen(yes)


/*Q2: Estimer l'impact redictributive sur l'indice de Gini*/


preserve

keep if year==1999
igini X T B N, rank(X)
clorenz X T B, rank(X)
restore

preserve

keep if year==2002
igini X T B N, rank(X)
clorenz X T B, rank(X)
restore

preserve

keep if year==2005
igini X T B N, rank(X)
clorenz X T B, rank(X)
restore


/*Q4: Vérification de la condition de TR progressivité pour la taxe*/
******La taxe T est dit TRprogressif si : CPROG (p) = L_X(p) - C_T(p) > 0 pour tout p dans ]0,1[.

preserve
keep if year==2005
cprog T, rank(X) hsize(hhsize) type(t) appr(tr)
restore

/*Q5: Province dans laquelle l'inégalité est la plus élevé***/

preserve
keep if year==2005
 igini X, hsize(hhsize) hgroup(province)
restore



















