/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : dfgtg                                                       */
/*************************************************************************/

#delim ;

capture program drop dfgtg2;
program define dfgtg2, rclass;
version 9.2;
syntax varlist  [,  HSize(varname) HGroup(varname) GNumber(int -1) AL(real 0) PL(string) TYpe(string) INDex(string) CI(real 95)];

tokenize `varlist';
tempvar _hs;
gen `_hs'=`hsize';
if (`gnumber'!=-1)  qui replace `_hs'=`_hs'*(`hgroup'==`gnumber');
tempvar _num _denum;
qui gen  `_num'=0;
qui gen  `_denum'=0;
if (`al' == 0) qui replace                      `_num' = `_hs'*(`pl'> `1');
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `_num' = `_hs'*(`pl'-`1')^`al'  if (`pl'>`1');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace `_num' = `_hs'*((`pl'-`1')/`pl')^`al'  if (`pl'>`1');


if (`al' == 0) qui replace                      `_denum' = `hsize'*(`pl'> `1');
if (`al' ~= 0  & "`type'"~="nor" )  qui replace `_denum' = `hsize'*(`pl'-`1')^`al'  if (`pl'>`1');
if (`al' ~= 0  & "`type'"=="nor" )  qui replace `_denum' = `hsize'*((`pl'-`1')/`pl')^`al'  if (`pl'>`1');

qui svy: ratio `_num'/`_hs';
cap drop matrix _aa;
matrix _aa=e(b);
local est = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std = el(_vv,1,1)^0.5;
return scalar std  = `std';
return scalar est  = `est';

qui svy: ratio `_hs'/`hsize';
cap drop matrix _aa;
matrix _aa=e(b);
local est2 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std2 = el(_vv,1,1)^0.5;
return scalar std2  = `std2';
return scalar est2  = `est2';
qui svy: ratio `_num'/`hsize';
cap drop matrix _aa;
matrix _aa=e(b);
local est3 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std3 = el(_vv,1,1)^0.5;
return scalar std3  = `std3';
return scalar est3  = `est3';
qui svy: ratio `_num'/`_denum';
cap drop matrix _aa;
matrix _aa=e(b);
local est4 = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std4 = el(_vv,1,1)^0.5;
return scalar std4  = `std4';
return scalar est4  = `est4';
end;

capture program drop dfgtg;
program define dfgtg, rclass;
version 9.2;
syntax varlist(min=1 max=1)[, HSize(varname) HGroup(varname) ALpha(real 0) 
PLine(string) type(string) INDex(string)
XFIL(string) XSHE(string)  XLAN(string) XTIT(string) MODREP(string)
 STE(string) dec(int 3) 
LEVEL(real 95) DSTE(int 1)
];
if ("`type'"=="") local type="nor";
if ("`hgroup'"!="") {;
preserve;
capture {;
local lvgroup:value label `hgroup';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , clear;
qui count;
forvalues i=1/`r(N)' {;
local tem=value[`i'];
local grlab`tem' = label[`i'];
};
};
};
restore;preserve;
qui tabulate `hgroup', matrow(gn);
svmat int gn;
global indica=r(r);
tokenize `varlist';
};

if ("`hgroup'"=="") {;
tokenize `varlist';
_nargs    `varlist';
preserve;
};
local ci=100-`level';
tempvar Variable EST EST1 EST2 EST3 EST4 STE STE1 STE2 STE3 STE4;
qui gen `Variable'="";
qui gen `EST'=0;
qui gen `STE'=0;

qui gen `EST2'=0;
qui gen `STE2'=0;

qui gen `EST3'=0;
qui gen `STE3'=0;

qui gen `EST4'=0;
qui gen `STE4'=0;




tempvar _ths;
qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';
cap svy: total;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local ll=length("`1': `grlab`1''");
forvalues k = 1/$indica {;
local kk = gn1[`k'];

dfgtg2 `1' ,  hsize(`_ths') pl(`pline') hgroup(`hgroup') gnumber(`kk') al(`alpha') ty(`type') index(`index') ci(`ci') ;
local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;
qui replace `EST'      = `r(est)' in `k1';
qui replace `EST'      = `r(std)' in `k2';

qui replace `EST2'      = `r(est2)' in `k1';
qui replace `EST2'      = `r(std2)' in `k2';

qui replace `EST3'      = `r(est3)' in `k1';
qui replace `EST3'      = `r(std3)' in `k2';

qui replace `EST4'      = `r(est4)' in `k1';
qui replace `EST4'      = `r(std4)' in `k2';

return scalar fgt_`kk'= `r(est)';
return scalar prop_`kk'= `r(est2)';
return scalar acont_`kk'= `r(est3)';
return scalar rcont_`kk'= `r(est4)';

local label`f'  : label (`hgroup') `kk';
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";
qui replace `Variable' = "`label`f''" in `k1';

local ll=max(`ll',length("`label`f''"));
};
local ll=`ll'+10;
if ("`type'"=="nor") local nor = "Normalized";
if ("`index'"=="ede") local ind = "EDE-";


dfgtg2 `1' ,  hsize(`_ths') pl(`pline') al(`alpha') ty(`type') index(`index') ci(`ci');

local kk1 = `k2'+1;
local kk2 = `k2'+2;
qui replace `Variable' = "Population" in `kk1';
qui replace `EST'      = `r(est)'  in `kk1';
qui replace `EST'      = `r(std)'  in `kk2';

qui replace `EST2'      = 1 in `kk1';
qui replace `EST2'      = 0 in `kk2';

qui replace `EST3'      = `r(est)' in `kk1';
qui replace `EST3'      = `r(std)' in `kk2';

qui replace `EST4'      = 1 in `kk1';
qui replace `EST4'      = 0 in `kk2';

if ("`type'"=="not")  local norm = "Not normalized ";
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

	tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width |`ll'|16 16 16 16|;
	.`table'.strcolor . . yellow . . ;
	.`table'.numcolor yellow yellow . yellow yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f;
	di _n as text "{col 4} Decomposition of the FGT index by groups";
                            di as text in white "{col 5}Poverty index   :  `norm'`ind'FGT index";
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";
                            di  as text "{col 5}Parameter alpha : "  %5.2f `alpha'       ;
     
	.`table'.sep, top;
	.`table'.titles "Group  " "FGT index"  "Population "  "  Absolute  " "  Relative  " ;
	.`table'.titles "       " "         "  "   share   "  "contribution" "contribution" ;
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor white yellow yellow yellow yellow ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green   green  green green ;
		  if (`dste'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i'] `EST'[`i']  `EST2'[`i'] `EST3'[`i'] `EST4'[`i'];
              	        
                };
  .`table'.sep, mid;
.`table'.numcolor white yellow yellow yellow yellow ;
.`table'.row `Variable'[`kk1'] `EST'[`kk1']  `EST2'[`kk1'] `EST3'[`kk1'] `EST4'[`kk1'];
if (`dste'==1){;
.`table'.numcolor white green   green  green green ;
.`table'.row `Variable'[`kk2'] `EST'[`kk2']  `EST2'[`kk2'] `EST3'[`kk2'] `EST4'[`kk2'];
};


.`table'.sep,bot;


//=============


tempname  Variableo;
qui gen  `Variableo'=`Variable';

local lng = ($indica*2+2);
qui keep in 1/`lng';


local rnam;

forvalues i=1(2)`lng'  {;
local temn=`Variableo'[`i'];
               local rnam `"`rnam' "`temn'""';
if (`dste'~=0) local rnam `"`rnam' " ""';


};







global rnam `"`rnam'"';





if (`dste'==0) {;
local bf=`lng'/2+1;
forvalues j=2(1)`bf'{;
qui drop in `j';
};
};
tempname zz;


qui mkmat	 `EST'  `EST2' `EST3' `EST4',	matrix(`zz');


local index = "FGT_Group (alpha=`alpha')";
if (`alpha'==0)                  local index = "Headcount"; 
if (`alpha'==0 & "`xlan'"=="fr") local index = "Taux de pauvret";
if (`alpha'==1)                  local index = "Average poverty gap";
if (`alpha'==1 & "`xlan'"=="fr") local index = "Carence moyenne";
if (`alpha'==2)                  local index = "Poverty severity";
if (`alpha'==2 & "`xlan'"=="fr") local index = "Svrit de la pauvret";

local cnam;
			   local cnam `"`cnam' "`index'""';
if ("`xlan'"~="fr")  local cnam `"`cnam' "Population share""';
if ("`xlan'"=="fr")  local cnam `"`cnam' "Proportion de la population""';
if ("`xlan'"~="fr")  local cnam `"`cnam' "Absolute contribution""';
if ("`xlan'"=="fr")  local cnam `"`cnam' "Contribution absolue""';
if ("`xlan'"~="fr")  local cnam `"`cnam' "Relative contribution""';
if ("`xlan'"=="fr")  local cnam `"`cnam' "Contribution relative""';
global cnam `"`cnam'"';



                     local xtit = "Table ##: Decomposition of poverty by population groups (`hgroup')";
if ("`xlan'"=="fr")  local xtit = "Tableau ##: Dcomposition de la pauvreté par groupes de population (`hgroup')";
if ("`xtit'"~="")    local xtit = "`xtit'";


if ("`xfil'" ~="") {;

local rnamn ="";
local lng1 = `lng'-1;
local pass = 2 ;
if `dste'~=1 local pass = 1 ;
forvalues i=1(`pass')`lng'  {;
local temn=`Variableo'[`i'];
if (`i'!=`lng1' & `dste'==1)                local rnamn `rnamn'  `temn' @ @  ;
if (`i'!=`lng1' & `dste'!=1)                local rnamn `rnamn'  `temn' @  ;
if (`i'==`lng1' | `i'==`lng')   local rnamn `rnamn'  `temn'       ;

};

global rnamn `"`rnamn'"';
local cnamn `index' @ ; 
if ("`xlan'"~="fr")  local cnamn `cnamn' Population share @;
if ("`xlan'"=="fr")  local cnamn `cnamn' Proportion de la population @;
if ("`xlan'"~="fr")  local cnamn `cnamn' Absolute contribution @ ;
if ("`xlan'"=="fr")  local cnamn `cnamn' Contribution absolue @ ;
if ("`xlan'"~="fr")  local cnamn `cnamn' Relative contribution ;
if ("`xlan'"=="fr")  local cnamn `cnamn' Contribution relative ;
global cnamn `cnamn';


tokenize "`xfil'" ,  parse(".");
local xfil = "`1'";
 mk_xls `1' ,  matn(`zz') dec(`dec')   etitle(`xtit') xlan(`xlan') dste(`dste')  fexcel(`xfil') esheet(`xshe') modrep(`modrep')  fcname(Population groups);
 
};
cap matrix drop _vv _aa gn;

restore;
end;


