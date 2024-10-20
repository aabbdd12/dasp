capture program drop _miwel_vers
program define       _miwel_vers

local  inst_ver   2.00
local  inst_dat  "03December2017"

dis _n
qui include http://dasp-two.vercel.app/miwel/Installer/version
dis _col(5) "- Installed MIWEL"_col(33) ": Version `inst_ver'"        _col(50)  "| Date: `inst_dat'  "
dis _col(5) "- Available updated MIWEL" _col(33) ": Version $srv_ver " _col(50) "| Date: $srv_dat  "

cap macro drop srv_dat
cap macro drop srv_ver

end


