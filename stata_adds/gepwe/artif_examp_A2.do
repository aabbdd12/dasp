#delimit cr
set seed 1234
clear
set obs 1000
gen     x1= _n-1
gen p=_n/1000
gen y  =  2000+ p*x1 + 60*uniform() 
qreg y x1, quantile(0.1)
predict  q_1
qreg y x1, quantile(0.2)
predict  q_2
qreg y x1, quantile(0.8)
predict  q_3
qreg y x1, quantile(0.9)
predict  q_4
#delimit ;
line q_* x1, legend(order(1 "p=0.1" 2 "p=0.2"  3 "p=0.8"  4 "p=0.9" ))
xtitle(Pecentiles) ytitle(Cofficient of X1)
 ylabel(, nogrid) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white))
 ;
