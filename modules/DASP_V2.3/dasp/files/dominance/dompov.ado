
/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim                       */
/* Universite Laval, Quebec, Canada                                       */
/* email : aabd@ecn.ulaval.ca                                            */
/* Web   : www.dasp.ecn.ulaval.ca                                        */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : dompov                                                      */
/*************************************************************************/

set more off
capture program drop dompov
program define dompov, rclass
version 9.2
#delimit ;
syntax namelist(min=2 max=2) 
[, 
FILE1(string)   
HSize1(string) 
COND1(string)

FILE2(string) 
HSize2(string) 
COND2(string) 

zmin(string) 
zmax(string)
step(string)  
ORDER(int 1)
DEC(int 3)
];

tokenize `namelist';
local alpha = `order' - 1;
local bool1=((`"`file1'"'=="") & (`"`file2'"'==""));
local bool2=(`"`file1'"'!=`"`file2'"');


preserve;
if (`"`file1'"'!="") use `"`file1'"', replace;
cap qui svy: total;
local srt ="`r(settings)'";

local wname1="";
if ( "`srt'"==", clear")   qui svyset _n, vce(linearized);
if ( "`srt'"~=", clear") {;
qui svy: total `1';
qui estat svyset;
local wname1=`"`e(wvar)'"';
};

tempvar y w1;
cap drop `w1';
cap drop `y';
if ( "`wname1'" == "" )    qui gen `w1' = 1;
if ( "`wname1'" ~= "" )    qui gen `w1' =`wname1';
if ("`hsize1'" ~= "")    qui replace `w1' =  `w1'*`hsize1';
qui gen _cd1=1;
if ("`cond1'" ~= "")  qui replace _cd1=`cond1';
if ("`cond1'" ~= "")     qui replace `w1' =  `w1'*_cd1;
qui rename `1' `y';
keep `y' `w1';
tempfile mas1;
qui save `mas1', replace;
restore;
preserve;
if (`"`file2'"'!="") use `"`file2'"', replace;
cap qui svy: total;
local wname2="";
if ( "`srt'"==", clear")   qui svyset _n, vce(linearized);
if ( "`srt'"~=", clear") {;
qui svy: total `2';
qui estat svyset;
local wname2=`"`e(wvar)'"';
};
cap drop `y';
tempvar `y' w2;
if ( "`wname2'" == "" )    qui gen `w2' = 1;
if ("`wname2'"~="")        qui gen `w2' =`wname2';
if ("`hsize2'" ~= "")      qui replace `w2' =  `w2'*`hsize2';
qui gen _cd2=1;
if ("`cond2'" ~= "")       qui replace _cd2=`cond2';
if ("`cond2'" ~= "")       qui replace  `w2' =  `w2'*_cd2;
qui rename `2' `y';
keep `y' `w2';
qui append using `mas1';

qui replace `w1'=0     if `w1'>=.;
qui replace `w2'=0     if `w2'>=.;
qui sort `y', stable;


collapse (sum) `w1' `w2', by(`y');
tempvar _sw1 _sy1 _s2y1 _szs1;
qui gen     `_sw1'  = sum(`w1');
local sw1=`_sw1'[_N];
qui replace `_sw1'  = `_sw1'/`sw1';
if (`alpha' >=1 ) qui gen   `_sy1'    = sum(`w1'*`y')/`sw1';

if (`alpha' == 2 ){;
qui gen   `_s2y1'   =  sum(`w1'*`y'^2)/`sw1';
qui gen   `_szs1'   = `_sw1'*`y'^2;
};

tempvar _sw2 _sy2 _s2y2 _szs2;
qui gen     `_sw2'        = sum(`w2');
local sw2=`_sw2'[_N];
qui replace `_sw2'      = `_sw2'/`sw2';
if (`alpha' >=1 ) qui gen `_sy2'    = sum(`w2'*`y')/`sw2';
if (`alpha' ==2 ){;
qui gen `_s2y2'   = sum(`w2'*`y'^2)/`sw2';
qui gen `_szs2'   = `_sw2'*`y'^2;
};

local ninter=0;
qui gen _case="";
qui gen _num=0;
qui gen _pline=0;
qui gen _irange_pline=.;
qui gen _arange_pline=.;

local bnodif=1;
local strr1=`y'[1];

if (`alpha'==0) {; /* BEGIN ALPHA=0*/


tempvar p1_0 p2_0 dif_0;
qui gen `p1_0'  = `_sw1';
qui gen `p2_0'  = `_sw2';
qui gen `dif_0' = `p2_0'-`p1_0';
qui count;
local chk=`r(N)'-1;

local z_et=0;
local _case="";
local  ran=0;
local eran=0;
 

forvalues i=1/`chk' {; /* BEG CHK */

local bnodif =`bnodif'*(`dif_0'[`i']==0); 
if (`dif_0'[`i']>0)  local _case="A";
if (`dif_0'[`i']<0)  local _case="B";
if (`bnodif'==1)     local _case="C";

if ((`dif_0'[`i']<0 & `dif_0'[`i'+1]>0) |  (`dif_0'[`i']>0 & `dif_0'[`i'+1]<0)) {;
local z_et=`y'[`i']-(`y'[`i'+1]-`y'[`i'])/(`dif_0'[`i'+1]-`dif_0'[`i'])*(`dif_0'[`i']);
local ninter = `ninter' +1;
qui replace _num =  `ninter'   in `ninter' ;
qui replace _pline =  `y'[`i'+1]     in `ninter' ;
qui replace _case = "`_case'"   in `ninter' ;

};






if (`dif_0'[`i']==0) {;


if (`i'!=1 ) {;

if( `dif_0'[`i'-1]!=0 ) local strr1=`y'[`i'];

