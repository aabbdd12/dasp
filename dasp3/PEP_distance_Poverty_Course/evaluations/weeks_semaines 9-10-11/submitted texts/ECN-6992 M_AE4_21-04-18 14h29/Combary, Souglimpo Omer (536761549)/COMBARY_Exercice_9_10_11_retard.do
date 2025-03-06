*********12%

version 16.1 
capture clear
capture log close
log using "C:\Evaluation_4\COMBARY_Resultats_9_10_11.log", replace
set more off

//*EXERCICE PRATIQUE 1*//

/*Supposons que la population est composée de six individus. Les niveaux de chacune des trois dimensions du bien-être sont rapportés dans le tableau ci-dessous.*/

clear
input individu W1 W2 W3 
1	1	5	3
2	2	3	0
3	4	4	6
4	3	3	4
5	7	5	4
6	6	4	3
end 

/*Supposons que le seuil de pauvreté pour chacune des trois dimensions soit de 3.5. Effectuer les calculs suivants avec Stata.*/

/*1.1 En utilisant l'approche de l’union, estimez la proportion d'individus pauvres. Refaites l'estimation à l'aide de la commande DASP appropriée.*/
 
/*Réponse : selon l'approche de l'union, les pauvres sont ceux qui ont au moins une dimension de privation de bien être par rapport au seuil de pauvreté. 
Le tableau indique que les individus 1, 2, 4 et 6 ont au moins une dimension de privation de bien être par rapport au seuil de pauvreté (3.5). Par conséquent, 
le taux de pauvreté peut être estimé à 4/6, soit 0,6666 */     

/*vérification du résultat avec la commande DASP*/
imdp_uhi W1 W2 W3, pl1(3.5) pl2(3.5) pl3(3.5)

/*1.2 En utilisant l'approche par intersection, estimez la proportion d'individus pauvres. Refaites l'estimation à l'aide de la commande DASP appropriée.*/

/*Réponse : selon l'approche par intersection, les pauvres sont ceux qui ont des privations sur toutes dimensions de bien être par rapport au seuil de pauvreté. 
Le tableau indique que seul l'individu 2 a des privations sur toutes dimensions de bien être par rapport au seuil de pauvreté (3.5). Par conséquent, le taux de 
pauvreté peut être estimé à 1/6, soit 0,1666 */ 

/*vérification du résultat avec la commande DASP*/
imdp_ihi W1 W2 W3, pl1(3.5) pl2(3.5) pl3(3.5)

/*1.3 Quelle approche est la plus sensible à l'augmentation des privations multiples individuelles ? */

/*Réponse : L'approche de l'union est la plus sensible parce que plus il y a de privation sur des dimensions de bien entre par rapport au seuil de pauvreté, plus 
le taux de pauvreté est élevé.*/

/*1.4 Estimez l’indice Alkire et Foster MPI(α=0) lorsque le seuil dimensionnel est égal à 2 (les pauvres sont ceux qui ont deux ou trois dimensions de privation).*/

/*1.5 Estimez maintenant les mêmes indices à l'aide de la commande DASP appropriée. Discutez des résultats.*/

imdp_afi W1 W2 W3, dcut(2) w1(1) pl1(3.5) w2(1) pl2(3.5) w3(1) pl3(3.5)
/*Réponse : La commande ci-dessus DASP permet de calculer l’indice de pauvreté multidimensionnelle d’Alkire et Foster MPI (α=0)  qui est estimé à 0,389 (les détails sont dans le fichier de résultats). Ce qui signifie que la pauvreté touche 38,9% des individus. Les résultats indiquent que par rapport aux dimensions 2 (28,57%) et 3 (28,57%), la dimension 1 (42,86%) contribue le plus à la pauvreté multidimensionnelle.*/

/*1.6 Supposons que le gouvernement dispose de 6 $ et puisse cibler une dimension à l’aide d’un transfert universel. Quelle dimension ciblée réduirait le plus l'indice d'union et l'indice d'intersection ? Discutez de vos résultats.*/   

save "C:\Evaluation_4\COMBARY_Data_0.dta", replace  

//*EXERCICE PRATIQUE 2*//

/*Dans le cas de la dimension tridimensionnelle du bien-être, l'indice de pauvreté de Bourguignon et Chakravarty (2003) (l’indice BC) est défini comme suit :
Avec les données de l’exercice 1,*/ 

/*2.1 Estimez l’indice de pauvreté de Bourguignon et Chakravarty (2003) lorsque β_i=1/3  ∀ i, z_i=3.5 ∀ i,   α=1 et ρ=1.*/  

