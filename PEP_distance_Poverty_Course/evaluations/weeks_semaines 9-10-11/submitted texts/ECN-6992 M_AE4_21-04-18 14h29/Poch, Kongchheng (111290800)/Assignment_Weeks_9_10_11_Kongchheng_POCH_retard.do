******12,5%

//* Assignment Weeks 9, 10 and 11 *//

//* Exercise 1

// Q1.1
/* The result is as follows:
. input ind       w1 w2 w3

           ind         w1         w2         w3
  1. 1       4       20      12
  2. 2       8       12      0
  3. 3       16      16      24
  4. 4       12      12      16
  5. 5       28      20      8
  6. 6       24      16      12
  7. end

.                    
. gen pov_union = 0

. replace pov_union = 1 if w1<= 14
(3 real changes made)

. replace pov_union = 1 if w2<= 14
(0 real changes made)

. replace pov_union = 1 if w3<= 14
(2 real changes made)

. 
. sum pov_union

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
   pov_union |          6    .8333333    .4082483          0          1

. proportion pov_union

Proportion estimation             Number of obs   =          6

--------------------------------------------------------------
             |                                   Logit
             | Proportion   Std. Err.     [95% Conf. Interval]
-------------+------------------------------------------------
pov_union    |
           0 |   .1666667   .1666667      .0090658    .8138556
           1 |   .8333333   .1666667      .1861444    .9909342
--------------------------------------------------------------

. 
. imdp_uhi w1 w2 w3, pl1(14) pl2(14) pl3(14)

    M.D. Poverty index :  Union headcount index                          
-----------------------------------------------------------------------------+
            |       Estimate            STE             LB              UB   |
------------+----------------------------------------------------------------|
Population  |           0.833           0.167           0.497           1.169|
-----------------------------------------------------------------------------+

*/
clear
input ind	w1 w2 w3
1	4	20	12
2	8	12	0
3	16	16	24
4	12	12	16
5	28	20	8
6	24	16	12
end
		   
gen pov_union = 0
replace pov_union = 1 if w1<= 14
replace pov_union = 1 if w2<= 14
replace pov_union = 1 if w3<= 14

sum pov_union
proportion pov_union

imdp_uhi w1 w2 w3, pl1(14) pl2(14) pl3(14)


// Q1.2
/*
. gen pov_intersect = 1

. replace pov_intersect = 0 if w1>= 14
(3 real changes made)

. replace pov_intersect = 0 if w2>= 14
(1 real change made)

. replace pov_intersect = 0 if w3>= 14
(1 real change made)

. 
. sum pov_intersect

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
pov_inters~t |          6    .1666667    .4082483          0          1

. proportion pov_intersect

Proportion estimation             Number of obs   =          6

---------------------------------------------------------------
              |                                   Logit
              | Proportion   Std. Err.     [95% Conf. Interval]
--------------+------------------------------------------------
pov_intersect |
            0 |   .8333333   .1666667      .1861444    .9909342
            1 |   .1666667   .1666667      .0090658    .8138556
---------------------------------------------------------------

. 
. imdp_ihi w1 w2 w3, pl1(14) pl2(14) pl3(14)

    M.D. Poverty index :  Intersection headcount index                   
-----------------------------------------------------------------------------+
            |       Estimate            STE             LB              UB   |
------------+----------------------------------------------------------------|
Population  |           0.167           0.167          -0.169           0.503|
-----------------------------------------------------------------------------+

*/
 
gen pov_intersect = 1
replace pov_intersect = 0 if w1>= 14
replace pov_intersect = 0 if w2>= 14
replace pov_intersect = 0 if w3>= 14

sum pov_intersect
proportion pov_intersect

imdp_ihi w1 w2 w3, pl1(14) pl2(14) pl3(14)

// Q1.3
/* The union approach is more sensitive to the increase in individual multiple deprivations.
It can result in a substantial increase in poverty because if an individual falls short of a poverty dimension, he/she is considered poor.*/


// Q1.4
/*
. egen sum_w      =  rowtotal(w*) 

. gen    af_poor  =  (sum_w>=28)          // Alkire and Foster H0 :  the dual cut-off is equal to 2.             
>                                 

. gen  w_af_poor  =  (sum_w/3)*af_poor   // Alkire and Foster M0 

. mean af_poor w_af_poor

Mean estimation                   Number of obs   =          6

--------------------------------------------------------------
             |       Mean   Std. Err.     [95% Conf. Interval]
-------------+------------------------------------------------
     af_poor |   .8333333   .1666667       .404903    1.261764
   w_af_poor |   13.33333    2.90083      5.876512    20.79015
--------------------------------------------------------------

*/
egen sum_w      =  rowtotal(w*) 
gen    af_poor  =  (sum_w>=28)          // Alkire and Foster H0 :  the dual cut-off is equal to 2.                                             
gen  w_af_poor  =  (sum_w/3)*af_poor   // Alkire and Foster M0 
mean af_poor w_af_poor

