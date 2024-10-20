/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : dentropyg                                                   */
/*************************************************************************/

#delim ;


cap program drop stdacon;  
program define stdacon, rclass ;    
version 9.2;  
args v1 v2 v3 theta;       
tempvar vec_a vec_b vec_c vec_d vec_e vec_f;

         if ( `theta' !=  0 & `theta' != 1 ) {;
         
         qui gen `vec_a' = `v3'*`v2';     
         qui gen `vec_b' = `v3';           
         qui gen `vec_c' = `v3'*`v2'^`theta'; 
         qui gen `vec_d' = `v1'*`v2';     
         qui gen `vec_e' = `v1'; 
         qui gen `vec_f' = `v1'*`v2'^`theta'; 
                
             
         qui svy: mean `vec_a' `vec_b' `vec_c' `vec_d' `vec_e' `vec_f' ;
         matrix _aa=e(b);
	   global sv1=el(_aa,1,1);
	   global sv2=el(_aa,1,2);
	   global sv3=el(_aa,1,3);
	   global sv4=el(_aa,1,4);
	   global sv5=el(_aa,1,5);
	   global sv6=el(_aa,1,6);
	   cap drop matrix mat;
	   matrix mat=e(V);
	 
         cap mtrix drop gra;
         matrix gra = 
                (
                (1/(1-`theta'))*(1/($sv4^`theta'))*(($sv2/($sv1*$sv5))^(1-`theta'))\
	          (1/(`theta'))*(1/($sv5^(1-`theta')))*(($sv1/($sv2*$sv4))^`theta')\
	          1/(`theta'*(`theta'-1))*(1/(($sv4^`theta')*($sv5^(1-`theta'))))\
	          (1/(1-`theta'))*($sv3-($sv1^`theta')*($sv2^(1-`theta')))/(($sv5^(1-`theta'))*($sv4^(`theta'+1)))\
	          (1/(`theta'))*($sv3-($sv1^`theta')*($sv2^(1-`theta')))/(($sv4^`theta')*($sv5^(2-`theta')))\
	          0                
	          );  
	   cap matrix drop gra2;
	   global xx = $sv3-($sv1^`theta')*($sv2^(1-`theta'));
         global zz = $sv6-($sv4^`theta')*($sv5^(-`theta'));
 
         matrix gra2 = 
                (
			(-`theta'*($sv1^(`theta'-1))*($sv2^(1-`theta')))/$zz \
			(-(1-`theta')*($sv1^`theta')*($sv2^(-`theta')))/$zz \
			1/$zz \
			`theta'*($sv5^(-`theta'))*($sv4^(`theta'-1))*$xx/($zz^2) \
			-`theta'*($sv5^(-`theta'-1))*($sv4^`theta')*$xx/($zz^2) \
			-$xx/($zz^2)              
	          );                             
        
        };
        
        if (`theta' == 0) {;
                
                qui gen `vec_a' =`v3'*`v2';     
                qui gen `vec_b' =`v3';           
                qui gen `vec_c' =`v3'*log(`v2'); 
                qui gen `vec_d' =`v1'*`v2';     
                qui gen `vec_e' =`v1';           
                qui gen `vec_f' =`v1'*log(`v2'); 
          
              qui svy: mean `vec_a' `vec_b' `vec_c' `vec_d' `vec_e' `vec_f';
	         matrix _aa=e(b);
	    	 global sv1=el(_aa,1,1);
	    	 global sv2=el(_aa,1,2);
	    	 global sv3=el(_aa,1,3);
	    	 global sv4=el(_aa,1,4);
	    	 global sv5=el(_aa,1,5);
	    	 global sv6=el(_aa,1,6);
	    	 cap drop matrix mat;
	    	 matrix mat=e(V);
	    	 
	    
	        cap mtrix drop gra;
	        matrix gra = 
                (
                	$sv2/($sv1*$sv5) \
			(log($sv1)-(log($sv2)+1))/$sv5\
			-1/$sv5\
			0 \
			((($sv2)*(log($sv2)-log($sv1))+($sv3)))/($sv5^2) \
			0                
		    );
              
              
                global xx=($sv2/$sv5)*(log($sv1)-log($sv2)-($sv3/$sv2));
                global zz=(log($sv4)-log($sv5)-($sv6/$sv5));
                
                global xx2=$xx*$sv5;
                global zz2=$zz*$sv5;
                cap mtrix drop gra2;
	          matrix gra2 = 
                (
                (($sv2)/($sv1*$sv5))/$zz \
                (log($sv1)-log($sv2)-1)/($sv5*$zz) \
                -(1/$sv5)/$zz \
                -((1/$sv4)*$xx)/($zz^2) \
                (log($sv5)+1-log($sv4))*$xx2/($zz2^2) \
                (1/$sv5)*$xx/($zz^2) 
                );
            
        };
        if (`theta' == 1) {;

                qui gen `vec_a'=`v3'*`v2';       
                qui gen `vec_b'=`v3';             
                qui gen `vec_c'=`v3'*`v2'*log(`v2');
                qui gen `vec_d'=`v1'*`v2';  
                qui gen `vec_e'=`v1';             
                qui gen `vec_f'=`v1'*`v2'*log(`v2');                    
 		 qui svy: mean `vec_a' `vec_b' `vec_c' `vec_d' `vec_e' `vec_f' ;
	         matrix _aa=e(b);
	    	 global sv1=el(_aa,1,1);
	    	 global sv2=el(_aa,1,2);
	    	 global sv3=el(_aa,1,3);
	    	 global sv4=el(_aa,1,4);
	    	 global sv5=el(_aa,1,5);
	    	 global sv6=el(_aa,1,6);
	    	 cap drop matrix mat;
	    	 matrix mat=e(V);
	    	 
	    
	        cap mtrix drop gra;
	        matrix gra = 
                (         
                (1/$sv4)*(log($sv2)-1-log($sv1))\
                $sv1/($sv4*$sv2)\
                1/$sv4\
                ($sv1*(log($sv1)-log($sv2))-$sv3)/($sv4^2)\
                0\
                0
                );
                
                global xx = $sv1/$sv4*(($sv3/$sv1)-log($sv1)+log($sv2));
		    global zz = (($sv6/$sv4)-log($sv4)+log($sv5));
                  
			global xx2=$xx*$sv4; 
			global zz2=$zz*$sv4; 
                 
           cap mtrix drop gra2;
	        matrix gra2 = 
                		(           
				(1/$sv4)*(log($sv2)-1-log($sv1))/$zz\
				($sv1/($sv4*$sv2))/$zz\
				(1/$sv4)/$zz\
				(log($sv4)+1-log($sv5))*$xx2/($zz2^2)\
				-(1/$sv5)*$xx/($zz^2)\
				-(1/$sv4)*$xx/($zz^2)
				);
                
            };

            
cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std = el(_zz,1,1)^0.5;
return scalar std= el(_zz,1,1)^0.5;
cap matrix drop _zz;
matrix _zz=gra2'*mat*gra2;
return scalar std2= el(_zz,1,1)^0.5;               

end;

cap program drop dentropyg2;  
program define dentropyg2, rclass ;    
version 9.2;         
syntax varlist (min=1 max=1) [, HSize(varname) HWeight(varname) HGroup(varname) THETA(real 1)  GNumber(int -1) CI(real 5)  LEVEL(real 95)];
preserve;
tokenize `varlist';
cap svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
                     qui drop if `1'>=. ;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;
tempvar  phs hs sw fw ;
gen `sw'=1;
gen `hs'=1;
gen `phs'=1;

if ("`hsize'"!="")     qui replace `hs'  = `hsize';
if ("`hsize'"!="")     qui replace `phs' = `hsize';

tempvar _in;
if ("`hgroup'" != "")  qui gen    `_in' = (`hgroup' == `gnumber');
if ("`hgroup'" != "")  qui replace `hs' = `hs' * `_in';
if ("`hweight'"!="")   qui replace `sw'=`hweight';

tempvar vec_a vec_b vec_c vec_d vec_e;

gen   `vec_b' = `hs';           
gen   `vec_c' = `hs'*`1';  
gen   `vec_d' = `phs';
gen   `vec_e' = `phs'*`1';



qui svy: mean `vec_b' `vec_c' `vec_d' `vec_e';
cap drop matrix _aa;
matrix _aa=e(b);
global ws1=el(_aa,1,1);
global ws2=el(_aa,1,2);
global ws3=el(_aa,1,3);
global ws4=el(_aa,1,4);
local est22= (($ws2*$ws3)/($ws1*$ws4))^`theta';
cap drop matrix mat;
matrix mat=e(V);
cap drop matrix gra;
matrix gra=
(
-($ws2*$ws3)/($ws1^2*$ws4)\
$ws3/($ws1*$ws4)\
$ws2/($ws1*$ws4)\
-($ws2*$ws3)/($ws1*$ws4^2)
);
cap matrix drop _zz;
matrix _zz=`theta'*`est22'^(`theta'-1)*gra'*mat*gra;
local std22= el(_zz,1,1)^0.5;  


if ( `theta' !=  0 & `theta' != 1 ) {;
gen   `vec_a' = `hs'*`1'^`theta';       
qui svy: mean `vec_a' `vec_b' `vec_c';
cap drop matrix _aa;
matrix _aa=e(b);
global ws1=el(_aa,1,1);
global ws2=el(_aa,1,2);
global ws3=el(_aa,1,3);
local est= ( 1/(`theta'*(`theta'-1) ) )*(($ws1/$ws2)/(($ws3/$ws2)^`theta') - 1);
cap drop matrix mat;
matrix mat=e(V);
cap drop matrix gra;
matrix gra=
(
((1/(`theta'*(`theta'-1)))*($ws2^(`theta'-1)))/($ws3^`theta')\
(1/`theta')*($ws1 )*($ws2^(`theta'-2))/($ws3^`theta')\
(1/(1-`theta'))*(($ws1 )*($ws2^(`theta'-1)))/($ws3^(`theta'+1))
);
cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std= el(_zz,1,1)^0.5;  
};



if ( `theta' ==  0) {;
gen   `vec_a' = `hs'*log(`1');       
qui svy: mean `vec_a' `vec_b' `vec_c';
cap drop matrix _aa;
matrix _aa=e(b);
global ws1=el(_aa,1,1);
global ws2=el(_aa,1,2);
global ws3=el(_aa,1,3);

local est=log($ws3/$ws2)-$ws1/$ws2; 
cap drop matrix mat;
matrix mat=e(V);
cap drop matrix gra;
matrix gra=
(
-1/($ws2)\
(($ws1-$ws2))/($ws2^2)\
1/($ws3)
);
cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std= el(_zz,1,1)^0.5;  
};


if ( `theta' ==  1) {;
gen   `vec_a' = `hs'*`1'*log(`1');      
qui svy: mean `vec_a' `vec_b' `vec_c';
cap drop matrix _aa;
matrix _aa=e(b);
global ws1=el(_aa,1,1);
global ws2=el(_aa,1,2);
global ws3=el(_aa,1,3);

local est=($ws1/$ws3)-log($ws3/$ws2);

cap drop matrix mat;
matrix mat=e(V);
cap drop matrix gra;
matrix gra=
(
1/($ws3)\
1/($ws2)\
-($ws1+$ws3)/($ws3^2)
);
cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std= el(_zz,1,1)^0.5;  
};

local est1=`est';
local std1=`std';

 

qui svy: mean `vec_a' `vec_b' `vec_c' `vec_d';
matrix _aa=e(b);
global ws1=el(_aa,1,1);
global ws2=el(_aa,1,2);
global ws3=el(_aa,1,3);
global ws4=el(_aa,1,4);
cap drop matrix mat;
matrix mat=e(V);
cap matrix drop gra;
matrix gra=
(
0\
1/($ws4)\
0\
-($ws2)/($ws4^2)
);
cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local est2=$ws2/$ws4;
local std2= el(_zz,1,1)^0.5; 




return scalar est1 = `est1';
return scalar std1 = `std1';

return scalar est2 = `est2';
return scalar std2 = `std2';

return scalar est22 = `est22';
return scalar std22 = `std22';

return scalar est3 = `est1'*`est2'*`est22';

stdacon `phs' `1' `hs' `theta';

return scalar std3 = `r(std)';
return scalar std4 = `r(std2)';

end;   




cap program drop entropybw;  
program define entropybw , rclass ;    
version 9.2;         
syntax varlist (min=2 max=2) [, HSize(varname) HWeight(varname)  HGroup(varname) THETA(real 1) CI(real 5)  LEVEL(real 95)];
preserve;
tokenize `varlist';
cap svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
                     qui drop if `1'>=. ;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;
tempvar  phs hs sw fw ;
gen `sw'=1;
gen `hs'=1;
gen `phs'=1;

if ("`hsize'"!="")     qui replace `hs'  = `hsize';
if ("`hsize'"!="")     qui replace `phs' = `hsize';
if ("`hweight'"!="")   qui replace `sw'=`hweight';

tempvar vec_a vec_b vec_c vec_d vec_e;
qui sum `1' [aw=`hs'*`sw'];
local mu = `r(mean)' ;

if ( `theta' ==  0) {;
gen `vec_a' = `hs'*(log(`mu'/`2')  - (1/`2')*(`1'-`2') + (1/`mu')*(`1'-`mu'));
gen `vec_b' = `hs';
gen `vec_d' = `hs'*(log(`mu'/`1')+(1/`mu')*(`1'-`mu'));
gen `vec_c' = `hs'*(log(`mu'/`1')+(1/`mu')*(`1'-`mu')  - (log(`mu'/`2')  - (1/`2')*(`1'-`2') + (1/`mu')*(`1'-`mu')));
};


if ( `theta' ==  1) {;
tempvar tmp gra1;
qui gen `tmp' = -(1/`2')*(`1'/`mu') ; qui sum `tmp' [aw=`sw']; 
tempvar tmp2 gra2;
qui gen `tmp2' = (-(`1'/`mu'^2)*log(`1'/`2')) ; qui sum `tmp2' [aw=`sw']; 
tempvar tmp3 gra3;
qui gen `tmp3' = -(`1'/`mu'^2)*log(`1'/`mu') -1/`mu'*(`1'/`mu'); 
qui gen `gra1' = .;
qui gen `gra2' = .;
qui gen `gra3' = .;
qui sum  `tmp' [aw=`hs'*`sw'] ; 
qui replace `gra1' =r(mean)  ;
qui sum  `tmp2' [aw=`hs'*`sw'] ; 
qui replace `gra2' =r(mean)  ;
qui sum  `tmp3' [aw=`hs'*`sw'] ; 
qui replace `gra3' =r(mean)  ;
gen `vec_a' = `hs'*((`1'/`mu')*log(`1'/`2')  + `gra1'*(`1'-`2') + `gra2'*(`1'-`mu') ) ;
gen `vec_b' = `hs';
gen `vec_c' = `hs'*((`1'/`mu')*log(`1'/`mu') + `gra3'*(`1'-`mu')) ; 
gen `vec_d' = `hs'*((`1'/`mu')*log(`1'/`mu') + `gra3'*(`1'-`mu')) ; 
replace `vec_c' = `vec_c'-`vec_a';
};


