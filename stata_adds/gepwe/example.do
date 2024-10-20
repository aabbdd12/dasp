use "data", replace
/* Generating weights around the percentile 0.4  and 0.6*/
gen fw= hhsize*wta_hh // individual extrapolation weight
gepwe pcexp [aw=fw], nper(2) per1(0.4) per2(0.6)
line _pcw pcexp if pcexp<1000000  , sort 

/* Generating weights around the percentile 0.5 */
/* By default the the new generated variable is _pcw */
gepwe pcexp [aw=fw], nper(1) per1(0.5)
sum pcexp [aw=fw], d
line _pcw pcexp if pcexp<1000000  , sort 

/* Performing the percentile weighed the regression */
gen lexp = log(pcexp)

/* Simple OLS model */
xi: reg  lexp i.hhedlevel hhagey i.hhsex hhsize i.rururb [pw=fw] 
eststo m1

/* Weighed Percentile Regression mnodel */
xi: reg  lexp i.hhedlevel hhagey i.hhsex hhsize i.rururb [pw=_pcw] 
eststo m2

/* Quntile Regression mnodel */
xi: qreg  lexp i.hhedlevel hhagey i.hhsex hhsize i.rururb [pw=fw] , quantile(0.5)
eststo m3

esttab m1 m2 m3

