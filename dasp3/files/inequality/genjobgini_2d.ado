/********************************************************************************/
/*  Stata Version : Required  15.0 and higher                                   */
/*  Authors       : Abdelkrim Araar  // aabd@ecn.ulaval.ca                      */
/********************************************************************************/

#delimit ;


#delimit ;
capture program drop mbasicgini;
program define mbasicgini, eclass;  
version 15;   
syntax varlist (min=1) [, HSize(varname) HWeight(varname) RANK(varname) HGroup(varname) conf(real 5)  LEVEL(real 95) XRNAMES(string) TYPE(string)];
preserve;
tokenize `varlist';
_nargs   `varlist';
version 15 ;
if "`hsize'" == "" {;
tempvar hsize; qui g `hsize' = 1;
};


if "`hgroup'" == "" {;
tempvar hgroup; qui g `hgroup' = 1;
};


qui levelsof `hgroup', local(mygr);
local mystr `r(levels)';
local ngr `: word count `mystr'';
tempname aa bb cc dd ee ff aabb;
matrix `aa' =J($indica,`ngr',.) ;
matrix `bb' =J($indica,`ngr',.) ;
matrix `cc' =J($indica,`ngr',.) ;
matrix `dd' =J($indica,`ngr',.) ;
matrix `ee' =J($indica,`ngr',.) ;
matrix `ff' =J($indica,`ngr',.) ;

qui levelsof `hgroup', local(mygr);
local mystr `r(levels)';
local ngr `: word count `mystr'';
local i = 1;

                     qui drop if `1'>=. ;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;


tempvar  hs sw fw ;
qui gen double `sw'=1.0;
qui gen double `hs'=1.0;
if ("`hweight'"!="")   qui replace `sw'=`hweight';
if ("`hsize'"!="")     qui replace `hs' = `hsize';

gen double `fw'=`hs'*`sw';

local tpos = 0; 
foreach x of local mygr { ;
qui count  if `hgroup' == `x';
local  N`x' = `r(N)';
local  FN`x'  = `tpos' + 1;
local  FN2`x' = `tpos' + 2;
local  EN`x' = `tpos'+`r(N)';
local  tpos  = `tpos'+`r(N)';
/* dis `x' "   " `FN`x'' "   " `EN`x''  ; */
} ;

tempvar ngrroup;
gen `ngrroup' = `hgroup' ;

forvalues i = 1/$indica { ;

if ("`rank'"=="") sort `hgroup' ``i''   , stable;
if ("`rank'"!="") sort `hgroup' `rank'  , stable;


local list1 smw smwy l1smwy ca vec_a vec_b theta v1 v2 sv1 sv2 v1 v2 vfx theta; 
foreach name of local list1 {;
cap drop ``name'' ;
};
cap drop `smw';
cap drop `smwy';
cap drop `llsmwy';
cap drop `ca';
tempvar smw smwy l1smwy ca;
gen  double `smw'  =0;
gen  double `smwy' =0;
qui gen double `l1smwy'=0;
qui gen double  `ca'= 0;
//gen suma = 0;

foreach x of local mygr { ;
qui replace `smw'  =sum(`fw')        if `hgroup' == `x';
qui replace `smwy' =sum(``i''*`fw')  if `hgroup' == `x';
};



foreach x of local mygr { ;
local mu`x'  =`smwy'[`EN`x'']/`smw'[`EN`x''];
local suma`x'=`smw'[`EN`x''];
qui replace `l1smwy'=`smwy'[_n-1]   if `hgroup' == `x';
qui replace `l1smwy' = 0 in `FN`x'' if `hgroup' == `x'; 
qui replace `ca'=`mu`x''+``i''*((1.0/`smw'[`EN`x''])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[`EN`x''])*(2.0*`l1smwy'+`fw'*``i'') if `hgroup' == `x'; 
qui sum `ca' [aw=`fw']  if `hgroup' == `x', meanonly; 
local gini_`x'=`r(mean)'/(2.0*`mu`x'');
if  ("`type'" == "abs") local gini_`x'=`r(mean)'/(2.0);
local xi`x' = `r(mean)';
};

