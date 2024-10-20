
/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.0)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universit Laval, Quebec, Canada                                       */
/* email : aabd@ecn.ulaval.ca                                            */
/* Web   : www.dasp-two.vercel.app                                        */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : domineq                                                     */
/*************************************************************************/


set more off
capture program drop domineq
program define domineq, rclass
version 9.2
#delimit ;
syntax namelist(min=2 max=2) 
[, 
FILE1(string)   
HSize1(string) 
RANK1(string)
COND1(string)

FILE2(string) 
HSize2(string) 
RANK2(string)
COND2(string) 

TYPE(string)
zmin(string) 
zmax(string)
step(string)  
DEC(int 3)
];

tokenize `namelist';


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

tempvar y1 w1;
cap drop `w1';
cap drop `y1';
qui gen  `y1'=`1';
if ( "`wname1'" == "" )    qui gen `w1' = 1;
if ( "`wname1'" ~= "" )    qui gen `w1' =`wname1';
if ("`hsize1'" ~= "")      qui replace `w1' =  `w1'*`hsize1';
qui gen _cd1=1;
if ("`cond1'" ~= "")     qui replace _cd1=`cond1';
if ("`cond1'" ~= "")     qui replace `w1' =  `w1'*_cd1;


keep `rank1' `y1' `w1';


if ("`rank1'"=="") sort `y1' , stable;
if ("`rank1'"~="") sort `rank1' `y1', stable;




if ("`type'"=="abs") {;
qui sum `y1' [aw=`w1'];
qui replace `y1' = `y1' - `r(mean)';
};

