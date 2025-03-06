*******************12,5

/*Exercices semaines 9, 10 et 11

Pour répondre à toutes les questions ci-dessous, vous devez utiliser Stata (et, spécifiquement, DASP, si demandé). Soyez concis(es) et clair(e)s dans vos réponses. 

L’examen est divisé en trois exercices (les points assignés à chaque exercice sont indiqués à côté de chaque exercice). Veuillez répondre directement dans ce fichier après chaque question et veuillez joindre le fichier *.do (do-file) que vous avez généré. Renommez ces deux fichiers en : "Exercice semaines 9-10-11 - Prénom, Nom" et veuillez les soumettre par la boîte de dépôt du portail de cours avant mardi le 13 avril à 23h59 (heure du Québec).
*/

// Exercice 1 (4.5%):******4,5%

/*
 Supposons que la population est composée de six individus. Les niveaux de chacune des trois dimensions du bien-être sont rapportés dans le tableau ci-dessous.  
*/ 


clear
input str11 individu  w1 w2 w3
"Individu 1" 1 5 3
"Individu 2" 2 3 0
"Individu 3" 4 4 6
"Individu 4" 3 3 4
"Individu 5" 7 5 4
"Individu 6" 6 4 3
end

//Supposons que le seuil de pauvreté pour chacune des trois dimensions soit de 3.5. Effectuer les calculs suivants avec Stata. 


//1.1	En utilisant l'approche de l’union, estimez la proportion d'individus pauvres. Refaites l'estimation à l'aide de la commande DASP appropriée. 


// Estimation à l'aide de STATA

// nous créons une variable compteur  pour compter le nombre de  pauvres et de non pauvres
gen compteur =0
replace compteur =1 if w1<3.5 
replace compteur =1 if w2<3.5
replace compteur  =1 if w3<3.5

label define Nombre 0 "non pauvre" 1 "pauvre"
label values compteur  Nombre

tab  compteur

//Estimation à l'aide de la commande appropriée de DASP

imdp_uhi w1 w2 w3, pl1(3.5) pl2(3.5) pl3(3.5)

/*
1.2	En utilisant l'approche par intersection, estimez la proportion d'individus pauvres. Refaites l'estimation à l'aide de la commande DASP appropriée. 
*/

// Estimation à l'aide de STATA

drop compteur
gen compteur = 1
replace compteur = 0 if w1 >3.5 
replace compteur = 0 if w2 >3.5
replace compteur  = 0 if w3 >3.5


label values compteur  Nombre

tab  compteur
drop compteur

//Estimation à l'aide de la commande appropriée de DASP

imdp_ihi w1 w2 w3, pl1(3.5) pl2(3.5) pl3(3.5)



/*1.3	Quelle approche est la plus sensible à l'augmentation des privations multiples 
individuelles ?
*/


/*L’approche la plus sensible à l’augmentation des privations multiples est celle de l’union. Les effets sont relativement plus cumulatifs que dans le deuxième cas.*/



/*	1.4  Estimez l’indice Alkire et Foster MPI(α=0) lorsque le seuil dimensionnel est égal à 2 (les pauvres sont ceux qui ont deux ou trois dimensions de privation).*/

egen sum_w = rowtotal(w*)
gen af_poor = (sum_w>=2)
gen w_af_poor = (sum_w /3)* af_poor
mean af_poor w_af_poor
//l’indice Alkire et Foster MPI(α=0) est égal à = 3.722222

/*1.5	Estimez maintenant les mêmes indices à l'aide de la commande DASP appropriée. Discutez des résultats*/

imdp_afi w1 w2 w3, dcut(2) w1(1) pl1(3.5) w2(1) pl2(3.5) w3(1) pl3(3.5)


