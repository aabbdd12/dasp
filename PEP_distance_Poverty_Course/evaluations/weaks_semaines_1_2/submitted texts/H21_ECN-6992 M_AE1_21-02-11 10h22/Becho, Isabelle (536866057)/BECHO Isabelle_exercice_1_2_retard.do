*************************10%


*Exercice 1*********4%
*Q 1.1: À l’aide de Stata, générez le revenu par habitant (pcinc).
 gen pcinc = income/hhsize
*Q 1.2: À l'aide de Stata, estimez le revenu moyen par habitant et le revenu total de notre population.

*Le revenu moyen par habitant

sum pcinc [aw=hhsize]
mean pcinc [aw=hhsize]

*Le revenu total de notre population

total income

*Q 1.3: Supposons que le seuil de pauvreté soit égal à 100. Générez la variable « intensité de la *pauvreté par habitant (pgap) », puis estimez sa moyenne (l’intensité de la pauvreté par habitant *devrait être normalisée par le seuil de pauvreté).

gen pline = 100

gen pgap = 0

replace pgap = (pline-pcinc)/pline if (pcinc < pline)
sum pgap [aw=hhsize]

*Q 1.4: Refaites la question Q 1.3 avec DASP
ifgt pcinc, pline(100) alpha(1) hsize(hhsize)
*Q 1.5: Supposons que le pouvoir d'achat dans la région B soit supérieur de 10% à celui de la région A
gen deflator = 1
replace deflator = 0.9 if region == 2 
replace deflator = 0.7 if region == 3 
gen rpcinc = pcinc/deflator

Q 1.6: Refaites les questions 1.3 et 1.4 en utilisant le revenu réel par habitant lorsque le seuil de pauvreté est de 120.

R : 
sum rpcinc [aw=hhsize]
ge pline2 = 120
. replace pgap2  = (pline2-rpcinc2)/pline2 if (rpcinc2 < pline2)
. sum     pgap2 [aw=hhsize]
. ifgt    rpcinc2, pline(120) alpha(1) hsize(hhsize)

*Exercice 2***************2%
*À l'aide du fichier data_1, estimez les dépenses moyennes par équivalent adulte sans utiliser le *poids de sondage et en utilisant la commande DASP imean. À quoi réfère cette statistique?

imean ae_exp , hsize(hhsize) /*(sans utiliser le poids) ==>imean ae_exp */


*Q2. ?????


*Vérifiez si les dépenses moyennes par équivalent adulte dans la région 1 sont supérieures au double de celles de la région 3. Discutez brièvement ce résultat.

dimean ae_exp ae_exp , hsize1(hhsize) test(100) cond1(strata==3 ) hsize2(hhsize) cond2(strata==1 ) 
1 ;4
*À l'aide de la commande DASP dimean, évaluez si les dépenses moyennes par équivalent adulte *pour les chefs de famille hommes sont plus élevées que celles des femmes chefs de famille. *Discutez brièvement ce résultat.
dimean ae_exp ae_exp , hsize1(hhsize) test(100) cond1( sex ==2 ) hsize2(hhsize) cond2( sex ==1 ) 

*Exercice 3**********4%
*Q 3.1 Utilisez le fichier de données data_1.dta, puis calculez la taille de la population des ménages *échantillonnés.   

. sum hhsize
*Q 3.2 Ordonnez les dépenses par habitant en ordre croissant et générez ensuite la variable part de *population (ps) qui comprend la proportion de la population échantillonnée avec les dépenses *par habitant correspondantes. Sur cette base, générez les variables centiles (p) et quantiles (q).

gen ps = hhsize/r(sum)
gen p = sum(ps)
gen q = pcexp

*Q 3.3 Dessinez la courbe de distribution cumulative (Axe X: les centiles et axe Y: les dépenses par habitant correspondantes) (domaine des centiles: min = 0 et max = 0,95).

line p pcexp /*if p<0.95*/, title(The cumulative distribution curve) xtitle(The per capita expenditure (y)) ytitle(F(y))

*Q 3.4 Tracez la courbe des quantiles (Axe X: centiles et axe Y: quantiles) (domaine des centiles: min *= 0 et max = 0,95), et commentez brièvement les résultats.

line q p /*if p<0.95*/ , title(The quantile curve) xtitle(the percentile (p)) ytitle(The quantile Q(p))

*Q 3.5 En utilisant DASP, dessinez la courbe des quantiles pour chacune des régions rurales et urbaines (domaine des centiles : min = 0 et max = 0,95), et discutez brièvement des résultats.

R : 
c_quantile q, hsize(hhsize) hgroup(zone) min(0.0) max(0.95)

***Q6????
*Reponse: cdensity pcexp , hs(hhsize) band(25000) min(0) max(1000000) hg(sex)