

/* In the Stata command window, type the following commands:  */

set more off
net from http://dasp.ecn.ulaval.ca/welcom/Installer 
net install welcom, force
cap addmimenu profile.do _welcom_menu

