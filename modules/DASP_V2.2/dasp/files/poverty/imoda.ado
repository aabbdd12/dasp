/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.2)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : imoda                                                      */
/* 1- Chakravarty et al (1998)   		: eq(06) // Union              */
/* 2- Extended Watts             		: eq(08) // Union              */
/* 3- Extended FGT               		: eq(09) // Intersection       */
/* 4- Tsui (2002)                		: eq(10) // Intersection       */
/* 5- Intersection headcount index                                     */
/* 6- Union headcount index                                            */ 
/* 7- Bourguignon and Chakravarty (2003) 	: eq(14) //                    */  
/* 8- Alkire and Foster  (2007) 	            :  //                    */                                 
/*************************************************************************/

/* 
H is programmed
add 
the 
M0

*/

#delim ;

capture program drop imoda2;
program define imoda2, rclass;
version 9.2;
syntax varlist [,  HSize(string)  SWeight(string) HGroup(varname) GNumber(int -1)
nembarg(int 1) 
ALPHA(real 1) 
PL1(real 0)  PL2(real 0) PL3(real 0)  
DSTE(int 0) index (string) detail(int 0)
];

preserve;
tokenize `varlist';
tempvar hs hs2 hs3;
gen `hs'  =`hsize';
gen `hs2' =2*`hsize';
gen `hs3' =3*`hsize';

