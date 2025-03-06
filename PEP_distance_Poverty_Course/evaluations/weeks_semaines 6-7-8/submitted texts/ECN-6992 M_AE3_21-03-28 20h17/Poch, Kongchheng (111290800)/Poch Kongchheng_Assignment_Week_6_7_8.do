********12.5%


// Stata Codes for Assignment Week 6,7,8//

set more off

//  Q1.1: estimate the subjective poverty line
/* Using the nonparametric regression technique to predict the perceived minimum well-being. 
Remember that the Nonparametric regression is useful to show the link between two variables 
without specifying beforehand a functional form. 
The Stata command: 
cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)  ...
will draw two curves. 
- The first  curve will show the relationship between the Y variable :     ae_exp and the X variable ae_exp.
- The second curve will show the relationship between the Y variable : min_ae_exp and the X variable ae_exp.
The range of the  X axis  will be encompensated between 0 and 60000.
The rest of options are similar to those of Stata command "line", which is used to draw curves. 
The last option vgen(yes) asks to generate the predicted values for each level of X_i (i.e., Predicted[Y|X_i]).
Names of generated variables will start by "_npe_" followed by the name of the variable Y (example _npe_ae_exp).  
*/

use "C:\Users\kongchheng.poch\Documents\KC Training\PEP MAPI_20210118\MAPI_AssignW6-7-8\data_b3_3.dta"

cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000) hs(hsize)            ///
legend(order( 1 "Perceived  minimum  well-being " 2 "Observed well-being"))  ///
subtitle("") title(The subjective poverty line)            ///
 xtitle(Observed well-being)                       /// 
 ytitle(Predicted level of the perceived  minimum  well-being )              ///
 vgen(yes)
 
/* 
Estimating the level of ae_exp when the difference between the predicted minimum well-being and the observed well-being is nil.
By adding the option xval(0) instead of the two options min() and max(), the cnpe perform the prediction
for only one value of X (dif in our case) , i.e., E[ae_exp|dif==0]. 
*/
cap drop dif
gen dif = _npe_min_ae_exp - ae_exp
cnpe ae_exp, xvar(dif) xval(0) vgen(yes)

/*
Showing the subjective poverty line  : Here we draw the similar two first curves, 
but in addition, we add the subjective poverty line with the option xline( 22832.943359) 
*/
cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)                      ///
legend(order( 1 "Perceived  minimum  well-being " 2 "Observed well-being"))  ///
subtitle("") title(The subjective poverty line)            ///
xline(22832.94) xtitle(Observed well-being)            /// 
ytitle(Predicted level of the perceived  minimum  well-being ) 

//  Q1.2: Estimate the poverty gap

/* "ifgt" is a DASP command that can be used to estimate the FGT poverty indices.
The "ifgt" DASP command should be followed by a varname of the welfare variable, which is the per adult equivalent expenditures in our case.
Among their options we find:
1- pline: to indicate the poverty line;
2- hsize: to indicate the varname of the household size.
3- alpha: the FGT alpha parameter:
- alpha(0) : the headcount poverty;
- alpha(1) : the poverty gap poverty;
- alpha(2) : the squared poverty gap poverty.

// a) The result is as follows:

 ifgt  ae_exp, alpha(1) hsize(hsize) pline(22832.94)

    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  sweight
    Parameter alpha :  1.00
-----------------------------------------------------------------------------------------------
   Variable   |       Estimate            STE             LB              UB         Pov. line
--------------+--------------------------------------------------------------------------------
ae_exp        |        0.144084        0.015001        0.114640        0.173528        22832.94
-----------------------------------------------------------------------------------------------
*/
ifgt  ae_exp, alpha(1) hsize(hsize) pline(22832.94)


/* b) The result is as follows:
 ifgt  ae_exp, alpha(1) hsize(hsize) pline(20900)

    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  sweight
    Parameter alpha :  1.00
-----------------------------------------------------------------------------------------------
   Variable   |       Estimate            STE             LB              UB         Pov. line
--------------+--------------------------------------------------------------------------------
ae_exp        |        0.120934        0.014569        0.092337        0.149532        20900.00
-----------------------------------------------------------------------------------------------

*/
ifgt  ae_exp, alpha(1) hsize(hsize) pline(20900)


