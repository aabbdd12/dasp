
#delimit ;
cap program drop emat_exc_shexp;
program define emat_exc_shexp, eclass;
syntax namelist (min=1 max=1) [,  PDES1(string) PDES2(string) PDES3(string) PDES4(string) PDES5(string) PDES6(string)]; 
version 15;
qui {;
tokenize `namelist' ;
 matrix list `1';
cap drop __res1-__res6 _tval _pval _lb _ub _lp ;
qui  svmat `1', name(__res) ;
local nrows = rowsof(`1');

svyset _n, vce(linearized) singleunit(missing);
qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local level = 95;
local lvl=(100-`level')/100;
local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');
local df1 = `fr';

qui gen _tval = __res4/__res5;
qui gen _pval = tprob(`df1',_tval);
qui gen _lb = __res4-invttail(`df1',`lvl')*__res5;
qui gen _ub = __res4+invttail(`df1',`lvl')*__res5;
qui gen _lp = __res6;
mkmat __res1-__res5 _tval _pval _lb _ub _lp in 1/`nrows', matrix(mymatri);
cap drop __res1-__res6 _tval _pval _lb _ub _lp;
};


local npl = rowsof(mymat)/4;

forvalues m=1/`npl' {;

local k = (`m'-1)*7;
forvalues i=1/7 {;
local m`i' = `i' + `k';
};

cap drop matrix aa;
local bg = (`m'-1)*4+1;
local eg = (`m'-1)*4+4;
matrix aa = mymatri[`bg'..`eg',.] ; 
matrix coln aa = "Pop_Share"   "Equal_Dist"  "Est_Dist"  "Difference"  "Std_Err"  "T_Stud"  "P_Val"  "CI_LL"  "CI_UL"  "Pov_Line"  ;
matrix rown aa = "Child" "Female" "Male" "All" ;
ereturn matrix pov_res_pline_`m' = aa;
};
end;
