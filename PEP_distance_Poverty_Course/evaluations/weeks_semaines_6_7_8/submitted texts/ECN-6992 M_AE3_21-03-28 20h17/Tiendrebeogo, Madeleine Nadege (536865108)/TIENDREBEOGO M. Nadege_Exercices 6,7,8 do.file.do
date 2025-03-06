****************9.5% 
 *EXERCICE 3*****4%
 
 3.1	Insérez les données, puis générez les centiles (basé sur le rang des revenus 
 de la période initiale (variable perc)), et le premier centile doit être égal à zéro).
 
 
 *(4 variables, 11 observations pasted into data editor)
 
. sum identifier weight inc_t1 inc_t2

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
  identifier |         11           5    3.316625          0         10
      weight |         11    .0909091    .0301511          0         .1
      inc_t1 |         11    7.363636    5.040292          0         15
      inc_t2 |         11        5.14    2.831978          0        8.8

	  
*  sort inc_t1
* gen perc=sum(weight)

R:  list perc

     +------+
     | perc |
     |------|
  1. |    0 |
  2. |   .1 |
  3. |   .2 |
  4. |   .3 |
  5. |   .4 |
     |------|
  6. |   .5 |
  7. |   .6 |
  8. |   .7 |
  9. |   .8 |
 10. |   .9 |
     |------|
 11. |    1 |
     +------+

3.2	Initialisez le scalaire g_mean, qui est égal au taux de croissance du revenu moyen.


.  qui sum inc_t1 [aw=weight]

.  scalar mean1=r(mean)

.  qui sum inc_t2 [aw=weight]

.  scalar mean2=r(mean)

.  scalar g_mean = (mean2-mean1)/mean1

.  gen g_mean  = (mean2-mean1)/mean1 
 list g_mean

     +-----------+
     |    g_mean |
     |-----------|
  1. | -.3019753 |
  2. | -.3019753 |
  3. | -.3019753 |
  4. | -.3019753 |
  5. | -.3019753 |
     |-----------|
  6. | -.3019753 |
  7. | -.3019753 |
  8. | -.3019753 |
  9. | -.3019753 |
 10. | -.3019753 |
     |-----------|
 11. | -.3019753 |
     +-----------+


avec : 

	 * dis "Mean 1              =" mean1
Mean 1              =8.1

	* dis "Mean 2             = " mean2
Mean 2             = 5.6539999

donc : dis "Growth in averages = " g_mean
Growth in averages = -.30197531

R: -0.30197531


3.3	Générez la variable g_inc, comme la croissance des revenus individuels.
 
 gen g_inc =(inc_t2-inc_t1)/inc_t1
(1 missing value generated)

.  replace g_inc = 0 in 1
(1 real change made)

R: list g_inc

     +-----------+
     |     g_inc |
     |-----------|
  1. |         0 |
  2. |  .0266666 |
  3. | -.0833333 |
  4. | -.1444445 |
  5. | -.0222222 |
     |-----------|
  6. |      -.12 |
  7. | -.1444445 |
  8. | -.1619047 |
  9. |      -.45 |
 10. | -.5111111 |
     |-----------|
 11. | -.4866667 |
     +-----------+

	 
3.4	Dessinez la courbe d’incidence de la croissance à l’aide 
des variables g_inc et perc. Discutez des résultats.
 
 R:
 *line g_inc g_mean perc
 
 *discutons les résultats
Lorsque le percentile = 0, la croissance individuelle des revenus = 0.
La croissance des moyennes (g_mean) est constante quelque soit la valeur des percentiles.


3.5	Supposons que le seuil de pauvreté est égal à 10.4. Estimez l'indice pro-pauvres de Chen et Ravallion (2003)

R:
.  drop in 1
(1 observation deleted)

.  sum g_inc [aw=weight] if (inc_t1<10.4)

    Variable |     Obs      Weight        Mean   Std. Dev.       Min        Max
-------------+-----------------------------------------------------------------
       g_inc |       6  .600000009   -.0812963   .0701759  -.1444445   .0266666

.  dis = r(mean)
-.08129631

. ipropoor inc_t1 inc_t2, pline(10.4)
   Poverty line    :        10.40
   Parameter alpha :         0.00
  -----------------------------------------------------------------------------------------------
               Pro-poor indices |       Estimate            STE             LB              UB  
  ------------------------------+----------------------------------------------------------------
                 Growth rate(g) |       -0.301975        0.068365       -0.456627       -0.147324
  ------------------------------+----------------------------------------------------------------
  Ravallion & Chen (2003) index |       -0.316687        0.164438       -0.688673        0.055299
  Ravallion & Chen (2003) - g   |       -0.014711        0.116486       -0.278222        0.248799
  ------------------------------+----------------------------------------------------------------
  Kakwani & Pernia (2000) index |        1.333333        0.418947        0.385609        2.281058
  ------------------------------+----------------------------------------------------------------
                     PEGR index |       -0.402634        0.181351       -0.812877        0.007610
                     PEGR - g   |       -0.100658        0.136631       -0.409739        0.208422
  -----------------------------------------------------------------------------------------------

  *discutons
