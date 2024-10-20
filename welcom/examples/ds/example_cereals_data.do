/*==========================================================================
project:       Cereals&Elasticities in Mexico
Author:        Araar, A. 
Dependencies:  World Bank
---------------------------------------------------------------------------
Creation Date:    17/08/2017
Modification Date:   
Do-file version:    01
References:          
Output:             dta

===========================================================================*/
set more off
version 14
clear all
global path_of_data_folder = "C:\PDATA\WB\Sergio\Mexico_Application\data"
cd $path_of_data_folder
/* To simply correct the appearance of the characters of the labels of the datafiles */
/*
unicode encoding set ISO-8859-1
unicode translate *.dta
*/

/* The datafile tra_concentrado_2014_concil_2010_stata.dta is the original published ENIGH household data files, with main 127 variables */
/* First, we change the labels of variables: Spanish to English */
use "ncv_concentrado_2014_concil_2010_stata", replace
merge 1:1 _n using lab_var.dta
count if var2 !=""
forvalues i=1/`r(N)' {
local a = var1[`i']
local b = var2[`i']
lab var `a' "`b'"
} 
cap drop _merge var1 var2
rename est_dis strata
save MY_HH_ENIGH_2014, replace


/* First, we use the hogar row datafile to construct some expenditures variables of interest */
use ncv_gastohogar_2014_concil_2010_stata.dta, replace
/* We replace the missing values by zeros */
replace gas_nm_tri =0 if gas_nm_tri==.
replace gasto_tri =0 if gasto_tri==.
replace gasto     =0 if gasto    ==. 
replace costo     =0 if costo    ==. 
gen gascos = gasto+costo

/* We keep the data for the items */

/*
*Cereal
CORN
A001 Grain corn
A002 Maize flour
A003 Mass of corn
A004 Corn tortilla
A005 Toast
A006 Other maize products

WHEAT
A007 Wheat flour
A008 Flour tortilla
A009 Pasta for soup
A010 Sweet cookies
A011 Crackers
A012 White bread: bolillo, telera, baguette, etc.
A013 Sweet bread in pieces
A014 Sweet bread packaged
A015 Bread for sandwich, hamburger, hot-dog and toasted
A016 Cakes and pastries in pieces or in bulk
A017 Packaged cakes and pastries
A018 Other Wheat Products

RICE
A019 Rice grain
A020 Other rice products

OTHER CEREALS
A021 Corn, wheat, rice, oat, granola, etc. cereal
A022 Botanas: fritters, popcorn, cheetos, doritos et cetera (except potatoes)
A023 Instant soups
A024 Other cereals
*/





local mylist A001 A002 A003 A004 A005 A006 A007 A008 A009 A010 A011 A012 A013 A014 A015 A016 A017 A018 A019 A020 A021 A022 A023 A024
local mylist1 A001 A002 A003 A004 A005 A006
local mylist2 A007 A008 A009 A010 A011 A012 A013 A014 A015 A016 A017 A018
local mylist3 A019 A020 
local mylist4 A021 A022 A023 A024 


gen tokeep = 0
foreach clave in A001 A002 A003 A004 A005 A006 A007 A008 A009 A010 A011 A012 A013 A014 A015 A016 A017 A018 A019 A020 A021 A022 A023 A024  {
	qui replace tokeep = 1 if clave=="`clave'"
}

*set trace on
keep if tokeep==1

foreach clave in A001 A002 A003 A004 A005 A006 A007 A008 A009 A010 A011 A012 A013 A014 A015 A016 A017 A018 A019 A020 A021 A022 A023 A024  {
    qui gen     hh_exp_`clave' =0
	qui gen     hh_qnt_`clave' =0
	qui gen     hh_cos_`clave' =0
	qui replace hh_exp_`clave'         = gasto_tri            if clave=="`clave'"
	qui replace hh_qnt_`clave'         = cantidad              if clave=="`clave'"
	qui replace hh_cos_`clave'         = gascos                if clave=="`clave'"
	qui replace hh_cos_`clave'         = 0                     if gascos==. &  clave=="`clave'"
	
}



