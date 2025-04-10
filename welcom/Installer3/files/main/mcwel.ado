/*************************************************************************/
/* mcwel: Market Concentration and Welfare  (Version 2.20)               */
/*************************************************************************/
/* Conceived  by :                                                       */
/*     Abdelkrim Araar                                                   */
/*     Eduardo Malasquez                                                 */
/*     Sergio Olivieri                                                   */
/*     Carlos Rodriguez-Castelan                                         */
/* email : aabd@ecn.ulaval.ca                                            */
/* 14/Nov/2018 			                                         */
/*************************************************************************/
/* mcwel.ado                                                             */
/*************************************************************************/



#delim ;
set more off;

capture program drop mcwel;
program define mcwel , eclass sortpreserve;
version 9.2;
syntax varlist (min=1 max=1) [if] [in] [,  
HSize(string)  
PLine(varname)
HGroup(string)
NITEMS(int 1)
MOVE(int 1)
MEAS(int 1)
MODEL(int 1)
SUBS(real 0.6)
EPSILON(real 0.5)
THETA(real 0)
INISave(string) 
GVIMP(int 0)
CONF(string) 
LEVEL(real 95)
DEC(int 3)
IT1(string) IT2(string)  IT3(string)  IT4(string) IT5(string)  
IT6(string) IT7(string)  IT8(string)  IT9(string) IT10(string)

MPART(int 0)

XFIL(string)
TJOBS(string) 

GJOBS(string) 
FOLGR(string)

OPGR1(string) OPGR2(string)  OPGR3(string) 
];


local lan en;
 if ("`inisave'" ~="") {;
  asdbsave_mcw `0' ;
  };

if "`hgroup'"=="" local hgroup = 5;
local mylist sn vn el st nf si;
forvalues i=1/`nitems' {;
extend_opt_item_mcwel test , `it`i'' ;
foreach name of local mylist {;
local `name'`i'  `r(`name')';

if  "`name'"~="sn" & "`name'"~="it"  & "``name'`i''"=="" local `name'`i' = 0 ;
/*
if  "``name'`i''"=="." local `name'`i' = "" ;
dis "`name'`i' = ``name'`i'' ";
*/
};
};


tokenize `varlist';
local mylist min max ogr;
forvalues i=1/10 {;
if ("`opgr`i''"~="") {;
extend_opt_graph test , `opgr`i'' ;
foreach name of local mylist {;
local `name'`i' = r(`name');
if  "``name'`i''"=="." local `name'`i' = "" ;
};
};
};


 
/****************************************************************/

/* Copying  the sampling weight */
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear;

/* The household size        */
if ("`hsize'"=="" )         {;
tempvar hsize;
qui gen `hsize' = 1;
};

/* The final weight         */
tempvar fw;
qui gen `fw'=`hsize';
if ("`hweight'"~="")        qui replace `fw'=`fw'*`hweight';


if "`hgroup'"=="" local ngroup = "Quintiles";
if "`hgroup'"~="" local ngroup = `hgroup';

/* Generating the categorical variable (quintiles) */
if "`hgroup'"==""  {;
tempvar quint;
qui xtile  `quint'=`2'  [aw=`fw'],  nq(5);
cap label drop quint;
forvalues i=1/5 {;
  lab def quint `i' "Quintile `i'", add;
};
lab val `quint' quint; 
local hgroup = "`quint'";
};

if "`hgroup'"~=""  {;
cap confirm integer number `hgroup' ;
if !_rc {;
tempvar dgr;
qui xtile  `dgr'=`1'  [aw=`fw'],  nq(`hgroup');
cap label drop dgr;
forvalues i=1/`hgroup' {;
  if `hgroup' == 4  lab def dgr `i' "Quartile `i'", add;
  if `hgroup' == 5  lab def dgr `i' "Quintile `i'", add;
  if `hgroup' == 10 lab def dgr `i' "Decile `i'",   add;
  if `hgroup' != 10 &  `hgroup' != 5  & `hgroup' != 4 lab def dgr `i' "Group `i'",   add;
};
lab val `dgr' dgr; 
local hgroup = "`dgr'";

};
};



