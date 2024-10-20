/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.0)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universit Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/


#delim ;

cap program drop diginis2;  
program define diginis2, rclass ;    
version 9.2;         
syntax varlist (min=1 max=1) [, HSize(varname) HWeight(varname) RANK(varname) HGroup(varname)  GNumber(int -1) TYPE(string) ];
preserve;
tokenize `varlist';
tempvar  hs sw fw ;
qui gen `sw'=1;
qui gen `hs'=1;
                     qui drop if `1'>=. ;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;

if ("`hsize'"!="")     qui replace `hs' = `hsize';

tempvar _in;
if ("`hgroup'" != "")  qui gen    `_in' = (`hgroup' == `gnumber');

if ("`hgroup'" != "")  qui replace `hs' = `hs' * `_in';
if ("`hweight'"!="")   qui replace `sw'=`hweight';
qui gen `fw'=`hs'*`sw';


sort `rank' , stable;
tempvar smw smwy l1smwy ca;
qui gen `smw'  =sum(`fw');
qui gen `smwy' =sum(`rank'*`fw');
qui gen `l1smwy'=0;
local mu=`smwy'[_N]/`smw'[_N];
local suma=`smw'[_N];
qui count;
forvalues i=2/`r(N)' { ;
qui replace `l1smwy'=`smwy'[`i'-1]  in `i';
};

qui gen `ca'=`mu'+`rank'*((1.0/`smw'[_N])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[_N])*(2.0*`l1smwy'+`fw'*`rank'); 
qui sum `ca' [aw=`fw'], meanonly; 
local gini=`r(mean)'/(2.0*`mu');
if ("`type'" == "abs") local gini=`r(mean)'/(2.0);
local xi = `r(mean)';
tempvar vec_a vec_b  vec_ob theta v1 v2 sv1 sv2;
qui count;

         
            local fx=0;
            gen `v1'=`fw'*`rank';
            gen `v2'=`fw';
            gen `sv1'=sum(`v1');
            gen `sv2'=sum(`v2') ;
            qui replace `v1'=`sv1'[`r(N)']   in 1;
		qui replace `v2'=`sv2'[`r(N)']   in 1;

            forvalues i=2/`r(N)'  {;
            qui replace `v1'=`sv1'[`r(N)']-`sv1'[`i'-1]   in `i';
		qui replace `v2'=`sv2'[`r(N)']-`sv2'[`i'-1]   in `i';
            } ;
           
            gen `theta'=`v1'-`v2'*`rank';

           forvalues i=1/`r(N)' {;
                qui replace `theta'=`theta'[`i']*(2.0/`suma')  in `i';
                local fx=`fx'+`fw'[`i']*`rank'[`i'];
            };            
            local fx=`fx'/`suma';
            gen `vec_a' = `hs'*((1.0)*`ca'+(`rank'-`fx')+`theta'-(1.0)*(`xi'));
            if ("`type'" == "") gen `vec_b' =  2*`hs'*`rank';
            if ("`type'" == "abs") gen `vec_b' =  2*`hs';
            gen `vec_ob' =  2*`hs'*`rank';


//===================================
tempvar smw smwy l1smwy ca;
gen `smw'  =sum(`fw');
gen `smwy' =sum(`1'*`fw');
gen `l1smwy'=0;
local muk=`smwy'[_N]/`smw'[_N];
local suma=`smw'[_N];
qui count;
forvalues i=2/`r(N)' { ;
qui replace `l1smwy'=`smwy'[`i'-1]  in `i';
};

gen `ca'=`muk'+`1'*((1.0/`smw'[_N])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[_N])*(2.0*`l1smwy'+`fw'*`1'); 
qui sum `ca' [aw=`fw'], meanonly; 
local conc=`r(mean)'/(2.0*`muk');
local xi = `r(mean)';
tempvar vec_c vec_d vec_od   theta v1 v2 sv1 sv2;
qui count;

         
            local fx=0;
            gen `v1'=`fw'*`1';
            gen `v2'=`fw';
            gen `sv1'=sum(`v1');
            gen `sv2'=sum(`v2') ;
            qui replace `v1'=`sv1'[`r(N)']   in 1;
		qui replace `v2'=`sv2'[`r(N)']   in 1;

            forvalues i=2/`r(N)'  {;
            qui replace `v1'=`sv1'[`r(N)']-`sv1'[`i'-1]   in `i';
		qui replace `v2'=`sv2'[`r(N)']-`sv2'[`i'-1]   in `i';
            } ;
           
            gen `theta'=`v1'-`v2'*`1';

           forvalues i=1/`r(N)' {;
                qui replace `theta'=`theta'[`i']*(2.0/`suma')  in `i';
                local fx=`fx'+`fw'[`i']*`1'[`i'];
            };            
            local fx=`fx'/`suma';
            gen `vec_c' = `hs'*(`ca'+(`1'-`fx')+`theta'-(1.0)*(`xi') );
            if ("`type'" == "")    gen `vec_d' =  2*(`hs'*`1');
            if ("`type'" == "abs") gen `vec_d' =  2*(`hs');
                                   gen `vec_od' =  2*(`hs'*`1');

        
//===================================



qui svy: ratio `vec_od'/`vec_ob'; 

cap drop matrix _aa;
matrix _aa=e(b);
local incs = el(_aa,1,1);
return scalar incs    = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std = el(_vv,1,1)^0.5;
return scalar incs_s  = `std';


qui svy: ratio `vec_c'/`vec_d'; 
cap drop matrix _aa;
matrix _aa=e(b);
local incs = el(_aa,1,1);
return scalar conc    = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std = el(_vv,1,1)^0.5;
return scalar conc_s  = `std';

qui svy: ratio `vec_c'/`vec_b'; 
cap drop matrix _aa;
matrix _aa=e(b);
local incs = el(_aa,1,1);
return scalar absc    = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std = el(_vv,1,1)^0.5;
return scalar absc_s  = `std';

qui svy: ratio `vec_c'/`vec_a'; 
cap drop matrix _aa;
matrix _aa=e(b);
local incs = el(_aa,1,1);
return scalar relc    = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std = el(_vv,1,1)^0.5;
return scalar relc_s  = `std';

qui svy: ratio `vec_a'/`vec_b'; 
return scalar gini    = `gini';
cap drop matrix _vv;
matrix _vv=e(V);
return scalar gini_s = el(_vv,1,1)^0.5;


//==================



sort `1' , stable;
tempvar smw smwy l1smwy ca;
qui gen `smw'  =sum(`fw');
qui gen `smwy' =sum(`1'*`fw');
qui gen `l1smwy'=0;
local mu=`smwy'[_N]/`smw'[_N];
local suma=`smw'[_N];
qui count;
forvalues i=2/`r(N)' { ;
qui replace `l1smwy'=`smwy'[`i'-1]  in `i';
};

qui gen `ca'=`mu'+`1'*((1.0/`smw'[_N])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[_N])*(2.0*`l1smwy'+`fw'*`1'); 
qui sum `ca' [aw=`fw'], meanonly; 
local gini=`r(mean)'/(2.0*`mu');
if ("`type'"=="abs")  local gini=`r(mean)'/(2.0);
local xi = `r(mean)';
tempvar vec_aa vec_bb theta v1 v2 sv1 sv2;
qui count;

         
            local fx=0;
            gen `v1'=`fw'*`1';
            gen `v2'=`fw';
            gen `sv1'=sum(`v1');
            gen `sv2'=sum(`v2') ;
            qui replace `v1'=`sv1'[`r(N)']   in 1;
		qui replace `v2'=`sv2'[`r(N)']   in 1;

            forvalues i=2/`r(N)'  {;
            qui replace `v1'=`sv1'[`r(N)']-`sv1'[`i'-1]   in `i';
		qui replace `v2'=`sv2'[`r(N)']-`sv2'[`i'-1]   in `i';
            } ;
           
            gen `theta'=`v1'-`v2'*`1';

           forvalues i=1/`r(N)' {;
                qui replace `theta'=`theta'[`i']*(2.0/`suma')  in `i';
                local fx=`fx'+`fw'[`i']*`1'[`i'];
            };            
            local fx=`fx'/`suma';
            gen `vec_aa' = `hs'*((1.0)*`ca'+(`1'-`fx')+`theta'-(1.0)*(`xi'));
            if ("`type'" == "")    gen `vec_bb' =  2*`hs'*`1';
            if ("`type'" == "abs") gen `vec_bb' =  2*`hs';



//==================

qui svy: ratio `vec_aa'/`vec_bb'; 
cap drop matrix _aa;
matrix _aa=e(b);
local gik = el(_aa,1,1);
return scalar gik    = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std = el(_vv,1,1)^0.5;
return scalar gik_s  = `std';

qui svy: ratio `vec_c'/`vec_aa'; 
cap drop matrix _aa;
matrix _aa=e(b);
local gic = el(_aa,1,1);
return scalar gic    = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local std = el(_vv,1,1)^0.5;
return scalar gic_s  = `std';

end;     







capture program drop diginis;
program define diginis, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname)  HGroup(varname)  APPR(string) TYPE(string) CONF(string)
LEVEL(real 95) DEC(int 6) DSTD(int 1) 
XFIL(string) XSHE(string) XLAN(string) XTIT(string)
];


if ("`conf'"=="")          local conf="ts";
local ll=0;
if ("`type'"~="abs") local type="";

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
if ("`appr'"=="") local appr="rao";

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

/* ERRORS */

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
restore;
preserve;
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

tempvar Variable Variable2 INCS  CONC  ABSC  RELC GIC GIK;
qui gen `Variable'="";
qui gen `Variable2'="";
qui gen `INCS'=0;
qui gen `CONC'=0;
qui gen `ABSC'=0;
qui gen `RELC'=0;

qui gen `GIC'=0;
qui gen `GIK'=0;

tempvar MINS  VAEF  COEF ;
qui gen `MINS'=0;
qui gen `VAEF'=0;
qui gen `COEF'=0;

qui count;
local minobs=$indica+2;
if (`r(N)'<`minobs') qui set obs `minobs'; 

tempvar totinc totince;
qui gen `totinc'=0;
qui gen `totince'=0;
forvalues k = 1/$indica {;
qui replace `totinc' = `totinc' + ``k'';
tempvar mina s`k';
egen `mina'= min(``k'');
qui gen `s`k''= ``k''-`mina';
qui replace `totince' = `totince' + `s`k'';
qui replace `MINS'         = `mina'[1]   in `k';
};

