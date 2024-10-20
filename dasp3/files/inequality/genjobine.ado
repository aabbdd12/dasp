

#delim ;
capture program drop genjobine;
program define genjobine, eclass;
version 15;
syntax varlist(min=1)[, 
HSize(varname)  
HGroup(varlist)
p1(real 0.1) p2(real 0.2) p3(real 0.8) p4(real 0.9) index(string) 
XRNAMES(string) 
LAN(string) 
xshe(string) modrep(string) 
xfil(string) xtit(string) eformat(string)
note1(string) note2(string) note3(string) note4(string)  note5(string) 
note6(string) note7(string) note8(string) note9(string)  note10(string) 
note11(string) note12(string) note13(string) note14(string)  note15(string) 
note16(string) note17(string) note18(string) note19(string)  note20(string)  
CHANGE(string)
dec1(int 4)
dec2(int 4)
LEVEL(int 95)  CONF(string) *
];


version 15;
*set trace on;
preserve;


if ("`conf'"=="")          local conf="ts";
local ll=0;

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);


local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

timer clear;
timer on 1;

local rnam ;
local lctmp_1  ;

if ("`xrnames'"~="") {;
local xrna  "`xrnames'" ;
local xrna : subinstr local xrna " " ",", all ; 
local xrna : subinstr local xrna "|" " ", all ;
local count : word count `xrna';
tokenize "`xrna'";
forvalues i = 1/`count' {;
        local `i': subinstr local `i' "," "", all ;
            local j = `i' + 1;
            local lctmp_`i' = substr("``i''",1,30);
};
};


if ("`hgroup'" ~= "" ) {;
tokenize `hgroup';
_nargs   `hgroup' ;
local nhgroups = $indica;
forvalues i=1/$indica {;
local hgroup_`i' = "``i''" ;    
};
};

tokenize  `varlist';
_nargs    `varlist';
local indica2 = $indica;
local nvars = wordcount("`varlist'");


tempvar _ths;
qui gen  `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';
/*
if ( "`change'"=="") local change == abs;
*/
cap svy: total;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
#delimit cr


if ("`hgroup'" ~= "" ) {
forvalues i=1/`nhgroups' {
mbasicine `1' ,  hsize(`_ths')  hweight(`hweight')  hgroup(`hgroup_`i'')   p1(`p1') p2(`p2') p3(`p3') p4(`p4') index(`index') 
matrix _ms_`i' = e(mmss)'
local tmatna `tmatna' _ms_`i'
}


mbasicine `1' ,  hsize(`_ths')  hweight(`hweight')    p1(`p1') p2(`p2') p3(`p3') p4(`p4') index(`index') 
#delimit cr
matrix _ms_pop = e(mmss)'
local tmatna `tmatna' _ms_pop
}

if ("`hgroup'" == "" ) {


mbasicine `varlist' ,  hsize(`_ths')  hweight(`hweight')    p1(`p1') p2(`p2') p3(`p3') p4(`p4') index(`index') 
#delimit cr
matrix _ms_pop = e(mmss)'
matrix rownames _ms_pop = `varlist'
local tmatna `tmatna' _ms_pop
}

	  
if ("`index'"=="qr")  local ind = "Quantile ratio"
if ("`index'"=="sr")  local ind = "Share ratio"

   	  di _n as text in white "{col 5}Index            :  `ind' index"
	  if "`index'" == "qr"  di as text     "{col 5}Quantile ratio   :  Q(p1=`p1')/Q(p2=`p2') "
      if "`index'" == "sr"  di as text     "{col 5}Share ratio      :  (Q(p2=`p1') -  Q(p1=`p2'))/(Q(p4=`p4') -  Q(p3=`p3')) "
       if ("`hsize'"!="")   di as text     "{col 5}Household size   :  `hsize'"
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight  :  `hweight'"
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable(s):  `hgroup'"
qui svydes
local fr=`r(N_units)'-`r(N_strata)'

                       local gro = 0	
if ("`hgroup'" ~= "" ) local gro = 1
                               local pop = 1
if (`gro'==0) & (`nvars' > 1)  local pop = 2

_dis_dasp_table  `tmatna' ,  df1(`fr')   level(`level') conf(`conf') hgroup(`hgroup') dec1(`dec1') dec2(`dec2')  gro(`gro')  pop(`pop') 


timer off  1
/* timer list 1 */
timer on   2



if ("`xfil'" ~= "" ) {
local gro = 0	
if ("`hgroup'" ~= "" ) local gro = 1

if "`xtit'"==""   local xtit Table ##:  `ind' inequality index
if `gro' == 1   local xtit `xtit' by population groups
if "`index'" == "qr" local note1 Quantile ratio inequality index  = Q(p1=`p1') /  Q(p2=`p2')
if "`index'" == "sr" local note1 Share ratio inequality index     = (Q(p2=`p1') -  Q(p1=`p2')) /  (Q(p4=`p4') -  Q(p3=`p3'))
#delimit ;
 mk_xls_m1  `tmatna' ,  df1(`fr')    level(`level') conf(`ci') hgroup(`hgroup') dec1(`dec1') dec2(`dec2')  pop(`pop')       xtit(`xtit') 
 dste(0)  xfil(`xfil') xshe(`xshe') modrep(`modrep')  fcname(Population groups) gro(`gro')
 note1(`note1')  note2(`note2')  note3(`note3')  note4(`note4')  note5(`note5')  note6(`note7') ;
 #delimit cr
} 






restore


end