if ("`lan'" == "") local lan = "en";
if ("`tjobs'" == ""  & "`tjobs'"~="off")  local tjobs 12  21 22 23   31 32 33 41  42 43 44 51 52 53   61 62 63  64   ;
if ("`gjobs'" == ""  & "`gjobs'"~="off" ) local gjobs 1 2 3 4 5 6;


local mylist  vn sn el st nf si;
forvalues i=1/`nitems' {;
extend_opt_item_mcwel test , `it`i'' ;
foreach name of local mylist {;
local `name'`i'  `r(`name')';

if  "`name'"~="sn" & "`name'"~="vn"  & "``name'`i''"=="" local `name'`i' = 0 ;
/*
if  "``name'`i''"=="." local `name'`i' = "" ;
dis "`name'`i' = ``name'`i'' ";
*/

if "`name'"=="sn" & "``name'`i''"==""  local `name'`i' = "`vn`i''"  ;

};
};




cap drop __VNITEMS ; 
qui gen  __VNITEMS = "";

cap drop __SLITEMS ; 
qui gen __SLITEMS = "";


forvalues i=1/`nitems' {;



if ("`vn`i''" ~= "" ) qui replace __VNITEMS =  "`vn`i''"  in `i' ;
if ("`sn`i''" == "" ) local sn`i' = "`it`i''" ;
if ("`sn`i''" ~= "" ) qui replace __SLITEMS =  "`sn`i''"  in `i' ;

};

local vnitems = "__VNITEMS"  ; 
local slitems = "__SLITEMS" ;




local vlist;
local slist;
preserve;
qui  cap drop if `vnitems'=="";
//sort `vnitems';
qui count;


forvalues i=1/`r(N)' {;
local tmp = ""+`vnitems'[`i'];
if `i' == 1 local tmp2 = " "+`slitems'[`i'];
if `i' != 1 local tmp2 = " |"+`slitems'[`i'];
if ("`slitems'"~="") {;
local vlist `vlist' `tmp';
local slist `slist' `tmp2';
};
};
restore;


tokenize "`tjobs'";
quietly {;
local k = -1;
if "`1'" ~= "" {;
local k = 1;
mac shift;
};
while "``k''" ~= "" {; 
local k = `k'+1;
};
};
if (`k'==-1) local k = 0;
tokenize "`tjobs'";
forvalues i=1/`k' {;
local tjob`i' = "``i''";
};
local ntables = `k';
tokenize "`gjobs'";
quietly {;
local k = -1;
if "`1'" ~= "" {;
local k = 1;
mac shift;
};
while "``k''" ~= "" {; 
local k = `k'+1;
};
};
if (`k'==-1) local k = 0;
tokenize "`gjobs'";
forvalues i=1/`k' {;
local gjob`i' = "``i''";

};
local ngraphs = `k';


local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear;



if ("`hsize'"=="" )         {;
tempvar hsize;
qui gen `hsize' = 1;
};
tempvar fw;
qui gen `fw'=`hsize';
if ("`hweight'"~="")        qui replace `fw'=`fw'*`hweight';



local ohgroup = "`hgroup'";
local langr   = "Groups"; 



/************************/

/* Capturing the modalities and the label values of the group variable */
preserve;
capture {;
cap local lvgroup:value label `hgroup';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , replace;
qui count;
local indica = `r(N)';
forvalues i=1/`r(N)' {;
local tem_`i'=value[`i'];
local grlab`tem_`i'' = label[`i'];
};
};
};

restore;

if ("`lvgroup'"=="") {;
cap matrix drop _aa;
qui tab `hgroup' , matrow(_aa);
local indica = `r(r)';
forvalues i=1/`r(r)' {; 
local tem_`i'=el(_aa, `i' ,1);
dis "****************" el(_aa, `i' ,1 );
local grlab`tem_`i'' = "Group_mod_`tem_`i''";
};
};


*preserve;


marksample touse;
qui sum `touse';
if (r(min)!=r(max)) preserve; 
qui keep if `touse' ;

tokenize "`xfil'" ,  parse(".");
local tname `1'.xml;

if ( "`tjobs'"~="off" ) {;
if "`xfil'" ~= ""  { ;
tokenize "`xfil'" ,  parse(".");
local xfil `1'.xml ;
cap erase  `1'.xml ;
cap winexec   taskkill /IM excel.exe ;
};
};

/* Computing the price changes */
tokenize `varlist';
if ( "`tjobs'"=="off" ) local prefix "qui" ;
`prefix' mcprc `1', 
it1(`it1')  it2(`it2')  it3(`it3')  it4(`it4')  it5(`it5')
it6(`it6')  it7(`it7')  it8(`it8')  it9(`it9')  it10(`it10')
nitems(`nitems') mpart(`mpart') move(`move');
;

matrix tab1_1 = e(tab1_1);
local simula = rowsof(tab1_1) -1;
                  local maindir = "Competitive to concentrated";
if `move' == -1   local maindir = "Concentrated to competitive";
forvalues s=1/`simula' {;
if `s'==`simula' local secdir = "Full adjustement" ;
if `s' <`simula' local secdir = "Step `s'";
local  tita`s'="`maindir': `secdir'";
local stita`s'="_`secdir'";
};



forvalues i=1/`nitems' {;
matrix tab1_`i' = e(tab1_`i');
local matrices " "`matrices' "tab1_`i'" ;
};
*set trace on;

tabtitmc 11 en;
local tabtit = "`r(tabtit)'";
matrix mymat=tab1_1;
forvalues i=1/`nitems' {;
matrix  coleq tab1_`i' =  "`sn`i''" ;
local matn `matn' tab1_`i' ;
if `i'>1 matrix mymat=mymat,tab1_`i';
};