qui sum `MINS';
local k1=$indica+1;
local smin  = `r(sum)';

tempvar _ths;

qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';

tempvar ww;
qui gen `ww' = `_ths';
if ("`hweight'"~="") qui replace `ww' = `_ths'*`hweight';
qui sum `totinc' [aw=`ww'], meanonly;
local mu = `r(mean)';

local ll=length("`1': `grlab`1''");
local component = "Variable";

qui count;
local mobs = 2*$indica+2;
if (`r(N)'< `mobs' ) qui set obs `mobs';




if ("`appr'"=="rao" | "`appr'"=="lay") {;

forvalues k = 1/$indica {;
local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;




qui replace `Variable' = "`k': ``k''" in `k1';
qui diginis2 ``k'' , hweight(`hweight') rank(`totinc') hsize(`_ths') type(`type') ;
qui replace `INCS'         = `r(incs)'    in `k1';
qui replace `INCS'         = `r(incs_s)'  in `k2';
qui replace `CONC'         = `r(conc)'    in `k1';
qui replace `CONC'         = `r(conc_s)'  in `k2';

qui replace `ABSC'         = `r(absc)'    in `k1';
qui replace `ABSC'         = `r(absc_s)'  in `k2';
qui replace `RELC'         = `r(relc)'    in `k1';
qui replace `RELC'         = `r(relc_s)'  in `k2';

qui replace `GIC'         = `r(gic)'    in `k1';
qui replace `GIC'         = `r(gic_s)'  in `k2';
qui replace `GIK'         = `r(gik)'    in `k1';
qui replace `GIK'         = `r(gik_s)'  in `k2';

global gini = `r(gini)';
global ginis = `r(gini_s)';

};

local ka=`k1'+2;
local kb=`k1'+3;
qui replace `Variable'    = "Total" in `ka';
qui replace `INCS'         = 1      in `ka';
qui replace `INCS'         = 0      in `kb';

qui replace `GIC'         = 1    in `ka';
qui replace `GIC'         = 0   in `kb';
qui replace `GIK'         = $gini    in `ka';
qui replace `GIK'         = $ginis    in `kb';
qui replace `CONC'        = .    in `ka';
qui replace `CONC'        = .    in `kb';

qui replace `ABSC'         = $gini  in `ka';
qui replace `ABSC'         = $ginis in `kb';
qui replace `RELC'         = 1.0    in `ka';
qui replace `RELC'         = 0.0    in `kb';
};

if ("`appr'"=="ara") {;

qui diginis2 `s1' , hweight(`hweight') rank(`totinc') hsize(`_ths') type(`type');
global gini = `r(gini)';
forvalues k = 1/$indica {;
qui replace `Variable2' = "`k': ``k''" in `k';
diginis2 `s`k'' , hweight(`hweight') rank(`totince') hsize(`_ths') type(`type') ;

qui replace `VAEF'         = `r(absc)'      in `k';
qui replace `COEF'         = -(`MINS'[`k']/`mu')*`r(gini)'    in `k';
qui replace `ABSC'         = `VAEF'[`k']+`COEF'[`k'] in `k';
qui replace `RELC'         = `ABSC'[`k']/$gini    in `k';
global ginie = `r(gini)';
};

local k1=$indica+1;

qui replace `Variable2' = "Total" in `k1';
qui replace `MINS'         = `smin'   in `k1';
qui replace `VAEF'         = $ginie      in `k1';
qui replace `COEF'         = -(`smin'/`mu')*`r(gini)'   in `k1';
qui replace `ABSC'         = $gini in `k1';
qui replace `RELC'         = 1.0   in `k1';

};

local ll=`ll'+10;





if ("`appr'" == "lay") {;
	tempname table;
	.`table'  = ._tab.new, col(6);
	.`table'.width |`ll'|16 16 16 16 16 |;
	.`table'.strcolor . . . yellow . .  ;
	.`table'.numcolor yellow yellow yellow . yellow yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f  %16.`dec'f  ;
	di _n as text "{col 4} Decomposition of the Gini Index by Incomes Sources: Lerman & Yitzhaki (1985) Approach.";
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
	.`table'.sep, top;
	.`table'.titles "Sources  "  "Income   "   "Gini         "          "Gini   "   "  Absolute  " "  Relative  " ;
	.`table'.titles "         "  "Share    "   "Correlation  "          "Index  "   "Contribution" "Contribution" ;
      .`table'.titles "         "  "(S_k)    "   "(R_k)        "          "(G_k)  "   "(S_k*R_k*G_k) " "(S_k*R_k*G_k/G)" ;
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor white yellow yellow  yellow yellow  yellow ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green green  green  green  green   ;
		  if (`dstd'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i'] `INCS'[`i'] `GIC'[`i'] `GIK'[`i'] `ABSC'[`i'] `RELC'[`i'];	        
              };
                     
  .`table'.sep, mid;
.`table'.numcolor white yellow yellow  yellow yellow yellow  ;
.`table'.row  "Total"  1   "---" "---" $gini   1.0;
if (`dstd'==1){;
.`table'.numcolor white green   green green green  green  ;
.`table'.row " " 0   "---"    "---"   $ginis   0.0;
};
	.`table'.sep,bot;
};




if ("`appr'" == "rao") {;
	tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width |`ll'|16 16 16 16 |;
	.`table'.strcolor . . . yellow .  ;
	.`table'.numcolor yellow yellow yellow . yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f ;
	di _n as text "{col 4} Decomposition of the Gini Index by Incomes Sources: Rao's (1969) Approach.";
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
	.`table'.sep, top;
	.`table'.titles "Sources  "  "Income   "   "Concentration"  "  Absolute  " "  Relative  " ;
	.`table'.titles "         "  " Share   "   " Index       "  "Contribution" "Contribution" ;
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor white yellow yellow  yellow  yellow ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green green  green  green  ;
		  if (`dstd'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i'] `INCS'[`i']  `CONC'[`i'] `ABSC'[`i'] `RELC'[`i'];	        
              };
                     
  .`table'.sep, mid;
.`table'.numcolor white yellow yellow  yellow yellow  ;
.`table'.row  "Total" 1   "---" $gini   1.0;
if (`dstd'==1){;
.`table'.numcolor white green   green green green  ;
.`table'.row " " 0   "---" $ginis   0.0;
};
	.`table'.sep,bot;
};


if ("`appr'" == "ara") {; 

tempname table;
	.`table'  = ._tab.new, col(6);
	.`table'.width |`ll'|16 16 16 16 16|;
	.`table'.strcolor . . . yellow   yellow yellow ;
	.`table'.numcolor yellow yellow yellow .  . .;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f %16.`dec'f;
	di _n as text "{col 4} Decomposition of the Gini Index by Incomes Sources: Araar's (2006) Approach.";
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
	.`table'.sep, top;
	.`table'.titles "Sources  "  " Min. Income   "   "  Variation  "  "  Constant  " "  Absolute  " "  Relative  " ;
	.`table'.titles "         "  " Source       "   "Effect   "  "Effect   " "Contribution" "Contribution" ;
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/$indica{;
             .`table'.numcolor white yellow yellow  yellow  yellow yellow;
		 .`table'.row `Variable2'[`i'] `MINS'[`i']  `VAEF'[`i'] `COEF'[`i'] `ABSC'[`i'] `RELC'[`i'];	        
              };
                     
  .`table'.sep, mid;
.`table'.numcolor white yellow yellow  yellow   yellow yellow ;
.`table'.row  "Total" `MINS'[$indica+1]   `VAEF'[$indica+1] `COEF'[$indica+1] `ABSC'[$indica+1] `RELC'[$indica+1] ;


.`table'.sep,bot;

};