/*Les contributions relatives des dimensions w1, w2  et w3 sont décrites dans le tableau plus haut. M0  est le produit du taux d’incidence de la pauvreté multidimensionnelle  par la quote-part moyenne de privations des pauvres. Il  satisfait au critère de monotonicité dimensionnelle : si une personne pauvre subit une privation dans une dimension supplémentaire, alors M0 augmente. Le pourcentage que chaque dimension contribue àla pauvreté est donc respectivement  42.86   (5.48)   ; 28.57  (11.40)   ;  28.57 (11.40) pour w1, w2 et w3 avec les écarts types entre parenthèses. L’interprétation est analogue pour les deux autres mesures M1 et M2.  */




/*1.6	Supposons que le gouvernement dispose de 6 $ et puisse cibler une dimension à l’aide d’un transfert universel. Quelle dimension ciblée réduirait le plus l'indice d'union et l'indice d'intersection ? Discutez de vos résultats.    */



gen w1n = w1+1

gen w2n = w2+1

gen w3n = w3+1

/*En utilisant l'approche de l’union, on estime à l'aide de la commande DASP appropriéela proportion d'individus pauvres après le transfert .*/

imdp_uhi w1 w2 w3, pl1(3.5) pl2(3.5) pl3(3.5)
imdp_uhi w1n w2 w3, pl1(3.5) pl2(3.5) pl3(3.5)
imdp_uhi w1 w2n w3, pl1(3.5) pl2(3.5) pl3(3.5)
imdp_uhi w1 w2 w3n, pl1(3.5) pl2(3.5) pl3(3.5)

/*En utilisant l'approche de l’intersection, on estime à l'aide de la commande DASP appropriéela proportion d'individus pauvres après le transfert .*/


imdp_ihi w1 w2 w3, pl1(3.5) pl2(3.5) pl3(3.5)
imdp_ihi w1n w2 w3, pl1(3.5) pl2(3.5) pl3(3.5)
imdp_ihi w1 w2n w3, pl1(3.5) pl2(3.5) pl3(3.5)
imdp_ihi w1 w2 w3n, pl1(3.5) pl2(3.5) pl3(3.5)



/*Exercice 2 (4%):****4%

Dans le cas de la dimension tridimensionnelle du bien-être, l'indice de pauvreté de Bourguignon et Chakravarty (2003) (l’indice BC) est défini comme suit :
MDP_BC=1/H ∑_(h=1)^h▒〖π"(" w_h "; z) " 〗
Où π"(" x_h "; z)"  représente la contribution de l’individu h à la pauvreté totale :
π"(" x_h "; z)=" [β_1 g_(h,1)^ρ+β_2 g_(h,2 )^ρ+β_3 g_(h,3)^ρ)]^(a/ρ) et  g_(h,i)=(z_i-w_(h,i) )_+/z_i 

Avec les données de l’exercice 1,  
*/
//Entrée des données


clear
input str11 individu  w1 w2 w3
"Individu 1" 1 5 3
"Individu 2" 2 3 0
"Individu 3" 4 4 6
"Individu 4" 3 3 4
"Individu 5" 7 5 4
"Individu 6" 6 4 3
end


/*	Estimez l’indice de pauvreté de Bourguignon et Chakravarty (2003) lorsque β_i=1/3  ∀ i,〖 z〗_i=3.5 ∀ i,   α=1 et ρ=1. */ 

//Les estimations ont été faites avec le logiciel excel et les résultats dans le fichier word de réponse. 


//2.2	Refaites l'estimation à l'aide de la commande DASP appropriée.

imdp_bci w1 w2 w3, alpha(1) gamma(1) b1(0.33) pl1(3.5) b2(0.33) pl2(3.5) b3(0.33) pl3(3.5)



/*2.3	Générez trois nouvelles variables (nw_ *) dans lesquelles les individus égalisent leurs dimensions de bien-être (exemple : gen nw_1 = (w_1+ w_2+w_3)/3) (c'est-à-dire, par exemple, l'individu 1 a 1, 5, 3 dans les trois dimensions respectivement. Après l’égalisation, nous aurons : 3, 3, 3.). Ensuite, en utilisant DASP, réestimez l’indice BC avec les nouveaux vecteurs du bien-être. Expliquez la direction du changement dans l'indice BC.*/


gen nw1 =(w1+ w2 + w3) /3
gen nw2 =(w1+ w2 + w3) /3
gen nw3 =(w1+ w2 + w3) /3


