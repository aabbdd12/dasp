/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3  )          */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : cdensity                                                    */
/*************************************************************************/

#delim ;


capture program drop borderrec;
program define borderrec, rclass;
version 9.2;
args y ll ul min max band order;
preserve;

cap drop _corr1; 
gen _corr1=0;
cap drop _corr2; 
gen _corr2=0;
cap drop _corr3; 
gen _corr3=0;

tempvar ra;
qui gen `ra'=`min'+(_n-1)*(`max'-`min')/100 in 1/101;


local raf=4000;
qui count;
if `r(N)' < `raf' qui set obs `raf';
keep in 1/`raf';
tempvar d xd xxd xxxd xxxxd;



cap drop _x_;
qui gen _x_= -50+(_n-1)*100/`raf';

qui gen `xd'     = _x_*exp(-0.5*_x_^2)/(sqrt(2*c(pi)));
qui gen `xxd'    = _x_*_x_*exp(-0.5*_x_^2)/(sqrt(2*c(pi)));
qui gen `xxxd'   = _x_*_x_*_x_*exp(-0.5*_x_^2)/(sqrt(2*c(pi)));
qui gen `xxxxd'  = _x_*_x_*_x_*_x_*exp(-0.5*_x_^2)/(sqrt(2*c(pi)));

cap drop _aa;
cap drop _bb;
qui gen _aa = (`ra'-`ul')/`band'; 
qui gen _bb = (`ra'-`ll')/`band';

local mina = r(min); local maxa= r(max); 


 forvalues i=1/101 {; 
 local t1=max(`mina', _aa[`i']); 
 local t2=min(`maxa', _bb[`i']);

 local int11 =  normal(_bb[`i']) - normal(_aa[`i']); 
 /*
 set trace on;
 set tracedepth 1;
 set more off;
 */
 if (`order'>=2) {;
 

 

 qui integ `xd'  _x_  if (_x_ >= `t1' & _x_<= `t2');
 local int12= r(integral);
 local int21 = `int12';

 
 qui integ `xxd'  _x_ if (_x_ >= `t1' & _x_<= `t2');
 local int22= r(integral); 
 if (`order'==2) {; 
 matrix M=(
          `int11',`int12'\
          `int21',`int22'
          ); 
 matrix IM = inv(M);
 qui replace _corr1=el(IM,1,1) in `i'; 
 qui replace _corr2=el(IM,1,2) in `i'; 
 };     
 };

 if (`order'==3) {;
 local int13=`int22'/2;
 local int31=`int13';
 
 qui integ `xxxd' _x_ if (_x_ >= `t1' & _x_<= `t2');

 local int23 = r(integral)/2;
 local int32 = `int23';
 qui integ `xxxxd' _x_ if (_x_ >= `t1' & _x_<= `t2');
 local int33 = r(integral)/4;
 matrix M=(
          `int11',`int12', `int13'\
          `int21',`int22', `int23'\
          `int31',`int32', `int33'
          );

   
 matrix IM = inv(M);
 qui replace _corr1=el(IM,1,1) in `i'; 
 qui replace _corr2=el(IM,1,2) in `i'; 
 qui replace _corr3=el(IM,1,3) in `i';  
 };
  
};

qui keep in 1/101;
set matsize 101;
cap matrix drop _co;
mkmat _corr1 _corr2 _corr3, matrix (_co);
restore;
end;




capture program drop cdensity2;
program define cdensity2, rclass;
version 9.2;
args www yyy min max band type border bcor  popb gr ng ;

cap drop if `yyy'>=.;
cap drop if `www'>=.;
qui count;
preserve;
tempvar _s2;
gen `_s2' = sum( `www' ); 

