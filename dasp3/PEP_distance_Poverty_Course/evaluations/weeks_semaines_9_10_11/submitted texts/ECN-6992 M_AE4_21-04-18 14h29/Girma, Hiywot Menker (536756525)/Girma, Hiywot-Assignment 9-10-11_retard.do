****************10%

//Excercise 1*********4%

//Q.1.1 

gen w1=1
replace w1=0 if var2>7
gen w2=1
replace w2=0 if var3>7
gen w3=1
replace w3=0 if var4>7
list ind w1 w2 w3

//Q.1.2
//union and intersection head count index

imdp_uhi var2 var3 var4, pl1(7) pl2(7) pl3(7)
imdp_ihi var2 var3 var4, pl1(7) pl2(7) pl3(7)

//Q. 1.4
mpi d1(w1) d2(w2) d3(w3), cutoff(.66) alph(0)
mpi d1(var2) d2(var3) d3(var4) t1(7)t2(7)t3(7), cutoff(.66)
 
//Q. 1.5
imdp_afi var2 var3 var4, dcut(2) w1(1) pl1(7) w2(1) pl2(7) w3(1) pl3(7)

//Q. 1.6
mpi d1(new2) t1(7) d2(new3)t2(7) d3(new4) t3(7), cutoff(0.66) alpha(0)

//Excercise 2*******3%


set obs 6 
qui input  x1 z1 x2 z2 x3 z3 
 2 7 10 7 6 7
 4 7 6 7 0 7
 8 7 8 7 12  7
 6 7 6 7 8 7
 14 7 10 7 4 7
 12 7 8 7 6  7 
scalar beta1 = 0.333
scalar beta2 = 0.333
scalar beta3 = 0.333

//Q2.1 
forvalues alpha = 0/1 {
*dis _n
cap drop ngap*
gen ngap1 = (z1-x1)/z1*(z1>x1)
gen ngap2 = (z2-x2)/z2*(z2>x2)
gen ngap3 = (z2-x3)/z3*(z3>x3)
forvalues e = 1/2 {
cap drop pi
gen pi = (beta1*ngap1^`e' + beta2*ngap2^`e' + beta3*ngap3^`e')^(`alpha'/`e')
if ngap1==0 & ngap2==0  & ngap3==0 replace pi=0
qui sum pi 
scalar MDI_BC = r(mean)

dis "The MDI_BC Index (alpha ="%4.2f `alpha' ", epsilon ="%4.2f `e' " ) : "  "CASE 1 = " _col(40) %6.4f  MDI_BC
}
}

//Q2.2 
imdp_bci x1 x2 x3, alpha(1) gamma(1) b1(0.333) pl1(7) b2(0.333) pl2(7) b3(0.333) pl3(7)

//Q2.3

set obs `=_N+1'


replace x1=(x1[1]+x2[1]+ x3[1])/3  in l 
replace x2=(x1[1]+x2[1]+ x3[1])/3  in l 
replace x3=(x1[1]+x2[1]+ x3[1])/3  in l 

set obs `=_N+1'
replace x1=(x1[2]+x2[2]+ x3[2])/3  in l 
replace x2=(x1[2]+x2[2]+ x3[2])/3  in l 
replace x3=(x1[2]+x2[2]+ x3[2])/3  in l 

set obs `=_N+1'
replace x1=(x1[3]+x2[3]+ x3[3])/3  in l 
replace x2=(x1[3]+x2[3]+ x3[3])/3  in l 
replace x3=(x1[3]+x2[3]+ x3[3])/3  in l 

replace z1 = 7 if z1==. 
replace z2 = 7 if z2==.  
replace z3 = 7 if z3==.  

drop in 1/3 

imdp_bci x1 x2 x3, alpha(1) gamma(1) b1(0.333) pl1(7) b2(0.333) pl2(7) b3(0.333) pl3(7)

//Excercise 3******3%


//Q.3.1
preserve
keep if year==2005
cnpe T B N, xvar(X) min(1000) max(3000)
cnpe T B N, xvar(X) type (dnp) min(1000) max(3000)
restore 
//Q.3.2

keep if year==1999 | year==2002 | year==2005 

igini X, hgroup(year)
igini N, hgroup(year)


//Q.3.3

iprog T, ginc(X) hsize(hhsize) gobs(year) type(t) index(ka)

//Q.3.4
preserve
keep if year==2005
cprog T, rank(X) type(t) 
restore

//Q.3.5
preserve
keep if year==2005
igini X, hsize(hhsize) hgroup(province)
iprog T, ginc(X) hsize(hhsize) gobs(province) type(t) index(ka)
restore