if ( "`tjobs'"~="off" )  mk_xtab_ms mymat ,     matn(`matn')  dec(4) xfil(`xfil') xshe(table_11) xtit(`tabtit') xlan(`lan')  options(showeq) dste(0);

cap matrix drop `mat`tjob`i''';

local dec11=4;
local dec12=0;

local dec21=0;
local dec22=2;
local dec23=2;

local dec31=2;
local dec32=2;
local dec33=2;


local dec41=0;
local dec42=2;
local dec43=2;
local dec44=2;

local dec51=3;
local dec52=3;
local dec53=3;



local dec61=4;
local dec62=4;
local dec63=4;
local dec64=4;



tokenize `varlist';
_nargs   `varlist';

if (`gvimp' == 1)   mcjob41 `vlist',   hs(`hsize') hgroup(`hgroup') lan(en)  xrnames(`slist')  aggr(`taggregate') pcexp(`1')   wappr(`meas') model(`model') subs(`subs')  gvimp(`gvimp') move(`move') step(`simula');
 
if ( "`tjobs'"~="off" ){;
forvalues i=1/`ntables' {;

if (`tjob`i'' == 12) {;
mcjob12 `1'        , hs(`hsize') hgroup(`hgroup') lan(en) ;
tempname mat12 ;
matrix `mat12'= e(est);
tabtitmc 12 en;
local tabtit = "`r(tabtit)'";
distable `mat12', dec1(0) dec2(0) dec3(2) dec4(0) dec5(2) dec6(2)   atit(`langr') head1(`tabtit')  head2(`head2') ;
mk_xtab_mc `1' ,  matn(`mat12') dec(`dec`tjob`i''') xfil(`xfil') xshe(table_`tjob`i'') xtit(`tabtit') xlan(`lan') dste(0) dec1(0) dec2(0) dec3(2) dec4(0) dec5(2) dec6(2) control(2);
cap matrix drop `mat`tjob`i''';
};


if (`tjob`i'' >= 21 & `tjob`i'' <= 23) {;
mcjob`tjob`i'' `vlist',   hs(`hsize') hgroup(`hgroup') lan(en)  xrnames(`slist')  aggr(`taggregate') pcexp(`1');
tempname  mat`tjob`i'' ; 
matrix `mat`tjob`i'''= e(est);
tabtitmc `tjob`i''; 
local tabtit = "`r(tabtit)'";
distable `mat`tjob`i''', dec(`dec`tjob`i''') atit(`langr') head1(`r(tabtit)')  head2(`head2') ;
mk_xtab_mc `1' ,  matn(`mat`tjob`i''') dec(`dec`tjob`i''') xfil(`xfil') xshe(table_`tjob`i'') xtit(`tabtit') xlan(`lan') dste(0);
cap matrix drop `mat`tjob`i''';
};


if (`tjob`i'' >= 31 & `tjob`i'' <= 33) {;
tokenize `varlist';
mcjob`tjob`i'' `vlist',   hs(`hsize') hgroup(`hgroup') lan(`lan')  xrnames(`slist')  aggr(`taggregate') pcexp(`1');
tempname  mat`tjob`i'' ; 
matrix `mat`tjob`i'''= e(est);
tabtitmc `tjob`i''; 

if `tjob`i''==31  local tabtit Table 3.1: Structure of expenditure on products (in %) ; 
if `tjob`i''==32  local tabtit Table 3.2: Expenditure on products over the total expenditures (in %) ;
if `tjob`i''==33  local tabtit Table 3.3: Proportion of real consumers (in %) ;

distable `mat`tjob`i''', dec(`dec`tjob`i''') atit(`langr') head1(`tabtit')  head2(`head2') ;
mk_xtab_mc `1' ,  matn(`mat`tjob`i''') dec(`dec`tjob`i''') xfil(`xfil') xshe(table_`tjob`i'') xtit(`tabtit') xlan(`lan') dste(0);
cap matrix drop `mat`tjob`i''';
};

forvalues s=1/`simula' {;
if (`tjob`i'' == 41 ) {;
*set trace on;
mcjob`tjob`i'' `vlist',   hs(`hsize') hgroup(`hgroup') lan(en)  xrnames(`slist')  aggr(`taggregate') pcexp(`1')   wappr(`meas') model(`model') subs(`subs')  gvimp(0) move(`move') step(`s');

tempname  mat`tjob`i''_`s' ;
matrix `mat`tjob`i''_`s''= e(est);

tabtitmc `tjob`i''; 
local tabtit = "`r(tabtit)'"+"`scena'"+" || `tita`s''";
distable `mat`tjob`i''_`s'', dec(`dec`tjob`i''') atit(`langr') head1(`tabtit')  head2(`head2') ;
mk_xtab_mc `1' ,  matn(`mat`tjob`i''_`s'') dec(`dec`tjob`i''') xfil(`xfil') xshe(table_`tjob`i''`stita`s'') xtit(`tabtit') xlan(`lan') dste(0);

cap matrix drop `mat`tjob`i''_`s'';

};

if (`tjob`i'' == 42) {;
*set trace on;
mcjob`tjob`i'' `vlist',   hs(`hsize') hgroup(`hgroup') lan(en)  xrnames(`slist')  aggr(`taggregate') pcexp(`1')   wappr(`meas') model(`model') subs(`subs')  gvimp(0) move(`move') step(`s');

tempname  mat`tjob`i''_`s' ;
matrix `mat`tjob`i''_`s''= e(est);

tabtitmc `tjob`i''; 
local tabtit = "`r(tabtit)'"+"`scena'"+" || `tita`s''";
distable2 `mat`tjob`i''_`s'', dec(`dec`tjob`i''') atit(`langr') head1(`tabtit')  head2(`head2') ;
mk_xtab_mc `1' ,  matn(`mat`tjob`i''_`s'') dec(`dec`tjob`i''') xfil(`xfil') xshe(table_`tjob`i''`stita`s'') xtit(`tabtit') xlan(`lan') dste(0) midline(2) ;

cap matrix drop `mat`tjob`i''_`s'';

};



if (`tjob`i'' == 43) {;
mcjob`tjob`i'' `vlist',   hs(`hsize') hgroup(`hgroup') lan(en)  xrnames(`slist')  aggr(`taggregate') pcexp(`1')  wappr(`meas') model(`model')  move(`move') step(`s');
tempname  mat`tjob`i'' ;
matrix `mat`tjob`i'''= e(est);