gen hh_exp_corn= 0
gen hh_exp_wheat= 0
gen hh_exp_rice= 0
gen hh_exp_other= 0
foreach clave of local  mylist1 {
	qui replace hh_exp_corn         =  hh_exp_corn + hh_exp_`clave' 
}

foreach clave of local  mylist2 {
	qui replace hh_exp_wheat         = hh_exp_wheat   + hh_exp_`clave' 
}

foreach clave of local  mylist3 {
	qui replace hh_exp_rice         = hh_exp_rice   + hh_exp_`clave' 
}


foreach clave of local  mylist4 {
	qui replace hh_exp_other         = hh_exp_other  + hh_exp_`clave' 
}



keep  folioviv foliohog hh_exp_*  hh_cos_* hh_qnt_*
collapse (sum) hh_exp_*  hh_cos_*  hh_qnt_*  , by(folioviv foliohog)
save hogar_cer_data, replace





/* Second, we do the same thing with the personal row data */  

use ncv_gastopersona_2014_concil_2010_stata.dta, replace
replace gas_nm_tri =0 if gas_nm_tri==.
replace gasto_tri =0 if gasto_tri==.
replace gasto     =0 if gasto    ==. 
replace costo     =0 if costo    ==. 
gen gascos = gasto+costo


gen tokeep = 0
forvalues i=1/24 {
if `i' <=9 local tmp ="0`i'"
if `i' >=10 local tmp ="`i'"
qui replace tokeep = 1 if clave=="A0`tmp'"
}

#delimit ;
local mylist
 A001
 A002
 A003
 A004
 A005
 A006
 A007
 A008
 A009
 A010
 A011
 A012
 A013
 A014
 A015
 A016
 A017
 A018
 A019
 A020
 A021
 A022
 A023
 A024
;

local mylist1 A001 A002 A003 A004 A005 A006;
local mylist2 A007 A008 A009 A010 A011 A012 A013 A014 A015 A016 A017 A018;
local mylist3 A019 A020 ;
local mylist4 A021 A022 A023 A024 ;

#delimit cr
keep if tokeep==1



*set trace on

foreach clave of local  mylist {
    cap drop pr_exp_`clave'
    qui gen     pr_exp_`clave' =0
	 cap drop pr_qnt_`clave'
	qui gen     pr_qnt_`clave' =0
	 cap drop pr_cos_`clave'
	qui gen     pr_cos_`clave' =0
	
	
	qui replace pr_exp_`clave'         = gasto_tri            if clave=="`clave'"
	qui replace pr_qnt_`clave'         = cantidad             if clave=="`clave'"
	qui replace pr_cos_`clave'         = gascos               if clave=="`clave'"
	qui replace pr_cos_`clave'         = 0       if gascos==. &  clave=="`clave'"
	
}



gen pr_exp_corn= 0
gen pr_exp_wheat= 0
gen pr_exp_rice= 0
gen pr_exp_other= 0
foreach clave of local  mylist1 {
	qui replace pr_exp_corn         =  pr_exp_corn + pr_exp_`clave' 
}

foreach clave of local  mylist2 {
	qui replace pr_exp_wheat         = pr_exp_wheat   + pr_exp_`clave' 
}

foreach clave of local  mylist3 {
	qui replace pr_exp_rice         = pr_exp_rice   + pr_exp_`clave' 
}


foreach clave of local  mylist4 {
	qui replace pr_exp_other         = pr_exp_other  + pr_exp_`clave' 
}



keep  folioviv foliohog pr_exp_*  pr_cos_* pr_qnt_*
collapse (sum) pr_exp_* pr_cos_* pr_qnt_* , by(folioviv foliohog)

save perso_cer_data, replace


use hogar_cer_data, replace
merge 1:1 folioviv foliohog using perso_cer_data
drop _merge
foreach var of varlist pr_* hh_* {
qui replace `var'=0 if `var'==.
}



#delimit ;
local mylist
 A001
 A002
 A003
 A004
 A005
 A006
 A007
 A008
 A009
 A010
 A011
 A012
 A013
 A014
 A015
 A016
 A017
 A018
 A019
 A020
 A021
 A022
 A023
 A024
