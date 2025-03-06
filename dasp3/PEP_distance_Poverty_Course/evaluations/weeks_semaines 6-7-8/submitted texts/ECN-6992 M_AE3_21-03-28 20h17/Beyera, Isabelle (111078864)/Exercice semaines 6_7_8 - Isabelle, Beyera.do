**********12.5%


//Exercice 1******3.5%
//1.1 Estimation du seuil de pauvreté subjective:
/*Utilisation du fichier de données*/
clear
use data_b3_2.dta, clear

/*Pour l’estimation du seuil de pauvreté subjective, la technique de régression non paramétrique est utilisée afin de prédire le bien-être minimum. 
La commande ‘’cnpe ae_exp min_ae_exp, xvar(ae_exp) min(0) max(100000)’’ va dessiner deux courbes.
- La première courbe indiquera la relation entre la variable Y : ae_exp et la variable X ae_exp.
- La seconde courbe montrera la relation entre la variable Y : min_ae_exp et la variable X ae_exp.
La plage de l'axe X est comprise entre 0 et 100000.
Les autres options sont similaires à celles de la commande Stata "line", qui est utilisée pour dessiner des courbes. La dernière option vgen(yes) demande de générer les valeurs prédites pour chaque niveau de X_i (c'est-à-dire Predicted [Y|X_i]).
Les noms des variables générées commenceront par "_npe_" suivi du nom de la variable Y (exemple _npe_ae_exp). 
Enfin, l’option hsize(hsize) est incluse dans la commande pour tenir compte de l’unité d'analyse qu’est l’individu.  */
cnpe ae_exp  min_ae_exp, xvar(ae_exp) hsize(hsize) min(0) max(100000)                      ///
legend(order( 1 " Bien- être observé " 2 " Bien-être  minimum prévu "))  ///
subtitle("") title(La ligne de pauvreté subjective)            ///
 xtitle(Bien- être observé)                       /// 
 ytitle(Bien-être minimum prévu )              ///
 vgen(yes)

/*On estime ensuite le niveau de ae_exp lorsque la différence entre le bien-être minimum prévu et le bien-être observé est nulle. En ajoutant l'option xval(0) au lieu des deux options min() et max(), le cnpe effectue la prédiction pour une seule valeur de X (dif dans notre cas) , à savoir E[ae_exp|dif==0]. */
cap drop dif
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) hsize(hsize) xval(0) vgen(yes)

/*Le seuil de pauvreté subjectif est ainsi de (z=22289.966797). Pour afficher ce seuil dans notre graphique, nous traçons les deux premières courbes ci-dessus, et nous montrons en plus le seuil de pauvreté subjectif avec l'option xline(22289.966797) */
cnpe ae_exp min_ae_exp, xvar(ae_exp) hsize(hsize) min(0) max(100000) ///
legend(order( 1 " Bien- être observé " 2 " Bien-être minimum prévu"))  ///
subtitle("") title(La ligne de pauvreté subjective)            ///
 xline(22289.966797) xtitle(Bien- être observé)                       /// 
 ytitle(Bien-être minimum prévu )              ///

//1.2 L’estimation de la pauvreté peut se faire à l’aide des commandes DASP ci-dessous :

/*L’estimation de l’intensité de la pauvreté peut se faire à l’aide des commandes DASP ci-dessous :*/
//a) Pour l’estimation de la pauvreté subjective on retient comme seuil, le seuil de pauvreté subjectif estimé précédemment et il est de z=22289.97 :
ifgt ae_exp, alpha(1) hsize(hsize) pline(22289.97)

// b) Pour estimer la pauvreté absolue on retient le seuil de pauvreté absolue (z=20600) :
ifgt ae_exp, alpha(1) hsize(hsize) pline(20600)

//c) Pour estimer la pauvreté relative, on considère le seuil de pauvreté relative (z= moitié du revenu moyens) :
/* Dans le cas de l’approche relative, nous n'indiquons pas le seuil de pauvreté, mais plutôt les options : opl(mean) prop(50) */
ifgt ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)


//Exercice 2*******4.5%
//2.1 Décomposition de la pauvreté (taux de pauvreté) selon le sexe du chef de ménage (sex) avec un seuil de pauvreté de 20600. 
clear
use data_b3_2.dta, clear
dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20600)