if ( `theta' !=  0 & `theta' != 1 ) {;
tempvar tmp gra1;
qui gen `tmp' = `theta'*`2'^(`theta'-1)/`mu'^`theta' ; 
tempvar tmp2 gra2;
qui gen `tmp2' = -(`theta'*`mu'^(`theta'-1)*(`2'^`theta'))/`mu'^(2*`theta') ; 

tempvar tmp12 gra12;
qui gen `tmp12' = `theta'*`2'^(`theta'-1)*(-(`theta'*`mu'^(`theta'-1)))/`mu'^(2*`theta') ; 
tempvar tmp21 gra21;
qui gen `tmp21' = -(`theta'^2*`mu'^(`theta'-1)*(`2'^(`theta'-1)))/`mu'^(2*`theta') ; 


tempvar tmp3 gra3;
qui gen `tmp3' = -(`theta'*`mu'^(`theta'-1)*(`1'^`theta'))/`mu'^(2*`theta') ; 
qui gen `gra1' = .;
qui gen `gra2' = .;
qui gen `gra12' = .;
qui gen `gra21' = .;
qui gen `gra3' = .;

forvalues i=1/$indica {;
local j = gn1[`i'];
qui sum  `tmp' [aw=`hs'*`sw'] if `j' == `hgroup'; 
qui replace `gra1' =r(mean)  if `j' == `hgroup';
};
qui sum  `tmp2' [aw=`hs'*`sw'];
qui replace `gra2' =r(mean)  ;
qui sum  `tmp3' [aw=`hs'*`sw'] ; 
qui replace `gra3' =r(mean)  ;