Plus la croissance parmi les pauvres est eleve quelque soit l'evolution des revenus parmi les non-pauvres,
plus l'indice Ravalion et Chen est eleve. en ce sens, ils sont concernes par la croissance absolue en faveur des pauvres.



3.6 	En utilisant l'approche de Shapley, décomposez le changement de l'intensité 
de la pauvreté en composantes de croissance et de redistribution. Discutez des résultats.
net from C:\DASP_V2.3\dasp
net install dasp_p1, force
net install dasp_p2, force
net install dasp_p3, force
net install dasp_p4, force
_daspmenu


R: 
	* dfgtgr inc_t1 inc_t2, alpha(1) pline(10.4)

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


	* discutons
Cette approche de Shapley est une approximation lineaire qui permet de decomposer des fonctions non additives. 
Elle mesure les effets de croissance pur (0.173659) et de redistribution pur (-0.028851). Le residue dans la 
decomposition de la pauvrete apparait donc nul d'apres le principe de cette methode de Shapley.



EXERCICE 2

2.1. 

R:
 
 *	dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20900)

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

	*	Conclusion
Les contributions relative et absolue (à la pauvreté totale) des ménages dirigés par des 
femmes sont inférieures à celles des ménages dirigés par des hommes.

2.2.

R:
	* dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(20900)

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
  |central           |        0.224916        0.268071        0.060293        0.165048|
  |                  |        0.027233        0.016345        0.008466        0.024568|
  |eastern           |        0.307212        0.266545        0.081886        0.224155|
  |                  |        0.026473        0.015916        0.008619        0.027066|
  |northern          |        0.721940        0.217543        0.157053        0.429918|
  |                  |        0.046327        0.024678        0.024949        0.049207|
  |western           |        0.266609        0.247841        0.066077        0.180879|
  |                  |        0.034500        0.015462        0.010135        0.028092|
  |------------------+----------------------------------------------------------------|
  |Population        |        0.365309        1.000000        0.365309        1.000000|
  |                  |        0.022878        0.000000        0.022878        0.000000|
  +-----------------------------------------------------------------------------------+

	
2.3.

R:

•	Les dépenses en équivalent-adultes ont augmenté de 11% dans la région 3
dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(1) pline(20900)

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
  |central           |        0.053819        0.268071        0.014427        0.119299|
  |                  |        0.009016        0.016345        0.002622        0.026096|
  |eastern           |        0.080410        0.266545        0.021433        0.177228|
  |                  |        0.007902        0.015916        0.002446        0.030960|
  |northern          |        0.321715        0.217543        0.069987        0.578717|
  |                  |        0.041079        0.024678        0.015490        0.064243|
  |western           |        0.060875        0.247841        0.015087        0.124756|
  |                  |        0.009835        0.015462        0.002767        0.027431|
  |------------------+----------------------------------------------------------------|
  |Population        |        0.120934        1.000000        0.120934        1.000000|
  |                  |        0.014569        0.000000        0.014569        0.000000|
  +-----------------------------------------------------------------------------------+


•	Les dépenses en équivalent-adultes ont diminué de 6% dans la région 2;
dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(20900)

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
  |central           |        0.224916        0.268071        0.060293        0.165048|
  |                  |        0.027233        0.016345        0.008466        0.024568|
  |eastern           |        0.307212        0.266545        0.081886        0.224155|
  |                  |        0.026473        0.015916        0.008619        0.027066|
  |northern          |        0.721940        0.217543        0.157053        0.429918|
  |                  |        0.046327        0.024678        0.024949        0.049207|
  |western           |        0.266609        0.247841        0.066077        0.180879|
  |                  |        0.034500        0.015462        0.010135        0.028092|
  |------------------+----------------------------------------------------------------|
  |Population        |        0.365309        1.000000        0.365309        1.000000|
  |                  |        0.022878        0.000000        0.022878        0.000000|
  +-----------------------------------------------------------------------------------+

  
   * itargetg ae_exp, alpha(1) pline(20900) hsize(hsize) hgroup(region) constam(1)

    Targeting population groups and poverty
    Targeting  groups  :  Groups => region 
    Targeting  scheme  :  Lump-sum (constant)
    Normalized by cost :  no
    Household size     :  hsize
    Sampling weight    :  sweight
    Parameter alpha    :  1.00
    Poverty line       : 20900.00
  +---------------------------------------------------------------------------+
  |  Group   |   Population         FGT index      Impact on        Impact on |
  |          |      Share                           Group          Population |
  |----------+----------------------------------------------------------------|
  |central   |     0.268070787     0.053819198    -0.000010762    -0.000002885|
  |          |     0.016345365     0.009015542     0.000001303     0.000000405|
  |eastern   |     0.266545475     0.080409922    -0.000014699    -0.000003918|
  |          |     0.015915919     0.007902111     0.000001267     0.000000412|
  |northern  |     0.217542857     0.321715117    -0.000034543    -0.000007514|
  |          |     0.024678381     0.041079145     0.000002217     0.000001194|
  |western   |     0.247840881     0.060874887    -0.000012756    -0.000003162|
  |          |     0.015462485     0.009834803     0.000001651     0.000000485|
  |----------+----------------------------------------------------------------|
  |Population|     1.000000000     0.120934367    -0.000017479    -0.000017479|
  |          |     0.000000000     0.014569446     0.000001095     0.000001095|
  +---------------------------------------------------------------------------+

