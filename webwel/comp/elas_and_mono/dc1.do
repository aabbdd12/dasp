clear
set obs 301
scalar a1 = 150
scalar d1= 1.50
gen q=(_n-1)


     gen p = a1-d1*q    
keep if p>=0
gen mr=150 - 2*d1*q
twoway (line p q) ( line mr q if mr>=0,  ysize(4) xsize(4) xtitle(Quantity (q) ) legend(order(1 "Price" 2 "Marginal revenue") ) graphregion(fcolor(white)) plotregion(margin(zero)))
