*****************12.5%


//Stata code for the Practical exercise 3// CATHERINE MANTHALU

//QUESTION 1*****3.5%

//Q1.1

use "C:\Users\USER\Desktop\PEP 2021 LESSONS\POVERTY INEQUALITY COURSE\exercise 6 7 8\data_b3_1.dta", clear

/* To represet an individual we mutply the household weight by the household size.*/
gen fweight = sweight*hsize

/*initialize the data*/
svyset psu [pweight=fweight], strata(strata) vce(linearized) singleunit(missing)

/* Use the nonparametric regression technique to predict the perceived minimum well-being */
cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)                      ///
legend(order( 1 "Perceived  minimum  well-being " 2 "Observed well-being"))  ///
subtitle("") title(The subjective poverty line)            ///
 xtitle(Observed well-being)                       /// 
 ytitle(Predicted level of the perceived  minimum  well-being )              ///
 vgen(yes)  /* The  predicted values for each level of X_i  (i.e., Predicted[Y|X_i]) is generaeted by the option vgen(yes)*/

 
/* 
Estimating the level of ae_exp when the difference between the predicted minimum well-being and the observed well-being is nil.
By adding the option xval(0) instead of the two options min() and max(), the cnpe perform the prediction
for only one value of X (dif in our case) , i.e., E[ae_exp|dif==0]. 
*/ 
cap drop dif
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) xval(0) vgen(yes)

cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)                      ///
legend(order( 1 "Perceived  minimum  well-being " 2 "Observed well-being"))  ///
subtitle("") title(The subjective poverty line)            ///
xline(22922.419922) xtitle(Observed well-being)            /// 
ytitle(Predicted level of the perceived  minimum  well-being ) 


// Q 1.2 //

ifgt ae_exp, alpha(1) hsize(hsize) pline(22922.419922 )

/*Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  fweight
    Parameter alpha :  1.00
-----------------------------------------------------------------------------------------------
   Variable   |       Estimate            STE             LB              UB         Pov. line
--------------+--------------------------------------------------------------------------------
ae_exp        |        0.133145        0.008793        0.115885        0.150404        22922.42
-----------------------------------------------------------------------------------------------*/

ifgt ae_exp, alpha(1) hsize(hsize) pline(21000)

/*Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  fweight
    Parameter alpha :  1.00
-----------------------------------------------------------------------------------------------
   Variable   |       Estimate            STE             LB              UB         Pov. line
--------------+--------------------------------------------------------------------------------
ae_exp        |        0.107530        0.008160        0.091513        0.123547        21000.00
-----------------------------------------------------------------------------------------------*/

ifgt ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)


/*    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  fweight
    Parameter alpha :  1.00
-----------------------------------------------------------------------------------------------
   Variable   |       Estimate            STE             LB              UB         Pov. line
--------------+--------------------------------------------------------------------------------
ae_exp        |        0.051763        0.006485        0.039035        0.064491        16082.23
-----------------------------------------------------------------------------------------------*/


//  Q1.3//

//Relative poverty is recommended in developed countries, stemming from the realization that the perception and experience of poverty have a social dimension. In very poor countries, absolute survival plays a bigger role, but as countries’ average wealth rises, so social inclusion, and thus relative poverty, becomes more salient.It is a condition where household income is a certain percentage below median incomes. This relative measure brings the important dimension of inequality into the definition. It views poverty as socially defined and dependent on social context. In addition, it is able to capture living standards levels of the population. (absolute poverty disappears as countries become richer). Relative poverty is useful for showing the percentage of the population who have been relatively left behind in developed economies. For example, the threshold for relative poverty could be set at 50% of median incomes (or 60%)//