if (`gnumber'!=-1)    {;
qui replace `hs'   =`hs'*(`hgroup'==`gnumber');
qui replace `hs2'  =`hs2'*(`hgroup'==`gnumber');
qui replace `hs3'  =`hs3'*(`hgroup'==`gnumber');

};

forvalues i=1/19   {;
tempvar num`i' num0`i';
qui gen `num`i'' = 0 ;
qui gen `num0`i'' = 0 ;
};
local pos = 1;
forvalues i=1/3   {;
qui replace `num`pos'' = `hs'*(``i''<`pl`i'')  ;
qui replace `num0`pos''= `hs'*(``i''<`pl`i'')  ;
local pos = `pos'+1 ;
};

forvalues i=1/3   {;
forvalues j=`i'/3 {;
if `j'!=`i' {;
qui replace `num`pos'' = `hs'*(``i''<`pl`i'')*(``j''<`pl`j'')  ;
qui replace `num0`pos''= `hs'*(``i''<`pl`i'')*(``j''<`pl`j'')*((``i''<`pl`i'')+(``j''<`pl`j''))  ;
local pos = `pos'+1;
};
};
};

qui replace `num`pos'' = `hs'*(`1'<`pl1')*(`2'<`pl2')*(`3'<`pl3')  ;
qui replace `num0`pos''= `hs'*(`1'<`pl1')*(`2'<`pl2')*(`3'<`pl3')*((`1'<`pl1')+(`2'<`pl2')+(`3'<`pl3'))  ;
local pos = `pos'+1;

forvalues i=1/3   {;
forvalues j=`i'/3 {;
if `j'!=`i' {;
qui replace `num`pos'' = `hs'* ((``i''<`pl`i'') | (``j''<`pl`j''))  ;
qui replace `num0`pos''= `hs'* ((``i''<`pl`i'') | (``j''<`pl`j''))*((``i''<`pl`i'')+(``j''<`pl`j''))  ;
local pos = `pos'+1;
};
};
};

qui replace `num`pos'' = `hs'* ((`1'<`pl1') | (`2'<`pl2') | (`3'<`pl3'))  ;
qui replace `num0`pos''= `hs'* ((`1'<`pl1') | (`2'<`pl2') | (`3'<`pl3'))*((`1'<`pl1')+(`2'<`pl2')+(`3'<`pl3'))   ;

local pos = `pos'+1;

qui replace `num`pos'' = `hs'* ((`1'<`pl1') & (`2'<`pl2') | (`1'<`pl1') & (`3'<`pl3') | (`2'<`pl2') & (`3'<`pl3') )  ;

qui replace `num0`pos''= `hs'* ((`1'<`pl1') & (`2'<`pl2') | (`1'<`pl1') & (`3'<`pl3') | (`2'<`pl2') & (`3'<`pl3') )*((`1'<`pl1')+(`2'<`pl2')+(`3'<`pl3'))   ;
local pos = `pos'+1;
qui replace `num0`pos''   = `hs'* ((`1'<`pl1') | (`2'<`pl2') | (`3'<`pl3'))*((`1'<`pl1')+(`2'<`pl2')+(`3'<`pl3'))   ;


if (`detail' == 1) {;
qui replace `num13' =  `num1'  - `num4'   ;
qui replace `num14' =  `num2'  - `num4' ;

qui replace `num15' = `num1' - `num5' ;
qui replace `num16' = `num3' - `num5'  ;

qui replace `num17' = `num2' - `num6'  ;
qui replace `num18' = `num3' - `num6' ;


};


/*
qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');

return scalar est  = `est';
return scalar std  = `std';
return scalar lb   = `est' - `tt'*`std';
return scalar ub   = `est' + `tt'*`std';

*/
local nest = 13;
if `detail' == 1 local nest = 18;
if (`dste'==1 ) {;

forvalues i=1/`nest'   {;


qui svy: ratio `num`i''/`hs';
cap drop matrix _aa;
matrix _aa=e(b);
local est = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local ste = el(_vv,1,1)^0.5;

return scalar est`i'  = `est'*100;
return scalar ste`i'  = `ste'*100;
};
};

if (`dste'==0 ) {;
cap drop `numa'; tempvar numa; qui gen `numa'=`hs'*`sweight'; qui sum `numa', meanonly; local mu1= `r(mean)';

forvalues i=1/`nest'   {;
cap drop `numa'; tempvar numa; qui gen `numa'=`num`i''*`sweight'; qui sum `numa', meanonly; 
return scalar est`i'  = `r(mean)'/`mu1'*100;
return scalar ste`i'  = 0;
};
};



if (`dste'==1 ) {;

forvalues i=1/13   {;
cap drop `dev'; tempvar dev; qui gen `dev' = .;

if `i'<=3 qui replace `dev' = `hs';
if `i'>=4 & `i'<=10 & `i'!=7  qui replace `dev' = `hs2';
if `i'==12 qui replace `dev' = `hs2';
if `i'==7 |`i'==11 | `i'==12 |  `i'==13  qui replace `dev' = `hs3';
qui svy: ratio `num0`i''/`dev';
cap drop matrix _aa;
matrix _aa=e(b);
local est = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local ste = el(_vv,1,1)^0.5;

return scalar est0`i'  = `est'*100;
return scalar ste0`i'  = `ste'*100;
};
};



if (`dste'==0 ) {;

forvalues i=1/13   {;
cap drop `dev'; tempvar dev; qui gen `dev' = .;
if `i'<=3 qui replace `dev' = `hs';
if `i'>=4 & `i'<=10 & `i'!=7  qui replace `dev' = `hs2';
if `i'==12 qui replace `dev' = `hs2';
if `i'==7 |`i'==11 | `i'==12 |  `i'==13   qui replace `dev' = `hs3';
cap drop `numa'; tempvar numa; qui gen `numa'=`dev'*`sweight'; qui sum `numa', meanonly; local mu1= `r(mean)';
cap drop `numa'; tempvar numa; qui gen `numa'=`num0`i''*`sweight'; qui sum `numa', meanonly; 
return scalar est0`i'  = `r(mean)'/`mu1'*100;
return scalar ste0`i'  = 0;
};
};


end;

#delim ;




capture program drop imoda;
program define imoda, rclass;
version 9.2;
syntax varlist(min=1)[,  
HSize(varname)
HGroup(varname)
dec(int 2)
alpha(real 1)  

SN1(string)  SN2(string) SN3(string)
PL1(real 0)  PL2(real 0) PL3(real 0)  
DSTE(int 0)
CONF(string)
LEVEL(real 95) 
detail(int 0)
];


qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

global indicag=0;
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

tempvar sw; qui gen `sw'=1;
if (`"`hweight'"'~="") qui replace `sw'=`hweight';


if ("`hgroup'"!="") {;

preserve;
capture {;
local lvgroup:value label `hgroup';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , clear;
qui count;
forvalues i=1/`r(N)' {;
local tem=value[`i'];
local grlab`tem' = label[`i'];
};
};
restore;
};

preserve;
qui tabulate `hgroup', matrow(gn);
svmat int gn;
global indicag=r(r);
tokenize `varlist';
};


