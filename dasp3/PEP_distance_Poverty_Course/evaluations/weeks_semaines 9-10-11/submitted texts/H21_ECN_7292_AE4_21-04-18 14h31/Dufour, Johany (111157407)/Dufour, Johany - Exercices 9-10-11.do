*************11,5%

****************************************************************
********** Dufour, Johany - Exercices 9-10-11 *************

********** Exercice 1 ****************** 
clear
set more off 

** Question 1.1 ** 
*Ajoutons les données. 
input id w1 w2 w3
1 1 5 3 
2 2 3 0
3 4 4 6
4 3 3 4
5 7 5 4
6 6 4 3 
end

*Une personne est pauvre selon l'approche de l'union si elle est pauvre dans au moins une dimension du bien-être 

gen w1_p =0
replace w1_p =1 if w1 < 3.5
gen w2_p =0
replace w2_p =1 if w2 < 3.5
gen w3_p =0
replace w3_p =1 if w3 < 3.5
gen score_p = w1_p + w2_p + w3_p 
gen union=0 
replace union=1 if score_p >=1

mean(union)
** La proportion d'individus pauvres selon l'approche de l'union est 0.6667 (66.67%)

** Commande DASP pour le taux de pauvreté avec l'approche de l'union : 
imdp_uhi w1 w2 w3, pl1(3.5) pl2(3.5) pl3(3.5)
** J'obtiens la même réponse, soit que le taux de pauvreté est de 0.667. 

** Question 1.2 
** Une personne est pauvre selon l'approche de l'intersection si elle est pauvre dans toutes les dimensions du bien-être. Il y en a dans cet exercice 3, donc une personne est pauvre lorsque score=3. 
gen inter=0
replace inter=1 if score_p==3 
mean(inter)

** Il y a un seul individu qui est pauvre dans les trois dimensions, alors le taux de pauvreté est 0.1667 (1/6) ou 16.67%. 
** Commande DASP pour le taux de pauvreté avec l'approche de l'intersection : 
imdp_ihi w1 w2 w3, pl1(3.5) pl2(3.5) pl3(3.5)

** J'obtiens la même réponse, soit que le taux de pauvreté est de 0.167. 

** Question 1.3 

** Réponse dans le document Word

** Question 1.4 
* L'indice AF avec alpha =0 est le taux de pauvreté (headcount ration). Un individu est pauvre s'il possède des privations dans 2 ou 3 dimensions du bien-être. Alors, un individu est pauvre si score_p >= 2. 

gen paf=0
replace paf=1 if score_p >=2
mean(paf)

** J'obtiens que 50% de l'échantillon est pauvre selon ces critères, soit un taux de pauvreté de 0,50 avec un écart-type de 0.223. 

** Question 1.5 
** J'utilise la commande DASP suivante et j'obtiens le même résultat, soit que 50% des individus possèdent des privations dans 2 ou 3 dimensions de la pauvreté. 

imdp_afi w1 w2 w3, dcut(2) w1(1) pl1(3.5) w2(1) pl2(3.5) w3(1) pl3(3.5)


** Question 1.6 

**Si le transfert est donné à la dimension 1, aucun changement dans l'indice d'union ou d'intersection 
replace w1=w1+1
replace w1_p=0 if w1>3.5
gen score_p1 = w1_p + w2_p + w3_p 
gen union1=0 
replace union1=1 if score_p1 >=1
mean(union1)
gen inter1=0
replace inter1=1 if score_p1==3 
mean(inter1)

**Si le transfert est donné à la dimension 2, l'indice d'union est inchangé et l'indice d'intersection est réduit à 0, puisque l'individu 2 devient pauvre dans seulement 2 dimensions et non 3. 
replace w1=w1-1
replace w1_p=1 if w1<3.5
replace w2=w2+1
replace w2_p=0 if w2>3.5
gen score_p2 = w1_p + w2_p + w3_p 
gen union2=0 
replace union2=1 if score_p2 >=1
mean(union2)
gen inter2=0
replace inter2=1 if score_p2==3 
mean(inter2)

**Si le transfert est donné à la dimension 3, l'indice d'union est devient 0.50 (3/6) et l'indice d'intersection est inchangé, puisqu'un individu est toujours pauvre dans toutes les dimensions. 
replace w2=w2-1
replace w2_p=1 if w2<3.5
replace w3=w3+1
replace w3_p=0 if w3>3.5
gen score_p3 = w1_p + w2_p + w3_p 
gen union3=0 
replace union3=1 if score_p3 >=1
mean(union3)
gen inter3=0
replace inter3=1 if score_p3==3 
mean(inter3)

** Avant le transfert : Avec l’approche de l’union, on obtient un taux de 0.667 (4/6), avec l’approche de l’intersection, on obtient un taux de 0.167 (1/6). 

