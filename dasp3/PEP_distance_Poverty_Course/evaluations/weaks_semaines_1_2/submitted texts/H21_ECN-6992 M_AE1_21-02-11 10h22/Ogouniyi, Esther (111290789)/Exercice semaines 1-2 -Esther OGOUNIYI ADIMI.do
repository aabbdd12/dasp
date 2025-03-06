******************11%

clear all 
drop _all
set more off
*===============================================================================
cd "C:\Users\Kbir\Desktop\LAVAL2021\Semaine1&2"
use data_1
*===============================================================================


* Exercice 1************4%

*Q 1.1: générez le revenu par habitant (pcinc)

 gen pcinc = income/hhsize

*Q 1.2 :estimez le revenu moyen par habitant et le revenu total de notre population.
asdoc sum pcinc [aw=hhsize], save(Q1.2.1.doc)

asdoc sum income [aw=hhsize], save(Q1.2.2.doc)

/*Q 1.3: générez la variable intensité de la
pauvreté par habitant (pgap), puis estimez sa moyenne (l'intensité de la pauvreté///
parhabitant doit être normalisée par le seuil de pauvreté).*/

gen pline=120
gen     pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
asdoc sum     pgap [aw=hhsize], save(Q1.3.doc)

*Q 1.4: Refaites la question Q 1.3 en utilisant DASP
asdoc ifgt pcinc, pline(120) alpha(1) hsize(hhsize), save(Q1.4.doc)

/*Q 1.5:générez la variable (deflator) en tant qu'indice de déflation des prix,///
 puis générez la variable revenu réel par habitant (rpcinc).*/
 
gen     deflator = 1

*Changer la variable chaine "region" en variable numerique

gen Region = 1

replace Region =2 if region=="B"
replace Region =3 if region=="C"
replace deflator = 1.2 if Region== 2
replace deflator = 1.4 if Region==3
gen     rpcinc = pcinc/deflator

asdoc sum rpcinc [aw=hhsize], save(Q1.5.doc)

/*Q 1.6: Refaites les questions 1.3 et 1.4 en utilisant le revenu réel par habitant lorsque le seuil de
pauvreté est de 110.*/

replace pline=110
replace pgap = (pline-rpcinc)/pline if (rpcinc < pline)
sum     pgap [aw=hhsize]


asdoc ifgt rpcinc, pline(110) alpha(1) hsize(hhsize) save(Q1.6.doc)
*END============================================================================

*Exercice 2**************2.5%

clear all 
drop _all
set more off
*===============================================================================
cd "C:\Users\Kbir\Desktop\LAVAL2021\Semaine1&2"
use data_2
*===============================================================================

*2.1 commande DASP imean

asdoc imean ae_exp, hsize(hhsize), save(Q2.1.doc)

*2.2  initialisez le plan d'échantillonnage, puis estimez la dépense moyenne par équivalent adulte.

asdoc svydes, save(Q2.2.1.doc)

asdoc sum pcexp [aw= ae_exp], save(Q2.2.2.doc)

/*2.3 Vérifiez si la dépense moyenne par équivalent adulte dans la région 1 est supérieure
au double de celle de la région 3.*/

asdoc oneway ae_exp region, tab save(Q2.3.1.doc)

asdoc datest 2*27784.739 est (48255.709) ste (10.528651), save(Q2.3.2.doc)

/*2.4 vérifiez si la dépense moyenne par
équivalent adulte pour les chefs de ménage hommes est plus élevée que celle des
ménages dirigés par des femmes. Discutez brièvement vos résultats.*/

asdoc ttest ae_exp, by(sex) save(Q2.4.doc)
*==================================================================================

*exercice 3*********4.5%

*Q 3.1 Utilisez le fichier de données data_2.dta, puis calculez la taille de la population des ménages échantillonnés

asdoc total hhsize, save(Q3.1.doc)

/*Q 3.2 Ordonnez les dépenses par habitant en ordre croissant et générez ensuite la variable part de
population (ps) qui comprend la proportion de la population avec les dépenses par habitant
correspondantes. Sur cette base, générer les variables centiles (p) et quantiles (q).*/

*Ordonnez les dépenses par habitant en ordre croissant

order pcexp

*générez ensuite la variable part de population (ps)

gen ps = hhsize/14609

*générer les variables centiles (p) 

xtile p = ps, nq(100) 

*générer les variables quantiles (q)

xtile q = ps, nq(5)

/*Q3.5 En utilisant DASP, dessinez les courbes quantiles selon le sexe de la tête du ménage
(centiles (0 à 0,95)), et discutez brièvement les résultats.*/

clorenz pcexp, hgroup(sex) hsize(hhsize)

/*Q3.6 À l'aide du DASP, dessinez les courbes de densité des dépenses par habitant pour chacune
des régions rurales et urbaines (domaine des dépenses par habitant : min = 0 et maximum
= 1000000), et discutez brièvement des résultats. */


cfgtsm pcexp, alpha(0) hsize(hhsize) hgroup(zone) max(100000)
