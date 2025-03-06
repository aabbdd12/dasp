****************10%
set more off

***Exercice 3 (4%)****4%
*****Q3.1 A l'aide des observations de 2005, estimez l’espérance des taux marginaux d'impôts, de bénéfices et de revenus nets pour la plage de revenus bruts comprise entre 1 000 et 31 000 $ (astuces : utilisez la commande DASP cnpe avec l'option : type(dnp))******
preserve
keep if year==2005
cnpe T B N , xvar(X) min(1000) max(31000) type(dnp)
graph save "Graph" "C:\Users\Isabelle BECHO\Dropbox\Mon PC (DESKTOP-PJCJ5KR)\Documents\COURS PEP\cours et homework pauvreté\Devoir 4 pauvrete\Graph cnpe exo3.gph"
restore

****Q3.2 Estimez l’impact redistributif sur l’indice d’inégalité de Gini pour 1999, 2002 et 2005 (astuce : utilisez les commandes Stata preserve/restore conserver les données après avoir utilisé la commande Stata “keep if year==…”).
preserve
keep if year==1999
igini X T B N
restore
preserve
keep if year==2000
igini X T B N
restore
preserve
keep if year==2005
igini X T B N
******Q3.3 Estimez l'indice de progressivité de Kakwani par an à l'aide de la commande DASP iprog (astuce : utilisez l’option gobs(year)).
restore
preserve
iprog T B N, ginc(X) gobs(year) index(ka)
******3.4 À l'aide des observations de 2005, vérifiez la condition de TR progressivité pour la taxe T à l'aide de la commande DASP cprog***********
keep if year==2005
cprog T, rank(X) type(t) appr(tr)
******Q3.5. Dans quelle province l'inégalité était-elle la plus élevée en 2005 ? Dans quelle province l’indice de progressivité fiscale de Kakwani était-il le plus élevé de 2005 ?
******Dans quelle province l'inégalité était-elle la plus élevée en 2005 ?****************
igini X T B N, hgroup(province)
******Dans quelle province l’indice de progressivité fiscale de Kakwani était-il le plus élevé de 2005 ?****
iprog T B N, ginc(X) gobs(province) type(t) index(ka)





***Exercice 1 (4.5%)*********************************4%

input individu w_1 w_2 w_3
  1 1 5 3
  2 2 3 0
  3 4 4 6
  4 3 3 4
  5 7 5 4
  6 6 4 3
 end


***Q1.1 En utilisant l'approche de l’union, estimez la proportion d'individus pauvres. Refaites l'estimation à l'aide de la commande DASP appropriée********

ge pauvreunio=1 if w1<=3.5 |w2<=3.5| w3<=3.5
replace pauvreunio=0 if pauvreunio==.
ta pauvreunio

*estimation à l'aide de la commande DASP
imdp_uhi w1 w2 w3, pl1(3.5) pl2(3.5) pl3(3.5)

*Q1.2 En utilisant l'approche par intersection, estimez la proportion d'individus pauvres. Refaites l'estimation à l'aide de la commande DASP appropriée. 
ge pauvre_intersec=1 if w1<=3.5 & w2<=3.5 & w3<=3.5
replace pauvre_intersec=0 if pauvre==.
ta pauvre_intersec

*estimation à l'aide de la commande DASP
imdp_ihi w1 w2 w3, pl1(3.5) pl2(3.5) pl3(3.5)


 **Q1.4 Estimez l’indice Alkire et Foster MPI(α=0) lorsque le seuil dimensionnel est égal à 2 (les pauvres sont ceux qui ont deux ou trois dimensions de privation).
 
 
 
***Q1.5 Estimez maintenant les mêmes indices à l'aide de la commande DASP appropriée. Discutez des résultats. 
 
imdp_afi w1 w2 w3, dcut(2) w1(1) pl1(3.5) w2(1) pl2(3.5) w3(1) pl3(3.5)

*Q1.6 Supposons que le gouvernement dispose de 6 $ et puisse cibler une dimension à l’aide d’un transfert universel. Quelle dimension ciblée réduirait le plus l'indice d'union et l'indice d'intersection ? 


 ********************Exercice 2 (4%)**************************2%

********Q2.1. Estimez l’indice de pauvreté de Bourguignon et Chakravarty (2003) lorsque β_i=1/3  ∀ i,〖 z〗_i=3.5 ∀ i,   α=1 et ρ=1********



*Q2.2 Refaites l'estimation à l'aide de la commande DASP appropriée.
imdp_bci w1 w2 w3, alpha(1) gamma(1) b1(0.33) pl1(3.5) b2(0.33) pl2(3.5) b3(0.33) pl3(3.5)



**Q2.3 Générez trois nouvelles variables (nw_ *) dans lesquelles les individus égalisent leurs dimensions de bien-être .
ge nw1= ( w1+ w2+ w3)/3