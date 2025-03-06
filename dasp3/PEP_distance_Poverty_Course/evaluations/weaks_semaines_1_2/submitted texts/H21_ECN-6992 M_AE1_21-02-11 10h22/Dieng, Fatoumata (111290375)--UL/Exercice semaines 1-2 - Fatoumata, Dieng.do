********************11%


*****************************************************************FATOUMATA DIENG, IDUL:FADIE6****************************************************


***************************************************************************************************************************************************************
******                                                     EXERCICE 1*******4%
***************************************************************************************************************************************************************
clear

input identifier region income hhsize
1 1 210 4
2 1 450 6
3 1 300 5
4 1 210 3
5 2 560 2
6 2 400 4
7 3 140 4
8 3 250 2
9 3 340 2
10 3 220 2
11 3 360 3
12 3 338 2
13 3 330 3
14 3 336 4
end


****************Q 1.1: À l’aide de Stata, générez le revenu par habitant (pcinc).
*********************************************************************************
gen pcinc = income/hhsize


****************Q 1.2: À l'aide de Stata, estimez le revenu moyen par habitant et le revenu total de notre population.
**********************************************************************************************************************
sum pcinc [aw=hhsize]     //revenu moyen par habitant
total(income)  //revenu total de notre population


****************Supposons que le seuil de pauvreté soit égal à 120. Générez la variable « intensité de la pauvreté par habitant (pgap) », puis estimez sa moyenne (l’intensité de la pauvreté par habitant devrait être normalisée par le seuil de pauvreté).
***********************************************************************************************************************************************************
gen pline = 120
gen pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
sum pgap [aw=hhsize] //moyenne



***************Q 1.4: Refaites la question Q 1.3 avec DASP.
*************************************************************
ifgt pcinc, pline(120) alpha(1) hsize(hhsize)


***************Q 1.5: Supposons que le pouvoir d'achat dans la région B soit supérieur de 15% à celui de la région A et que celui de la région C soit supérieur de 20% à celui de la région A. Dans le cas où la région A est la région de référence, générez la variable (deflator) en tant qu'indice de déflation des prix, puis générez la variable de revenu réel par habitant (rpcinc).
***************************************************************************************************************************************************
gen deflator = 1
replace deflator = 1.15 if region == 2  //region B
replace deflator = 1.20 if region == 3  //region C
gen rpcinc = pcinc/deflator


**************Q 1.6: Refaites la question 1.3 et 1.4 en utilisant le revenu réel par habitant lorsque le seuil de pauvreté est de 130.
*************************************************************************************************************************************
sum rpcinc [aw=hhsize]
replace pline = 130
replace pgap = (pline-rpcinc)/pline if (rpcinc < pline)
sum pgap [aw=hhsize]
ifgt rpcinc, pline(130) alpha(1) hsize(hhsize)  //commande avec Dasp


*************************************************************************************************************************************************************
******                                                     EXERCICE 2***2.5%
*************************************************************************************************************************************************************

clear
input period income hhsize na
1 29 4 2
1 50 3 2
1 36 4 3
2 30 4 2
2 48 3 3
2 46 5 2
end

***************Q 2.1: À l'aide de Stata, estimez le revenu moyen par habitant et le revenu moyen par équivalent-adulte pour chaque période.
******************************************************************************************************************************************

/* Estimation Revenu par habitant */
gen pcinc = income/hhsize

/* Estimation du revenu moyen par habitant: periode 1 */
sum pcinc [aw=hhsize] if period == 1

/* Estimation du revenu moyen par habitant: periode 2 */
sum pcinc [aw=hhsize] if period == 2

/* Creation taille equivalent adulte et revenu par equivalent adulte*/
gen aes = 1 + 0.6 * (na-1) + 0.4 * (hhsize-na) //aes
gen eainc = income/aes //revenu equivalent adulte

/* Estimation de la moyenne du revenu par equivalent adulte: periode 1 */
sum eainc [aw=hhsize] if period == 1

/* Estimation de la moyenne du revenu par equivalent adulte: periode 2 */
sum eainc [aw=hhsize] if period == 2



***************Q 2.2: Discutez des changements dans chaque mesure de bien-être




*************************************************************************************************************************************************************
******                                                     EXERCICE 3 ****4.5%
*************************************************************************************************************************************************************


cd "C:\Users\wb557366\OneDrive - WBG\Desktop\fatou\admissions\LAVAl\cours\pauvrete\evaluations"

use "data_3.dta",clear


***************Q 3.1 Utilisez le fichier de données data_3.dta, puis calculez la taille de la population des ménages échantillonnés.
*************************************************************************************************************************************
gen fweight=psu*hhsize

total(fweight) 


***************Q 3.2 Ordonnez les dépenses par habitant en ordre croissant et générez ensuite la variable part de population (ps) qui comprend la proportion de la population échantillonnée avec les dépenses par habitant correspondantes. Sur cette base, générer les variables centiles (p) et quantiles (q).*******************************************************************************************************************************************************


/*ordonner en ordre croissant les depenses par habitant*/
sort pcexp

/*generer la variable ps, proportion de la population échantillonnée*/
sum hhsize
gen ps = hhsize/r(sum)

/*generer la variable percentile et quantiles*/
gen p = sum(ps)
gen q = pcexp
list, sep(0)


***************Q 3.3 Dessinez la courbe de distribution cumulative (Axe X: les centiles et axe Y: les dépenses par habitant correspondantes) (domaine des centiles: min = 0 et max = 0,90).
*********************************************************************************************************************************************************
line p pcexp, title(La courbe de distribution cumulative) xtitle(dépenses par habitant correspondantes (pcexp)) 
ytitle(F(pcexp),min = 0, max=0.90))


**************Q 3.4 Tracez la courbe des quantiles (Axe X: centiles et axe Y: quantiles) (domaine des centiles: min = 0 et max = 0,90), et commentez brièvement les résultats.
****************************************************************************************************************************************************

c_quantile pcexp, hsize(hhsize) min(0.0) max(0.90)  //courbe des quantiles avec dasp


*************Q 3.5 En utilisant DASP, dessinez la courbe des quantiles pour chacune des régions rurales et urbaines (domaine des centiles : min = 0 et max = 0,90), et discutez brièvement des résultats.
*********************************************************************************************************************************************************
c_quantile pcexp, hsize(hhsize) hgroup(zone) min(0.0) max(0.90)


*************Q 3.6 À l'aide de DASP, dessinez les courbes de densité des dépenses par habitant en fonction du sexe du chef de ménage (domaine des dépenses par habitant: min = 0 et maximum = 800000) et discuter brièvement des résultats.
**********************************************************************************************************************************************************
cdensity pcexp, hsize(hhsize) hgroup(sex) min(0) max(800000)


