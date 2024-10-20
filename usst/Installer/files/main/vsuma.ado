/********************************************************************************/
/*  Package       : USST //Usefull Stata Tools                                  */
/*  Version       :   0.10   //                       JUNE         2020         */
/*  Stata Version : Required  15.0 and higher                                   */
/*  Authors       : Abdelkrim Araar  // aabd@ecn.ulaval.ca                      */
/********************************************************************************/

capture program drop vsuma
program define vsuma, eclas
version 15
syntax varlist (min=1 ) [if] [in] [aweight fweight iweight],  [hgroup(varname) statistic(string)]

tokenize `varlist'
local vnumber = 0
foreach var of varlist `varlist' {
local vnumber = `vnumber'+1
}
if   ("`statistic'" == "") local statistic mean
local ohgroup `hgroup'
if   ("`hgroup'" == "") {
tempvar hgroup
qui gen  `hgroup' = 1
}



if ( "`if'" == "") local roma   if
if ( "`if'" ~= "") local roma   & 
qui levelsof `hgroup', local(group)
local ncol = wordcount("`r(levels)'")
                     local ncol1 = `ncol'
if "`ohgroup'" ~= "" local ncol1 = `ncol' + 1


tempname mat1
matrix  `mat1' = J(`vnumber',`ncol1',.)


local i = 0
foreach x of local group {
local i = `i'+1
local j = 0
foreach var of varlist `varlist' {
local j = `j'+1
sum `var'  `if'  `roma'  `hgroup' == `x'  `in'  [`weight'`exp']   , meanonly
local m1 = `r(`statistic')'
qui matrix `mat1'[`j',`i'] = `m1'
}
}


if "`ohgroup'" ~= ""   {
local j = 0
foreach var of varlist `varlist' {
local j = `j'+1
qui replace `var'=0 if `var'==.
sum `var'  `if'  `in'  [`weight'`exp']   , meanonly
local m1 = `r(`statistic')'
qui matrix `mat1'[`j',`ncol1'] = `m1'
}
}

ereturn matrix results = `mat1'

end


