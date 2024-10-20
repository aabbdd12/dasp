/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : bian                                                        */
/*************************************************************************/

#delim ;
capture program drop quantind;
program define quantind, rclass sortpreserve;
version 9.2;
syntax varlist(min=1)[,  fw(varname) quant_rep(int 4)];
tokenize `varlist';
qui sort `1';
tempvar perc;
qui     gen `perc' =  sum(`fw');
qui replace `perc' = `perc'/`perc'[_N];
cap drop _qgr;
gen _qgr=1;

local pas = 1/`quant_rep';
local step1=0;
local step2=`pas';
forvalues i=1/`quant_rep'{;
qui replace _qgr=`i' if ((`perc'>`step1') & (`perc'<=`step2'));
local step1=`step2';
local step2=`step1'+`pas';
};
end;


#delim ;
capture program drop bian;
program define bian, rclass;
version 9.2;
syntax varlist(min=1)[,  
hgroup(varname)
sgroup(string)
dec(int 3)
dtab1(int 1) dtab2(int 1) dtab3(int 2)
mainlab(string)
APProach(int 1)
bgen(int 0)
frq1(varname) sz1(varname) in1(varname) din1(varname) lbs1(string)
frq2(varname) sz2(varname) in2(varname) din2(varname) lbs2(string)
frq3(varname) sz3(varname) in3(varname) din3(varname) lbs3(string)
frq4(varname) sz4(varname) in4(varname) din4(varname) lbs4(string)
frq5(varname) sz5(varname) in5(varname) din5(varname) lbs5(string)
frq6(varname) sz6(varname) in6(varname) din6(varname) lbs6(string)
*
];



	
if ("`hgroup'"!="") {;
preserve;
capture {;
local lvgroup:value label `hgroup';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , clear;
qui count;
forvalues i=1/`r(N)' {;
local grlab`i' = label[`i'];
};
};
};
restore;
preserve;
qui tabulate `hgroup', matrow(gn);
svmat int gn;
global indica=r(r);
local
tokenize `varlist';
matrix drop gn;
forvalues i=1/$indica {;
local tem=gn1[`i'];
if ("`grlab`i''"=="" ) local grlab`i'="Group_`tem'";
};
};




tokenize `varlist';
tempvar fw;
qui gen `fw'=1;

local nbsec=1;

local disres=1;

                       local quant_rep=5;
if ("`sgroup'"=="qrt") local quant_rep=4;
if ("`sgroup'"=="dcl") local quant_rep=10;
if ("`hgroup'"!="")    local quant_rep=$indica;

local quant_rep1=`quant_rep'+1;

forvalues i=2/6 {;
 
local j =`i'-1;
if ("`frq`i''"~="" & "`frq`j''" =="") {;
dis as error "You have to define the varname of frq`j'.";
local disres = 0;
};

if ("`frq`i''"~="" & "`frq`j''" ~="") {;
local nbsec=`i';
};

};

tempvar fw;
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear;
qui gen `fw'=1;
if ("`hweight'"~="")       qui replace `fw'=`fw'*`hweight';



forvalues i=1/`nbsec'{;
tempvar fw`i' tsz`i';
qui gen `tsz`i''=1;
if ("`sz`i''"~="")  qui replace  `tsz`i''=`sz`i''; 
if ("`sz`i''"=="")  qui replace  `tsz`i''=`frq`i'';   
qui gen   `fw`i''=`fw'*`tsz`i'';
quantind `1', fw(`fw`i'') quant_rep(`quant_rep');
cap drop _qgr`i';
gen  _qgr`i'=_qgr;
if ("`hgroup'"!="") qui replace _qgr`i'=`hgroup';
forvalues j=1/`quant_rep'{;
qui sum `fw`i'' if  _qgr`i'==`j';
};

};


