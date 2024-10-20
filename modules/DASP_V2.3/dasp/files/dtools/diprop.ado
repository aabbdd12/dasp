/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : diprop2d                                                     */
/*************************************************************************/






#delim ;
set more off;

capture program drop diprop2;
program define diprop2, rclass;
version 9.2;
syntax namelist [,  GNumber(integer 1) HS(string)];

tokenize `namelist';

tempvar hsi1 hsia1;
qui gen `hsi1'=`hs';


qui gen `hsia1'=`hs';

qui replace `hsi1'=`hsi1'*(`1'==`gnumber');


 qui svy: ratio  `hsi1'/`hsia1';
 cap drop matrix _aa;
 matrix _aa=e(b);
 local est1 = el(_aa,1,1);
 cap drop matrix _vv;
 matrix _vv=e(V);
 local std1 = el(_vv,1,1)^0.5;
 return scalar std1  = `std1';
 return scalar est1  = `est1';


end;





capture program drop diprop2d;
program define diprop2d, rclass;
version 9.2;
syntax namelist (min=1 max=1) [,   GNumber(integer 1) HS1(string) HS2(string) ];

tokenize `namelist';


tempvar hsi1 hsi2 hsia1 hsia2;

qui gen `hsi1'=`hs1';
qui gen `hsi2'=`hs2';

qui gen `hsia1'=`hs1';
qui gen `hsia2'=`hs2';

qui replace `hsi1'=`hsi1'*(`1'==`gnumber');
qui replace `hsi2'=`hsi2'*(`1'==`gnumber');

 qui svy: ratio  `hsi1'/`hsia1';
 cap drop matrix _aa;
 matrix _aa=e(b);
 local est1 = el(_aa,1,1);
 cap drop matrix _vv;
 matrix _vv=e(V);
 local std1 = el(_vv,1,1)^0.5;
 return scalar std1  = `std1';
 return scalar est1  = `est1';
 
 qui svy: ratio  `hsi2'/`hsia2';
 cap drop matrix _aa;
 matrix _aa=e(b);
 local est2 = el(_aa,1,1);
 cap drop matrix _vv;
 matrix _vv=e(V);
 local std2 = el(_vv,1,1)^0.5;
 return scalar std2  = `std2';
 return scalar est2  = `est2';
 
 qui svy: mean    `hsi1' `hsia1' `hsi2' `hsia2';
qui nlcom ((_b[`hsi1']/_b[`hsia1']) - (_b[`hsi2']/_b[`hsia2'])) , iterate(50000); 

 cap drop matrix _aa;
 matrix _aa=r(b);
 local est3 = el(_aa,1,1);
 cap drop matrix _vv;
 matrix _vv=r(V);
 local std3 = el(_vv,1,1)^0.5;
 return scalar std3  = `std3';
 return scalar est3  = `est3';

end;






capture program drop diprop;
program define diprop, eclass;
version 9.2;
syntax  namelist (min=1 max=1) [, FILE1(string) FILE2(string) HSize1(string) HSize2(string) 
ALpha(real 0)  PLINE(real 10000)  type(string) DEC(int 6) DSTE(int 1) REF(int 1)];



if ("`type'"=="")          local type="nor";

local ll=10;

local indep = ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  );




if ( "`hsize1'" == "") {;
tempvar hsize1;
qui gen `hsize1'=1;
};

if ( "`hsize2'" == "") {;
tempvar hsize2;
qui gen `hsize2'=1;
};




if ((`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;
if (`"`file1'"'~="") use `"`file1'"', replace;


tempvar Variable EST1 EST2   EST3  STE1 STE2   STE3   ;
qui gen `Variable'="";
qui gen `EST1'=0;
qui gen `STE1'=0;


qui gen `EST2'=0;
qui gen `STE2'=0;

qui gen `EST3'=0;
qui gen `STE3'=0;


tokenize `namelist' , parse(,);



preserve;
capture {;
local lvgroup:value label `1';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , clear;
qui count;
forvalues i=1/`r(N)' {;
local tem=value[`i'];
local grlab`tem' = label[`i'];
};
};
};
restore;preserve;
qui tabulate `1', matrow(gn);
svmat int gn;
global indica=r(r);



tokenize `namelist' , parse(,);




