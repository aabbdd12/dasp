****************12%

//Code Stata  pour les Exercices semaines 6, 7 et 8


*EXERCICE 1***************3%
//Question 1.1 :
/*1.1	En utilisant le fichier de données data_b3_1.dta, estimez le seuil de pauvreté subjective en considérant les informations suivantes :
•	Le bien-être équivalent adulte observé est la variable :  ae_exp
•	Le bien-être équivalent-adulte perçu minimum pour échapper à la pauvreté est min_ae_exp.
•	L’unité d'analyse est l’individu (utilisez la variable de taille du ménage).
*/


/* Utilisation de la technique de régression non paramétrique pour prédire le bien-être minimum perçu */

/* Selon le cours et les exercices préparatoires, "la régression non paramétrique est utile pour montrer le lien entre deux variables sans spécifier au préalable une forme fonctionnelle. La commande Stata :
cnpe ae_exp min_ae_exp, xvar(ae_exp) min(0) max(60000) ...
va dessiner deux courbes.
- La première courbe montrera la relation entre la variable Y : ae_exp et la variable X ae_exp.
- La seconde courbe montrera la relation entre la variable Y : min_ae_exp et la variable X ae_exp.
La plage de l'axe X est comprise entre 0 et 600000.
Les autres options sont similaires à celles de la commande Stata "line", qui est utilisée pour dessiner des courbes.
La dernière option vgen(yes) demande de générer les valeurs prédites pour chaque niveau de X_i (c'est-à-dire Predicted [Y|X_i]).
Les noms des variables générées commenceront par "_npe_" suivi du nom de la variable Y (exemple _npe_ae_exp)".

*/

clear

use "C:\Documents\Laval 2021\ECN-6992 Measuring and Alleviating Poverty and Inequality Mesure et allègement de la pauvreté et inégalité H21\Devoir 6 7  8\data_b3_1.dta"

cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)  hsize(hsize)                   ///
legend(order( 1 "Bien être minimum perçu" 2 "Bien être observé"))  ///
subtitle("") title(Ligne de pauvreté subjective)            ///
 xtitle(Bien être observé)                       /// 
 ytitle(Niveau de Prédiction du bien être perçu)              ///
 vgen(yes)


 /*
Estimer le niveau de ae_exp lorsque la différence entre le bien-être minimum prévu et le bien-être observé est nulle.
En ajoutant l'option xval(0) au lieu des deux options min() et max(), le cnpe effectue la prédiction pour une seule valeur de X (dif dans notre cas) , à savoir E[ae_exp|dif==0].
*/
 
cap drop dif
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) xval(0) vgen(yes)
 
/*
Afficher le seuil de pauvreté subjectif : Ici nous traçons les deux premières courbes, mais, en plus, nous montrons le seuil de pauvreté subjectif avec l'option xline(22914.478516)
*/ 
 
cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)  hsize(hsize)                   ///
legend(order( 1 "Bien être minimum perçu" 2 "Bien être observé"))  ///
subtitle("") title(Ligne de pauvreté subjective)            ///
xline(22914.478516) xtitle(Bien être observé)                       /// 
 ytitle(Niveau de Prédiction du bien être perçu)              ///
 vgen(yes)
 
 
 //Question 1.2 :
 
 /*Estimez l’intensité de la pauvreté (avec les variables : ae_exp and hsize) pour chacun de ces trois cas, et discutez les résultats :
a)	Le seuil de pauvreté subjective ;
b)	Le seuil de pauvreté absolue (z=21000) ;
c)	Le seuil de pauvreté relative (z= moitié du revenu moyens).
*/
 
 
 /* ifgt est une commande DASP qui peut être utilisée pour estimer les indices de pauvreté FGT.*/
 
 //a)	Le seuil de pauvreté subjective ;
ifgt  ae_exp, alpha(1) hsize(hsize) pline(22914.478516)

// b)	Le seuil de pauvreté absolue (z=21000) ;

ifgt  ae_exp, alpha(1) hsize(hsize) pline(21000)

//  c)   Le seuil de pauvreté relative (z= moitié du revenu moyens)

ifgt  ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)

// Q 1.3:
/*
Selon le cours et les exercices préparatoires, "l'utilisation du seuil de pauvreté absolue est justifiée par deux raisons principales.
Premièrement, il nous permet d'obtenir des profils de pauvreté "cohérents", c'est-à-dire que deux individus quelconques ayant le même niveau de vie réel doivent être considérés comme identiques en termes d'évaluation de la pauvreté.
Deuxièmement, elle nous permet d'éviter de sous-estimer la valeur des exigences minimales lorsque le pays est très pauvre et que le seuil de pauvreté relative diminue avec la baisse du niveau moyen de bien-être du pays."
*/


