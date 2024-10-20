/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                       */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/

#delim;
capture program drop shapar;
program define shapar, eclass;
version 9.2;
args g;  

local size=2^`g'; global shasize=`size';
qui count;
if (`r(N)' < `size') qui set obs `size';

forvalues i=1/`g' {;
tempvar v`i'; 
qui gen `v`i''=.;
cap drop _shapwe`i'; 
qui gen  _shapwe`i'=0;
cap drop _o`i';      
qui gen       _o`i'=.;
};



local fac0=1;
forvalues i=1/`g' {;
local j=`i'-1;
local fac`i' = `fac`j'' * `i';
};

forvalues i=0/`g' {;
local  rho`k'= 0;
local srho`k'= 0;
};
forvalues k=1/`g' {;
local k_1=`k'-1;
local rho`k' = 2^(`g'-`k');
local srho`k'= `srho`k_1'' + `rho`k'';
};


local   b=1;
local   e=`srho1';
qui replace `v1' = 1 in `b'/`e';
qui replace _o1 = 1 in  `b'/`e';
forvalues i=2/`g' {;
local i_1 = `i' -  1;
local   b=`srho`i_1'' + 1;
local   e=`srho`i'';
qui replace     `v1'   = `i' in  `b'/`e';
};
forvalues vec=2/`g'{;
local   vec1 = `vec' -  1;
local   b=2;
local   e=`srho`g''+1;
local   d=`rho1';
qui replace `v`vec'' = `v`vec1''[_n+`d'-1] in `b'/`e';
forvalues i=2/`g' {;
local i1 = `i' -  1;
local   b=`srho`i1''+2;
local   e=`srho`i'' +1;
local   d= `rho`i'';
qui replace `v`vec'' = `v`vec1''[_n+`d'-1]  in `b'/`e';
};
};



forvalues i =1/`g' {;
forvalues j =1/`g' {;
qui replace _o`i' = `i' if `v`j''==`i';
};
};
 
tempvar elp elp2; 
qui gen `elp'= 0; qui gen `elp2'= 0;
forvalues i=1/`g' {;
qui replace `v`i''=-1*(_o`i'==.)+(_o`i'!=.);
qui replace `elp'  = `elp'  + (_o`i'!=.);
qui replace `elp2' = `elp2' + (_o`i'==.);
};

cap drop _sg;
qui gen _sg=`elp';

qui replace `elp' =max(0,`elp'  - 1);
qui replace `elp2'=max(0,`elp2' - 1);
tempvar sf scf _sf _scf;
qui gen  `sf'=0; qui gen  `scf'=0; 
qui gen `_sf'=0; qui gen `_scf'=0; 
forvalues i=1/`size' {;
local s    =  `elp'[`i'];
local sc   =  `g'-`s'-1;
local _s   = `elp2'[`i'];
local _sc   =  `g'-`_s'-1;
qui replace     `sf'     =  `fac`s''   in `i';
qui replace    `scf'     =  `fac`sc''  in `i';
qui replace    `_sf'     =  `fac`_s''  in `i';
qui replace   `_scf'     =  `fac`_sc'' in `i';
};
forvalues j=1/`g' {;
qui replace _shapwe`j' =  ((`v`j''> 0 )*`sf'*`scf' - (`v`j''< 0 )*`_sf'*`_scf')/ `fac`g'';
};
order _o*;
end;

