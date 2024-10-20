/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.2)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : cfgts2d                                                     */
/*************************************************************************/

#delim ;
set more off;
capture program drop sdom2d;
program define sdom2d, rclass;
version 9.2;
syntax namelist [,  HSize1(string) HSize2(string) 
AL1(real 0)  AL2(real 0) 
MIN1(real 0) MAX1(real 10000) PAR1(int 20)
MIN2(real 0) MAX2(real 10000) PAR2(int 20) 
LEVEL(real 95) CONF(string) DIF(int 1) LB(int 0) UB(int 0) TGR(int 1)];

tokenize `namelist';


gen  _td1=`min1'+(_n-1)*(`max1'-`min1')/`par1';
gen  _td2=`min2'+(_n-1)*(`max2'-`min2')/`par2';




tempvar num1 num2; 

gen  __xx =0;
gen  __yy =0;
gen  __zz =0;
gen  __st =0;
gen  __lb =0;
gen  __ub =0;

qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');
 
gen  _xx =" ";
gen  _yy =" ";
gen  _zz =" ";
gen  _lb =" ";
gen  _ub =" ";

local pos=1;
local opos=1;
local part1=`par1'+1;
local part2=`par2'+1;

local minob=(`part1'+1)*(`part2'+1);
qui count;
if (`r(N)'<`minob') set obs `minob';


/* dis `band1' "  "`band2'; */

local pas1=((`part1' * `part2')/100);
local pas2=(`part1' * `part2')/10;

local prog1=`pas1';
local prog2=`pas2';

local comp=1;
local com2=10;
dis "ESTIMATION IN PROGRESS";


forvalues i=1/`part1' {; 
forvalues j=1/`part2' {;
local pl1 = _td1[`i'];
local pl2 = _td2[`j'];


cap drop `num1';
cap drop `num2';

qui gen  double `num1'=0;
qui gen  double `num2'=0;



if (`al1' == 0 & `al2' == 0)   qui replace   `num1' =        (`pl1'> `1')*(`pl2'> `2'); 
if (`al2' ~= 0 | `al2' ~= 0)   qui replace   `num1' =        ((`pl1'-`1')/`pl1')^`al1'*((`pl2'-`2')/`pl2')^`al2' if  (`pl1'>`1') & (`pl2'>`2');

if (`al1' == 0 & `al2' == 0)   qui replace    `num2' =        (`pl1'>`3')*(`pl2'>`4');
if (`al2' ~= 0 | `al2' ~= 0)   qui replace    `num2' =        ((`pl1'-`3')/`pl1')^`al1'*((`pl2'-`4')/`pl2')^`al2' if  (`pl1'>`3') & (`pl2'>`4');

qui replace   `num1' = `num1'*`hsize1';
qui replace   `num2' = `num2'*`hsize2';



qui svy: ratio (eq1: `num1'/`hsize1') (eq2:  `num2'/`hsize2'); 


qui nlcom (_b[eq2])-(_b[eq1]);

cap matrix drop _aa;
matrix _aa=r(b);
local  est = el(_aa,1,1);
matrix _vv=r(V);
local std = el(_vv,1,1)^0.5;
local llb = `est' - `tt'*`std';
local lub = `est' + `tt'*`std';

local dif = `est';

qui replace __xx = `pl1' in `opos';
qui replace __yy = `pl2' in `opos';
qui replace __zz = `est' in `opos';
qui replace __st = `std' in `opos';
qui replace __lb = `llb'  in `opos';
qui replace __ub = `lub'  in `opos';


if(`tgr'==1) {;
local ldif = round(`dif' ,0.0000000000001); 
local lub  = round(`lub' ,0.0000000000001); 
local llb  = round(`llb' ,0.0000000000001);
};

if(`tgr'==2) {;
local ldif = -1*(`dif'<0)+1*(`dif'>=0)  ;
local llb  = -1*(`llb'<0)+1*(`llb'>=0)  ;
local lub  = -1*(`lub'<0)+1*(`lub'>=0)  ;
};


qui replace _zz= "`ldif'" in `pos';
qui replace _lb= "`llb'"  in `pos';
qui replace _ub= "`lub'"  in `pos';

qui replace _xx=string(`pl1')     in `pos';
qui replace _yy=string(`pl2')     in `pos';


local pos=`pos'+1;
local opos=`opos'+1;
local comp=`comp'+1;
if( `comp' >=`prog1' ) {;
dis ".", _continue;
if( `comp' >=`prog2') {;
    dis "`com2':100";
    local prog2=`prog2'+`pas2'; 
    local com2=`com2'+10;
  };
 local prog1=`prog1'+`pas1';
};


};
local pos=`pos'+1;


};




end;




#delim ;
set more off;
capture program drop sdom2;
program define sdom2, rclass;
version 9.2;
syntax namelist [,  HSize(string)  
AL1(real 0)  AL2(real 0)   
MIN1(real 0) MAX1(real 10000) PAR1(int 20)
MIN2(real 0) MAX2(real 10000) PAR2(int 20) 
LEVEL(real 95) CONF(string) PROCESS(int 1) TGR(int 1)];

tokenize `namelist';


gen  _td1=`min1'+(_n-1)*(`max1'-`min1')/`par1';
gen  _td2=`min2'+(_n-1)*(`max2'-`min2')/`par2';




tempvar num1 num2; 



qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');
 
gen  _xx =" ";
gen  _yy =" ";
gen  _zz =" ";
gen  _st =" ";
gen  _lb =" ";
gen  _ub =" ";

gen __xx=0;
gen __yy=0;
gen __zz=0;
gen __st=0;
gen __lb=0;
gen __ub=0;

gen ___va=0;
gen ___zz=0;

local pos=1;
local opos=1;
local part1=`par1'+1;
local part2=`par2'+1;

local minob=(`part1'+1)*(`part2'+1);
qui count;
if (`r(N)'<`minob') set obs `minob';


/* dis `band1' "  "`band2'; */

local pas1=((`part1' * `part2')/100);
local pas2=(`part1' * `part2')/10;

local prog1=`pas1';
local prog2=`pas2';

local comp=1;
local com2=10;
dis "ESTIMATION IN PROGRESS: Distribution `process'";


forvalues i=1/`part1' {; 
forvalues j=1/`part2' {;
local pl1 = _td1[`i'];
local pl2 = _td2[`j'];

qui replace _xx=string(`pl1')     in `pos';
qui replace _yy=string(`pl2')     in `pos';

qui replace __xx = `pl1' in  `opos';
qui replace __yy = `pl2' in  `opos';

cap drop `num1' `num2';
qui gen  `num1'=0;
qui gen  `num2'=0;

if (`al1' == 0 & `al2' == 0  )   qui replace   `num1' =        (`pl1'> `1')*(`pl2'> `2');
if (`al1' ~= 0 | `al2' ~= 0  )   qui replace   `num1' =        ((`pl1'-`1')/`pl1')^`al1'*((`pl2'-`2')/`pl2')^`al2'  if (`pl1'>`1') & (`pl2'>`2');




qui replace   `num1' = `num1'*`hsize';


qui svy: ratio  `num1'/`hsize';

cap matrix drop _aa;
matrix _aa=e(b);
local est = el(_aa,1,1);
matrix _vv=e(V);
local var = el(_vv,1,1);



qui replace ___zz = `est'  in `pos';
qui replace ___va = `var'  in `pos';




local pos=`pos'+1;
local opos=`opos'+1;
local comp=`comp'+1;
if( `comp' >=`prog1' ) {;
dis ".", _continue;
if( `comp' >=`prog2') {;
    dis "`com2':100";
    local prog2=`prog2'+`pas2'; 
    local com2=`com2'+10;
  };
 local prog1=`prog1'+`pas1';
};


};
local pos=`pos'+1;


};


local kk=(`par1'+1)*(`par2'+2);

if (`process'==1){;
preserve;
keep __xx __yy ___zz ___va;
rename __xx __xx1; 
rename __yy __yy1;
rename ___zz ___zz1;
rename ___va ___va1;
qui keep in 1/`kk'; 
qui save __tempfile1, replace;
restore;
};


if (`process'==2){;
qui merge using __tempfile1;

local zzz=invnorm(`lvl');

local pos=1;
local opos=1;
forvalues i=1/`part1' {; 
forvalues j=1/`part2' {;
local dif =  ___zz1[`pos']-___zz[`pos'];
local std = (___va1[`pos']+___va[`pos'])^0.5;

local llb   = `dif' +  `zzz'*`std';
local lub   = `dif' -  `zzz'*`std';


local ldif = round(`dif' ,0.0000000000001); 
local lub  = round(`lub' ,0.0000000000001); 
local llb  = round(`llb' ,0.0000000000001);

if(`tgr'==2) {;
local ldif = -1*(`dif'<0)+1*(`dif'>=0)  ;
local llb  = -1*(`llb'<0)+1*(`llb'>=0)  ;
local lub  = -1*(`lub'<0)+1*(`lub'>=0)  ;
};


 
qui replace _zz= "`ldif'" in `pos';
qui replace _lb= "`llb'"  in `pos';
qui replace _ub= "`lub'"  in `pos';



qui replace __zz = `dif' in   `opos';
qui replace __st = `std' in   `opos';
qui replace __lb = `llb'  in  `opos';
qui replace __ub = `lub'  in  `opos';


local pos= `pos'+1;
local opos=`opos'+1;


};
local pos=`pos'+1;
};




};







end;








capture program drop dombdpov;
program define dombdpov, rclass;
version 9.2;

syntax  namelist(min=4 max=4) [, 
FILE1(string) FILE2(string) 
HSize1(string) HSize2(string) 
ALPHA1(real 0)  ALPHA2(real 0)
COND1(string)   COND2(string) 
LAB1(string)    LAB2(string) 
LEVEL(real 95) CONF(string)
DIF(int 1) LB(int 0) UB(int 0)
LRES(int  0) SRES(string) SRESG(string) 
MIN1(real 0) MAX1(real 10000) PAR1(int 20)
MIN2(real 0) MAX2(real 10000) PAR2(int 20) 
TITLE(string)
SGEMF(string)
TGR(int 1)
GIFTIT(int 1)
];

preserve;
if ("`conf'"=="")  local conf="ts";

qui count;
local minobs=(`par1'+2)*(`par2'+1); 

if (`r(N)'<`minobs') qui set obs `minobs';
	
tokenize `namelist';



if ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;
if (`"`file1'"'~="") use `"`file1'"', replace;


tempvar cd1;
cap drop _ths1;
qui gen _ths1=1;
if ( "`hsize1'"!="") qui replace _ths1=`hsize1';
if ( "`cond1'"!="") {;
gen `cd1'=`cond1';
qui replace _ths1=_ths1*`cd1';
qui sum `cd1';
if (`r(sum)'==0) {;
dis as error " With the condition(s) of distribution_1, the number of observations is 0.";
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
dis as error " With the condition(s) of distribution_2, the number of observations is 0.";
exit;
};
};


cap qui svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

sdom2d `namelist'  ,  hsize1(_ths1) hsize2(_ths2) 
min1(`min1') max1(`max1') par1(`par1')
min2(`min2') max2(`max2') par2(`par2')
al1(`alpha1') al2(`alpha2') 
level(`level') conf(`conf') tgr(`tgr');

dis "OK FIRST PART";




};


// second stage

if !( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) {;

if ("`file1'" !="") use `"`file1'"', replace;
tempvar cd1;
cap drop _ths1;
qui gen _ths1=1;

if ( "`hsize1'"!="") qui replace _ths1=`hsize1';
global counter=0;
if ( "`cond1'"!="") {;
gen `cd1'=`cond1';
qui replace _ths1=_ths1*`cd1';
qui sum `cd1';
if (`r(sum)'==0) {;
dis as error " With the condition(s) of distribution_1, the number of observations is 0.";
exit;
};
};


cap qui svy: total `1';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

sdom2 `1' `2' ,  hsize(_ths) 
min1(`min1') max1(`max1') par1(`par1')
min2(`min2') max2(`max2') par2(`par2')
al1(`alpha1') al2(`alpha2') 
level(`level') conf(`conf') process(1) tgr(`tgr');



if ("`file2'" !="") use `"`file2'"', replace;
global counter=50;
tempvar cd2;
cap drop _ths2;
qui gen _ths2=1;
if ( "`hsize2'"!="") qui replace _ths2=`hsize2';
if ( "`cond2'"!="") {;
gen `cd2'=`cond2';
qui replace _ths2=_ths2*`cd2';
qui sum `cd2';
if (`r(sum)'==0) {;
dis as error " With the condition(s) of distribution_2, the number of observations is 0.";
exit;
};
};
cap qui svy: total `3';
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
sdom2 `3' `4' ,  hsize(_ths2) 
min1(`min1') max1(`max1') par1(`par1')
min2(`min2') max2(`max2') par2(`par2')
al1(`alpha1') al2(`alpha2') 
level(`level') conf(`conf') process(2) tgr(`tgr');





};

dis "END: WAIT FOR THE GRAPH...";

local kk=(`par1'+1)*(`par2'+2);
qui keep in 1/`kk'; 



cap erase _coordinates_l.txt;
cap erase _coordinates_d.txt;
cap erase _coordinates_u.txt;
outfile _xx _yy _lb   using  _coordinates_l.txt,  noquote;
outfile _xx _yy _zz   using  _coordinates_d.txt,  noquote;
outfile _xx _yy _ub   using  _coordinates_u.txt,  noquote;

local surf="all";
if ("`conf'"=="lb") local surf="lb";
if ("`conf'"=="ub") local surf="ub";



qui findfile wgnuplot.exe;
local dir1="`r(fn)'";




local mylist = "__xx __yy __zz __st  __lb  __ub";

if( "`sresg'" ~= "") {;
outfile _xx _yy _lb _zz _ub  using `"`sresg'"',  noquote replace;
};

if( "`sres'" ~= "") {;
qui keep `mylist';
save `"`sres'"', replace;
};


/*************************/
   if ("`lab1'"=="") local  lab1 = "Dimension 1";
   if ("`lab2'"=="") local  lab2 = "Dimension 2";
   if ("`title'"=="") local title = "Bi-dimensional poverty dominance";
   cap file close myfile;
   cap file close myfile2;
   if ("`sgemf'"~="") {;
   tempfile  myfile;
   file open myfile   using "wprg_bdom.plt", write replace ;
   

   if (`tgr'==1) {;
   cap erase ttgr.emf;
   file write myfile `"set title  "`title'""' _n;
   file write myfile `"set xlabel "`lab1'""' _n;
   file write myfile `"set ylabel "`lab2'""' _n;
   file write myfile `"set ticslevel 0"' _n;
   file write myfile `"set terminal emf"' _n;
   file write myfile `"set out "`sgemf'.emf""' _n;
   if (`dif'== 1 & `lb' ==  0 & `ub' == 0)  file  write myfile  `"splot "_coordinates_d.txt" using 1:2:3 with lines t "Difference" "';
   if (`dif'== 0 & `lb' ==  1 & `ub' == 0)  file  write myfile  `"splot "_coordinates_l.txt" using 1:2:3 with lines t "Lower-bounded" "';
   if (`dif'== 0 & `lb' ==  1 & `ub' == 1)  file  write myfile  `"splot "_coordinates_l.txt" using 1:2:3 with lines t "Lower-bounded" , "_coordinates_u.txt" using 1:2:3 with line t "Upper-bounded" "';
   if (`dif'== 1 & `lb' ==  1 & `ub' == 1)  file  write myfile  `"splot "_coordinates_d.txt" using 1:2:3 with line  t "Difference"  , "_coordinates_l.txt" using 1:2:3 with line t "Lower-bounded" , "_coordinates_u.txt" using 1:2:3 with line t "Upper-bounded" "';
   if (`dif'== 0 & `lb' ==  0 & `ub' == 1)  file  write myfile  `"splot "_coordinates_u.txt" using 1:2:3 with lines t "Upper-bounded" "';
   if (`dif'== 1 & `lb' ==  1 & `ub' == 0)  file  write myfile  `"splot "_coordinates_d.txt" using 1:2:3 with line  t "Difference"  , "_coordinates_l.txt" using 1:2:3 with line t "Lower-bounded" "';
   if (`dif'== 1 & `lb' ==  0 & `ub' == 1)  file  write myfile  `"splot "_coordinates_d.txt" using 1:2:3 with line  t "Difference"  , "_coordinates_u.txt" using 1:2:3 with line t "Upper-bounded" "';
   file write myfile  `"reset"';
   file close myfile;
   winexec "`dir1'" "wprg_bdom.plt" ;
   };
    
   if (`tgr'==2) {;
  
   file write myfile `"set title  "`title'""' _n;
   file write myfile `"set xlabel "`lab1'""' _n;
   file write myfile `"set ylabel "`lab2'""' _n;
   if (`giftit'==0) {;
   file write myfile `"unset title "' _n;
   file write myfile `"unset xlabel "' _n;
   file write myfile `"unset ylabel "' _n;
   };
   file write myfile `"set ticslevel 0"' _n;
   file write myfile `"set terminal gif"' _n;
   file write myfile `"set out "`sgemf'.gif""' _n;
	file write myfile `"set view map "' _n;
	file write myfile `"set pm3d  "' _n;
	file write myfile `"set palette defined ( 0 "white", 1 "gray" )  "' _n;
	file write myfile `"set pal maxcolors 2 "' _n;
	file write myfile `"set hidden3d  "' _n;
	file write myfile `"unset key"' _n;
	
	
   if (`dif'== 1 & `lb' ==  0 & `ub' == 0)  file  write myfile  `"splot "_coordinates_d.txt" using 1:2:3 with lines t "Difference" "';
   if (`dif'== 0 & `lb' ==  1 & `ub' == 0)  file  write myfile  `"splot "_coordinates_l.txt" using 1:2:3 with lines t "Lower-bounded" "';
   if (`dif'== 0 & `lb' ==  0 & `ub' == 1)  file  write myfile  `"splot "_coordinates_u.txt" using 1:2:3 with lines t "Upper-bounded" "';
   
   file write myfile  `"reset"';
   file close myfile;
   winexec "`dir1'" "wprg_bdom.plt" ;
   };
   };


   tempfile   myfile2;
   file open  myfile2   using "wprg_bdom2.plt", write replace ;
   
   
   file write myfile2 `"reset"' _n;
   file write myfile2 `"set title  "`title'""' _n;
   file write myfile2 `"set xlabel "`lab1'""' _n;
   file write myfile2 `"set ylabel "`lab2'""' _n;
   file write myfile2 `"set ticslevel 0"' _n;
   
   if (`tgr'==1) {;
   if (`dif'== 1 & `lb' ==  0 & `ub' == 0)  file  write myfile2  `"splot "_coordinates_d.txt" using 1:2:3 with lines t "Difference" "';
   if (`dif'== 0 & `lb' ==  1 & `ub' == 0)  file  write myfile2  `"splot "_coordinates_l.txt" using 1:2:3 with lines t "Lower-bounded" "';
   if (`dif'== 0 & `lb' ==  1 & `ub' == 1)  file  write myfile2  `"splot "_coordinates_l.txt" using 1:2:3 with lines t "Lower-bounded" , "_coordinates_u.txt" using 1:2:3 with line t "Upper-bounded" "';
   if (`dif'== 1 & `lb' ==  1 & `ub' == 1)  file  write myfile2  `"splot "_coordinates_d.txt" using 1:2:3 with line  t "Difference"  , "_coordinates_l.txt" using 1:2:3 with line t "Lower-bounded" , "_coordinates_u.txt" using 1:2:3 with line t "Upper-bounded" "';
   if (`dif'== 0 & `lb' ==  0 & `ub' == 1)  file  write myfile2  `"splot "_coordinates_u.txt" using 1:2:3 with lines t "Upper-bounded" "';
   if (`dif'== 1 & `lb' ==  1 & `ub' == 0)  file  write myfile2  `"splot "_coordinates_d.txt" using 1:2:3 with line  t "Difference"  , "_coordinates_l.txt" using 1:2:3 with line t "Lower-bounded" "';
   if (`dif'== 1 & `lb' ==  0 & `ub' == 1)  file  write myfile2  `"splot "_coordinates_d.txt" using 1:2:3 with line  t "Difference"  , "_coordinates_u.txt" using 1:2:3 with line t "Upper-bounded" "';
   };
   
   if (`tgr'==2) {;
   file write myfile2 `"set view map "' _n;
   file write myfile2 `"set pm3d "' _n;	
   file write myfile2  `"set palette defined ( 0 "white", 1 "gray" )  "' _n;
   file write myfile2 `"set pal maxcolors 2 "' _n;
   file write myfile2 `"set hidden3d  "' _n;
   file write myfile2 `"unset key"' _n;
   if (`dif'== 1 & `lb' ==  0 & `ub' == 0)  file  write myfile2  `"splot "_coordinates_d.txt" using 1:2:3 with lines t "Difference" "';
   if (`dif'== 0 & `lb' ==  1 & `ub' == 0)  file  write myfile2  `"splot "_coordinates_l.txt" using 1:2:3 with lines t "Lower-bounded" "';
   if (`dif'== 0 & `lb' ==  0 & `ub' == 1)  file  write myfile2  `"splot "_coordinates_u.txt" using 1:2:3 with lines t "Upper-bounded" "';
   };
   
   file close myfile2;
   winexec "`dir1'" "wprg_bdom2.plt" - noraise;
   pwd;
;
   

     

/************************/


if( `lres' == 1) {;
set more off;
local kk=(`par1'+1)*(`par2'+1);
qui keep in 1/`kk';
local sep = `par1'+1;
list `mylist', separator(`sep') ;
};


restore;

end;