;

local mylist1 A001 A002 A003 A004 A005 A006;
local mylist2 A007 A008 A009 A010 A011 A012 A013 A014 A015 A016 A017 A018;
local mylist3 A019 A020 ;
local mylist4 A021 A022 A023 A024 ;

#delimit cr 



cap drop tot_cos
gen tot_cos = 0
local nlist exp qnt cos 

*set trace on
foreach  var of local  mylist {
foreach name of local nlist {
cap drop  `name'_`var'
gen `name'_`var' = hh_`name'_`var'+pr_`name'_`var'
drop hh_`name'_`var' pr_`name'_`var'
}
cap drop uval_`var'
gen uval_`var' = cos_`var' / qnt_`var'
qui replace uval_`var'=0 if uval_`var'==.
qui replace exp_`var'=0 if exp_`var'==.
replace tot_cos = tot_cos+ cos_`var'
}

local name1 "corn"
local name2 "wheat"
local name3 "rice"
local name4 "other"

/* We add to this data some other variables : like : rururb and ent */
cap drop _merge
merge 1:1 folioviv foliohog using "basic.dta"
drop if _merge!=3
drop _merge

merge 1:1 folioviv foliohog using "upm.dta"
drop if _merge!=3
drop _merge

merge 1:1 folioviv foliohog using "strata.dta"
drop if _merge!=3
drop _merge

*set trace on 
forvalues i=1/4 {
cap drop tot_cos_`i'
cap drop pr_`name`i''
gen tot_cos_`i'=0
gen pr_`name`i''=0

foreach  var of local  mylist`i' {

cap drop upm_cos_`var'
by  upm, sort : egen float upm_cos_`var' = mean(cos_`var') if cos_`var'>0
qui replace upm_cos_`var' = 0 if upm_cos_`var'==.

cap drop nupm_cos_`var'
by  upm, sort : egen float nupm_cos_`var' = max(upm_cos_`var')
qui replace cos_`var' = nupm_cos_`var' if cos_`var'==0

cap drop upm_uval_`var'
by  upm, sort : egen float upm_uval_`var' = mean(uval_`var') if uval_`var'>0  & uval_`var'!=0
qui replace upm_uval_`var' = 0 if upm_uval_`var'==.
cap drop nupm_uval_`var'
by  upm, sort : egen float nupm_uval_`var' = max(upm_uval_`var')
qui replace uval_`var'   = nupm_uval_`var' if uval_`var'==0

/*
cap drop strata_cos_`var'
by  strata, sort : egen float strata_cos_`var' = mean(cos_`var') if cos_`var'>0
qui replace strata_cos_`var' = 0 if strata_cos_`var'==.

cap drop nstrata_cos_`var'
by  strata, sort : egen float nstrata_cos_`var' = max(strata_cos_`var')
qui replace cos_`var' = nstrata_cos_`var' if cos_`var'==0

cap drop strata_uval_`var'
by  strata, sort : egen float strata_uval_`var' = mean(uval_`var') if uval_`var'>0  & uval_`var'!=0
qui replace strata_uval_`var' = 0 if strata_uval_`var'==.
cap drop nstrata_uval_`var'
by  strata, sort : egen float nstrata_uval_`var' = max(strata_uval_`var')
qui replace uval_`var'   = nstrata_uval_`var' if uval_`var'==0
*/

}



foreach  var of local  mylist`i' {
replace tot_cos_`i'=tot_cos_`i'+cos_`var'
}

foreach  var of local  mylist`i' {
replace pr_`name`i'' = pr_`name`i''+ (cos_`var'/tot_cos_`i')*uval_`var'
}
}

sum nupm_uval*
save Cereal_HH, replace



/* I use the published household data file and add the constructed expenditure variables */

use MY_HH_ENIGH_2014, replace 
merge 1:1 folioviv foliohog using Cereal_HH

foreach var of varlist exp_* {
qui replace `var'=0 if `var'==.
}



/* We add to this data some other variables : like : rururb and ent */
cap drop _merge
merge 1:1 folioviv foliohog using "basic.dta"
drop if _merge!=3
drop _merge


