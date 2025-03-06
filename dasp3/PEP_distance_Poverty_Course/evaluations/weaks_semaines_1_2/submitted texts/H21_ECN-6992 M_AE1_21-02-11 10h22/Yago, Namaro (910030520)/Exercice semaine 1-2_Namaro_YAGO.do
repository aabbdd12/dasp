****************11.5%


clear all
** repertoire de travail 
cd "C:\Users\nyago\Documents\PERSO\PEP Laval\DEV1\"

** importation des données via excel
import excel dataexo1.xlsx, sheet("Feuil1") firstrow
save dataexo1.dta,replace 

**Q1.1***********3.5%
gen pcinc=income/hhsize

***Q1.2
* moyenne du revenu par tête
sum pcinc [aw=hhsize]

** estimation du total de revenu
global  Rtot r(sum)
display $Rtot

**Q1.3 intensité de la pauvreté par habitant
global pline 100
gen  pgap=0
replace  pgap=($pline-pcinc)/$pline  if pcinc<$pline

** estimation de sa moyenne
sum pgap [aw=hhsize] 


**Q1.4  
ifgt pcinc, pline(100) alpha(1) hsize(hhsize)

**Q1.5 
**déflateur
gen deflator=1 if region=="A"
replace deflator=0.9 if region=="B"
replace deflator=0.7 if region=="C"

**revenu réel par habitant
gen rpcinc=pcinc/deflator

*Q1.6  calcul à base du revenu réel 

*Q1.3bis intensité de la pauvreté par habitant
global pline_r 120
gen  pgap_r=0
replace  pgap_r=($pline_r-rpcinc)/$pline_r  if rpcinc<$pline_r

** estimation de sa moyenne
sum pgap_r [aw=hhsize] 


**Q1.4bis  
ifgt rpcinc, pline(120) alpha(1) hsize(hhsize)


***Exercice 2*********3%
use data_1,clear

*Q1.1  Nous supposons que pcexp est estimé en équivalent adulte

* moyenne de la dépense par équivalent adulte sans le poids de sondage: sens: moyenne sur l'échantillon
sum ae_exp[aw=hhsize]

** DASP
imean ae_exp, hs(hhsize)


**Q1.2 

*CAS1
svyset _n, strata(strata) 
gen numerator=hhsize*ae_exp
gen denominator=hhsize
svy: ratio numerator/denominator

**cas 2
 svyset psu
svy: ratio numerator/denominator


**Cas 3
svyset psu, strata(strata) 
svy: ratio numerator/denominator


**Cas4: 
gen fweight=sweight*hhsize
svyset psu [pweight=fweight], strata(strata) 
svy: ratio numerator/denominator


*Q1.3  Il manque la variable region dans la base

table region [aw= fweight],c(mean ae_exp) row

** calcul du rapport des moyennes des deux régions.
sum ae_exp [aw=fweight] if region==1
scalar m1=r(mean)

sum ae_exp [aw=fweight] if region==3
scalar m3=r(mean)

scalar rapport13=m1/m3

display rapport13

*** pour comparaison  des positions des régions : pcexp vs ae_exp.
table  region [aw=fw], c(mean pcexp ) row


*Q1.4  : 
dimean ae_exp ae_exp, hsize1(hhsize) test(0) cond1(sex==2) hsize2(hhsize) cond2(sex==1) conf(ub)




***Exercice 3 ***********5.5%

**Q3.1  
sum hhsize
global tpop r(sum)
displa $tpop

*Q3.2  
sort pcexp
gen ps=hhsize/$tpop
gen p=sum(ps)
gen q=pcexp

**Q3.3 
preserve 

keep if p<=0.95

line p q, title(courbe de distribution cumulative) xtitle(dépenses par habitant)  ytitle(centiles (P)) ylab(0(.1) 0.95,ang(hor)) xlab(0 (50000 ) 400500)

restore 


**Q3.4 
keep if p<=0.95
line q p, title(courbe des quantiles)  xtitle(centiles (P))  ytitle(dépenses par habitant) xlab(0(.1) 0.95,ang(hor)) ylab(0 (50000 ) 400500)

restore 


**Q3.5

c_quantile pcexp, hs(hhsize) hgroup(zone) min(0) max(0.95)

***Q3.6

cdensity pcexp, hsize(hhsize) hgroup(sex) popb(1) type(den) min(0) max(1000000) ytitle(Fréquences) xtitle(depenses par tête) title(Courbe de densité des dépenses par habitant en fonction du sexe du CM)






