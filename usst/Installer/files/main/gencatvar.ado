

cap program drop gencatvar
program define gencatvar, rclass
args myvar code

local hgroup = "`myvar'"
cap drop gn1
cap drop _I`hgroup'_*
preserve
capture {
local lvgroup:value label `hgroup'
if ("`lvgroup'"!="") {
uselabel `lvgroup' , replace
qui count
forvalues i=1/`r(N)' {
local tem=value[`i']
local grlab`tem' = label[`i']
}
}
}
restore
cap drop gn1 
qui tabulate `hgroup', matrow(gn)

svmat int gn

matrix drop gn
global indica=r(r)
tokenize `varlist'
forvalues k=2/$indica {
local kk = gn1[`k']
local label`f'  : label (`hgroup') `kk'
if ( "`label`f''" == "" | "`label`f''" == "`kk'" )   local label`f'   = "`myvar'_`kk'"

qui gen _I`hgroup'_`kk' = `hgroup'==`kk' 
lab var _I`hgroup'_`kk' "`label`f''" 
local slist `slist' _I`hgroup'_`kk' 
}
macro drop indica
cap drop gn1
return local slist = "`slist'"
end




