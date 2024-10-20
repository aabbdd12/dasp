/* In the Stata command window, type the following commands:  */

set more off
 net from http://dasp.ecn.ulaval.ca/welcom/Installer
 net install welcom_p1, force
 net install welcom_p2, force
 cap addITMenu profile.do _welcom_menu