/*COMMENTAIRE REPONSE: L'utilisation du seuil de pauvreté relative est plus appropriée pour les pays développés. 
Ceci peut être justifié par l'augmentation rapide du bien-être en moyenne et du niveau de vie dans le temps.

*/


//Exercice 2******4,5%

//
/*Les indices de pauvreté additive, comme l'indice FGT, permettent d'effectuer une décomposition analytique exacte de ces indices par sous-groupe de population. Ceci est utile pour montrer la contribution de chaque groupe à la pauvreté totale.*/

/*Question 2.1	Utilisez le fichier data_b3_1.dta et décomposez la pauvreté (taux de pauvreté) selon le sexe du chef de ménage (sex) (le seuil de pauvreté est 21000). Que pouvons-nous conclure ?  */

clear

 use "C:\Documents\Laval 2021\ECN-6992 Measuring and Alleviating Poverty and Inequality Mesure et allègement de la pauvreté et inégalité H21\Devoir 6 7  8\data_b3_1.dta"

dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(21000)


/*Question 2.2 Estimez la pauvreté totale (taux de pauvreté) en fonction de la région du chef de ménage (region*/

dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(21000)




/*Question 2.3 : La répartition des dépenses en équivalent-adultes est similaire à celle de la période initiale (ae_exp), avec les légères différences suivantes
•	Les dépenses en équivalent-adultes ont augmenté de 10% dans la région 3;
•	Les dépenses en équivalent-adultes ont diminué de 6% dans la région 2;
Générez la variable ae_exp2 en vous basant sur les informations ci-dessus. 
*/

gen ae_exp2 = ae_exp 

/*Estimation des nouvelles dépenses en équivalent-adultes  dans la région 3*/
replace ae_exp2 = ae_exp * 1.1 if region == 3
 /*Estimation des nouvelles dépenses en équivalent-adultes dans la région 2*/
replace ae_exp2 = ae_exp * 0.94 if region == 2

/*Question 2.4	En utilisant l'approche de Shapley, décomposez le changement de l'intensité de la pauvreté en croissance et redistribution. Puis discutez des résultats. */


/*Selon le cours et les exercices préparatoires, ''la commande dfgtgr de DASP permet d'effectuer la décomposition de la variation des indices FGT entre deux périodes en composantes de croissance et de redistribution.
Cette décomposition est effectuée selon trois approches différentes :
- Approche Datt & Ravallion : période de référence t1
- Approche Datt & Ravallion : période de référence t2
- Approche de Shapley (permet de dépasser la spécification de la période de référence)" */

dfgtgr ae_exp ae_exp2, alpha(1) pline(21000)

/*Question 5 : 	Effectuez une décomposition sectorielle (basée sur les groupes de régions) de la variation de l'intensité de la pauvreté totale. Discutez des résultats.*/


dfgtg2d ae_exp ae_exp2, alpha(1) hgroup(region) pline(21000) hsize1(hsize) hsize2(hsize) ref(0)


//Exercice 3**********4,5%

/*Question 3.1 :  Insérez les données, puis générez les centiles (basé sur le rang des revenus de la période initiale (variable perc)), et le premier centile doit être égal à zéro).*/

clear


input identifier weight  inc_t1 inc_t2
0 0 0.00 0.00
1 0.1 1.50 1.54
2 0.1 4.50 3.85
3 0.1 7.50 6.60
4 0.1 3.00 2.75
5 0.1 4.50 4.40
6 0.1 9.00 7.70
7 0.1 10.50 8.80
8 0.1 15.00 7.70
9 0.1 12.00 6.60
10 0.1 13.50 6.60
end

/*
Pour générer des percentiles, nous commençons par ordonner les individus/observations en fonction des revenus.
Cette tâche peut être effectuée avec la commande "sort"
*/
sort inc_t1

/*
Le poids ici  est simplement la part de chaque individu dans la population.
Le percentile d'un revenu donné est simplement la part de population de ceux dont les revenus sont égaux ou inférieurs au revenu d'intérêt. */

gen perc=sum(weight)
list perc

/*Question 3.2 Initialisez le scalaire g_mean, qui est égal au taux de croissance du revenu moyen.*/

//Calcul de  la moyenne des revenus en t1. Grâce à la commande summarize  on obtient la moyenne: r(mean)
qui sum inc_t1 [aw=weight]   	

//Enregistrement  dans la mémoire le scalaire  mean1 = r(mean) in t1		 
scalar mean1=r(mean) 

 //calcul de  la moyenne des revenus en t2. Grâce à la commande summarize  on obtient la moyenne: r(mean) 
qui sum inc_t2 [aw=weight]

//Enregistrement  dans la mémoire le scalaire  mean1 = r(mean) in t2

