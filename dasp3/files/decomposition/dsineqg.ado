
/*************************************************************************/
/* The dsineqg Stata module                                              */
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/




#delim ;

capture program drop nargs;
program define nargs, rclass;
version 9.2;
syntax varlist(min=0);
quietly {;
tokenize `varlist';
local k = 1;
mac shift;
while "``k''" ~= "" {; 
local k = `k'+1 ;
};
};
global indica=`k';
end;



cap program drop dsineqg2_gini; 
program define dsineqg2_gini, rclass;
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
local ineq = 1 - `xi'/`mu';
restore; 
};
return scalar ineq = `ineq';
return scalar mu   = `mu'  ;
end;


#delim ;
cap program drop dsineqg2_atk;
program define dsineqg2_atk, rclass;
syntax varlist(min=1 max=1) [, FWeight(varname) epsilon(real 0.5)];
version 9.2;
tokenize `varlist';
preserve;
tempvar fw;
qui gen `fw'=`fweight';
qui sum `1' [aw=`fw']; local mu = `r(mean)';

tempvar vec_a vec_b vec_c;
gen   `vec_b' = `fw';      qui sum  `vec_b', meanonly; local  ws2 = `r(mean)';          
gen   `vec_c' = `fw'*`1';  qui sum  `vec_c', meanonly; local  ws3 = `r(mean)';  

if ( `epsilon' != 1.0 ) {;
gen      `vec_a' = `fw'*`1'^(1-`epsilon');    qui sum  `vec_a', meanonly; local  ws1 = `r(mean)'; 
local ineq =  1 - (`ws1')^(1/(1-`epsilon'))*(`ws2')^(1+(1/(`epsilon'-1)))/(`ws3');          
};

