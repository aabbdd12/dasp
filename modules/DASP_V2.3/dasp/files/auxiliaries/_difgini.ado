
#delimit ;


#delimit ;
capture program drop _difgini;
program define _difgini, rclass;
syntax varlist(min=2 max=2) [, HSize(varname)];
preserve; 
tokenize `varlist';
tempvar fw;

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
qui gen `fw'=`hsize';
if ("`hweight'"~="")    qui replace `fw'=`fw'*`hweight';

qui sort `1' ;
tempvar smw smwy l1smwy ca;
gen `smw'  =sum(`fw');
gen `smwy' =sum(`1'*`fw');
gen `l1smwy'=0;
local mu=`smwy'[_N]/`smw'[_N];
local suma=`smw'[_N];
qui count;
forvalues i=2/`r(N)' { ;
qui replace `l1smwy'=`smwy'[`i'-1]  in `i';
};
gen `ca'=`mu'+`1'*((1.0/`smw'[_N])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[_N])*(2.0*`l1smwy'+`fw'*`1'); 
sum `ca' [aw=`fw'], meanonly; 
return scalar gini = `r(mean)'/(2*`mu');
/*


**************************/
local xi = `r(mean)';
tempvar vec_a vec_b vec_c vec_d  theta v1 v2 sv1 sv2;
            qui count;
            qui count;
            local fx=0;
            gen `v1'=`fw'*`1';
            gen `v2'=`fw';
            gen `sv1'=sum(`v1');
            gen `sv2'=sum(`v2') ;
            qui replace `v1'=`sv1'[`r(N)']   in 1;
            qui replace `v2'=`sv2'[`r(N)']   in 1;
			qui replace `v1'=`sv1'[`r(N)']-`sv1'[_n-1]   in 2/`=_N'; 
			qui replace `v2'=`sv2'[`r(N)']-`sv2'[_n-1]   in 2/`=_N';
			gen `theta'=`v1'-`v2'*`1';
			qui replace `theta'=`theta'*(2.0/`suma')  in 1/`=_N'; 
			tempvar fxvar;
			qui gen `fxvar'=sum(`fw'*`1');
			local fx = `fxvar'[`=_N']/`suma';
            qui  gen `vec_a' = `hsize'*((1.0)*`ca'+(`1'-`fx')+`theta'-(1.0)*(`xi'));
            qui  gen `vec_b' =  2*`hsize'*`1';
	
cap drop `theta';
cap drop `v1';
cap drop `v2'; 
cap drop `sv1';
cap drop `sv2'; 
			
qui sort `2' ;
tempvar smw smwy l1smwy ca;
gen `smw'  =sum(`fw');
gen `smwy' =sum(`2'*`fw');
gen `l1smwy'=0;
local mu=`smwy'[_N]/`smw'[_N];
local suma=`smw'[_N];
qui count;
qui replace `l1smwy'=`smwy'[_n-1]  in 2/`=_N';
gen `ca'=`mu'+`2'*((1.0/`smw'[_N])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[_N])*(2.0*`l1smwy'+`fw'*`2'); 
sum `ca' [aw=`fw'], meanonly; 
local xi = `r(mean)';

            qui count;
            local fx=0;
            gen `v1'=`fw'*`2';
            gen `v2'=`fw';
            gen `sv1'=sum(`v1');
            gen `sv2'=sum(`v2') ;
            qui replace `v1'=`sv1'[`r(N)']   in 1;
            qui replace `v2'=`sv2'[`r(N)']   in 1;
			qui replace `v1'=`sv1'[`r(N)']-`sv1'[_n-1]   in 2/`=_N'; 
			qui replace `v2'=`sv2'[`r(N)']-`sv2'[_n-1]   in 2/`=_N';
			gen `theta'=`v1'-`v2'*`2';
			qui replace `theta'=`theta'*(2.0/`suma')  in 1/`=_N'; 
			tempvar fxvar;
			qui gen `fxvar'=sum(`fw'*`2');
			local fx = `fxvar'[`=_N']/`suma';
            qui  gen `vec_c' = `hsize'*((1.0)*`ca'+(`2'-`fx')+`theta'-(1.0)*(`xi'));
            qui  gen `vec_d' =  2*`hsize'*`2';			
	       
			qui svy: mean `vec_a' `vec_b'  `vec_c'  `vec_d' ;

qui nlcom (_b[`vec_a']/_b[`vec_b'] - _b[`vec_c']/_b[`vec_d']) , iterate(10000);
tempname aa;
matrix `aa'=r(b);
local dif = el(`aa',1,1);
return scalar dif = -`dif';

tempname vv;
matrix `vv'=r(V);
local sdif = el(`vv',1,1)^0.5;
return scalar sdif = `sdif';

qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local tval = -`dif'/`sdif';
return scalar tval = `tval';
local pval = 1-2*(normal(abs(`tval'))-0.5);
if `sdif'==0 local pval = 0; 
return scalar pval = `pval';


qui nlcom (_b[`vec_a']/_b[`vec_b'] ) , iterate(10000);
tempname aa;
matrix `aa'=r(b);
local g0 = el(`aa',1,1);
return scalar g0 = `g0';

tempname vv;
matrix `vv'=r(V);
local sg0 = el(`vv',1,1)^0.5;
return scalar sg0 = `sg0';

qui nlcom (_b[`vec_c']/_b[`vec_d'] ) , iterate(10000);
tempname aa;
matrix `aa'=r(b);
local g1 = el(`aa',1,1);
return scalar g1 = `g1';

tempname vv;
matrix `vv'=r(V);
local sg1 = el(`vv',1,1)^0.5;
return scalar sg1 = `sg1';


		
restore;
end;
