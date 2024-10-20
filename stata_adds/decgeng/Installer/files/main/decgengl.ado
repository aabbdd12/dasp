
#delimit ;
cap program drop bdecgengl;
program define bdecgengl, rclas;
syntax varlist(min=2 max=2)[, 
indcon(string) 
nindcat(string) 
extend(varname)
excat(int 0)
eindcon(string) 
enindcat(string)
DEC(int  4)
DREGRES(int 0)
NITER(int 0)
HWEIGHT(string)
indcat(string) 
   *];
 preserve ;
 bsample ;



tokenize `varlist';
local depvar `1';
local sex    `2' ;

/*
qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
*/


tempvar sw;
qui gen double `sw'=1;
if ("`hweight'"~="")        qui replace `sw'=`hweight';



#delimit cr

local mycmd  qui xi: regress `depvar' `indcon' `nindcat' _constant [pw= `sw']
`mycmd' if `sex'==1 , nocons
tempvar pym pyf bstar
qui predict `pym', xb
qui estat summarize
matrix estm = e(b)'
matrix est2= r(stats)
local nrows = rowsof(estm)
forvalues i=1/`nrows' {
qui getRowName estm `i'
local  coef = r(rowname)
local scoef =  subinstr("`coef'",".","_",.)
if ("`scoef'" == "o__constant") local scoef = "_constant"
local acoef =  subinstr("`scoef'","o.","",1)
local b_m_`acoef' =  _b[`coef'] 

}

`mycmd' if `sex'==2 , nocons
cap drop `pyf'
qui predict `pyf', xb
qui estat summarize
matrix estm = e(b)'
matrix est2= r(stats)
local nrows = rowsof(estm)
forvalues i=1/`nrows' {
qui getRowName estm `i'
local  coef = r(rowname)
local scoef =  subinstr("`coef'",".","_",.)
if ("`scoef'" == "o__constant") local scoef = "_constant"
local acoef =  subinstr("`scoef'","o.","",1)
local b_f_`acoef' =  _b[`coef'] 
}


`mycmd' , nocons
cap drop `bstar'
tempvar bstar
qui predict `bstar', xb
qui estat summarize
matrix estm = e(b)'
matrix est2= r(stats)
local nrows = rowsof(estm)
forvalues i=1/`nrows' {
qui getRowName estm `i'
local  coef = r(rowname)
local scoef =  subinstr("`coef'",".","_",.)
if ("`scoef'" == "o__constant") local scoef = "_constant"
local acoef =  subinstr("`scoef'","o.","",1)
local b_s_`acoef' =  _b[`coef'] 
}


foreach var of varlist `indcon' `nindcat' _constant   {
if "`b_m_`var''"=="" local  b_m_`var' = 0
if "`b_f_`var''"=="" local  b_f_`var' = 0
if "`b_s_`var''"=="" local  b_s_`var' = 0     
}    




	
/* GENDER GAP (D) */
qui sum `pym' if `sex'==1 [aw=`sw']
local YM =  r(mean)

qui sum `pyf' if `sex'==2 [aw=`sw']
local YF =  r(mean)
local D =  `YM'-`YF'

/* Endowment Effect */
qui sum  `bstar' if `sex'==1 [aw=`sw']
local meanM = r(mean)
qui sum  `bstar' if `sex'==2 [aw=`sw']
local meanF = r(mean)
local EE = `meanM'-`meanF'


/* Male structural advantage : MSA*/
local MSA = (`YM'-`meanM')

/* Female structural disadvantage : FSD*/
local FSD = (`meanF'-`YF')




 
return clear
return scalar EE  = `EE'
return scalar MSA = `MSA'
return scalar FSD = `FSD'

cap drop _I*
cap drop _est*
cap drop _constant

restore
end





#delimit ;
cap program drop decgengl;
program define decgengl, rclas;
syntax varlist(min=2 max=2)[, 
indcon(string) 
indcat(string) 
extend(varname)
eindcon(string) 
eindcat(string)
DEC(int  4)
DREGRES(int 0)
NITER(int 0)
HWEIGHT(string)
   *];
tokenize `varlist';
local depvar `1';
local sex    `2' ;


qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

tempvar sw;
qui gen double `sw'=1;
if ("`hweight'"~="")        qui replace `sw'=`hweight';


#delimit cr
local i=1
if ("`indcat'" ~= "") {
foreach var of varlist `indcat' {
qui gencatvar `var'	
local cat_`var' = "`r(slist)'"
local nindcat `nindcat' `cat_`var''
local i = `i' + 1
}
}
cap drop _constant
qui gen double      _constant = 1