tempvar vec_a_`i' vec_b_`i' theta v1 v2 sv1 sv2;

      

gen `v1'=`fw'*``i'';
gen `v2'=`fw';

gen `sv1'=0;
gen `sv2'= 0;

tempvar vfx ;
cap drop `vfx' ;
qui gen `vfx' =0;
cap drop `vec_a_`i'';
cap drop `vec_b_`i'';
cap drop `theta';
qui  gen `vec_a_`i'' = 0 ;
qui  gen `vec_b_`i'' = 0 ;
qui  gen `theta' = 0; 
foreach x of local mygr { ;
qui replace `sv1'=sum(`v1') if `hgroup' == `x';
qui replace `sv2'=sum(`v2') if `hgroup' == `x';

qui replace `v1'=`sv1'[`EN`x'']   in `FN`x''    if `hgroup' == `x';
qui replace `v2'=`sv2'[`EN`x'']   in `FN`x''    if `hgroup' == `x';     
qui replace `v1'=`sv1'[`EN`x'']-`sv1'[_n-1] in `FN2`x''/`EN`x'' if `hgroup' == `x';
qui replace `v2'=`sv2'[`EN`x'']-`sv2'[_n-1] in `FN2`x''/`EN`x'' if `hgroup' == `x';
qui replace `vfx' = sum(`fw'*``i'')  if `hgroup' == `x';
local fx_`x' = `vfx'[`EN`x'']/`suma`x''; 
qui replace    `theta'=(`v1'-`v2'*``i'')*(2.0/`suma`x'')  if `hgroup' == `x';
qui replace `vec_a_`i'' = `hs'*((1.0)*`ca'+(``i''-`fx_`x'')+`theta'-(1.0)*(`xi`x'')) if `hgroup' == `x';
};

qui  replace  `vec_b_`i'' =  2*`hs'*``i'';




if  ("`type'" == "abs") qui replace `vec_b_`i''  =  2*`hs';
qui  svy: ratio (`vec_a_`i''/`vec_b_`i'') , over(`hgroup'); 

forvalues v=1/`ngr' {;
matrix `aa'[`i',`v'] = el(e(b), 1 , `v');
matrix `bb'[`i',`v'] = el(e(V), `v' , `v')^0.5;
};
matrix __aa = `aa';
matrix __bb = `bb';
matrix __ms = __aa\__bb;
ereturn matrix mmss_``i'' = __ms  ;
};

matrix __aa = `aa';
matrix __bb = `bb';
matrix __ms = __aa\__bb;
ereturn matrix mmss = __ms  ;
cap matrix drop __aa;
cap matrix drop __bb;
cap matrix drop __ms;
*ereturn clear ;

end;    


capture program drop mbasicgini2;
program define mbasicgini2, eclass;  
version 15;   
syntax varlist (min=1 max=2) [, HSize1(varname) RANK1(varname)  HSize2(varname) RANK2(varname)  HWeight(varname) HGroup(varname) conf(real 5)  LEVEL(real 95) XRNAMES(string) TYPE(string)];
preserve;
tokenize `varlist';
_nargs   `varlist';
version 15 ;
if "`hsize'" == "" {;
tempvar hsize; qui g `hsize' = 1;
};


if "`hgroup'" == "" {;
tempvar hgroup; qui g `hgroup' = 1;
};

qui levelsof `hgroup', local(mygr);
local mystr `r(levels)';
local ngr `: word count `mystr'';

tempname aa bb cc dd ee ff aabb;
matrix `aa' =J($indica,`ngr',.) ;
matrix `bb' =J($indica,`ngr',.) ;
matrix `cc' =J($indica,`ngr',.) ;
matrix `dd' =J($indica,`ngr',.) ;
matrix `ee' =J($indica,`ngr',.) ;
matrix `ff' =J($indica,`ngr',.) ;

