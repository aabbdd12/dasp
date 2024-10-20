#delimit ;
cap program drop tsateng;
program define tsateng, eclass;
syntax varlist (min=1 max=1) [,  
listf(varlist) 
listm(varlist) 
hhtype(varname) 
EXPEXM(varname)
EXPEXF(varname)
EXPEXK(varname)  
TEXPSHM(varname) 
TEXPSHF(varname) 
TEXPSHK(varname)
];
preserve;
tokenize `varlist';
tempvar  totexp;
qui gen `totexp' = `1';
cap drop gen _lnexp ;
qui gen _lnexp = log(`1');
tempvar expexa ;
qui gen  `expexa' = `expexm'+`expexf';

tempvar expexa  texpsha;
qui gen  `expexa'  =  `expexm'+`expexf';
qui gen  `texpsha' = `texpshm'+`texpshf';

local list1sure0  
__d_0 __d_1 __d_2 __d_3
 _lnexp_0  _lnexp_1 _lnexp_2 _lnexp_3 
 ;

local list1sure  
__d_0 __d_1 __d_2 __d_3
 _lnexp_0 _lnexp2_0 
 _lnexp_1 _lnexp_2 
 _lnexp_3 _lnexp2_1 
 _lnexp2_2 _lnexp2_3 
 ;
 
 
 

 
foreach name of local listf {;
local clistf `clistf' `name'_* ;
};
foreach name of local listm {;
local clistm `clistm' `name'_* ;
};



/* prepare polynomial and interactions */
forvalues i=1/3 {;
local j = `i'+1;
cap drop _lnexp`j';
gen _lnexp`j'=_lnexp^`j';
cap drop _kid`i';
qui gen _kid`i'=(`hhtype'==`i');
};

/* interaction terms */
forvalues k=0(1)3 {;	
cap drop __d_`k';
qui gen  __d_`k' =  (`hhtype'==`k');
};

