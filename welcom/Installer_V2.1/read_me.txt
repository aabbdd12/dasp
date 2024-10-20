

/* In the Stata command window, type the following commands:  */

set more off
net from http://dasp-two.vercel.app/welcom/Installer 
net install welcom, force
cap addmimenu profile.do _welcom_menu