/*As countries get richer, their assessment of basic needs increases in value. Fixing basic needs to be the same across all countries ensures equality in the bundle of goods across countries, and this is one important way of counting the poor across countries. But, equality of the consumption bundle across countries may not result in the same level of wellbeing. Basic functioning may be costlier in some countries relative to other countries depending on level of development, and fixing consumption to be constant could well mean an unequal treatment of people across the world in terms of their wellbeing. Hence, Relative Poverty is suitable for developed countries as it atkes into account such ineqaulity aspects in developed countries*/


//QUESTION 2//***********4.5%

//  Q2.1//

dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(21000)
/*+-----------------------------------------------------------------------------------+
  |          Group   |      FGT index     Population       Absolute        Relative   |
  |                  |                       share       contribution    contribution |
  |------------------+----------------------------------------------------------------|
  |Male              |        0.354664        0.811153        0.287687        0.771896|
  |                  |        0.023994        0.015801        0.020133        0.028288|
  |Female            |        0.450176        0.188847        0.085015        0.228104|
  |                  |        0.040346        0.015801        0.011252        0.028288|
  |------------------+----------------------------------------------------------------|
  |Population        |        0.372701        1.000000        0.372701        1.000000|
  |                  |        0.021186        0.000000        0.021186        0.000000|
  +-----------------------------------------------------------------------------------*/



//1- The proportion of population of male-headed households is 81.11%, while female-headed households is 18.89 %.
//2- The total headcount poverty is equal to 37.27%. Male group contributes by  28.78 and females 8.50 (28.78 + 8.50 = 37.27%).   
 
 
//The contribution (to total poverty) of poverty among households headed by women is greater than the contribution that comes from their representativeness in the total population (0.450176  VS 0.188847). As known, the absolute contribution to total poverty is given by the product of these two components: poverty in the group x population share of the group. However, the relative and absolute contributions of female-headed households are smaller than those of male-headed households.// 


// Question 2.2//

dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(21000)

/*Decomposition of the FGT index by groups
    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  fweight
    Group variable  :  region
    Parameter alpha :  0.00
  +-----------------------------------------------------------------------------------+
  |          Group   |      FGT index     Population       Absolute        Relative   |
  |                  |                       share       contribution    contribution |
  |------------------+----------------------------------------------------------------|
  |central           |        0.269808        0.261808        0.070638        0.189530|
  |                  |        0.037255        0.019595        0.011699        0.029344|
  |eastern           |        0.349802        0.298313        0.104350        0.279984|
  |                  |        0.042660        0.024717        0.013013        0.032067|
  |northern          |        0.659893        0.195767        0.129185        0.346618|
  |                  |        0.041074        0.017333        0.015759        0.035649|
  |western           |        0.280723        0.244113        0.068528        0.183868|
  |                  |        0.033872        0.016222        0.010211        0.026010|
  |------------------+----------------------------------------------------------------|
  |Population        |        0.372701        1.000000        0.372701        1.000000|
  |                  |        0.021186        0.000000        0.021186        0.000000|
  +-----------------------------------------------------------------------------------+*/



//  Q2.3//
gen ae_exp2= ae_exp*0.94 if region==2
replace ae_exp2= ae_exp*1.1 if region==3
replace ae_exp2= ae_exp if ae_exp2==.


//Q2.4//

dfgtgr ae_exp ae_exp2, alpha(1) pline(21000)