//2.2	Estimation de la pauvreté totale (taux de pauvreté) en fonction de la région du chef de ménage (region). 
dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(20600)

//2.3 Génération de la variable ae_exp2 
gen ae_exp2= ae_exp
replace ae_exp2= ae_exp*(1+0.12) if region==3
replace ae_exp2= ae_exp*(1-0.06) if region==2

//2.4 En utilisant l'approche de Shapley, décomposons le changement de l'intensité de la pauvreté en croissance et redistribution. 
dfgtgr ae_exp ae_exp2, alpha(1) pline(20600)

//2.5 Effectuez une décomposition sectorielle (basée sur les groupes de régions) de la variation de l'intensité de la pauvreté totale. 
 


//Exercice 3********4.5%

//3.1: Insertion des données, puis générez les centiles :
/*En insérant les données, nous ajoutons une première ligne avec des valeurs nulles pour considérer le cas de percentile = 0 */

clear
input identifier weight inc_t1 inc_t2 
   0 0 0 0.00 0.00
   1 0.1 1.5 1.54
   2 0.1 4.5 3.85
   3 0.1 7.5 6.6
   4 0.1 3 2.75
   5 0.1 4.5 4.4
   6 0.1 9 7.7
   7 0.1 10.5 8.8
   8 0.1 15 7.7
  9 0.1 12 6.6
  10 0.1 13.5 6.6
  end

//Générer les centiles:
/*Nous ordonnons tout d'abord les individus en fonction des revenus*/
sort inc_t1

/*Ensuite,comme le percentile d'un revenu donné est la part de population de ceux dont les revenus sont égaux ou inférieurs au revenu d'intérêt, nous considérons dans notre cas, le poids c'est-à-dire la variable "weight" comme la part de la population */
gen perc=sum(weight)
list perc inc_t1

//3.2 Initialisation du scalaire g_mean, qui est égal au taux de croissance du revenu moyen.
/*On calcule d"abord la moyenne des revenus en t1 (période initiale) */
qui sum inc_t1 [aw=weight] 
/*On garde en mémoire le scalaire  mean1 = r(mean) in t1 comme suit:*/
scalar mean1=r(mean) 
/*calcul de la moyenne des revenus en t2 */
qui sum inc_t2 [aw=weight]
/*Pour garder en mémoire le scalaire  mean2 = r(mean) en t2 */
scalar mean2=r(mean)    
/*La variable g_mean, qui est égale à la croissance des moyennes est généré comme suit:  */ 			
scalar g_mean = (mean2-mean1)/mean1
gen g_mean  = (mean2-mean1)/mean1    	
dis "Mean 1              =" mean1
dis "Mean 2             = " mean2
dis "Growth in averages = " g_mean

//3.3 Génération de la variable g_inc, comme la croissance des revenus individuels.
gen g_inc =(inc_t2-inc_t1)/inc_t1 
replace g_inc = 0 in 1
/* Cette dernière commande remplace la valeur manquante par 0 car la croissance est nulle lorsque le percentile= 0 */

//3.4 Dessinons la courbe d’incidence de la croissance à l’aide des variables g_inc et perc. 
line g_inc g_mean perc, ///
title(Courbe d’incidence de la croissance ‘GIC’) ///
yline(`g_mean') ///
legend(order( 1 "GIC curve" 2 "Growth in average income")) ///
xtitle(Percentiles (p)) ytitle(Growth in incomes)  ///
plotregion(margin(zero))

//3.5 Estimation de l'indice pro-pauvres de Chen et Ravallion (2003)
drop in 1                            // pour supprimer la valeur 0 sur la première ligne.
sum g_inc [aw=weight] if (inc_t1<10.4) 	 
dis = r(mean)

//3.6 Décomposition du changement de l'intensité de la pauvreté en composantes de croissance et de redistribution en utilisant l'approche de Shapley.

dfgtgr inc_t1 inc_t2, alpha(1) pline(10.4)

/*La commande dfgtgr de DASP permet de décomposer la variation des indices FGT entre deux périodes en composantes de croissance et de redistribution. Cette décomposition est effectuée selon trois approches différentes :
- Approche Datt & Ravallion : période de référence t1  
- Approche Datt & Ravallion : période de référence t2
- Approche de Shapley (permet de dépasser la spécification de la période de référence).  */


