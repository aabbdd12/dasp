 ************9%
 
 *Q3.5 intaller DASP
 ssc install cqiv
 net from c:/dasp
 net install dasp_p1, force
 net install dasp_p2, force
 net install dasp_p3, force
 net install dasp_p4, force
 
                   ***** exercice 1*****3%
				   
*** 1.1	Pour la distribution inc1, indiquez si les affirmations suivantes sont vraies ou fausses, et pourquoi.

 ** a-	Basé sur le principe d'invariance d'échelle, l'inégalité de revenu du groupe 1 est égale à celle du groupe 2. Entrez les données et confirmez vos justifications en estimant le coefficient de Gini par groupe de population.  
igini inc1

  ** c-	L'inégalité entre les groupes de inc1 est égale à celle de inc2. En outre, vérifiez ceci en utilisant la commande dentropyg dans DASP (par exemple, pour theta = 0).
dientropy inc1 inc2

*** 1.3 Estimer l'inégalité de gini pour chacune des trois distributions
igini inc1 inc2 inc3

                        ***** exercice 2****3%
*** 2.1	En utilisant Stata, entrez les données (les huit observations), puis générez les variables :

** Scenario A
gen impot = 0.1*pre_tax_income
gen pcincatA = pre_tax_income - impot
total impot in 1/8
gen taxe = impot in 9
gen uinc = 0.6*taxe
gen pcuincA = uinc/8
gen allowA = taxe-uinc
gen pcallowA = allow/8
gen dpcincA = pcincatA+pcuincA1+pcallowA

** Scenario B
gen impot = 0.1*pre_tax_income
gen pcincatB = pre_tax_income-impot
total impot in 1/8
gen pcallowB = mean impot
gen dpcincB = pcuincatB+pcallowB


                         ***** exercice 3****3%
						 
*** 3.1	Chargez le fichier data_3, puis initialisez le plan d'échantillonnage avec les variables strata, psu et sweight. 
 
 svyset psu [pweight=hsize], strata(strata) vce(linearized) singleunit(missing)
 
 *** 3.2	À l'aide de la commande DASP ifgt, estimez le taux de pauvreté lorsque la mesure du bien-être correspond aux dépenses par équivalent adulte, et lorsque le seuil de pauvreté est égal à 21 000.

 ifgt ae_exp, alpha(0) pline(21000)
 ifgt ae_exp, alpha(1) pline(21000)
 ifgt ae_exp, alpha(2) pline(21000)

 
 *** 3.3	Estimez maintenant le taux de pauvreté par groupes de population (définie par le sexe du chef de ménage) et discutez vos résultats.
 
 ifgt ae_exp, alpha(0) hgroup(sex) pline(21000)
 ifgt ae_exp, alpha(1) hgroup(sex) pline(21000)
 ifgt ae_exp, alpha(2) hgroup(sex) pline(21000)