// Q1.5
/* The estimation result is as follows:
. imdp_afi w1 w2 w3 , dcut(2) pl1(14) pl2(14) pl3(14)

    Alkire and Foster (2007) MDP indices
  +---------------------------------------------------------------------------------------------+
  |    Group   |     Pop. share             H0              M0              M1              M2  |
  |------------+--------------------------------------------------------------------------------|
  |Population  |           1.000           0.500           0.389           0.151           0.099|
  |            |           0.000           0.224           0.181           0.087           0.067|
  +---------------------------------------------------------------------------------------------+

    The relative contribution of dimensions to the Alkire and Foster (2007) 
    MDP indices estimated at population level (results in %).
  +-------------------------------------------------------------+
  |Dimensions  |            M0              M1              M2  |
  |------------+------------------------------------------------|
  |w1          |           42.86           47.37           40.23|
  |            |            5.48           17.81           26.07|
  |w2          |           28.57           10.53            2.30|
  |            |           11.40            5.90            1.49|
  |w3          |           28.57           42.11           57.47|
  |            |           11.40           16.96           25.91|
  +-------------------------------------------------------------+

*/
imdp_afi w1 w2 w3 , dcut(2) pl1(14) pl2(14) pl3(14)

/* Discussion:
The approach used in Q1.4 yielded an under-estimate of the poverty index.
The DASP command provided a better estimation of the multidimensional poverty index.
*/

// Q1.6

/* Targeting dimension 1 */
gen n_w1 = w1 + 24

gen n_pov_union = 0
replace n_pov_union = 1 if n_w1<= 14
replace n_pov_union = 1 if w2<= 14
replace n_pov_union = 1 if w3<= 14

proportion n_pov_union
imdp_uhi n_w1 w2 w3, pl1(14) pl2(14) pl3(14)

gen n_pov_intersect = 1
replace n_pov_intersect = 0 if n_w1>= 14
replace n_pov_intersect = 0 if w2>= 14
replace n_pov_intersect = 0 if w3>= 14

proportion n_pov_intersect
imdp_ihi n_w1 w2 w3, pl1(14) pl2(14) pl3(14)

/* Targeting dimension 2 */
drop n_pov_union
drop n_pov_intersect

gen n_w2 = w2 + 24

gen n_pov_union = 0
replace n_pov_union = 1 if w1<= 14
replace n_pov_union = 1 if n_w2<= 14
replace n_pov_union = 1 if w3<= 14

proportion n_pov_union
imdp_uhi w1 n_w2 w3, pl1(14) pl2(14) pl3(14)

gen n_pov_intersect = 1
replace n_pov_intersect = 0 if w1>= 14
replace n_pov_intersect = 0 if n_w2>= 14
replace n_pov_intersect = 0 if w3>= 14

proportion n_pov_intersect
imdp_ihi w1 n_w2 w3, pl1(14) pl2(14) pl3(14)

/* Targeting dimension 3 */
drop n_pov_union
drop n_pov_intersect

gen n_w3 = w3 + 24

gen n_pov_union = 0
replace n_pov_union = 1 if w1<= 14
replace n_pov_union = 1 if w2<= 14
replace n_pov_union = 1 if n_w3<= 14

proportion n_pov_union
imdp_uhi w1 w2 n_w3, pl1(14) pl2(14) pl3(14)

gen n_pov_intersect = 1
replace n_pov_intersect = 0 if w1>= 14
replace n_pov_intersect = 0 if w2>= 14
replace n_pov_intersect = 0 if n_w3>= 14

proportion n_pov_intersect
imdp_ihi w1 w2 n_w3, pl1(14) pl2(14) pl3(14)

/* If the government transfer is targeted for dimension 3, it will reduce the union index the most.
Whichever dimension the government transfer is targeted, it yields the same intersection index.
*/


//* Exercise 2

