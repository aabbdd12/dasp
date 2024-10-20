/********************************************************************************/
/*  Stata Version : Required  15.0 and higher                                   */
/*  Authors       : Abdelkrim Araar  // aabd@ecn.ulaval.ca                      */
/********************************************************************************/


#delimit ;

capture program drop gen_pov_2d;
program define gen_pov_2d, eclass;
version 15;
syntax namelist(min=2)[, 
FILE1(string) FILE2(string) 
HSize1(string) HSize2(string)
COND1(string)  COND2(string)  
HGROUP(namelist)
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
LEVEL(int 95)  CONF(string)
ALpha(real 0) TYPE(string)
PLINE1(string) OPL1(string) PROP1(real 50) PERC1(real 0.4)
PLINE2(string) OPL2(string) PROP2(real 50) PERC2(real 0.4)
index(string) BOOT(string) NREP(string) TEST(string)
*
];


if ("`index'" == "" ) local index = "fgt" ;
if  ("`type'" == "" ) local type  = "nor" ;

forvalues dd=1/2 {;
	
	if "`opl`dd''"=="median" {;
		local  opl`dd' = "quantile";
		local perc`dd'= 0.5;
	};
};
	
local ddep=0;
local nvars = 1;
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
if "`hweight'"~="" {;
	local hweight1= "`hweight'"; 
	local hweight2= "`hweight'"; 
};
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




tempvar cd1;
if ( "`cond1'"~="") {;
gen `cd1'=(`cond1');
qui replace `_ths1'=`_ths1'*`cd1';
qui sum `cd1';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_1, the number of observations is 0.";
exit;
};
};

tempvar cd2 ;
if ( "`cond2'"~="") {;
gen `cd2'=(`cond2');
qui replace `_ths2'=`_ths2'*`cd2';
qui sum `cd2i';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_2, the number of observations is 0.";
exit;
};
};




cap svy: total;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
#delimit cr

if ("`hgroup'"~="") {
forvalues i=1/`nhgroups' {
	
if ("`index'" == "fgt" | "`index'" == "ede" )  {	
mbasicfgt2 `namelist' ,  hsize1(`_ths1') hsize2(`_ths2')  hgroup(`hgroup_`i'')  xrnames(`xrnames') pline1(`pline1') pline2(`pline2')  ///
opl1(`opl1') prop1(`prop1') perc1(`perc1')  opl2(`opl2') prop2(`prop2') perc2(`perc2') al(`alpha') type(`type')  
}
if ("`index'" == "watts")  {	
mbasicwatts2 `namelist' ,  hsize1(`_ths1') hsize2(`_ths2')  hgroup(`hgroup_`i'')  xrnames(`xrnames') pline1(`pline1') pline2(`pline2')  
}

if ("`index'" == "sst")  {	
mbasicsst2 `namelist' ,  hsize1(`_ths1') hsize2(`_ths2')  hgroup(`hgroup_`i'')  xrnames(`xrnames') pline1(`pline1') pline2(`pline2') 
}



matrix _ms_`i' = e(mmss)'
local tmatna `tmatna' _ms_`i'
}
}

if ("`index'" == "fgt" | "`index'" == "ede" )  {	
mbasicfgt2 `namelist' ,  hsize1(`_ths1') hsize2(`_ths2')  xrnames(`xrnames') pline1(`pline1') pline2(`pline2')  ///
opl1(`opl1') prop1(`prop1') perc1(`perc1')  opl2(`opl2') prop2(`prop2') perc2(`perc2') al(`alpha') type(`type')  
}
if ("`index'" == "watts")  {	
mbasicwatts2 `namelist' ,  hsize1(`_ths1') hsize2(`_ths2')   xrnames(`xrnames') pline1(`pline1') pline2(`pline2')  
}

if ("`index'" == "sst")  {	
mbasicsst2 `namelist' ,  hsize1(`_ths1') hsize2(`_ths2')    xrnames(`xrnames') pline1(`pline1') pline2(`pline2') 
}

	


#delimit cr
matrix _ms_pop = e(mmss)'
local tmatna  `tmatna'  _ms_pop

qui svydes
local fr=`r(N_units)'-`r(N_strata)'



} //ddep==1



if (`ddep'==0) {



#delimit ;

forvalues dd=1/2{;
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
qui levelsof(``i'') , local(level_``i''_`dd'); 
};
};

