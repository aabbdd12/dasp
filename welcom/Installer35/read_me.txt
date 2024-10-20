/* In the Stata command window, type the following commands:  */

set more off
 net from http://dasp-two.vercel.app/welcom/Installer
 net install welcom_p1, force
 net install welcom_p2, force
 net install welcom_p3, force
 net install welcom_p4, force
 cap addITMenu profile.do _welcom_menu

