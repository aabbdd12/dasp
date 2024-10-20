/************************************************************************************/
/* ttrwel: Tobacco Tax Reform and Welfare  (Version 1.00)                           */
/************************************************************************************/
/* Conceived  by Dr. Araar Abdelkrim and Alan Fuchs				                    */
/* World Bank and Universite Laval, Quebec, Canada                       	        */
/* email : aabd@ecn.ulaval.ca                                            			*/
/* Phone : 1 418 656 7507                                                			*/
/************************************************************************************/
/*   ttrwel.dlg                                                           			*/
/************************************************************************************/



#delim ;
set more off;
capture program drop ttrwel;
program define ttrwel , eclass sortpreserve;
version 9.2;
syntax varlist (min=2 max=2) [if] [in] [,  
HSize(string)  
DECile(string)
INISave(string) 
CONF(string) 
LEVEL(real 95)

XFIL(string)
TJOBS(string) 
GJOBS(string) 
FOLGR(string)
OPGR1(string) OPGR2(string)  OPGR3(string) 
FELAS(string)

ELASM(string)
ELASL(string)
ELASU(string)

MEDEXP(real 1000000)
TYLL(real 100000)
PRINC(real 0.25)
DEC(int 6)
STE(int 0)
];


local lan en;
 if ("`inisave'" ~="") {;
  asdbsave_ttrw `0' ;
  };

if "`hgroup'"=="" local hgroup = 10;

tokenize `varlist';

local mylist min max ogr;
forvalues i=1/4 {;
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



local lan = "en";
if ("`tjobs'" == ""  & "`tjobs'"~="off" ) local tjobs 1 2 3 4 5 6;
if ("`gjobs'" == ""  & "`gjobs'"~="off" ) local gjobs 1 2 3 4;

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
local tjob``i'' = "``i''";
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

forvalues i=1/6 {;
if "`tjob`i''"=="" local tjob`i'=-1;
};

forvalues i=1/4 {;
if "`gjob`i''"=="" local gjob`i'=-1;
};


/************************/
marksample touse;
qui sum `touse';
if (r(min)!=r(max)) preserve; 
qui keep if `touse' ;

tokenize "`xfil'" ,  parse(".");
local tname "`1'.xml";
if "`xfil'" ~= ""  { ;
tokenize "`xfil'" ,  parse(".");
local xfil "`1'.xml" ;
cap erase  "`1'.xml" ;
cap winexec   taskkill /IM excel.exe ;
};


cap drop _merge;
qui merge n:1 `decile' using `felas';
cap drop _merge;

local  e_medium      `elasm';
local  e_low         `elasl';
local  e_upper       `elasu';

tokenize `varlist';
_nargs   `varlist';

if  `tjob1'==1 {;
tempname mat10;
qui mean `e_medium' `e_low' `e_upper' , over(decile);
tempname rtp ;
matrix `rtp' = r(table)' ;
matrix `mat10' = `rtp'[1..10,1..1],`rtp'[11..20,1..1],`rtp'[21..30,1..1] ;
matrix colnames `mat10' = Medium Low  Upper;
local myrownames Decile_1 Decile_2 Decile_3 Decile_4 Decile_5  Decile_6  Decile_7  Decile_8  Decile_9 Decile_10 ;
 matrix roweq `mat10'="";
 matrix coleq `mat10'="";
matrix colnames `mat10' = Medium Low  Upper;
matrix rownames `mat10' = `myrownames';
local title "Table 10: Price elasticities";
dismat_mod2 `mat10', dec(`dec') head1(`title');
tokenize `varlist';
_nargs   `varlist';

mk_xtab_tr `1' ,  matn(`mat10') dec(`dec') xfil(`xfil') xshe(table_10) xtit(`title') xlan(en) dste(0);

cap matrix drop `mat10';

};

if  `tjob2'==2 {;
ttrjob20 `1' `2'    , hs(`hsize') hgroup(`decile') lan(en) ;
tempname mat20 ;
matrix `mat20'= e(est);
local tabtit  "Table 20: Population and expenditures (in currency)";
matrix rownames  `mat20' = `myrownames' ;
dismat_mod2 `mat20', dec1(0) dec2(0) dec3(2) dec4(0) dec5(2) dec6(2)   atit(`langr') head1(`tabtit')  head2(`head2') ;
mk_xtab_tr `1' ,  matn(`mat20') dec(`dec')          xfil(`xfil') xshe(table_20) xtit(`tabtit') xlan(en) dste(0) dec1(0) dec2(0) dec3(2) dec4(0) dec5(2) dec6(2) control(2);
cap matrix drop `mat20';

};

#delimit cr

tempvar cig
qui gen       `cig' = (`2'!=0 & `2'!=.)
tempvar prop_cig
qui gen `prop_cig'=`2'/`1'	 

 
tempvar temp1 temp2  smokers_w
qui egen double `temp1' = total(`hweight'*`cig'), by(`decile')
qui egen double `temp2' = total(`hweight'*`cig')
qui gen `smokers_w' = `temp1'/`temp2'

