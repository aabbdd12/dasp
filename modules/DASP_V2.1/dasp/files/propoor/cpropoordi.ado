


#delim ;
set more off;
/*****************************************************/
/* ppddensity function      : ici fw=Hweight*Hsize   */
/*****************************************************/

cap program drop ppddens;                    
program define ppddens, rclass;              
args fw x xval;                       
qui su `x' [aw=`fw'], detail;           
local tmp = (`r(p75)'-`r(p25)')/1.34;                          
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ; 
qui sum `fw'; 
local h   = 0.9*`tmp'*_N^(-1.0/5.0);                          
tempvar s1 s2;                                                  
gen `s1' = sum( `fw' *exp(-0.5* ( ((`xval'-`x')/`h')^2  )  ));  
gen `s2' = sum( `fw' );
return scalar den = `s1'[_N]/( `h'* sqrt(2*c(pi)) * `s2'[_N] );  
end;


capture program drop propquant2;
program define propquant2, rclass sortpreserve;
version 9.2;
args www yyy min max gr ng;
preserve;
if ("`gr'" ~="") qui keep if (`gr'==gn1[`ng']);
sort `yyy';
cap drop if `yyy'>=.;
cap drop if `www'>=.;
if (_N<101) qui set obs 101;
tempvar  _finqp _finglp _ww _qup  _glp _pc;
qui gen `_ww'=sum(`www');
qui gen `_pc'=`_ww'/`_ww'[_N];
qui gen `_qup' = `yyy' ;
qui gen double `_glp'  = sum(`www'*`yyy')/`_ww'[_N];
qui sum `yyy' [aw=`www'];
qui sum  [aw=`www'];
local mina=`r(min)';
local maxa=`r(max)';
local ff=`mina';
if(`min'==0 & `mina'>0) local ff=0;
qui gen  `_finqp' =0;
qui gen  `_finglp'=0;
local step=(`max'-`min')/100;
local i = 1;
forvalues j=0/100 {;
local pcf=`min'+`j' *`step';
local av=`j'+1;
while (`pcf' > `_pc'[`i']) {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) {;
			local lqi  =`_qup'[`ar']+((`_qup'[`i']-`_qup'[`ar'])/(`_pc'[`i']-`_pc'[`ar']))*(`_pc'[`i']-`_pc'[`ar']);
			local glor=`_glp'[`ar']+((`_glp'[`i']-`_glp'[`ar']) /(`_pc'[`i']-`_pc'[`ar']))*(`_pc'[`i']-`_pc'[`ar']);
	      };
if (`i'==1) {;
		local lqi=`ff'+(max(0,`_qup'[`i'])/(`_pc'[`i']))*(`_pc'[`i']);
		local glor=    (max(0,`_glp'[`i'])/(`_pc'[`i']))*(`_pc'[`i']);
		};
qui replace `_finqp' =`lqi'  in `av';
qui replace `_finglp'=`glor' in `av';
};

if(`min'==0 & `mina'>0) qui replace `_finqp' = 0 in 1;
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat `_finqp' `_finglp' , matrix (_xx);
restore;
end;




capture program drop cpropoordi;
program define cpropoordi, rclass;
version 9.0;
syntax  namelist(min=2 max=2) [, FILE1(string) FILE2(string) HSize1(string) 
HSize2(string)  MIN(real 0) MAX(real 1)  COND1(string) COND2(string) 
CRV(int 1) CONF(string) LEVEL(real 95) DEC(int 6) ORDER(int 1) BOOT(string)];
global indica=3;
tokenize `namelist';


preserve;

              global ncomp=101;

if ("`conf'"=="") local conf="ts";

if ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;
drop if `1'==. |`2'==0 ; 
if (`"`file1'"'~="") use `"`file1'"', replace;
qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');

tempvar cd1;
cap drop _ths1;
qui gen _ths1=1;
if ( "`hsize1'"!="") qui replace _ths1=`hsize1';
if ( "`cond1'"!="") {;
gen `cd1'=`cond1';
qui replace _ths1=_ths1*`cd1';
qui sum `cd1';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_1, the number of observartions is 0.";
exit;
};
};

tempvar cd2;
cap drop _ths2;
qui gen _ths2=1;
if ( "`hsize2'"!="") qui replace _ths2=`hsize2';
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace _ths2=_ths2*`cd2';
qui sum `cd2i';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_2, the number of observartions is 0.";
exit;
};
};


local wname="";
qui gen _fw1=_ths1;
qui gen _fw2=_ths2;
cap svy: total;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
cap estat svyset;
cap local wname=`"`e(wvar)'"';
if (`"`wname'"'~="") {;
qui replace _fw1=_fw1*`wname';
qui replace _fw2=_fw2*`wname';
};



local step = (`max'-`min')/100;
qui count;
if (`r(N)'<101) qui set obs 101;

gen _corx=0; gen _est=0; gen _lb=0; gen _ub=0; 


propquant2 _fw1 `1' `min' `max';
cap matrix drop _xx1;
matrix rename _xx _xx1;
propquant2 _fw2 `2' `min' `max';
cap matrix drop _xx2;
matrix rename _xx _xx2;

forvalues j=1/$ncomp {;

local perc = `min'+(`j'-1)*`step';
cap drop `b1' `s1' `m1' `sb1' `ss1' `sm1';
cap drop `b2' `s2' `m2' `sb2' `ss2' `sm2';

tempvar b1 s1 m1 sb1 ss1 sm1;
tempvar b2 s2 m2 sb2 ss2 sm2;



local qp1 = el(_xx1,`j',1);
if (`order'==1) local est1=`qp1';
if (`order'==2) local est1=el(_xx1,`j',2);

ppddens _fw1 `1' `qp1';
local fqp1=`r(den)';

qui sum `1' [aw=_fw1], meanonly;
local mu1=`r(mean)';



gen `s1'=_ths1;
gen `m1'=_ths1*`1';
if (`order'==1) gen `b1'=_ths1*`qp1'-_ths1*((`qp1'>`1')-`perc')/`fqp1';
if (`order'==2) gen `b1'=_ths1*(`qp1'*`perc'+(`1'-`qp1')*(`qp1'>`1'));

qui svy: ratio `b1'/`s1';
gen `ss1'=_fw1;
gen `sm1'=_fw1*`1';
gen `sb1'=_fw1*`est1'; 

qui sum `ss1'; local es1=`r(sum)';
qui sum `sm1'; local em1=`r(sum)';
qui sum `sb1'; local eb1=`r(sum)';

local qp2=el(_xx2,`j',1);
if (`order'==1) local est2=`qp2';
if (`order'==2) local est2=el(_xx2,`j',2);

ppddens _fw2 `2' `qp2';
local fqp2=`r(den)';

qui sum `2' [aw=_fw2], meanonly;
local mu2=`r(mean)';



gen `s2'=_ths2;
gen `m2'=_ths2*`2';
if (`order'==1) gen `b2'=_ths2*`qp2'-_ths2* ((`qp2'>`2')-`perc')/`fqp2';
if (`order'==2) gen `b2'=_ths2*(`qp2'*`perc'+(`2'-`qp2')*(`qp2'>`2')); 

gen `ss2'=_fw2;
gen `sm2'=_fw2*`2';
gen `sb2'=_fw2*`est2'; 

qui sum `ss2'; local es2=`r(sum)';
qui sum `sm2'; local em2=`r(sum)';
qui sum `sb2'; local eb2=`r(sum)';

qui svy: total  `m1' `s1' `b1' `m2' `s2' `b2';
cap drop matrix mat;
matrix mat=e(V);


cap matrix drop gra;
matrix gra=
(
0 \
`eb1'/`es1'^2\
-1/`es1'\
0 \
-`eb2'/`es2'^2\
1/`es2'
);



cap matrix drop _vv;
matrix _vv=gra'*mat*gra;
local std_dif = el(_vv,1,1)^0.5;
local dif=`est2'-`est1';

local lb   = `dif' - `tt'*`std_dif';
local ub   = `dif' + `tt'*`std_dif';

dis `lb' "  "  `dif' "  " `ub';

if (`crv'==1 ) {;
qui replace _corx = `perc'  in `j';
qui replace _est =  `dif'   in `j';
qui replace _lb =  `lb'    in `j';
qui replace _ub =  `ub'    in `j';
};

cap matrix drop gra;
matrix gra=
(
`em2'*`es1'/(`es2'*`em1'^2) \
`eb2'/(`eb1'*`es2')-`em2'/(`em1'*`es2') \
-`eb2'*`es1'/(`es2'*`eb1'^2) \
-`es1'/(`es2'*`em1') \
-(`eb2'*`es1')/(`eb1'*`es2'^2)+(`em2'*`es1')/(`em1'*`es2'^2) \
`es1'/(`es2'*`eb1')
);

cap matrix drop _var;
matrix _var=gra'*mat*gra;
local std_dif = el(_var,1,1)^0.5;

local dif=`est2'/`est1'-`mu2'/`mu1';

local lb   = `dif' - `tt'*`std_dif';
local ub   = `dif' + `tt'*`std_dif';



if (`crv'==3 ) {;
qui replace _corx = `perc'  in `j';
qui replace _est =  `dif'   in `j';
qui replace _lb =  `lb'    in `j';
qui replace _ub =  `ub'    in `j';
};

cap matrix drop gra;
matrix gra=
(
-`em2'*`es1'/(`es2'*`em1'^2) \
`em2'/(`em1'*`es2') \
0  \
`es1'/(`es2'*`em1') \
-(`em2'*`es1')/(`em1'*`es2'^2) \
0
);

if ("`conf'"!="ts") local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl = (1-(100-`level')/200);
local zzz=invnorm(`lvl');
cap matrix drop _var;
matrix _var=gra'*mat*gra;
local std_m2_m1 = el(_var,1,1)^0.5;
local dif  = `mu2' - `mu1';
local lb   = `dif' - `zzz'*`std_m2_m1';
local ub   = `dif' + `zzz'*`std_m2_m1';



cap matrix drop gra;
matrix gra=
(
0 \
`eb2'/(`eb1'*`es2') \
-`eb2'*`es1'/(`es2'*`eb1'^2)\
0 \
-(`eb2'*`es1')/(`eb1'*`es2'^2) \
`es1'/(`es2'*`eb1')
);
cap matrix drop _var;
matrix _var=gra'*mat*gra;
local std_q2_q1 = el(_var,1,1)^0.5;
local lb   = (`est2'/`est1'-1)  - `tt'*`std_q2_q1';
local ub   = (`est2'/`est1'-1)  + `tt'*`std_q2_q1';
matrix _res_d1 =((`est2'/`est1'-1),`std_q2_q1',`lb',`ub');

if (`crv'==2 ) {;
qui replace _corx =  `perc' in `j';
qui replace _est =  (`est2'/`est1'-1)   in `j';
qui replace _lb =  `lb'    in `j';
qui replace _ub =  `ub'    in `j';
};

if (`j'!=101)  dis "." ,  _continue;
if (`j'/10==round(`j'/10)) {;
                            dis " "  %4.2f `j' " %";
                           };


}; /* end of for j */
qui mkmat _corx _est _lb _ub  in 1/101, matrix(RES);
};


/* SECOND STAGE */
if !( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;


if ("`file1'" !="") use `"`file1'"', replace;
cap drop if `1'==. ;
tempvar cd1;
cap drop _ths1;
qui gen _ths1=1;
if ( "`hsize1'"!="") qui replace _ths1=`hsize1';
if ( "`cond1'"!="") {;
gen `cd1'=`cond1';
qui replace _ths1=_ths1*`cd1';
qui sum `cd1';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_1, the number of observartions is 0.";
exit;
};
};


local wname1="";
qui gen _fw1=_ths1;
cap qui svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
cap estat svyset;
cap local wname1=`"`e(wvar)'"';
if (`"`wname1'"'~="") qui replace _fw1=_fw1*`wname1';


local step = (`max'-`min')/100;
qui count;
if (`r(N)'<101) qui set obs 101;

qui gen _corx=0; qui gen _est=0; qui gen _lb=0; qui gen _ub=0; 

tempvar b1 s1 m1 sb1 ss1 sm1;
tempvar _sb1 _ss1 _sm1 _est1;

gen `_sb1'  = 0;
gen `_ss1'  = 0;
gen `_sm1'  = 0;
gen `_est1' = 0;

dis "STEP 1/2";

propquant2 _fw1 `1' `min' `max';
cap matrix drop   _xx1;
matrix rename _xx _xx1;
forvalues j=1/$ncomp  {;

local perc = `min'+(`j'-1)*`step';


local qp1 = el(_xx1,`j',1);
if (`order'==1) local est1=`qp1';
if (`order'==2) local est1=el(_xx1,`j',2);


/*dis "Estimate 1: `est1'";*/
ppddens _fw1 `1' `qp1';
local fqp1=`r(den)';

qui sum `1' [aw=_fw1], meanonly;
local mu1=`r(mean)';

cap drop `b1' `s1' `m1' `sb1' `ss1' `sm1';


qui gen `s1'=_ths1;
qui gen `m1'=_ths1*`1';
if (`order'==1) qui gen `b1'=_ths1*`qp1'-_ths1*((`qp1'>`1')-`perc')/`fqp1';
if (`order'==2) qui gen `b1'=_ths1*(`qp1'*`perc'+(`1'-`qp1')*(`qp1'>`1'));


qui gen `ss1'=_fw1;
qui gen `sm1'=_fw1*`1';
qui gen `sb1'=_fw1*`est1';  

qui sum `ss1'; local es1`j'=`r(sum)';
qui sum `sm1'; local em1`j'=`r(sum)';
qui sum `sb1'; local eb1`j'=`r(sum)';
local est1`j'=`est1';

qui svy: total  `m1' `s1' `b1';
cap drop matrix mat1`j';

matrix mat1`j'=e(V);

if (`j'!=101)  dis "." ,  _continue;
if (`j'/10==round(`j'/10)) dis " "  %4.2f `j' " %";

}; 




restore;

preserve;
if ("`file2'" !="") use `"`file2'"', replace;
cap drop if `2'==. ;
tempvar cd2;
cap drop _ths2;
qui gen _ths2=2;
if ( "`hsize2'"!="") qui replace _ths2=`hsize2';
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace _ths2=_ths2*`cd2';
qui sum `cd2';
if (`r(sum)'==0) {;
dis as error " With condition(s) of distribution_2, the number of observartions is 0.";
exit;
};
};


local wname2="";
qui gen _fw2=_ths2;
cap svy: total `2';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
cap estat svyset;
cap local wname2=`"`e(wvar)'"';
if (`"`wname2'"'~="") qui replace _fw=_fw*`wname2';
local step = (`max'-`min')/100;
qui count;
if (`r(N)'<101) qui set obs 101;

gen _corx=0; gen _est=0; gen _lb=0; gen _ub=0; 

dis "STEP 2/2";
tempvar b2 s2 m2 sb2 ss2 sm2;

propquant2 _fw2 `2' `min' `max';
cap matrix drop   _xx2;
matrix rename _xx _xx2;

forvalues j=1/$ncomp {;

local perc = `min'+(`j'-1)*`step';

local es1=`es1`j'';
local em1=`em1`j'';
local eb1=`eb1`j'';
local est1=`est1`j'';
matrix mat1 = mat1`j'; 
matrix drop mat1`j'; 





local qp2=el(_xx2,`j',1);
if (`order'==1) local est2=`qp2';
if (`order'==2) local est2=el(_xx2,`j',2);;

/*dis "Estimate 2: `est2'";*/
ppddens _fw2 `2' `qp2';
local fqp2=`r(den)';

qui sum `2' [aw=_fw2], meanonly;
local mu2=`r(mean)';

cap drop `b2' `s2' `m2' `sb2' `ss2' `sm2';

gen `s2'=_ths2;
gen `m2'=_ths2*`2';
if (`order'==1) gen `b2'=_ths2*`qp2'-_ths2* ((`qp2'>`2')-`perc')/`fqp2';
if (`order'==2) gen `b2'=_ths2*(`qp2'*`perc'+(`2'-`qp2')*(`qp2'>`2')); 



gen `ss2'=_fw2;
gen `sm2'=_fw2*`2';
gen `sb2'=_fw2*`est2'; 

qui sum `ss2'; local es2=`r(sum)';
qui sum `sm2'; local em2=`r(sum)';
qui sum `sb2'; local eb2=`r(sum)';

qui svy: total  `m2' `s2' `b2';
cap drop matrix m2;

matrix mat2=e(V);


cap matrix drop gra1;
matrix gra1=
(
`em2'*`es1'/(`es2'*`em1'^2) \
`eb2'/(`eb1'*`es2')-`em2'/(`em1'*`es2') \
-`eb2'*`es1'/(`es2'*`eb1'^2)
);

cap matrix drop gra2;
matrix gra2=
(
-`es1'/(`es2'*`em1') \
-(`eb2'*`es1')/(`eb1'*`es2'^2)+(`em2'*`es1')/(`em1'*`es2'^2) \
`es1'/(`es2'*`eb1')
);
cap matrix drop _vv;
matrix _vv=gra1'*mat1*gra1+gra2'*mat2*gra2;
local std_dif = el(_vv,1,1)^0.5;
local dif=`est2'/`est1'-`mu2'/`mu1';


if ("`conf'"!="ts") local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl = (1-(100-`level')/200);
local zzz=invnorm(`lvl');

local lb   = `dif' - `zzz'*`std_dif';
local ub   = `dif' + `zzz'*`std_dif';



if (`crv'==3 ) {;
qui replace _corx =  `perc'  in `j';
qui replace _est =   `dif'   in `j';
qui replace _lb =    `lb'    in `j';
qui replace _ub =    `ub'    in `j';
};


cap matrix drop gra1;

cap matrix drop gra1;
matrix gra1=
(
0 \
`eb1'/`es1'^2\
-1/`es1'
);

cap matrix drop gra2;
matrix gra2=
(
0 \
-`eb2'/`es2'^2\
1/`es2'
);
cap matrix drop _vv;
matrix _vv=gra1'*mat1*gra1+gra2'*mat2*gra2;
local std_dif = el(_vv,1,1)^0.5;
local dif=`est2'-`est1';
local lb   = `dif' - `zzz'*`std_dif';
local std_dif = el(_vv,1,1)^0.5;
local dif=`est2'-`est1';
local lb   = `dif' - `zzz'*`std_dif';
local ub   = `dif' + `zzz'*`std_dif';


if (`crv'==1 ) {;

qui replace _corx = `perc'  in `j';
qui replace _est =  `dif'   in `j';
qui replace _lb =  `lb'    in `j';
qui replace _ub =  `ub'    in `j';
};


cap matrix drop gra1;
matrix gra1=
(
-`em2'*`es1'/(`es2'*`em1'^2) \
`em2'/(`em1'*`es2') \
0
);
cap matrix drop gra2;
matrix gra2=
(
`es1'/(`es2'*`em1') \
-(`em2'*`es1')/(`em1'*`es2'^2) \
0
);
cap matrix drop _vv;
matrix _vv=gra1'*mat1*gra1+gra2'*mat2*gra2;
local std_m2_m1 = el(_vv,1,1)^0.5;
local est  = `mu2'/`mu1'-1;
local lb   = `est' - `zzz'*`std_m2_m1';
local ub   = `est' + `zzz'*`std_m2_m1';



cap matrix drop gra1;

matrix gra1=
(
0 \
`eb2'/(`eb1'*`es2') \
-`eb2'*`es1'/(`es2'*`eb1'^2)
);

cap matrix drop gra2;
matrix gra2=
(
0 \
-(`eb2'*`es1')/(`eb1'*`es2'^2) \
`es1'/(`es2'*`eb1')
);

cap matrix drop _vv;
matrix _vv=gra1'*mat1*gra1+gra2'*mat2*gra2;
local std_q2_q1 = el(_vv,1,1)^0.5;
local est  = `est2'/`est1'-1;
local lb   = `est' - `zzz'*`std_q2_q1';
local ub   = `est' + `zzz'*`std_q2_q1';

if (`crv'==2 ) {;
qui replace _corx = `perc'  in `j';
qui replace _est =  (`est2'/`est1'-1)   in `j';
qui replace _lb =  `lb'    in `j';
qui replace _ub =  `ub'    in `j';
};

if (`j'!=101)  dis "." ,  _continue;
if (`j'/10==round(`j'/10)) {;
                            dis " "  %4.2f `j' " %";
                           };


}; /* END boucle j */

qui mkmat _corx _est _lb _ub  in 1/101, matrix(RES);


};

cap matrix drop mat1 mat2 gra1 gra2 _vv _xx _xx1 _xx2;
end;


