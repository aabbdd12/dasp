
/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Université Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : crossgroup                                                  */
/*************************************************************************/

#delimit ;
set more off; 

cap program drop crossgroup;
program define crossgroup;
version 10.0;
syntax varlist(min=2 max=2) [ , GENG(string)];



preserve;
capture {;
local lvgroup:value label `1';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , replace;
qui count;
forvalues i=1/`r(N)' {;
local tem=value[`i'];
local  1_grlab`tem' = label[`i'];
};
};
};
restore;

preserve;
qui tabulate `1', matrow(v1gn);
cap drop v1gn1;
svmat int v1gn;
global indica1=r(r);
restore;
 
preserve;
capture {;
local lvgroup:value label `2';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , replace;
qui count;
forvalues i=1/`r(N)' {;
local tem=value[`i'];
local  2_grlab`tem' = label[`i'];
};
};
};
restore;

preserve;
qui tabulate `2', matrow(v2gn);
cap drop v2gn1;
svmat int v2gn;
global indica2=r(r);
restore;





tokenize `varlist';
cap drop v1gn1;
svmat int v1gn;
tokenize `varlist';
cap drop v2gn1;
svmat int v2gn;


forvalues k = 1/$indica2 {;
local kk = v2gn1[`k'];
                           local label`k'  : label (`2') `kk';
if ( "`label`k''" == "")   local label`k'   = "Group: `kk'";
dis `kk' "     `label`k''" ;
};

qui sum `1';



local j=10;
while (`j'<r(max)) {;
local j = `j'*10;
};



                  local cname = "cgroup";
if ("`geng'"~="") local cname = "`geng'";

cap drop `cname';
gen `cname' = `2'*`j'+`1';

set trace on;
cap  label drop l`cname';

set trace off;

forvalues k = 1/$indica2 {;

forvalues h = 1/$indica1 {;

local kk = v2gn1[`k'];


                           local 1label`k'  : label (`2') `kk';
if ( "`label`k''" == "")   local 1label`k'   = "Group: `kk'";


local hh = v1gn1[`h'];
						   local 2label`h'  : label (`1') `hh';
if ( "`label`h''" == "")   local 2label`h'   = "Group: `hh'";



local code = `kk'*`j'+`hh';

label define l`cname' `code' `"`1label`k''_`2label`h''"', modify;


};
};
label val `cname' l`cname' ;
cap drop v1gn1 v2gn1 ; 
cap matrix drop gn1 gn2;
end;


