clear
set obs 301
scalar a1 =  0.025
scalar d1 =  0.75
gen q=(_n)


gen p = a1^(-1/d1)/(q^(d1))
gen r = a1^(-1/d1)*q /( q^(d1))   
gen dr=r[_n]-r[_n-1]
replace dr=p[1] in 1
gen mr=( a1^(-1/d1)*(1-d1))*q^(-d1)


twoway (line p q) ( line mr q if mr>=0,  ysize(4) xsize(4) xtitle(Quantity (q) ) legend(order(1 "Price" 2 "Marginal revenue") ) graphregion(fcolor(white)) plotregion(margin(zero)))
list in  1/10



