*********11.5%

clear all

* EXERCICE 1 ***2.5%

// Données
cd "~/Documents/Stata"
use data_prac_b4.dta

// Q1.1 
// predict the perceived minimum well-being: _npe_min_ae_exp
cnpe ae_exp  min_ae_exp, xvar(ae_exp) hsize(hsize) min(0) max(50000) vgen(yes)
// level of ae_exp when the difference between the predicted minimum well-being and the observed well-being is nil
cap drop dif
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) xval(0) hsize(hsize) vgen(yes)
// graph
cnpe ae_exp  min_ae_exp, xvar(ae_exp) hsize(hsize) min(0) max(50000)   ///          
legend(order( 1 "Observed well-being" 2 "Perceived  minimum  well-being"))  ///
subtitle("") title(The subjective poverty line)            ///
xline(22613.242188) xtitle(Observed well-being)         ///  
ytitle(Predicted level of the perceived  minimum  well-being )

// Q1.2 pour l'intensité de pauvreté, on utilise alpha=1
// a)
ifgt  ae_exp, alpha(1) hsize(hsize) pline(22613.242188)
// b)
ifgt  ae_exp, alpha(1) hsize(hsize) pline(21000)
// c)
ifgt  ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)

// Q1.3
// Voir fichier Word



* EXERCICE 2 **********4.5%

// Q2.1
dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(21000)
/*
 Decomposition of the FGT index by groups
+-----------------------------------------------------------------------------------+
  |          Group   |      FGT index     Population       Absolute        Relative   |
  |                  |                       share       contribution    contribution |
  |------------------+----------------------------------------------------------------|
  |Male              |        0.327669        0.778889        0.255218        0.737687|
  |                  |        0.013362        0.011401        0.010533        0.025703|
  |Female            |        0.410438        0.221111        0.090753        0.262313|
  |                  |        0.035271        0.011401        0.011081        0.025703|
  |------------------+----------------------------------------------------------------|
  |Population        |        0.345970        1.000000        0.345970        1.000000|
  |                  |        0.014486        0.000000        0.014486        0.000000|
  +-----------------------------------------------------------------------------------+

*/

// Q2.2
ifgt ae_exp, hsize(hsize) pline(21000) alpha(0) hgroup(region)
/*
    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  sweight
    Group variable  :  region
    Parameter alpha :  0.00
--------------------------------------------------------------------------------------------------
         Group   |       Estimate            STE             LB              UB         Pov. line
-----------------+--------------------------------------------------------------------------------
1: central       |        0.211661        0.018010        0.176316        0.247006        21000.00
2: eastern       |        0.349732        0.019104        0.312240        0.387224        21000.00
3: northern      |        0.650641        0.035878        0.580230        0.721053        21000.00
4: western       |        0.251535        0.022109        0.208146        0.294924        21000.00
-----------------+--------------------------------------------------------------------------------
Population       |        0.345970        0.014486        0.317541        0.374400        21000.00
--------------------------------------------------------------------------------------------------
*/

// Q2.3
gen ae_exp2 = ae_exp
replace ae_exp2 = 0.94*ae_exp if region==2
replace ae_exp2 = 1.1*ae_exp if region==3

// Q2.4
dfgtgr ae_exp ae_exp2, alpha(1) hsize(hsize) pline(21000)
/*
  -------------------------------------------------------------------------------------
                      |       Estimate            STE             LB              UB  
--------------------+----------------------------------------------------------------
                      |  Shapley approach                                             
   --------------------+----------------------------------------------------------------
      Growth          |       -0.028168        0.021113       -0.069603        0.013266
      Redistribution  |        0.010447        0.019053       -0.026944        0.047839
  -------------------------------------------------------------------------------------
*/

// Q2.5
dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(1) pline(21000)

/*
 Decomposition of the FGT index by groups
+-----------------------------------------------------------------------------------+
  |          Group   |      FGT index     Population       Absolute        Relative   |
  |                  |                       share       contribution    contribution |
  |------------------+----------------------------------------------------------------|
  |central           |        0.048595        0.284768        0.013838        0.131539|
  |                  |        0.005030        0.012891        0.001521        0.017420|
  |eastern           |        0.088158        0.271134        0.023903        0.227203|
  |                  |        0.006660        0.012747        0.002178        0.026235|
  |northern          |        0.265423        0.198358        0.052649        0.500446|
  |                  |        0.026950        0.014834        0.008296        0.045591|
  |western           |        0.060283        0.245740        0.014814        0.140812|
  |                  |        0.006575        0.010550        0.001802        0.019540|
  |------------------+----------------------------------------------------------------|
  |Population        |        0.105203        1.000000        0.105203        1.000000|
  |                  |        0.007999        0.000000        0.007999        0.000000|
  +-----------------------------------------------------------------------------------+

*/
/*
Commentaire: cibler la region Northern pour réduire l'intensité de pauvreté à travers un transfert marginal

Code à utiliser pour déterminer les contributions relatives au taux de pauvreté :
dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(21000)
itargetg ae_exp, alpha(1) pline(21000) hsize(hsize) hgroup(region) constam(1)
*/




* EXERCICE 3 *******4.5%

clear all
// Données
input Identifier	weight	inc_t1	inc_t2
0	0	0.00	0.00
1	0.1	1.50	1.54
2	0.1	4.50	3.85
3	0.1	7.50	6.60
4	0.1	3.00	2.75
5	0.1	4.50	4.40
6	0.1	9.00	7.70
7	0.1	10.50	8.80
8	0.1	15.00	7.70
9	0.1	12.00	6.60
10	0.1	13.50	6.60
end

// Q3.1
sort inc_t1

*sum weight
*gen perc=sum(weight)/r(sum)
gen perc=sum(weight)
list perc

// Q3.2
qui sum inc_t1 [aw=weight]   			
scalar mean1=r(mean)         			
qui sum inc_t2 [aw=weight]
scalar mean2=r(mean)         			
scalar g_mean = (mean2-mean1)/mean1
dis "taux de croissance du revenu moyen = " g_mean

// Q3.3
gen g_inc =(inc_t2-inc_t1)/inc_t1 		 
replace g_inc = 0 in 1 

// Q3.4
gen g_mean = g_mean

line g_inc g_mean perc, ///
title(Growth Incidence Curve) ///
yline(`g_mean') ///
legend(order( 1 "GIC curve" 2 "Growth in average income")) ///
xtitle(Percentiles (p)) ytitle(Growth in incomes)  ///
plotregion(margin(zero))

// Q3.5
ipropoor inc_t1 inc_t2, pline(10.2)

// Q3.6
dfgtgr inc_t1 inc_t2, alpha(1) pline(10.2)
/*
 Decomposition of the variation in the FGT index into growth and redistribution.
   Parameter alpha :         1.00
   Poverty line    :        10.20
  -------------------------------------------------------------------------------------
                      |       Estimate            STE             LB              UB  
  --------------------+----------------------------------------------------------------
                      |  Shapley approach                                             
  --------------------+----------------------------------------------------------------
      Growth          |        0.155620        0.044422        0.056641        0.254599
      Redistribution  |       -0.028525        0.010994       -0.053021       -0.004029
  -------------------------------------------------------------------------------------
*/