tabtitmc `tjob`i''; 
local tabtit = "`r(tabtit)'"+"`scena'"+" || `tita`s''";
distable `mat`tjob`i''', dec(`dec`tjob`i''') atit(`langr') head1(`tabtit')  head2(`head2') ;
mk_xtab_mc `1' ,  matn(`mat`tjob`i''') dec(`dec`tjob`i''') xfil(`xfil') xshe(table_`tjob`i''`stita`s'') xtit(`tabtit') xlan(`lan') dste(0);

cap matrix drop `mat`tjob`i''';
};

if (`tjob`i'' == 44) {;
*set trace on;
mcjob`tjob`i'' `vlist',   hs(`hsize') hgroup(`hgroup') lan(en)  xrnames(`slist')  aggr(`taggregate') pcexp(`1')   wappr(`meas') model(`model') subs(`subs')  gvimp(0) move(`move') step(`s');

tempname  mat`tjob`i''_`s' ;
matrix `mat`tjob`i''_`s''= e(est);

tabtitmc `tjob`i''; 
local tabtit = "`r(tabtit)'"+"`scena'"+" || `tita`s''";
distable2 `mat`tjob`i''_`s'', dec(`dec`tjob`i''') atit(`langr') head1(`tabtit')  head2(`head2') ;
mk_xtab_mc `1' ,  matn(`mat`tjob`i''_`s'') dec(`dec`tjob`i''') xfil(`xfil') xshe(table_`tjob`i''`stita`s'') xtit(`tabtit') xlan(`lan') dste(0) midline(2) ;

cap matrix drop `mat`tjob`i''_`s'';

};


if (`tjob`i'' >= 51 & `tjob`i'' <= 53) {;
*set trace on;

qui mcjob`tjob`i'' `vlist',   hs(`hsize') hgroup(`hgroup') lan(en)  xrnames(`slist')  aggr(`taggregate') pcexp(`1')   wappr(`meas') model(`model') subs(`subs')  gvimp(`gvimp') move(`move') pline(`pline') step(`s') ;

tempname  mat`tjob`i'' ;
matrix `mat`tjob`i'''= e(est);