/* We generate the expenditures or incomes in month and per capita */
/* Note that the total/current  HH ingresos or gastos are in the published data file */
 
local mylist exp_* gasto_mon ing_cor 
foreach var of varlist `mylist' {
qui gen pc_`var' = `var' / (3*tot_integ)
}



/* I generate the poverty line, based on the coneval information */ 
gen pline=1614.65*(rururb==1)+2542.13*(rururb==0)

/* Initialising the SD */
svyset _n [pweight=factor_hog], vce(linearized) singleunit(missing)


*CORN
lab var pc_exp_A001 "Grain corn"
lab var pc_exp_A002 "Maize flour"
lab var pc_exp_A003 "Mass of corn"
lab var pc_exp_A004 "Corn tortilla"
lab var pc_exp_A005 "Toast"
lab var pc_exp_A006 "Other maize products"

*WHEAT
lab var pc_exp_A007 "Wheat flour"
lab var pc_exp_A008 "Flour tortilla"
lab var pc_exp_A009 "Pasta for soup"
lab var pc_exp_A010 "Sweet cookies"
lab var pc_exp_A011 "Crackers"
lab var pc_exp_A012 "White bread: bolillo, telera, baguette, etc."
lab var pc_exp_A013 "Sweet bread in pieces"
lab var pc_exp_A014 "Sweet bread packaged"
lab var pc_exp_A015 "Bread for sandwich, hamburger, hot-dog and toasted"
lab var pc_exp_A016 "Cakes and pastries in pieces or in bulk"
lab var pc_exp_A017 "Packaged cakes and pastries"
lab var pc_exp_A018 "Other Wheat Products"

*RICE
lab var pc_exp_A019 "Rice grain"
lab var pc_exp_A020 "Other rice products"

*OTHER CEREALS
lab var pc_exp_A021 "Corn, wheat, rice, oat, granola, etc. cereal"
lab var pc_exp_A022 "Botanas: fritters, popcorn, cheetos, doritos et cetera (except potatoes)"
lab var pc_exp_A023 "Instant soups"
lab var pc_exp_A024 "Other cereals"



forvalues i=1/4 {
gen pc_exp_`name`i'' = 0
foreach  var of local  mylist`i' {
replace pc_exp_`name`i''=pc_exp_`name`i''+pc_exp_`var' if pc_exp_`var'!=.
}
lab var pc_exp_`name`i'' "Per capita expenditures on `name`i''" 
}


/* Saving the basic file used in teh study */
cap drop decile
gen fw = factor_hog* tot_integ
xtile decile = pc_ing_cor [pweight = fw], nquantiles(10)
gen pc_exp_cereal = pc_exp_corn+ pc_exp_wheat+ pc_exp_rice
local name1 "corn"
local name2 "wheat"
local name3 "rice"
local name4 "other"
forvalues i=1/4 {
gen p`name`i'' = pr_`name`i''
}
replace  pc_exp_cereal = pc_exp_corn+ pc_exp_wheat+ pc_exp_rice+ pc_exp_other 
*keep folioviv foliohog ubica_geo ageb tam_loc est_socio est_dis upm factor* sexo_jefe pc_* tot_integ rururb ent
save Cereals_HH_ENIGH_2014, replace

use Cereals_HH_ENIGH_2014, replace
cap drop key
gen key = _n
cap drop hh_ing_cor
gen hh_ing_cor=(pc_ing_cor*tot_integ)
replace pc_exp_cereal = pc_exp_corn+pc_exp_wheat+pc_exp_rice+pc_exp_other
*set trace on
local mylist corn wheat rice other
foreach  name of local mylist  {
local tmp  = "p`name'"
cap drop luv`name'
gen double luv`name' = log(`tmp')

gen  double w`name' = (pc_exp_`name')/pc_ing_cor 
sum  w`name', d
drop if  w`name'>r(p95) 
}
gen  double wcomp = 1- wcorn-wwheat-wrice-wother
gen luvcomp=0
keep if wcorn!=.
#delimit ;