gen `vec_a' = 1/(`theta'*(`theta'-1))*`hs'*(`2'^`theta'/`mu'^`theta' - 1   + (`gra1')*(`1'-`2') + (`gra2')*(`1'-`mu'))   ;
gen `vec_b' = `hs';
gen `vec_c' = 1/(`theta'*(`theta'-1))*`hs'*(`1'^`theta'/`mu'^`theta' - 1   + `gra3'*(`1'-`mu'))   ; 
gen `vec_d' = 1/(`theta'*(`theta'-1))*`hs'*(`1'^`theta'/`mu'^`theta' - 1   + `gra3'*(`1'-`mu'))   ; 
replace `vec_c' = `vec_c'-`vec_a';
};

if (`theta' != 1) {;
qui svy: ratio `vec_a'/`vec_b';
cap matrix drop vv;
matrix vv=e(V);
local sbet = el(vv,1,1)^0.5;
qui svy: ratio `vec_c'/`vec_b';
matrix vv=e(V);
local swit = el(vv,1,1)^0.5;

qui svy: ratio `vec_a'/`vec_d';
cap matrix drop vv;
matrix vv=e(V);
local sbeta = el(vv,1,1)^0.5;
qui svy: ratio `vec_c'/`vec_d';
matrix vv=e(V);
local swita = el(vv,1,1)^0.5;

return scalar sbet = `sbet' ;
return scalar swit = (`swit') ;
return scalar sbeta = `sbeta' ;
return scalar swita = (`swita') ;
};