/*
In the following command line, we do not indicate the poverty line, but instead add the options: opl(mean) prop(50).
Thus, the command is to ask Stata to consider that the poverty line is relative, and it is equal to the half of the mean (i.e., 50% of the mean).

// b) The result is as follows:
 ifgt  ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)

    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  sweight
    Parameter alpha :  1.00
-----------------------------------------------------------------------------------------------
   Variable   |       Estimate            STE             LB              UB         Pov. line
--------------+--------------------------------------------------------------------------------
ae_exp        |        0.077279        0.011093        0.055506        0.099052        16991.00
-----------------------------------------------------------------------------------------------
*/
ifgt  ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)


//  Q1.3: 
/*
In developed countries, the use of relative poverty line is the most appropriate method for two main reasons.
First, the living standards in developed countries are generally high. Poverty is basically viewed as a relative distance from the average income of the population; thus, it is defined as a fraction of the average income. Alternative method such as “absolute poverty line” will underestimate the poverty level.
Second, connected to the first point above, the relative poverty line will provide a consistency of poverty profile. So, it allows us to compare poverty dynamics across time span. 
*/


//* Exercise 2
clear
use "C:\Users\kongchheng.poch\Documents\KC Training\PEP MAPI_20210118\MAPI_AssignW6-7-8\data_b3_3.dta"

// Q2.1: Decompose poverty (headcount index) by the gender of the household head
/* The result is as follows:
 dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20900)

    Decomposition of the FGT index by groups
    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  sweight
    Group variable  :  sex
    Parameter alpha :  0.00
  +-----------------------------------------------------------------------------------+
  |          Group   |      FGT index     Population       Absolute        Relative   |
  |                  |                       share       contribution    contribution |
  |------------------+----------------------------------------------------------------|
  |Male              |        0.336161        0.754545        0.253648        0.694339|
  |                  |        0.019070        0.020842        0.015560        0.047359|
  |Female            |        0.454912        0.245455        0.111661        0.305661|
  |                  |        0.058320        0.020842        0.022011        0.047359|
  |------------------+----------------------------------------------------------------|
  |Population        |        0.365309        1.000000        0.365309        1.000000|
  |                  |        0.022878        0.000000        0.022878        0.000000|
  +-----------------------------------------------------------------------------------+

Conclusion:
 The poverty headcount among female-headed households is more prevalent than the male-headed household.
 The poverty headcount of the female-headed households is 0.45, which is significantly higher than that of their counterparts (i.e., male-headed households) at 0.33.
*/
dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20900)


//  Q2.2: Estimate total poverty according to the region of household head (region)
/* The result is as follows:
 ifgt  ae_exp, hgroup(region) alpha(0) pline(20900)

    Poverty index   :  FGT index
    Sampling weight :  sweight
    Group variable  :  region
    Parameter alpha :  0.00
--------------------------------------------------------------------------------------------------
         Group   |       Estimate            STE             LB              UB         Pov. line
-----------------+--------------------------------------------------------------------------------
1: central       |        0.176114        0.021796        0.133333        0.218895        20900.00
2: eastern       |        0.257333        0.024003        0.210219        0.304448        20900.00
3: northern      |        0.672212        0.047806        0.578376        0.766048        20900.00
4: western       |        0.229931        0.030062        0.170924        0.288937        20900.00
-----------------+--------------------------------------------------------------------------------
Population       |        0.307643        0.020096        0.268197        0.347088        20900.00
--------------------------------------------------------------------------------------------------

*/
ifgt  ae_exp, hgroup(region) alpha(0) pline(20900)


//  Q2.3:
/*  The result is as follows:
. gen ae_exp2=ae_exp

. replace ae_exp2 = ae_exp*1.11 if region==3
(509 real changes made)

. replace ae_exp2 = ae_exp*0.94 if region==2
(838 real changes made)
*/
gen ae_exp2=ae_exp
replace ae_exp2 = ae_exp*1.11 if region==3
replace ae_exp2 = ae_exp*0.94 if region==2


