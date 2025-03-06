*********9.5%


**Exercice 1******3.5%
*Q1.1

*insertion des données dans Stata
clear
input hhid region income hhsize
1             1      310   4  
2             1      460   6
3             1      300   5           
4             1      220   3
5             2      560   2
6             2      400   4
7             3      140   3
8             3      250   2
9             3      340   2
10            3      220   2
end

*generer la variable revenu par habitant (pcinc)
gen pcinc=income/hhsize

*Q1.2
*estimation du revenu moyen par habitant
sum pcinc [aw=hhsize]

*estimation du revenu total de notre population
di r(sum)
*or 
gen revtot=sum(income)


*Q1.3
*generer la variable intensité de la pauvreté par habitant (pgap)
gen pline=120
gen pgap=0
replace pgap= (pline-pcinc)/pline if (pcinc<pline)

*estimer la variable intensité de la pauvreté moyenne 
sum pgap [aw=hhsize]

*Q1.4
* en utilisant DASP
ifgt pcinc, pline (120) alpha (1) hsize(hhsize)

*Q1.5
*generer la variable (deflator)
gen deflator=1
replace deflator=0.8 if region==2
replace deflator=0.6 if region==3

*generer la variable revenu reel par habitant rpcinc
gen rpcinc=pcinc/deflator 

*Q1.6
* refaire les questions 1.3 et 1.4 en utilisant le revenu réel par habitant lorsque le pauvreté est de 110
*le revenu réel moyen par habitant
sum rpcinc [aw=hhsize]
replace pline=110
replace pgap=(pline-rpcinc)/pline if (rpcinc<pline)
sum pgap [aw=hhsize]

*avec DASP
ifgt rpcinc, pline (110) alpha (1) hsize(hhsize)

save "C:\Users\LENOVO\OneDrive\Desktop\pep\2021 course\Assignments\EXO1_Isabel.dta"
save replace
clear

**Exercice 3**********5%

 clear
 use "C:\Users\LENOVO\OneDrive\Desktop\pep\2021 course\Assignments\data_2.dta"
 
*Q3.1
* calcul de la taille de la population des ménages échantillonés
gen pop_size= psu*

*Q3.2
*ordonner les dépenses par habitant en ordre croissant
 sort pcexp
 *générez la variable part de population (ps) 
 gen ps= hhsize/r(sum)
  *générer les variables centiles (p) et quantiles (q)
 gen p=sum( ps)
 gen q= pcexp
 
 *Q3.3
 *Dessinez la courbe de distribution cumulative 
line p pcexp, title(la courbe de distribution cumulative) xtitle(dépense par habitant) ytitle(F(Y))

**Q3.4
*Tracez la courbe quantile 
line q p, title(la courbe quantile) xtitle(centile (p)) ytitle(quantile (Q(p)))

**Q3.5
*dessinez les courbes quantiles selon le sexe de la tête du ménage 
codebook sex
gen pcexpM= pcexp if sex==1
gen pcexpF= pcexp if sex==2
c_quantile pcexpM, hsize( hhsize)
c_quantile pcexpF, hsize( hhsize)

**Q3.6
codebook zone
gen pcexpR= pcexp if zone==1
gen pcexpU= pcexp if zone==2
**pour zone rurale
cdensity pcexpR ,hs(hhsize) min(0) max(1000000)
**pour zone urbaine
cdensity pcexpU ,hs(hhsize) min(0) max(1000000)
 save "C:\Users\LENOVO\OneDrive\Desktop\pep\2021 course\Assignments\exo3 Isabel.dta"
 save replace
 clear
 
 ***Exercice 2********1%
 
use "C:\Users\LENOVO\OneDrive\Desktop\pep\2021 course\Assignments\data_2.dta"

*estimez les dépenses moyennes par équivalent adulte sans utiliser le poids de sondage et en utilisant la commande DASP imean
 imean ae_exp, hsize (hhsize)