********** Exercice 2 ****************** 
clear
set more off 

** Question 2.1 ** 
input id w1 w2 w3
1 1 5 3 
2 2 3 0
3 4 4 6
4 3 3 4
5 7 5 4
6 6 4 3 
end

* D'abord, l'écart de pauvreté dans chacune des dimensions, g_h,i

gen ngap1 = (3.5-w1)/3.5*(3.5>w1) // notez que (3.5>x1)=1 si z1>x1 et zéro sinon.
gen ngap2 = (3.5-w2)/3.5*(3.5>w2) // l'écart de pauvreté de dimension 2 : rappelons que (z2>x2)=1 si z1>x1 et zéro sinon.
gen ngap3 = (3.5-w3)/3.5*(3.5>w3)

*Ensuite, les contributions individuelles à la pauvreté totale
gen pi = ((1/3)*ngap1^1 + (1/3)*ngap2^1 + (1/3)*ngap3^1)^(1) 
if ngap1==0 & ngap2==0 & ngap3==0 replace pi=0 /
qui sum pi in 1/6
scalar indice_BC = r(mean)
display indice_BC

** Question 2.2 ** 
** Avec la commande DASP : 
imdp_bci w1 w2 w3, alpha(1) gamma(1) b1(0.33) pl1(3.5) b2(0.33) pl2(3.5) b3(0.33) pl3(3.5)

*J'obtiens comme résultat  0.157

** Question 2.3 ** 

*D'abord, on génère les nouvelles variables de dimensions de bien-être
gen nw_1 = (w1 + w2 + w3)/3
gen nw_2 = nw_1
gen nw_3 = nw_1

*Ensuite, on calcule l'indice BC avec DASP 
imdp_bci nw_1 nw_2 nw_3, alpha(1) gamma(1) b1(0.33) pl1(3.5) b2(0.33) pl2(3.5) b3(0.33) pl3(3.5)



********** Exercice 3 ****************** 
clear
set more off 

** Utilisons le fichier de données 
use "D:\Téléchargement Chrome\Canada_Incomes&Taxes_1996_2005_random_sample_1.dta", clear
svyset [pweight=sweight]

** Question 3.1 ** 
**Commande DASP 
preserve
keep if year==2005 
cnpe T B N, xvar(X) hsize(hhsize) min(1000) max(31000) type(dnp) ytitle(Espérance des taux marginaux) xtitle(Revenus bruts (X))
restore 

** Question 3.2 ** 
preserve
keep if year==1999 
igini X N
local Gini_X=el(e(est),1,1)
local Gini_N=el(e(est),2,1)
igini N, rank(X)
local CONC_N=el(e(est),1,1)
dis "Difference = " `Gini_X' - `Gini_N'
dis "VE = " `Gini_X' - `CONC_N'
dis "HI = " `Gini_N' - `CONC_N'
restore, preserve 
** Résultats : Difference = .14514935  VE = .17302138  HI = .02787203

preserve
keep if year==2002
igini X N
local Gini_X=el(e(est),1,1)
local Gini_N=el(e(est),2,1)
igini N, rank(X)
local CONC_N=el(e(est),1,1)
dis "Difference = " `Gini_X' - `Gini_N'
dis "VE = " `Gini_X' - `CONC_N'
dis "HI = " `Gini_N' - `CONC_N'
restore 
** Résultats : Difference = .13784307  VE = .16543868  HI = .02759561

preserve
keep if year==2005
igini X N
local Gini_X=el(e(est),1,1)
local Gini_N=el(e(est),2,1)
igini N, rank(X)
local CONC_N=el(e(est),1,1)
dis "Difference = " `Gini_X' - `Gini_N'
dis "VE = " `Gini_X' - `CONC_N'
dis "HI = " `Gini_N' - `CONC_N'
restore 
** Résultats : Difference = .13497144  VE = .15726858  HI = .02229714


** Question 3.3 ** 

**Commande DASP 
iprog T, ginc(X) hsize(hhsize) gobs(year) type(t) index(ka)

** Question 3.4 ** 

**Selon le corrigé des exercices pratique de la semaine 10, 
/*
L'impôt T est progressif par rapport à la redistribution fiscale (TR) si :
CPROG (p) = L_X(p) - C_T(p) > 0 pour tout p dans ]0,1[.
En d'autres termes, la condition est que la part des revenus jusqu'à un groupe de p percentile donné (groupe p plus pauvre)
doit être supérieure à leur part d'impôts. 
*/
**Commande DASP 

keep if year==2005
cprog T, rank(X) hsize(hhsize) type(t) appr(tr)

** Question 3.5 ** 

igini X, hsize(hhsize) hgroup(province)
iprog T, ginc(X) hsize(hhsize) gobs(province) type(t) index(ka)



********** Fin du travail **************** 

*** Merci pour votre travail durant cette session !! *** 
