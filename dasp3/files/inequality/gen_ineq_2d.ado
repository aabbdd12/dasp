/********************************************************************************/
/*  Stata Version : Required  15.0 and higher                                   */
/*  Authors       : Abdelkrim Araar  // aabd@ecn.ulaval.ca                      */
/********************************************************************************/


#delimit ;

capture program drop gen_ineq_2d;
program define gen_ineq_2d, eclass;
version 15;
syntax namelist(min=2)[, 
FILE1(string) FILE2(string) 
RANK1(string)  RANK2(string)
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
LEVEL(int 95)  CONF(string) TYPE(string) 
EPSIlon(real 0.5)  THETA(real 1) p1(real 0.1) p2(real 0.2) p3(real 0.8) p4(real 0.9)
index(string) BOOT(string) NREP(string) TEST(string)
*
];

if ("`index'" == "" ) local index = "gini" ;

if ("`index'" == "agini" | "`index'" == "aconc")  local type = "abs" ;
if  "`index'" == "gini" | "`index'" == "agini" | "`index'" == "conc" | "`index'" == "aconc"  local index = "gini" ;

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
	local hweighta1= "`hweight'"; 
	local hweighta2= "`hweight'"; 
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


tempvar cd1;
if ( "`cond1'"!="") {;
gen `cd1'=`cond1';
qui replace `_ths1'=`_ths1'*`cd1';
qui sum `cd1';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_1, the number of observations is 0.";
exit;
};
};

tempvar cd2 ;
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace `_ths2'=`_ths2'*`cd2';
qui sum `cd2i';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_2, the number of observations is 0.";
exit;
};
};

/*
if ( "`change'"=="") local change == abs;
*/
cap svy: total;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
#delimit cr

if ("`hgroup'"~="") {
forvalues i=1/`nhgroups' {
if ("`index'" == "gini")  {	
mbasicgini2 `namelist' ,  hsize1(`_ths1') hsize2(`_ths2')  hgroup(`hgroup_`i'')  xrnames(`xrnames') rank1(`rank1') rank2(`rank2')  type(`type')
}
if ("`index'" == "atk")  {	
mbasicatk2 `namelist' ,  hsize1(`_ths1') hsize2(`_ths2')  hgroup(`hgroup_`i'')  xrnames(`xrnames') epsilon(`epsilon')	
}

if ("`index'" == "entropy")  {	
mbasicent2 `namelist' ,  hsize1(`_ths1') hsize2(`_ths2')  hgroup(`hgroup_`i'')  xrnames(`xrnames') theta(`theta')	
}

if ("`index'" == "covar")  {	
mbasiccov2 `namelist' ,  hsize1(`_ths1') hsize2(`_ths2')  hgroup(`hgroup_`i'')  xrnames(`xrnames') 
}

if ("`index'" == "qr" | "`index'" == "sr" )  {
mbasicine2 `namelist' ,  hsize1(`_ths1') hsize2(`_ths2') p1(`p1') p2(`p2') p3(`p3') p4(`p4') hgroup(`hgroup_`i'')  index(`index')	 xrnames(`xrnames') 	
}	


matrix _ms_`i' = e(mmss)'
local tmatna `tmatna' _ms_`i'
}
}

if ("`index'" == "gini")  {	
mbasicgini2 `namelist' ,  hsize1(`_ths1') hsize2(`_ths2')   xrnames(`xrnames') rank1(`rank1') rank2(`rank2')  type(`type')
}

if ("`index'" == "atk")  {	
mbasicatk2 `namelist' ,  hsize1(`_ths1') hsize2(`_ths2')   xrnames(`xrnames') epsilon(`epsilon')	
}

if ("`index'" == "entropy")  {	
mbasicent2 `namelist' ,  hsize1(`_ths1') hsize2(`_ths2')   xrnames(`xrnames') theta(`theta')	
}
if ("`index'" == "covar")  {
mbasiccov2 `namelist' ,  hsize1(`_ths1') hsize2(`_ths2')  xrnames(`xrnames') 	
}

if ("`index'" == "qr" | "`index'" == "sr" )  {
mbasicine2 `namelist' ,  hsize1(`_ths1') hsize2(`_ths2')  p1(`p1') p2(`p2') p3(`p3') p4(`p4')  xrnames(`xrnames') 	index(`index')	
}	