local rnam;

forvalues k=1/$indica {;
                local tnv:var label ``k'';
if ("`tnv'"=="")  local tnv ="``k''";
                local rnam `"`rnam' "`tnv'""';
if (`dstd'~=0 ) local rnam `"`rnam' " ""';
};
local rnam `"`rnam' "Total""';
local rnam `"`rnam' " ""';
global rnam `"`rnam'"';




if ("`appr'"~="ara") {;
local lng = ($indica*2+2);
keep in 1/`lng';
if (`dstd'==0 ) {;
local bf=`lng'/2+1;
forvalues j=2(1)`bf'{;
qui drop in `j';
};
};


};

if ("`appr'"=="ara") {;
local lng = $indica+1;
qui keep in 1/`lng';
local dstd=0;
};



tempname zz;

if ("`appr'" == "lay") mkmat	`INCS' `GIC' `GIK' `ABSC' `RELC',	matrix(`zz');

if ("`appr'" == "rao") mkmat	`INCS'   `CONC' `ABSC' `RELC',	matrix(`zz');

if ("`appr'" == "ara") mkmat	`MINS' `VAEF' `COEF' `ABSC' `RELC',	matrix(`zz');




local cnam;

if ("`appr'" != "ara" & "`xlan'"~="fr")   local cnam `"`cnam' "Income share""';
if ("`appr'" != "ara" & "`xlan'"=="fr")   local cnam `"`cnam' "Proportion du revenu total""';

if ("`appr'" == "ara" & "`xlan'"~="fr")  {;
local cnam `"`cnam' "Min. income source""';
local cnam `"`cnam' "Variation effect""';
local cnam `"`cnam' "Constant effect""';
};
if ("`appr'" == "ara" & "`xlan'"=="fr")   {;
local cnam `"`cnam' "Min. de la composante""';
local cnam `"`cnam' "Effet de variation""';
local cnam `"`cnam' "Effet de constante""';
};


if ("`appr'" == "rao" & "`xlan'"~="fr")  {;
local cnam `"`cnam' "Concentration index""';
};
if ("`appr'" == "rao" & "`xlan'"=="fr")   {;
local cnam `"`cnam' "Indice de concentration""';
};

if ("`appr'" == "lay" & "`xlan'"~="fr")  {;
local cnam `"`cnam' "Gini correlation""';
local cnam `"`cnam' "Gini index""';

};
if ("`appr'" == "lay" & "`xlan'"=="fr")   {;
local cnam `"`cnam' "Corrlation de Gini""';
local cnam `"`cnam' "Indice de Gini""';

};



if ("`xlan'"~="fr")  local cnam `"`cnam' "Absolute contribution""';
if ("`xlan'"=="fr")  local cnam `"`cnam' "Contribution absolue""';
if ("`xlan'"~="fr")  local cnam `"`cnam' "Relative contribution""';
if ("`xlan'"=="fr")  local cnam `"`cnam' "Contribution relative""';
global cnam `"`cnam'"';

                     local xtit = "Table ##: Decomposition of the Gini index by income sources";
if ("`xlan'"=="fr")  local xtit = "Tableau ##: Dcomposition de l'indice de Gini selon les composantes du revenu";
if ("`xtit'"~="")    local xtit = "`xtit'";

if ("`appr'" == "rao") local note2 = "[-] Decomposition with Rao's approach (1969).";
if ("`appr'" == "lay") local note2 = "[-] Decomposition with Lerman and Yitzhaki's approach (1985).";
if ("`appr'" == "ara") local note2 = "[-] Decomposition with Araar's approach (2006).";

if ("`appr'" == "rao" & "`xlan'"=="fr") local note2 = "[-] Dcomposition selon l'approche de Rao (1969).";
if ("`appr'" == "lay" & "`xlan'"=="fr") local note2 = "[-] Dcomposition selon l'approche de Lerman and Yitzhaki (1985).";
if ("`appr'" == "ara" & "`xlan'"=="fr") local note2 = "[-] Dcomposition selon l'approche de Araar (2006).";

if ("`xfil'" ~="") {;
mk_xtab_m1 `1' ,  matn(`zz') dec(`dec') xfil(`xfil') xshe(`xshe') xtit(`xtit') xlan(`xlan') dstd(`dstd') note(`note2');
};




cap ereturn clear;
restore;
end;



