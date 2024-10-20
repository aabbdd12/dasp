
#delimit ;
cap program drop bdecgeng;
program define bdecgeng, eclas;
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
indcat(string) 
   *];
 preserve ;
 bsample ;

if ("`extend'" ~= "" & `excat' == 1 ) {;
qui gencatvar `extend';	
local cat_`extend' = "`r(slist)'";
};



tokenize `varlist';
local depvar `1';
local sex    `2' ;

/*
qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
*/

/* Copying  the sampling weight */
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear;
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

if ("`extend'"~="") {
if "`cat_`extend''" ~= "" {
tokenize `cat_`extend'' 
_nargs   `cat_`extend''
local numbcate = $indica+1 
local b_m_`extend' = 0
local b_f_`extend' = 0
local b_s_`extend' = 0 

forvalues j=2/`numbcate'  {
local b_m_`extend' = `b_m_`extend'' +  `b_m__I`extend'_`j''
local b_f_`extend' = `b_f_`extend'' +  `b_f__I`extend'_`j''
local b_s_`extend' = `b_s_`extend'' +  `b_s__I`extend'_`j''
}
}
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

local SE  = `MSA' + `FSD' 

matrix aaaa = ( `D' \ `EE' \ `SE' \ `MSA' \ `FSD' )

 
tempvar res0 res1 res2 res3 res4
qui gen  `res0'=""
qui gen double `res1' =.
qui gen double `res2' =.
qui gen double `res3' =.
qui gen double `res4' =.
local i = 1

local suma1 = 0
local suma2 = 0
local suma3 = 0	
local suma4 = 0

foreach var of varlist `indcon' `nindcat' _constant {
qui sum `var' if `sex'==1 [aw=`sw']
local mm = r(mean)
qui sum `var' if `sex'==2 [aw=`sw']
local mf = r(mean)
qui replace `res0' = "`var'" in `i'
qui replace `res1' = (`mm'-`mf')*`b_s_`var'' in `i'	
qui replace `res2' = (`b_m_`var''- `b_s_`var'')*`mm' in `i'	
qui replace `res3' = (`b_s_`var''- `b_f_`var'')*`mf' in `i'	
qui replace `res4' = `res1' + `res2' +`res3'  in `i'	
local suma1 = `suma1' + `res1'[`i']
local suma2 = `suma2' + `res2'[`i']
local suma3 = `suma3' + `res3'[`i']	
local suma4 = `suma4' + `res4'[`i']
local i = `i' +1
}
qui replace `res0' = "All " in `i'
qui replace `res1' = `suma1' in `i'	
qui replace `res2' = `suma2' in `i'	
qui replace `res3' = `suma3' in `i'	
qui replace `res4' = `suma4'  in `i'	


mkmat `res1' `res2' `res3' `res4'  in 1/`i' , matrix(bbbb) rownames(`res0')




if ("`extend'"~="") {
 
//set trace on
local i=1

cap drop _constant
qui gen double      _constant = 1



if "`cat_`extend''" == "" {
local mycmd  qui xi: regress `extend' `eindcon' `enindcat' _constant [pw= `sw']


`mycmd' if `sex'==1 , nocons
tempvar pym pyf `bstar't
qui predict `pym', xb 
qui estat summarize
matrix estm = e(b)'
matrix est2= r(stats)
local nrows = rowsof(estm)
forvalues i=1/`nrows' {
qui getRowName estm `i'
local  ecoef = r(rowname)
local escoef =  subinstr("`ecoef'",".","_",.)
if ("`escoef'" == "o__constant") local escoef = "_constant"
local eacoef =  subinstr("`escoef'","o.","",1)
local eb_m_`aecoef' =  _b[`ecoef'] 
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
local  ecoef = r(rowname)
local escoef =  subinstr("`ecoef'",".","_",.)
if ("`escoef'" == "o__constant") local escoef = "_constant"
local eacoef =  subinstr("`escoef'","o.","",1)
local eb_f_`aecoef' =  _b[`ecoef'] 
}


`mycmd' , nocons

cap drop `ebstar'
tempvar ebstar
qui predict `ebstar', xb
qui estat summarize
matrix estm = e(b)'
matrix est2= r(stats)
local nrows = rowsof(estm)
forvalues i=1/`nrows' {
qui getRowName estm `i'
local  ecoef = r(rowname)
local escoef =  subinstr("`ecoef'",".","_",.)
if ("`escoef'" == "o__constant") local escoef = "_constant"
local eacoef =  subinstr("`escoef'","o.","",1)
local eb_s_`aecoef' =  _b[`ecoef']  
}

}