tabtitmc `tjob`i''; 
local tabtit = "`r(tabtit)'"+"`scena'"+" || `tita`s''";
distable `mat`tjob`i''', dec(`dec`tjob`i''') atit(Step) head1(`tabtit')  head2(`head2') dsmidl(1);
mk_xtab_mc `1' ,  matn(`mat`tjob`i''') dec(`dec`tjob`i''') xfil(`xfil') xshe(table_`tjob`i''`stita`s'') xtit(`tabtit') xlan(`lan') dste(0) ;

cap matrix drop `mat`tjob`i''';

};







if (`tjob`i'' == 61 ) {;
*set trace on;

qui mcjob`tjob`i'' `vlist',   hs(`hsize') hgroup(`hgroup') lan(en)  xrnames(`slist')  aggr(`taggregate') pcexp(`1')   wappr(`meas') model(`model') subs(`subs')  gvimp(`gvimp') move(`move')  step(`s');

tempname  mat`tjob`i'' ;
matrix `mat`tjob`i'''= e(est);

tabtitmc `tjob`i''; 
local tabtit = "`r(tabtit)'"+"`scena'"+" || `tita`s''";
distable `mat`tjob`i''', dec(`dec`tjob`i''') atit(Step) head1(`tabtit')  head2(`head2') dsmidl(1) ;
mk_xtab_mc `1' ,  matn(`mat`tjob`i''') dec(`dec`tjob`i''') xfil(`xfil') xshe(table_`tjob`i''`stita`s'') xtit(`tabtit') xlan(`lan') dste(0);

cap matrix drop `mat`tjob`i''';

};


if (`tjob`i'' == 62 ) {;
*set trace on;

qui mcjob`tjob`i'' `vlist',   hs(`hsize') hgroup(`hgroup') lan(en)  xrnames(`slist')  aggr(`taggregate') pcexp(`1')   wappr(`meas') model(`model') subs(`subs')  gvimp(`gvimp') move(`move')  epsilon(`epsilon')  step(`s');

tempname  mat`tjob`i'' ;
matrix `mat`tjob`i'''= e(est);

tabtitmc `tjob`i''; 
local tabtit = "`r(tabtit)'"+"`scena'"+" || `tita`s''";
distable `mat`tjob`i''', dec(`dec`tjob`i''') atit(Step) head1(`tabtit')  head2(`head2') dsmidl(1) ;
mk_xtab_mc `1' ,  matn(`mat`tjob`i''') dec(`dec`tjob`i''') xfil(`xfil') xshe(table_`tjob`i''`stita`s'') xtit(`tabtit') xlan(`lan') dste(0);

cap matrix drop `mat`tjob`i''';

};


if (`tjob`i'' == 63 ) {;
*set trace on;

qui mcjob`tjob`i'' `vlist',   hs(`hsize') hgroup(`hgroup') lan(en)  xrnames(`slist')  aggr(`taggregate') pcexp(`1')   wappr(`meas') model(`model') subs(`subs')  gvimp(`gvimp') move(`move')  theta(`theta')  step(`s');

tempname  mat`tjob`i'' ;
matrix `mat`tjob`i'''= e(est);

tabtitmc `tjob`i''; 
local tabtit = "`r(tabtit)'"+"`scena'"+" || `tita`s''";
distable `mat`tjob`i''', dec(`dec`tjob`i''') atit(Step) head1(`tabtit')  head2(`head2') dsmidl(1);
mk_xtab_mc `1' ,  matn(`mat`tjob`i''') dec(`dec`tjob`i''') xfil(`xfil') xshe(table_`tjob`i''`stita`s'') xtit(`tabtit') xlan(`lan') dste(0);

cap matrix drop `mat`tjob`i''';

};

if (`tjob`i'' == 64 ) {;
*set trace on;

qui mcjob`tjob`i'' `vlist',   hs(`hsize') hgroup(`hgroup') lan(en)  xrnames(`slist')  aggr(`taggregate') pcexp(`1')   wappr(`meas') model(`model') subs(`subs')  gvimp(`gvimp') move(`move')  step(`s');

tempname  mat`tjob`i'' ;
matrix `mat`tjob`i'''= e(est);

tabtitmc `tjob`i''; 
local tabtit = "`r(tabtit)'"+"`scena'"+" || `tita`s''";
distable `mat`tjob`i''', dec(`dec`tjob`i''') atit(Step) head1(`tabtit')  head2(`head2') dsmidl(1);
mk_xtab_mc `1' ,  matn(`mat`tjob`i''') dec(`dec`tjob`i''') xfil(`xfil') xshe(table_`tjob`i''`stita`s'') xtit(`tabtit') xlan(`lan') dste(0);

cap matrix drop `mat`tjob`i''';

};
};

};
};

*set trace on;

/********* The graphs *********************/

cap rmdir Graphs;
cap mkdir Graphs;
local mygrdir Graphs\ ;

if ( "`gjobs'"~="off" ){;
forvalues i=1/`ngraphs' {;
set matsize 800;
if ("`gjob`i''" == "1" ) {;
*set trace on;
set tracedepth 1;
tokenize `varlist';

qui mcprc `1', 
it1(`it1')  it2(`it2')  it3(`it3')  it4(`it4')  it5(`it5')
it6(`it6')  it7(`it7')  it8(`it8')  it9(`it9')  it10(`it10')
nitems(`nitems') mpart(100) move(`move');
;



if "`min`gjob`i'''"=="" local min`gjob`i'' = 0;
if "`max`gjob`i'''"=="" local max`gjob`i'' = 1;

 qui mcjobgr`gjob`i'' `1',   hs(`hsize') lan(`lan')  xrnames(`slist')  aggr(`gaggregate') pcexp(`1') ogr(`ogr`gjob`i''') nitems(`nitems') 
 it1(`it1')  it2(`it2')  it3(`it3')  it4(`it4')  it5(`it5')
it6(`it6')  it7(`it7')  it8(`it8')  it9(`it9')  it10(`it10')
 ;

 qui graph save           "`mygrdir'Fig_`gjob`i''.gph" , replace ;
 qui graph export         "`mygrdir'Fig_`gjob`i''.wmf"  , replace ;
 qui cap graph export     "`mygrdir'Fig_`gjob`i''.pdf"  ,  as(pdf) replace ;
 
 qui mcprc `1', 
it1(`it1')  it2(`it2')  it3(`it3')  it4(`it4')  it5(`it5')
it6(`it6')  it7(`it7')  it8(`it8')  it9(`it9')  it10(`it10')
nitems(`nitems') mpart(`mpart') move(`move');

forvalues j=1/`nitems' {;
matrix tab1_`j' = e(tab1_`j');
};
};