// Q2.1
/* The result is as follows.
. gen z1 = 14

. gen z2 = 14

. gen z3 = 14

. 
. scalar beta1 = 1/3

. scalar beta2 = 1/3

. scalar beta3 = 1/3

. 
. gen ngap1 = (z1-w1)/z1*(z1>w1) // the poverty gap of dimension 1 : remember that (z1>w1)=1 if z1>w1 and zero ot
> herwise. 

. gen ngap2 = (z2-w2)/z2*(z2>w2) // the poverty gap of dimension 2 : remember that (z2>w2)=1 if z2>w2 and zero ot
> herwise. 

. gen ngap3 = (z3-w3)/z3*(z3>w3) // the poverty gap of dimension 3 : remember that (z3>w3)=1 if z3>w3 and zero ot
> herwise. 

. 
. scalar alpha = 1

. scalar e = 1

. 
. cap drop pi  // try to drop the variable pi

. gen pi = (beta1*ngap1^e + beta2*ngap2^e + beta3*ngap3^e)^(alpha/e) // we generate the pi variable

. if ngap1==0 & ngap2==0 & ngap3==0 replace pi=0 // If the gaps in dimensions 1, 2 and 3 are nil, then pi is equa
> l to zero. 

. qui sum pi

. scalar MDP_BC = r(mean) // Bourguignon and Chakravarty index

. 
. dis MDP_BC
.18253969

*/
gen z1 = 14
gen z2 = 14
gen z3 = 14

scalar beta1 = 1/3
scalar beta2 = 1/3
scalar beta3 = 1/3

gen ngap1 = (z1-w1)/z1*(z1>w1) // the poverty gap of dimension 1 : remember that (z1>w1)=1 if z1>w1 and zero otherwise. 
gen ngap2 = (z2-w2)/z2*(z2>w2) // the poverty gap of dimension 2 : remember that (z2>w2)=1 if z2>w2 and zero otherwise. 
gen ngap3 = (z3-w3)/z3*(z3>w3) // the poverty gap of dimension 3 : remember that (z3>w3)=1 if z3>w3 and zero otherwise. 

scalar alpha = 1
scalar e = 1

cap drop pi  // try to drop the variable pi
gen pi = (beta1*ngap1^e + beta2*ngap2^e + beta3*ngap3^e)^(alpha/e) // we generate the pi variable
if ngap1==0 & ngap2==0 & ngap3==0 replace pi=0 // If the gaps in dimensions 1, 2 and 3 are nil, then pi is equal to zero. 
qui sum pi
scalar MDP_BC = r(mean) // Bourguignon and Chakravarty index

dis MDP_BC


// Q2.2
/* The result is as follows.
. imdp_bci w1 w2 w3, alpha(1) gamma(1) b1(0.333) pl1(14) b2(0.333) pl2(14) b3(0.333) pl3(14)

    M.D. Poverty index :  Bourguignon and Chakravarty (2003)             
-----------------------------------------------------------------------------+
            |       Estimate            STE             LB              UB   |
------------+----------------------------------------------------------------|
Population  |           0.182           0.079           0.023           0.342|
-----------------------------------------------------------------------------+

*/
imdp_bci w1 w2 w3, alpha(1) gamma(1) b1(0.333) pl1(14) b2(0.333) pl2(14) b3(0.333) pl3(14)


//  Q2.3
/* The result is as follows.
. gen nw1 = (w1 + w2 + w3)/3

. gen nw2 = (w1 + w2 + w3)/3

. gen nw3 = (w1 + w2 + w3)/3

. 
. imdp_bci w1 w2 w3, alpha(1) gamma(1) b1(0.333) pl1(14) b2(0.333) pl2(14) b3(0.333) pl3(14)

    M.D. Poverty index :  Bourguignon and Chakravarty (2003)             
-----------------------------------------------------------------------------+
            |       Estimate            STE             LB              UB   |
------------+----------------------------------------------------------------|
Population  |           0.182           0.079           0.023           0.342|
-----------------------------------------------------------------------------+

*/
gen nw1 = (w1 + w2 + w3)/3
gen nw2 = (w1 + w2 + w3)/3
gen nw3 = (w1 + w2 + w3)/3

imdp_bci w1 w2 w3, alpha(1) gamma(1) b1(0.333) pl1(14) b2(0.333) pl2(14) b3(0.333) pl3(14)

/* The BC index does not change because the weight of each well-being dimension is equalized.*/



//* Exercise 3

clear
use "C:\Users\kongchheng.poch\Documents\KC Training\PEP MAPI_20210118\MAPI_AssignW9-10-11\Canada_Incomes&Taxes_1996_2005_random_sample_3.dta"

// Q3.1

preserve
keep if year==2005
cnpe T B N, xvar(X) min(1000) max(31000) type(dnp)
restore