if "`cat_`extend''" ~= "" {
forvalues j=2/`numbcate'  {

qui xi: regress _I`extend'_`j' `eindcon' `enindcat' _constant   if `sex'==1 [pw= `sw'], nocons
tempvar pym_`j' pyf_`j' `bstar't_`j'
qui predict `pym_`j'', xb 
qui estat summarize
cap matrix drop estm
cap matrix drop est2
matrix estm = e(b)'
matrix est2= r(stats)
local nrows = rowsof(estm)


forvalues i=1/`nrows' {
qui getRowName estm `i'
local  ecoef = r(rowname)
local eb_m_`ecoef' =  0
}

forvalues i=1/`nrows' {
qui getRowName estm `i'
local  ecoef = r(rowname)
local escoef =  subinstr("`escoef'",".","_",.)
local eb_m_`ecoef'_`j' =  _b[`ecoef'] 
local eb_m_`ecoef' =  `eb_m_`ecoef'' + `eb_m_`ecoef'_`j''
}


qui xi: regress _I`extend'_`j' `eindcon' `enindcat' _constant   if `sex'==2 [pw= `sw'], nocons
cap drop `pyf_`j''
qui predict `pyf_`j'', xb
qui estat summarize
cap matrix drop estm
cap matrix drop est2
matrix estm = e(b)'
matrix est2= r(stats)
local nrows = rowsof(estm)

forvalues i=1/`nrows' {
qui getRowName estm `i'
local  ecoef = r(rowname)
local eb_f_`ecoef' =  0
}
forvalues i=1/`nrows' {
qui getRowName estm `i'
local  ecoef = r(rowname)
local escoef =  subinstr("`escoef'",".","_",.)
local eb_f_`ecoef'_`j' =  _b[`ecoef'] 
local eb_f_`ecoef'     =  `eb_f_`ecoef'' + `eb_f_`ecoef'_`j''
}



qui xi: regress _I`extend'_`j' `eindcon' `enindcat' _constant  [pw= `sw'] , nocons


cap drop `ebstar_`j''
tempvar ebstar_`j'
qui predict `ebstar_`j'', xb
qui estat summarize
cap matrix drop estm
cap matrix drop est2
matrix estm = e(b)'
matrix est2= r(stats)
local nrows = rowsof(estm)
forvalues i=1/`nrows' {
qui getRowName estm `i'
local  ecoef = r(rowname)
local eb_s_`ecoef' =  0
}
forvalues i=1/`nrows' {
qui getRowName estm `i'
local  ecoef = r(rowname)
local escoef =  subinstr("`escoef'",".","_",.)
local eb_s_`ecoef'_`j' =  _b[`ecoef'] 
local eb_s_`ecoef' =  `eb_s_`ecoef'' + `eb_s_`ecoef'_`j''
}

	
}	
	
}

local suma1 = 0
local suma2 = 0
local suma3 = 0	
local suma4 = 0
local i = 1
/*
set trace on
*/
tempvar rres0 rres1 rres2 rres3 rres4
qui gen        `rres0'=""
qui gen double `rres1' =0
qui gen double `rres2' =0
qui gen double `rres3' =0
qui gen double `rres4' =0

foreach var of varlist `eindcon' `enindcat' _constant {
qui sum `var' if `sex'==1 [aw=`sw']
local mm = r(mean)
qui sum `var' if `sex'==2 [aw=`sw']
local mf = r(mean)
qui replace `rres0' = "`var'" in `i'

