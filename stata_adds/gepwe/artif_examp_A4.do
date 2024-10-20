

/*Artificial Example with discreete var*/

/*
The case: assume the variable tr is the treatment dummy variable.
We assume that some idividuals of the group of percentile p are treated.

with a sample size of 4000 obs, the pecentile 1/200 will represent the first 20 observations as an approximation,
2/200 the second 20, and so one.

for samplicity, we assume that 10 of each group are treated and 10 non treated. 
The imapct of treatment varies. it is: 
10 if p in 0.0 to 0.2;
20 if p in 0.2 to 0.4;
26  if p in 0.4 to 0.6;
32 if p in 0.6 to 0.8;
44  if p in 0.8 to 1.0;
*/

set more off
#delim ;
capture program drop quantile;
program define quantile, rclass;
version 8.0;
args www yyy perc;
preserve;
sort `yyy';
cap drop if `yyy'>=.;
cap drop if `www'>=.;
tempvar _ww _qp _pc _finqp;
qui gen `_ww'=sum(`www');
gen `_pc'=`_ww'/`_ww'[_N];
gen `_qp' = `yyy' ;
qui sum `yyy' [aw=`www'];
qui sum  [aw=`www'];
local pcf=`perc';
local av=`j'+1;
local i = 1;
while (`pcf' > `_pc'[`i']) {;
local i=`i'+1;
};
local ar=`i'-1;
return scalar quantile =`_qp'[`i'] ;
restore;
end;

/*********************************/




#delimit cr
set seed 1234
clear
set obs 4000

gen     x1=  3*_n^1.2
gen     x2= (_n-1)

gen v=int((_n-1)/20)+1
gen p=min(1,v/200)
sum p

gen treatment = .
local cho=1
forvalues i=1(10)4000 {
local j=min(`i'+10, 4000)
dis `i' "  " `j'
replace treatment=( `cho' == 1 ) in `i'/`j'
local cho = `cho'*(-1)
}

gen         x3= treatment *10 if p>=0.0 & p<=0.2
replace     x3= treatment *20 if p> 0.2 & p<=0.4
replace     x3= treatment *26 if p> 0.4 & p<=0.6
replace     x3= treatment *32 if p> 0.6 & p<=0.8
replace     x3= treatment *44 if p> 0.8 & p<=1.0


gen income =  1000 + x1+ p*x2 + x3+  0.00001*uniform()

cap drop    ext4

gen         est4= 0 





gen minr = 0
gen maxr = 0
gen perc = 0

gen est1=0
gen est2=0
gen est3=0
gen est33=0

forvalues i=0/10 {
local perc= `i'/10 + 0.05
local j=`i'+1
qreg income  x1 x2 treatment , quantile(`perc') 
replace minr=`i'/10 in `j'
replace maxr=(`i'+1)/10  in `j'
replace perc=`perc'  in `j'
replace est1 = _b[treatment]  in `j'
}







gen www=1
#delimit ;
cap drop c_*;

forvalues i=1/10 {;
local prc=`i'/10 - 0.05;
rifreg income x1 x2 treatment, quantile(`prc')  kernop(gaussian)  ;
replace est2 = el(r(table),1,3)  in `i';



quantile www p `prc' ;
local qnt = r(quantile);

qui su p , detail     ;       
local tmp    = (`r(p75)'-`r(p25)')/1.34    ;                       
local tmp    = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)'  ;  
local band   =     0.10*`tmp'*_N^(-1.0/5.0);
local band2  =     0.018*`tmp'*_N^(-1.0/5.0);
cap drop ww;
cap drop www;
gen www=1;
cap drop fw fw2;
qui gen fw   =  (exp(-0.5* ( ((`qnt'-p)/`band')^2  )  )   )^0.5 / ( `band'* sqrt(2*c(pi)) * `r(N)' ) ;
qui gen fw2   = (exp(-0.5* ( ((`qnt'-p)/`band2')^2  )  )   )^0.5 / ( `band2'* sqrt(2*c(pi)) * `r(N)' ) ;

regress income x1 x2 treatment [aw=fw];
cap replace est3 = _b[treatment]  in `i';

regress income x1 x2 treatment [aw=fw2];
cap replace est33 = _b[treatment]  in `i';
/******/


replace     est4= 10 if `prc'>=0.0 & `prc'<=0.2  in `i';
replace     est4= 20 if `prc'> 0.2 & `prc'<=0.4  in `i';
replace     est4= 26 if `prc'> 0.4 & `prc'<=0.6  in `i';
replace     est4= 32 if `prc'> 0.6 & `prc'<=0.8  in `i';
replace     est4= 44 if `prc'> 0.8 & `prc'<=1.0  in `i';
};


list minr maxr perc  est4  est1 est2 est3 est33   in 1/10 , separator(300);

line est4 est1 est3 est33   perc in 1/10
, legend(order( 1 "True value" 2 "Quantile Regression " 3 "WPR" 4 "WPR and lower bandwidth" )) 
xtitle(Pecentiles) ytitle(Cofficient of X2) legend(size(small))

;



/*
dydx income x2, generate(dy)
line dy x2

*/