forvalues k = 1/$indica {;
local kk = gn1[`k'];
diprop2d `1' ,   hs1(`hsize1') hs2(`hsize2')  gnumber(`kk')  ;
local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;
qui replace `EST1'      = `r(est1)' in `k1';
qui replace `EST1'      = `r(std1)' in `k2';



qui replace `EST2'      = `r(est2)' in `k1';
qui replace `EST2'      = `r(std2)' in `k2';

qui replace `EST3'      = `r(est3)' in `k1';
qui replace `EST3'      = `r(std3)' in `k2';


local label`f'  : label (`1') `kk';
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";
qui replace `Variable' = "`label`f''" in `k1';

local ll=max(`ll',length("`label`f''"));
};

local k2 = 2*$indica;
 tempname table;
        .`table'  = ._tab.new, col(4);
        .`table'.width |`ll'|16 16 16|;
        .`table'.strcolor . . yellow .  ;
        .`table'.numcolor yellow yellow . yellow   ;
        .`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f ;
        di _n as text "{col 4} Change in group population shares";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";


        .`table'.sep, top;
        .`table'.titles "Group  " "Initial   "    "Final "            "Difference in"  ;
        .`table'.titles "       " "Pop. share"    "Pop. share"      "Pop. share   "  ;
        .`table'.sep, mid;
        local nalt = "ddd";
        forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor white yellow yellow yellow   ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green   green  green  ;
                  if (`dste'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i'] `EST1'[`i'] `EST2'[`i']  `EST3'[`i'] ;
                        
                };
.`table'.sep,bot;






};


// second stage
if !( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;
if ("`file1'" !="") use `"`file1'"', replace;
tokenize `namelist' , parse(,);

preserve;
capture {;
local lvgroup:value label `1';
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
qui tabulate `1', matrow(gn);
svmat int gn;
global indica=r(r);
tokenize `namelist' , parse(,);


tempvar hs1;
qui gen `hs1'=1;
if ("`hsize1'"~="") {;
qui replace `hs1'= `hsize1'; 
};

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight1=""; 
cap qui svy: total `1'; 
local hweight1=`"`e(wvar)'"';
cap ereturn clear; 

tempvar hsia1;
qui gen `hsia1'  = `hs1'; 

forvalues j = 1/$indica {;
local k = gn1[`j'];

diprop2 `1' ,   hs(`hs1')   gnumber(`k');

local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;

local estt1_`k1' =  `r(est1)';
local estt1_`k2' =  `r(std1)';



};


restore;
if ("`file2'" !="") use `"`file2'"', replace;

preserve;
tokenize `namelist' , parse(,);
capture {;
local lvgroup:value label `1';
uselabel `lvgroup' , clear;
qui count;
forvalues i=1/`r(N)' {;
local tem=value[`i'];
local grlab`tem' = label[`i'];
};
};

restore;
preserve;
qui tabulate `1', matrow(gn);
svmat int gn;
global indica=r(r);


tempvar hs2;
qui gen `hs2'=1;
if ("`hsize2'"~="") {;
qui replace `hs2'= `hsize2'; 
};

tokenize `namelist' , parse(,);

qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

local hweight2=""; 
cap qui svy: total `1'; 
local hweight2=`"`e(wvar)'"';
cap ereturn clear; 



tempvar Variable EST1 EST2  EST3  STE1 STE11 STE2 STE3 ;
qui gen `Variable'="";


qui gen `EST1'=0;
qui gen `STE1'=0;

qui gen `EST2'=0;
qui gen `STE2'=0;

qui gen `EST3'=0;
qui gen `STE3'=0;






tempvar hsia2;
qui gen `hsia2'  = `hs2'; 
forvalues j = 1/$indica {;
local k = gn1[`j'];


diprop2 `1' ,   hs(`hs2')   gnumber(`k');

local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;


qui replace `EST1'       = `estt1_`k1'' in `k1';
qui replace `EST1'       = `estt1_`k2'' in `k2';


qui replace `EST2'       = `r(est1)' in `k1';
qui replace `EST2'       = `r(std1)' in `k2';

qui replace `EST3'       = `EST2'[`k1']-`EST1'[`k1']           in `k1';
qui replace `EST3'       = (`EST2'[`k2']^2+`EST1'[`k2']^2)^0.5 in `k2';

local label`k'  : label (`1') `k';
if ( "`label`k''" == "") local label`k'   = "Group: `k'";
qui replace `Variable' = "`label`k''" in `k1';

local ll=max(`ll',length("`label`k''"));

};
 tempname table;
        .`table'  = ._tab.new, col(4);
        .`table'.width |`ll'|16 16 16|;
        .`table'.strcolor . . yellow .  ;
        .`table'.numcolor yellow yellow . yellow   ;
        .`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f ;
        di _n as text "{col 4} Change in group population shares";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`1'"!="")  di as text     "{col 5}Group variable  :  `1'";


        .`table'.sep, top;
        .`table'.titles "Group  " "Initial   "    "Final "            "Difference in"  ;
        .`table'.titles "       " "Pop. share"    "Pop. share"      "Pop. share   "  ;
        .`table'.sep, mid;
        local nalt = "ddd";
        forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor white yellow yellow yellow   ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green   green  green  ;
                  if (`dste'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i'] `EST1'[`i'] `EST2'[`i']  `EST3'[`i'] ;
                        
                };
.`table'.sep,bot;

};

restore;


end;