if (`dd' == 2 ) {;
forvalues i=1/$indica {;
local nfals = 0;
foreach g1 of local level_``i''_1 {;
	local fal = 1;
	foreach g2 of local level_``i''_2 {;
	if `g1' == `g2' local fal = 0;
	};
	if `fal' == 1 dis as error "Error : Modality " `g1' " is in Dist1 but not in Dist 2 : group variable (``i'')";
	local nfals = `nfals'+`fal';
};

foreach g2 of local level_``i''_2 {;
	local fal = 1;
	foreach g1 of local level_``i''_1 {;
	if `g2' == `g1' local fal = 0;
	//dis `g2' " : " `fal';
	};
	if `fal' == 1 dis as error "Error : Modality " `g2' " is in Dist2 but not in Dist 1:  group variable (``i'')";
	local nfals = `nfals'+`fal';
};
if (`nfals' > 0) exit ;
}; 
};

tokenize  `namelist';


tempvar   _ths`dd';
qui gen  `_ths`dd''=1;
if ( "`hsize`dd'''"!="") qui replace `_ths`dd''=`hsize`dd'';

tempvar cd`dd';
if ( "`cond`dd''"!="") {;
gen `cd`dd''=`cond`dd'';
qui replace `_ths`dd''=`_ths`dd''*`cd`dd'';
qui sum `_ths`dd'';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_`dd', the number of observations is 0.";
exit;
};
};

cap svy: total;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

#delimit cr

if ("`hgroup'"~="")      {
forvalues i=1/`nhgroups' {
	
if ("`index'" == "fgt" | "`index'" == "ede" )   {	
mbasicfgt ``dd'' ,  hsize(`_ths`dd'')   hgroup(`hgroup_`i'')  pline(`pline`dd'') xrnames(`xrnames')  type(`type') opl(`opl`dd'') prop(`prop`dd'')  perc(`perc`dd'') 
}
if ("`index'" == "watts")  {	
mbasicwatts ``dd'' ,  hsize(`_ths`dd'')  hgroup(`hgroup_`i'')   pline(`pline`dd'') xrnames(`xrnames') 
}

if ("`index'" == "sst")  {	
mbasicsst ``dd'' ,  hsize(`_ths`dd'')  hgroup(`hgroup_`i'') pline(`pline`dd'')  xrnames(`xrnames') 
}

matrix _ms_`dd'_`i' = e(mmss)'
matrix _ms_`dd'_`i' = _ms_`dd'_`i'[.,1..2]

}

if ("`index'" == "fgt" | "`index'" == "ede" )   {		
mbasicfgt ``dd'' ,  hsize(`_ths`dd'')    pline(`pline`dd'') xrnames(`xrnames')   type(`type') opl(`opl`dd'') prop(`prop`dd'')  perc(`perc`dd'') 
}
if ("`index'" == "watts")  {	
mbasicwatts ``dd'' ,  hsize(`_ths`dd'')     pline(`pline`dd'') xrnames(`xrnames') 
}

if ("`index'" == "sst")  {	
mbasicsst ``dd'' ,  hsize(`_ths`dd'')   pline(`pline`dd'')  xrnames(`xrnames') 
}

matrix _ms_`dd'_pop = e(mmss)'
matrix _ms_`dd'_pop = _ms_`dd'_pop[.,1..2]


qui svydes
local fr_`dd'=`r(N_units)'-`r(N_strata)'

}

if ("`hgroup'"=="") {
tokenize `namelist' 
local  nvars = wordcount("`namelist'")

forvalues v=1/`nvars' {
if `dd' == 1 local rnames `rnames'   ``v''
}

if ("`index'" == "fgt" | "`index'" == "ede" )   {	
	
	
	
mbasicfgt ``dd'' ,  hsize(`_ths`dd'')    pline(`pline`dd'') xrnames(`xrnames')  type(`type')  opl(`opl`dd'') prop(`prop`dd'')  perc(`perc`dd'')
}
if ("`index'" == "watts")  {	
mbasicwatts ``dd'' ,  hsize(`_ths`dd'')     pline(`pline`dd'') xrnames(`xrnames') 
}

if ("`index'" == "sst")  {	
mbasicsst ``dd'' ,  hsize(`_ths`dd'')   pline(`pline`dd'')  xrnames(`xrnames') 
}


 
matrix _ms_`dd'_pop = e(mmss)'
matrix _ms_`dd'_pop = _ms_`dd'_pop[1..1,1..2]


}



qui svydes
local fr_`dd'=`r(N_units)'-`r(N_strata)'

restore


}


local fr=`fr_1' + `fr_2'

local tmatna_1 = ""
if ("`hgroup'"~="") {
forvalues i=1/`nhgroups' {

local rr=rowsof(_ms_1_`i')
matrix dif = J(`rr',2,0)
matrix  _mss_`i'  = _ms_1_`i' , _ms_2_`i'
forvalues l=1/`rr' {
	matrix dif[`l',1] = el(_ms_2_`i',`l',1) - el(_ms_1_`i',`l',1) 
	matrix dif[`l',2] = (el(_ms_2_`i',`l',2)^2 + el(_ms_1_`i',`l',2)^2)^0.5 
}
matrix  _mss_`i'=_mss_`i', dif
local tmatna  `tmatna'  _mss_`i'
}

}

/*
local rr=rowsof(_ms_1_pop)
matrix dif = J(`rr',2,0)
matrix  _mss_aa  = _ms_1_pop , _ms_2_pop
matrix list  _mss_aa 
local rr=rowsof(_mss_aa)
forvalues l=1/`rr' {
	matrix dif[`l',1] =  el(_ms_1_pop,`l',1)  -  el(_ms_2_pop,`l',1) 
	matrix dif[`l',2] = (el(_ms_1_pop,`l',2)^2 + el(_ms_2_pop,`l',2)^2)^0.5 
}
matrix  _mss_pop=_mss_aa, dif
local tmatna  `tmatna'  _mss_pop

matrix list _mss_pop


*/




    matrix difp = J(1,2,0)
	matrix difp[1,1] = el(_ms_2_pop,1,1) - el(_ms_1_pop,1,1) 
	matrix difp[1,2] = (el(_ms_2_pop,1,2)^2 + el(_ms_1_pop,1,2)^2)^0.5 
matrix _ms_pop = _ms_1_pop, _ms_2_pop,difp
 local tmatna  `tmatna'  _ms_pop





}




 //ddep==0 end




	
      if("`index'" == "fgt") {
	  	local indexa = "Difference between FGT"
	  }
	  
	        if("`index'" == "ede") {
	  	local indexa = "Difference between EDE-FGT"
	  }
      if ("`index'" == "watts") {
	  		local indexa = "Difference between Watts"
	  }

	        if ("`index'" == "sst") {
	  		local indexa = "Difference between SST"
	  }


	  




	  
	  di _n as text in white "{col 5}Index           {col 25}: `indexa' indices"
       if ("`hsize1'"!="" &)   di as text     "{col 5}Household size 1 {col 25}: `hsize1'"  
       if ("`hsize2'"!="")   di as text       "{col 5}Household size 2 {col 25}: `hsize2'"
       if ("`hweight1'"!="") di as text       "{col 5}Sampling weight 1 {col 25}: `hweight1'"
	   if ("`hweight2'"!="") di as text       "{col 5}Sampling weight 2 {col 25}: `hweight2'"
       if ("`hgroup'"!="")  di as text        "{col 5}Group variable(s) {col 25}: `hgroup'"




 
                       local gro = 0	
if ("`hgroup'" ~= "" ) { 
	local gro   = 1
	local nvars = 1
}
                               local pop = 1


_dis_dasp_table_2d  `tmatna' ,  df(`fr')   level(`level') conf(`conf') hgroup(`hgroup') dec1(`dec1') dec2(`dec2')  gro(`gro') pop(`pop') file1(`file1') file2(`file2') test(`test') index(`index')


timer off  1
/* timer list 1 */
timer on   2



if ("`xfil'" ~= "" ) {
                       local gro = 0	
if ("`hgroup'" ~= "" ) local gro = 1
	if "`xtit'"==""   local xtit Table ##: " `indexa' indices"
if `gro' == 1   local xtit `xtit' by population groups 
if ("`hgroup'" ~= "" ) local gro = 1
#delimit ;
 mk_xls_m1_2d  `tmatna' ,  df1(`fr')    level(`level') conf(`conf') hgroup(`hgroup') dec1(`dec1') dec2(`dec2')  pop(`pop')  
 xtit(`xtit') file1(`file1') file2(`file2') 
 dste(0)  xfil(`xfil') xshe(`xshe') modrep(`modrep')  fcname(Population groups) gro(`gro')
 note1(`note1')  note2(`note2')  note3(`note3')  note4(`note4')  note5(`note5')  note6(`note7') ;
 #delimit cr
} 


#delimit cr

end


