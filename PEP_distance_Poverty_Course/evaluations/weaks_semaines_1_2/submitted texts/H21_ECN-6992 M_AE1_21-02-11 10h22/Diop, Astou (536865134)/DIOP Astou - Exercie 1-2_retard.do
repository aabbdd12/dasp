*************3%

                              *exercice 1***1%
cd "C:\Users\22177\Desktop\PEP oneline courses\exam semaine 1 et 2"

* Q1.2
mean pcinc
total pcinc

*Q1.3 Supposons que le seuil de pauvreté soit égal à 120. Générez la variable « intensité de la pauvreté par habitant (pgap) », puis estimez sa moyenne (l’intensité de la pauvreté par habitant devrait être normalisée par le seuil de pauvreté)*




                                 *exercice 3***2%

cd "C:\Users\22177\Desktop\PEP oneline courses\exam semaine 1 et 2"

* Q3.1 Utilisez le fichier de données data_3.dta, puis calculez la taille de la population des ménages échantillonnés
db svyset
svyset psu [pweight=hhsize], strata(strata) vce(linearized) singleunit(missing)
 
 svydes
 
 *Q3.2 Ordornnez les dépenses par habtiant en ordre croissant 
 db gsort
 sort pcexp
 
 * générer ps : variable part de la population qui comprend la proportion de la population échantillonnée avec les dépenses par habitant correspondantes
 gen ps = hhsize
 
 *génerer les variables centile (p) et quantiles (q)*
 
svyset psu [pweight=hhsize], strata(strata)
summarize pcexp, detail

*Q3.3 Courbe de distribution cumulative
db cusum

 *Q3.5 intaller DASP
 ssc install cqiv
 net from c:/dasp
 net install dasp_p1, force
 net install dasp_p2, force
 net install dasp_p3, force
 net install dasp_p4, force