/*Decomposition of the variation in the FGT index into growth and redistribution.
   Parameter alpha :         1.00
   Poverty line    :     21000.00
  -------------------------------------------------------------------------------------
                      |       Estimate            STE             LB              UB  
  --------------------+----------------------------------------------------------------
       Distribution_1 |        0.102046        0.007282        0.087753        0.116339
       Distribution_2 |        0.099618        0.006934        0.086007        0.113228
  --------------------+----------------------------------------------------------------
  Difference: (d2-d1) |       -0.002428        0.001030       -0.004450       -0.000406
  --------------------+----------------------------------------------------------------
                      |  Datt & Ravallion approach: reference period  t1               
  --------------------+----------------------------------------------------------------
      Growth          |        0.001151        0.000406        0.000354        0.001948
      Redistribution  |       -0.003618        0.000895       -0.005375       -0.001861
      Residue         |        0.000039            ---             ---             ---
  --------------------+----------------------------------------------------------------
                      |  Datt & Ravallion approach: reference period  t2               
  --------------------+----------------------------------------------------------------
      Growth          |        0.001190        0.000427        0.000352        0.002028
      Redistribution  |       -0.003579        0.000897       -0.005339       -0.001818
      Residue         |       -0.000039            ---             ---             ---
  --------------------+----------------------------------------------------------------
                      |  Shapley approach                                             
  --------------------+----------------------------------------------------------------
      Growth          |        0.001170        0.000416        0.000353        0.001987
      Redistribution  |       -0.003598        0.000896       -0.005356       -0.001840
  -------------------------------------------------------------------------------------*/



//  Q2.5//
dfgtg ae_exp2, hgroup(region) hsize(hsize) alpha(1) pline(21000)

/*Decomposition of the FGT index by groups
    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  fweight
    Group variable  :  region
    Parameter alpha :  1.00
  +------------------------------------------------------------------------------------+
  |           Group   |      FGT index     Population       Absolute        Relative   |
  |                   |                       share       contribution    contribution |
  |-------------------+----------------------------------------------------------------|
  |central            |        0.060380        0.261808        0.015808        0.150213|
  |                   |        0.009344        0.019595        0.002749        0.026118|
  |eastern            |        0.112314        0.298313        0.033505        0.318371|
  |                   |        0.016121        0.024717        0.005071        0.041668|
  |northern           |        0.208752        0.195767        0.040867        0.388328|
  |                   |        0.022672        0.017333        0.006192        0.044970|
  |western            |        0.061686        0.244113        0.015058        0.143088|
  |                   |        0.009247        0.016222        0.002582        0.024504|
  |-------------------+----------------------------------------------------------------|
  |Population         |        0.105238        1.000000        0.105238        1.000000|
  |                   |        0.007846        0.000000        0.007846        0.000000|
  +------------------------------------------------------------------------------------+*/

dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(1) pline(21000)

/*Decomposition of the FGT index by groups
    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  fweight
    Group variable  :  region
    Parameter alpha :  1.00
  +-----------------------------------------------------------------------------------+
  |          Group   |      FGT index     Population       Absolute        Relative   |
  |                  |                       share       contribution    contribution |
  |------------------+----------------------------------------------------------------|
  |central           |        0.060380        0.261808        0.015808        0.147010|
  |                  |        0.009344        0.019595        0.002749        0.025704|
  |eastern           |        0.094795        0.298313        0.028278        0.262981|
  |                  |        0.015058        0.024717        0.004656        0.039030|
  |northern          |        0.247160        0.195767        0.048386        0.449972|
  |                  |        0.023386        0.017333        0.006871        0.045334|
  |western           |        0.061686        0.244113        0.015058        0.140037|
  |                  |        0.009247        0.016222        0.002582        0.024112|
  |------------------+----------------------------------------------------------------|
  |Population        |        0.107530        1.000000        0.107530        1.000000|
  |                  |        0.008160        0.000000        0.008160        0.000000|
  +-----------------------------------------------------------------------------------+*/



//  QUESTION 3:*************4.5%

//  Q3.1

clear
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

sort inc_t1 
gen perc=sum(weight)  
list perc  


//  Q3.2

qui sum inc_t1 [aw=weight]      // To compute the mean of incomes in t1. 
scalar mean1=r(mean)           // To   keep in memory the scalar  mean1 = r(mean) in t1 
qui sum inc_t2 [aw=weight] 
scalar mean2=r(mean)            // To   keep in memory the scalar  mean2 = r(mean) in t2 
scalar g_mean = (mean2-mean1)/mean1 
gen g_mean  = (mean2-mean1)/mean1     // To generate the variable g_mean, which is equal to the growth in averages. 
dis "Mean 1              =" mean1
dis "Mean 2              = " mean2 
dis "Growth in averages  = " g_mean