if ("`gr'" ~="") qui keep if (`gr'==gn1[`ng']);
if (`popb'==1) {;
cap drop `_s2';
tempvar _s2;
gen `_s2' = sum( `www' ); 
};

qui sum `yyy'; local ll=`r(min)' ; local ul =`r(max)';
local posa = `r(N)' ;

qui count;
if (`r(N)'<101) set obs 101;


tempvar  _density _ra;
qui gen `_ra'=0;
qui gen `_density'=0;
local pas = (`max'-`min')/100;
if (_N<101) qui set obs 101;
qui su `yyy' [aw=`www'], detail;            
local tmp = (`r(p75)'-`r(p25)')/1.34;                           
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)';     
local h   = 0.9*`tmp'*`posa'^(-1.0/5.0); 
if (`band'==0) local band=`h';  




if ("`bcor'" == "renor" )  {;
 borderrec `yyy' `ll' `ul' `min' `max' `band' `border';
svmat float _co;
cap matrix drop _co;
rename _co1 _corr1;
rename _co2 _corr2;
rename _co3 _corr3;
};

forvalues j=1/101 {;
cap drop `_s1'; 
tempvar  _s1;

qui replace `_ra'=`min'+(`j'-1)*`pas' in `j';
                      
if ("`type'" =="den")    qui gen `_s1' =   `www'*exp(-0.5* ( ((`_ra'[`j']-`yyy')/`band')^2  )  );  
if ("`type'" =="dde")    qui gen `_s1' =   `www'*((`yyy'-`_ra'[`j'])/(`band'^2))*exp(-0.5* ( ((`_ra'[`j']-`yyy')/`band')^2  )  );

if ("`bcor'" == "renor" ) {; 

if (`border' ==1)   {;  
                   local corr = 1 / ( normal((`ul'-`_ra'[`j'])/`band') - normal((`ll'-`_ra'[`j'])/`band') );
                   if ( `_ra'[`j']<`ll' | `_ra'[`j'] > `ul' ) qui replace `_s1'=0;
                   
                   qui replace `_s1'=`_s1'*`corr';
                   };

if (`border' ==2)   {;        
                   qui replace `_s1'= ( _corr1[`j'] + ((`_ra'[`j']-`yyy')/`band')*_corr2[`j'] )*`_s1';
                   if ( `_ra'[`j']<`ll' | `_ra'[`j'] > `ul' ) qui replace `_s1'=0;
                   };

if (`border' ==3)   {;        
                   qui replace `_s1'= ( _corr1[`j'] + ((`_ra'[`j']-`yyy')/`band')*_corr2[`j'] + ((`_ra'[`j']-`yyy')/`band')^2/2*_corr3[`j'] )*`_s1';
                   if ( `_ra'[`j']<`ll' | `_ra'[`j'] > `ul' ) qui replace `_s1'=0;
                   };

};

