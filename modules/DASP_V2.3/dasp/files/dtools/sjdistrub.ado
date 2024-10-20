/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3  )          */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : sjdistrub                                                    */
/*************************************************************************/

#delim ;
capture program drop sjdistrub;
program define sjdistrub, rclass;
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
 


cap drop __xx; cap drop __yy; cap drop __zz;

gen __xx=0;
gen __yy=0;
gen __zz=0;


 

gen  _td1=`min1'+(_n-1)*(`max1'-`min1')/`par1';
gen  _td2=`min2'+(_n-1)*(`max2'-`min2')/`par2';

gen  _xx=" ";
gen  _yy=" ";
gen  _zz=" ";

local pos=1;
local opos=1;
local part1=`par1'+1;
local part2=`par2'+1;

local minob=(`part1'+1)*(`part2'+1);
qui count;
if (`r(N)'<`minob') set obs `minob';


qui sum `fw', meanonly; local ssf=`r(sum)'^2;



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



qui replace __xx = `p1'   in  `opos';
qui replace __yy = `p2'   in  `opos';


qui replace _xx=string(_td1[`i'])     in `pos';
qui replace _yy=string(_td2[`j'])     in `pos';


qui sum `fw' if (`1'<=`p1') , meanonly; local sf1=`r(sum)';
qui sum `fw' if (`2'<=`p2') , meanonly; local sf2=`r(sum)';
local bidis=`sf1'*`sf2'/`ssf';

local dis = round(`bidis',0.000000000000001); 

qui replace _zz = "`dis'"  in   `pos';

qui replace __zz = `dis'  in   `opos';

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
   if ("`title'"=="") local title = "Joint distribution function";
   cap file close myfile;
   cap file close myfile2;
   if ("`sgemf'"~="") {;
   tempfile  myfile;
   file open myfile   using "wprg_jdis.plt", write replace ;
   file write myfile `"set title  "`title'""' _n;
   file write myfile `"set xlabel "`lab1'""' _n;
   file write myfile `"set ylabel "`lab2'""' _n;
   file write myfile `"set ticslevel 0"' _n;
   file write myfile `"set terminal emf"' _n;
   file write myfile `"set out "tgr.emf""' _n;
   file write myfile  `"splot "_coordinates.txt" using 1:2:3 with line t "f(x,y)" "';
   file write myfile  `"reset"';
   file close myfile;
   winexec "`dir1'" "wprg_jdis.plt" ;
   copy tgr.emf "`sgemf'", replace;
   };
   
   tempfile   myfile2;
   file open  myfile2   using "wprg_jdis2.plt", write replace ;
   file write myfile2 `"reset"' _n;
   file write myfile2 `"set title  "`title'""' _n;
   file write myfile2 `"set xlabel "`lab1'""' _n;
   file write myfile2 `"set ylabel "`lab2'""' _n;
   file write  myfile2 `"set ticslevel 0"' _n;
   file  write myfile2  `"splot "_coordinates.txt" using 1:2:3 with line t "f(x,y)" "';   
   file close  myfile2;
   winexec "`dir1'" "wprg_jdis2.plt" - noraise;

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



