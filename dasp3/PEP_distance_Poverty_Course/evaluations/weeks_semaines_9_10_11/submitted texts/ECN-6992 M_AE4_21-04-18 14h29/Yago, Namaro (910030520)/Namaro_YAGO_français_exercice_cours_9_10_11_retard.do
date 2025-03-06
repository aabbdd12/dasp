*************12,5%
clear all

set obs 6
qui input  str10 individus w1 w2 w3
           "individu 1"     1 5 3
           "individu 2"  	2 3 0  
           "individu 3"     4 4 6
		   "individu 4"     3 3 4
		   "individu 5"     7 5 4
		   "individu 6"     6 4 3

*Q11 calcul du taux de pauvres par l'approche Union
gen pauvre=(w1<3.5|w2<3.5|w3<3.5)
sum pauvre 
drop pauvre
**On trouve que 2/3 de la population est pauvre.

*Utilisation de commande DASP
 imdp_uhi  w1 w2 w3, pl1(3.5) pl2(3.5) pl3(3.5) alpha(0)


 *Q1.2 Approche intersection 
 
 gen pauvre=(w1<3.5&w2<3.5&w3<3.5)
 sum pauvre 
 drop pauvre
 
 * par DASP 
  imdp_ihi  w1 w2 w3, pl1(3.5) pl2(3.5) pl3(3.5) alpha(0)

  *Q1.3 Approche par Union est plus sensible à l'augmentation des privations multiples individuelles
  
  *Q1.4  Estimation de l'indice de Alkire et FOSTER
  
  forvalues i=1/3 {
  	gen w`i'_p=(w`i'<3.5)
	
  }
  egen numberdim=rsum(w1_p w2_p w3_p)
  
  *Alkire et Foster H0 :le seuil inter-dimensionnel « dual » est égal à 2                                              
 gen    af_poor        =  (numberdim>=2) 
 
 * Alkire et Foster M0 
 gen  w_af_poor        =  (numberdim /3)* af_poor 

/* Alkire et Foster H0 et M0 */
mean af_poor w_af_poor 

*** L"indice de  AlKIRE et  Foster MPI (a=0)  fait 0.5 (la moitié des individus sont pauvres)

*Q1.5  Estimation par DASP 

imdp_afi w1 w2 w3 , dcut(2) w1(1) pl1(3.5) w2(1) pl2(3.5) w3(1) pl3(3.5)

** On trouve 50% de pauvres sans pondérations et 38,9% de pauvres en considérant la pondération par le nombre de privations. On trouve en moyenne 2.33 dimensions de privations pour les pauvres.


**Q1.6  Calcul des contributions des dimensions au taux de pauvreté selon les deux approches (Union et Intersection)

*indice d'union
imdp_afi w1 w2 w3 , dcut(1) w1(1) pl1(3.5) w2(1) pl2(3.5) w3(1) pl3(3.5)

** indice d'intersection

imdp_afi w1 w2 w3 , dcut(3) w1(1) pl1(3.5) w2(1) pl2(3.5) w3(1) pl3(3.5)




***Exercice  2

*Q2.1
clear all

set obs 6
qui input  str10 individus w1 w2 w3
           "individu 1"     1 5 3
           "individu 2"  	2 3 0  
           "individu 3"     4 4 6
		   "individu 4"     3 3 4
		   "individu 5"     7 5 4
		   "individu 6"     6 4 3
		   
* fixation des parametres
scalar beta1 =1/3
scalar beta2=1/3
scalar beta3=1/3
scalar z1=3.5
scalar z2=3.5
scalar z3=3.5
scalar e=1
scalar alpha=1

gen ngap1 = (z1-w1)/z1*(z1>w1) // l'écart de pauvreté de dimension 1 
gen ngap2 = (z2-w2)/z2*(z2>w2) // l'écart de pauvreté de dimension 2 
gen ngap3= (z3-w3)/z3*(z3>w3) // l'écart de pauvreté de dimension 3


gen pi=(beta1*(ngap1)^e + beta2*(ngap2)^e+beta3*(ngap3)^e)^(alpha/e) 

** Indice Bourguignon et Chakravarty:
qui sum pi 
scalar MDI_BC = r(mean) 
disp    MDI_BC

**Q2.2 
***COMMANDE DASP DE CALCUL DE l'INDICE Bourguignon  et Chakravarty:
 imdp_bci  w1 w2 w3, pl1(3.5) pl2(3.5) pl3(3.5) b1(0.3333) b2(.3333) b3(.3334) alpha(1) gamma(1)
 
 *** on trouve le même indice : MDPBC=0.159
 
 *Q2.3 Egalisation des dimensions 
 
 forvalues i=1/3{
 	egen nw_`i'=rmean(w1 w2 w3)
 }
 
  imdp_bci  nw_1 nw_2 nw_3, pl1(3.5) pl2(3.5) pl3(3.5) b1(0.3333) b2(.3333) b3(.3334) alpha(1) gamma(1)

  **  L'indice   MDI_BC chute a 0.119 . La chute s'explique par la substitution entre les dimensions opéré par cette opération de moyenne. 
  
  
  
  **Exercice 3
  clear all
  cd "C:\Users\nyago\Documents\PERSO\PEP Laval\DEV4\"
  use Canada_Incomes&Taxes_1996_2005_random_sample_1.dta,clear
  
  ** plan d'echantillonnage : pas de strates , pas d'unité primaire
  svyset _n [pweight= sweight]
  
  ***Q3.1 faisons la regression non parametrique entre l'impot, le bénéfice , le revenu net  et le revenu brut pour la tranche specifiée (2005)
  

 preserve 
 keep if year==2005
 cnpe T B N, xvar(X) hs(hhsize)  type(dnp) min(1000) max(31000) 
 save dnpgraph, replace
 restore 


	*** Q3.2  Calcul de l'indice de GINI pour le revenu Brut et le Revenu net
	local acode  1999 2002 2005 
	foreach i of local acode {
		preserve 
		keep if year==`i'
		igini X N , hs(hhsize)
		restore
	}

	
	
	***Q3.3 Calcul de l'indice de progressivité de KAKWANI par année
	
	iprog T  , hs(hhsize) gobs(year) ginc(X)
	
	** Q3.4  Verification de la TR progressivité de T  pour l'année 2005
	preserve
	keep if year==2005
	cprog T, rank(X)  hs(hhsize) type(t) appr(tr)
	restore
	** Impot n'est pas TR-progressif  car pour les percentiles faibles, on a  l'indice négatif.
	
	***Q3.5  calcul des indices de GINI et de  progressivité de KAKWANI par province en 2005
	preserve 
	keep if year==2005
	igini X, hs(hhsize) hg(province)
	igini N, hs(hhsize) hg(province)
	
	*** Newfoundland   est la province où l'inégalité est la plus élevé. GINI=0.49 contre 0.43 pour la moyenne nationale
		
		***Q3.3 Calcul de l'indice de KAKWANI
	
	iprog T, hs(hhsize) gobs(province) ginc(X)
	
	restore	
	 