/*
cap drop _merge
qui merge n:1 `decile' using `felas'
cap drop _merge
*/

tempvar totalexp_sum dec_s_w
egen  double `totalexp_sum'   =  total(`hweight'*`1'), by(`decile')
egen  double `dec_s_w'        =  total(`hweight')    , by(`decile')

tempvar ndecile
    bys decile: egen `ndecile'=sum(`hweight'*`hsize')
	
tempvar loss_passt 
	qui gen `loss_passt' = (1-(1+`princ')*(1))*`prop_cig'*100    			   // effect Price Increase - complete pass-through 
	

tempvar reduction_medium reduction_low reduction_upper

	local baselist1 low medium upper 
	foreach name of local baselist1  {
	tempvar  reduction_`name' loss_`name'
	qui gen `loss_`name''                   = (1-(1+`princ')*(1+`princ'*`e_`name''))*`prop_cig'*100
    qui gen `reduction_`name''              = (1-(1-`princ'*`e_`name''))
	}

*===============================================================================================
*                                  2: Final Tables                                              
*===============================================================================================
forvalues i=1/4 {
if "`gjob`i''"=="" | "`gjob`i''"=="off" local gjob`i' = -1 
}

forvalues i=1/6 {
if "`tjob`i''"=="" | "`tjob`i''"=="off" local tjob`i' = -1 
}


tempname varx 
matrix `varx' = (1 \2 \3 \4 \5 \6 \7 \8 \9 \10)
local mylist loss_passt loss_low loss_medium loss_upper 
local tit1 passt
local tit2 low 
local tit3 medium 
local tit4 upper 
if  `tjob3'==3 | `gjob1'==1 {
local i = 1
foreach name of local mylist {
cap drop `v1'
tempvar v1
    qui gen `v1' = ``name''*`1'  
	qui svy: ratio `v1'/`1' , over(`decile')
	tempname mat1_`i' tempo
	matrix `tempo' = r(table)'
	matrix `mat1_`i'' = `tempo'[.,1..2],`tempo'[.,5..6]
   local i = `i'+1
	}
    tempname summary1 gmat1
	matrix   `summary1' = `mat1_1'[.,1..1],`mat1_2'[.,1..1],`mat1_3'[.,1..1],`mat1_4'[.,1..1]
	matrix   `gmat1'    = `varx',`mat1_1'[.,1..1],`mat1_1'[.,3..4],`mat1_2'[.,1..1],`mat1_2'[.,3..4],`mat1_3'[.,1..1],`mat1_3'[.,3..4],`mat1_4'[.,1..1],`mat1_4'[.,3..4]
		 
	
		
	 matrix colnames `summary1' = Passt Low Medium Upper
	 matrix roweq    `summary1'=""
	 matrix coleq    `summary1'=""
     matrix rownames `summary1' = `myrownames' 
	 
	local title "Table 30: Price increase (summary estimate in %)"
	if  `tjob3'==3 dismat_mod2 `summary1', dec(`dec') head1(`title')
	if  `tjob3'==3 mk_xtab_tr `1' ,  matn(`summary1') dec(`dec') xfil(`xfil') xshe(table_30) xtit(`title') xlan(en) dste(0)
	local i = 1
	foreach name of local mylist {
   local title "Table 3`i': Price increase (`tit`i'' estimate in %)"
   matrix roweq `mat1_`i''="" 
   matrix coleq `mat1_`i''=""  
   matrix rownames `mat1_`i'' = `myrownames'
   matrix colnames `mat1_`i'' = Estimate STE LB UB
   
   if (`tjob3'==3 & `ste'==1)  {
   dismat_mod2 `mat1_`i'',  dec(`dec') head1("`title'")
    mk_xtab_tr `1' ,  matn(`mat1_`i'') dec(`dec') xfil(`xfil') xshe(table_3`i') xtit(`title') xlan(en) dste(0)
   
   }
   local i = `i'+1
	}
	
	}
/***************************/

local basiclist1 low medium upper

forvalues i=1/3 {
local v = `i'+1
tempname summary_`i'  gmat`v'
matrix `gmat`v'' = `varx'
}

local j = 1
foreach name1 of local basiclist1 {

forvalues d=1/10 {
tempvar vv0 vv00 vv11 vv12 vv13 vv2 vv3 vv4
 gen double `vv0'  = `loss_`name1''*`1' *(`decile'==`d') 
 gen double `vv00' = `1' *(`decile'==`d')*100
 gen double `vv11' = -`reduction_`name1''*`medexp'*`cig'*(`decile'==`d')
 gen double `vv12' = -`reduction_`name1''*`tyll'*`cig'*(`decile'==`d')
 gen double `vv13' = (1-(1+`princ')*(1+`princ'*`e_`name1''))*`prop_cig'*(`decile'==`d')
 gen double `vv2' = `cig' 
 gen double `vv3' = `1'*(`decile'==`d') 
 gen double `vv4' = `hsize'*(`decile'==`d') 
  if  (`tjob4'==4 |  `tjob5'==5 | `tjob6'==6 | `gjob2'==2 |  `gjob3'==3 | `gjob4'==4 ) qui svy: total  `vv0' `vv00'  `vv11' `vv12' `vv13'  `vv2' `vv3' `vv4' 
  
 if    `tjob4'==4 |  `gjob2'==2  {
 qui nlcom   ( _b[`vv11'] ) / ( _b[`vv2'] * _b[`vv3']) , iterate(40000) 
 local est=el(r(b),1,1)*100
local se=el(r(V),1,1)^0.5*100
local lb=(el(r(b),1,1)-1.96*el(r(V),1,1)^0.5)*100
local ub=(el(r(b),1,1)+1.96*el(r(V),1,1)^0.5)*100
if `d'==1   matrix resu1=(`est',`se',`lb',`ub')
if `d'!=1   matrix resu1= resu1\(`est',`se',`lb',`ub')
}

if    `tjob5'==5 |  `gjob3'==3  {
 qui nlcom   ( _b[`vv12'] ) / ( _b[`vv2'] * _b[`vv4']) , iterate(40000) 
 
 local est=el(r(b),1,1)*100
local se=el(r(V),1,1)^0.5*100
local lb=(el(r(b),1,1)-1.96*el(r(V),1,1)^0.5)*100
local ub=(el(r(b),1,1)+1.96*el(r(V),1,1)^0.5)*100
if `d'==1   matrix resu2=(`est',`se',`lb',`ub')
if `d'!=1   matrix resu2= resu2\(`est',`se',`lb',`ub')
}
if   `tjob6'==6 |  `gjob4'==4  {
qui nlcom   ( _b[`vv0']/ _b[`vv00'] )  + ( _b[`vv11'] ) / ( _b[`vv2'] * _b[`vv3']) + ( _b[`vv12'] ) / ( _b[`vv2'] * _b[`vv4']) , iterate(40000) 
local est=el(r(b),1,1)*100
local se=el(r(V),1,1)^0.5*100
local lb=(el(r(b),1,1)-1.96*el(r(V),1,1)^0.5)*100
local ub=(el(r(b),1,1)+1.96*el(r(V),1,1)^0.5)*100
if `d'==1   matrix resu3=(`est',`se',`lb',`ub')
if `d'!=1   matrix resu3= resu3\(`est',`se',`lb',`ub')
}
}


   forvalues h=1/3 {
   local v=`h'+1
   local z=`h'+3
   if `tjob`z''==`z' | `gjob`v''==`v'  {
    tempname mat2_`h'_`j'
    matrix `mat2_`h'_`j'' = resu`h'
    *matrix list `mat2_`h'_`j''
	if `j'==1 matrix `summary_`h'' = `mat2_`h'_`j''[.,1..1]
	if `j'!=1 matrix `summary_`h'' = `summary_`h'',`mat2_`h'_`j''[.,1..1]
	 matrix   `gmat`v''    = `gmat`v'',`mat2_`h'_`j''[.,1..1],`mat2_`h'_`j''[.,3..4]
	 }
    }
	local j = `j'+1
	}
	
	
local main_tit_1 "Medical expenses"   
local main_tit_2 "Life lost"  
local main_tit_3 "Total net loss"

local tit1 low 
local tit2 medium 
local tit3 upper 

	
	
local i = 1
local basiclist0 medical_expenses_  years_loss_   t_net_loss_tobacco_
foreach name0 of local basiclist0 {
local k = `i'+3
if `tjob`k'' == `k' {
local title "Table `k'0: `main_tit_`i'' (summary estimate in %)"
matrix colnames `summary_`i'' = Low  Medium  Upper
matrix roweq    `summary_`i''=""
matrix coleq    `summary_`i''=""
matrix rownames `summary_`i'' = `myrownames'
dismat_mod2     `summary_`i'', dec(`dec') head1(`title')
 mk_xtab_tr `1' ,  matn(`summary_`i'') dec(`dec') xfil(`xfil') xshe(Table_`k'0) xtit(`title') xlan(en) dste(0)
if (`ste'==1) {
local j = 1 
foreach name1 of local basiclist1 {
local title "Table `k'`j': `main_tit_`i'' (`tit`j'' estimate in %)"
 	matrix colnames  `mat2_`i'_`j'' = Estimate STE LB UB
	matrix rownames  `mat2_`i'_`j'' = `myrownames'
 dismat_mod2 `mat2_`i'_`j'',  dec(`dec') head1("`title'")
 mk_xtab_tr `1' ,  matn(`mat2_`i'_`j'') dec(`dec') xfil(`xfil') xshe(Table_`k'`j') xtit(`title') xlan(en) dste(0)  
local j = `j'+1
}
}
}
local i = `i'+1
}

	

#delimit ;



/********* The graphs *********************/

cap rmdir Graphs;
cap mkdir "`folgr'\Graphs";
local mygrdir "`folgr'\Graphs\" ;

if ( "`gjobs'"~="off" ) {;
forvalues i=1/`ngraphs' {;
set matsize 800;

local cprinc= `princ'*100;
if ("`gjob`i''" == "1" ) {;
set tracedepth 1;
*set trace on;
cmnpe `gmat1',  min(0) max(10) band(1.0) 
title("Figure 01: Income Gains: Direct Effect of Taxes") 
subtitle(" (Increase of expenditure due to tobacco tax)") 
ytitle("Income Gains (%)") 
note("Source: Author̳ estimation using a price shock of `cprinc'%")  
lab1("Direct pass through")
lab2("Lower Bound Elasticity")  
lab3("Medium Bound Elasticity")  
lab4("Upper Bound") 
;

 qui graph save           "`mygrdir'Fig_`gjob`i''.gph" , replace ;
 qui graph export         "`mygrdir'Fig_`gjob`i''.emf"  , replace ;
 qui cap graph export     "`mygrdir'Fig_`gjob`i''.pdf"  ,  as(pdf) replace ;

};


if ("`gjob`i''" == "2" ) {;
set tracedepth 1;
*set trace on;
cmnpe `gmat2',  min(0) max(10) band(1.0) 
title("Figure 02: Income Gains: Medical Costs of Tobacco Taxes")  
subtitle("(Reduction of Medical Expenditures)")  
xtitle("Decile") 
ytitle("Income Gains (%)") 
note("Source: Author̳ estimation using a price shock of `cprinc'%") 
lab1("Lower Bound Elasticity")  
lab2("Medium Bound Elasticity")  
lab3("Upper Bound") 
;
 qui graph save           "`mygrdir'Fig_`gjob`i''.gph" , replace ;
 qui graph export         "`mygrdir'Fig_`gjob`i''.emf"  , replace ;
 qui cap graph export     "`mygrdir'Fig_`gjob`i''.pdf"  ,  as(pdf) replace ;
 
};



if ("`gjob`i''" == "3" ) {;
set tracedepth 1;
*set trace on;
cmnpe `gmat3',  min(0) max(10) band(1.0) 
title("Figure 03: Income Gains: Life lost")   
subtitle("(Production during years lost by income decile)") 
xtitle("Decile") 
ytitle("Income Gains (%)") 
note("Source: Author̳ estimation using a price shock of `cprinc'%") 
lab1("Lower Bound Elasticity")  
lab2("Medium Bound Elasticity")  
lab3("Upper Bound") 
;
 qui graph save           "`mygrdir'Fig_`gjob`i''.gph" , replace ;
 qui graph export         "`mygrdir'Fig_`gjob`i''.emf"  , replace ;
 qui cap graph export     "`mygrdir'Fig_`gjob`i''.pdf"  ,  as(pdf) replace ;
 
};


if ("`gjob`i''" == "4" ) {;
set tracedepth 1;
*set trace on;
cmnpe `gmat4',  min(0) max(10) band(1.0) 
title("Figure 04: Total Income Effect: Direct and Indirect Effect of Taxes")  
subtitle("(tobacco price increase, medical expenditure and life lost gained)")
xtitle("Decile") 
ytitle("Income Gains (%)") 
note("Source: Author̳ estimation using a price shock of `cprinc'%") 
lab1("Lower Bound Elasticity")  
lab2("Medium Bound Elasticity")  
lab3("Upper Bound") 
;
 qui graph save           "`mygrdir'Fig_`gjob`i''.gph" , replace ;
 qui graph export         "`mygrdir'Fig_`gjob`i''.emf"  , replace ;
 qui cap graph export     "`mygrdir'Fig_`gjob`i''.pdf"  ,  as(pdf) replace ;
 
};

};

};


cap drop __nevar*;
if  ("`xfil'" ~= "" &  "`tjobs'"~="off" ) | ("`xfil'" ~= "") {;
cap !start "" /min "`xfil'" ; 
};
end;



