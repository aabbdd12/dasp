capture program drop _tswel_vers
program define       _tswel_vers

local  inst_ver   1.03
local  inst_dat  "25Mayo2018"

dis _n
qui include http://dasp.ecn.ulaval.ca/tswel/Installer/version
dis _col(5) "- Installed TSWEL"_col(33) ": Version `inst_ver'"        _col(50)   "| Date: `inst_dat'  "
dis _col(5) "- Available updated WELCOM" _col(33) ": Version $srv_ver " _col(50) "| Date: $srv_dat  "

cap macro drop srv_dat
cap macro drop srv_ver

end


