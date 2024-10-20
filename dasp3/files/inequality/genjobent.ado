

#delimit ;
/*
capture program drop basicentropy;
program define basicentropy, eclass;
syntax varlist(min=1 ) [, HSize(varname) theta(real 0.5) HGROUP(varname)];

tokenize `varlist';
tempvar fw;
version 15.0;
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
qui gen `fw'=`hsize';
if ("`hweight'"~="")    qui replace `fw'=`fw'*`hweight';



/************/


tempvar vec_a vec_b vec_c;
if ( `theta' !=  0 & `theta' != 1 ) {;
gen   `vec_a' = `hsize'*`1'^`theta';    
gen   `vec_b' = `hsize';           
gen   `vec_c' = `hsize'*`1';     
};
if ( `theta' ==  0) {;
gen   double    `vec_a' = `hsize'*log(`1');    
gen   double    `vec_b' = `hsize';           
gen   double    `vec_c' = `hsize'*`1';  

};

if ( `theta' ==  1 ) {;
gen   double    `vec_a' = `hsize'*`1'*log(`1');    
gen   double    `vec_b' = `hsize';           
gen   double    `vec_c' = `hsize'*`1';  

};

if ("`hgroup'" =="") {;



matrix __ms = J(1,2,0);
qui svy: mean `vec_a' `vec_b' `vec_c'  ;
if ( `theta' !=  0  & `theta' != 1 )  qui nlcom   ( 1/(`theta'*(`theta'-1) ) )*((_b[`vec_a']/_b[`vec_b'])/((_b[`vec_c']/_b[`vec_b'])^`theta') - 1) , iterate(50000);
if ( `theta' ==  0)                  qui nlcom   log(_b[`vec_c']/_b[`vec_b'])-_b[`vec_a']/_b[`vec_b']   , iterate(50000);
if ( `theta' ==  1)                  qui nlcom   (_b[`vec_a']/_b[`vec_c']) - log(_b[`vec_c']/_b[`vec_b']) , iterate(50000);
matrix __ms[1,1] =  el(r(b),1,1);
matrix __ms[1,2] =  el(r(V),1,1)^0.5;
};

if ("`hgroup'" ~="") {;
qui levelsof `hgroup', local(vgr);
local zz = wordcount("`vgr'");
matrix __ms = J(`zz',2,0);
local pos = 1 ;
foreach x of local vgr {;
preserve;
qui keep  if `hgroup' == `x' ;
qui svy: mean `vec_a' `vec_b' `vec_c'  ;
if ( `theta' !=  0 & `theta' != 1 )  qui nlcom   ( 1/(`theta'*(`theta'-1) ) )*((_b[`vec_a']/_b[`vec_b'])/((_b[`vec_c']/_b[`vec_b'])^`theta') - 1) , iterate(50000);
if ( `theta' ==  0)                  qui nlcom   log(_b[`vec_c']/_b[`vec_b'])-_b[`vec_a']/_b[`vec_b'] , iterate(50000);
if ( `theta' ==  1)                  qui nlcom   (_b[`vec_a']/_b[`vec_c'])-log(_b[`vec_c']/_b[`vec_b']) , iterate(50000);                   
matrix __ms[`pos',1] =  el(r(b),1,1);
matrix __ms[`pos',2] =  el(r(V),1,1)^0.5;
local pos = `pos' + 1;
restore; 
};


	
};

ereturn matrix __ms = __ms;
end;
*/
/*
#delimit cr
//set trace on
timer clear 1
timer on 1
basicentropy exppc  ,  hsize( size )  theta(0.500000)  hgroup(gse)
timer off 1
timer list 1
matrix list e(__ms)
*/



capture program drop genjobent;
program define genjobent, eclass;
version 15;
syntax varlist(min=1)[, 
HSize(varname)  
HGroup(varlist)
theta(real 1.0)
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

if ("`hgroup'" ~= "" ) {
forvalues i=1/`nhgroups' {
mbasicent `1' ,  hsize(`_ths')  hgroup(`hgroup_`i'')   theta(`theta') 
matrix _ms_`i' = e(mmss)'
local tmatna `tmatna' _ms_`i'
}


mbasicent `1' ,  hsize(`_ths')     theta(`theta') 
#delimit cr
matrix _ms_pop = e(mmss)'
local tmatna `tmatna' _ms_pop
}


if ("`hgroup'" == "" ) {
mbasicent `varlist' ,  hsize(`_ths')     theta(`theta') 
#delimit cr
matrix _ms_pop = e(mmss)'
matrix rownames _ms_pop = `varlist'
local tmatna `tmatna' _ms_pop
}


	  
	   local index = "Entropy";
   	  di _n as text in white               "{col 5}Index            :  `index' index"
                            di as text     "{col 5}theta            :  `theta'"
       if ("`hsize'"!="")   di as text     "{col 5}Household size   :  `hsize'"
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight  :  `hweight'"
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable(s):  `hgroup'"
qui svydes
local fr=`r(N_units)'-`r(N_strata)'
                       local gro = 0	
if ("`hgroup'" ~= "" ) local gro = 1

                               local pop = 1
if (`gro'==0) & (`nvars' > 1)  local pop = 2

_dis_dasp_table  `tmatna' ,  df1(`fr')   level(`level') conf(`conf') hgroup(`hgroup') dec1(`dec1') dec2(`dec2')  gro(`gro') pop(`pop')



timer off  1
/* timer list 1 */
timer on   2



if ("`xfil'" ~= "" ) {
                       local gro = 0	
if ("`hgroup'" ~= "" ) local gro = 1
if "`xtit'"==""   local xtit Table ##: Entropy index
if `gro' == 1     local xtit `xtit' by population groups
local note1 Parameter theta = `theta'
#delimit ;
 mk_xls_m1  `tmatna' ,  df1(`fr')    level(`level') conf(`ci') hgroup(`hgroup') dec1(`dec1') dec2(`dec2')  pop(`pop')  xtit(`xtit') 
 dste(0)  xfil(`xfil') xshe(`xshe') modrep(`modrep')  fcname(Population groups) gro(`gro')
 note1(`note1')  note2(`note2')  note3(`note3')  note4(`note4')  note5(`note5')  note6(`note7') ;
 #delimit cr
} 




restore


#delimit cr

end