if "`cat_`extend''" == "" {
qui replace `rres1' = (`eb_m_`var''*`mm' - `eb_f_`var''*`mf')*`b_s_`extend'' in `i'	
qui replace `rres2' = (`b_m_`extend'' - `b_s_`extend'')*`mm'*`eb_m_`var'' in `i'	
qui replace `rres3' = (`b_s_`extend'' - `b_f_`extend'')*`mf'*`eb_f_`var'' in `i'	
}


if "`cat_`extend''" ~= "" {
forvalues j=2/`numbcate'  {                                                          
qui replace `rres1' = `rres1'[`i'] + (`eb_m_`var'_`j''*`mm' - `eb_f_`var'_`j''*`mf')*`b_s__I`extend'_`j'' in `i'	
qui replace `rres2' = `rres2'[`i'] + (`b_m__I`extend'_`j'' - `b_s__I`extend'_`j'')*`mm'*`eb_m_`var'_`j'' in `i'	
qui replace `rres3' = `rres3'[`i'] + (`b_s__I`extend'_`j'' - `b_f__I`extend'_`j'')*`mf'*`eb_f_`var'_`j'' in `i'	
}
}

/*
qui replace `res1' = (`eb_s_`var''*`mm' - `eb_s_`var''*`mf')*`b_s_`extend'' in `i'	
qui replace `res2' = (`b_m_`extend'' - `b_s_`extend'')*`mm'*`eb_s_`var'' in `i'	
qui replace `res3' = (`b_s_`extend'' - `b_f_`extend'')*`mf'*`eb_s_`var'' in `i'	
*/
qui replace `rres4' = `rres1' + `rres2' +`rres3'  in `i'	
local suma1 = `suma1' + `rres1'[`i']
local suma2 = `suma2' + `rres2'[`i']
local suma3 = `suma3' + `rres3'[`i']	
local suma4 = `suma4' + `rres4'[`i']
local i = `i' +1
}
qui replace `rres0' = "All " in `i'
qui replace `rres1' = `suma1' in `i'	
qui replace `rres2' = `suma2' in `i'	
qui replace `rres3' = `suma3' in `i'	
qui replace `rres4' = `suma4'  in `i'	

mkmat `rres1' `rres2' `rres3' `rres4'  in 1/`i' , matrix(cccc) rownames(`rres0')

}
 

ereturn clear
ereturn matrix tab2 = aaaa
ereturn matrix tab3 = bbbb
if ("`extend'"~="") ereturn matrix tab5 = cccc
cap drop _I*
cap drop _est*
cap drop _constant

restore
end





#delimit ;
cap program drop decgeng;
program define decgeng, eclas;
syntax varlist(min=2 max=2)[, 
indcon(string) 
indcat(string) 
extend(varname)
eindcon(string) 
eindcat(string)
DEC(int  4)
DREGRES(int 0)
NITER(int 0)
   *];
tokenize `varlist';
local depvar `1';
local sex    `2' ;


qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

/* Copying  the sampling weight */
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear;
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

if ("`extend'"~="") {
if "`cat_`extend''" ~= "" {
tokenize `cat_`extend'' 
_nargs `cat_`extend''
local numbcate = $indica+1 
local b_m_`extend' = 0
local b_f_`extend' = 0
local b_s_`extend' = 0 

forvalues j=2/`numbcate'  {
local b_m_`extend' = `b_m_`extend'' +  `b_m__I`extend'_`j''
local b_f_`extend' = `b_f_`extend'' +  `b_f__I`extend'_`j''
local b_s_`extend' = `b_s_`extend'' +  `b_s__I`extend'_`j''
}
}
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



local SE  = `MSA' + `FSD' 



