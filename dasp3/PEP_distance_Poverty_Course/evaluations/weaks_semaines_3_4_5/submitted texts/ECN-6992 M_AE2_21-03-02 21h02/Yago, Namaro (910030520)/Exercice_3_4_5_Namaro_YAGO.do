******************12,5%


***Exercice 1************4%
clear all
input  group inc1 inc2 inc3
1 1 8 2
1 2 8 4
1 9 8 18
2 3 24 2
2 6 24 4
2 27 24 18
end

**1.1 Elements de calcul pour repondre aux affrmations

**** a) calcul de 'indice de gini par groupe'
igini inc1, hg(group)


**c) calculons la moyenne des groupe pour chacune des distributions
table group, c(mean inc1 mean inc2)

** decomposition  de l'inégalité par dentropyg
dentropyg inc1, theta(0) hgroup(group)
dentropyg inc2, theta(0) hgroup(group)


**1.2 - décomposition des inégalités par groupes pour toutes les distributions de revenus
foreach var of varlist inc1 inc2 inc3 {
    display "Decomposition inegalite pour `var'"
   	dentropyg `var', theta(0) hgroup(group)
                }
				

*1.3 Calcul des indices d'inégalités des trois distributions
igini inc* 


***Exercice 2*************5,5%

clear all

**2.1 ENTREE DONNEES
input identifier  Pre_tax_income  hhsize  nchild

1 240 4 2
2 600 5 3
3 230 3 2
4 1250 3 1
5 1900 4 1 
6 280 4 2
7 620  3 1
8 880  4 3 
end

**Creations des variables
scalar tax=0.1
scalar Tpop=30
scalar Tnchild=15
 
** Generons les différents revenus 

** revenu apres imposition par tête 
gen pcincatA=(1-tax)*Pre_tax_income/hhsize
label var pcincatA "revenu après impôt par habitant avec le scénario A"

gen pcincatB=(1-tax)*Pre_tax_income/hhsize
label var pcincatB "revenu après impôt par habitant avec le scénario B"

**verification de la somme des revenus
sum Pre_tax_income
display r(sum)

** calcul du revenu universel/tête 60% des impots (Scenario A)
gen pcuincA=tax* r(sum)*0.6/Tpop
label var pcuincA "revenu universel par habitant avec le scénario A"

*** pas de revenu universel (0 pour tous les menages)
gen pcuincB=0
label var pcuincB "revenu universel par habitant avec le scénario B"

***calcul de l'allocation par enfant : 40% des impots collectés (scenario A)
gen pcallowA=tax* r(sum)*0.4/Tnchild
label var pcallowA "allocations familiales par enfant avec le scénario A"

***calcul allocation par enfant : totalité des impôts collectés (scenario B)
gen pcallowB=tax* r(sum)/Tnchild
label var pcallowB "allocations familiales par enfant avec le scénario B"

** reconstitution du revenu du ménage pour le calcul du revenu par tête: 
**NB: Il faut avoir les allocations par habitant pour une addition simple

gen dpcincA= (pcincatA*hhsize +pcuincA*hhsize+pcallowA*nchild)/hhsize
label var dpcincA "revenu disponible par habitant avec le scénario A "
gen dpcincB=(pcincatB*hhsize +pcuincB*hhsize+pcallowB*nchild)/hhsize
label var dpcincB"revenu disponible par habitant avec le scénario B "

***verification du total du revenu apres les politiques (doit être le même avant les politiques )
sum dpcincA [aw=hhsize]
display r(sum)
sum dpcincB  [aw=hhsize]
display r(sum)


**2.2 Inégalité dans les deux scenarios

igini dpcincA dpcincB, hs(hhsize)

** inegalite avant impot pour comparaison
gen dpcinc=Pre_tax_income/hhsize

igini dpcinc,hs(hhsize)

** etude de la variation de l'indice entre les deux scenarii
digini dpcincA dpcincB, hs(hhsize)

** 2.3 decomposition des inegalites selon la source de revenus
**construction de l'allocation par habitant 
preserve
replace pcallowA=pcallowB*nchild/hhsize
replace pcallowB=pcallowB*nchild/hhsize

*** decomposition des inégalités
diginis pcincatA pcuincA pcallowA, hs(hhsize)

diginis pcincatB pcuincB pcallowB, hs(hhsize)
restore 

*** 2.4  recherche de la politique optimale de réduction des inégalités

** recherche du seuil de revenu à partir duquel appliquer la fiscalité pour avoir 600 comme impot au total
 gsort -dpcinc
  gen total_collect_taxes = 0 in 1
  replace total_collect_taxes = sum((dpcinc[1]*hhsize[1]-dpcinc*hhsize)) in 2/8 
  list dpcinc Pre_tax_income total_collect_taxes  hhsize, separator(0)
  
  ** on lit que pour 650 au rang 2. Pour que les deux plus riches aient le meme niveau de vie après impots (effets de la taille des ménages a prendre en compte par la résolution d'un système  d'equations linéaires à deux inconnus: equation 1:égalité du revenu par tete apres impots ; equation 2: somme des impots payés=600'): On trouve que imposant les deux ménages plus riches respectivement à 442,85 et 157,15 respectivement on a les 600 d'impots et leur revenu par tête est égal à 364.28.  

  * montant taxe preleve sur chacun des deux premier ménages
  gen tax=442.85 in 1
  replace tax=157.15 in 2
  replace tax=0 in 3/8
  
  * netoyage fichier  variable instrumentale
  drop total_collect_taxes
  
  ***************
 * calcul du revenu des transferts qui egalise les revenus faibles/tête
sort dpcinc 

***initialisation des transfers recus à 0
gen transfer = 0

*** initialisation du total des transferts
local  total_transfers=0


local  limit=0 // la limite est le revenu/tête de la personne la
//moins pauvre qui recevra les transferts


while `total_transfers' < 600 {
qui replace transfer=max(0, (`limit'-Pre_tax_income/hhsize)*hhsize)
qui sum transfer
local total_transfers=r(sum)
local limit = `limit'+1
       }

list Pre_tax_income transfer, sep(0)

*** revenu apres impot et redistribution

gen incomeTax2=Pre_tax_income-tax+transfer
 
 gen pcincomeTax2=incomeTax2/hhsize
 
 igini pcincomeTax2, hs(hhsize)
 
 ** netoyage du fichier des variables de travail
 
drop tax  transfer  incomeTax2

** 2.5 calcul du taux de pauvreté
 
 **incidence
difgt dpcincB dpcinc , hsize1(hhsize) alpha(0) hsize2(hhsize) pline1(100) pline2(100)

**2.6 intensité
difgt dpcincB dpcinc , hsize1(hhsize) alpha(1) hsize2(hhsize) pline1(100) pline2(100)


*** Exercice 3*************3%
cd "C:\Users\nyago\Documents\PERSO\PEP Laval\DEV2\"

**3.1
use data_1.dta,clear
svyset psu [pweight=sweight], strata(strata)

*3.2 Taux de pauvreté 

ifgt ae_exp, hs(hsize)  pline(21000)  


*3.3 le taux de pauvreté par sex du CM
ifgt ae_exp, hs(hsize)  hg( sex) pline(21000)

 ** courbe de pauvreté en fonction du seuil
 cfgt ae_exp, hs(hsize) hgroup(sex) alpha(0) min(0) max(75000) xlab(0 (10000) 75000)