qui levelsof `hgroup', local(mygr);
local mystr `r(levels)';
local ngr `: word count `mystr'';
local i = 1;

                     qui drop if `1'>=. ;
if ("`hsize1'"!="")   qui drop if `hsize1'>=.;
if ("`hweight1'"!="") qui drop if `hweigh1t'>=.;

                     qui drop if `2'>=. ;
if ("`hsize2'"!="")   qui drop if `hsize2'>=.;
if ("`hweight2'"!="") qui drop if `hweight2'>=.;


tempvar  hs1 sw1 fw1 ;
qui gen double `sw1'=1.0;
qui gen double `hs1'=1.0;
if ("`hweight1'"!="")   qui replace `sw1'=`hweight1';
if ("`hsize1'"!="")     qui replace `hs1' = `hsize1';

gen double `fw1'=`hs1'*`sw1';

tempvar  hs2 sw2 fw2 ;
qui gen double `sw2'=1.0;
qui gen double `hs2'=1.0;
if ("`hweight2'"!="")   qui replace `sw2'=`hweight2';
if ("`hsize2'"!="")     qui replace `hs2' = `hsize2';

gen double `fw2'=`hs2'*`sw2';


local tpos = 0; 
foreach x of local mygr { ;
qui count  if `hgroup' == `x';
local  N`x' = `r(N)';
local  FN`x'  = `tpos' + 1;
local  FN2`x' = `tpos' + 2;
local  EN`x' = `tpos'+`r(N)';
local  tpos  = `tpos'+`r(N)';
/* dis `x' "   " `FN`x'' "   " `EN`x''  ; */
} ;

tempvar ngrroup;
gen `ngrroup' = `hgroup' ;


forvalues i = 1/$indica { ;

if ("`rank`i''"=="") sort `hgroup' ``i''      , stable;
if ("`rank`i''"!="") sort `hgroup' `rank`i''  , stable;


local list1 smw smwy l1smwy ca vec_a vec_b theta v1 v2 sv1 sv2 v1 v2 vfx theta; 
foreach name of local list1 {;
cap drop ``name'' ;
};
cap drop `smw';
cap drop `smwy';
cap drop `llsmwy';
cap drop `ca';
tempvar smw smwy l1smwy ca;
gen  double `smw'  =0;
gen  double `smwy' =0;
qui gen double `l1smwy'=0;
qui gen double  `ca'= 0;
//gen suma = 0;

foreach x of local mygr { ;
qui replace `smw'  =sum(`fw`i'')        if `hgroup' == `x';
qui replace `smwy' =sum(``i''*`fw`i'')  if `hgroup' == `x';
};



foreach x of local mygr { ;
local mu`x'  =`smwy'[`EN`x'']/`smw'[`EN`x''];
local suma`x'=`smw'[`EN`x''];
qui replace `l1smwy'=`smwy'[_n-1]   if `hgroup' == `x';
qui replace `l1smwy' = 0 in `FN`x'' if `hgroup' == `x'; 
qui replace `ca'=`mu`x''+``i''*((1.0/`smw'[`EN`x''])*(2.0*`smw'-`fw`i'')-1.0) - (1.0/`smw'[`EN`x''])*(2.0*`l1smwy'+`fw`i''*``i'') if `hgroup' == `x'; 
qui sum `ca' [aw=`fw`i'']  if `hgroup' == `x', meanonly; 
local gini_`x'=`r(mean)'/(2.0*`mu`x'');
if  ("`type'" == "abs") local gini_`x'=`r(mean)'/(2.0);
local xi`x' = `r(mean)';
};

tempvar vec_a_`i' vec_b_`i' theta v1 v2 sv1 sv2;

      

gen `v1'=`fw`i''*``i'';
gen `v2'=`fw`i'';