// Q3.2
/* 1999: The result is as follows:
 preserve

. keep if year==1999
(90,765 observations deleted)

. 
. igini X N

    Index            :  Gini index
    Sampling weight  :  sweight
----------------------------------------------------------------------------------------
            Variable   |       Estimate            STE             LB              UB  
-----------------------+----------------------------------------------------------------
1: GINI_X              |        0.482704        0.005474        0.471973        0.493435
2: GINI_N              |        0.332937        0.004406        0.324300        0.341574
----------------------------------------------------------------------------------------

. local Gini_X=el(e(est),1,1)

. local Gini_N=el(e(est),2,1)

. igini N, rank(X)

    Index            :  Concentration index
    Ranking variable :  X
    Sampling weight  :  sweight
----------------------------------------------------------------------------------------
            Variable   |       Estimate            STE             LB              UB  
-----------------------+----------------------------------------------------------------
1: CONC_N              |        0.305381        0.004695        0.296178        0.314583
----------------------------------------------------------------------------------------

. local CONC_N=el(e(est),1,1)

. dis "Difference = " `Gini_X' - `Gini_N'
Difference = .14976716

. dis "VE         = " `Gini_X' - `CONC_N'
VE         = .17732319

. dis "HI         = " `Gini_N' - `CONC_N'
HI         = .02755603

. restore

*/
preserve
keep if year==1999

igini X N
local Gini_X=el(e(est),1,1)
local Gini_N=el(e(est),2,1)
igini N, rank(X)
local CONC_N=el(e(est),1,1)
dis "Difference = " `Gini_X' - `Gini_N'
dis "VE         = " `Gini_X' - `CONC_N'
dis "HI         = " `Gini_N' - `CONC_N'
restore

/* 2002: The result is as follows:
. preserve

. keep if year==2002
(91,116 observations deleted)

. 
. igini X N

    Index            :  Gini index
    Sampling weight  :  sweight
----------------------------------------------------------------------------------------
            Variable   |       Estimate            STE             LB              UB  
-----------------------+----------------------------------------------------------------
1: GINI_X              |        0.484478        0.005663        0.473377        0.495579
2: GINI_N              |        0.344567        0.004579        0.335592        0.353543
----------------------------------------------------------------------------------------

. local Gini_X=el(e(est),1,1)

. local Gini_N=el(e(est),2,1)

. igini N, rank(X)

    Index            :  Concentration index
    Ranking variable :  X
    Sampling weight  :  sweight
----------------------------------------------------------------------------------------
            Variable   |       Estimate            STE             LB              UB  
-----------------------+----------------------------------------------------------------
1: CONC_N              |        0.320307        0.004759        0.310978        0.329636
----------------------------------------------------------------------------------------

. local CONC_N=el(e(est),1,1)

. dis "Difference = " `Gini_X' - `Gini_N'
Difference = .13991103

. dis "VE         = " `Gini_X' - `CONC_N'
VE         = .16417122

. dis "HI         = " `Gini_N' - `CONC_N'
HI         = .02426019

. restore

*/
preserve
keep if year==2002

igini X N
local Gini_X=el(e(est),1,1)
local Gini_N=el(e(est),2,1)
igini N, rank(X)
local CONC_N=el(e(est),1,1)
dis "Difference = " `Gini_X' - `Gini_N'
dis "VE         = " `Gini_X' - `CONC_N'
dis "HI         = " `Gini_N' - `CONC_N'
restore

/* 2005: The result is as follows:
. preserve

. keep if year==2005
(91,664 observations deleted)

. 
. igini X N

    Index            :  Gini index
    Sampling weight  :  sweight
----------------------------------------------------------------------------------------
            Variable   |       Estimate            STE             LB              UB  
-----------------------+----------------------------------------------------------------
1: GINI_X              |        0.472714        0.005778        0.461387        0.484040
2: GINI_N              |        0.335971        0.004715        0.326728        0.345214
----------------------------------------------------------------------------------------

. local Gini_X=el(e(est),1,1)

. local Gini_N=el(e(est),2,1)

. igini N, rank(X)

    Index            :  Concentration index
    Ranking variable :  X
    Sampling weight  :  sweight
----------------------------------------------------------------------------------------
            Variable   |       Estimate            STE             LB              UB  
-----------------------+----------------------------------------------------------------
1: CONC_N              |        0.314413        0.004854        0.304898        0.323927
----------------------------------------------------------------------------------------

. local CONC_N=el(e(est),1,1)

. dis "Difference = " `Gini_X' - `Gini_N'
Difference = .13674247

. dis "VE         = " `Gini_X' - `CONC_N'
VE         = .15830094

. dis "HI         = " `Gini_N' - `CONC_N'
HI         = .02155846

. restore

*/
preserve
keep if year==2005