tempvar res0 res1 res2 res3 res4
qui gen        `res0'=""
qui gen double `res1' =.
qui gen double `res2' =.
qui gen double `res3' =.
qui gen double `res4' =.
local i = 1


local suma1 = 0
local suma2 = 0
local suma3 = 0	
local suma4 = 0

foreach var of varlist `indcon' `nindcat' _constant {
qui sum `var' if `sex'==1 [aw=`sw']
local mm = r(mean)
qui sum `var' if `sex'==2 [aw=`sw']
local mf = r(mean)
qui replace `res0' = "`var'" in `i'
qui replace `res1' = (`mm'-`mf')*`b_s_`var'' in `i'	
qui replace `res2' = (`b_m_`var''- `b_s_`var'')*`mm' in `i'	
qui replace `res3' = (`b_s_`var''- `b_f_`var'')*`mf' in `i'	
qui replace `res4' = `res1' + `res2' +`res3'  in `i'	
local suma1 = `suma1' + `res1'[`i']
local suma2 = `suma2' + `res2'[`i']
local suma3 = `suma3' + `res3'[`i']	
local suma4 = `suma4' + `res4'[`i']
local i = `i' +1
}
qui replace `res0' = "All " in `i'
qui replace `res1' = `suma1' in `i'	
qui replace `res2' = `suma2' in `i'	
qui replace `res3' = `suma3' in `i'	
qui replace `res4' = `suma4'  in `i'	

local ltb3 = `i'



if ("`extend'"~="") {
     
//set trace on
local i=1
local enindcat ""
if ("`eindcat'" ~= "") {
foreach var of varlist `eindcat' {
qui gencatvar `var'	
local cat_`var' = "`r(slist)'"
local enindcat `enindcat' `cat_`var''
local i = `i' + 1
}
}

cap drop _constant
qui gen double      _constant = 1



if "`cat_`extend''" == "" {
 qui xi: regress `extend' `eindcon' `enindcat'  [pw= `sw'] if `sex'==1 
eststo mm3    
local mycmd  qui xi: regress `extend' `eindcon' `enindcat' _constant [pw= `sw']
`mycmd' if `sex'==1 , nocons
tempvar pym pyf `bstar't
qui predict `pym', xb 
qui estat summarize
matrix estm = e(b)'
matrix est2= r(stats)
local nrows = rowsof(estm)
forvalues i=1/`nrows' {
qui getRowName estm `i'
local  ecoef = r(rowname)
local escoef =  subinstr("`ecoef'",".","_",.)
if ("`escoef'" == "o__constant") local escoef = "_constant"
local eacoef =  subinstr("`escoef'","o.","",1)
local eb_m_`eacoef' =  _b[`ecoef'] 
}

 qui xi: regress `extend' `eindcon' `enindcat'  [pw= `sw'] if `sex'==2 
eststo mm2  
`mycmd' if `sex'==2 , nocons
cap drop `pyf'
qui predict `pyf', xb
qui estat summarize
matrix estm = e(b)'
matrix est2= r(stats)
local nrows = rowsof(estm)
forvalues i=1/`nrows' {
qui getRowName estm `i'
local  ecoef = r(rowname)
local escoef =  subinstr("`ecoef'",".","_",.)
if ("`escoef'" == "o__constant") local escoef = "_constant"
local eacoef =  subinstr("`escoef'","o.","",1)
local eb_f_`eacoef' =  _b[`ecoef'] 
}

 qui xi: regress `extend' `eindcon' `enindcat'  [pw= `sw'] 
eststo mm1
`mycmd' , nocons
cap drop `ebstar'
tempvar ebstar
qui predict `ebstar', xb
qui estat summarize
matrix estm = e(b)'
matrix est2= r(stats)
local nrows = rowsof(estm)
forvalues i=1/`nrows' {
qui getRowName estm `i'
local  ecoef = r(rowname)
local escoef =  subinstr("`ecoef'",".","_",.)
if ("`escoef'" == "o__constant") local escoef = "_constant"
local eacoef =  subinstr("`escoef'","o.","",1)
local eb_s_`eacoef' =  _b[`ecoef'] 
}

}



if "`cat_`extend''" ~= "" {
forvalues j=2/`numbcate'  {
qui xi: regress _I`extend'_`j' `eindcon' `enindcat'   if `sex'==1 [pw= `sw'] 
eststo mm3_`j'
qui xi: regress _I`extend'_`j' `eindcon' `enindcat' _constant   if `sex'==1 [pw= `sw'], nocons
tempvar pym_`j' pyf_`j' `bstar't_`j'
qui predict `pym_`j'', xb 
qui estat summarize
cap matrix drop estm
cap matrix drop est2
matrix estm = e(b)'
matrix est2= r(stats)
local nrows = rowsof(estm)


forvalues i=1/`nrows' {
qui getRowName estm `i'
local  ecoef = r(rowname)
local eb_m_`ecoef' =  0
}

forvalues i=1/`nrows' {
qui getRowName estm `i'
local  ecoef = r(rowname)
local escoef =  subinstr("`escoef'",".","_",.)
local eb_m_`ecoef'_`j' =  _b[`ecoef'] 
local eb_m_`ecoef' =  `eb_m_`ecoef'' + `eb_m_`ecoef'_`j''
}
qui xi: regress _I`extend'_`j' `eindcon' `enindcat'   if `sex'==2 [pw= `sw'] 
eststo mm2_`j'
qui xi: regress _I`extend'_`j' `eindcon' `enindcat' _constant   if `sex'==2 [pw= `sw'], nocons

cap drop `pyf_`j''
qui predict `pyf_`j'', xb
qui estat summarize
cap matrix drop estm
cap matrix drop est2
matrix estm = e(b)'
matrix est2= r(stats)
local nrows = rowsof(estm)

forvalues i=1/`nrows' {
qui getRowName estm `i'
local  ecoef = r(rowname)
local eb_f_`ecoef' =  0
}
forvalues i=1/`nrows' {
qui getRowName estm `i'
local  ecoef = r(rowname)
local escoef =  subinstr("`ecoef'",".","_",.)
local eb_f_`ecoef'_`j' =  _b[`ecoef'] 
local eb_f_`ecoef'     =  `eb_f_`ecoef'' + `eb_f_`ecoef'_`j''
}

