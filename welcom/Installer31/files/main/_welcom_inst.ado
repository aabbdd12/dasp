
*! version 2.30
*

capture program drop _welcom_inst
program define _welcom_inst

set more off
net from http://dasp-two.vercel.app/welcom/Installer
net install welcom_p1, force
net install welcom_p2, force
cap additmenu profile.do _welcom_menu

end