gen `sv1'=0;
gen `sv2'= 0;

tempvar vfx ;
cap drop `vfx' ;
qui gen `vfx' =0;
cap drop `vec_a_`i'';
cap drop `vec_b_`i'';
cap drop `theta';
qui  gen `vec_a_`i'' = 0 ;
qui  gen `vec_b_`i'' = 0 ;
qui  gen `theta' = 0; 
foreach x of local mygr { ;
qui replace `sv1'=sum(`v1') if `hgroup' == `x';
qui replace `sv2'=sum(`v2') if `hgroup' == `x';

qui replace `v1'=`sv1'[`EN`x'']   in `FN`x''    if `hgroup' == `x';
qui replace `v2'=`sv2'[`EN`x'']   in `FN`x''    if `hgroup' == `x';     
qui replace `v1'=`sv1'[`EN`x'']-`sv1'[_n-1] in `FN2`x''/`EN`x'' if `hgroup' == `x';
qui replace `v2'=`sv2'[`EN`x'']-`sv2'[_n-1] in `FN2`x''/`EN`x'' if `hgroup' == `x';
qui replace `vfx' = sum(`fw`i''*``i'')  if `hgroup' == `x';
local fx_`x' = `vfx'[`EN`x'']/`suma`x''; 
qui replace    `theta'=(`v1'-`v2'*``i'')*(2.0/`suma`x'')  if `hgroup' == `x';
qui replace `vec_a_`i'' = `hs`i''*((1.0)*`ca'+(``i''-`fx_`x'')+`theta'-(1.0)*(`xi`x'')) if `hgroup' == `x';
};

qui  replace  `vec_b_`i'' =  2*`hs`i''*``i'';

if  ("`type'" == "abs") qui replace `vec_b_`i''  =  2*`hs`i'';
qui  svy: ratio (`vec_a_`i''/`vec_b_`i'') , over(`hgroup'); 

if (`i' == 1) {;
forvalues v=1/`ngr' {;
matrix `aa'[1,`v'] = el(e(b), 1 , `v');
matrix `aa'[2,`v'] = el(e(V), `v' , `v')^0.5;
};
matrix __aa_1 = `aa';
};
if (`i' == 2) {;
forvalues v=1/`ngr' {;
matrix `aa'[1,`v'] = el(e(b), 1 , `v');
matrix `aa'[2,`v'] = el(e(V), `v' , `v')^0.5;
};
matrix __aa_2 = `aa';
matrix __ms = __aa_1\__aa_2;
};

if (`i'== 2) {;
local v = 1;
 foreach x of local mygr { ;
 qui svy:mean `vec_a_1' `vec_b_1' `vec_a_2' `vec_b_2' if (`hgroup'==`x'); 
	qui nlcom (_b[`vec_a_1']/_b[`vec_b_1']) - (_b[`vec_a_2']/_b[`vec_b_2']) ;
	matrix `aa'[1,`v'] = el(r(b), 1 , 1);
    matrix `aa'[2,`v'] = el(r(V), 1 , 1)^0.5;
	local v=`v'+1;
 };
matrix __aa = `aa';
matrix __bb = `bb';
matrix __ms = __ms\__aa;
};



};

ereturn matrix mmss  = __ms   ;


cap matrix drop __aa;
cap matrix drop __bb;
cap matrix drop __ms;
*ereturn clear ;
end;    




capture program drop genjobgini_2d;
program define genjobgini_2d, eclass;
version 15;
syntax namelist(min=2 max=2)[, 
FILE1(string) FILE2(string) 
RANK1(string)  RANK2(string)
HSize1(string) HSize2(string)
COND1(string)  COND2(string)  
HGROUP(varlist)
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
LEVEL(int 95)  CONF(string) TYPE(string) *
];


version 15;
*set trace on;


local ddep=0;
if ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) local ddep=1;

if (`ddep'==1) {; 
preserve;
if "`file1'" ~="" & "`file2'" ~="" { ;
qui use "`file1'", replace; 
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

tokenize  `namelist';
_nargs    `namelist';
local indica2 = $indica;



tempvar _ths1;
qui gen  `_ths1'=1;
if ( "`hsize1'"!="") qui replace `_ths1'=`hsize1';
tempvar _ths2;
qui gen  `_ths2'=2;
if ( "`hsize2'"!="") qui replace `_ths2'=`hsize2';
/*
if ( "`change'"=="") local change == abs;
*/
cap svy: total;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
#delimit cr

if ("`hgroup'"~="") {
forvalues i=1/`nhgroups' {
mbasicgini2 `namelist' ,  hsize1(`_ths1') hsize2(`_ths2')  hgroup(`hgroup_`i'')  xrnames(`xrnames') rank1(`rank1') rank2(`rank2')  type(`type')
matrix _ms_`i' = e(mmss)'
local tmatna `tmatna' _ms_`i'
}
}

mbasicgini2 `namelist' ,  hsize1(`_ths1') hsize2(`_ths2')   xrnames(`xrnames') rank1(`rank1') rank2(`rank2')  type(`type')
#delimit cr
matrix _ms_pop = e(mmss)'



} //ddep==1



if (`ddep'==0) {

forvalues dd=1/2 {
#delimit ;
preserve;
if "`file`dd''" ~="" { ;
qui use "`file`dd''", replace; 
};
qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local hweight1=""; 
cap qui svy: total ``dd''; 
local hweight`dd'=`"`e(wvar)'"';
cap ereturn clear; 
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

tokenize  `namelist';


tempvar   _ths`dd';
qui gen  `_ths`dd''=1;
if ( "`hsize1'"!="") qui replace `_ths`dd''=`hsize`dd'';

cap svy: total;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

#delimit cr

if ("`hgroup'"~="") {
forvalues i=1/`nhgroups' {
mbasicgini ``dd'' ,  hsize(`_ths`dd'')  hgroup(`hgroup_`i'')  xrnames(`xrnames') rank(`rank`dd'') type(`type')
matrix _ms_`dd'_`i' = e(mmss)'
}
}