igini X N
local Gini_X=el(e(est),1,1)
local Gini_N=el(e(est),2,1)
igini N, rank(X)
local CONC_N=el(e(est),1,1)
dis "Difference = " `Gini_X' - `Gini_N'
dis "VE         = " `Gini_X' - `CONC_N'
dis "HI         = " `Gini_N' - `CONC_N'
restore

// Q3.3
/* The Kakwani progressivity index can be estimated using 'iprog' command.
The result is as follows:
. iprog T, ginc(X) hsize(hhsize) gobs(year) type(t) index(ka)

    Index                    :  Kakwani progressivity index
    Gross income variable    :  X
    Household size           :  hhsize
    Sampling weight          :  sweight
    gobs variable            :  year
---------------------------------------------------------------------------------
         gobs   |       Estimate            STE             LB              UB  
----------------+----------------------------------------------------------------
1993            |        0.067648        0.003749        0.060300        0.074996
1994            |        0.073560        0.004038        0.065645        0.081476
1996            |        0.101285        0.004609        0.092250        0.110320
1997            |        0.086321        0.006556        0.073470        0.099171
1998            |        0.102671        0.004524        0.093804        0.111539
1999            |        0.111415        0.003578        0.104401        0.118429
2000            |        0.106796        0.003699        0.099546        0.114046
2002            |        0.111500        0.004233        0.103202        0.119798
2003            |        0.112625        0.003303        0.106150        0.119099
2004            |        0.110759        0.003881        0.103152        0.118366
2005            |        0.115607        0.003546        0.108657        0.122558
---------------------------------------------------------------------------------

*/
iprog T, ginc(X) hsize(hhsize) gobs(year) type(t) index(ka)

// Q3.4
/* The TR progressivity condition for the tax T can be checked using the 'cprog' command.*/
preserve
keep if year==2005
cprog T, rank(X) type(t) appr(tr)


// Q3.5
/* The inequality can be estimated using the Gini index. The result is as follows:
. igini X N, hgroup(province)

    Index            :  Gini index
    Sampling weight  :  sweight
    Group variable   :  province
-----------------------------------------------------------------------------------------------------
                            Group   |       Estimate            STE             LB              UB  
------------------------------------+----------------------------------------------------------------
1: Newfoundland                     |        0.535053        0.005593        0.524091        0.546016
2: Prince_Edward_Island             |        0.485137        0.008337        0.468797        0.501476
3: Nova_Scotia                      |        0.494503        0.005290        0.484136        0.504871
4: New_Brunswick                    |        0.495080        0.005291        0.484710        0.505450
5: Quebec                           |        0.500697        0.004149        0.492566        0.508829
6: Ontario                          |        0.468998        0.003319        0.462493        0.475504
7: Manitoba                         |        0.474137        0.005048        0.464242        0.484031
8: Saskatchewan                     |        0.477834        0.004488        0.469037        0.486631
9: Alberta                          |        0.468749        0.004675        0.459586        0.477912
10: British_Columbia                |        0.479874        0.005434        0.469222        0.490525
------------------------------------+----------------------------------------------------------------
Population                          |        0.484202        0.001888        0.480502        0.487902
-----------------------------------------------------------------------------------------------------

Based on the estimates in the table above, inequality in Newfoundland is the highest. 
*/
igini X N, hgroup(province)

/* The Kakwani tax progressivity index can be checked using the 'iprog' command.
The result is as follows:
. iprog T, ginc(X) hsize(hhsize) gobs(province) index(ka)

    Index                    :  Kakwani progressivity index
    Gross income variable    :  X
    Household size           :  hhsize
    Sampling weight          :  sweight
    gobs variable            :  province
---------------------------------------------------------------------------------------------
                     gobs   |       Estimate            STE             LB              UB  
----------------------------+----------------------------------------------------------------
Newfoundland                |        0.053468        0.003501        0.046604        0.060332
Prince_Edward_Island        |        0.077587        0.005436        0.066927        0.088247
Nova_Scotia                 |        0.079003        0.003045        0.073034        0.084972
New_Brunswick               |        0.071652        0.003148        0.065481        0.077824
Quebec                      |        0.086002        0.002889        0.080338        0.091665
Ontario                     |        0.092772        0.002286        0.088290        0.097253
Manitoba                    |        0.104603        0.003276        0.098182        0.111024
Saskatchewan                |        0.087375        0.002838        0.081812        0.092938
Alberta                     |        0.105888        0.003123        0.099767        0.112009
British_Columbia            |        0.089744        0.003933        0.082033        0.097454
---------------------------------------------------------------------------------------------

Based on the estimates in the table above, the Kakwani tax progressivity index in Alberta is the highest.
*/
iprog T, ginc(X) hsize(hhsize) gobs(province) index(ka)

restore

/* END */
