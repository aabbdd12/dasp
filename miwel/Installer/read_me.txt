

/* In the Stata command window, type the following commands:  */

set more off
net from http://dasp-two.vercel.app/miwel/Installer 
net install miwel, force
cap addmimenu profile.do _miwel_menu