if (`dif_0'[`i'+1]!=0 ) {;
local eran=1;
local strr2=`y'[`i'+1];

};

if (`dif_0'[`i'-1]>0)  local _case="A";
if (`dif_0'[`i'-1]<0)  local _case="B";

};



if (`eran'==1) {;
local ninter=`ninter'+1;
qui replace _num          =  `ninter'   in `ninter' ;
qui replace _irange_pline  =  `strr1'   in `ninter' ;
qui replace _arange_pline  =  `strr2'   in `ninter' ;
qui replace _pline        =  .     in `ninter' ;
qui replace _case         =  "`_case'"  in `ninter' ;
local eran=0;
};


};


}; /* FOR CHK */


};  /* END ALPHA=0*/


if (`alpha'==1) {; /* BEG ALPHA==1 */

tempvar p1_1 p2_1 dif_1;
qui gen `p1_1'=(`_sw1'*`y'-`_sy1');
qui gen `p2_1'=(`_sw2'*`y'-`_sy2');
qui gen `dif_1'=`p2_1'-`p1_1';
qui drop if `dif_1'>=. | `p1_1'==0 | `p2_1'==0  ; 
qui count;
local chk=`r(N)'-1;
local z_et=0;
local _case="";
local  ran=0;
local eran=0;


forvalues i=1/`chk' {;

local bnodif =`bnodif'*(`dif_0'[`i']==0); 
if (`dif_1'[`i']>0)  local _case="A";
if (`dif_1'[`i']<0)  local _case="B";
if (`bnodif'==1)     local _case="C";


if ((`dif_1'[`i']>0 & `dif_1'[`i'+1]<0) | (`dif_1'[`i']<0 & `dif_1'[`i'+1]>0)) {;
local b=(`dif_1'[`i'+1]- `dif_1'[`i'])/(`y'[`i'+1]-`y'[`i']);
if (`ran'!=1 & `i'!=1 & `eran'!=1 ){;
local z_et=`y'[`i']-(`dif_1'[`i']/`b');
local ninter=`ninter'+1;
qui replace _num =  `ninter'      in `ninter' ;
qui replace _pline =  `z_et'      in `ninter' ;
qui replace _case = "`_case'"     in `ninter' ;
};
};

if (`i'!=1){;

if (`dif_1'[`i']==0 & `dif_1'[`i'+1]!=0 & `dif_1'[`i'-1]!=0 ) {;
local b=(`dif_1'[`i'+1]- `dif_1'[`i'])/(`y'[`i'+1]-`y'[`i']);
if (`ran'!=1  & `eran'!=1 ){;
local z_et=`y'[`i']-(`dif_1'[`i']/`b');
local ninter=`ninter'+1;
qui replace _num =  `ninter'      in `ninter' ;
qui replace _pline =  `z_et'      in `ninter' ;
qui replace _case = "`_case'"     in `ninter' ;
};
};

};



if (`dif_1'[`i']==0) {;
if (`i'==1) local strr1=`y'[`i']; 
if (`dif_1'[`i'-1]!=0 & `dif_1'[`i']==0 ) {;

local strr1=`y'[`i'];
if (`dif_1'[`i'-1]>0)  local _case="A";
if (`dif_1'[`i'-1]<0)  local _case="B";
};


if (`dif_1'[`i'-1]==0 ) local ran = 1;
if (`dif_1'[`i'-1]==0 & `dif_1'[`i'+1]!=0 ) {;
local eran=1;
local strr2=`y'[`i'];

};


local z_et=`y'[`i'];

if (`ran'==1 & `eran'==1 ) {;
local ninter=`ninter'+1;
qui replace _num         =  `ninter'   in `ninter' ;
qui replace _irange_pline  =  `strr1'   in `ninter' ;
qui replace _arange_pline  =  `strr2'   in `ninter' ;
qui replace _perc =.                   in `ninter' ;
qui replace _case        =  "`_case'"  in `ninter' ;
local nonint=0;
local eran=0;
local ran=0;
};

};

}; /*  END CHK */


}; /* END ALPHA==1*/

if (`alpha'==2) {;

tempvar p1_1 p2_1 dif_1;
tempvar p1_2 p2_2 dif_2;
qui gen `p1_2'=(`_szs1'-2.0*`_sy1'*`y'+`_s2y1');
qui gen `p2_2'=(`_szs2'-2.0*`_sy2'*`y'+`_s2y2');
qui gen `dif_2'=`p2_2'-`p1_2';

qui gen `p1_1'=(`_sw1'*`y'-`_sy1');
qui gen `p2_1'=(`_sw2'*`y'-`_sy2');
qui gen `dif_1'=`p2_1'-`p1_1';
qui drop if `dif_1'>=. | `p1_1'==0 | `p2_1'==0  ; 

qui drop if `dif_2'>=. | `p1_2'==0 | `p2_2'==0  ; 
qui count;
local chk=`r(N)'-1;

forvalues i=1/`chk' {;


local _case="";
if (`dif_2'[`i']>0)  local _case="A";
if (`dif_2'[`i']<0)  local _case="B";


local cond1=((`dif_1'[`i']>0 & `dif_1'[`i'+1]<0)|(`dif_1'[`i']<0 & `dif_1'[`i'+1]>0));



if ((`dif_1'[`i']>0 & `dif_1'[`i'+1]<0)|(`dif_1'[`i']<0 & `dif_1'[`i'+1]>0)) {;
local bnodif=0;
local a=(`_sw2'[`i']-`_sw1'[`i']);
local b=-2.0*(`_sy2'[`i']-`_sy1'[`i']);
local c=(`_s2y2'[`i']-`_s2y1'[`i']);
local delta = (`b'^2-4*`a'*`c');
local rdelta = (`b'^2-4*`a'*`c')^0.5;
local s1=(-`b'-`rdelta')/(2*`a');
local s2=(-`b'+`rdelta')/(2*`a');

if (`a'==0 ) {;
local s=-`c'/`b';
if (`s'>`y'[`i'] & `s'<`y'[`i'+1]) {;
local z_et=`s';
local ninter=`ninter'+1;
qui replace _num =  `ninter' in `ninter' ;
qui replace _pline =  `z_et'   in `ninter' ;
qui replace _case = "`_case'"   in `ninter' ;
};
};

if (`s1'>`y'[`i'] & `s1'<`y'[`i'+1]) {;
local z_et = `s1';
local ninter=`ninter'+1;
qui replace _num =  `ninter' in `ninter' ;
qui replace _pline =  `z_et'   in `ninter' ;
qui replace _case = "`_case'" in `ninter' ;
};

if (`s2'>`y'[`i'] & `s2'<`y'[`i'+1]) {;
     if ("`_case'"=="A")  local _case = "B";
else if ("`_case'"=="B")  local _case = "A";
dis "ch point `_case'";
local z_et = `s2';
local ninter=`ninter'+1;
qui replace _num =  `ninter' in `ninter' ;
qui replace _pline =  `z_et' in `ninter' ;
qui replace _case = "`_case'"   in `ninter' ;
};

};



if ( (`dif_2'[`i']>0 & `dif_2'[`i'+1]<0) | (`dif_2'[`i']<0 & `dif_2'[`i'+1]>0)) {;
local bnodif=0;
if  (`dif_2'[`i']>0 & `dif_2'[`i'+1]<0){;
local a=(`_sw2'[`i']-`_sw1'[`i']);
local b=-2.0*(`_sy2'[`i']-`_sy1'[`i']);
local c=(`_s2y2'[`i']-`_s2y1'[`i']);
};

if  (`dif_2'[`i']<0 & `dif_2'[`i'+1]>0){;
local a=-(`_sw2'[`i']-`_sw1'[`i']);
local b=2.0*(`_sy2'[`i']-`_sy1'[`i']);
local c=-(`_s2y2'[`i']-`_s2y1'[`i']);
};
local delta  = (`b'^2-4*`a'*`c');
local rdelta = (`b'^2-4*`a'*`c')^0.5;
local s1=(-`b'-`rdelta')/(2*`a');
local s2=(-`b'+`rdelta')/(2*`a');



if (`a'==0 ) {;
local s=-`c'/`b';
if (`s'>`y'[`i'] & `s'<`y'[`i'+1]) {;
local z_et=`s';
local ninter=`ninter'+1;
qui replace _num =  `ninter' in `ninter' ;
qui replace _pline =  `z_et' in `ninter' ;
qui replace _case = "`_case'"   in `ninter' ;
};
};


if (`s1'>`y'[`i'] & `s1'<`y'[`i'+1]) {;
local z_et = `s1';
local ninter=`ninter'+1;
qui replace _num =  `ninter' in `ninter' ;
qui replace _pline =  `z_et' in `ninter' ;
qui replace _case = "`_case'"   in `ninter' ;
};

if (`s2'>`y'[`i'] & `s2'<`y'[`i'+1]) {;
local z_et = `s2';
local ninter=`ninter'+1;
qui replace _num =  `ninter' in `ninter' ;
qui replace _pline =  `z_et' in `ninter' ;
qui replace _case = "`_case'"   in `ninter' ;
};

};

if (`dif_2'[`i']==0 ) {;
if (`dif_2'[`i'-1]>0)  local _case="A";
if (`dif_2'[`i'-1]<0)  local _case="B";
local z_et=`y'[`i'];
local ninter=`ninter'+1;
qui replace _num =  `ninter' in `ninter' ;
qui replace _pline =  `z_et' in `ninter' ;
qui replace _case = "`_case'"   in `ninter' ;

};

};



};

if (`bnodif' == 0 & `ninter'>=1) {;
tempname table;
	.`table'  = ._tab.new, col(5)  separator(0) lmargin(0);
	.`table'.width  16 16 16 16 16 ;
	.`table'.strcolor . . yellow . .;
	.`table'.numcolor yellow yellow . yellow  yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f %16.`dec'f %16.`dec'f   %16s;

       
      .`table'.sep, top;
      .`table'.titles "Number of   " "Critical  "  "Min. range of" "Max. range of"	"Case";
	.`table'.titles "intersection" "pov. line"  "pov. lines  " "pov. line "	"    ";
	
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`ninter'{;
           		.`table'.row `i' _pline[`i'] _irange_pline[`i'] _arange_pline[`i'] _case[`i']; 
	};
   .`table'.sep,bot;
 disp in white " Notes :    ";
disp in white " _case A: Before this intersection, distribution 1 dominates (in welfare) distribution 2.";
disp in white " _case B: Before this intersection, distribution 2 dominates (in welfare) distribution 1.";
disp in white " _case C: No dominance before this intersection. "; 
 
};
if ( `bnodif'== 1 | `ninter'==0 ) {;
disp in green _newline "{hline 70}";
disp in white "Notes : No intersection founded.   ";
     if ("`_case'"=="A") disp in white "Distribution 1 dominates (in welfare) distribution 2.";
else if ("`_case'"=="B") disp in white "Distribution 2 dominates (in welfare) distribution 1.";
else if ("`_case'"=="C") disp in white "        No dominance : Same distributions. ";    
disp in green "{hline 70}" ; 
};

end; 

