*****12%

********************************************************************************
* Assignment for course module 6 7 and 8
********************************************************************************

*Excerise 1. ***3%

// Question 1.1 

use data_b3_2.dta, clear

/*The provided weight in the survey is at household level. But different houisehold have got different number of people. To represet an individual we mutply the household weight by the household size. This makes our weighted analysis at individual level*/
gen fweight = sweight*hsize

/*We then initialize the data by using the generaeted individual weights as follows*/
svyset psu [pweight=fweight], strata(strata) vce(linearized) singleunit(missing)

/* Now we will Use the nonparametric regression technique to predict the perceived minimum well-being */
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

/*
. cnpe ae_exp, xvar(dif) xval(0) vgen(yes)
In progress ...
   Sampling weight    :  fweight
  +---------------------------------+
  |   Variable(s)  |Estimated value |
  |----------------+----------------|
  |ae_exp          |    22289.966797|
  +---------------------------------+
*/
cap drop dif
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) xval(0) vgen(yes)

/*
Showing the subjective poverty line  : Here we draw the similar two first curves, 
but in addition, we add the show the subjective poverty line with the option xline(22289.966797) 
*/
cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)                      ///
legend(order( 1 "Perceived  minimum  well-being " 2 "Observed well-being"))  ///
subtitle("") title(The subjective poverty line)            ///
xline(22289.966797) xtitle(Observed well-being)            /// 
ytitle(Predicted level of the perceived  minimum  well-being ) 

// Qiestion 1.2 

/*Estimating the poverty gap (using the variables: ae_exp and hsize) then discuss the results:
a)	the subjective poverty line;*/

/*
. ifgt ae_exp, alpha(1) hsize(hsize) pline(22289.97)

    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  fweight
    Parameter alpha :  1.00
-----------------------------------------------------------------------------------------------
   Variable   |       Estimate            STE             LB              UB         Pov. line
--------------+--------------------------------------------------------------------------------
ae_exp        |        0.111312        0.008626        0.094381        0.128244        22289.97
-----------------------------------------------------------------------------------------------
*/

ifgt ae_exp, alpha(1) hsize(hsize) pline(22289.97)
/*

b)	the absolute poverty line (z=20600)*/
ifgt ae_exp, alpha(1) hsize(hsize) pline(20600)

/*
. ifgt ae_exp, alpha(1) hsize(hsize) pline(20600)

    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  fweight
    Parameter alpha :  1.00
-----------------------------------------------------------------------------------------------
   Variable   |       Estimate            STE             LB              UB         Pov. line
--------------+--------------------------------------------------------------------------------
ae_exp        |        0.091793        0.008069        0.075956        0.107630        20600.00
-----------------------------------------------------------------------------------------------
*/

/*
c)	The relative poverty line: (z= half of average income).
*/
ifgt ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)

/*
. ifgt ae_exp, alpha(1) hsize(hsize) opl(mean) prop(50)

    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  fweight
    Parameter alpha :  1.00
-----------------------------------------------------------------------------------------------
   Variable   |       Estimate            STE             LB              UB         Pov. line
--------------+--------------------------------------------------------------------------------
ae_exp        |        0.050231        0.006098        0.038262        0.062201        16286.92
-----------------------------------------------------------------------------------------------

*/

/*Comment: We notice that using subjective poverty line we have high the highest 
estimated poverty gap of 11.13, while for absolute poverty line, we have the 
estimated poverty gap of 9.18% and with relative poverty line we have the 
estimated 5.02%. Since the subjective ppoverty line is based on perception of
 individuals themselves, they tend to over report their poverty and tend to express
 a higher minimum required to satisfy their basic needs, hence we expect to se the 
 highest poverty gap using this subjective poverty line compared to other poverty
 lines. For the absolute poverty line, is a standardized minimum requirement to
 ensure a minimum standard of living and allows for comparisons across groups over 
 times or space. Since the absolute poverty is the same for both developing and 
 developed countries, despite the level of incomes, welfare and standards of living,
 it is more likely to have a higher poverty estimate compared to relative poverty 
 lines but lower compared to subjective poverty. In the same vein we observe that 
 the subjective poverty line is context specific as it is adopted in accrodance 
 with the specific social norm. Rich countries would choose a higher poverty line
 compared to poor countries and we expect the relative poverty to be more 
 apporopriate in capturing these differences and hence we observe the lowest 
 poverty head gap */
 
 