qui xi: regress _I`extend'_`j' `eindcon' `enindcat'   [pw= `sw'] 
eststo mm1_`j'
qui xi: regress _I`extend'_`j' `eindcon' `enindcat' _constant  [pw= `sw'] , nocons
cap drop `ebstar_`j''
tempvar ebstar_`j'
qui predict `ebstar_`j'', xb
qui estat summarize
cap matrix drop estm
cap matrix drop est2
matrix estm = e(b)'
matrix est2= r(stats)
local nrows = rowsof(estm)
forvalues i=1/`nrows' {
qui getRowName estm `i'
local  ecoef = r(rowname)
local eb_s_`ecoef' =  0
}
forvalues i=1/`nrows' {
qui getRowName estm `i'
local  ecoef = r(rowname)
local escoef =  subinstr("`escoef'",".","_",.)
local eb_s_`ecoef'_`j' =  _b[`ecoef'] 
local eb_s_`ecoef' =  `eb_s_`ecoef'' + `eb_s_`ecoef'_`j''
}

	
}	
	
}

local suma1 = 0
local suma2 = 0
local suma3 = 0	
local suma4 = 0
local i = 1
/*
set trace on
*/
tempvar rres0 rres1 rres2 rres3 rres4
qui gen        `rres0'=""
qui gen double `rres1' =0
qui gen double `rres2' =0
qui gen double `rres3' =0
qui gen double `rres4' =0
foreach var of varlist `eindcon' `enindcat' _constant {
qui sum `var' if `sex'==1 [aw=`sw']
local mm = r(mean)
qui sum `var' if `sex'==2 [aw=`sw']
local mf = r(mean)
qui replace `rres0' = "`var'" in `i'


if "`cat_`extend''" == "" {
qui replace `rres1' = (`eb_m_`var''*`mm' - `eb_f_`var''*`mf')*`b_s_`extend'' in `i'	
qui replace `rres2' = (`b_m_`extend'' - `b_s_`extend'')*`mm'*`eb_m_`var'' in `i'	
qui replace `rres3' = (`b_s_`extend'' - `b_f_`extend'')*`mf'*`eb_f_`var'' in `i'	
}


if "`cat_`extend''" ~= "" {
forvalues j=2/`numbcate'  {                                                          
qui replace `rres1' = `rres1'[`i'] + (`eb_m_`var'_`j''*`mm' - `eb_f_`var'_`j''*`mf')*`b_s__I`extend'_`j'' in `i'	
qui replace `rres2' = `rres2'[`i'] + (`b_m__I`extend'_`j'' - `b_s__I`extend'_`j'')*`mm'*`eb_m_`var'_`j'' in `i'	
qui replace `rres3' = `rres3'[`i'] + (`b_s__I`extend'_`j'' - `b_f__I`extend'_`j'')*`mf'*`eb_f_`var'_`j'' in `i'	
}
}

