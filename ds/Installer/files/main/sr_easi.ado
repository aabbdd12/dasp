

/*************************************************************************/
/* Stata_R_Easi                             (Version 1.00)               */
/*************************************************************************/
/* Conceived  by Dr. Araar, Carlos & Sergio  (2018)                     */
/* World Bank and Universite Laval, Quebec, Canada                       */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* sr_easi.ado                                                           */
/*************************************************************************/


#delimit ;
capture program drop sr_easi;
program define sr_easi, eclass;
version 9.2;
syntax namelist (min=1 max=1) [,  
WDIR(string) 
SHares(string)
LNPrices(string)
LNExp(string)
VDemo(string)
RTool(string)
power(int 3)
INPY(int 1)
INPZ(int 1)
INZY(int 1)
DEC(int 4)
SNames(string)
];

#delimit cr
tokenize `namelist'
local mydata = "`1'"
              local ipy  TRUE
if `inpy'==0  local ipy  FALSE
              local ipz  TRUE
if `inpz'==0  local ipz  FALSE
              local izy  TRUE
if `inzy'==0  local izy  FALSE

preserve
cd `wdir'
use `mydata' , replace
order `shares' `lnprices' `lnexp' `vdemo'
keep  `shares' `lnprices' `lnexp' `vdemo'

foreach var of varlist _all {
qui drop if `var'==.
}

local nitems = 0
foreach var of varlist `shares' {
local nitems = `nitems'+1
}

local nitemsp = 0
foreach var of varlist `lnprices' {
local nitemsp = `nitemsp'+1
}


local nitemsd = 0
if "`vdemo'"~="" {
cap {
foreach var of varlist `vdemo' {
local nitemsd = `nitemsd'+1
}
}
}

local pos_share_i  1
local pos_share_f  `nitems'

local tmp =  `nitems'+1
local pos_lnprice_i `tmp'
local tmp =  2*`nitems'
local pos_lnprice_f  `tmp'

local tmp =  2*`nitems'+1
local pos_lnexp    `tmp'

local pos_demo_i 0
local pos_demo_f 0

if `nitemsd'>=1 {
local tmp =  2*`nitems'+2
local pos_demo_i  `tmp'
local tmp =   2*`nitems'+1+`nitemsd'
local pos_demo_f `tmp'
}
/*
dis `pos_share_i' "  "  `pos_share_f'
dis `pos_lnprice_i' "  "  `pos_lnprice_f'
dis `pos_demo_i' "  "  `pos_demo_f'
dis `pos_lnexp' 
*/
qui save mydata, replace

restore

tokenize `snames' 

forvalues i=1/`nitems' {
local names `names' ``i''
}


local nitems1=`nitems'-1
forvalues i=1/`nitems1' {
if `i' != `nitems1' local litems `litems'``i''","
if `i' == `nitems1' local litems `litems'``i'' 
}

local aaa  `"`litems'""'


cap erase Inc_Elas.dta
cap erase Price_Elas.dta

file close _all
local string dol = "$"
file open rcode using  _RProg.R, write replace
local ldemog ""age","hsex","carown","time","tran""
local litems   

if `nitemsd' ==1 {
file write rcode ///
`"chooseCRANmirror(graphics=FALSE,1)"' _newline ///
`"install.packages("rio")"' _newline ///
`"install.packages("micEcon")"' _newline ///
`"install.packages("systemfit")"' _newline ///
`"install.packages("http://dasp-two.vercel.app/webwel/elas/easi/easi_0.21.zip", repos = NULL, type = "binary", dependencies=TRUE) "' _newline ///
`"library(easi)"' _newline ///
`"library(rio)"' _newline ///
`"setwd("`wdir'")"' _newline ///
`"X <- import("mydata.dta")"'  _newline ///
`"shares_HIX    = X[, `pos_share_i':`pos_share_f']"'  _newline ///
`"log.price_HIX = X[,`pos_lnprice_i':`pos_lnprice_f']"'  _newline ///
`"log.exp_HIX   = X[,`pos_lnexp']"'  _newline ///
`"var.soc_HIX   = X[,`pos_demo_i']"'  _newline  ///
`"labels.share=c("`aaa')"'  _newline  ///
`"est <- easi(   shares=shares_HIX,   log.price=log.price_HIX,  var.soc=var.soc_HIX,    y.power=`power',   log.exp=log.exp_HIX,   labels.share=labels.share,   py.inter=`ipy',  zy.inter=`izy',  pz.inter=`ipz',  interpz=c(1)) "'  _newline ///
`"elastincome <- elastic(est,type="income",sd=TRUE)"'  _newline ///
`"elastincome"' `"`=char(36)'"' `"ELASTINCOME[1,labels.share]"'  _newline ///
`"elastprice <- elastic(est,type="price",sd=TRUE)"'  _newline ///
`"elastprice"' `"`=char(36)'"' `"ELASTPRICE[paste("p",labels.share,sep=""), paste("p",labels.share,sep="")]"'  _newline ///
`"X1 <- elastincome"' `"`=char(36)'"' `"ELASTINCOME"'  _newline ///
`"export(X1, "Inc_Elas.dta")"'  _newline ///
`"X2 <- elastprice"' `"`=char(36)'"' `"ELASTPRICE"'  _newline ///
`"export(X2, "Price_Elas.dta")"'  _newline ///
`"coef(est)"'  _newline
file close rcode

}

