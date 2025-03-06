
set more off

***Exercice 3 (4%)****3,5%
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