qui gen _p=0;
qui gen      _sw1  = sum(`w1');
qui gen      _lp1  = sum(`w1'*`y1');
if ("`type'"!="gen") qui replace  _lp1  = sum(`w1'*`y1')/_lp1[_N];
if ("`type'"=="gen" | "`type'"=="abs") qui replace  _lp1  = sum(`w1'*`y1')/_sw1[_N];

qui replace  _p    =_sw1/_sw1[_N];
keep _lp1 _p;
tempfile mas1;
qui save `mas1', replace;
restore;

preserve;
if (`"`file2'"'!="") use `"`file2'"', replace;
cap qui svy: total `2';
local wname2="";
if ( "`srt'"==", clear")   qui svyset _n, vce(linearized);
if ( "`srt'"~=", clear") {;
qui svy: total `2';
qui estat svyset;
local wname2=`"`e(wvar)'"';
};

tempvar y2 w2;
cap drop `w2';
cap drop `y2';
qui gen `y2'=`2';
if ( "`wname2'" == "" )    qui gen `w2' = 1;
if ( "`wname2'" ~= "" )    qui gen `w2' =`wname2';
if ("`hsize2'" ~= "")      qui replace `w2' =  `w2'*`hsize2';
qui gen _cd2=1;
if ("`cond2'" ~= "")     qui replace _cd2=`cond2';
if ("`cond2'" ~= "")     qui replace `w2' =  `w2'*_cd2;


keep `rank2' `y2' `w2';


if ("`rank2'"=="") sort `y2' , stable;
if ("`rank2'"~="") sort `rank2' `y2' , stable;



if ("`type'"=="abs") {;
qui sum `y2' [aw=`w2'];
qui replace `y2' = `y2' - `r(mean)';
};

qui gen _p=0;
qui gen      _sw2  = sum(`w2');
qui gen      _lp2  = sum(`w2'*`y2');
if ("`type'"!="gen") qui replace  _lp2  = sum(`w2'*`y2')/_lp2[_N];
if ("`type'"=="gen" | "`type'"=="abs") qui replace  _lp2  = sum(`w2'*`y2')/_sw2[_N];

qui replace  _p    =_sw2/_sw2[_N];
keep _lp2 _p;
tempfile mas2;
keep _lp2 _p ;
qui save `mas2', replace;



qui append using `mas1';
qui sort _p, stable;

collapse (sum) _lp1 _lp2, by(_p);

qui count;
local obs1=`r(N)'+1;
qui set obs `obs1';
gen double _fp=0;
qui count;
local chk = `r(N)' - 1;
forvalues i=2/`r(N)' {;
qui replace _fp = _p[`i'-1] in `i';
};

keep _fp;


merge using `mas1';
qui gen _flp1=0;
qui count; 
local i = 1;
local aa=`r(N)'-1;
forvalues j=0/`aa' {;
local pcf=_fp[`j'+1];
local av=`j'+1;

while (`pcf' > _p[`i']) {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) local lpi=_lp1[`ar']+((_lp1[`i']-_lp1[`ar'])/(_p[`i']-_p[`ar']))*(`pcf'-_p[`ar']);
if (`i'==1) local lpi=0+((_lp1[`i'])/(_p[`i']))*(`pcf');
qui replace _flp1= `lpi' in `av';

};

cap drop _p _lp1;
drop _merge;
merge using `mas2';
gen _flp2=0;
qui count; 
local i = 1;
local aa=`r(N)'-1;



forvalues j=0/`aa' {;
local pcf=_fp[`j'+1];
local av=`j'+1;

while (`pcf' > _p[`i']) {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) local lpi=_lp2[`ar']+((_lp2[`i']-_lp2[`ar'])/(_p[`i']-_p[`ar']))*(`pcf'-_p[`ar']);
if (`i'==1) local lpi=0+((_lp2[`i'])/(_p[`i']))*(`pcf');
qui replace _flp2= `lpi' in `av';
};




/* list _*; */
qui gen double dif = _flp2-_flp1;



qui count;
local chk=`r(N)'-1;
qui gen _num=0;
qui gen _irange_perc=0;
qui gen _arange_perc=0;
qui gen _perc=0;
qui gen _case="";local bnodif=1;
local ninter=0;


local   ran=0;
local   eran=0;
local   strr1=0;

forvalues i=2/`chk' {;

if (dif[`i']>0)  local _case="A";
if (dif[`i']<0)  local _case="B";
local bnodif =`bnodif'*(dif[`i']==0);
if (`bnodif'==1)  local _case="C";

if ((dif[`i']>0 & dif[`i'+1]<0) | (dif[`i']<0 & dif[`i'+1]>0)) {;

if (dif[`i']>0)  local _case="A";
if (dif[`i']<0)  local _case="B";

local b=(dif[`i'+1]-dif[`i'])/(_fp[`i'+1]-_fp[`i']);
local p_et=_fp[`i']-(dif[`i']/`b');


if ( `p_et' < .99999999){;
local ninter=`ninter'+1;
qui replace _num  =    `ninter'      in `ninter' ;
qui replace _perc =    `p_et'        in `ninter' ;
qui replace _case =    "`_case'"     in `ninter' ;
qui replace _irange_perc  =  .   in `ninter' ;
qui replace _arange_perc  =  .   in `ninter' ;
};
};


if ( dif[`i'-1]!=0 & dif[`i'+1]!=0 & dif[`i']==0 ) {;
if (dif[`i'-1]>0)  local _case="A";
if (dif[`i'+1]<0)  local _case="B";
local p_et=_fp[`i'];
if ( `p_et' < .99999999){;
local ninter=`ninter'+1;
qui replace _num  =    `ninter'    in `ninter' ;
qui replace _perc =    `p_et'      in `ninter' ;
qui replace _case =    "`_case'"    in `ninter' ;
qui replace _irange_perc  =  .   in `ninter' ;
qui replace _arange_perc  =  .   in `ninter' ;
};
};



 
if (dif[`i']==0) {;


if (dif[`i'-1]!=0 & dif[`i']==0 ) {;
local strr1=round(_fp[`i']*1000000)/1000000;
if (dif[`i'-1]>0)  local _case="A";
if (dif[`i'-1]<0)  local _case="B";
};


if (dif[`i'-1]==0 ) local ran = 1;
if (dif[`i'-1]==0 & dif[`i'+1]!=0 ) {;
local eran=1;
local strr2=_fp[`i'];
local strr="`strr1' - `strr2'";
};


local p_et=_fp[`i'];

if (`ran'==1 & `eran'==1 ) {;
local ninter=`ninter'+1;
qui replace _num         =  `ninter'   in `ninter' ;
qui replace _irange_perc  =  `strr1'   in `ninter' ;
qui replace _arange_perc  =  `strr2'   in `ninter' ;
qui replace _perc =.                   in `ninter' ;
qui replace _case        =  "`_case'"  in `ninter' ;
local nonint=0;
local eran=0;
local ran=0;
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
	.`table'.titles "intersection" "percentile"  "percentiles  " "percentiles  "	"    ";
	
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`ninter'{;
           		.`table'.row `i' _perc[`i'] _irange_perc[`i'] _arange_perc[`i'] _case[`i']; 
	};
   .`table'.sep,bot;
disp in white " Notes :    ";
disp in white " _case A: Curve_1 is below Curve_2 before the intersection.";
disp in white " _case B: Curve_1 is above  Curve_2 before the intersection.";  
disp in white " _case C: # of intersections before.";  
 
};



if (`ninter'==0) {;
disp in green _newline "{hline 70}";
disp in white                          "Notes : No intersection found. ";
     if ("`_case'"=="A") disp in white "        Curve_1 is below Curve_2.";
else if ("`_case'"=="B") disp in white "        Curve_1 is above  Curve_2.";  
else if ("`_case'"=="C") disp in white "        Identical curves.";  
disp in green "{hline 70}" ; 

};


end;