//  Q3.3 
gen g_inc =(inc_t2-inc_t1)/inc_t1   // This variable contain the individual growth in income. 
replace g_inc = 0 in 1               // When the percentile = 0, the growth is also 0 // default values. 


//  Q3.4
line g_inc g_mean perc, /// 
title(Growth Incidence Curve) /// 
yline(`g_mean') /// 
legend(order( 1 "GIC curve" 2 "Growth in average income")) ///
xtitle(Percentiles (p)) ytitle(Growth in incomes)  /// 
plotregion(margin(zero))  

//  Q3.5
/* the Chen and Ravallion (2003) pro-poor index is simply the average of income growths of poor individuals.   */  
drop in 1 
sum g_inc [aw=weight] if (inc_t1<10.2)  // to compute the average income growths of poor individuals. 


/*    Variable |     Obs      Weight        Mean   Std. Dev.       Min        Max
-------------+-----------------------------------------------------------------
       g_inc |       6  .600000009   -.0812963   .0701759  -.1444445   .0266666*/


dis = r(mean) 
ipropoor inc_t1 inc_t2, pline(10.2)    // To compute different propoor indices with DASP  

/*Poverty line    :        10.20
   Parameter alpha :         0.00
  -----------------------------------------------------------------------------------------------
               Pro-poor indices |       Estimate            STE             LB              UB  
  ------------------------------+----------------------------------------------------------------
                 Growth rate(g) |       -0.301975        0.068365       -0.456627       -0.147324
  ------------------------------+----------------------------------------------------------------
  Ravallion & Chen (2003) index |       -0.081296        0.027568       -0.143659       -0.018934
  Ravallion & Chen (2003) - g   |        0.220679        0.075578        0.049710        0.391648
  ------------------------------+----------------------------------------------------------------
  Kakwani & Pernia (2000) index |        1.333333        0.423542        0.375216        2.291451
  ------------------------------+----------------------------------------------------------------
                     PEGR index |       -0.402634        0.184119       -0.819140        0.013872
                     PEGR - g   |       -0.100658        0.138512       -0.413995        0.212678
  -----------------------------------------------------------------------------------------------*/




//  Q3.6
dfgtgr inc_t1 inc_t2, alpha(1) pline(10.2)  

/*Decomposition of the variation in the FGT index into growth and redistribution.
   Parameter alpha :         1.00
   Poverty line    :        10.20
  -------------------------------------------------------------------------------------
                      |       Estimate            STE             LB              UB  
  --------------------+----------------------------------------------------------------
       Distribution_1 |        0.305882        0.105336        0.067595        0.544170
       Distribution_2 |        0.445686        0.073902        0.278508        0.612864
  --------------------+----------------------------------------------------------------
  Difference: (d2-d1) |        0.139804        0.042347        0.044007        0.235601
  --------------------+----------------------------------------------------------------
                      |  Datt & Ravallion approach: reference period  t1               
  --------------------+----------------------------------------------------------------
      Growth          |        0.142455        0.035167        0.062901        0.222008
      Redistribution  |       -0.060105        0.028402       -0.124355        0.004145
      Residue         |        0.057455            ---             ---             ---
  --------------------+----------------------------------------------------------------
                      |  Datt & Ravallion approach: reference period  t2               
  --------------------+----------------------------------------------------------------
      Growth          |        0.199909        0.060038        0.064093        0.335725
      Redistribution  |       -0.002651        0.008859       -0.022690        0.017389
      Residue         |       -0.057455            ---             ---             ---
  --------------------+----------------------------------------------------------------
                      |  Shapley approach                                             
  --------------------+----------------------------------------------------------------
      Growth          |        0.171182        0.045998        0.067126        0.275238
      Redistribution  |       -0.031378        0.011738       -0.057931       -0.004825
  -------------------------------------------------------------------------------------*/



 