if ("`gjob`i''" == "2" ) {;
*set trace on;
set tracedepth 1;
if "`min`gjob`i'''"=="" local min`gjob`i'' = 0;
if "`max`gjob`i'''"=="" local max`gjob`i'' = 1;

qui mcjobgr`gjob`i'' `vlist',   hs(`hsize') lan(`lan')  xrnames(`slist')  aggr(`gaggregate') pcexp(`1') ogr(`ogr`gjob`i''') min(`min`gjob`i''') max(`max`gjob`i''')   ;

 qui graph save           "`mygrdir'Fig_`gjob`i''.gph" , replace ;
 qui graph export         "`mygrdir'Fig_`gjob`i''.wmf"  , replace ;
 qui cap graph export     "`mygrdir'Fig_`gjob`i''.pdf"  ,  as(pdf) replace ;
};

if ("`gjob`i''" == "3" ) {;
*set trace on;
set more off;
set tracedepth 2;
if "`min`gjob`i'''"=="" local min`gjob`i'' = 0;
if "`max`gjob`i'''"=="" local max`gjob`i'' = 1;
 mcjobgr`gjob`i'' `vlist',   hs(`hsize') hgroup(`hgroup') lan(`lan')  xrnames(`slist')  aggr(`gaggregate') pcexp(`1') ogr(`ogr`gjob`i''')  min(`min`gjob`i''') max(`max`gjob`i''')   wappr(`meas') model(`model') subs(`subs')  gvimp(`gvimp') move(`move');
