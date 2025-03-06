***************12%

clear all

/* EXERCICE 1 *********4%*/

// Données
input	identifier	region	income	hhsize
	1	1	210	4
	2	1	450	6
	3	1	300	5
	4	1	210	3
	5	2	560	2
	6	2	400	4
	7	3	140	4
	8	3	250	2
	9	3	340	2
	10	3	220	2
	11	3	360	3
	12	3	338	3
end

// Q 1.1: À l’aide de Stata, générez le revenu par habitant (pcinc).
gen pcinc = income/hhsize

// Q 1.2: À l'aide de Stata, estimez le revenu moyen par habitant et le revenu total de notre population.
sum pcinc [aw=hhsize]
display "revenu moyen par habitant = " r(mean)
display "revenu total de la population = " r(sum)

//Q 1.3: Supposons que le seuil de pauvreté (pline) soit égal à 100. Générez la variable « intensité de la pauvreté par habitant (pgap) », puis estimez sa moyenne. 
gen     pline = 100
gen     pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline) 
sum     pgap [aw=hhsize]
display "moyenne de l'intensité de la pauvreté par habitant = " r(mean)

//Q 1.4: Refaites la question Q 1.3 avec DASP.
ifgt pcinc, pline(100) alpha(1) hsize(hhsize)

//Q 1.5: Supposons que le pouvoir d'achat dans la région B soit supérieur de 10% à celui de la région A et que celui de la région C soit supérieur de 30% à celui de la région A. Dans le cas où la région A est la région de référence, générez la variable (deflator) en tant qu'indice de déflation des prix, puis générez la variable de revenu réel par habitant (rpcinc).
gen deflator = 1
replace deflator = 0.9 if (region == 2)
replace deflator = 0.7 if (region == 3)
gen rpcinc = pcinc/deflator 

//Q 1.6: Refaites les questions 1.3 et 1.4 en utilisant le revenu réel par habitant lorsque le seuil de pauvreté est de 120.
// estimation avec Stata
replace pline = 120
gen     pgap2 = 0
replace pgap2 = (pline-rpcinc)/pline if (rpcinc < pline) 
sum     pgap2 [aw=hhsize]
display "moyenne de l'intensité de la pauvreté par habitant = " r(mean)

// estimation avec DASP.
ifgt rpcinc, pline(120) alpha(1) hsize(hhsize)



/* EXERCICE 2 ****2.5%*/

clear all

// Données
//emplacement du fichier (file path to be updated if necessary)
cd "~/Documents/Stata"
//data import
use data_1

//1.1 Estimez les dépenses moyennes par équivalent adulte sans utiliser le poids de sondage et en utilisant la commande DASP imean. 
imean ae_exp, hsize(hhsize) /*(Commentaire: sans utiliser le poids de sondage 
							    Réponse: imean ae_exp)*/

//1.2
//Cas 1
svyset , strata(strata)
imean ae_exp, hsize(hhsize)
//Cas 2
svyset psu
imean ae_exp, hsize(hhsize)
//Cas 3
svyset psu, strata(strata)
imean ae_exp, hsize(hhsize)
//Cas 4
svyset psu [pweight=sweight], strata(strata)
imean ae_exp, hsize(hhsize)

//1.3	Vérifiez si les dépenses moyennes par équivalent adulte dans la région 1 sont supérieures au double de celles de la région 3. Discutez brièvement ce résultat.
gen double_ae_exp = ae_exp*2
dimean double_ae_exp ae_exp, hsize1(hhsize) test(0) cond1(region==3) hsize2(hhsize) cond2(region==1) conf(ub)

//1.4	À l'aide de la commande DASP dimean, évaluez si les dépenses moyennes par équivalent adulte pour les chefs de famille hommes sont plus élevées que celles des femmes chefs de famille. Discutez brièvement ce résultat.
dimean ae_exp ae_exp, hsize1(hhsize) test(0) cond1(sex==2) hsize2(hhsize) cond2(sex==1) conf(ub)



/* EXERCICE 3 *********5.5%*/

//Q 3.1 calculez la taille de la population des ménages échantillonnés.   
summarize
display "la taille de la population des ménages échantillonnés est " r(N)

//Q 3.2 Ordonnez les dépenses par habitant en ordre croissant et générez ensuite la variable part de population (ps) qui comprend la proportion de la population échantillonnée avec les dépenses par habitant correspondantes. Sur cette base, générez les variables centiles (p) et quantiles (q).
sort pcexp
sum hhsize
gen ps = hhsize/r(sum) 
gen p = sum(ps)
gen q = pcexp


//Q 3.3 Dessinez la courbe de distribution cumulative (Axe X: les dépenses par habitant et axe Y:  les centiles correspondantes) (domaine des centiles: min = 0 et max = 0,95).
gen domain_centile = 1 if p <= 0.95

#delimit;
line p pcexp if domain_centile==1, 
title(Courbe de distribution cumulative) 
xtitle(Depenses par habitant (y)) 
ytitle(F(y)) 
ylabel(0(0.05)0.95, angle(horizontal))
;
 
//Q 3.4 Tracez la courbe des quantiles (Axe X: centiles et axe Y: quantiles) (domaine des centiles: min = 0 et max = 0,95), et commentez brièvement les résultats.
#delimit;
line  q p if domain_centile==1, 
title(Courbe des quantiles) 
xtitle(Centiles (p)) 
ytitle(Quantiles Q(p)) 
xlabel(0(0.05)0.95) 
ylabel(, angle(horizontal))
;
 
//Q 3.5 En utilisant DASP, dessinez la courbe des quantiles pour chacune des régions rurales et urbaines (domaine des centiles : min = 0 et max = 0,95), et discutez brièvement des résultats.
#delimit;
c_quantile q, hsize(hhsize) hgroup(zone) max(0.95) 
title(Courbe des quantiles par zone) 
xtitle(Centiles (p)) ytitle(Quantiles Q(p)) 
xlabel(0(0.05)0.95) 
ylabel(, angle(horizontal))
;

//Q 3.6 À l'aide de DASP, dessinez les courbes de densité des dépenses par habitant en fonction du sexe du chef de ménage (domaine des dépenses par habitant: min = 0 et maximum = 1000000) et discuter brièvement des résultats.
#delimit;
cdensity pcexp , hs(hhsize) hgroup(sex) min(0) max(1000000) 
title(Courbe de densite des dépenses par habitant) 
xtitle(Dépenses par habitant (y)) 
ylabel(, angle(horizontal))
;