//Question 1.3 

/*In developed countries, using absolute poverty line, majority of individual will 
lie above poverty line and thus the poverty index will show a low poverty rates. 
However, the cost of living in the developed countries could be much higher than 
the cost of living in developing countries. Thus a person slightly above the poverty
 line in developed country may look to be well to do, but in actual fact they are 
 just bearly surving while someone just above the poverty line in developing country
 will be doing much better. Therefore, to better capture the levels standards of 
 living, relative poverty is a much better measure of poverty in developed countries*/



**Excerise 2**4.5%

// Question 2.1 

use data_b3_2.dta, clear

dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20600)

/*
. dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20600)

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
  |Male              |        0.292844        0.794986        0.232807        0.758764|
  |                  |        0.017957        0.011824        0.014660        0.024917|
  |Female            |        0.361034        0.205014        0.074017        0.241236|
  |                  |        0.035384        0.011824        0.008928        0.024917|
  |------------------+----------------------------------------------------------------|
  |Population        |        0.306824        1.000000        0.306824        1.000000|
  |                  |        0.017156        0.000000        0.017156        0.000000|
  +-----------------------------------------------------------------------------------+
*/

/*Comment:  1- The proportion of population of male-headed households is 79.5%, while female-headed households is20.5%.
 2- The total headcount poverty is equal to 30.68%. Male group contributes by  23.28% and 7.40 % (23.28+ 7.40 = 30.68%).   
 
 
The contribution (to total poverty) among households headed by women is greater than the contribution that comes from their representativeness in the total population ( 0.361 VS 0.205). As known, the absolute contribution to total poverty is given by the product of these two components: poverty in the group x population share of the group. (Compare between the population share of the female group and the relative contribution of that group to the total poverty).
However, of course, note that the relative and absolute contributions of female-headed households are smaller than those of male-headed households. 

*/


// Question 2.2
*Decomposing total poverty according to the region of household head (region).
dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(20600)
/*
. dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(20600)

    Decomposition of the FGT index by groups
    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  sweight
    Group variable  :  region
    Parameter alpha :  0.00
  +-----------------------------------------------------------------------------------+
  |          Group   |      FGT index     Population       Absolute        Relative   |
  |                  |                       share       contribution    contribution |
  |------------------+----------------------------------------------------------------|
  |central           |        0.172511        0.299749        0.051710        0.168533|
  |                  |        0.021242        0.016365        0.007205        0.023455|
  |eastern           |        0.339337        0.256752        0.087125        0.283958|
  |                  |        0.027234        0.013749        0.008720        0.028180|
  |northern          |        0.599108        0.188621        0.113005        0.368304|
  |                  |        0.047338        0.016391        0.015483        0.038845|
  |western           |        0.215728        0.254878        0.054984        0.179205|
  |                  |        0.027715        0.013794        0.007673        0.024078|
  |------------------+----------------------------------------------------------------|
  |Population        |        0.306824        1.000000        0.306824        1.000000|
  |                  |        0.017156        0.000000        0.017156        0.000000|
  +-----------------------------------------------------------------------------------+

*/
// Question 2.3


/*  The distribution of the adult equivalent expenditures is similar to that of the initial period (ae_exp), with the following slight differences
•	the adult equivalent expenditures have increased by 12% in region 3;
•	the adult equivalent expenditures have decreased by 6% in region 2;
Generating the variable ae_exp2, based on the information above. 
  */
gen ae_exp2= ae_exp*0.94 if region==2
replace ae_exp2= ae_exp*1.12 if region==3
replace ae_exp2= ae_exp if ae_exp2==.

//Question 2.4 
/* Decomposing the poverty gap change into growth and redistribution using the Shapley approach. Discuss the results. */

dfgtgr ae_exp ae_exp2, alpha(1) pline(20600)


