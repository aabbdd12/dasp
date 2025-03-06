*********11.5%

//Exercice1**************2.5%


// Using the latest updated DASP files
set more off
net from http://dasp.ecn.ulaval.ca/modules/DASP_V2.3/dasp
net install dasp_p1, force
net install dasp_p2, force
net install dasp_p3, force
net install dasp_p4, force
addDMenu profile.do _daspmenu 


//  Question 1.1

use data_b3_3.dta, replace
cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)                                       
legend(order( 1 "Perceived  minimum  well-being " 2 "Observed well-being"))  
subtitle("") title(The subjective poverty line) 						     
 xtitle(Observed well-being) 									             
 ytitle(Predicted level of the perceived  minimum  well-being )              
 vgen(yes)  
 /* Estimating the level of ae_exp when the difference between the predicted minimum well-being 
and the observed well-being is nil */
cap drop dif  
gen dif = _npe_min_ae_exp- ae_exp
cnpe ae_exp, xvar(dif) xval(0) vgen(yes) 

/*Showing the subjective poverty line  */
cnpe ae_exp  min_ae_exp, xvar(ae_exp) min(0) max(60000)                      
legend(order( 1 "Perceived  minimum  well-being " 2 "Observed well-being"))  
subtitle("") title(The subjective poverty line) 						     
xline( 22692.876953) xtitle(Observed well-being) 						     
ytitle(Predicted level of the perceived  minimum  well-being ) 

//  Question 1.2
//a) seuil de pauvrete subjectif
ifgt  ae_exp, alpha(0) hsize(hsize) pline(22692.876953)
//b) seuil de pauvrete absolu
ifgt  ae_exp, alpha(0) hsize(hsize) pline(20900)
//c)Seuil de pauvrete relatif
ifgt  ae_exp, alpha(0) hsize(hsize) opl(mean) prop(50)



//Exercice2****4.5%


//Question 2.1
dfgtg ae_exp, hgroup(sex) hsize(hsize) alpha(0) pline(20900)

//Question 2.2
dfgtg ae_exp, hgroup(region) hsize(hsize) alpha(0) pline(20900)

//Question 2.3
scalar ae_expregion1=ae_exp*(region==1)
scalar ae_expregion2=ae_exp*(region==2)*0.94 
scalar ae_expregion3=ae_exp*(region==3)*1.1 
scalar ae_expregion4=ae_exp*(region==4)
gen ae_exp2=  ae_expregion1 + ae_expregion2 + ae_expregion3+ ae_expregion4

//Question 2.4
dfgtgr ae_exp ae_exp2, alpha(1) pline(20900)

//Question 2.5
dfgtgr ae_exp ae_exp2,cond(activity & region) alpha(1) pline(20900)


//Exercice3*****4.5%


//Question 3.1
clear
input identifier	weight	inc_t1	inc_t2
0 0 0 0
1	0.1	1.50	1.54
2	0.1	4.50	3.85
3	0.1	7.50	6.60
4	0.1	3.00	2.75
5	0.1	4.50	4.40
6	0.1	9.00	7.70
7	0.1	10.50	8.80
8	0.1	15.00	7.70
9	0.1	11.00	6.60
10	0.1	13.50	6.60
end
sort inc_t1
gen perc=sum(weight)

//Question 3.2
qui sum inc_t1 [aw=weight] 
scalar mean1=r(mean) 
qui sum inc_t2 [aw=weight]
scalar mean2=r(mean)
scalar g_mean = (mean2-mean1)/mean1
gen g_mean  = (mean2-mean1)/mean1
dis "Mean 1              =" mean1
dis "Mean 2             = " mean2
dis "Growth in averages = " g_mean

//Question 3.3
gen g_inc =(inc_t2-inc_t1)/inc_t1
replace g_inc = 0 in 1

//Question 3.4
line g_inc g_mean perc, title(Growth Incidence Curve) yline(`g_mean') 
legend(order( 1 "GIC curve" 2 "Growth in average income")) 
xtitle(Percentiles (p)) ytitle(Growth in incomes)  
plotregion(margin(zero))

//Question 3.5
ipropoor inc_t1 inc_t2, pline(10.4)
// Les deux aboutissent aux mêmes résultats.

//Question 3.6
dfgtgr inc_t1 inc_t2, alpha(1) pline(10.2)
