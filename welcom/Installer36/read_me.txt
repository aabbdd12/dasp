/********************************************************************************************/
/* Installing the package from the WELCOM server : required to be connected to the internet */
/********************************************************************************************/

/* In the Stata command window, type the following commands:  */
 set more off
 net from http://dasp.ecn.ulaval.ca/welcom/Installer36
 net install welcom_p1,   force
 net install welcom_p2,   force
 net install welcom_p3,   force
 net install welcom_p4,   force
 net get     welcom_data, force
 cap addITMenu profile.do _welcom_menu


/********************************************************************************************/
/* Installing the package using a zipped folder                                             */
/********************************************************************************************/
1- Load the zipped folder:
http://dasp.ecn.ulaval.ca/welcom/Installer36/welcom.zip
or 
http://dasp.ecn.ulaval.ca/welcom/Installer36/welcom.rar

2- Unzip the forlder in a local directory. For instance, c:/temp

3- In the Stata command window, type the following commands:
 set more off
 net from c:/temp/welcom/Installer
 net install welcom_p1,   force
 net install welcom_p2,   force
 net install welcom_p3,   force
 net install welcom_p4,   force
 net get     welcom_data, force
 cap addITMenu profile.do _welcom_menu