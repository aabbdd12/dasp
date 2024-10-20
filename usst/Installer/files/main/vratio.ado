/********************************************************************************/
/*  Package       : USST //Usefull Stata Tools                                  */
/*  Version       :   0.10   //                       JUNE         2020         */
/*  Stata Version : Required  15.0 and higher                                   */
/*  Authors       : Abdelkrim Araar  // aabd@ecn.ulaval.ca                      */
/********************************************************************************/

capture program drop vratio
program define vratio, eclas
version 15
syntax varlist (min=1 ) [if] [in] [aweight fweight iweight], denom(varname)  [hgroup(varname)]

tokenize `varlist'
local vnumber = 0
foreach var of varlist `varlist' {
local vnumber = `vnumber'+1
}

if ("`hgroup'" == "") {
tempvar hgroup
qui gen `hgroup' = 	1
}

if ("`if'"=="") local roma   if
if ("`if'"~="") local roma   & 
qui levelsof `hgroup', local(group)
local ncol = wordcount("`r(levels)'")
tempname mat1
matrix `mat1' = J(`vnumber',`ncol',.)
local i = 0
foreach x of local group {
local i = `i'+1
sum `denom'  `if'  `roma' `hgroup' == `x' `in' [`weight'`exp'] , meanonly 
local m2 = `r(mean)'
local j = 0
foreach var of varlist `varlist' {
local j = `j'+1
qui replace `var'=0 if `var'==.
sum `var'  `if'  `roma'  `hgroup' == `x'  `in'  [`weight'`exp']   , meanonly
local m1 = `r(mean)'
qui matrix `mat1'[`j',`i'] = `m1'/`m2'
}
}

ereturn matrix results = `mat1'

end