if (`theta' == 1) {;
qui svy: ratio `vec_a'/`vec_b';
cap matrix drop vv;
matrix vv=e(V);
local swit = el(vv,1,1)^0.5;
qui svy: ratio `vec_c'/`vec_b';
matrix vv=e(V);
local sbet = el(vv,1,1)^0.5;

qui svy: ratio `vec_a'/`vec_d';
cap matrix drop vv;
matrix vv=e(V);
local swita = el(vv,1,1)^0.5;
qui svy: ratio `vec_c'/`vec_d';
matrix vv=e(V);
local sbeta = el(vv,1,1)^0.5;

return scalar sbet = `sbet' ;
return scalar swit = (`swit') ;
return scalar swita = `swita' ;
return scalar sbeta = (`sbeta') ;
};

end;     


  



capture program drop dentropyg;
program define dentropyg, eclass;
version 9.2;
syntax varlist(min=1 max=1)[, HSize(varname) HGroup(varname) THETA(real 0) 
 STE(string) dec(int 6) LEVEL(real 95) DSTE(int 1)
XFIL(string) XSHE(string) XLAN(string) XTIT(string) MODREP(string)
];
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
local ci=100-`level';
tempvar Variable EST EST1 EST2 EST22 EST3 EST4 STE STE1 STE2 STE22 STE3 STE4;
qui gen `Variable'="";
qui gen `EST'=0;
qui gen `STE'=0;