//  Q2.4:
/*  The result is as follows:
dfgtgr ae_exp ae_exp2, alpha(1) pline(20900)

   Decomposition of the variation in the FGT index into growth and redistribution.
   Parameter alpha :         1.00
   Poverty line    :     20900.00
  -------------------------------------------------------------------------------------
                      |       Estimate            STE             LB              UB  
  --------------------+----------------------------------------------------------------
       Distribution_1 |        0.102255        0.011426        0.079828        0.124682
       Distribution_2 |        0.098344        0.010589        0.077558        0.119129
  --------------------+----------------------------------------------------------------
  Difference: (d2-d1) |       -0.003912        0.001146       -0.006161       -0.001662
  --------------------+----------------------------------------------------------------
                      |  Datt & Ravallion approach: reference period  t1               
  --------------------+----------------------------------------------------------------
      Growth          |        0.000997        0.000284        0.000440        0.001554
      Redistribution  |       -0.004956        0.001063       -0.007043       -0.002868
      Residue         |        0.000047            ---             ---             ---
  --------------------+----------------------------------------------------------------
                      |  Datt & Ravallion approach: reference period  t2               
  --------------------+----------------------------------------------------------------
      Growth          |        0.001044        0.000296        0.000463        0.001625
      Redistribution  |       -0.004909        0.001062       -0.006993       -0.002824
      Residue         |       -0.000047            ---             ---             ---
  --------------------+----------------------------------------------------------------
                      |  Shapley approach                                             
  --------------------+----------------------------------------------------------------
      Growth          |        0.001021        0.000290        0.000452        0.001589
      Redistribution  |       -0.004932        0.001063       -0.007018       -0.002846
  -------------------------------------------------------------------------------------

Discussion:
1) The income distribution contributes to a reduction in poverty gap.
2) The economic growth or increase in average income of the population results in an increase in poverty gap.
*/
dfgtgr ae_exp ae_exp2, alpha(1) pline(20900)


//  Q2.5:
/*  The result is as follows:
ifgt  ae_exp2, hgroup(region) alpha(1) pline(20900)

    Poverty index   :  FGT index
    Sampling weight :  sweight
    Group variable  :  region
    Parameter alpha :  1.00
--------------------------------------------------------------------------------------------------
         Group   |       Estimate            STE             LB              UB         Pov. line
-----------------+--------------------------------------------------------------------------------
1: central       |        0.045387        0.007863        0.029954        0.060821        20900.00
2: eastern       |        0.083422        0.008599        0.066543        0.100301        20900.00
3: northern      |        0.255402        0.035142        0.186423        0.324381        20900.00
4: western       |        0.052065        0.008480        0.035421        0.068709        20900.00
-----------------+--------------------------------------------------------------------------------
Population       |        0.098344        0.010589        0.077558        0.119129        20900.00
--------------------------------------------------------------------------------------------------

Discussion:
1) The poverty gap in the northern region (region 3) is the highest at 0.255.
2) The poverty gaps in the other three regions are quite similar (i.e., region1=0.045, region2=0.083, region4=0.052).
3) Hence, given the relatively low poverty gaps in the three regions, the average poverty gap of the country is only 0.098.
*/
ifgt  ae_exp2, hgroup(region) alpha(1) pline(20900)


//* Exercise 3
// Q3.1: 

clear
input identifier weight inc_t1 inc_t2
0 0.0  0     0
1 0.1  1.5   1.54
2 0.1  4.5   3.85
3 0.1  7.5   6.60
4 0.1  3     2.75
5 0.1  4.5   4.4
6 0.1  9 	 7.7
7 0.1  10.5  8.8
8 0.1  15.0  7.7
9 0.1  12.0  6.6
10 0.1 13.5  6.6
end

sort inc_t1
gen perc=sum(weight)
list perc

// Q3.2:

qui sum inc_t1 [aw=weight]   			// To compute the mean of incomes in t1. Also, the summarize (sum in abbreviation ) returns the average as: r(mean)
scalar mean1=r(mean)         			// To   keep in memory the scalar  mean1 = r(mean) in t1
qui sum inc_t2 [aw=weight]
scalar mean2=r(mean)         			// To   keep in memory the scalar  mean2 = r(mean) in t2
scalar g_mean = (mean2-mean1)/mean1
gen g_mean  = (mean2-mean1)/mean1    	// To generate the variable g_mean, which is equal to the growth in averages. 
dis "Mean 1              =" mean1
dis "Mean 2             = " mean2
dis "Growth in averages = " g_mean

//  Q3.3:
gen g_inc =(inc_t2-inc_t1)/inc_t1 		// This variable with contain the individual growth in income. 
replace g_inc = 0 in 1             		// When the percentile = 0, the growth is also 0 // default values.  