if (`quant_rep'==4)  local  tn1="Quartile";
if (`quant_rep'==5)  local  tn1="Quintile";
if (`quant_rep'==10) local  tn1="Decile";

cap drop _group;
qui gen  _group ="";

forvalues j=1/`quant_rep'{;
qui replace _group = "`tn1' `j'" in `j';
if ("`hgroup'"~="") {;
local lab=gn1[`j'];
if ( "`grlab`j''" == "") local grlab`j' = "Group `lab'";
qui replace _group="`grlab`j''" in `j';
};
};


forvalues i=1/`nbsec'{;
if ("`lbs`i''"=="") local lbs`i'="Sector_`i'";

if ("`in`i''"=="") {;
tempvar in`i';
gen `in`i''=1;
};

tempvar par`i';
qui gen `par`i''=0;
tempvar rar`i';
qui gen `rar`i''=0;

qui sum `frq`i'' [aw=`fw'];
local totfreq`i' = `r(sum)';

qui sum `tsz`i'' [aw=`fw'];
local totsz`i' = `r(sum)';


forvalues j=1/`quant_rep'{;
qui sum `frq`i'' [aw=`fw'] if [_qgr`i'==`j']; 
local temfri=`r(sum)';
qui replace `par`i'' = `r(sum)'/`totfreq`i'' in `j';
qui sum `tsz`i'' [aw=`fw'] if [_qgr`i'==`j'];
qui replace `rar`i'' = `temfri'/`r(sum)'     in `j';
};
qui replace `par`i'' = 1 in `quant_rep1';
qui replace `rar`i'' = `totfreq`i''/`totsz`i'' in `quant_rep1';
};

qui replace _group = "All" in `quant_rep1'; 

if (`disres'==1 & `dtab1'==1){;
 disp in green  "{hline 80}";
 disp  _col(20) "Benefit Incidence Analysis: `mainlab'";
 disp in green  "{hline 80}";

local title="Share by `tn1' Groups.";
maketab , title(`title') model(1) nbsec(`nbsec') dec(`dec') quant_rep(`quant_rep') pop(1)
lbs1(`lbs1') pvar1(`par1')
lbs2(`lbs2') pvar2(`par2')
lbs3(`lbs3') pvar3(`par3')
lbs4(`lbs4') pvar4(`par4')
lbs5(`lbs5') pvar5(`par5')
lbs6(`lbs6') pvar6(`par6')
;

local title="Rate of Participation by `tn1' Groups.";
maketab , title(`title') model(1) nbsec(`nbsec') dec(`dec') quant_rep(`quant_rep') pop(1)
lbs1(`lbs1') pvar1(`rar1')
lbs2(`lbs2') pvar2(`rar2')
lbs3(`lbs3') pvar3(`rar3')
lbs4(`lbs4') pvar4(`rar4')
lbs5(`lbs5') pvar5(`rar5')
lbs6(`lbs6') pvar6(`rar6')
;

};

if (`approach'==2) {;

tempvar  _tben avr_tben;

qui gen `_tben'   =  0;
qui gen `avr_tben'=  0;
qui replace _group = "All" in `quant_rep1'; 
forvalues i=1/`nbsec'{;

tempvar  _ben`i'  _uen`i'  avr_ben`i' bavr_ben`i' avr_pben`i' wfr`i' wsz`i' wtfr`i';

qui gen `avr_ben`i'' = 0;
qui gen `bavr_ben`i'' = 0;
qui gen `_ben`i''    = 0;
qui gen `_uen`i''    = 0;
qui  gen `wfr`i''    = `frq`i''*`fw';
qui egen `wtfr`i''   =  sum(`wfr`i''), by(`in`i'');



qui replace `_uen`i'' = (`din`i''/`wtfr`i'');
qui replace `_ben`i'' = `_uen`i''*`frq`i'';
qui replace `_tben'   = `_tben' + `_ben`i'';


if (`bgen'==1) {;
cap drop  _B_Sec_`i';
cap drop  _UB_Sec_`i';
qui gen   _B_Sec_`i'  = `_ben`i''; 
qui gen   _UB_Sec_`i' = `_uen`i''; 
cap drop  _B_All;
qui gen   _B_All = `_tben'; 
};


forvalues j=1/`quant_rep'{;
qui sum `_uen`i'' [aw=`wfr`i''] if [_qgr`i'==`j']; 
local tem=`r(sum)';
qui sum `fw`i''                if [_qgr`i'==`j']; 
qui replace `avr_ben`i'' = `tem'/`r(sum)' in `j';
qui sum `wfr`i''                 if [_qgr`i'==`j']; 
qui replace `bavr_ben`i'' = `tem'/`r(sum)' in `j';
};

qui sum `_uen`i'' [aw=`wfr`i'']; 
local tem=`r(sum)';
qui sum `fw`i'';                
qui replace `avr_ben`i'' = `tem'/`r(sum)' in `quant_rep1';
qui sum `wfr`i'';               
qui replace `bavr_ben`i'' = `tem'/`r(sum)' in `quant_rep1';

};




qui sum `_tben' [aw=`fw']; 
qui replace `avr_tben' = `r(mean)'   in `quant_rep1';

local tot_pub_exp=`r(sum)'; 

tempvar  prop_tben;
qui gen `prop_tben'=0;

forvalues j=1/`quant_rep'{;
qui sum `_tben' [aw=`fw'] if [_qgr`i'==`j']; 
qui replace `avr_tben'  = `r(mean)' in `j';
qui replace `prop_tben' = `r(sum)'/`tot_pub_exp' in `j';
};
qui replace `prop_tben' = 1          in `quant_rep1';

if (`disres'==1 & `dtab2'==1){;

local title="Average Benefits by `tn1' Groups: (at the level of eligible members)";
local mod=1;
maketab , title(`title') model(`mod') nbsec(`nbsec') dec(`dec') quant_rep(`quant_rep') pop(1)
lbs1(`lbs1') pvar1(`avr_ben1')
lbs2(`lbs2') pvar2(`avr_ben2')
lbs3(`lbs3') pvar3(`avr_ben3')
lbs4(`lbs4') pvar4(`avr_ben4')
lbs5(`lbs5') pvar5(`avr_ben5')
lbs6(`lbs6') pvar6(`avr_ben6')
tvar(`avr_tben')
;

local title="Average Benefits by `tn1' Groups: (at the level of members that use the public service)";
local mod=1;
maketab , title(`title') model(`mod') nbsec(`nbsec') dec(`dec') quant_rep(`quant_rep') pop(1)
lbs1(`lbs1') pvar1(`bavr_ben1')
lbs2(`lbs2') pvar2(`bavr_ben2')
lbs3(`lbs3') pvar3(`bavr_ben3')
lbs4(`lbs4') pvar4(`bavr_ben4')
lbs5(`lbs5') pvar5(`bavr_ben5')
lbs6(`lbs6') pvar6(`bavr_ben6')
tvar(`bavr_tben')
;

};




forvalues i=1/`nbsec'{;
tempvar  prop_ben`i';
qui gen `prop_ben`i''=0;
forvalues j=1/`quant_rep'{;
qui sum `_ben`i'' [aw=`fw'] if [_qgr`i'==`j']; 
qui replace `prop_ben`i'' = `r(sum)'/`tot_pub_exp' in `j';
};
qui sum `_ben`i'' [aw=`fw'];  
qui replace `prop_ben`i'' = `r(sum)'/`tot_pub_exp' in `quant_rep1';
};


if (`disres'==1 & `dtab3'==1)
{;
local title="Proportion of Benefits by `tn1' Groups and by Sectors.";
maketab , title(`title') model(`mod') nbsec(`nbsec') dec(`dec') quant_rep(`quant_rep') pop(1)
lbs1(`lbs1') pvar1(`prop_ben1')
lbs2(`lbs2') pvar2(`prop_ben2')
lbs3(`lbs3') pvar3(`prop_ben3')
lbs4(`lbs4') pvar4(`prop_ben4')
lbs5(`lbs5') pvar5(`prop_ben5')
lbs6(`lbs6') pvar6(`prop_ben6')
tvar(`prop_tben')
;

};
};
cap drop _qgr*;
cap drop _group;


end;





capture program drop maketab;
program define maketab, rclass;
syntax [,   
title(string)
model(int 1) 
nbsec(int 1) 
dec(int 3)
quant_rep(int 4)
pop(int 0)
pvar1(varname)
pvar2(varname)
pvar3(varname)
pvar4(varname)
pvar5(varname)
pvar6(varname)
tvar(varname)
lbs1(string)
lbs2(string)
lbs3(string)
lbs4(string)
lbs5(string)
lbs6(string)
];


local  tab_col=`nbsec'+1;
local line2="  20|";
local line3=" %16.0g";
local line4=" ";
forvalues i=1/`nbsec' {;
local line2="`line2'"+" 16";
local line3="`line3'"+" %16.`dec'f";
};

local line4="Group  `line4'";





tempname table;

if (`model'==1) {;

.`table'  = ._tab.new, col(`tab_col');
.`table'.width  `line2';
.`table'.numfmt  `line3';

 di _n as text in white "{col `tab_col'}`title'";
.`table'.sep, top;


if (`nbsec'==1)	.`table'.titles "Groups  " "`lbs1'"   ;
if (`nbsec'==2)	.`table'.titles "Groups  " "`lbs1'" "`lbs2'"   ;	
if (`nbsec'==3)	.`table'.titles "Groups  " "`lbs1'" "`lbs2'"  "`lbs3'"  ;
if (`nbsec'==4)	.`table'.titles "Groups  " "`lbs1'" "`lbs2'"  "`lbs3'"  "`lbs4'"   ;
if (`nbsec'==5)	.`table'.titles "Groups  " "`lbs1'" "`lbs2'"  "`lbs3'"  "`lbs4'" "`lbs5'"   ;
if (`nbsec'==6)	.`table'.titles "Groups  " "`lbs1'" "`lbs2'"  "`lbs3'"  "`lbs4'" "`lbs5'" "`lbs6'";


local q_rep=`quant_rep';
if (`pop'==1) {;
local quant_rep=`quant_rep'+1;
};

	.`table'.sep, mid;
forvalues i=1/`quant_rep' {;
         if (`nbsec'==1) {;
                          .`table'.row _group[`i'] 
                          `pvar1'[`i']; 	
	                   };
         if (`nbsec'==2) {;
                          .`table'.row _group[`i'] 
                          `pvar1'[`i']
				  `pvar2'[`i']; 	
	                   };
	   if (`nbsec'==3) {;
                          .`table'.row _group[`i'] 
                          `pvar1'[`i']
				  `pvar2'[`i'] 
                          `pvar3'[`i']; 	
	                   };
	   if (`nbsec'==4) {;
                          .`table'.row _group[`i'] 
                          `pvar1'[`i']
				  `pvar2'[`i'] 
                          `pvar3'[`i']
			        `pvar4'[`i']; 	
	                   };

	   if (`nbsec'==5) {;
                          .`table'.row _group[`i'] 
                          `pvar1'[`i']
				  `pvar2'[`i'] 
                          `pvar3'[`i']
			        `pvar4'[`i']
				  `pvar5'[`i']; 	
	                   };
         if (`nbsec'==6) {;
                          .`table'.row _group[`i'] 
                          `pvar1'[`i']
				  `pvar2'[`i'] 
                          `pvar3'[`i']
			        `pvar4'[`i']
                          `pvar5'[`i']
				  `pvar6'[`i']; 	
	                   };
if (`pop'==1 & `i'==`q_rep') .`table'.sep, mid;

};

.`table'.sep,bot;

};


if (`model'==2) {;

if (`nbsec'>1) {; 
       local  tab_col=`nbsec'+2;
       local line2="`line2'"+" 16";
       local line3="`line3'"+" %16.`dec'f";
       };


tempname table;
.`table'  = ._tab.new, col(`tab_col');
.`table'.width   `line2';
.`table'.numfmt  `line3';
di _n as text in white "{col `tab_col'}`title'";
.`table'.sep, top;
if (`nbsec'==1)	.`table'.titles "Groups  " "`lbs1'"   ;
if (`nbsec'==2)	.`table'.titles "Groups  " "`lbs1'" "`lbs2'"   "All"  ;	
if (`nbsec'==3)	.`table'.titles "Groups  " "`lbs1'" "`lbs2'"  "`lbs3'"   "All"  ;
if (`nbsec'==4)	.`table'.titles "Groups  " "`lbs1'" "`lbs2'"  "`lbs3'"  "`lbs4'"    "All"  ;
if (`nbsec'==5)	.`table'.titles "Groups  " "`lbs1'" "`lbs2'"  "`lbs3'"  "`lbs4'" "`lbs5'"   "All"   ;
if (`nbsec'==6)	.`table'.titles "Groups  " "`lbs1'" "`lbs2'"  "`lbs3'"  "`lbs4'" "`lbs5'" "`lbs6'"  "All" ;

local q_rep=`quant_rep';
if (`pop'==1) {;
local quant_rep=`quant_rep'+1;
};
.`table'.sep, mid;	
forvalues i=1/`quant_rep' {;
         if (`nbsec'==1) {;
                          .`table'.row _group[`i'] 
                          `pvar1'[`i']; 	
	                   };
         if (`nbsec'==2) {;
                          .`table'.row _group[`i'] 
                          `pvar1'[`i']
				  `pvar2'[`i']
                          `tvar'[`i'];	
	                   };
	   if (`nbsec'==3) {;
                          .`table'.row _group[`i'] 
                          `pvar1'[`i']
				  `pvar2'[`i'] 
                          `pvar3'[`i'] 
                          `tvar'[`i'];	
	                   };
	   if (`nbsec'==4) {;
                          .`table'.row _group[`i'] 
                          `pvar1'[`i']
				  `pvar2'[`i'] 
                          `pvar3'[`i']
			        `pvar4'[`i']
                          `tvar'[`i'];	
	                   };

	   if (`nbsec'==5) {;
                          .`table'.row _group[`i'] 
                          `pvar1'[`i']
				  `pvar2'[`i'] 
                          `pvar3'[`i']
			        `pvar4'[`i']
				  `pvar5'[`i'] 
                          `tvar'[`i'];	
	                   };
         if (`nbsec'==6) {;
                          .`table'.row _group[`i'] 
                          `pvar1'[`i']
				  `pvar2'[`i'] 
                          `pvar3'[`i']
			        `pvar4'[`i']
                          `pvar5'[`i']
				  `pvar6'[`i'] 
                          `tvar'[`i'];	
	                   };
if (`pop'==1 & `i'==`q_rep') .`table'.sep, mid;

};
.`table'.sep,bot;

};

end;