clear
set obs 6
qui input individu W1 Z1 W2 Z2 W3 Z3
1	1	3.5	5	3.5	3	3.5
2	2	3.5	3	3.5	0	3.5
3	4	3.5	4	3.5	6	3.5
4	3	3.5	3	3.5	4	3.5
5	7	3.5	5	3.5	4	3.5
6	6	3.5	4	3.5	3	3.5

scalar beta1=0.33
scalar beta2=0.33
scalar beta3=0.33
scalar alpha=1
scalar rho=1 

gen ngap1=(Z1-W1)/Z1*(Z1>W1)
gen ngap2=(Z2-W2)/Z2*(Z2>W2)
gen ngap3=(Z3-W3)/Z3*(Z3>W3)

gen pi=(beta1*ngap1^rho+beta2*ngap2^rho+beta3*ngap3^rho)^alpha/rho 

qui sum pi in 1/6
scalar MDP_BC=r(mean)
gen MDP_BC=r(mean)

/*l’indice de pauvreté multidimensionnel de Bourguignon et Chakravarty (2003) est de 0,15714286*/

/*2.2 Reprise de l'estimation de l’indice de pauvreté multidimensionnel de Bourguignon et Chakravarty à l'aide de la commande DASP appropriée.*/

imdp_bci W1 W2 W3, alpha(1) gamma(1) b1(0.33) pl1(3.5) b2(0.33) pl2(3.5) b3(0.33) pl3(3.5)

/*l’indice de pauvreté multidimensionnel de Bourguignon et Chakravarty (2003) est de 0,157*/

/*2.3 Générez trois nouvelles variables (nw_ *) dans lesquelles les individus égalisent leurs dimensions de bien-être (exemple : gen nw_1 = (w_1+ w_2+w_3)/3) 
(c'est-à-dire, par exemple, l'individu 1 a 1, 5, 3 dans les trois dimensions respectivement. Après l’égalisation, nous aurons : 3, 3, 3.). Ensuite, en utilisant 
DASP, réestimez l’indice BC avec les nouveaux vecteurs du bien-être. Expliquez la direction du changement dans l'indice BC.*/

gen nW1=(W1+W2+W3)/3
gen nW2=(W1+W2+W3)/3
gen nW3=(W1+W2+W3)/3

imdp_bci nW1 nW2 nW3, alpha(1) gamma(1) b1(0.33) pl1(3.5) b2(0.33) pl2(3.5) b3(0.33) pl3(3.5)

save "C:\Evaluation_4\COMBARY_Data_1.dta", replace 

//*EXERCICE PRATIQUE 3*//

/*Le fichier de données Canada_1996_2005_random_sample_1 est un échantillon tiré au hasard de 100 000 observations. Il contient des informations sur les revenus bruts, les impôts et les transferts.*/

use "C:\Evaluation_4\Canada_Incomes&Taxes_1996_2005_random_sample_1.dta", clear 

/*3.1	A l'aide des observations de 2005, estimez l’espérance des taux marginaux d'impôts, de bénéfices et de revenus nets pour la plage de revenus bruts comprise entre 1 000 et 31 000 $ (astuces : utilisez la commande DASP cnpe avec l'option : type(dnp)).*/

preserve
keep if year==2005
cnpe T B N, xvar(X) hsize(hhsize) min(1000) max(31000) type(dnp)
restore

/*3.2 Estimez l’impact redistributif sur l’indice d’inégalité de Gini pour 1999, 2002 et 2005 (astuce : utilisez les commandes Stata preserve/restore conserver les données après avoir utilisé la commande Stata “keep if year==…”).*/

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
restore

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

/*3.3 Estimez l'indice de progressivité de Kakwani par an à l'aide de la commande DASP iprog (astuce : utilisez l’option gobs(year)).*/ 

iprog T, ginc(X) hsize(hhsize) gobs(year) type(t) index(ka)

/*3.4 À l'aide des observations de 2005, vérifiez la condition de TR progressivité pour la taxe T à l'aide de la commande DASP cprog.*/ 

preserve
keep if year==2005 
cprog T, rank(X) type(t) 
restore

/* Sur la base de l'approche TR, la progressivité de l'impôt n'est pas vérifiée */

/*3.5	Dans quelle province l'inégalité était-elle la plus élevée en 2005 ? Dans quelle province l’indice de progressivité fiscale de Kakwani était-il le plus élevé de 2005 ?*/

preserve
keep if year==2005 
igini T, hgroup(province) 
restore

preserve
keep if year==2005 
iprog T, ginc(X) hsize(hhsize) gobs(province) type(t) index(ka)
restore



