
/*************************************************************************/
/* The dsginis Stata module                                              */
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/


#delim ;
cap program drop dsginis2;
program define dsginis2, rclass;
syntax varlist(min=1 max=1) [, FWeight(varname)];
version 8.0;
tokenize `varlist';
qui {;
preserve;
local rho=2;
tempvar fw;
qui gen `fw'=`fweight';
gsort -`1';
cap drop if `1' >=.; 
cap drop if `fw'>=.;
gen vr = sum(`fw')^`rho'; gen p = vr  - vr[_n-1];
replace p = vr[1] in 1; replace p = p / vr[_N];
gen  xi = sum(p*`1');  local xi = xi[_N];
qui sum `1' [aw=`fw']; local mu = `r(mean)';
local gini = 1 - `xi'/`mu';
restore; 
};
return scalar gini = `gini';
return scalar mu   = `mu'  ;
end;




capture program drop dsginis;
program define dsginis, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname)  HGroup(varname) DEC(int 6) APPR(string) SAPPR(string) * 
XFIL(string) XSHE(string) XLAN(string) XTIT(string) MODREP(string)
];


timer clear 1;
timer on 1;
preserve;
if ("`conf'"=="")          local conf="ts";
if ("`sappr'"=="")        local appr = "mean";
if ("`sappr'"~="")        local appr = "`sappr'";
local ll=0;

 tokenize `varlist';
_nargs    `varlist';

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

tempvar hw; qui gen `hw'=1; if ("`hweight'"~="") qui replace `hw'=`hweight';

tempvar fw;
qui gen `fw'=1;
qui replace `fw'=`fw'*`hw';
tempvar hs;
qui gen `hs'=1;
if ("`hsize'"~="")   qui replace `hs'=`hsize';
qui replace `fw'=`fw'*`hs';

shapar $indica;
tempvar tinco   ;
gen    `tinco'=0 ;
forvalues j=1/$indica {;
qui replace `tinco' = `tinco'+``j'';
};


qui dsginis2 `tinco', fweight(`fw');
local     tgini = `r(gini)'; 
local     mu_inc = `r(mu)';


tempvar tinco   ;

cap drop _shav;
qui gen  _shav=0;

tempvar Variable INCS  ABSC  RELC;
qui gen `Variable'="";
qui gen `INCS'=0;
qui gen `ABSC'=0;
qui gen `RELC'=0;


