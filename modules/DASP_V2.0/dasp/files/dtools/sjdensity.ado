/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 1.5  )          */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universit Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : sjdensity                                                    */
/*************************************************************************/

#delim ;
capture program drop sjdensity;
program define sjdensity, rclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) HGroup(varname) NGroup(int 1) 
  BAND1(real 0)  BAND2(real 0) 
  LRES(int  0) SRES(string) SRESG(string)  
  MIN1(real 0) MAX1(real 10000) PAR1(int 20)
  MIN2(real 0) MAX2(real 10000) PAR2(int 20)
  LAB1(string)    LAB2(string) 
  TITLE(string)
  SGEMF(string)
   *];

preserve;
tokenize `varlist';
tempvar hs;
gen `hs'=1;
if ("`hsize'"    ~="")      qui replace `hs'=`hsize';
if ("`hgroup'"   ~="")      qui replace `hs'=`hs'*(`hgroup'==`ngroup');

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 

tempvar fw;
gen `fw'=`hs';
if (`"`hweight'"'~="") qui replace `fw'=`fw'*`hweight';




cap drop _x _y _z1 _z2 _dz _td1 _td2 _zz _xx _yy;
 


qui su `1' [aw=`fw'], detail;   
local tmp1 = (`r(p75)'-`r(p25)')/1.34;                           
local tmp1 = (`tmp1'<`r(sd)')*`tmp1'+(`tmp1'>=`r(sd)')*`r(sd)';     
local h1   = 0.9*`tmp1'*_N^(-1.0/5.0); 
if (`band1' == 0) local band1=`h1';  

qui su `2' [aw=`fw'], detail;    
local tmp2 = (`r(p75)'-`r(p25)')/1.34;                           
local tmp2 = (`tmp2'<`r(sd)')*`tmp2'+(`tmp2'>=`r(sd)')*`r(sd)';     
local h2   = 0.9*`tmp2'*_N^(-1.0/5.0); 
if (`band2' == 0)  local band2=`h2'; 
 

gen  _td1=`min1'+(_n-1)*(`max1'-`min1')/`par1';
gen  _td2=`min2'+(_n-1)*(`max2'-`min2')/`par2';

gen  _xx=" ";
gen  _yy=" ";
gen _zz=" ";

local pos=1;
local opos=1;
local part1=`par1'+1;
local part2=`par2'+1;

local minob=(`part1'+1)*(`part2'+1);
qui count;
if (`r(N)'<`minob') set obs `minob';

/*

local tmp=(`tmp1'+`tmp2')/2;
local h   = 0.96*`tmp'*_N^(-1.0/6.0); 
if (`band'==0) local band=`h';  

*/

cap drop __xx; cap drop __yy; cap drop __zz;

gen __xx=0;
gen __yy=0;
gen __zz=0;

cap drop `_s2'; 
tempvar   _s2;
gen `_s2'=sum(`fw');


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
local p1 = _td1[`i'];
local p2 = _td2[`j'];
qui replace _xx=string(_td1[`i'])     in `pos';
qui replace _yy=string(_td2[`j'])     in `pos';


cap drop `_s1'; 
tempvar   _s1;


qui gen  `_s1' = sum(  `fw' * (  exp(-0.5* (  ((`p1'-`1')/`band1')^2) + -0.5* (  ((`p2'-`2')/`band2')^2))  ));
local densi =  `_s1'[_N]/ ((`band1'*`band2')*2*c(pi)* `_s2'[_N] );


local density = round(`densi',0.000000000000001); 
qui replace _zz= "`density'" in `pos';

qui replace __xx = `p1'   in   `opos';
qui replace __yy = `p2'   in   `opos';
qui replace __zz = `densi' in  `opos';

local pos =`pos'+1;
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

local mylist = "__xx __yy __zz";

dis "WAIT FOR THE GRAPH...";
local ka=`part1'*(`part2'+1);

qui keep in 1/`ka';

cap erase _coordinates.txt;
outfile _xx _yy _zz  using _coordinates.txt,  noquote;

if( "`sresg'" ~= "") {;
outfile _xx _yy _zz  using `"`sresg'"',  noquote replace;
};

qui findfile wgnuplot.exe;
local dir1="`r(fn)'";





   /*************************/

   if ("`lab1'"=="") local  lab1 = "Dimension 1";
   if ("`lab2'"=="") local  lab2 = "Dimension 2";
   if ("`title'"=="") local title = "Joint density function";
   cap file close myfile;
   cap file close myfile2;
   if ("`sgemf'"~="") {;
   tempfile  myfile;
   file open myfile   using "wprg_jden.plt", write replace ;
   file write myfile `"set title  "`title'""' _n;
   file write myfile `"set xlabel "`lab1'""' _n;
   file write myfile `"set ylabel "`lab2'""' _n;
   file write myfile `"set ticslevel 0"' _n;
   file write myfile `"set terminal emf"' _n;
   file write myfile `"set out "tgr.emf""' _n;
   file write myfile  `"splot "_coordinates.txt" using 1:2:3 with line t "f(x,y)" "';
   file write myfile  `"reset"';
   file close myfile;
   winexec "`dir1'" "wprg_jden.plt" ;
   copy tgr.emf "`sgemf'", replace;
   };
   
   tempfile   myfile2;
   file open  myfile2   using "wprg_jden2.plt", write replace ;
   file write myfile2 `"reset"' _n;
   file write myfile2 `"set title  "`title'""' _n;
   file write myfile2 `"set xlabel "`lab1'""' _n;
   file write myfile2 `"set ylabel "`lab2'""' _n;
   file write  myfile2 `"set ticslevel 0"' _n;
   file  write myfile2  `"splot "_coordinates.txt" using 1:2:3 with line t "f(x,y)" "';   
   file close  myfile2;
   winexec "`dir1'" "wprg_jden2.plt" - noraise;

  /************************/


local kk=(`par1'+1)*(`par2'+1);

if( `lres' == 1) {;
qui keep in 1/`kk';
set more off;
local sep = `par1'+1;
list `mylist', separator(`sep') ;
};

if( "`sres'" ~= "") {;
qui keep in 1/`kk';
qui keep `mylist';
save `"`sres'"', replace;
};



restore;

end;