if ( `epsilon' == 1.0)  {;
gen   `vec_a' = `fw'*log(`1'); 
qui sum  `vec_a', meanonly; local  ws1 = `r(mean)';       
local ineq =  1- exp(`ws1'/`ws2')*(`ws2'/`ws3');
};



return scalar ineq = `ineq';
return scalar mu   = `mu'  ;
restore; 

end;


#delim ;
cap program drop dsineqg2_cvar;
program define dsineqg2_cvar, rclass;
syntax varlist(min=1 max=1) [, FWeight(varname)];
version 8.0;
tokenize `varlist';
qui {;
preserve;
tempvar fw;
qui gen `fw'=`fweight';
qui sum `1' [aw=`fw']; local mu = `r(mean)';
tempvar vec_a vec_b vec_c;
gen   `vec_a' = `fw'*`1'^2;    qui sum  `vec_a', meanonly; local  ws1 = `r(mean)'; 
gen   `vec_b' = `fw';          qui sum  `vec_b', meanonly; local  ws2 = `r(mean)';          
gen   `vec_c' = `fw'*`1';      qui sum  `vec_c', meanonly; local  ws3 = `r(mean)';  
local ineq  =  (`ws1'*`ws2'/`ws3'^2-1)^0.5;
restore; 
};
return scalar ineq = `ineq';
return scalar mu   = `mu'  ;
end;


#delim ;
cap program drop dsineqg2_ge;
program define dsineqg2_ge, rclass;
syntax varlist(min=1 max=1) [, FWeight(varname) theta(real 0.5)];
version 8.0;
tokenize `varlist';
qui {;
preserve;
tempvar fw;
qui gen `fw'=`fweight';
qui sum `1' [aw=`fw']; local mu = `r(mean)';

tempvar vec_a vec_b vec_c;
   
gen   `vec_b' = `fw';      qui sum  `vec_b', meanonly; local  ws2 = `r(mean)';          
gen   `vec_c' = `fw'*`1';  qui sum  `vec_c', meanonly; local  ws3 = `r(mean)';  

if ( `theta' !=  0 & `theta' != 1 ) {;
gen   `vec_a' = `fw'*`1'^`theta';   
qui sum  `vec_a', meanonly; local  ws1 = `r(mean)';  
local ineq= ( 1/(`theta'*(`theta'-1) ) )*((`ws1'/`ws2')/((`ws3'/`ws2')^`theta') - 1);
};


if ( `theta' ==  0) {;
tempvar vec_a vec_b vec_c;
gen      `vec_a' = `fw'*log(`1');    
qui sum  `vec_a', meanonly; local  ws1 = `r(mean)';  
local ineq=log(`ws3'/`ws2')-`ws1'/`ws2'; 
};


if ( `theta' ==  1) {;
gen   `vec_a' = `fw'*`1'*log(`1');    
qui sum  `vec_a', meanonly; local  ws1 = `r(mean)';              
local ineq=(`ws1'/`ws3')-log(`ws3'/`ws2');
};

restore; 
};
return scalar ineq = `ineq';
return scalar mu   = `mu'  ;
end;




capture program drop dsineqg;
program define dsineqg, eclass;
syntax varlist (min=1 max=1) [, HGroup(varname) HSize(varname) 
INDEX(string) EPSilon(real 0.5) THETA(real 0.5)  DEC(int 6) ] ;
version 9.2;
timer clear 1;
timer on 1;


if ("`index'"=="")           local index="gini";



if ("`hgroup'"!="") {;
preserve;

capture {;

local lvgroup:value label `hgroup';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , replace;
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
tokenize  `varlist';
_nargs    `varlist';
preserve;
};






cap svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local ll=length("`1': `grlab`1''");

local hweight="";
cap qui svy: total `1' set more off;
local hweight=`"`e(wvar)'"';
cap ereturn clear;
tempvar fw;
quietly{;
gen `fw'=1;
if ("`hsize'"  ~="")     replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")     replace `fw'=`fw'*`hweight';
};


tempvar _muk;
qui gen `_muk'=0;

qui count;

qui sum `fw';
local suma = `r(sum)';



local ll=0;

 tokenize `varlist';



if ("`index'"=="atk" & `epsilon' == 1) {;
tempvar mark;
qui gen `mark'=1;
forvalues j=1/$indica {;
qui replace `mark' = 0 if `1'==0;
};
qui count if `mark'==0;
if `r(N)'>0 dis "Warning: `r(N)' will be omitted: Atkinson index (epsilon==`epsilon') is not defined with zero values."; 
qui drop if `mark'==0;
}; 

if ("`index'"=="ge" & (`theta' == 0 | `theta' == 0 ) ) {;
tempvar mark;
qui gen `mark'=1;
forvalues j=1/$indica {;
qui replace `mark' = 0 if `1'==0;
};
qui count if `mark'==0;
if `r(N)'>0 dis "Warning: `r(N)' will be omitted: Generalized entropy index (theta==0) is not defined with zero values."; 
qui drop if `mark'==0;
}; 

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

tempvar hw; 
qui gen `hw'=1; 
if ("`hweight'"~="") qui replace `hw'=`hweight';

tempvar fw;
qui gen `fw'=1;
qui replace `fw'=`fw'*`hw';
tempvar hs;
qui gen `hs'=1;
if ("`hsize'"~="")   qui replace `hs'=`hsize';
qui replace `fw'=`fw'*`hs'; 


tempvar mu muk mu_muk t1 tt1 t2 tt2;


gen `t1' = `fw'*`1';
gen `t2' = `fw';
tempvar _key;
gen `_key' = _n;
qui by `hgroup', sort : egen double `tt1'  = total(`t1');
qui by `hgroup', sort : egen double `tt2'  = total(`t2');
sort `_key', stable;

qui gen `muk' = `tt1'/`tt2';
qui sum `1' [aw=`fw'], meanonly;
gen `mu' = `r(mean)';
gen `mu_muk' = `1'*`mu'/`muk';



if ("`index'"=="gini") {;
qui dsineqg2_gini `1', fweight(`fw');
local c1 = `r(ineq)';
qui dsineqg2_gini `muk', fweight(`fw');
local c2 = `r(ineq)';
qui dsineqg2_gini `mu_muk', fweight(`fw');
local c3 = `r(ineq)';
};
if ("`index'"=="cvar") {;
qui dsineqg2_cvar `1', fweight(`fw');
local c1 = `r(ineq)';
qui dsineqg2_cvar `muk', fweight(`fw');
local c2 = `r(ineq)';
qui dsineqg2_cvar `mu_muk', fweight(`fw');
local c3 = `r(ineq)';
};

if ("`index'"=="atk") {;
 qui dsineqg2_atk `1', fweight(`fw') epsilon(`epsilon');

local c1 = `r(ineq)';
qui dsineqg2_atk `muk', fweight(`fw') epsilon(`epsilon');
local c2 = `r(ineq)';
qui dsineqg2_atk `mu_muk', fweight(`fw') epsilon(`epsilon');
local c3 = `r(ineq)';
 };
if ("`index'"=="ge")  {;
  qui dsineqg2_ge `1', fweight(`fw')  theta(`theta');
local c1 = `r(ineq)';
qui dsineqg2_ge `muk', fweight(`fw')  theta(`theta');
local c2 = `r(ineq)';
qui dsineqg2_ge `mu_muk', fweight(`fw') theta(`theta');
local c3 = `r(ineq)';
 };

local vindex = `c1';
local inter = 0.5*(`c1'-`c3'+`c2'-0);
local intra = 0.5*(`c1'-`c2'+`c3'-0);
local rinter = `inter' / `vindex' ;
local rintra = `intra' / `vindex' ;




shapar $indica;




tempvar vv1 vv2   ;





cap drop _shav;
qui gen  _shav=0;

tempvar Group INCS  ABSC  RELC;
qui gen `Group'="";
qui gen `INCS'=0;
qui gen `ABSC'=0;
qui gen `RELC'=0;


forvalues i=1/$shasize {;

cap drop `vv1';
cap drop `vv2';
gen `vv1' = `1';
gen `vv2' = `1'*`mu'/`muk';
cap drop `inco';
tempvar inco;
gen `inco'=0;

forvalues j=1/$indica {;
local kk = gn1[`j'];
qui replace `vv1' = `muk' if (_o`j'[`i'] == .) & `hgroup'==`kk';
qui replace `vv2' = `mu'  if (_o`j'[`i'] == .) & `hgroup'==`kk';
};


if ("`index'"=="gini") {;
qui dsineqg2_gini `vv1', fweight(`fw');
local c1 = `r(ineq)';
qui dsineqg2_gini `vv2', fweight(`fw');
local c3 = `r(ineq)';

};
if ("`index'"=="cvar") {;
qui dsineqg2_cvar `vv1', fweight(`fw');
local c1 = `r(ineq)';
qui dsineqg2_cvar `vv2', fweight(`fw');
local c3 = `r(ineq)';
};

if ("`index'"=="atk") {;
qui dsineqg2_atk `vv1', fweight(`fw') epsilon(`epsilon');
local c1 = `r(ineq)';

qui dsineqg2_atk `vv2', fweight(`fw') epsilon(`epsilon');
local c3 = `r(ineq)';
 };
if ("`index'"=="ge")  {;
  qui dsineqg2_ge `vv1', fweight(`fw')  theta(`theta');
local c1 = `r(ineq)';

qui dsineqg2_ge `vv2', fweight(`fw') theta(`theta');
local c3 = `r(ineq)';
 };


local mintra = 0.5*(`c1'-`c2'+`c3'-0);
qui replace _shav = `mintra' in `i';

                                               
};


local ll=24;


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

local kk = gn1[`k'];
if ( "`grlab`kk''" == "") local grlab`kk' = "Group_`kk'";
qui replace `Group' = "`kk': `grlab`kk''" in `k';
local ll=max(`ll',length("`kk': `grlab`kk''"));



local k1= (`k'-1)+1;




qui sum ``k'' [aw=`fw']; 


tempvar shav; qui gen `shav'=0;
qui replace `shav'         =  _shav*_shapwe`k';
qui sum `shav';
qui replace `ABSC'         = `r(sum)'               in `k1';
qui replace `RELC'         = `r(sum)'/(`vindex')     in `k1';

};





timer off 1;
qui timer list 1;
local ptime = `r(t1)';

local ka=`k1'+2;
local kb=`k1'+3;
qui replace `Group'     = "Population" in `ka';



qui replace `ABSC'         = `intra'  in `ka';

qui replace `RELC'         = 1.0    in `ka';
qui replace `RELC'         = 0.0    in `kb';


                     local kindex = "Gini";
if "`index'"== "atk"  local kindex = "Atkinson";
if "`index'"== "ge"   local kindex = "Generalised Entropy";
if "`index'"== "cvar" local kindex = "Coefficient of Variation";



 tempname table;
	.`table'  = ._tab.new, col(3);
	.`table'.width |`ll'|16 16|;
	.`table'.strcolor . . yellow ;
	.`table'.numcolor  yellow yellow yellow;
	.`table'.numfmt %12.0g   %12.`dec'f %12.`dec'f ;
       di _n as text "{col 4} Decomposition of the `kindex' inequality index by poplation groups (using the Shapley value).";
       di as text  "{col 5}Execution  time :    "  %10.2f `ptime' " second(s)";
       
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";
     
	.`table'.sep, top;
	.`table'.titles "            "   "Absolute  " "Relative  " ;
	.`table'.titles "Components       "    "Contribution " "Contribution " ;
	.`table'.sep, mid;
    .`table'.numcolor white yellow yellow   ;
 
	.`table'.row "Inter-Group"   `inter' `rinter';	
	 .`table'.sep, mid;
	 .`table'.row "Inter-Group Components"   "" "";
	 
	  forvalues i=1/`k1'{;
             .`table'.numcolor  .  .  .    ;
             .`table'.row `Group'[`i']  `ABSC'[`i'] `RELC'[`i']; 
                    };
					 .`table'.sep, mid;
	.`table'.row "Intra-Group"   `intra' `rintra';                
    .`table'.sep, mid;
    .`table'.numcolor white yellow yellow   ;
    .`table'.row "Total" `vindex'  1.0;
	.`table'.sep, bot;





end;
    

