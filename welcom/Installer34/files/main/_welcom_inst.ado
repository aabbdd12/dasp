
*! version 3.40
*
capture program drop _welcom_inst
program define _welcom_inst

set more off
net from http://dasp-two.vercel.app/welcom/Installer34
net install welcom_p1, force
net install welcom_p2, force
net install welcom_p3, force
net install welcom_p4, force
cap addITMenu profile.do _welcom_menu

end