forvalues i=1/$shasize {;
cap drop `inco';
tempvar inco;
gen `inco'=0;
forvalues j=1/$indica {;
qui replace `inco' = `inco' + ``j'' *(_o`j'[`i'] != .);
};

qui sum `inco' [aw=`fw'], meanonly; 
local mup=`r(mean)';
if ("`appr'"=="mean") qui replace `inco'=`inco' + `mu_inc' - `mup';
qui dsginis2 `inco', fweight(`fw');
qui replace _shav = `r(gini)' in `i';
                                               
};


forvalues l=1/$indica {;
cap drop level_`l' ; qui gen level_`l'=0;
forvalues j=1/$indica {;
cap drop `temp';
tempvar temp;  qui gen `temp' = 0;
qui replace `temp'   =  (_o`j'==`j')*(_sg==`l') | (_o`j'!=`j')*(_sg==`l'-1) ;
qui replace `temp'   =  `temp'*_shav*_shapwe`j';
qui sum `temp' in 1/$shasize;
qui replace level_`l' =  `r(sum)' in `j' ; 
};
};


forvalues k=1/$indica {;
local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;
qui replace `Variable' = "`k': ``k''"    in `k1';
tempvar  wcomk;
qui sum ``k'' [aw=`fw']; 
qui replace `INCS'         = `r(mean)'/`mu_inc'  in `k1';
tempvar shav; qui gen `shav'=0;
qui replace `shav'         =  _shav*_shapwe`k';
qui sum `shav';
qui replace `ABSC'         = `r(sum)'               in `k1';
qui replace `RELC'         = `r(sum)'/(`tgini')    in `k1';
};

local ka=`k1'+2;
local kb=`k1'+3;
qui replace `Variable'     = "Total" in `ka';
qui replace `INCS'         = 1      in `ka';
qui replace `INCS'         = 0      in `kb';


qui replace `ABSC'         = `tgini'  in `ka';

qui replace `RELC'         = 1.0    in `ka';
qui replace `RELC'         = 0.0    in `kb';








timer off 1;
qui timer list 1;
local ptime = `r(t1)';
/****TO DISPLAY RESULTS *****/
set more off;
local ll = 20;
        tempname table;
        .`table'  = ._tab.new, col(4);
        .`table'.width |`ll'|16 16 16 |;
        .`table'.strcolor . . yellow .  ;
        .`table'.numcolor yellow yellow . yellow ;
        .`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f ;
           di _n as text "{col 4} Decomposition of the Gini index by income components (using the Shapley value).";
           di as text  "{col 5}Execution  time :    "  %10.2f `ptime' " second(s)";
           di  as text "{col 5}Gini index      :    "  %10.6f `tgini'       ;
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
        .`table'.sep, top;
        .`table'.titles "Sources  "  "Income   "     "  Absolute  " "  Relative  " ;
        .`table'.titles "         "  " Share   "     "Contribution" "Contribution" ;
        .`table'.sep, mid;
        local nalt = "ddd";
        forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor  white yellow yellow   yellow ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green    green   green  ;
             if ((`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i'] `INCS'[`i']  `ABSC'[`i'] `RELC'[`i']; 
                    };
                     
  .`table'.sep, mid;
.`table'.numcolor white yellow yellow   yellow  ;
.`table'.row  "Total" `INCS'[`ka']  `ABSC'[`ka'] `RELC'[`ka'];
if ("`ste'"=="yes"){;
.`table'.numcolor white green   green green  ;
.`table'.row " "  `INCS'[`kb']  `ABSC'[`kb'] `RELC'[`kb'];
};
	.`table'.sep,bot;


if ("`ste'"~="yes") {;
cap drop Source; qui gen Source="";
forvalues k=1/$indica {;
qui replace Source = "`k': ``k''"    in `k';
};

disp _n;
      disp in green  "{hline 60}";
      disp in yellow "Marginal contributions:";
      disp in green  "{hline 60}";
local ntab=ceil($indica/5)-1;
forvalues i=0/`ntab' {; 
local b= `i'*5+1;
local e= min(`b'+4,$indica);
tabdisp Source in 1/$indica, cellvar(level_`b'-level_`e') concise format(%18.6f) left total;
};

}; 



tempname  Variableo;
qui gen  `Variableo'=`Variable';



local lng = ($indica*2+2);
qui keep in 1/`lng';

local bf=`lng'/2+1;
forvalues j=2(1)`bf'{;
qui drop in `j';
};


local dste = 0;

tempname zz;


 mkmat	`INCS'  `ABSC' `RELC',	matrix(`zz');

if ("`xfil'" ~="") {;

local rnamn ="";
local lng1 = `lng'-1;
local pass = 2 ;
if `dste'~=1 local pass = 1 ;
forvalues i=1(`pass')`lng'  {;
local temn= `Variableo'[`i'];
if (`i'!=`lng1' & `dste'==1)                local rnamn `rnamn'  `temn' @ @  ;
if (`i'!=`lng1' & `dste'!=1)                local rnamn `rnamn'  `temn' @  ;
if (`i'==`lng1' | `i'==`lng')               local rnamn `rnamn'  `temn'       ;

};
global rnamn `"`rnamn'"';


local cnamn `index' @ ; 
                     local cnamn `cnamn' Income share  @;
if ("`xlan'"~="fr")  local cnamn `cnamn' Absolute contribution @;
if ("`xlan'"~="fr")  local cnamn `cnamn' Relative contribution @;
global cnamn `cnamn';

if ("`xtit'"=="")    local xtit = "Table ##: Decomposition of the Gini index by income sources";
if ("`xtit'"~="")    local xtit = "`xtit'";
local note2 = "Decomposition with the Shapley approach.";

tokenize "`xfil'" ,  parse(".");
local xfil = "`1'";
 mk_xls `1' ,  matn(`zz') dec(`dec')   etitle(`xtit') xlan(`xlan') dste(`dste')  fexcel(`xfil') esheet(`xshe') modrep(`modrep') note2(`note2') fcname(Income source);
 
};


end;  

