/********************************************************************************/
/*  Package       : USST //Usefull Stata Tools                                  */
/*  Version       :   0.10   //                       JUNE         2020         */
/*  Stata Version : Required  15.0 and higher                                   */
/*  Authors       : Abdelkrim Araar  // aabd@ecn.ulaval.ca                      */
/********************************************************************************/



#delim ;


capture program drop ddfgts;
program define ddfgts, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname)  HGroup(varname) PLine(real 10000) ALpha(real 0) STE(string) CONF(string)
LEVEL(real 95) DEC(int 6) DSTE(int 1) initial(varname)
XFIL(string) XSHE(string) XLAN(string) XTIT(string)
];

timer clear 1;
timer on 1;
preserve;
if ("`conf'"=="")          local conf="ts";
local ll=0;

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);


 tokenize `varlist';
_nargs    `varlist';

local hweight=""; 
qui svy: total `1'; 
cap local hweight=`"`e(wvar)'"';
cap ereturn clear; 
tempvar fw;
qui gen `fw'=1;
if ("`hweight'"~="") qui replace `fw'=`fw'*`hweight';
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


cap drop `num' ;
tempvar num; 
qui gen  `num'=0;

cap drop `num1' ;
tempvar num1; 
qui gen  `num1'=0;

cap drop `num2' ;
tempvar num2; 
qui gen  `num2'=0;

tempvar final; 
qui gen  `final'=0;

if ("`STE'"~="yes") {;
qui replace `final' =  (`initial'+`tinco') ;
cap drop `num1' `num2';
tempvar num1 num2;
qui gen `num1' = 0;
qui gen `num2' = 0;

if (`alpha' == 0)           {;

    qui replace    `num1' =  (`pline'> `final')      if (`pline'> `final');
    qui replace    `num2' =  (`pline'> `initial')    if (`pline'>`initial');
	qui replace    `num' =  `num1'- `num2';
};
if (`alpha' ~= 0)           {;
    qui replace    `num1' =  ((`pline'-  `final')/`pline')^`alpha'               if (`pline'>`final');
    qui replace    `num2' =  ((`pline'-`initial')/`pline')^`alpha'               if (`pline'>`initial');
	qui replace    `num' =  `num1'- `num2';
};
qui sum `num' [aw=`fw'];
local     tfgt = `r(mean)';
qui  sum `tinco' [aw=`fw']; 
local mu_inc = `r(mean)';
};
                                                 
if ("`ste'"=="yes") {;
qui replace `final' =  (`initial'+`tinco') ;
cap drop `num1' `num2';
tempvar num1 num2;
qui gen `num1' = 0;
qui gen `num2' = 0;