scalar mean2=r(mean)         			

// Calcul de la croissance des moyennes que est égale g_mean.
scalar g_mean = (mean2-mean1)/mean1
gen g_mean  = (mean2-mean1)/mean1    	 
// Affichage des paramètres

dis "Mean 1              =" mean1
dis "Mean 2             = " mean2
dis "Growth in averages = " g_mean

/*Question 3.3 Générez la variable g_inc, comme la croissance des revenus individuels.*/


//Calcul de la variable g_inc qui est la croissance individuelle des revenus
gen g_inc =(inc_t2-inc_t1)/inc_t1 		 

//Ajustement de la valeur du premier percentile, lorsque le percentile = 0, la croissance est également de 0  valeurs par défaut.
replace g_inc = 0 in 1         


/*Question 3.4 : Dessinez la courbe d’incidence de la croissance à l’aide des variables g_inc et perc. Discutez des résultats.
*/

/*
Selon le cours et les exercices préparatoires, "La ligne de commande permet de produire des graphiques dans lesquels on trace des courbes linéaires. 
En général, la syntaxe de la ligne de commande est la suivante
line y1 y2 y3...yN x , options.
Ainsi, on indique les variables des coordonnées Y (une ou plusieurs), puis le varname des coordonnées X. 
Dans notre cas, les options sont :
1- title:titre principal ;
2- ytitle : titre de l'axe y ;
3- xtitle : titre de l'axe des x ;
4- legend(order(...)) : pour étiqueter les courbes (dans notre cas, nous avons deux courbes : g_inc g_mean)
5- plotregion(margin(zero)) : pour supprimer les marges(espaces) dans la région où nous traçons la figure. "

*/

line g_inc g_mean perc, ///
title(Growth Incidence Curve) ///
yline(`g_mean') ///
legend(order( 1 "GIC curve" 2 "Growth in average income")) ///
xtitle(Percentiles (p)) ytitle(Growth in incomes)  ///
plotregion(margin(zero))


/*	Question 3.5	Supposons que le seuil de pauvreté est égal à 10.2. Estimez l'indice pro-pauvres de Chen et Ravallion (2003) (IP=1/q ∑_(i=1)^q▒〖γ^t (p_i ) 〗). Discutez des résultats.*/


/*
Il est rappelé dans le cours et les exercices préparatoires : "que l'indice pro-pauvre de Chen et Ravallion (2003) est simplement la moyenne de la croissance des revenus des individus pauvres.  
*/

drop in 1
// Calcul de  la croissance moyenne des revenus des personnes pauvres. 
sum g_inc [aw=weight] if (inc_t1<10.2) 	
dis = r(mean)

//La croissance moyenne des revenus est de -0.08.
// Calcul des  différents indices de pauvreté avec DASP
ipropoor inc_t1 inc_t2, pline(10.2)   	 

/*


Le taux de croissance des indices de pauvreté est de -0.30. L’indice de Ravallion et Chen est de -0.0812. Lorsque l’on lui soustrait le taux de croissance (g), nous avons une valeur de 0.22. 
Il convient de préciser que ces indices mesurent  la croissance sera pro-pauvre qui est définie comme la croissance lorsque le taux de croissance du revenu des individus pauvres sera supérieur à celui des individus non pauvres (White et Anderson, 2000; Klasen, 2003).
En fait, il s’agit de la croissance  qui vient de la base, et qui profite à terme à l’ensemble de la
population par un flux de bas en haut et qui permet d’accélérer les mécanismes de réduction de la pauvreté. 
L’indice -0.0812 est le changement de la pauvreté qui s’est produit avec la distribution de la croissance 
*/





//  Q6:
/*
La commande dfgtgr de DASP permet d'effectuer la décomposition de la variation des indices FGT entre deux périodes
en composantes de croissance et de redistribution.
Cette décomposition est effectuée selon trois approches différentes :
- Approche Datt & Ravallion : période de référence t1  
- Approche Datt & Ravallion : période de référence t2
- Approche de Shapley (permet de dépasser la spécification de la période de référence).  

*/


dfgtgr inc_t1 inc_t2, alpha(1) pline(10.2)

/*La commande permet une décomposition de la différence entre les indices de pauvreté. Dans le cas d’espèce, il s’agit de la différence entre les  revenus  inc_t1 et  inc_t2_ exp2.  Cette commande génère la contribution marginale  de la croissance et de la distribution  à l’intensité de la  pauvreté. Nous avons ici le changement de l’intensité de  la pauvreté dans le temps qui  est supposé expliqué par la croissance du revenu (0.171182)       et le changement de la redistribution (-0.0313). Ces valeurs sont significatives au seuil de 5%.*/






 
 
 