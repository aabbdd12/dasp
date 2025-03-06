***********12%

_daspmenu
cd "/Users/rafaeldias/OneDrive - Université Laval/economia/2021/Pauvrete et inegalite ECN6992/data/"

***************************************************************************
//code Stata : Évaluation | Rafael Dias | Exercice 6-7-8 | 23 mars
***************************************************************************

//  EXERCICE 1
clear
use data_b3_3.dta

// Q1.1
cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)                      ///
legend(order( 1 "Observed well-being" 2 "Perceived  minimum  well-being "))  ///
subtitle("") title(The subjective poverty line)        					     ///
 xtitle(Observed well-being)                       							 /// 
 ytitle(Predicted level of the perceived  minimum  well-being )              ///
 vgen(yes)

cap drop dif
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) xval(0) vgen(yes)
*22692.876953

cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)                      ///
legend(order( 1 "Observed well-being" 2 "Perceived  minimum  well-being "))  ///
subtitle("") title(The subjective poverty line)            ///
xline(22692.88) xtitle(Observed well-being)            /// 
ytitle(Predicted level of the perceived  minimum  well-being ) 

// Q1.2
ifgt  ae_exp, alpha(1) hsize(hsize) pline(22692.88)
ifgt  ae_exp, alpha(1) hsize(hsize) pline(20900)
ifgt  ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)


// Q1.3
*seuil de pauvreté relative

***************************************************************************

//  EXERCICE 2
clear
use data_b3_3.dta

// Q2.1
dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20900) 
/*+-----------------------------------------------------------------------------------+
  |          Group   |      FGT index     Population       Absolute        Relative   |
  |                  |                       share       contribution    contribution |
  |------------------+----------------------------------------------------------------|
  |Male              |        0.336161        0.754545        0.253648        0.694339|
  |Female            |        0.454912        0.245455        0.111661        0.305661|
  |------------------+----------------------------------------------------------------|
  |Population        |        0.365309        1.000000        0.365309        1.000000|
  +-----------------------------------------------------------------------------------+*/

// Q2.2
dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(20900)
/*+-----------------------------------------------------------------------------------+
  |          Group   |      FGT index     Population       Absolute        Relative   |
  |                  |                       share       contribution    contribution |
  |------------------+----------------------------------------------------------------|
  |central           |        0.224916        0.268071        0.060293        0.165048|
  |eastern           |        0.307212        0.266545        0.081886        0.224155|
  |northern          |        0.721940        0.217543        0.157053        0.429918|
  |western           |        0.266609        0.247841        0.066077        0.180879|
  |------------------+----------------------------------------------------------------|
  |Population        |        0.365309        1.000000        0.365309        1.000000|
  +-----------------------------------------------------------------------------------+
*/

// Q2.3
gen ae_exp2 = ae_exp 
replace ae_exp2 = ae_exp*1.11 if region==3
replace ae_exp2 = ae_exp*0.94 if region==2

// Q2.4 Shapley
dfgtgr ae_exp ae_exp2, alpha(1) pline(20900)
/*                    |  Shapley approach                                             
  --------------------+----------------------------------------------------------------
      Growth          |        0.001021        0.000290        0.000452        0.001589
      Redistribution  |       -0.004932        0.001063       -0.007018       -0.002846
  -------------------------------------------------------------------------------------*/

// Q2.5
itargetg ae_exp, alpha(1) pline(20900) hsize(hsize) hgroup(region) constam(1)
/*+---------------------------------------------------------------------------+
  |  Group   |   Population         FGT index      Impact on        Impact on |
  |          |      Share                           Group          Population |
  |----------+----------------------------------------------------------------|
  |central   |     0.268070787     0.053819198    -0.000010762    -0.000002885|
  |eastern   |     0.266545475     0.096069150    -0.000017745    -0.000004730|
  |northern  |     0.217542857     0.281127125    -0.000032408    -0.000007050|
  |western   |     0.247840881     0.060874887    -0.000012756    -0.000003162|
  |----------+----------------------------------------------------------------|
  |Population|     1.000000000     0.116278633    -0.000017826    -0.000017826|
  +---------------------------------------------------------------------------+*/


***************************************************************************

//  EXERCICE 3
clear

// Q3.1

input id	weight	inc_t1	inc_t2
0	0		0.00	0.00
1	0.1		1.50	1.54
2	0.1		4.50	3.85
3	0.1		7.50	6.60
4	0.1		3.00	2.75
5	0.1		4.50	4.40
6	0.1		9.00	7.70
7	0.1		10.50	8.80
8	0.1		15.00	7.70
9	0.1		12.00	6.60
10	0.1		13.50	6.60
end

sort inc_t1
gen perc=sum(weight)
list perc

// Q3.2
qui sum inc_t1 [aw=weight]   
scalar mean1=r(mean)         			

qui sum inc_t2 [aw=weight]
scalar mean2=r(mean) 

scalar g_mean = (mean2-mean1)/mean1	
gen g_mean  = (mean2-mean1)/mean1    	

dis "Mean 1              =" mean1
dis "Mean 2             = " mean2
dis "taux de croissance du revenu moyen = " g_mean

// Q3.3
gen g_inc =(inc_t2-inc_t1)/inc_t1 		// Cette variable contient la croissance des revenus individuels. 
replace g_inc = 0 in 1             		// Pour le percentile = 0, la croissance est aussi de 0  
list g_inc

// Q3.4
line g_inc g_mean perc, ///
title(Courbe d’incidence de la croissance ) ///
yline(`g_mean') ///
legend(order( 1 "Curve CIC" 2 "Croissance du revenu moyen")) ///
xtitle(Percentiles (p)) ytitle(Croissance des revenu)  ///
plotregion(margin(zero))

// Q3.5
drop in 1
sum g_inc [aw=weight] if (inc_t1<10.4) 	// pour calculer la croissance moyenne des revenus des personnes pauvres. 
dis "indice pro-pauvres de Chen et Ravillon (2003) = "r(mean)
ipropoor inc_t1 inc_t2, pline(10.4)   	// avec DASP 

// Q3.6
dfgtgr inc_t1 inc_t2, alpha(1) pline(10.4)
/*--------------------+---------------------
                      |  Shapley approach                                             
  --------------------+---------------------
      Growth          |        0.173659        
      Redistribution  |       -0.028851        
  ------------------------------------------*/
