set more off
#delim ;
capture program drop quantile ;
program define quantile, rclass sortpreserve;
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


cap program drop densi;                    
program define densi, rclass;              
args fw x xval;                       
qui su `x' [aw=`fw'], detail;           
local tmp = (`r(p75)'-`r(p25)')/1.34;                          
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ; 
qui sum `fw'; 
local h   = 0.09*`tmp'*_N^(-1.0/5.0);                          
tempvar s1 s2;                                                  
gen `s1' = sum( `fw' *exp(-0.5* ( ((`xval'-`x')/`h')^2  )  ));  
gen `s2' = sum( `fw' );
return scalar den = `s1'[_N]/( `h'* sqrt(2*c(pi)) * `s2'[_N] );  
end;


/*********************************/

/*Artificial Example */
#delimit cr
set seed 1234
clear
set obs 1000
gen     x1= _n-1
gen p=_n/1000
gen income =  1000 + p*x1 + 0.00001*uniform()

gen minr = 0
gen maxr = 0
gen perc = 0

gen est1=0
gen est2=0
gen est3=0
gen est4=0
forvalues i=0/10 {
local perc= `i'/10 + 0.05
local j=`i'+1
qreg income  x1  , quantile(`perc') 
replace minr=`i'/10 in `j'
replace maxr=(`i'+1)/10  in `j'
replace perc=`perc'  in `j'
replace est1 = _b[x1]  in `j'
}


gen www=1
#delimit ;
cap drop c_*;

forvalues i=1/10 {;
local prc=`i'/10 - 0.05;
/*
rifreg income x1, quantile(`prc')  kernop(gaussian)  ;
replace est2 = el(r(table),1,1)  in `i';

*/

quantile www p `prc' ;
local qnt = r(quantile);

qui su p , detail     ;       
local tmp    = (`r(p75)'-`r(p25)')/1.34    ;                       
local tmp    = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)'  ;  
local band   =     0.3*`tmp'*_N^(-1.0/5.0);
cap drop ww;
cap drop www;
gen www=1;
cap drop fw;
qui gen fw   = (exp(-0.5* ( ((`qnt'-p)/`band')^2  )  )   )^0.5 / ( `band'* sqrt(2*c(pi)) * `r(N)' ) ;


regress income x1 [aw=fw];
cap replace est3 = _b[x1]  in `i';

/******/

quantile w income `prc';

local qnt = r(quantile);

densi w income `qnt' ;
local fy = r(den);

cap drop rif;
gen rif = `qnt'+(`prc' - (income<=`qnt'))/`fy';
regress rif x1;
replace est2 = el(r(table),1,1)  in `i';

/*********/

sum x1 if p>(`prc'-0.0001) & p<(`prc'+0.0001);
local val = r(mean);
qui cnpe inc, xvar(x1) type(dnp) approach(lle) xval(`val') ;
cap replace est4 = r(est1)  in `i';
};


list minr maxr perc  est4 est1  est2 est3   in 1/10 , separator(300);

line est4  est1  est2 est3   perc in 1/10
, legend(order( 1 "True value" 2 "Quantile regression" 3 "Unconditional Quantile Regression" 4 "Weighed Percentile Regression")) 
xtitle(Pecentiles) ytitle(Cofficient of X1)
 ylabel(, nogrid) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white))
;



/*
dydx income x1, generate(dy)
line dy x1

*/