mbasicgini ``dd'' ,  hsize(`_ths`dd'')    xrnames(`xrnames') rank(`rank`dd'')  type(`type')
#delimit cr
matrix _ms_`dd'_pop = e(mmss)'

qui svydes
local fr_`dd'=`r(N_units)'-`r(N_strata)'


restore



}

local tmatna_1 = ""
if ("`hgroup'"~="") {
forvalues i=1/`nhgroups' {

local rr=rowsof(_ms_1_`i')
matrix dif = J(`rr',2,0)
matrix  _mss_`i'  = _ms_1_`i' , _ms_2_`i'
forvalues l=1/`rr' {
	matrix dif[`l',1] = el(_ms_1_`i',`l',1) - el(_ms_2_`i',`l',1) 
	matrix dif[`l',2] = (el(_ms_1_`i',`l',2)^2 + el(_ms_2_`i',`l',2)^2)^0.5 
}
matrix  _mss_`i'=_mss_`i', dif
local tmatna  `tmatna'  _mss_`i'
}
}

matrix difp = J(1,2,0)
	matrix difp[1,1] = el(_ms_1_pop,1,1) - el(_ms_2_pop,1,1) 
	matrix difp[1,2] = (el(_ms_1_pop,1,2)^2 + el(_ms_2_pop,1,2)^2)^0.5 
matrix _ms_pop = _ms_1_pop, _ms_2_pop,difp
local tmatna  `tmatna'  _ms_pop




}
local fr = `fr_1'+`fr_2' 

 //ddep==0 end



	  

	if ("`rank1'"=="" | "`rank1'"=="`1'" ) &  ("`rank2'"~="" | ( "`rank2'"~="`2'" & "`rank2'"~="" ))      &     ("`type'"=="")  local index = "Difference between Gini and concentration"
	if ("`rank1'"=="" | "`rank1'"=="`1'" ) & ("`rank2'"=="" | "`rank2'"=="`2'" )   & ("`type'"=="")     local index = "Difference between Gini"
	if ("`rank1'"~="" | ("`rank1'"~="`1'"  & "`rank1'"~="" ))  &  ("`rank2'"=="" | "`rank2'"=="`2'" )     &   ("`type'"=="")                      local index = "Difference between concentration and Gini"
	if ("`rank1'"~="" & "`rank2'"~="" ) & ("`rank1'"~="`1'" & "`rank2'"~="`2'" ) & ("`type'"=="")     local index = "Difference between concentration"
	
		
	if ("`rank1'"=="" | "`rank1'"=="`1'" ) &  ("`rank2'"~="" | "`rank2'"~="`2'" )     & ("`type'"=="abs")                     local index = "Difference between absolute Gini and absolute concentration"	
	if ("`rank1'"=="" | "`rank1'"=="`1'" ) & ("`rank2'"=="" | "`rank2'"=="`2'" ) & ("`type'"=="abs")     local index = "Difference between absolute Gini"

	if ("`rank1'"~="" | "`rank1'"~="`1'" ) &  ("`rank2'"=="" | "`rank2'"=="`2'" )     &  ("`type'"=="abs")                     local index = "Difference between absolute concentration and absolute Gini"
	if ("`rank1'"~="" & "`rank2'"~="" ) & ("`rank1'"~="`1'" & "`rank2'"~="`2'" ) & ("`type'"=="abs")      local index = "Difference between absolute concentration"
	
	


	  di _n as text in white "{col 5}Index            :  `index' indices"
       if ("`rank1'"!="")    di as text     "{col 5}Ranking variable :  `rank1'"
       if ("`hsize'"!="")   di as text     "{col 5}Household size   :  `hsize'"
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight  :  `hweight'"
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable(s):  `hgroup'"




 
                       local gro = 0	
if ("`hgroup'" ~= "" ) local gro = 1
_dis_dasp_table_2d  `tmatna' ,  df(`fr')   level(`level') conf(`conf') hgroup(`hgroup') dec1(`dec1') dec2(`dec2')  gro(`gro')


timer off  1
/* timer list 1 */
timer on   2



if ("`xfil'" ~= "" ) {
                       local gro = 0	
if ("`hgroup'" ~= "" ) local gro = 1
	if "`xtit'"==""   local xtit Table ##: " `index' indices"
if `gro' == 1   local xtit `xtit' by population groups 
if ("`hgroup'" ~= "" ) local gro = 1
#delimit ;
 mk_xls_m1_2d  `tmatna' ,  df1(`fr')    level(`level') conf(`conf') hgroup(`hgroup') dec1(`dec1') dec2(`dec2')  pop(1)       xtit(`xtit') 
 dste(0)  xfil(`xfil') xshe(`xshe') modrep(`modrep')  fcname(Population groups) gro(`gro')
 note1(`note1')  note2(`note2')  note3(`note3')  note4(`note4')  note5(`note5')  note6(`note7') ;
 #delimit cr
} 







#delimit cr

end


/*
  //set trace on
  set tracedepth 2

sysuse bkf94I,  replace
save file_1994, replace
sysuse bkf98I,  replace
save file_1998, replace
adopath ++ C:\Users\aabd\Desktop\dasp302
	genjobgini_2d expeq totexp  ,   file1(file_1994) hsize1(size) file2(file_1998) hsize2(size)  ///
    xrnames("Var 1" )     dec1(6)    ///
	hgroup(sex gse) xtit() xshe(Table1)  ///
	rank1(sex)  rank2(zone)   ///
	xfil("xls_res")     type() ///
	modrep(replace)  level(90)
	*/