qui graph save       "`mygrdir'Fig_`gjob`i''.gph" , replace ;
qui graph export     "`mygrdir'Fig_`gjob`i''.wmf"  , replace ;
cap qui graph export     "`mygrdir'Fig_`gjob`i''.pdf"  ,  as(pdf) replace ;
};

if ("`gjob`i''" == "4" ) {;
*set trace on;
qui mcjobgr`gjob`i'' `vlist',   hs(`hsize') lan(`lan')  xrnames(`slist')  aggr(`gaggregate') pcexp(`1') ogr(`ogr`gjob`i''')  min(`min`gjob`i''') max(`max`gjob`i''')  ;
qui graph save       "`mygrdir'Fig_`gjob`i''.gph" , replace ;
qui graph export     "`mygrdir'Fig_`gjob`i''.wmf"  , replace ;
cap qui graph export     "`mygrdir'Fig_`gjob`i''.pdf"  ,  as(pdf) replace ;

};



if ("`gjob`i''" == "5" ) {;
*set trace on;
set tracedepth 3;
tokenize `varlist';

qui mcprc `1', 
it1(`it1')  it2(`it2')  it3(`it3')  it4(`it4')  it5(`it5')
it6(`it6')  it7(`it7')  it8(`it8')  it9(`it9')  it10(`it10')
nitems(`nitems') mpart(20) move(`move');
;

forvalues j=1/`nitems' {;
matrix tab1_`j' = e(tab1_`j');
};

if "`min`gjob`i'''"=="" local min`gjob`i'' = 0;
if "`max`gjob`i'''"=="" local max`gjob`i'' = 1;

qui mcjob51b `vlist',   hs(`hsize') hgroup(`hgroup') lan(en)  xrnames(`slist')  aggr(`taggregate') pcexp(`1')   wappr(`meas') model(`model') subs(`subs')  gvimp(`gvimp') move(`move') pline(`pline') nitems(`nitems');
matrix gmat = e(gmat);

 

  mcjobgr`gjob`i'' `1',   hs(`hsize') lan(`lan')  xrnames(`slist')  aggr(`gaggregate') pcexp(`1') ogr(`ogr`gjob`i''') nitems(`nitems') 
 it1(`it1')  it2(`it2')  it3(`it3')  it4(`it4')  it5(`it5')
it6(`it6')  it7(`it7')  it8(`it8')  it9(`it9')  it10(`it10')
 ;
 

 qui graph save           "`mygrdir'Fig_`gjob`i''.gph" , replace ;
 qui graph export         "`mygrdir'Fig_`gjob`i''.wmf"  , replace ;
 qui cap graph export     "`mygrdir'Fig_`gjob`i''.pdf"  ,  as(pdf) replace ;
 
 
 
 qui mcprc `1', 
it1(`it1')  it2(`it2')  it3(`it3')  it4(`it4')  it5(`it5')
it6(`it6')  it7(`it7')  it8(`it8')  it9(`it9')  it10(`it10')
nitems(`nitems') mpart(`mpart') move(`move');


};



if ("`gjob`i''" == "6" ) {;
*set trace on;
set tracedepth 3;
tokenize `varlist';

qui mcprc `1', 
it1(`it1')  it2(`it2')  it3(`it3')  it4(`it4')  it5(`it5')
it6(`it6')  it7(`it7')  it8(`it8')  it9(`it9')  it10(`it10')
nitems(`nitems') mpart(20) move(`move');
;
forvalues j=1/`nitems' {;
matrix tab1_`j' = e(tab1_`j');
};

if "`min`gjob`i'''"=="" local min`gjob`i'' = 0;
if "`max`gjob`i'''"=="" local max`gjob`i'' = 1;

qui mcjob61b `vlist',   hs(`hsize') hgroup(`hgroup') lan(en)  xrnames(`slist')  aggr(`taggregate') pcexp(`1')   wappr(`meas') model(`model') subs(`subs')  gvimp(`gvimp') move(`move') nitems(`nitems');
matrix gmat = e(gmat);


  mcjobgr`gjob`i'' `1',   hs(`hsize') lan(`lan')  xrnames(`slist')  aggr(`gaggregate') pcexp(`1') ogr(`ogr`gjob`i''') nitems(`nitems') 
 it1(`it1')  it2(`it2')  it3(`it3')  it4(`it4')  it5(`it5')
it6(`it6')  it7(`it7')  it8(`it8')  it9(`it9')  it10(`it10')
 ;
 
 
 qui graph save           "`mygrdir'Fig_`gjob`i''.gph" , replace ;
 qui graph export         "`mygrdir'Fig_`gjob`i''.wmf"  , replace ;
 qui cap graph export     "`mygrdir'Fig_`gjob`i''.pdf"  ,  as(pdf) replace ;
 
 
 
 qui mcprc `1', 
it1(`it1')  it2(`it2')  it3(`it3')  it4(`it4')  it5(`it5')
it6(`it6')  it7(`it7')  it8(`it8')  it9(`it9')  it10(`it10')
nitems(`nitems') mpart(`mpart') move(`move');

forvalues j=1/`nitems' {;
matrix tab1_`j' = e(tab1_`j');
};
};


};

};


if ( "`tjobs'"~="off" ) {;

cap drop __nevar*;
if  ("`xfil'" ~= "" &  "`tjobs'"~="off" ) | ("`xfil'" ~= "") {;
cap !start "" /min "`xfil'" ; 
};

};
  
cap drop __VNITEMS ; 
cap drop __SLITEMS ; 
cap drop __imp_well ;

end;
/*
set trace on; 
set tracedepth 4;

mcwel pc_ing_cor, hsize(tot_integ) pline(pline) gvimp(1) inisave(C:\PDATA\welcom2\test1) nitems(2) 
it1( sn(Combustile) vn(pc_exp_combus_all) el(-0.8) st(2) nf(10) ) 
it2( sn(Comunication) vn(pc_exp_comu_all) el(-1.2) st(3) si(0.5) ) 
model(2) subs(.009) meas(1)
move(1) 
hgroup(10)  theta(.7) epsilon(.8) 
opgr1( min(0) max(0.8)  )
opgr2( min(0) max(0.9)  )
opgr3( min(0) max(1)  ) 
mpart(2) 
;
*/