local myvarlist _lnexp _lnexp2 `listf' `listm' ;
foreach name of local myvarlist { ;
forvalues k=0(1)3 {;	
cap drop `name'_`k';
qui gen  `name'_`k'     =`name'*(`hhtype'==`k')	;
};
};

cap drop _lnexp_123;
qui gen _lnexp_123 =_lnexp*(`hhtype'>0);
cap drop _lnexp2_123;
qui gen _lnexp2_123=_lnexp2*(`hhtype'>0);
cap drop _d123;
qui gen _d123       =(`hhtype'>0);



/*
*-----------------  test RG**, SAP and RG
* RG** = Rothbarth-Gronau** with nonparam, i.e. similarity of complete basic budget share
* SAP = SAP (Dunbar et al.)
* RG = Rothbarth-Gronau
*/

local carlist a f m k;
foreach g of local carlist {;
tempvar sh`g';
quiet gen `sh`g''=`expex`g''/(`texpsh`g''*`totexp');
};



 
/* SURE AND TEST 0 AGAINST 1, 2, 3 SEPARATELY*/
quiet sureg (`shf' `list1sure' , nocons) (`shm' `list1sure', nocons) ;
local lista1  _lnexp _lnexp2  __d;  /* manque _lnexp2 ? */

forvalues m=1/3 {;
local commandm "qui test ";
local commandf "qui test ";
foreach name of local  lista1 {;
local commandm `commandm' ([`shm']`name'_0=[`shm']`name'_`m');
};
`commandm';

local np_sat_mquad_`m'=round(r(p)*1000)/1000;
foreach name of local  lista1 {;
local commandf `commandf' ([`shf']`name'_0=[`shf']`name'_`m');
};
`commandf';
local np_sat_fquad_`m'=round(r(p)*1000)/1000;
};



tempname rmat0 ;
matrix define  `rmat0' = ///
( `np_sat_fquad_1'  , `np_sat_mquad_1'       \ /// 
  `np_sat_fquad_2'  , `np_sat_mquad_2'      \ /// 
  `np_sat_fquad_3'  , `np_sat_mquad_3'      ) ;

matrix rown  `rmat0' = Order_1  Order_2   Order_3 ;
matrix coln  `rmat0' = f m ;

/* SURE AND TEST 0 AGAINST 1, 2, 3 SEPARATELY as SEPARATE TESTS*/

quiet sureg (`shf' `list1sure', nocons) (`shm' `list1sure', nocons) ;



local shortl _lnexp  _lnexp2 __d;
local commandm "qui test ";
local commandf "qui test ";
foreach name of local  lista1 {;
forvalues m=1/3 {;
local commandm `commandm' ([`shm']`name'_0=[`shm']`name'_`m');
local commandf `commandf' ([`shf']`name'_0=[`shf']`name'_`m');
};
`commandf';
local np_sat_fqua__d_`name' = round(r(p)*1000000)/1000000;
`commandm';
local np_sat_mqua__d_`name' = round(r(p)*1000000)/1000000;
};



#delimit cr
tempname rmat1
matrix define  `rmat1' = ///
( `np_sat_mqua__d__lnexp'  , `np_sat_fqua__d__lnexp'       \ /// 
  `np_sat_mqua__d__lnexp2' , `np_sat_fqua__d__lnexp2'      \ /// 
  `np_sat_mqua__d___d'     , `np_sat_fqua__d___d'      ) 


matrix rown  `rmat1' = lnexp lnexp2 d
matrix coln  `rmat1' = f m 


/* SURE AND TEST 0 AGAINST 1, 2, 3 SEPARATELY as SEPARATE TESTS*/
#delimit ;

/*
test 
([sh_`i'_m]age_m1_0=[sh_`i'_m]age_m1_`m') 
([sh_`i'_f]age_m2_0=[sh_`i'_f]age_m2_`m') 
([sh_`i'_f]nuclear_0=[sh_`i'_f]nuclear_`m') 
([sh_`i'_m]nuclear_0=[sh_`i'_m]nuclear_`m')  
([sh_`i'_f]urban_0=[sh_`i'_f]urban_`m') 
([sh_`i'_m]urban_0=[sh_`i'_m]urban_`m') 
([sh_`i'_f]lnexp_0=[sh_`i'_f]lnexp_`m') 
([sh_`i'_f]d0=[sh_`i'_f]d`m') 
([sh_`i'_m]lnexp_0=[sh_`i'_m]lnexp_`m') 
([sh_`i'_m]d0=[sh_`i'_m]d`m') 
([sh_`i'_m]lnexp2_0=[sh_`i'_m]lnexp2_`m')

qui test  
([__000009]agem1_0=[__000009]agem1_1) 
([__000009]urban_0=[__000009]urban_1) 
([__000009]nuclear_0=[__000009]nuclear_1) 
([__000009]_lnexp_0=[__000009]_lnexp_1) 
([__000009]_lnexp2_0=[__000009]_lnexp2_1) 
([__000009]__d_0=[__000009]__d_1)

*/



quiet sureg 
(`shf' `clistf' `list1sure0', nocons) 
(`shm' `clistm' `list1sure0', nocons) 
;


local myflist_f `listf'  _lnexp    __d ;  //  erreur 2 manque  _lnexp2 
local myflist_m `listm'  _lnexp   __d ;
forvalues m=1/3 {;
local command`m' "qui test ";
foreach name of local  myflist_f {;
local command`m' `command`m'' ([`shf']`name'_0=[`shf']`name'_`m');
};
foreach name of local  myflist_m {;
local  command`m' `command`m'' ([`shm']`name'_0=[`shm']`name'_`m');
};
`command`m'';
dis "`command`m''";
local np_satlin_`m'=round(r(p)*1000000)/1000000;
};



quiet sureg 
(`shf' `clistf' `list1sure', nocons) 
(`shm' `clistm' `list1sure', nocons) 
;


local myflist_f `listf'  _lnexp  _lnexp2    __d ;  //  erreur 2 manque  _lnexp2 
local myflist_m `listm'  _lnexp   _lnexp2   __d ;
forvalues m=1/3 {;
local command`m' "qui test ";
foreach name of local  myflist_f {;
local command`m' `command`m'' ([`shf']`name'_0=[`shf']`name'_`m');
};
foreach name of local  myflist_m {;
local  command`m' `command`m'' ([`shm']`name'_0=[`shm']`name'_`m');
};
`command`m'';
dis "`command`m''";
local np_satquad_`m'=round(r(p)*1000000)/1000000;
};

tempname rmat2;
matrix define  `rmat2' = (
`np_satlin_1' ,`np_satquad_1'     \ 
`np_satlin_2', `np_satquad_2' \ 
`np_satlin_3' ,  `np_satquad_3'   ) ;


matrix rown  `rmat2' = "n=0 & n=1"  "n=0 & n=2" "n=0 & n=3"  ;
matrix coln  `rmat2' = "Linear" "Quadratic" ;

ereturn matrix rmat0 = `rmat0';
ereturn matrix rmat1 = `rmat1';
ereturn matrix rmat2 = `rmat2';
end;