if (`alpha' == 0)           {;
    qui replace    `num1' =  `hs'*(`pline'> `final')      if (`pline'> `final');
    qui replace    `num2' =  `hs'*(`pline'> `initial')    if (`pline'>`initial');
	qui replace    `num' =  `num1'- `num2';
};
if (`alpha' ~= 0)           {;
    qui replace    `num1' =  `hs'*((`pline'- `final' )/`pline')^`alpha'   if (`pline'> `final');
    qui replace    `num2' =  `hs'*((`pline'-`initial')/`pline')^`alpha'   if (`pline'>`initial');
	qui replace    `num' =  `num1'- `num2';
};
qui gen _tvega = `num';;
tempvar  wtinco;
qui gen `wtinco'=`hs'*`tinco';
};



tempvar tinco   ;

cap drop _shav;
qui gen  _shav=0;

tempvar Variable INCS  ABSC  RELC;
qui gen `Variable'="";
qui gen `INCS'=0;
qui gen `ABSC'=0;
qui gen `RELC'=0;





if ("`ste'"=="yes") {;
forvalues j=1/$indica {;
cap drop _vega`j';
qui gen  _vega`j'=0;
};
};



forvalues i=1/$shasize {;
cap drop `inco';
tempvar inco;
gen `inco'=0;
forvalues j=1/$indica {;
qui replace `inco' = `inco' + ``j'' *(_o`j'[`i'] != .);
};

cap drop `num';
tempvar   num; 
qui gen  `num'=0;
if ("`STE'"~="yes") {;
qui replace `final' =  (`initial'+`inco') ;
cap drop `num1' `num2';
tempvar num1 num2;
qui gen `num1' = 0;
qui gen `num2' = 0;

if (`alpha' == 0)           {;
    qui replace    `num1' =  (`pline'> `final')     ;
    qui replace    `num2' =  (`pline'> `initial')   ;
	qui replace    `num' =  `num1'- `num2';
	

};

if (`alpha' ~= 0)           {;
    qui replace    `num1' =  ((`pline'- `final' )/`pline')^`alpha'   if (`pline'> `final');
    qui replace    `num2' =  ((`pline'-`initial')/`pline')^`alpha'   if (`pline'>`initial');
	qui replace    `num' =  `num1'- `num2';
};
qui sum `num' [aw=`fw'], meanonly;
qui replace _shav = `r(mean)' in `i';
};
                                                 
if ("`ste'"=="yes") {;
qui replace `final' =  (`initial'+`inco') ;
cap drop `num1' `num2';
tempvar num1 num2;
qui gen `num1' = 0;
qui gen `num2' = 0;

if (`alpha' == 0)           {;
    qui replace    `num1' =  `hs'*(`pline'> `final')      if (`pline'> `final');
    qui replace    `num2' =  `hs'*(`pline'> `initial')    if (`pline'>`initial');
	qui replace    `num' =  `num1'- `num2';
};

if (`alpha' ~= 0)           {;
    qui replace    `num1' =  `hs'*((`pline'- `final' )/`pline')^`alpha'   if (`pline'> `final');
    qui replace    `num2' =  `hs'*((`pline'-`initial')/`pline')^`alpha'   if (`pline'>`initial');
	qui replace    `num' =  `num1'- `num2';
};
forvalues j=1/$indica {;
qui replace _vega`j' = _vega`j'+_shapwe`j'[`i']*`num';
};
};

};



/******************/

if ("`ste'"~="yes") {;

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
};

/******************/



forvalues k=1/$indica {;
local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;

qui replace `Variable' = "`k': ``k''"    in `k1';

if ("`ste'"~="yes") {;

tempvar  wcomk;
qui sum ``k'' [aw=`fw']; 

qui replace `INCS'         = `r(mean)'/`mu_inc'  in `k1';
tempvar shav; qui gen `shav'=0;
qui replace `shav'         =  _shav*_shapwe`k';
qui sum `shav';
qui replace `ABSC'         = `r(sum)'*(100)               in `k1';

qui replace `RELC'         = `r(sum)'/(`tfgt')*100    in `k1';
};

if ("`ste'"=="yes") {;

tempvar  wcomk;
qui gen `wcomk'=`hs'*``k'';
qui svy: ratio `wcomk'/`wtinco';
cap drop matrix _aa; matrix _aa=e(b);
cap drop matrix _vv; matrix _vv=e(V);
qui replace `INCS'         = el(_aa,1,1)        in `k1';
qui replace `INCS'         = el(_vv,1,1)^0.5    in `k2';

qui svy: ratio _vega`k' / `hs' ;
cap drop matrix _aa; matrix _aa=e(b);
cap drop matrix _vv; matrix _vv=e(V);
qui replace `ABSC'         = el(_aa,1,1)*100        in `k1';
qui replace `ABSC'         = el(_vv,1,1)^0.5*100    in `k2';


tempvar  rela;
qui gen `rela'=`hs'-_tvega;
qui svy: ratio _vega`k' / `rela' ;
cap drop matrix _aa; matrix _aa=e(b);
cap drop matrix _vv; matrix _vv=e(V);
qui replace `RELC'         = el(_aa,1,1)*100        in `k1';
qui replace `RELC'         = el(_vv,1,1)^0.5*100    in `k2';

};
};







local ka=`k1'+2;
local kb=`k1'+3;
qui replace `Variable'     = "Total" in `ka';
qui replace `INCS'         = 1       in `ka';
qui replace `INCS'         = 0      in `kb';

if ("`ste'"~="yes") {;
qui replace `ABSC'         = `tfgt'*100  in `ka';
};

if ("`ste'"=="yes") {;
qui svy: ratio _tvega / `hs' ;
cap drop matrix _aa; matrix _aa=e(b);
cap drop matrix _vv; matrix _vv=e(V);
cap drop matrix _aa; matrix _aa=e(b);
cap drop matrix _vv; matrix _vv=e(V);
qui replace `ABSC'         = el(_aa,1,1)        in `ka';
qui replace `ABSC'         = el(_vv,1,1)^0.5      in `kb';
local tfgt  = el(_aa,1,1);
};

qui replace `RELC'         = 100.0    in `ka';
qui replace `RELC'         = 0.0     in `kb';








timer off 1;
qui timer list 1;
local ptime = `r(t1)';
/****TO DISPLAY RESULTS *****/
set more off;
local ll = 20;
        tempname table;
        .`table'  = ._tab.new, col(3);
        .`table'.width |`ll'| 20 20 |;
        .`table'.strcolor  . yellow .  ;
        .`table'.numcolor  yellow . yellow ;
        .`table'.numfmt %16.0g  %16.2f %16.2f ;
           di _n as text "{col 4} Decomposition of change in the FGT index by shock components (using the Shapley value).";
           di as text  "{col 5}Execution  time     :    "  %10.2f `ptime' " second(s)";
           di  as text "{col 5}Parameter alpha     :    "  %10.2f `alpha'       ;
             di  as text "{col 5}Poverty line      :    "  %10.2f `pline'       ;
           di  as text "{col 5}Change in FGT index :    "  %10.6f `tfgt'*100 " (in %)"       ;
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
        .`table'.sep, top;
        .`table'.titles  "Income   "     "  Absolute  " "  Relative  " ;
        .`table'.titles  " Share   "     "Contribution  " "Contribution (in%)" ;
        .`table'.sep, mid;
        local nalt = "ddd";
        forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor  white  yellow   yellow ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white  green   green  ;
             if ("`ste'"=="yes" | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i']   `ABSC'[`i'] `RELC'[`i']; 
                    };
                     
  .`table'.sep, mid;
.`table'.numcolor white  yellow   yellow  ;
.`table'.row  "Total"   `ABSC'[`ka'] `RELC'[`ka'];
if ("`ste'"=="yes"){;
.`table'.numcolor white    green green  ;
.`table'.row " "  `  `ABSC'[`kb'] `RELC'[`kb'];
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


local dste=0; if ("`ste'"=="yes") local dste=1;

local rnam;

forvalues k=1/$indica {;
                  local tnv:var label ``k'';
if ("`tnv'"=="")  local tnv ="``k''";
                local rnam `"`rnam' "`tnv'""';
if (`dste'~=0 ) local rnam `"`rnam' " ""';
};
local rnam `"`rnam' "Total""';
local rnam `"`rnam' " ""';
global rnam `"`rnam'"';


local lng = ($indica*2+2);
qui keep in 1/`lng';
if (`dste'==0 ) {;
local bf=`lng'/2+1;
forvalues j=2(1)`bf'{;
qui drop in `j';
};
};



tempname zz;


 mkmat  `INCS'  `ABSC' `RELC',  matrix(`zz');




local cnam;

if ( "`xlan'"~="fr")   local cnam `"`cnam' "Income share""';
if ( "`xlan'"=="fr")   local cnam `"`cnam' "Proportion du revenu total""';

if ("`xlan'"~="fr")  local cnam `"`cnam' "Absolute contribution""';
if ("`xlan'"=="fr")  local cnam `"`cnam' "Contribution absolue""';
if ("`xlan'"~="fr")  local cnam `"`cnam' "Relative contribution""';
if ("`xlan'"=="fr")  local cnam `"`cnam' "Contribution relative""';
global cnam `"`cnam'"';

                     local xtit = "Table ##: Decomposition of the FGT index by income components";
if ("`xlan'"=="fr")  local xtit = "Tableau ##: Dcomposition de l'indice FGT selon les composantes du revenu";
if ("`xtit'"~="")    local xtit = "`xtit'";

                           local note2 = "[-] Decomposition with the Shapley value.";
if ( "`xlan'"=="fr") local note2 = "[-] Dcomposition selon la valeur de Shapley.";



if ("`xfil'" ~="") {;
mk_xtab_m1 `1' ,  matn(`zz') dec(`dec') xfil(`xfil') xshe(`xshe') xtit(`xtit') xlan(`xlan') dste(`dste') note(`note2');
};

ereturn matrix est = `zz' ;

end;  

