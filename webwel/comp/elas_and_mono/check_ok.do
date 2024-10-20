clear
set obs 301
scalar a1 = 150
scalar a2 = 100
scalar d1= 1.50
scalar d2= 0.50
gen q=(_n-1)
local qs= (a2-a1)/(d2-d1)
local ps = a1-d1*`qs'

dis `qs' " " `ps'

     gen p = a1-d1*q     if q<=`qs'
replace  p = a2-d2*q     if q> `qs'

keep if p>=0
     gen el = p/(-d1*q)     if p<=`ps'
replace  el = p/(-d2*q)     if p> `ps'



/* assume that the cost by unit is 30 */
gen c=30


gen     mrn=a1-2*d1*q  if q<= `qs'
replace mrn=a2-2*d2*q  if q>  `qs'

sum
preserve
gen  p1  =p[_n-1]     
gen  q1  =q[_n-1]     
gen mrn1 =mrn[_n-1] 
replace q = q1 in 52/201
replace mrn= a2-2*d2*q in 52
*replace q=q[51] in 52


line p mrn q if p>0,  ysize(4) xsize(4) xtitle(Quantity (q)) ytitle(Price (p))  plotregion(margin(zero)) xline(`qs', lpattern(dot)) ///
legend(order( 1 "Price" 2 "Marginal Revenue"))  graphregion(fcolor(white)) plotregion(margin(zero))


restore


gen     profit=(p -c)*q


qui sum profit
list  if profit==r(max)
local pmax=r(max)
cap  gen l1= `pmax' in 1/70
qui sum el if profit==r(max)
qui gen l2= r(mean) in 70/100

twoway (line profit q in 1/100 , xline(70, lpattern(dash) lcolor(black)) legend(order(1 "Profit" 2 "Elasticity")) ) ///
(line el q in 60/100, yaxis(2)) ///
 (line l1 q in 1/70  , lpattern(dot) lcolor(black) ) ///
 (line l2 q in 71/100 , lpattern(dot) lcolor(black) yaxis(2) ) ///
 , xtitle(Quantity (q)) graphregion(fcolor(white)) plotregion(margin(zero)) ytitle(Profit) ytitle(Elasticity, axis(2))   ysize(4) xsize(4)