qui gen `EST2'=0;
qui gen `STE2'=0;

qui gen `EST22'=0;
qui gen `STE22'=0;

qui gen `EST3'=0;
qui gen `STE3'=0;

qui gen `EST4'=0;
qui gen `STE4'=0;

tempvar _ths;
qui gen `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';
cap svy: total;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
local ll=length("`1': `grlab`1''");

dentropyg2 `1' ,  hsize(`_ths')  theta(`theta')  ci(`ci');
global est = `r(est1)';

local acon=0;
local rcon=0;

forvalues k = 1/$indica {;
local kk = gn1[`k'];

local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;
local kk1 = `k2'+1;
local kk2 = `k2'+2;
local kk3 = `k2'+3;
local kk4 = `k2'+4;
local kk5 = `k2'+5;
local kk6 = `k2'+6;
qui count;
if `r(N)' < `kk6' qui set obs `kk6' ;

qui dentropyg2 `1' ,  hsize(`_ths')  hgroup(`hgroup') gnumber(`kk') theta(`theta') ci(`ci') ;
qui replace `EST'      = `r(est1)' in `k1';
qui replace `EST'      = `r(std1)' in `k2';

qui replace `EST2'      = `r(est2)' in `k1';
qui replace `EST2'      = `r(std2)' in `k2';

qui replace `EST22'      = `r(est22)' in `k1';
qui replace `EST22'      = `r(std22)' in `k2';

qui replace `EST3'      = `r(est3)' in `k1';
qui replace `EST3'      = `r(std3)' in `k2';

qui replace `EST4'      = `r(est3)'/$est in `k1';
qui replace `EST4'      = `r(std4)'      in `k2';
local acon= `acon'+ `r(est3)';
local rcon= `rcon'+ `r(est3)'/$est;
if ( "`grlab`kk''" == "") local grlab`kk' = "Group_`kk'";
qui replace `Variable' = "`kk': `grlab`kk''" in `k1';
local ll=max(`ll',length("`kk': `grlab`kk''"));
};
local ll=`ll'+2;



qui replace `Variable' = "Within"  in `kk1';
qui replace `EST'      = .          in `kk1';
qui replace `EST'      = .          in `kk2';

qui replace `EST2'      = . in `kk1';
qui replace `EST2'      = . in `kk2';
qui replace `EST2'      = . in `kk3';
qui replace `EST2'      = . in `kk4';

qui replace `EST22'      = . in `kk1';
qui replace `EST22'      = . in `kk2';
qui replace `EST22'      = . in `kk3';
qui replace `EST22'      = . in `kk4';
qui replace `EST22'      = . in `kk5';
qui replace `EST22'      = . in `kk6';

qui replace `EST3'      = `acon'    in `kk1';
qui replace `EST3'      = .         in `kk2';

qui replace `EST4'      = `rcon' in `kk1';
qui replace `EST4'      = .      in `kk2';




qui dentropyg2 `1' ,  hsize(`_ths')  theta(`theta')  ci(`ci');



qui replace `Variable' = "Population" in `kk5';
qui replace `EST'      = `r(est1)'  in `kk5';
qui replace `EST'      = `r(std1)'  in `kk6';
local sesttot = `r(std1)';

qui replace `EST2'      = 1 in `kk5';
qui replace `EST2'      = 0 in `kk6';

qui replace `EST3'      = `r(est1)' in `kk5';
qui replace `EST3'      = `r(std1)' in `kk6';

qui replace `EST4'      = 1 in `kk5';
qui replace `EST4'      = 0 in `kk6';


tempvar fw;
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear;
qui gen `fw'=1;
if ("`hweight'"~="")       qui replace `fw'=`fw'*`hweight';
tempvar key;
gen `key'=_n;
tempvar aa bb muk;
bysort `hgroup': egen `aa'=sum(`1'*`_ths'*`fw');
bysort `hgroup': egen `bb'=sum(`_ths'*`fw');
qui gen `muk' =  `aa'/`bb';
sort `key';
/*
*set trace on;
set tracedepth 2;
*/
qui entropybw `1' `muk' , hsize(`_ths') hweight(`fw')  theta(`theta')  ci(`ci') hgroup(`hgroup');
local sestb = `r(sbet)' ;
local sestw = `r(swit)' ;
local sestba = `r(sbeta)' ;
local sestwa = `r(swita)' ;



qui dentropyg2 `muk' ,  hsize(`_ths')  theta(`theta')  ci(`ci');



qui replace `Variable' = "Between"  in `kk3';
qui replace `EST'      = `r(est1)'  in `kk3';



qui replace `EST3'      = `r(est1)' in `kk3';
qui replace `EST3'      = `r(std1)' in `kk4';

qui replace `EST3'      = `sestw'  in `kk2';
qui replace `EST3'      = `sestb'  in `kk4';

qui replace `EST4'      = `r(est1)'/$est in `kk3';
local rbetween =  `r(est1)'/$est ;
qui replace `EST4'      = .              in `kk4';


qui replace `EST4'      = `sestwa'  in `kk2';
qui replace `EST4'      = `sestba'  in `kk4';




	tempname table;
	.`table'  = ._tab.new, col(6);
	.`table'.width |`ll'|16 16 16 16 16|;
	.`table'.strcolor . . . yellow . . ;
	.`table'.numcolor yellow yellow yellow . yellow yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f %16.`dec'f;
	di _n as text "{col 4} Decomposition of the Generalised Entropy Index by Groups";
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";
                            di  as text "{col 5}Parameter theta : "  %5.2f `theta'       ;
     
	.`table'.sep, top;
	.`table'.titles "Group  " "Entropy index"  "Population " "(mu_k/mu)^theta " "  Absolute  " "  Relative  " ;
	.`table'.titles "       " "         "  "   share   "  "  " "contribution" "contribution" ;
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2)) .`table'.numcolor white yellow yellow  yellow yellow yellow ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green green  green  green green ;
		  if (`dste'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i'] `EST'[`i']  `EST2'[`i'] `EST22'[`i'] `EST3'[`i'] `EST4'[`i'];	        
              };
                
                
 .`table'.sep, mid;
.`table'.numcolor white yellow yellow  yellow yellow yellow ;
.`table'.row `Variable'[`kk1'] "---"  "---" "---" `EST3'[`kk1'] `EST4'[`kk1'];
if (`dste'==1){;
.`table'.numcolor white green   green green green green ;
.`table'.row `Variable'[`kk2'] "---"  "---"  "---"  `EST3'[`kk2'] `EST4'[`kk2'];
};


local within  = `EST3'[`kk1'];
local between = `EST3'[`kk3'];
local  total   = `EST3'[`kk5'];
.`table'.sep, mid;
.`table'.numcolor white yellow yellow  yellow yellow yellow ;
.`table'.row `Variable'[`kk3'] "---"  "---" "---" `EST3'[`kk3'] `EST4'[`kk3'];
if (`dste'==1){;
.`table'.numcolor white green   green green green green ;
.`table'.row `Variable'[`kk4'] "---"  "---"  "---" `EST3'[`kk4'] `EST4'[`kk4'];
};

               
  .`table'.sep, mid;
.`table'.numcolor white yellow yellow  yellow yellow yellow ;
.`table'.row `Variable'[`kk5'] `EST'[`kk5']  `EST2'[`kk5'] "---" `EST3'[`kk5'] `EST4'[`kk5'];
if (`dste'==1){;
.`table'.numcolor white green   green green green green ;
.`table'.row `Variable'[`kk6'] `EST'[`kk6']  `EST2'[`kk6']  "---" `EST3'[`kk6'] `EST4'[`kk6'];
};


	.`table'.sep,bot;


//===============


tempname  Variableo;
qui gen  `Variableo'=`Variable';


