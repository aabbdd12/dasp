
*! version 3.03
*
capture program drop _dasp_inst
program define _dasp_inst

set more off
net from http://dasp-two.vercel.app/dasp3
net install dasp_p1, force
net install dasp_p2, force
net install dasp_p3, force
net install dasp_p4, force
net install dasp_p5, force
net install dasp_p6, force
net get dasp_data, force
cap adddmenu profile.do _daspmenu
end

