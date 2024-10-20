clear
set obs 201
scalar a22 =  0.016
scalar d22 =  0.75
gen q=(_n)*0.5


scalar a1 = 150
scalar d1= 1.50
gen p1 = a1-d1*q  


gen p2 = a22^(-1/d22)/(q^(d22))


scalar a1 = 150
scalar a2 = 70
scalar d1= 4.20
scalar d2= 0.70
local qs= (a2-a1)/(d2-d1)
local ps = a1-d1*`qs'

dis `qs' " " `ps'

     gen p3 = a1-d1*q     if q<=`qs'
replace  p3 = a2-d2*q     if q> `qs'



twoway (line p1 p2 p3 q in 4/201,  ysize(4) xsize(4) xtitle(Quantity (q) ) ///
graphregion(fcolor(white)) plotregion(margin(zero)) ///
legend(order(1 "Linear : 150 - 0.5q " 2 "Segmented ( a{subscript:1}=150, a{subscript:2}=70 // {&delta}{subscript:1}=4.2, {&delta}{subscript:2}=0.7)" 3 "CES ({&delta}= 0.75)") size(small) ) ///
legend(cols(1) ring(0) pos(1))) 

list in  1/10



