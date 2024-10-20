
*! version 2.00
*

capture program drop _miwel_inst
program define _miwel_inst

set more off
net from http://dasp.ecn.ulaval.ca/miwel/Installer
net install miwel, force
cap addITMenu profile.do _miwel_menu


end


