***********10%


****************************3%
// Q1
/* Importing the data */ 
import excel "C:\Users\Admin\Documents\Course-PEP\Cours_PEP_21\Analyse_Pauv\Donnees_Exercice1&2.xlsx", sheet("Exo1") firstrow 

//Q1.1
/* Generating the variable per capita income */
gen pcinc = income/hhsize

// Q1.2:
/* Estimating the average per capita income */
sum pcinc [aw=hhsize]

// Q1.3:
gen    pline = 100
gen     pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
sum pgap [aw=hhsize]

// Q1.4:
ifgt pcinc, pline(100) alpha(1) hsize(hhsize)

// Q1.5:
gen deflator = 1
replace deflator = 0.9 if region == 2 /*replace deflator = 1.1 if region == 2*/
replace deflator = 0.7 if region == 3 /*replace deflator = 1.3 if region == 3*/
gen rpcinc = pcinc/deflator

// Q6
sum rpcinc [aw=hhsize]
replace pline = 120
replace pgap = (pline-rpcinc)/pline if (rpcinc < pline)
sum pgap [aw=hhsize]
ifgt rpcinc, pline(120) alpha(1) hsize(hhsize)
 
//Stata code for the Practical exercise 2****3%
clear
clear
use "C:\Users\Admin\Documents\Course-PEP\Cours_PEP_21\Analyse_Pauv\Semaines_I_II\data_1.dta"

// Q1.1
/* Estimating of total expenditures per capita mean*/
imean pcexp, hsize(hhsize) /*use ae_exp instead of pcexp*/ 

// Q1.2
/* Estimating of total expenditures per capita mean case by case*/
svyset _n, strata(strata) vce(linearized) singleunit(missing)
imean pcexp, hsize(hhsize)
/*Cas 1*/
svyset psu, vce(linearized) singleunit(missing)
imean pcexp, hsize(hhsize)
/*Cas 2*/
svyset psu, strata(strata) vce(linearized) singleunit(missing)
imean pcexp, hsize(hhsize)
/*Cas 3*/
svyset psu, strata(strata) vce(linearized) singleunit(missing)
imean pcexp, hsize(hhsize)
/*Cas 4*/
svyset psu, strata(strata) vce(linearized) singleunit(pw)
imean pcexp, hsize(hhsize)
// Q1.3
/* comparing total expenditures per capita mean by group*/
imean pcexp, hsize(hhsize) hgroup(zone) /*imean ae_exp , hsize(hhsize) hg(region)*/

// Q1.4
/* comparing total expenditures per capita mean by sex*/
imean pcexp, hsize(hhsize) hgroup(sex) /*dimean ae_exp ae_exp, hsize1(hhsize) test(0) cond1(sex==2 ) hsize2(hhsize) cond2(sex==1 )*/


//Stata code for the Practical exercise 3***4,5%

clear
use "C:\Users\Admin\Documents\Course-PEP\Cours_PEP_21\Analyse_Pauv\Semaines_I_II\data_1.dta"
// Q3.1
power onemean 138627 140000, sd(4280.26)
// Q3.2
sort pcexp
/* generating the variable of the proportion ofpopulation */
sum pcexp
gen ps = pcexp/r(sum) /*gen ps = hhsize/r(sum)*/

/* generating the variable percentile and the quantiles */
gen p = sum(ps)
gen q = pcexp
list, sep(0)

// Q3.3
line p pcexp /*if p<0.95*/, title(The cumulative distribution curve) xtitle(F(y)) ytitle(The per capita income (y)F(y))
// Q3.4
line q p  /*if p<0.95*/, title(The quantile curve) xtitle(the percentile (p)) ytitle(The quantile Q(p))
// Q3.5
gen p_u=p if zone ==1
gen p_r=p if zone ==2
gen q_u=p if zone ==1
gen q_r=p if zone ==2
line q_u p_u , title(The quantile curve) xtitle(the percentile (p)) ytitle(The quantile Q(p))

line q_r p_r , title(The quantile curve) xtitle(the percentile (p_r)) ytitle(The quantile Q(p_r)) 

/*c_quantile pcexp, hsize(hhsize) min(0) max(0.95) hgroup(zone)*/

// Q3.6
cdensity pcexp , hs(hhsize) min(0) max(1000000) /*hg(sex) band(25000)*/