
/* In this fictive example, we assume that our statistic is the difference between averages of expenditures */
/* The following program estimates the difference between averages */
/* fw1 is the final weight of the fisrt variable */
/* fw2 is the final weight of the fisrt variable */

cap program drop simpleprog
program define simpleprog, rclass
syntax varlist (min=2 max=2), [ fw1(varname) fw2(varname) ]
	tokenize `varlist'
	qui sum `1' [aw=`fw1'] , meanonly
	local m1 = r(mean)
	qui sum `2' [aw=`fw2'] , meanonly
	local m2 = r(mean)
	return scalar dimean = `m1' - `m2'
end


/* We use the data examples to simulate to panel waves */
/* 1000 obs in wave94 and 1200 in wave98 */
/* we assume that in 98 we have 200 additional sampled households */
/* expenditures, sizes and weights vary, but the poor are poor abd the rich are rich : we order the expenditures */


sysuse bkf94I, replace
keep in 1/1000
rename size     size94
gen  exppc94= exppc 
sort  exppc, stable
gen hhid = _n 
keep weight size94 exppc94 exppc hhid
svyset _n [pweight=weight], vce(linearized) singleunit(missing)
save wave94, replace


sysuse bkf98I, replace
keep in 1/1200
rename size     size98
gen  exppc98= exppc 
sort  exppc, stable
gen hhid = _n 
keep weight size98 exppc98 exppc hhid
svyset _n [pweight=weight], vce(linearized) singleunit(missing)
save wave98, replace

/* We can combine the data files */
/* The dependendance resides on the rank according to expenditures (the ppor in 94 as potentially poor in 98) */

use wave94, replace
merge 1:1 hhid using wave98
tab _merge

gen fw1 = size94*weight
gen fw2 = size98*weight


/*  By wrongly assuming that the two samples are independent */
dimean exppc94 exppc98, hsize1(size94) hsize2(size98) file1(wave94) file2(wave98)

/*

. dimean exppc94 exppc98, hsize1(size94) hsize2(size98) file1(wave94) file2(wave98)
------------------------------------------------------------------------------
Index    |   Estimate   Std. Err.       t     P>|t|       [95% Conf. Interval]
---------+--------------------------------------------------------------------
 mean_D1 |  224213.1    11454.61    19.574   0.0000       201735.2      246691
 mean_D2 |  161864.6    8809.843   18.3732   0.0000       144580.2      179149
---------+--------------------------------------------------------------------
    diff.| -62348.46    14450.66  -4.31458   0.0000      -90686.84   -34010.08
------------------------------------------------------------------------------

The estimated STE of the difference (14450.66) is thus wrong since we do not consider the dependance for the first 1000 obs!
*/
 /* A first step to find the good STE */
 /* We use the bootstrap technic */ 
set seed 656565
simpleprog exppc94 exppc98, fw1(fw1) fw2(fw2)
return list
bootstrap r(dimean), reps(3000) : simpleprog exppc94 exppc98, fw1(fw1) fw2(fw2)


/* By using a combined file with a additional trick */
replace size94  = 0  if   size94==.
replace exppc94 = 0  if exppc94==. 

/* if some missings in 98 */
replace size98  = 0  if   size98==.
replace exppc98 = 0  if exppc98==. 

dimean exppc98 exppc94, hsize1(size98) hsize2(size94)