/*
. dfgtgr ae_exp ae_exp2, alpha(1) pline(20600)

   Decomposition of the variation in the FGT index into growth and redistribution.
   Parameter alpha :         1.00
   Poverty line    :     20600.00
  -------------------------------------------------------------------------------------
                      |       Estimate            STE             LB              UB  
  --------------------+----------------------------------------------------------------
       Distribution_1 |        0.079957        0.007094        0.066033        0.093880
       Distribution_2 |        0.077030        0.006517        0.064238        0.089822
  --------------------+----------------------------------------------------------------
  Difference: (d2-d1) |       -0.002926        0.000942       -0.004775       -0.001078
  --------------------+----------------------------------------------------------------
                      |  Datt & Ravallion approach: reference period  t1               
  --------------------+----------------------------------------------------------------
      Growth          |        0.000231        0.000272       -0.000303        0.000765
      Redistribution  |       -0.003166        0.000892       -0.004917       -0.001415
      Residue         |        0.000009            ---             ---             ---
  --------------------+----------------------------------------------------------------
                      |  Datt & Ravallion approach: reference period  t2               
  --------------------+----------------------------------------------------------------
      Growth          |        0.000240        0.000282       -0.000313        0.000793
      Redistribution  |       -0.003157        0.000892       -0.004908       -0.001407
      Residue         |       -0.000009            ---             ---             ---
  --------------------+----------------------------------------------------------------
                      |  Shapley approach                                             
  --------------------+----------------------------------------------------------------
      Growth          |        0.000235        0.000277       -0.000308        0.000779
      Redistribution  |       -0.003162        0.000892       -0.004912       -0.001411
  -------------------------------------------------------------------------------------

*/

/*Comment: The shapley approach helps us to have a linear approximation of decomposing non-additive functions. The growth effect is an average of the previous two growth effects and the redistribution effect as an average of the two previous redistribution effects. This allows us to eliminate the residual as it sums up to zero. this is the oibserved difference from the previous decompositions. average income Growth is positive (0.000235) but inequality is negative (-0.003162) thus, we conclude that the observed poverty levels are as a result of redstributive of income with population */

//Question 2.5

dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(1) pline(20600)
/*
. dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(1) pline(20600)

    Decomposition of the FGT index by groups
    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  sweight
    Group variable  :  region
    Parameter alpha :  1.00
  +-----------------------------------------------------------------------------------+
  |          Group   |      FGT index     Population       Absolute        Relative   |
  |                  |                       share       contribution    contribution |
  |------------------+----------------------------------------------------------------|
  |central           |        0.036190        0.299749        0.010848        0.118782|
  |                  |        0.005377        0.016365        0.001766        0.021356|
  |eastern           |        0.086712        0.256752        0.022264        0.243782|
  |                  |        0.008955        0.013749        0.002561        0.032309|
  |northern          |        0.243506        0.188621        0.045930        0.502930|
  |                  |        0.028370        0.016391        0.008026        0.051172|
  |western           |        0.048195        0.254878        0.012284        0.134506|
  |                  |        0.006716        0.013794        0.001816        0.022031|
  |------------------+----------------------------------------------------------------|
  |Population        |        0.091326        1.000000        0.091326        1.000000|
  |                  |        0.008031        0.000000        0.008031        0.000000|
  +-----------------------------------------------------------------------------------+
*/

dfgtg ae_exp2, hgroup(region) hsize(hsize) alpha(1) pline(20600)