local mycmdo   qui xi: regress `depvar' `indcon' `nindcat'  [pw= `sw']
`mycmdo' if `sex'==1 
eststo m3
local mycmd   qui xi: regress `depvar' `indcon' `nindcat' _constant [pw= `sw']
`mycmd'  if `sex'==1 , nocons
tempvar pym pyf
qui predict `pym', xb
qui estat summarize
matrix estm = e(b)'
matrix est2= r(stats)
local nrows = rowsof(estm)
forvalues i=1/`nrows' {
qui getRowName estm `i'
local  coef = r(rowname)
local scoef =  subinstr("`coef'",".","_",.)
if ("`scoef'" == "o__constant") local scoef = "_constant"
local acoef = subinstr("`scoef'","o.","",1)
local b_m_`acoef' =  _b[`coef'] 
}




`mycmdo' if `sex'==2 
eststo m2
`mycmd'  if `sex'==2 , nocons
cap drop `pyf'
qui predict `pyf', xb
qui estat summarize
matrix estm = e(b)'
matrix est2= r(stats)
local nrows = rowsof(estm)
forvalues i=1/`nrows' {
qui getRowName estm `i'
local  coef = r(rowname)
local scoef =  subinstr("`coef'",".","_",.)
if ("`scoef'" == "o__constant") local scoef = "_constant"
local acoef = subinstr("`scoef'","o.","",1)
local b_f_`acoef' =  _b[`coef'] 
}


`mycmdo'
eststo m1
`mycmd' , nocons
cap drop `bstar'
tempvar bstar
qui predict `bstar', xb
qui estat summarize
matrix estm = e(b)'
matrix est2= r(stats)
local nrows = rowsof(estm)
forvalues i=1/`nrows' {
qui getRowName estm `i'
local  coef = r(rowname)
local scoef =  subinstr("`coef'",".","_",.)
if ("`scoef'" == "o__constant") local scoef = "_constant"
local acoef =  subinstr("`scoef'","o.","",1)
local b_s_`acoef' =  _b[`coef'] 
}


foreach var of varlist `indcon' `nindcat' _constant    {
if "`b_m_`var''"=="" local  b_m_`var' = 0
if "`b_f_`var''"=="" local  b_f_`var' = 0
if "`b_s_`var''"=="" local  b_s_`var' = 0     
}    




/* GENDER GAP (D) */
qui sum `pym' if `sex'==1 [aw=`sw']
local YM =  r(mean)

qui sum `pyf' if `sex'==2 [aw=`sw']
local YF =  r(mean)
local D =  `YM'-`YF'

/* Endowment Effect */
qui sum  `bstar' if `sex'==1 [aw=`sw']
local meanM = r(mean)
qui sum  `bstar' if `sex'==2 [aw=`sw']
local meanF = r(mean)
local EE = `meanM'-`meanF'


/* Male structural advantage : MSA*/
local MSA = (`YM'-`meanM')


/* Female structural disadvantage : FSD*/
local FSD = (`meanF'-`YF')




if (`niter'>0) {

/* Table 02 */	
tempvar  stres2
qui gen `stres2' = .

forvalues i= 1/5 {
tempvar  bres_2_`i'
qui gen `bres_2_`i'' = .
}



                           local excat = 0
if "`cat_`extend''" ~= ""  local excat = 1
forvalues b=1/`niter' {
 bdecgengl `0' nindcat(`nindcat')	 enindcat(`enindcat') ocat_extend(`cat_`extend'') excat(`excat')
qui replace `bres_2_1' = `r(EE)'  in `b'
qui replace `bres_2_2' = `r(MSA)' in `b'
qui replace `bres_2_3' = `r(FSD)' in `b'
dis "Iter : `b'"
}



qui mean  `bres_2_1' in 1/`niter'
cap matrix drop zzz
matrix zzz = e(V)
local STE_EE = el(zzz,1,1)^0.5 

qui mean  `bres_2_2' in 1/`niter'
cap matrix drop zzz
matrix zzz = e(V)
local STE_MSA = el(zzz,1,1)^0.5 


qui mean  `bres_2_3' in 1/`niter'
cap matrix drop zzz
matrix zzz = e(V)
local STE_FSD = el(zzz,1,1)^0.5 

return scalar sest1  = `STE_EE'
return scalar sest2  = `STE_MSA'
return scalar sest3  = `STE_FSD'		
}



return scalar est1  = `EE'
return scalar est2 = `MSA'
return scalar est3 = `FSD'




cap drop _I*
cap drop _est*
cap drop _constant



end