tokenize  `varlist';
_nargs    `varlist';



local ci=100-`level';
local pos = 1;
tempvar Variable Dime ;
qui gen `Variable'="";
qui gen `Dime'="";

forvalues i=1/3   {;
qui replace `Variable'="Dim`i'" in `pos' ;
qui replace `Dime'="Dim`i'" in `pos' ;
local pos = `pos'+1 ;
};

forvalues i=1/3   {;
forvalues j=`i'/3 {;
if `j'!=`i' {;qui replace `Variable'="IN: Dim`i' - Dim`j'"  in `pos' ;
qui replace `Dime'="Dim`i' - Dim`j'"  in `pos' ;
local pos = `pos'+1;
};
};
};

qui replace `Variable'="IN: Dim1 - Dim2 - Dim3  "  in `pos' ;
qui replace `Dime'="Dim1 - Dim2 - Dim3 "  in `pos' ;


local pos = `pos'+1;
qui replace `Dime'="Cut-off = 2 "  in `pos' ;
forvalues i=1/3   {;
forvalues j=`i'/3 {;
if `j'!=`i' {;
qui replace `Variable'="UN: Dim`i' - Dim`j'"  in `pos' ;
local pos = `pos'+1;
};
};
};

qui replace `Variable'="UN: Dim1 - Dim2 - Dim3  "  in `pos' ;







tempvar  union sunion inter sinter;
qui gen `union'=0;
qui gen `sunion'=0;
qui gen `inter'=0;
qui gen `sinter'=0;


tempvar  union0 sunion0 inter0 sinter0;
qui gen `union0'=0;
qui gen `sunion0'=0;
qui gen `inter0'=0;
qui gen `sinter0'=0;


tempvar   det1 det2 det3 det4;
qui gen `det1'=0;
qui gen `det2'=0;
qui gen `det3'=0;
qui gen `det4'=0;

tempvar   sdet1 sdet2 sdet3 sdet4 Dimedet;
qui gen `sdet1'=0;
qui gen `sdet2'=0;
qui gen `sdet3'=0;
qui gen `sdet4'=0;
qui gen `Dimedet'="";

qui replace `Dimedet'="D1:Dim1 // D2:Dim2"  in 1 ;
qui replace `Dimedet'="D1:Dim1 // D2:Dim3"  in 2 ;
qui replace `Dimedet'="D1:Dim2 // D2:Dim3"  in 3 ;

tempvar _ths _fw;

qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';
qui gen `_fw'=`_ths';
if (`"`hweight'"'~="") qui replace `_fw'=`_fw'*`hweight';

local ll = 12;
local k=1;
tempvar _ths;
qui gen `_ths'=1;


if ( "`hsize'"!="") qui replace `_ths'=`hsize';


set more off;
set tracedepth 2;
imoda2 `varlist', sweight(`sw') hsize(`_ths') 
pl1(`pl1')  pl2(`pl2') pl3(`pl3') dste(`dste') detail(`detail');


forvalues i=1/3 {;
qui replace `union' = `r(est`i')'  in `i';
qui replace `sunion' = `r(ste`i')' in `i';

qui replace `inter' = `r(est`i')'  in `i';
qui replace `sinter' = `r(ste`i')' in `i';

qui replace `union0' = `r(est0`i')'  in `i';
qui replace `sunion0' = `r(ste0`i')' in `i';

qui replace `inter0' = `r(est0`i')'  in `i';
qui replace `sinter0' = `r(ste0`i')' in `i';

};

forvalues i=4/6 {;
qui replace `union' = `r(est`i')'  in `i';
qui replace `sunion' = `r(ste`i')' in `i';

qui replace `union0' = `r(est0`i')'  in `i';
qui replace `sunion0' = `r(ste0`i')' in `i';

local z=`i'+4;
qui replace `inter' = `r(est`z')'  in `i';
qui replace `sinter' = `r(ste`z')' in `i';

qui replace `inter0' = `r(est0`z')'  in `i';
qui replace `sinter0' = `r(ste0`z')' in `i';
};

qui replace `union'  = `r(est7)'   in 7;
qui replace `sunion' = `r(ste7)'   in 7;

qui replace `inter'  = `r(est11)'   in 7;
qui replace `sinter' = `r(ste11)'   in 7;

qui replace `union0'  = `r(est07)'   in 7;
qui replace `sunion0' = `r(ste07)'   in 7;



qui replace `inter0'  = `r(est011)'   in 7;
qui replace `sinter0' = `r(ste011)'   in 7;



qui replace `inter'  = `r(est12)'   in 8;
qui replace `sinter' = `r(ste12)'   in 8;

qui replace `inter0'  = `r(est012)'   in 8;
qui replace `sinter0' = `r(ste012)'   in 8;

qui replace `inter'  = `r(est13)'   in 9;
qui replace `sinter' = `r(ste13)'   in 9;

qui replace `inter0'  = `r(est013)'   in 9;
qui replace `sinter0' = `r(ste013)'   in 9;





/**********************/
forvalues i=4/6 {;
local j = `i'-3;
qui replace `det2' = `r(est`i')'  in `j';
qui replace `sdet2' = `r(ste`i')' in `j';

local z=`i'+4;
qui replace `det1' = `r(est`z')'  in `j';
qui replace `sdet1' = `r(ste`z')' in `j';
};

forvalues i=1/3 {;
local j = 11 + 2*`i' ;
qui replace `det3'  =   `r(est`j')'  in `i'; 
qui replace `sdet3'  =  `r(ste`j')'   in `i'; 
local j = 11 + 2*`i' +1;
qui replace `det4'  =   `r(est`j')'  in `i'; 
qui replace `sdet4'  =  `r(ste`j')'   in `i'; 
};



/***************************/


if ("`hgroup'"~=""){;

forvalues k=1/$indicag {; 

tempvar  union`k' sunion`k' inter`k' sinter`k';
qui gen `union`k''=0;
qui gen `sunion`k''=0;
qui gen `inter`k''=0;
qui gen `sinter`k''=0;

tempvar  union0`k' sunion0`k' inter0`k' sinter0`k';
qui gen `union0`k''=0;
qui gen `sunion0`k''=0;
qui gen `inter0`k''=0;
qui gen `sinter0`k''=0;


local kk = gn1[`k'];

imoda2 `varlist', hsize(`_ths') sweight(`sw') 
pl1(`pl1')  pl2(`pl2') pl3(`pl3') 
 hgroup(`hgroup') gnumber(`kk') dste(`dste') detail(`detail');;

forvalues i=1/3 {;
qui replace `union`k'' = `r(est`i')'  in `i';
qui replace `sunion`k'' = `r(ste`i')' in `i';

qui replace `inter`k'' = `r(est`i')'  in `i';
qui replace `sinter`k'' = `r(ste`i')' in `i';

qui replace `union0`k'' = `r(est0`i')'  in `i';
qui replace `sunion0`k'' = `r(ste`i')' in `i';

qui replace `inter0`k'' = `r(est0`i')'  in `i';
qui replace `sinter0`k'' = `r(ste0`i')' in `i';
};

forvalues i=4/6 {;
qui replace `union`k'' = `r(est`i')'  in `i';
qui replace `sunion`k'' = `r(ste`i')' in `i';

qui replace `union0`k'' = `r(est0`i')'  in `i';
qui replace `sunion0`k'' = `r(ste0`i')' in `i';

local z=`i'+4;
qui replace `inter`k'' = `r(est`z')'  in `i';
qui replace `sinter`k'' = `r(ste`z')' in `i';

qui replace `inter0`k'' = `r(est0`z')'  in `i';
qui replace `sinter0`k'' = `r(ste0`z')' in `i';
};

qui replace `union`k''  = `r(est7)'   in 7;
qui replace `sunion`k'' = `r(ste7)'   in 7;

qui replace `inter`k''  = `r(est11)'   in 7;
qui replace `sinter`k'' = `r(ste11)'   in 7;

qui replace `union0`k''  = `r(est07)'   in 7;
qui replace `sunion0`k'' = `r(ste07)'   in 7;

qui replace `inter0`k''  = `r(est011)'   in 7;
qui replace `sinter0`k'' = `r(ste011)'   in 7;


qui replace `inter`k''  = `r(est12)'   in 8;
qui replace `sinter`k'' = `r(ste12)'   in 8;

qui replace `inter0`k''  = `r(est012)'   in 8;
qui replace `sinter0`k'' = `r(ste012)'   in 8;

qui replace `inter`k''  = `r(est13)'   in 9;
qui replace `sinter`k'' = `r(ste13)'   in 9;

qui replace `inter0`k''  = `r(est013)'   in 9;
qui replace `sinter0`k'' = `r(ste013)'   in 9;




};
};

  set more off;

  tempname table;
	.`table'  = ._tab.new, col(6)  separator(0) lmargin(0);


	   if ("`hsize'"!="")   di as text     "{col 1}Multiple Overlapping Deprivation Analysis     ";
       if ("`hsize'"!="")   di as text     "{col 2}Household size     :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 2}Sampling weight    :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 2}Group variable     :  `hgroup'";
	      .`table'.width  1  16 16 16 16 16;
		  
   .`table'.row "Notes:" "" "" "" "" "";
   .`table'.row "  - Dim1:  `sn1'" "" "" "" "" "";
   .`table'.row "  - Dim2:  `sn2'" "" "" "" "" "";
   .`table'.row "  - Dim3:  `sn3'" "" "" "" "" "";
   .`table'.width  | 20 | 16 16 | 16 16 16|;
 
    
	.`table'.strcolor . . yellow  yellow  yellow  yellow ;


       if ("`hgroup'"~="")  dis as text    "Results for the whole population" ;
	  .`table'.sep, top;
	 .`table'.width  | 20 | 22 10 | 24 12 12|;  
	 
	.`table'.titles "Index" "    Headcount (H)"" ""   M0""" ""	 ;
	
	.`table'.width  | 20 | 16 16 | 16 16 16 |;  
	
	.`table'.numcolor yellow yellow .  yellow yellow  yellow ;
	.`table'.strcolor . . yellow  yellow  yellow  yellow ;
	
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f  %16.`dec'f  %16.`dec'f;
	
	.`table'.sep, mid;
	.`table'.titles "Dimensions" "Union" "Intersection" "Cut-off = 1" "Cut-off = 2" "Cut-off = 3" 	 ;
	 
	.`table'.sep, mid;
	local nalt = "ddd";
     
			.`table'.row " - One dimension:" "" "" "" "" "" ;
		forvalues k=1/3 {; 
						        .`table'.row             `Dime'[`k'] `inter'[`k'] `union'[`k']   `inter0'[`k']  "---"  "---"; 
								 if `dste' == 1    .`table'.row " " `sinter'[`k'] `sunion'[`k'] `sinter0'[`k'] "---" "---" ; 
								
						       };
							  
		 .`table'.row "" "" "" "" "" "";	
		 .`table'.row " - Two dimensions:" "" "" "" "" "";					   
							   	forvalues k=4/6 {; 
						                           .`table'.row `Dime'[`k'] `inter'[`k'] `union'[`k']  `inter0'[`k'] `union0'[`k'] "---"; 
								 if `dste' == 1    .`table'.row " " `sinter'[`k'] `sunion'[`k']  `sinter0'[`k'] `sunion0'[`k'] "---"; 
						       };
							   
				 .`table'.row "" "" "" "" "" "" ;				 
				 .`table'.row " - Three dimensions:" "" "" "" "" "" ;
				local k=7;
                  .`table'.row `Dime'[`k']             `inter'[`k']    `union'[`k']      `inter0'[9]    `inter0'[8]   `union0'[7] ;
				   if `dste' == 1    .`table'.row " "  `sinter'[`k']  `sunion'[`k']     `sinter0'[9]   `sinter0'[8]   `sunion0'[7] ; 
				
					.`table'.sep,bot; 
                              
				 
				 
			 
	if (`detail'==1) {;
	  dis " Detailed results for the headcount index (H) and two dimensions:";
	  .`table'  = ._tab.new, col(5)  separator(0) lmargin(0);
	.`table'.width  | 20 | 24 | 24 | 20 | 20|;  
	.`table'.numcolor yellow yellow .  yellow yellow ;
	.`table'.strcolor . . yellow  yellow  yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f  %16.`dec'f ;
	.`table'.sep, top;
	.`table'.titles "Dimensions" "Union: D1 OR D2" "Intersection: D1 and D2" "D1 and not D2" "D2 and not D1" 	 ;
	 
	.`table'.sep, mid;
	local nalt = "ddd";
      
		 				   
							   	forvalues k=1/3 {; 
						                           .`table'.row `Dimedet'[`k'] `det1'[`k'] `det2'[`k']  `det3'[`k'] `det4'[`k'] ; 
								 if `dste' == 1    .`table'.row " " `sdet1'[`k'] `sdet2'[`k']  `sdet3'[`k'] `sdet4'[`k'] ; 
						       };
		.`table'.sep, bottom;					   
       };
	   
	   
	   
	
	
   
   if ("`hgroup'"~=""){;
 
forvalues g=1/$indicag {; 

local kk = gn1[`g'];
local ll=max(`ll',length("`kk': `grlab`g''"));
if ( "`grlab`kk''" == "") local grlab`kk' = "Group_`kk'";

 dis as text    "- Results for the group: `grlab`kk''" ;
 
 
 tempname table;
	.`table'  = ._tab.new, col(6)  separator(0) lmargin(0);
	      .`table'.width  1  16 16 16 16 16;
		  
   .`table'.row "Notes:" "" "" "" "" "";
   .`table'.row "  - Dim1:  `sn1'" "" "" "" "" "";
   .`table'.row "  - Dim2:  `sn2'" "" "" "" "" "";
   .`table'.row "  - Dim3:  `sn3'" "" "" "" "" "";
   .`table'.width  | 20 | 16 16 | 16 16 16|;
 
    
	.`table'.strcolor . . yellow  yellow  yellow  yellow ;


       if ("`hgroup'"~="")  dis as text    "Results for the whole population" ;
	  .`table'.sep, top;
	 .`table'.width  | 20 | 22 10 | 24 12 12|;  
	 
	.`table'.titles "Index" "    Headcount (H)"" ""   M0""" ""	 ;
	
	.`table'.width  | 20 | 16 16 | 16 16 16 |;  
	
	.`table'.numcolor yellow yellow .  yellow yellow  yellow ;
	.`table'.strcolor . . yellow  yellow  yellow  yellow ;
	
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f  %16.`dec'f  %16.`dec'f;
	
	.`table'.sep, mid;
	.`table'.titles "Dimensions" "Union" "Intersection" "Cut-off = 1" "Cut-off = 2" "Cut-off = 3" 	 ;
	 
	.`table'.sep, mid;
	local nalt = "ddd";
     
			.`table'.row " - One dimension:" "" "" "" "" "" ;
		forvalues k=1/3 {; 
						        .`table'.row             `Dime'[`k'] `inter`g''[`k'] `union`g''[`k']   `inter0`g''[`k']  "---"  "---"; 
								 if `dste' == 1    .`table'.row " " `sinter`g''[`k'] `sunion`g''[`k'] `sinter0`g''[`k'] "---" "---" ; 
								
						       };
							  
		 .`table'.row "" "" "" "" "" "";	
		 .`table'.row " - Two dimensions:" "" "" "" "" "";					   
							   	forvalues k=4/6 {; 
						                           .`table'.row `Dime'[`k'] `inter`g''[`k'] `union`g''[`k']  `inter0`g''[`k'] `union0`g''[`k'] "---"; 
								 if `dste' == 1    .`table'.row " " `sinter`g''[`k'] `sunion`g''[`k']  `sinter0`g''[`k'] `sunion0`g''[`k'] "---"; 
						       };
							   
				 .`table'.row "" "" "" "" "" "" ;				 
				 .`table'.row " - Three dimensions:" "" "" "" "" "" ;
				local k=7;
                  .`table'.row `Dime'[`k']             `inter`g''[`k']    `union`g''[`k']      `inter0`g''[9]    `inter0`g''[8]   `union0`g''[7] ;
				   if `dste' == 1    .`table'.row " "  `sinter`g''[`k']  `sunion`g''[`k']     `sinter0`g''[9]   `sinter0`g''[8]   `sunion0`g''[7] ; 
				
					.`table'.sep,bot; 
                              
				 
				 
			 

	   
 
};
};





end;


*set trace on;
/*
set more off;
set tracedepth 2;
imoda nsc_hab nsc_san nsc_etu, hsize(s00q9)  pl1(1) pl2(1) pl3(1) sn1(Housing) sn2(Health) sn3(Education)   dste(0)
detail(1)
;

*/
/* hg(s00q7) */