matrix _ms_pop = e(mmss)'
local tmatna  `tmatna'  _ms_pop


qui svydes
local fr=`r(N_units)'-`r(N_strata)'



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
local hweight`dd' =`"`e(wvar)'"';

local hweighta`dd' = "`hweight`dd''" ;


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
	if `fal' == 1 dis as error "Error : Modality " `g2' " is in Dist2 but not in Dist 1: : group variable (``i'')";
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
gen `cd`dd''=`cond';
qui replace `_ths`dd''=`_ths`dd''*`cd`dd'';
qui sum `cd1';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_1, the number of observations is 0.";
exit;
};
};

cap svy: total;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

#delimit cr

if ("`hgroup'"~="")      {
forvalues i=1/`nhgroups' {
if ("`index'" == "gini")  {		
mbasicgini ``dd'' ,  hsize(`_ths`dd'')  hgroup(`hgroup_`i'')  xrnames(`xrnames') rank(`rank`dd'') type(`type')
}
if ("`index'" == "atk")  {	
mbasicatk ``dd'' ,  hsize(`_ths`dd'')  hgroup(`hgroup_`i'')  xrnames(`xrnames') epsilon(`epsilon')
}

if ("`index'" == "entropy")  {	
mbasicent ``dd'' ,  hsize(`_ths`dd'')  hgroup(`hgroup_`i'')  xrnames(`xrnames') theta(`theta')
}

if ("`index'" == "covar")  {	
mbasiccov  ``dd'',   hsize(`_ths`dd'')  hgroup(`hgroup_`i'')  xrnames(`xrnames') 
}

if ("`index'" == "qr" | "`index'" == "sr" )  {
mbasicine ``dd'',   hsize(`_ths`dd'')  hgroup(`hgroup_`i'')  p1(`p1') p2(`p2') p3(`p3') p4(`p4')  index(`index') xrnames(`xrnames') 	
} 
matrix _ms_`dd'_`i' = e(mmss)'
}


if ("`index'" == "gini")  {	
mbasicgini ``dd'' ,  hsize(`_ths`dd'')    xrnames(`xrnames') rank(`rank`dd'')  type(`type')
}
if ("`index'" == "atk")  {	
mbasicatk ``dd'' ,  hsize(`_ths`dd'')    xrnames(`xrnames') epsilon(`epsilon')
}

if ("`index'" == "entropy")  {	
mbasicent ``dd'' ,  hsize(`_ths`dd'')  xrnames(`xrnames') theta(`theta')
}

if ("`index'" == "covar")  {	
mbasiccov  ``dd'',   hsize(`_ths`dd'')  xrnames(`xrnames') 
}

if ("`index'" == "qr" | "`index'" == "sr" )  {
mbasicine ``dd'',   hsize(`_ths`dd'') p1(`p1') p2(`p2') p3(`p3') p4(`p4')   index(`index') xrnames(`xrnames') 	
}
 
#delimit cr
matrix _ms_`dd'_pop = e(mmss)'

qui svydes
local fr_`dd'=`r(N_units)'-`r(N_strata)'

}

if ("`hgroup'"=="") {
tokenize `namelist' 
local  nvars = wordcount("`namelist'")

forvalues v=1/`nvars' {
if `dd' == 1 local rnames `rnames'   ``v''
}

if ("`index'" == "gini")  {	
mbasicgini ``dd''  ,  hsize(`_ths`dd'')    xrnames(`xrnames') rank(`rank`dd'')  type(`type')
}
if ("`index'" == "atk")  {	
mbasicatk ``dd''  ,  hsize(`_ths`dd'')    xrnames(`xrnames') epsilon(`epsilon')
}

if ("`index'" == "entropy")  {	
mbasicent ``dd''  ,  hsize(`_ths`dd'')  xrnames(`xrnames') theta(`theta')
}

if ("`index'" == "covar")  {	
mbasiccov  ``dd'' ,   hsize(`_ths`dd'')  xrnames(`xrnames') 
}

if ("`index'" == "qr" | "`index'" == "sr" )  {
mbasicine ``dd'' ,   hsize(`_ths`dd'') p1(`p1') p2(`p2') p3(`p3') p4(`p4')   index(`index') xrnames(`xrnames') 	
}
 


}

matrix _ms_`dd'_pop = e(mmss)'



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



	  
    if("`index'" == "gini") {
	if ("`rank1'"=="" | "`rank1'"=="`1'" ) &  ("`rank2'"~="" | ( "`rank2'"~="`2'" & "`rank2'"~="" ))      &     ("`type'"=="")  local indexa = "Difference between Gini and concentration"
	if ("`rank1'"=="" | "`rank1'"=="`1'" ) & ("`rank2'"=="" | "`rank2'"=="`2'" )   & ("`type'"=="")     local indexa = "Difference between Gini"
	if ("`rank1'"~="" | ("`rank1'"~="`1'"  & "`rank1'"~="" ))  &  ("`rank2'"=="" | "`rank2'"=="`2'" )     &   ("`type'"=="")                      local indexa = "Difference between concentration and Gini"
	if ("`rank1'"~="" & "`rank2'"~="" ) & ("`rank1'"~="`1'" & "`rank2'"~="`2'" ) & ("`type'"=="")     local indexa = "Difference between concentration"
	
		
	if ("`rank1'"=="" | "`rank1'"=="`1'" ) &  ("`rank2'"~="" | "`rank2'"~="`2'" )     & ("`type'"=="abs")                     local indexa = "Difference between absolute Gini and absolute concentration"	
	if ("`rank1'"=="" | "`rank1'"=="`1'" ) & ("`rank2'"=="" | "`rank2'"=="`2'" ) & ("`type'"=="abs")     local indexa = "Difference between absolute Gini"

	if ("`rank1'"~="" | "`rank1'"~="`1'" ) &  ("`rank2'"=="" | "`rank2'"=="`2'" )     &  ("`type'"=="abs")                     local indexa = "Difference between absolute concentration and absolute Gini"
	if ("`rank1'"~="" & "`rank2'"~="" ) & ("`rank1'"~="`1'" & "`rank2'"~="`2'" ) & ("`type'"=="abs")      local indexa = "Difference between absolute concentration"
	}
	
      if("`index'" == "atk") {
	  	local indexa = "Difference between Atkinson"
	  }
	  
	        if("`index'" == "entropy") {
	  	local indexa = "Difference between generalised entropy"
	  }
      if ("`index'" == "covar") {
	  		local indexa = "Difference between coefficient of convariance"
	  }

	        if ("`index'" == "qr") {
	  		local indexa = "Difference between quantile ratio"
	  }

	  	        if ("`index'" == "sr") {
	  		local indexa = "Difference between share ratio"
	  }
	  




	  
	  di _n as text in white "{col 5}Index           {col 25}: `indexa' indices"
       if ("`rank1'"!="" & "`index'" == "gini")     di as text     "{col 5}Ranking variable 1  {col 25}: `rank1'"
       if ("`hsize1'"!="" &)   di as text     "{col 5}Household size 1 {col 25}: `hsize1'"
	   
	    if ("`rank2'"!="" & "`index'" == "gini")     di as text     "{col 5}Ranking variable 2 {col 25}: `rank2'"
       if ("`hsize2'"!="")   di as text       "{col 5}Household size 2 {col 25}: `hsize2'"
	   

	   
       if ("`hweighta1'"!="") di as text     "{col 5}Sampling weight 1 {col 25}: `hweighta1'"
	   if ("`hweighta2'"!="") di as text     "{col 5}Sampling weight 2 {col 25}: `hweighta2'"
	   
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable(s) {col 25}: `hgroup'"
       if ("`index'" == "atk") di as text     "{col 5}Epsilon {col 25}:`epsilon'"
	   if ("`index'" == "entropy") di as text     "{col 5}Theta {col 25}: `theta'"
	   	 if "`index'" == "qr"  di as text     "{col 5}Quantile ratio {col 25}: Q(p1=`p1')/Q(p2=`p2') "
        if "`index'" == "sr"  di as text     "{col 5}Share ratio {col 25}: (Q(p2=`p1') -  Q(p1=`p2'))/(Q(p4=`p4') -  Q(p3=`p3')) "



 
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


