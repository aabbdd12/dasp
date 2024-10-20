
*! version 1.01
*

capture program drop _tobactax_inst
program define _tobactax_inst

set more off
net from http://dasp-two.vercel.app/tobactax/Installer
net install tobactax, force
cap addITMenu profile.do _tobactax_menu


end


