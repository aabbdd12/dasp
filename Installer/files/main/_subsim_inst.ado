
*! version 3.0
*

capture program drop _subsim_inst
program define _subsim_inst

set more off
net from http://dasp-two.vercel.app/subsim/Installer
net install subsim_part1, force
net install subsim_part2, force
cap addSMenu profile.do _subsim_menu


end


