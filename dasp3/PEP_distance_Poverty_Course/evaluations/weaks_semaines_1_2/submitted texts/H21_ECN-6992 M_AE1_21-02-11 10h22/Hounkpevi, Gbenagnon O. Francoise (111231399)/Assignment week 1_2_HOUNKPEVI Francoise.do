**********************5%


*Exo 1**************4%
import excel "C:\Users\lasta\OneDrive\Desktop\fiche1.xlsx", sheet("Feuil1") firstrow

*****Q 1.1: Using Stata, generate per capita income (pcinc).

gen pcinc= income/ hhsize

*****Q 1.2: Using Stata, estimate the average per capita income and the total income of our population.

sum pcinc

sum income




*******Q 1.3
gen pline = 120 
gen pgap = 0 
replace pgap = (pline-pcinc)/pline if (pcinc < pline) 
sum pgap [aw=hhsize]

***ad DASP to STATA MENU
_daspmenu

******Q1.4
ifgt pcinc, pline(120) alpha(1) hsize(hhsize)

*******Q1.5

gen deflator = 1 
replace deflator = 1.2 if region == 2 
replace deflator = 1.4 if region == 3 
gen rpcinc = pcinc/deflator

*******Q1.6 Redo 1.3

sum rpcinc [aw=hhsize]
replace pline = 110 
replace pgap = (pline-rpcinc)/pline if (rpcinc < pline) 
sum pgap [aw=hhsize]

*******Q1.6 Redo 1.4
ifgt rpcinc, pline(110) alpha(1) hsize(hhsize)




*******************************Exercise 2***********************************************1%
clear
use "C:\Users\lasta\OneDrive\Documents\PEP_2\ONLINE COURSE PAUVRETE\data_2.dta"

********2.1	Using the file data_2, estimate the average per adult equivalent expenditures 

imean ae_exp
 
 
 ******Q2.3.
 
 sum ae_exp if region ==1
 sum ae_exp if region ==3
 
 
 
 