/*
qui replace `res1' = (`eb_s_`var''*`mm' - `eb_s_`var''*`mf')*`b_s_`extend'' in `i'	
qui replace `res2' = (`b_m_`extend'' - `b_s_`extend'')*`mm'*`eb_s_`var'' in `i'	
qui replace `res3' = (`b_s_`extend'' - `b_f_`extend'')*`mf'*`eb_s_`var'' in `i'	
*/
qui replace `rres4' = `rres1' + `rres2' +`rres3'  in `i'	
local suma1 = `suma1' + `rres1'[`i']
local suma2 = `suma2' + `rres2'[`i']
local suma3 = `suma3' + `rres3'[`i']	
local suma4 = `suma4' + `rres4'[`i']
local i = `i' +1
}
qui replace `rres0' = "All " in `i'
qui replace `rres1' = `suma1' in `i'	
qui replace `rres2' = `suma2' in `i'	
qui replace `rres3' = `suma3' in `i'	
qui replace `rres4' = `suma4'  in `i'	

local ltb5 = `i' 


	


}

if (`niter'>0) {

/* Table 02 */	
tempvar  stres2
qui gen `stres2' = .

forvalues i= 1/5 {
tempvar  bres_2_`i'
qui gen `bres_2_`i'' = .
}



/* Table 03 */
forvalues v=1/4 {
tempvar  stres3_`v'
qui gen `stres3_`v'' = .
}

forvalues r= 1/`ltb3'  {
forvalues v= 1/4       {
tempvar  bres_3_`r'_`v'
qui gen `bres_3_`r'_`v'' = .
}
}


if ("`extend'"~="") {

/* Table 05 */
forvalues v=1/4 {
tempvar  stres5_`v'
qui gen `stres5_`v'' = .
}

forvalues r= 1/`ltb5'  {
forvalues v= 1/4       {
tempvar  bres_5_`r'_`v'
qui gen `bres_5_`r'_`v'' = .
}
}
}

                           local excat = 0
if "`cat_`extend''" ~= ""  local excat = 1
forvalues b=1/`niter' {

 bdecgeng `0' nindcat(`nindcat')	 enindcat(`enindcat') ocat_extend(`cat_`extend'') excat(`excat')
/* Table 2 */	

forvalues j= 1/5 {
cap matrix drop zzz
matrix zzz = e(tab2)
qui replace `bres_2_`j'' = el(zzz,`j',1) in `b'
}
/* Table 3*/

forvalues r= 1/`ltb3'  {
forvalues v= 1/4       {
cap matrix drop zzz
matrix zzz = e(tab3)	
qui replace `bres_3_`r'_`v'' = el(zzz,`r',`v') in `b'
}
}

if ("`extend'"~="") {
/* Table 5*/
/*matrix list e(tab5)*/
forvalues r= 1/`ltb5'  {
forvalues v= 1/4       {
cap matrix drop zzz
matrix zzz = e(tab5)
qui replace `bres_5_`r'_`v'' = el(zzz,`r',`v') in `b'
}
}
}

dis "Iter : `b'"
}

/*
forvalues r= 1/`ltb3'  {
forvalues v= 1/4       {
list `bres_3_`r'_`v'' in 1/`niter'
}
} 

forvalues r= 1/`ltb5'  {
forvalues v= 1/4       {
list `bres_5_`r'_`v'' in 1/`niter'
}
} 

*/

/*list `bres_2_1'	 `bres_2_2' `bres_2_3' `bres_2_4' `bres_2_5'  in 1/`niter'*/
 
forvalues i= 1/5 {
qui mean  `bres_2_`i'' in 1/`niter'
cap matrix drop zzz
matrix zzz = e(V)
qui replace `stres2' = el(zzz,1,1)^0.5 in `i'
}




forvalues r= 1/`ltb3'  {
forvalues v= 1/4       {
qui mean  `bres_3_`r'_`v'' in 1/`niter'
cap matrix drop zzz
matrix zzz = e(V)
qui replace `stres3_`v'' = el(zzz,1,1)^0.5 in `r'
}
}



