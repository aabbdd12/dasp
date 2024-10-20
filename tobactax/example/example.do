clear all
set more off

/* Exemple */
/* Indicate the path to load the zipped folder of the example : data and do files */
global mydir C:\temp


/* Intalling the TOBACTAX Stata package */
set more off
net from http://dasp.ecn.ulaval.ca/tobactax/Installer 
net install tobactax, force



/* Changing the directory to the indicated working directory  (WD)*/
cd $mydir

/* Coppying the zipped folder of the example in the WD */
copy http://dasp.ecn.ulaval.ca/tobactax/example.zip "$mydir/example.zip", replace

/* Unzipping the folder */
qui unzipfile "$mydir/example.zip"

/* Changing the directory to the folder example */
cd example

/* Opening the data file */
use data\BGD_tobacco_final16_vars, replace


/* Replacing the missing values of the expenditures on cigarettes by zeros. */
replace rs_exp_cigarettes=0 if rs_exp_cigarettes==.

/* It is important to indicate at least the sampling weight with the command svyset */
/* The TTRWEL command uses this weight automatically */
svyset _n [pweight=hhwgt], vce(linearized) singleunit(missing)


/* Opening the dialog box of the TTRWEL module */
db tobatref

/* Filling the values and the options of the TTRWEL with the file myproj.trw */
tobatrefl_ini_trw myproj.trw