imdp_bci nw1 nw2 nw3, alpha(1) gamma(1) b1(0.33) pl1(3.5) b2(0.33) pl2(3.5) b3(0.33) pl3(3.5)

/*L’indice de pauvreté est passé de 0.159 à 0.118. Cet indice a donc connu  une baisse après l’égalisation des mesures de dimension. 


Explication
La pauvreté globale est une moyenne pondérée de la pauvreté des individus de la  population et des inégalités dans les dimensions. Une réduction des inégalités dans les dimensions réduit la pauvreté. Une réduction de la pauvreté pour les individus de la population réduit la pauvreté globale c’est ce que l’on observ en comparant les indices d’avant et après égalisation. .
On pourrait expliquer cette évolution en faisant observer que l’indice de Bourguignon et Chakravarty est sensible à la corrélation des écarts entre les dimensions. La pauvreté diminue suite à  l’augmentation de la corrélation qui tend ici vers l’infini. 

*/

/*Exercice 3 (4%):*****4%

Le fichier de données Canada_1996_2005_random_sample_1 est un échantillon tiré au hasard de 100 000 observations. Il contient des informations sur les revenus bruts, les impôts et les transferts.  
*/


clear
use "C:\Documents\Laval 2021\ECN-6992 Measuring and Alleviating Poverty and Inequality Mesure et allègement de la pauvreté et inégalité H21\Devoir 9 10 11\Canada_Incomes&Taxes_1996_2005_random_sample_1.dta"

/*3.1	A l'aide des observations de 2005, estimez l’espérance des taux marginaux d'impôts, de bénéfices et de revenus nets pour la plage de revenus bruts comprise entre 1 000 et 31 000 $ (astuces : utilisez la commande DASP cnpe avec l'option : type(dnp)).  */

cnpe T B N, xvar(X) hsize(hhsize) type(dnp) min(1000) max(31000)

/*3.2	Estimez l’impact redistributif sur l’indice d’inégalité de Gini pour 1999, 2002 et 2005 (astuce : utilisez les commandes Stata preserve/restore conserver les données après avoir utilisé la commande Stata “keep if year==…”). */

 // Estimation de l'indice de GINI pour l'année 1999
 
 preserve
 keep if year == 1999
 
 igini X B N T, hsize(hhsize)

 restore
 
 
// Estimation de l'indice de GINI pour l'année 2002
 
 preserve
 keep if year == 2002
  
 igini X B N T, hsize(hhsize)

 restore
 
 // Estimation de l'indice de GINI pour l'année 2005
 
 preserve
 keep if year == 2005
 
 igini X B N T, hsize(hhsize)

 restore
/*3.3	Estimez l'indice de progressivité de Kakwani par an à l'aide de la commande DASP iprog (astuce : utilisez l’option gobs(year)). */


iprog T , ginc(X) hsize(hhsize) gobs(year) type(t) index(ka)



/*3.4	À l'aide des observations de 2005, vérifiez la condition de TR progressivité pour la taxe T à l'aide de la commande DASP cprog.*/

preserve
 keep if year == 2005
 
 cprog T, rank(X) hsize(hhsize) hgroup(province) type(t) appr(tr)
restore

/*3.5	Dans quelle province l'inégalité était-elle la plus élevée en 2005 ? Dans quelle province l’indice de progressivité fiscale de Kakwani était-il le plus élevé de 2005 ?*/

preserve
 keep if year == 2005

igini X , hsize(hhsize) hgroup(province)
restore


/*Comme l’indique l'estimation ci-dessus, la province où l’inégalité était la plus élevée en  2005 est la province du Newfoundland  avec comme indice : 0.497669*/

preserve
 keep if year == 2005
 iprog T , ginc(X) hsize(hhsize) gobs(province) type(t) index(ka)

restore

/*Comme l’indique l'estimation ci-dessus, la province où l’indice de progressivité fiscale de Kakwani était le plus élevée en  2005 est la province du Manitoba   avec comme indice :0.137435  */


