if ("`extend'"~="") {
forvalues r= 1/`ltb5'  {
forvalues v= 1/4       {
qui mean  `bres_5_`r'_`v'' in 1/`niter'
cap matrix drop zzz
matrix zzz = e(V)
qui replace `stres5_`v'' = el(zzz,1,1)^0.5 in `r'
}
}
}
	
/*list `stres2' in 1/5*/ 			
}



dis _n "   Table 01: Estimates of model(s)" 
esttab m1 m2 m3, not r2    mtitle("Population" "Female" "Male")  nodepvars nonumbers b(`dec') varwidth(34) label


dis _n as result  "   Table 02: Main decompostion components" 
if `niter' == 0 matrix     aaa = ( `D' \ `EE' \ `SE' \ `MSA' \ `FSD' )
if `niter' > 0  matrix     aaa = ( `D' , `stres2'[1] \ `EE' , `stres2'[2] \ `SE' , `stres2'[3] \ `MSA' , `stres2'[4] \ `FSD' , `stres2'[5] )
if `niter' == 0 matrix colnames aaa = "Estimated Value"  
if `niter' > 0  matrix colnames aaa = "Estimated Value"   "Standard Errors"
matrix rownames aaa = "GENDER GAP      "   "Endoyment Effect"   "Structural Effect"  "Male Structural Advantage"  "Female Structural Disadvantage"  
distable2  aaa, dec(`dec') atit(`langr')    dsmidl(1)





if `niter' == 0  mkmat `res1' `res2' `res3' `res4'  in 1/`ltb3' , matrix(bbb) rownames(`res0')
if `niter' > 0   mkmat `res1' `stres3_1' `res2' `stres3_2'  `res3' `stres3_3'  `res4' `stres3_4'  in 1/`ltb3' , matrix(bbb) rownames(`res0')

if `niter' == 0   matrix colnames bbb = "Endowment Effect"  "Male Structural Advantage"  "Female Structural Disadvantage"  "All"
if `niter' > 0  matrix colnames bbb = "Endowment Effect" "STE" "Male Structural Advantage" "STE"   "Female Structural Disadvantage"  "STE"  "All"  "STE" 
dis _n as result  "   Table 03: Absolute Contribution of indep. variables" 
distable  bbb, dec(`dec') atit(`langr')    dsmidl(0)




if ("`extend'"~="") {

if "`cat_`extend''" == "" {    
dis _n as result  "   Table 04_`v': Estimates of model(s) : Dep Var : `extend'_`j' " 
esttab mm1 mm2 mm3, not r2    mtitle("Population" "Female" "Male")  nodepvars nonumbers b(`dec') varwidth(34) label
}

if "`cat_`extend''" ~= "" {    
forvalues j=2/`numbcate'  {	
local v=`j'-1
dis _n as result  "   Table 04_`v': Estimates of model(s) : Dep Var : `extend'_`j' " 
esttab mm1_`j' mm2_`j' mm3_`j', not r2    mtitle("Population" "Female" "Male")  nodepvars nonumbers b(`dec') varwidth(34) label
}
}

if `niter' == 0    mkmat `rres1' `rres2' `rres3' `rres4'  in 1/`i' , matrix(ccc) rownames(`rres0')
if `niter' > 0     mkmat `rres1' `stres5_1' `rres2' `stres5_2'  `rres3' `stres5_3'  `rres4' `stres5_4'  in 1/`ltb5' , matrix(ccc) rownames(`rres0')

if `niter' == 0    matrix colnames ccc = "Endowment Effect"  "Male Structural Advantage"  "Female Structural Disadvantage"  "All"
if `niter'  > 0    matrix colnames ccc =  "Endowment Effect" "STE" "Male Structural Advantage" "STE"   "Female Structural Disadvantage"  "STE"  "All"  "STE" 

dis _n as result  "   Table 05: Absolute Contribution of indep. variables" 
distable  ccc, dec(`dec') atit(`langr')    dsmidl(0)
}

cap drop _I*
cap drop _est*
cap drop _constant



end

