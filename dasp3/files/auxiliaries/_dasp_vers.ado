capture program drop _dasp_vers
program define       _dasp_vers

local  inst_ver   3.03
local  inst_dat  "07February2022"

dis _n
qui include http://dasp-two.vercel.app/dasp3/version
dis _col(5) "- Installed DASP"_col(33) ": Version `inst_ver'"         _col(50)  "| Date: `inst_dat'  "
dis _col(5) "- Available updated DASP" _col(33) ": Version $srv_ver " _col(50)  "| Date: $srv_dat  "

cap macro drop srv_dat
cap macro drop srv_ver

end