2.4.

R:

 dfgtgr ae_exp min_ae_exp, alpha(1) pline(20900) hsize1(region) hsize2(region)

   Decomposition of the variation in the FGT index into growth and redistribution.
   Parameter alpha :         1.00
   Poverty line    :     20900.00
  -------------------------------------------------------------------------------------
                      |       Estimate            STE             LB              UB  
  --------------------+----------------------------------------------------------------
       Distribution_1 |        0.115151        0.013903        0.087861        0.142440
       Distribution_2 |        0.066931        0.007349        0.052507        0.081356
  --------------------+----------------------------------------------------------------
  Difference: (d2-d1) |       -0.048219        0.006760       -0.061487       -0.034951
  --------------------+----------------------------------------------------------------
                      |  Datt & Ravallion approach: reference period  t1               
  --------------------+----------------------------------------------------------------
      Growth          |        0.035088        0.003164        0.028877        0.041299
      Redistribution  |       -0.079207        0.007787       -0.094492       -0.063923
      Residue         |       -0.004099            ---             ---             ---
  --------------------+----------------------------------------------------------------
                      |  Datt & Ravallion approach: reference period  t2               
  --------------------+----------------------------------------------------------------
      Growth          |        0.030988        0.002251        0.026570        0.035406
      Redistribution  |       -0.083307        0.006333       -0.095738       -0.070875
      Residue         |        0.004099            ---             ---             ---
  --------------------+----------------------------------------------------------------
                      |  Shapley approach                                             
  --------------------+----------------------------------------------------------------
      Growth          |        0.033038        0.006886        0.019522        0.046554
      Redistribution  |       -0.081257        0.007006       -0.095008       -0.067506
  -------------------------------------------------------------------------------------
  
  * discutons
Cette approche de Shapley est une approximation lineaire qui permet de decomposer des fonctions non additives. 
Elle mesure les effets de croissance pur (0.033038) et de redistribution pur (-0.081257). Le residue dans la 
decomposition de la pauvrete apparait donc nul d'apres le principe de cette methode de Shapley.


2.5.

R:




EXERCICE 1

1.1.

. difgt ae_exp min_ae_exp, alpha(0) hsize1(hsize) hsize2(hsize) opl1(mean) prop1(50) opl2(mean) prop2(50)
------------------------------------------------------------------------------------------
Variable |   Estimate   Std. Err.       t     P>|t|       [95% Conf. interval]  Pov. line
---------+--------------------------------------------------------------------------------
  ae_exp |    .26328    .0200258    13.147   0.0000       .2239728    .3025872     16991
min_ae_exp| .1016817    .0213657   4.75911   0.0000       .0597445    .1436189  14997.09
---------+--------------------------------------------------------------------------------
    diff.| -.1615983    .0122556  -13.1857   0.0000       -.185654   -.1375426      ---
------------------------------------------------------------------------------------------

R: 14997.09


1.2.


a) ifgt ae_exp, alpha(0) hsize(hsize) pline(14997.09)

    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  sweight
    Parameter alpha :  0.00
-----------------------------------------------------------------------------------------------
   Variable   |       Estimate            STE             LB              UB         Pov. line
--------------+--------------------------------------------------------------------------------
ae_exp        |        0.203112        0.023758        0.156479        0.249744        14997.09
-----------------------------------------------------------------------------------------------

R: 0.203112 



b)	 ifgt ae_exp, alpha(0) hsize(hsize) pline(20900)

    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  sweight
    Parameter alpha :  0.00
-----------------------------------------------------------------------------------------------
   Variable   |       Estimate            STE             LB              UB         Pov. line
--------------+--------------------------------------------------------------------------------
ae_exp        |        0.365309        0.022878        0.320402        0.410215        20900.00
-----------------------------------------------------------------------------------------------

R : 0.365309

c)
 sum ae_exp

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
      ae_exp |      3,000     40031.5    41609.92   3374.894   583743.4

 ifgt ae_exp, alpha(0) hsize(hsize) opl(mean) prop(50)

    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  sweight
    Parameter alpha :  0.00
-----------------------------------------------------------------------------------------------
   Variable   |       Estimate            STE             LB              UB         Pov. line
--------------+--------------------------------------------------------------------------------
ae_exp        |        0.263280        0.020026        0.223973        0.302587        16991.00
-----------------------------------------------------------------------------------------------

R:  0.263280  


1.3.
R: 