destring sexo_jefe, replace;
sort upm;
replace upm="10"+upm;
destring upm, replace;
destring  educa_jefe, replace;

sum upm educa_jefe luvcorn;
gen hh_exp_cereal = pc_exp_cereal*tot_integ;
#delimit ;
replace pc_exp_cereal = pc_exp_corn+pc_exp_wheat+pc_exp_rice+pc_exp_other;

keep folioviv foliohog ubica_geo factor_hog upm strata sexo_jefe edad_jefe educa_jefe tot_integ luv* w* p*  hh_ing_cor pc_gasto_mon rururb perc_ocupa;
order folioviv foliohog ubica_geo strata upm factor_hog sexo_jefe edad_jefe educa_jefe tot_integ luv* p* w*;
drop p12_64 p65mas percep_ing  pecuarios pesca pescado pred_cons publico paq_turist personales percep_tot prestamos prest_terc pago_tarje pc_exp_A* ;
count;
set seed 234;

gen pce = hh_ing_cor/ tot_integ;
gen fw= tot_integ* factor_hog;
xtile decile = pce [pweight = fw], nquantiles(10);
lab def ldecile
1 Decile_1
2 Decile_2
3 Decile_3
4 Decile_4
5 Decile_5
6 Decile_6
7 Decile_7
8 Decile_8
9 Decile_9
10 Decile_10
;
lab val decile ldecile;

drop pce fw;
rename folioviv hhid;
rename ubica_geo geo_loc;
*rename est_dis strata;
rename upm psu;
rename factor_hog sweight;
rename sexo_jefe sex;
rename edad_jefe age;
rename educa_jefe educ;
rename tot_integ hhsize;
rename hh_ing_cor hh_current_inc;
#delimit ;
rename pc_ing_cor pc_current_inc;
save "Mexico_cereal_2014.dta" , replace;
replace sex = sex-1;
drop pr_*;
drop pline;
save "Mexico_cereal_2014.dta" , replace;





#delimit ;
use Mexico_cereal_2014.dta, replace; 
cap drop pcomp;
gen pcomp = 1;
local mylist corn wheat rice other comp ;
foreach var of local mylist {;
lab var luv`var' "log of the unit value  of corn"; 
lab var p`var'   "the price (unit value) of corn";
lab var w`var'   "expenditure share of corn";  
};
lab var hh_current_inc "Household current income";
lab var rururb "Living household area";
order foliohog hhid geo_loc strata psu sweight sex age educ hhsize hh_current_inc decile rururb;

*replace educ=7 if educ>7;
lab def leduc
1 "Without instruction"
2 Preschool
3 "Elementary incomplete"
4 "Complete primary"
5 "Incomplete Secondary"
6 "Secondary complete"
7 "Incomplete high school"
8 "High School"
9 "Incomplete professional"
10 "Full professional"
11 Postgraduate
;
lab val educ leduc;
#delimit ; 
forvalues i=1/11 {;
gen educa`i' = educ==`i';
};

qui replace perc_ocupa=4 if perc_ocupa>4;
#delimit ; 
forvalues i=0/4 {;
gen nocup`i' = perc_ocupa==`i';
};

lab var nocup0 "No person receiving income";
lab var nocup1 "One person receiving income";
lab var nocup2 "Two persons receiving income";
lab var nocup3 "Three persons receiving income";
lab var nocup4 "Four persons or more receiving income";


lab var educa1 "Without instruction";
lab var educa2 Preschool;
lab var educa3 "Elementary incomplete";
lab var educa4 "Complete primary";
lab var educa5 "Incomplete Secondary";
lab var educa6 "Secondary complete";
lab var educa7 "Incomplete high school";
lab var educa8 "High School";
lab var educa9 "Incomplete professional";
lab var educa10 "Full professional";
lab var educa11 " Postgraduate";

lab def lsex 0 Male 1 Female;
lab val sex lsex;
drop pc_gasto_mon pc_current_inc;
lab var pc_exp_cereal "Per capita expenditures on cereal products";
gen isMale = sex==0;
label var isMale "Male household head";
save Mexico_2014_Cereals.dta , replace;  

