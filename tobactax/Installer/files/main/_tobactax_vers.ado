capture program drop _tobactax_vers
program define       _tobactax_vers

local  inst_ver   1.07
local  inst_dat  "29Dec2018"

dis _n
qui include http://dasp.ecn.ulaval.ca/tobactax/Installer/version
dis _col(5) "- Installed TOBACTAX"_col(33) ": Version `inst_ver'"        _col(50)   "| Date: `inst_dat'  "
dis _col(5) "- Available updated TOBACTAX" _col(33) ": Version $srv_ver " _col(50) "| Date: $srv_dat  "

cap macro drop srv_dat
cap macro drop srv_ver

end


