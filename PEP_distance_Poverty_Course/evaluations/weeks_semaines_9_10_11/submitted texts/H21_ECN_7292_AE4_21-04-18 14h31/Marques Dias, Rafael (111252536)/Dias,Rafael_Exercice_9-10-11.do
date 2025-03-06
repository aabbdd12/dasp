************11,5%

daspmenu
cd "/Users/rafaeldias/OneDrive - Université Laval/economia/2021/Pauvrete et inegalite ECN6992/data/"

***************************************************************************
//code Stata : Évaluation | Rafael Dias | Exercice 9-10-11 | 13 avril
***************************************************************************

//  EXERCICE 1
clear
input 	id	w1	w2	w3
		1	4	20	12
		2	8	12	0
		3	16	16	24
		4	12	12 	16
		5	28	20	8
		6	24	16	12
end

// Q1.1
imdp_uhi w1 w2 w3, pl1(14) pl2(14) pl3(14)
/*-------------------------------+
            |       Estimate     |
------------+--------------------|
Population  |           0.833    |
--------------------------------*/

// Q1.2
imdp_ihi w1 w2 w3, pl1(14) pl2(14) pl3(14)
/*-------------------------------+
            |       Estimate     |
------------+--------------------|
Population  |           0.167    |
--------------------------------*/

// Q1.3
imdp_mfi w1 w2 w3, pl1(14) pl2(14) pl3(14)


// Q1.4
gen w1_poor         =   w1<14
gen w2_poor         =   w2<14
gen w3_poor         =   w3<14

egen sum_w = rowtotal(w*_poor)

gen af_poor        =  (sum_w>=2)          

// Q1.5
imdp_afi w1 w2 w3, dcut(2) pl1(14) pl2(14) pl3(14)


***************************************************************************

//  EXERCICE 2
clear
input 	id	w1	w2	w3
		1	4	20	12
		2	8	12	0
		3	16	16	24
		4	12	12 	16
		5	28	20	8
		6	24	16	12
end

// Q2.1
* e = alpha = 1, alors on peut les exclure à la formule
scalar beta = .33333333
scalar z= 14

gen gap1 = (z-w1)/z*(z>w1) // l'écart de pauvreté de dimension i : rappelons que (z>wi)=1 si z>wi et zéro sinon.
gen gap2 = (z-w2)/z*(z>w2)
gen gap3 = (z-w3)/z*(z>w3) 

gen pi = beta*(gap1+gap2+gap3) // nous générons la variable pi

qui sum pi
scalar MDI_BC = r(mean) // Indice Bourguignon et Chakravarty
disp MDI_BC

// Q2.2
imdp_bci w1 w2 w3, alpha(1) gamma(1) b1(.33333333) pl1(14) b2(.33333333) pl2(14) b3(.33333333) pl3(14)

// Q2.3
gen nw_1 = (w1+w2+w3)/3
gen nw_2 = (w1+w2+w3)/3
gen nw_3 = (w1+w2+w3)/3

imdp_bci nw_1 nw_2 nw_3, alpha(1) gamma(1) b1(.33333333) pl1(14) b2(.33333333) pl2(14) b3(.33333333) pl3(14)


***************************************************************************

//  EXERCICE 3
use Canada_Incomes&Taxes_1996_2005_random_sample_3.dta, clear

// Q3.1
cnpe T B N, xvar(X) min(1000) max(31000) type(dnp)


// Q3.2
preserve
keep if year == 1999
igini X N
restore
/*---------------------------------------
year=1999   Variable   |       Estimate       
-----------------------+-----------------
1: GINI_X              |        0.482704    
2: GINI_N              |        0.332937   
----------------------------------------*/
preserve
keep if year == 2002
igini X N
restore
/*---------------------------------------
year=2002   Variable   |       Estimate       
-----------------------+-----------------
1: GINI_X              |        0.484478    
2: GINI_N              |        0.344567   
----------------------------------------*/
preserve
keep if year == 2005
igini X N
restore
/*---------------------------------------
year=2005   Variable   |       Estimate       
-----------------------+-----------------
1: GINI_X              |        0.472714    
2: GINI_N              |        0.335971   
----------------------------------------*/


// Q3.3
iprog T, ginc(X) type(t) index(ka) gobs(year)
/*----------------------------------
     gobs       |        Estimate    
----------------+-------------------
1993            |        0.067899       
1994            |        0.072604     
1996            |        0.098642    
1997            |        0.078426    
1998            |        0.095304  
1999            |        0.103618    
2000            |        0.100305  
2002            |        0.100064     
2003            |        0.106723   
2004            |        0.104125   
2005            |        0.109989  
-----------------------------------*/


// Q3.4
preserve
keep if year == 2005
cprog T, rank(X) type(t)
restore

// Q3.5
preserve
keep if year == 2005
igini N, hgroup(province)
restore
/*-----------------------------------------------
  Gini                 Group   |       Estimate  
-------------------------------+-----------------
1: Newfoundland                |       0.300561 
2: Prince_Edward_Island        |       0.283617  
3: Nova_Scotia                 |       0.312390 
4: New_Brunswick               |       0.321247 
5: Quebec                      |       0.319053   
6: Ontario                     |       0.339533     
7: Manitoba                    |       0.312695 
8: Saskatchewan                |       0.345459       
9: Alberta                     |       0.344673
10: British_Columbia           |       0.336080
-------------------------------+-----------------
Population                     |       0.335971
-------------------------------------------------*/

preserve
keep if year == 2005
iprog T, ginc(X) gobs(province) type(t) index(ka)
restore
/*----------------------------------------------
                     gobs   |       Estimate    
----------------------------+-------------------
Newfoundland                |        0.077626    
Prince_Edward_Island        |        0.077769   
Nova_Scotia                 |        0.113172    
New_Brunswick               |        0.087471     
Quebec                      |        0.118058     
Ontario                     |        0.104837    
Manitoba                    |        0.103341   
Saskatchewan                |        0.095888   
Alberta                     |        0.131228  
British_Columbia            |        0.123347   
-----------------------------------------------*/
