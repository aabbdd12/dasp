capture program drop _welcom_vers
program define       _welcom_vers

local  inst_ver   3.50
local  inst_dat  "22October2020"

dis _n
qui include http://dasp-two.vercel.app/welcom/Installer/version
dis _col(5) "- Installed WELCOM"_col(33) ": Version `inst_ver'"         _col(50)  "| Date: `inst_dat'  "
dis _col(5) "- Available updated WELCOM" _col(33) ": Version $srv_ver " _col(50) "| Date: $srv_dat  "

cap macro drop srv_dat
cap macro drop srv_ver

end