/*
. dfgtg ae_exp2, hgroup(region) hsize(hsize) alpha(1) pline(20600)

    Decomposition of the FGT index by groups
    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  sweight
    Group variable  :  region
    Parameter alpha :  1.00
  +------------------------------------------------------------------------------------+
  |           Group   |      FGT index     Population       Absolute        Relative   |
  |                   |                       share       contribution    contribution |
  |-------------------+----------------------------------------------------------------|
  |central            |        0.036190        0.299749        0.010848        0.123184|
  |                   |        0.005377        0.016365        0.001766        0.021754|
  |eastern            |        0.103596        0.256752        0.026598        0.302039|
  |                   |        0.009747        0.013749        0.002868        0.036339|
  |northern           |        0.203225        0.188621        0.038332        0.435287|
  |                   |        0.026696        0.016391        0.007224        0.053190|
  |western            |        0.048195        0.254878        0.012284        0.139490|
  |                   |        0.006716        0.013794        0.001816        0.022371|
  |-------------------+----------------------------------------------------------------|
  |Population         |        0.088063        1.000000        0.088063        1.000000|
  |                   |        0.007358        0.000000        0.007358        0.000000|
  +------------------------------------------------------------------------------------+
*/
/*Comment: The total poverty gap in the first scenario is 9.1% while in the scenario whith the changes in the incomes in eastern and northern region is 8.8 % a reduced poverty gap. a 12 % increase in the ae expenditure in northern region, decreases its absolute contribution to total poverty gap from 0.045930 to  0.038332 and 6% decrease in ae expenditure in eastern region also decreases the contribution to total poverty gap from  0.026598  to  0.022264. For other regions, their contributions remain the same */

** Excerise 3**4.5%

// Question 3.1 
clear
/*inputing the data and generating percentiles*/
input Identifier	weight	inc_t1	Inc_t2
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

// Question 3.2

qui sum inc_t1 [aw=weight]   			// To compute the mean of incomes in t1. Also, the summarize (sum in abbreviation ) returns the average as: r(mean)
scalar mean1=r(mean)         			// To   keep in memory the scalar  mean1 = r(mean) in t1
qui sum Inc_t2 [aw=weight]
scalar mean2=r(mean)         			// To   keep in memory the scalar  mean2 = r(mean) in t2
scalar g_mean = (mean2-mean1)/mean1
gen g_mean  = (mean2-mean1)/mean1    	// To generate the variable g_mean, which is equal to the growth in averages. 
dis "Mean 1              =" mean1
dis "Mean 2             = " mean2
dis "Growth in averages = " g_mean

// Question 3.3 

gen g_inc =(Inc_t2-inc_t1)/inc_t1 		// This variable with contain the individual growth in income. 
replace g_inc = 0 in 1             		// When the percentile = 0, the growth is also 0 // default values.  

// Question 3.4

line g_inc g_mean perc, ///
title(Growth Incidence Curve) ///
yline(`g_mean') ///
legend(order( 1 "GIC curve" 2 "Growth in average income")) ///
xtitle(Percentiles (p)) ytitle(Growth in incomes)  ///
plotregion(margin(zero))

/*Comment: The GIC is proportional change on incomes observed at different percentiles. We observe that the GIC is greater than the increase in mean income for all poor percintiles, thus we conclude that growth is relatively pro-poor in this economy. */

// Question 3.5
drop in 1
sum g_inc [aw=weight] if (inc_t1<10.4) 	// to compute the average income growths of poor individuals. 

/*
sum g_inc [aw=weight] if (inc_t1<10.4)  

    Variable |     Obs      Weight        Mean   Std. Dev.       Min        Max
-------------+-----------------------------------------------------------------
       g_inc |       6  .600000009   -.0812963   .0701759  -.1444445   .0266666
*/
dis = r(mean)
ipropoor inc_t1 Inc_t2, pline(10.4)   	// To compute different propoor indices with DASP
/*
. ipropoor inc_t1 Inc_t2, pline(10.4)  
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
*/

/*Comment: The Ravallion & Chen (2003) index is -0.081296 which is greater than the avergae Growth rate(g) of -0.301975 by 0.220679. The higher the index the greater the growth among the poor regardless of the incomes of the non-poor.*/

// Question 3.6

dfgtgr inc_t1 Inc_t2, alpha(1) pline(10.4)

/*
. dfgtgr inc_t1 Inc_t2, alpha(1) pline(10.4)

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

  
  Comment: The average growth effect from the previous two growth effects is    0.173659 while the average redesrtibution effect from the previous two redisrtibution is -0.028851.That we see that the mean income difference is possitive while mean inequality differences is negative. That these two factors affect poverty and inequality in opposite directions. While the mean income difference is postive implying there is growth in incomes between the two peoriods, the mean inequality chnages is negative implying that inequlaity is also increasing. That implies that the observed poverty in the society is as a result of distributive of income within the population.*/