// Q3.4:
line g_inc g_mean perc, ///
title(Growth Incidence Curve) ///
yline(`g_mean') ///
legend(order( 1 "GIC curve" 2 "Growth in average income")) ///
xtitle(Percentiles (p)) ytitle(Growth in incomes)  ///
plotregion(margin(zero))

// Q3.5:
/*The Chen and Ravallion (2003) pro-poor index is simply the average of income growths of poor individuals.*/  
/* The result is as follows:
 drop in 1
(1 observation deleted)

. sum g_inc [aw=weight] if (inc_t1<10.4)  // to compute the average income growths of poor individuals. 

    Variable |     Obs      Weight        Mean   Std. Dev.       Min        Max
-------------+-----------------------------------------------------------------
       g_inc |       6  .600000009   -.0812963   .0701759  -.1444445   .0266666

. dis = r(mean)
-.08129631

. ipropoor inc_t1 inc_t2, pline(10.4)     // To compute different propoor indices with DASP
MUM-.4  DENUM -.3
   Poverty line    :        10.40
   Parameter alpha :         0.00
  -----------------------------------------------------------------------------------------------
               Pro-poor indices |       Estimate            STE             LB              UB  
  ------------------------------+----------------------------------------------------------------
                 Growth rate(g) |       -0.301975        0.068365       -0.456627       -0.147324
  ------------------------------+----------------------------------------------------------------
  Ravallion & Chen (2003) index |       -0.081296        0.027568       -0.143659       -0.018934
  Ravallion & Chen (2003) - g   |        0.220679        0.075578        0.049710        0.391648
  ------------------------------+----------------------------------------------------------------
  Kakwani & Pernia (2000) index |        1.333333        0.418947        0.385609        2.281058
  ------------------------------+----------------------------------------------------------------
                     PEGR index |       -0.402634        0.181351       -0.812877        0.007610
                     PEGR - g   |       -0.100658        0.136631       -0.409739        0.208422
  -----------------------------------------------------------------------------------------------

Discussion:
1) The economic growth is not conducive to poverty reduction. The average income of the poor is relatively lower than average income growth of the population.
*/

drop in 1
sum g_inc [aw=weight] if (inc_t1<10.4) 	// to compute the average income growths of poor individuals. 
dis = r(mean)
ipropoor inc_t1 inc_t2, pline(10.4)   	// To compute different propoor indices with DASP

//  Q3.6:
/*
The DASP command dfgtgr enables to perform the decomposition of the variation in FGT indices between two periods
into growth and redistribution components.
This decomposition is performed with three different approaches:
- Datt & Ravallion approach: reference period  t1  
- Datt & Ravallion approach: reference period  t2
- Shapley approach  (enables to overcome the specification of the reference period).     
*/
/* The result is as follows:
 dfgtgr inc_t1 inc_t2, alpha(1) pline(10.4)

   Decomposition of the variation in the FGT index into growth and redistribution.
   Parameter alpha :         1.00
   Poverty line    :        10.40
  -------------------------------------------------------------------------------------
                      |       Estimate            STE             LB              UB  
  --------------------+----------------------------------------------------------------
       Distribution_1 |        0.311538        0.105810        0.072180        0.550897
       Distribution_2 |        0.456346        0.072481        0.292383        0.620309
  --------------------+----------------------------------------------------------------
  Difference: (d2-d1) |        0.144808        0.044233        0.044745        0.244871
  --------------------+----------------------------------------------------------------
                      |  Datt & Ravallion approach: reference period  t1               
  --------------------+----------------------------------------------------------------
      Growth          |        0.145484        0.036725        0.062407        0.228562
      Redistribution  |       -0.057026        0.026851       -0.117767        0.003714
      Residue         |        0.056350            ---             ---             ---
  --------------------+----------------------------------------------------------------
                      |  Datt & Ravallion approach: reference period  t2               
  --------------------+----------------------------------------------------------------
      Growth          |        0.201834        0.059022        0.068318        0.335350
      Redistribution  |       -0.000677        0.009501       -0.022169        0.020816
      Residue         |       -0.056350            ---             ---             ---
  --------------------+----------------------------------------------------------------
                      |  Shapley approach                                             
  --------------------+----------------------------------------------------------------
      Growth          |        0.173659        0.046125        0.069318        0.278001
      Redistribution  |       -0.028851        0.010816       -0.053318       -0.004385
  -------------------------------------------------------------------------------------


*/
dfgtgr inc_t1 inc_t2, alpha(1) pline(10.4)