cap drop __compa;
qui gen  __compna=`Variable';

local lng = ($indica*2+`k2'+2);
qui keep in 1/`lng';

if ("`xlan'"=="fr") {;
local k1=$indica*2+1;
local k2=$indica*2+3;
qui replace __compna = "Intra-groupes" in `k1';
qui replace __compna = "Inter-groupes" in `k2';
};

local rnam;
forvalues i=1(2)`lng'  {;
local temn=__compna[`i'];
               local rnam `"`rnam' "`temn'""';
if (`dste'~=0) local rnam `"`rnam' " ""';
};

global rnam `"`rnam'"';


if (`dste'==0) {;
local bf=`lng'/2+1;
forvalues j=2(1)`bf'{;
qui drop in `j';
};
};



tempname zz;


                local mtl = `kk6';
if (`dste'==0)  local mtl = (`mtl'-6)/2+3;

				
qui replace `Variable' = "STE" if `Variable'=="";
qui mkmat	 `EST'  `EST2' `EST22' `EST3' `EST4' in 1/`mtl',	matrix(`zz') rownames(`Variable');





                    local index = "Entropy index"; 
if ("`xlan'"=="fr") local index = "Indice d'entropie";

local cnam;
local cnam `"`cnam' "`index'""';
if ("`xlan'"~="fr")  local cnam `"`cnam' "Population share""';

                     local cnam `"`cnam' "(mu_k/mu)^theta""'; 
if ("`xlan'"~="fr")  local cnam `"`cnam' "Absolute contribution""';

if ("`xlan'"~="fr")  local cnam `"`cnam' "Relative contribution""';

global cnam `"`cnam'"';

if ("`xtit'"=="")    local xtit = "Table ##: Decomposition of the entropy index by population groups";
if ("`xtit'"~="")     local xtit = "`xtit'";


if ("`xfil'" ~="") {;

local rnamn ="";
local lng1 = `lng'-1;
local pass = 2 ;
if `dste'~=1 local pass = 1 ;
forvalues i=1(`pass')`lng'  {;
local temn=`Variableo'[`i'];
if (`i'!=`lng1' & `dste'==1)                local rnamn `rnamn'  `temn' @ @  ;
if (`i'!=`lng1' & `dste'!=1)                local rnamn `rnamn'  `temn' @  ;
if (`i'==`lng1' | `i'==`lng')   local rnamn `rnamn'  `temn'       ;

};

global rnamn `"`rnamn'"';
local cnamn `index' @ ; 
if ("`xlan'"~="fr")  local cnamn `cnamn' Population share @;
if ("`xlan'"~="fr")  local cnamn `cnamn' (mu_k/mu)^theta @ ;
if ("`xlan'"~="fr")  local cnamn `cnamn' Absolute contribution @ ;
if ("`xlan'"~="fr")  local cnamn `cnamn' Relative contribution ;
global cnamn `cnamn';


tokenize "`xfil'" ,  parse(".");
local xfil = "`1'";
 mk_xls `1' ,  matn(`zz') dec(`dec')   etitle(`xtit') xlan(`xlan') dste(`dste')  fexcel(`xfil') esheet(`xshe') modrep(`modrep') fcname(Population groups);
 
};

cap ereturn clear; 

ereturn scalar rwithin = `rcon';
ereturn scalar sesttot = `sesttot';
ereturn scalar sestb = `sestb' ;
ereturn scalar sestw = `sestw' ;
ereturn scalar sestba = `sestba' ;
ereturn scalar sestwa = `sestwa' ;
ereturn scalar rbetween = `rbetween';
ereturn scalar within  = `within';
ereturn scalar between = `between';
ereturn scalar total   = `total';

matrix colnames `zz' = "Entropy	index"	"Population share"	"(mu_k/mu)^theta"	"Absolute contribution"	"Relative   contribution" ;


ereturn matrix totres = `zz' ;

restore;
end;

