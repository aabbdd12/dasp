
*! version 1.01
*

capture program drop _tswel_inst
program define _tswel_inst

set more off
net from http://dasp-two.vercel.app/tswel/Installer
net install tswel, force
cap addITMenu profile.do _tswel_menu


end