if `nitemsd' >1 {
file write rcode ///
`"chooseCRANmirror(graphics=FALSE,1)"' _newline ///
`"install.packages("rio")"' _newline ///
`"install.packages("micEcon")"' _newline ///
`"install.packages("systemfit")"' _newline ///
`"install.packages("http://dasp-two.vercel.app/webwel/elas/easi/easi_0.21.zip", repos = NULL, type = "binary", dependencies=TRUE) "' _newline ///
`"library(easi)"' _newline ///
`"library(rio)"' _newline ///
`"setwd("`wdir'")"' _newline ///
`"X <- import("mydata.dta")"'  _newline ///
`"shares_HIX    = X[, `pos_share_i':`pos_share_f']"'  _newline ///
`"log.price_HIX = X[,`pos_lnprice_i':`pos_lnprice_f']"'  _newline ///
`"log.exp_HIX   = X[,`pos_lnexp']"'  _newline ///
`"var.soc_HIX   = X[,`pos_demo_i':`pos_demo_f']"'  _newline  ///
`"labels.share=c("`aaa')"'  _newline  ///
`"est <- easi(   shares=shares_HIX,   log.price=log.price_HIX,  var.soc=var.soc_HIX,    y.power=`power',   log.exp=log.exp_HIX,   labels.share=labels.share,   py.inter=`ipy',  zy.inter=`izy',  pz.inter=`ipz',  interpz=c(1:`nitemsd')) "'  _newline ///
`"elastincome <- elastic(est,type="income",sd=TRUE)"'  _newline ///
`"elastincome"' `"`=char(36)'"' `"ELASTINCOME[1,labels.share]"'  _newline ///
`"elastprice <- elastic(est,type="price",sd=TRUE)"'  _newline ///
`"elastprice"' `"`=char(36)'"' `"ELASTPRICE[paste("p",labels.share,sep=""), paste("p",labels.share,sep="")]"'  _newline ///
`"X1 <- elastincome"' `"`=char(36)'"' `"ELASTINCOME"'  _newline ///
`"export(X1, "Inc_Elas.dta")"'  _newline ///
`"X2 <- elastprice"' `"`=char(36)'"' `"ELASTPRICE"'  _newline ///
`"export(X2, "Price_Elas.dta")"'  _newline ///
`"coef(est)"'  _newline
file close rcode
}


*doedit _RProg.R

dis "Work in Progress under the R Tool. Wait..."
qui shell "`rtool'" CMD BATCH _RProg.R

preserve
qui {
use Inc_Elas.dta, replace
mkmat _all in 1/1, matrix(elas_income) 
}
restore

preserve
qui {
use Price_Elas.dta, replace
mkmat _all in 1/`nitems', matrix(elas_prices) 
}
restore

matrix colnames elas_prices = `names'
matrix rownames elas_prices = `names'

matrix colnames elas_income = `names'
matrix rownames elas_income = "Inc_Elas"

local prdec = `dec'+6
local twi   = `prdec'+2
matlist elas_income , border(all) format(%`prdec'.`dec'f) twidth(`twi') left(1) title( - Income elasticities) 
matlist elas_prices , border(all) format(%`prdec'.`dec'f) twidth(`twi') left(1) title( - Price elasticities) 

ereturn matrix Elas_pr = elas_prices
ereturn matrix Elas_in = elas_income

end
