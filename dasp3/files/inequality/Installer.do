clear all
set more off
local cwd  `c(pwd)'
local per : sysdir PERSONAL
cd "`per'"
net from https://www.dasp.cstip.ulaval.ca/dasp3
net install dasp_p1.pkg, force 
net install dasp_p2.pkg, force 
net install dasp_p3.pkg, force 
net install dasp_p4.pkg, force 
net install dasp_p5.pkg, force 
net get     dasp_p6.pkg, force 
adddmenu _daspmenu
cd "`cwd'"