if ("`bcor'" == "reflec" ) {; 

if ("`type'" =="den")  {; 

qui replace `_s1' =  `_s1'+ `www'*exp(-0.5* ( ((`_ra'[`j']+`yyy'-2*`ll')/`band')^2  )  ) + `www'*exp(-0.5* ( ((`_ra'[`j']+`yyy'-2*`ul')/`band')^2  )  ); 

};

if ("`type'" =="dde")    {;
qui replace `_s1' =   `_s1'+

 ((`yyy'+`_ra'[`j']-2*`ll')/(`band'^2))*((`yyy'+`_ra'[`j']-2*`ll')/(`band'^2))*`www'*exp(-0.5* ( ((`_ra'[`j']+`yyy'-2*`ll')/`band')^2  )  )
+ 
 ((`yyy'+`_ra'[`j']-2*`ul')/(`band'^2))*((`yyy'+`_ra'[`j']-2*`ul')/(`band'^2))*`www'*exp(-0.5* ( ((`_ra'[`j']+`yyy'-2*`ul')/`band')^2  )  );

};

};

qui sum `_s1'; local sum1=`r(sum)';
if ("`type'" =="den")  local sum1=max(0,`r(sum)');
qui replace `_density'= `sum1'/( `band'* sqrt(2*c(pi)) * `_s2'[`posa'] )  in `j';


};
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat `_density', matrix (_xx);
restore;
end;





capture program drop borderrec1;
program define borderrec1, rclass;
version 9.2;
args y ll ul xval band order;
preserve;

local co1 = 0 ; 
local co2 = 0 ; 
local co3 = 0) ; 

local raf=4000;
qui count;
if `r(N)' < `raf' qui set obs `raf';
keep in 1/`raf';
tempvar d xd xxd xxxd xxxxd;



cap drop _x_;
qui gen _x_= -50+(_n-1)*100/`raf';

qui gen `xd'     = _x_*exp(-0.5*_x_^2)/(sqrt(2*c(pi)));
qui gen `xxd'    = _x_*_x_*exp(-0.5*_x_^2)/(sqrt(2*c(pi)));
qui gen `xxxd'   = _x_*_x_*_x_*exp(-0.5*_x_^2)/(sqrt(2*c(pi)));
qui gen `xxxxd'  = _x_*_x_*_x_*_x_*exp(-0.5*_x_^2)/(sqrt(2*c(pi)));


local aa = (`xval'-`ul')/`band'; 
local bb = (`xval'-`ll')/`band';
qui sum `y';
local mina = r(min); 
local maxa = r(max); 

 local t1=max(`mina', `aa'); 
 local t2=min(`maxa', `bb');

 local int11 =  normal(`bb') - normal(`aa'); 
 if (`order'>=2) {;
 

 

 qui integ `xd'  _x_  if (_x_ >= `t1' & _x_<= `t2');
 local int12= r(integral);
 local int21 = `int12';

 
 qui integ `xxd'  _x_ if (_x_ >= `t1' & _x_<= `t2');
 local int22= r(integral); 
 if (`order'==2) {; 
 matrix M=(
          `int11',`int12'\
          `int21',`int22'
          ); 
 matrix IM = inv(M);
local co1 = el(IM,1,1) ; 
local co2 = el(IM,1,2) ; 
 };     
 };

 if (`order'==3) {;
 local int13=`int22'/2;
 local int31=`int13';
 
 qui integ `xxxd' _x_ if (_x_ >= `t1' & _x_<= `t2');

 local int23 = r(integral)/2;
 local int32 = `int23';
 qui integ `xxxxd' _x_ if (_x_ >= `t1' & _x_<= `t2');
 local int33 = r(integral)/4;
 matrix M=(
          `int11',`int12', `int13'\
          `int21',`int22', `int23'\
          `int31',`int32', `int33'
          );

   
 matrix IM = inv(M);
local co1 = el(IM,1,1) ; 
local co2 = el(IM,1,2) ; 
local co3 = el(IM,1,2) ; 
 qui replace _corr3=el(IM,1,3);  
 };
  
};

forvalues i=1/3{;
return scalar co`i' = `co`i'';
};
restore;
end;



capture program drop cdensity21;
program define cdensity21, rclass;
version 9.2;
args www yyy xval band type border bcor popb gr ng;

preserve;
cap drop if `yyy'>=.;
cap drop if `www'>=.;
qui count;

tempvar _s2;
gen `_s2' = sum( `www' ); 
if ("`gr'" ~="") qui keep if (`gr'==gn1[`ng']);
if (`popb'==1) {;
cap drop `_s2';
tempvar _s2;
gen `_s2' = sum( `www' ); 
};

qui sum `yyy'; local ll=`r(min)' ; local ul =`r(max)';

local posa = `r(N)';

if (`r(N)'<101) set obs 101;



if (_N<101) qui set obs 101;
qui su `yyy' [aw=`www'], detail;            
local tmp = (`r(p75)'-`r(p25)')/1.34;                           
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)';     
local h   = 0.9*`tmp'*`posa'^(-1.0/5.0); 
if (`band'==0) local band=`h';  




if ("`bcor'" == "renor" )  {;
 borderrec1 `yyy' `ll' `ul'  `xval' `band' `border';
local co1 =r(co1);
local co2 =r(co2);
local co3 =r(co3);
};


cap drop `_s1'; 
tempvar  _s1;

                      
if ("`type'" =="den")    qui gen `_s1' =   `www'*exp(-0.5* ( ((`xval'-`yyy')/`band')^2  )  );  
if ("`type'" =="dde")    qui gen `_s1' =   `www'*((`yyy'-`xval')/(`band'^2))*exp(-0.5* ( ((`xval'-`yyy')/`band')^2  )  );

if ("`bcor'" == "renor" ) {; 

if (`border' ==1)   {;  
                   local corr = 1 / ( normal((`ul'-`xval')/`band') - normal((`ll'-`xval')/`band') );
                   if ( `xval'<`ll' | `xval' > `ul' ) qui replace `_s1'=0;
                   
                   qui replace `_s1'=`_s1'*`corr';
                   };

if (`border' ==2)   {;        
                   qui replace `_s1'= ( `co1' + ((`xval'-`yyy')/`band')*`co2' )*`_s1';
                   if ( `xval'<`ll' | `xval' > `ul' ) qui replace `_s1'=0;
                   };

if (`border' ==3)   {;        
                   qui replace `_s1'= ( `co1' + ((`xval'-`yyy')/`band')*`co2' + ((`xval'-`yyy')/`band')^2/2*`co3' )*`_s1';
                   if ( `xval'<`ll' | `xval' > `ul' ) qui replace `_s1'=0;
                   };

};

if ("`bcor'" == "reflec" ) {; 

if ("`type'" =="den")  {; 

qui replace `_s1' =  `_s1'+ `www'*exp(-0.5* ( ((`xval'+`yyy'-2*`ll')/`band')^2  )  ) + `www'*exp(-0.5* ( ((`xval'+`yyy'-2*`ul')/`band')^2  )  ); 

};

if ("`type'" =="dde")    {;
qui replace `_s1' =   `_s1'+

 ((`yyy'+`xval'-2*`ll')/(`band'^2))*((`yyy'+`xval'-2*`ll')/(`band'^2))*`www'*exp(-0.5* ( ((`xval'+`yyy'-2*`ll')/`band')^2  )  )
+ 
 ((`yyy'+`xval'-2*`ul')/(`band'^2))*((`yyy'+`xval'-2*`ul')/(`band'^2))*`www'*exp(-0.5* ( ((`xval'+`yyy'-2*`ul')/`band')^2  )  );

};

};
qui sum `_s1'; local sum1=`r(sum)';
if ("`type'" =="den")  local sum1=max(0,`r(sum)');
local density= `sum1'/( `band'* sqrt(2*c(pi)) * `_s2'[`posa'] );


return scalar density = `density';
restore;
end;


capture program drop cdensity;
program define cdensity, rclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) HGroup(varname) TYPE(string) BAND(real 0) border(int 1) bcor(string)
  LRES(int 0) SRES(string) XVAL(real 10000) POPB(int 1) MIN(string) MAX(string) DGRA(int 1) SGRA(string) EGRA(string) DEC(int 12) *];
if ("`dif'"=="no") local dif="";

_get_gropts , graphopts(`options') ;
	local options `"`s(graphopts)'"';

if ("`type'" =="") local type = "den";
if ("`bcor'" =="") local bcor = "no";
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
tokenize `varlist';
};

if ("`hgroup'"=="") {;
tokenize `varlist';
_nargs    `varlist';
preserve;
};


qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local hweight=""; 
cap qui svy: total `1'; 
cap local hweight=`"`e(wvar)'"';
cap ereturn clear; 

tempvar fw;
local _cory  = "";
local label = "";


local dgr = "no";

if ("`max'" ~= "" ) local dgr = "yes";





quietly{;
gen `fw'=1;


if ($indica>1) local tits="s";
			    local ftitle = "Density curve`tits'";
if ("`type'" =="dde") local ftitle = "Derivative of density Curve`tits'";
				local ytitle = "f(y)";
if ("`type'" =="dde")   local ytitle = "df(y)/dy";
local xtitle = "y";
if ("`cytitle'"  ~="") local ytitle ="`cytitle'";
if ("`cxtitle'"  ~="") local xtitle ="`cxtitle'";

if ("`ctitle'"  ~="")     local ftitle ="`ctitle'";
if ("`hsize'"  ~="")      replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")      replace `fw'=`fw'*`hweight';
};

qui count;
qui sum `1';
if ("`min'"  =="")     local min =`r(min)';
if ("`max'"  =="")     local max =`r(max)';
if ("`type'"  =="")     local type ="yes";


forvalues k = 1/$indica {;

local _cory  = "`_cory'" + " _cory`k'";
local f=`k';
if ("`hgroup'"=="") {;
local label`f'  =  "``k''";

if ("`dgr'" == "yes" ) {;
cdensity2  `fw' ``k'' `min'   `max' `band' `type' `border' `bcor' `popb';
};
if ("`dgr'" == "no"  ) {;
cdensity21 `fw' ``k'' `xval' `band' `type' `border' `bcor' `popb';
local den`k' =r(density); 
};
};

if ("`hgroup'"!="") {;
local kk = gn1[`k'];
local label`f'  : label (`hgroup') `kk';
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";

if ("`dgr'" == "yes" ) cdensity2  `fw' `1' `min'   `max' `band' `type' `border' `bcor' `popb' `hgroup' `k' ;
if ("`dgr'" == "no" ) {;
                       cdensity21 `fw' `1' `xval'  `band' `type' `border' `bcor' `popb' `hgroup' `k' ;
local den`k' =r(density); 
};
};
if ("`dgr'" == "yes" ) {;
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _cory`k';
};
};

if ("`dgr'" == "yes" ) {;
qui count;
if (`r(N)'<101) set obs 101;

qui keep in 1/101;
gen _corx=0;
local m5  = (`max'-`min')/5;
local pas = (`max'-`min')/100;
forvalues j=1/101 {;
qui replace _corx=`min'+(`j'-1)*`pas' in `j';
};

if( `lres' == 1) {;
set more off;
list _corx _cory*;
};

if (`dgra'!=0) {;  
line `_cory'  _corx, 
legend(
label(1 `label1')
label(2 `label2')
label(3 `label3')
label(4 `label4')
label(5 `label5')
label(6 `label6')
label(7 `label7')
label(8 `label8')
label(9 `label9')
label(10 `label10')
label(11 `label11')
label(12 `label12')
)
title(`ftitle')
subtitle(`cstitle')
ytitle(`ytitle')
xtitle(`xtitle') 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))

plotregion(margin(zero))
`options'
;

;
};
cap matrix drop _xx;
if( "`sres'" ~= "") {;
keep _corx _cory*;
save `"`sres'"', replace;
};

if( "`sgra'" ~= "") {;
graph save `"`sgra'"', replace;
};

if( "`egra'" ~= "") {;
graph export `"`egra'"', replace;
};
restore;
};


if ("`dgr'" == "no" ) {;
local ll = 20;

tempvar Variable EST;
qui gen `Variable' = "";
qui gen `EST'=.;
forvalues k = 1/$indica {;

if ("`hgroup'"=="") {;
qui replace `EST'      = `den`k'' in `k';
local label`f'  =  "``k''";
qui replace `Variable' = "`label`f''" in `k';
local ll=max(`ll',length("`label`f''"));
};

if ("`hgroup'"!="") {;
qui replace `EST'      = `den`k'' in `k';
qui replace `Variable' = "`label`k''" in `k';
local ll=max(`ll',length("`label`k''"));
};

};




local comp = "Variable(s)";
if ("`hgroup'"!="") local comp = "Groups(s)";
      tempname table;
	.`table'  = ._tab.new, col(2);
	.`table'.width |`ll'|20 |;
	.`table'.strcolor . .   ;
	.`table'.numcolor yellow yellow  ;
	.`table'.numfmt %16.0g  %20.`dec'f  ;
  
       if ("`hsize'"!="")   di as text     "{col 4}Household size     :  `hsize'"  ;
       if ("`hweight'"!="") di as text     "{col 4}Sampling weight    :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 4}Group variable     :  `hgroup'" ;
  						  		
	.`table'.sep, top;
	.`table'.titles "`comp' " "Estimated value"    ;

	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/$indica{;
             .`table'.numcolor white yellow   ;
		     .`table'.row `Variable'[`i'] `EST'[`i']  ; 	        
             };
  if ("`hgroup'"=="") {;			 
  .`table'.sep,bot;
  };
  if ("`hgroup'"!="") {;
  /*
  .`table'.sep, mid;
    local i = $indica+1;
  .`table'.numcolor white yellow   ;
  .`table'.row `Variable'[`i'] `EST'[`i']  ; 
  */
  .`table'.sep,bot;
  };
  
  };
  
end;




