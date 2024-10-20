

#delimit ;

capture program drop genjobpova;
program define genjobpova, eclass;
version 15;
syntax varlist(min=1)[, 
HSize(varname)  
HGroup(varlist)
XRNAMES(string) 
LAN(string) 
ALpha(real 0) PLine(string)  OPL(string) PROP(real 50) PERC(real 0.4) REL(string) type(string) INDex(string)
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

 if "`index'" == ""  local index = "fgt" ;

if ("`type'"=="")          local type="nor";
if ("`conf'"=="")          local conf="ts";
if ("`rel'"=="")           local rel ="popul"; 

local varpl=0;
capture {; 
qui total `pline'; 
local varpl=1; 
};

local ll=0;


cap drop if `1'==.;
cap drop if `hsize'==.;
cap drop if `hgoup'==.;

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);


local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

local varpl=0;
capture {; 
qui total `pline'; 
local varpl=1; 
};

local ll=0;


cap drop if `1'==.;
cap drop if `hsize'==.;
cap drop if `hgoup'==.;

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);


local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

/* ERRORS */

if (`alpha' == 0 & "`index'"=="ede") {;
 di as err "For the EDE index, the parameter alpha should be greater than 0."; exit;
};


if ("`opl'"=="median")   {;
local opl = "quantile";
local perc = 0.5;
};

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


if "`hgroup'" ~= "" {;
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

if "`hgroup'" ~= "" {
forvalues i=1/`nhgroups' {
	
if ("`index'" == "fgt" | "`index'" == "ede") {	
mbasicfgt  `1' ,  hsize(`_ths')  hgroup(`hgroup_`i'')   pline(`pline')  opl(`opl') prop(`prop')  perc(`perc')  rel(`rel') al(`alpha')  type(`type') index(`index')
}

if ("`index'" == "watts" ) {	
mbasicwatts  `1' ,  hsize(`_ths')  hgroup(`hgroup_`i'')   pline(`pline')  
}

if ("`index'" == "sst" ) {	
mbasicsst  `1' ,  hsize(`_ths')  hgroup(`hgroup_`i'')   pline(`pline')  
}

matrix _ms_`i' = e(mmss)'
local tmatna `tmatna' _ms_`i'
}

#delimit cr

if ("`index'" == "fgt" | "`index'" == "ede") {	
mbasicfgt  `1' ,  hsize(`_ths')   pline(`pline')  opl(`opl') prop(`prop')  perc(`perc') rel(`rel')  al(`alpha') type(`type') index(`index')
}

if ("`index'" == "watts" ) {	
mbasicwatts  `1' ,  hsize(`_ths')     pline(`pline')  
}

if ("`index'" == "sst" ) {	
mbasicsst  `1' ,  hsize(`_ths')    pline(`pline')  
}
matrix _ms_pop = e(mmss)'
local tmatna `tmatna' _ms_pop

}

if "`hgroup'" == "" {
if ("`index'" == "fgt" | "`index'" == "ede") {	
mbasicfgt  `varlist' ,  hsize(`_ths')  pline(`pline')  opl(`opl') prop(`prop')  perc(`perc') rel(`rel') al(`alpha') type(`type') index(`index')
}

if ("`index'" == "watts" ) {	
mbasicwatts  `varlist' ,  hsize(`_ths')    pline(`pline')  
}

if ("`index'" == "sst" ) {	
mbasicsst     `varlist' ,  hsize(`_ths')    pline(`pline')  
}
matrix _ms_pop = e(mmss)'
matrix rownames _ms_pop = "`varlist'"
local tmatna `tmatna' _ms_pop
}

	  
	                            local indexa = "FGT";
	   if "`index'" == "ede"    local indexa = "EDE-FGT";
	   if "`index'" == "watts"  local indexa = "Watts";
	   if "`index'" == "sst"    local indexa = "SST";
   	  di _n as text in white "{col 5}Index            :  `indexa' index"
       if ("`hsize'"!="")   di as text     "{col 5}Household size   :  `hsize'"
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight  :  `hweight'"
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable(s):  `hgroup'"
qui svydes
local fr=`r(N_units)'-`r(N_strata)'

                       local gro = 0	
if ("`hgroup'" ~= "" ) local gro = 1

                               local pop = 1
if (`gro'==0) & (`nvars' > 1)  local pop = 2
_dis_dasp_table_pl  `tmatna' ,  df1(`fr')   level(`level') conf(`conf') hgroup(`hgroup') dec1(`dec1') dec2(`dec2')  gro(`gro') pop(`pop') 


timer off  1
/* timer list 1 */
timer on   2




if ("`xfil'" ~= "" ) {
                       local gro = 0	
if ("`hgroup'" ~= "" ) local gro = 1
if "`xtit'"==""   local xtit  Table ##: `indexa' indices
if `gro' == 1     local xtit `xtit' by population groups
#delimit ;
 mk_xls_m1_pl  `tmatna' ,  df1(`fr')    level(`level') conf(`ci') hgroup(`hgroup') dec1(`dec1') dec2(`dec2')  pop(`pop')       xtit(`xtit') 
 dste(0)  xfil(`xfil') xshe(`xshe') modrep(`modrep')  fcname(Population groups) gro(`gro')
 note1(`note1')  note2(`note2')  note3(`note3')  note4(`note4')  note5(`note5')  note6(`note7') ;
 #delimit cr
} 



restore


end


