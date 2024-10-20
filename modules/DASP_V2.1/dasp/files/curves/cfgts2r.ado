/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.1)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universite Laval , Quebec, Canada                                     */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : cdomc2d                                                     */
/*************************************************************************/

#delim ;

capture program drop cdomc2dc2;
program define cdomc2dc2, rclass;
version 9.2;
syntax varlist(min=1)[,  HWEIGHT(string) HSize(string) COMP1(string) COMP2(string) ALpha(real 1) PLINE(real 10000)
cnor(string)
];
preserve;
tokenize `varlist';
tempvar hs hsr hsy1 hsy2;
if ("`hsize'"~="") {;
gen `hs' =`hsize';
gen `hsr'=`hsize';
};

if ("`hsize'"=="") {;
gen `hs' =1;
gen `hsr'=1;
};

local al1 = `alpha' - 1;


if ("`hweight'"=="")   {;
tempvar hweight;
gen `hweight' = 1;
};

gen `hsy1'=`hs'*`comp1';
gen `hsy2'=`hs'*`comp2';

cap drop if `1'>=.;

cap drop  `tnum' `numi1' `numi2';
tempvar   tnum numi1 numi2;
qui gen    `tnum'= 0;
qui gen    `numi1'= 0;
qui gen    `numi2'= 0;
				    

if (`alpha' > 0) {;
if (`al1' == 0 & `pline' ~=0)               qui replace    `tnum' = `alpha'/`pline'*`hs'*(`pline'> `1');
if (`al1' ~= 0 & `pline' ~=0)               qui replace    `tnum' = `alpha'/`pline'*`hs'*((`pline'-`1')/`pline')^`al1'  if (`pline'>`1');                                           
 

qui replace    `numi1' = `tnum'*`comp1';
qui replace    `numi2' = `tnum'*`comp2';
};



if (`alpha' == 0) {;
tempvar fw;
qui gen `fw' =`hs'*`hweight';
qui su `1' [aw=`fw'], detail;           
local tmp = (`r(p75)'-`r(p25)')/1.34;                          
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
local h   = 0.9*`tmp'*_N^(-1.0/5.0);  
qui replace `tnum' =  `hs' *exp(-0.5* ( ((`pline'-`1')/`h')^2  )  )/( `h'* sqrt(2*c(pi)));  
qui replace `numi1' = `tnum'*`comp1';
qui replace `numi2' = `tnum'*`comp2';
};





if ("`cnor'"=="no"){;


qui svy: ratio `numi1'/`hs'; 
cap drop matrix _aa;
matrix _aa=e(b);
local est1 = el(_aa,1,1);
return scalar est1    = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local sest1 = el(_vv,1,1)^0.5;
return scalar sest1  = `sest1';

qui svy: ratio `numi2'/`hs'; 
cap drop matrix _aa;
matrix _aa=e(b);
local est2 = el(_aa,1,1);
return scalar est2    = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local sest2 = el(_vv,1,1)^0.5;
return scalar sest2  = `sest2';


tempvar numi;
gen `numi'=`numi2' - `numi1';
qui svy: ratio `numi'/`hsr'; 
cap drop matrix _aa;
matrix _aa=e(b);
local est3 = el(_aa,1,1);
return scalar est3    = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local sest3 = el(_vv,1,1)^0.5;
return scalar sest3  = `sest3';


};


if ("`cnor'"=="yes"){;


qui svy: ratio `numi1'/`hsy1'; 
cap drop matrix _aa;
matrix _aa=e(b);
local est1 = el(_aa,1,1);
return scalar est1    = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local sest1 = el(_vv,1,1)^0.5;
return scalar sest1  = `sest1';

qui svy: ratio `numi2'/`hsy2'; 
cap drop matrix _aa;
matrix _aa=e(b);
local est2 = el(_aa,1,1);
return scalar est2    = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local sest2 = el(_vv,1,1)^0.5;
return scalar sest2  = `sest2';

qui svy: mean `numi1' `hsy1' `numi2' `hsy2' ; 
qui nlcom _b[`numi2']/_b[`hsy2'] - _b[`numi1']/_b[`hsy1'], iterate(50000) ;
cap drop matrix _aa;
matrix _aa=r(b);
local est3 = el(_aa,1,1);
return scalar est3    = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=r(V);
local sest3 = el(_vv,1,1)^0.5;
return scalar sest3  = `sest3';


};


restore;
end;




capture program drop gcdomc2dc2;
program define gcdomc2dc2, rclass;
version 9.2;
syntax varlist(min=1)[,  HWEIGHT(string) HSize(string) COMP1(string) COMP2(string) ALpha(real 1) 
MIN(real 0) MAX(real 10000)
cnor(string)
type(string)
dci(string)
level(real 95)
conf(string)
label(string)
];
preserve;
tokenize `varlist';
tempvar hs hsr hsy;
if ("`hsize'"~="") {;
gen `hs' =`hsize';
gen `hsr'=`hsize';
};

if ("`hsize'"=="") {;
gen `hs' =1;
gen `hsr'=1;
};

local al1 = `alpha' - 1;

if ("`component'"~="")    qui replace `hs'  =`hs'*(`component'!=0);

if ("`hweight'"=="")   {;
tempvar hweight;
gen `hweight' = 1;
};
cap drop `hsy1' `hsy2';
tempvar hsy1 hsy2;
cap gen `hsy1'=`hs'*`comp1';
cap gen `hsy2'=`hs'*`comp2';

cap drop if `1'>=.;

cap drop  `numi1' `numi2';
tempvar numi1 numi2;

qui gen    `numi1'= 0;
qui gen    `numi2'= 0;


local al1 = `alpha' - 1;



if ("`hweight'"=="")   {;
tempvar hweight;
gen `hweight' = 1;
};


if ("`dci'"=="no") {;
qui replace `hs'  =  `hs'*`hweight';
qui replace `hsy1'=`hsy1'*`hweight';
qui replace `hsy2'=`hsy2'*`hweight';
};



tempvar ra vimpp _limpp _uimpp;

gen  `vimpp'=0;
gen `_limpp'=0;
gen `_uimpp'=0;


if ("`dci'"=="yes"){;
qui svydes;
local fr=`r(N_units)'-`r(N_strata)';
local lvl=(100-`level')/100;
if ("`conf'"=="ts") local lvl=`lvl'/2;
local tt=invttail(`fr',`lvl');
};






gen `ra'=0;
local pas = (`max'-`min')/100;
if (_N<101) qui set obs 101;


forvalues j=1/101 {;

qui replace `ra'=`min'+(`j'-1)*`pas' in `j';
local pline = `min'+(`j'-1)*`pas';


cap drop  `tnum' `numi1' `numi2';
tempvar   tnum numi1 numi2;
qui gen    `tnum'= 0;
qui gen    `numi1'= 0;
qui gen    `numi2'= 0;
				    

if (`alpha' > 0) {;
if (`al1' == 0 & `pline' ~=0)               qui replace    `tnum' = `alpha'/`pline'*`hs'*(`pline'> `1');
if (`al1' ~= 0 & `pline' ~=0)               qui replace    `tnum' = `alpha'/`pline'*`hs'*((`pline'-`1')/`pline')^`al1'  if (`pline'>`1');                                           
 

qui replace    `numi1' = `tnum'*`comp1';
qui replace    `numi2' = `tnum'*`comp2';
};



if (`alpha' == 0) {;
tempvar fw;
qui gen `fw' =`hs'*`hweight';
qui su `1' [aw=`fw'], detail;           
local tmp = (`r(p75)'-`r(p25)')/1.34;                          
local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
local h   = 0.9*`tmp'*_N^(-1.0/5.0);  
qui replace `tnum' =  `hs' *exp(-0.5* ( ((`pline'-`1')/`h')^2  )  )/( `h'* sqrt(2*c(pi)));  
qui replace `numi1' = `tnum'*`comp1';
qui replace `numi2' = `tnum'*`comp2';
};

 

qui sum `numi1'; local snumi1    = `r(sum)';
qui sum `numi2'; local snumi2    = `r(sum)';
qui sum `hs';    local shs       = `r(sum)';
qui sum `hsr';   local shsr      = `r(sum)';
qui sum `hsy1';  local shsy1     = `r(sum)';
qui sum `hsy2';  local shsy2     = `r(sum)';

if ("`cnor'"=="no"){;


if ("`dci'"=="no") {;
local impp = (`snumi2'-`snumi1')/`shs'; 
};

if ("`dci'"=="yes"){;
cap drop `numi';
tempvar numi;
gen `numi'=`numi2'-`numi1';
qui svy: ratio `numi'/`hsr';
matrix _aa=e(b);
local impp = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
local simpp = el(_vv,1,1)^0.5;
local limpp   = `impp' - `tt'*`simpp';
local uimpp   = `impp' + `tt'*`simpp';

};

};


if ("`cnor'"=="yes"){;


if ("`dci'"=="no"){;
local impp    = `snumi2'/`shsy2' - `snumi1'/`shsy1' ; 
};

if ("`dci'"=="yes"){;
qui svy: mean `numi1' `hsy1' `numi2' `hsy2';
qui nlcom _b[`numi2']/_b[`hsy2'] - _b[`numi1']/_b[`hsy1'], iterate(50000) ;
matrix _aa=r(b);
local impp = el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=r(V);
local simpp = el(_vv,1,1)^0.5;
local limpp   = `impp' - `tt'*`simpp';
local uimpp   = `impp' + `tt'*`simpp';
};

};

if ("`dci'"=="no") qui replace `vimpp'=`impp' in `j';
if ("`dci'"=="yes") {;
 qui replace `_limpp'=`limpp' in `j';
 qui replace `_uimpp'=`uimpp' in `j';
};

if (`j'!=101)  dis "." ,  _continue;
if (`j'/10==round(`j'/10)) dis " "  %4.2f `j' " %";

};
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
if ("`dci'"=="no")  mkmat `vimpp', matrix (_xx);
if ("`dci'"=="yes") mkmat `_limpp' `_uimpp', matrix (_xx);
restore;
end;





capture program drop cdomc2d;
program define cdomc2d, rclass;
version 9.2;
syntax varlist(min=1)[,  
HSize(varname)  good1(varname) good2(varname)  ORDER(real 1) PLINE(real 10000)
cnor(string)
DEC(int 9)
DSTE(int 1)
  LRES(int 0) SRES(string) DCI(string) LEVEL(real 95)
CONF(string) DIF(string) MIN(string) MAX(string) DGRA(int 1) SGRA(string) EGRA(string) *];

_get_gropts , graphopts(`options') ;
	local options `"`s(graphopts)'"';

local alpha = `order'-1;

if ("`cnor'"=="")     local cnor="no";
if ("`dci'"=="")      local dci="no";
if ("`conf'"=="")     local conf="ts";

preserve;
qui svyset ;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

tokenize `varlist';
local inc = "`1'" ;

if ("`clist'"!="") {;
tokenize    `clist';
_nargs      `clist';

};

local hweight=""; 
cap qui svy: total `1'; 

cap if (`e(wvar)') local hweight=`"`e(wvar)'"';
if ("`e(wvar)'"~="`hweight'") dis as txt in blue " Warning: sampling weight is initialized but not found.";


local dgr = "no";

if ("`max'" ~= "" ) local dgr = "yes";




if ("`dgr'" == "no" ){;


cdomc2dc2 `inc', hweight(`hweight') 
hsize(`hsize') comp1(`good1') comp2(`good2')   alpha(`alpha') pline(`pline') 
cnor(`cnor');


local name1 = "CD_`good1'";
local name2 = "CD_`good2'";
local name3 = "Difference";

forvalues i=1/3{;
local est`i' = `r(est`i')';
local sest`i' = `r(sest`i')';
};

qui svydes;
local df=`r(N_units)'-`r(N_strata)';

local cilc = 59;

noi di in smcl in gr "{hline 13}{c TT}{hline 68}";
		noi di in smcl in gr "Estimates    {c |}" /*
		*/ _col(17) "Diff." _col(25) /*
		*/ "Std. Err." _col(41) "t" _col(47) /*
	*/ "P>|t|" _col(`cilc') `"[`=strsubdp("`level'")'% Conf. Interval]"';
		noi di in smcl in gr "{hline 13}{c +}{hline 68}";

forvalues i=1/3{;
local beg = 14 - length(`"`name`i''"');

		local tval = `est`i''/`sest`i'';
		local pval = tprob(`df',`tval');
            local ub = `est`i''-invttail(`df',`level'/100)*`sest`i'';
	      local lb = `est`i''+invttail(`df',`level'/100)*`sest`i'';
		noi di in smcl in gr _col(`beg') `"`name`i''"' /*
		*/ in gr _col(13) "{c |}" in ye /*
		*/ _col(14) %9.0g  `est`i''   /*
		*/ _col(24) %9.0g  `sest`i''     /*
		*/ _col(35) %8.0g  `tval'   /*
		*/ _col(46) %6.4f  `pval'   /*
		*/ _col(58) %9.0g  `lb'  /*
		*/ _col(70) %9.0g  `ub';

if (`i' ==  2  ) noi di in smcl in gr "{hline 13}{c +}{hline 68}";
};
di in smcl in gr "{hline 13}{c BT}{hline 68}";



}; //DGRAPH NO




if ("`dgr'" ~= "no" ){;
set more off;
dis "ESTIMATION IN PROGRESS";

tempvar fw;
local _cory  = "";
local _coryl  = "";
local _coryu  = "";
local mcmd   = "";
local label  = "";
quietly{;
local tits="";
local tits="s";
gen `fw'=1;
local tit1="Difference Between Consumption Dominance"; 
local tit2="Difference"; 
local tit3="";
local tit4="";

if ("`type'"=="nor") {;
local tit3="";
local tit4="Normalised ";
};


local ftitle = "Difference Between Consumption Dominance Curve`tits'";
                   local ytitle = "Difference";
if ("`hsize'"  ~="")      replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")      replace `fw'=`fw'*`hweight';
};

qui count;
qui sum `1';
if ("`min'"  =="")      local min =`r(min)';
if ("`max'"  =="")      local max =`r(max)';

if (r(N)<101) qui set obs 101;


local k=1;


                                     local _cory  = "`_cory'" + " _cory`k'";
if ("`dci'"=="yes" & "`conf'"=="ts") local mcmd  = "`mcmd'" + "(rarea  _coryl`k'  _coryu`k' _corx) ";

local f=`k';
local kk = `k';
local k1 = `1';

if ( "`label1'" == "")   local labelg1    = "``1''";
if ( "`label`f''" == "") local label`f'   = "``kk''";



gcdomc2dc2 `inc', hweight(`hweight') 
hsize(`hsize') comp1(`good1') comp2(`good2') alpha(`alpha') min(`min') max(`max')
cnor(`cnor') dci(`dci') level(`level') conf(`conf') label(`label`f'');


svmat float _xx;
cap matrix drop _xx;
if ("`dci'"=="no") rename _xx1 _cory`k';

if ("`dci'"=="yes"){;

if ("`conf'"=="ts") {;
 rename _xx1 _coryl`k';
 rename _xx2 _coryu`k';
};

if ("`conf'"=="lb"){;
rename _xx1 _cory`k';
};

if ("`conf'"=="ub"){;
 rename _xx2 _cory`k';
};

};

cap drop _xx*;

qui keep in 1/101;
gen _corx=0;
local pas = (`max'-`min')/100;
local m5 = (`max'-`min')/5;
forvalues j=1/101 {;
qui replace _corx=`min'+(`j'-1)*`pas' in `j';
};

                      local typeb = "Lower";
if ("`conf'"=="ub")   local typeb = "Upper";

if ("`dif'"=="c1") {;
gen _dct=_cory1;
forvalues k = 1/$indica {;
qui replace _cory`k'=_cory`k'-_dct;
};
local label1  ="Null horizontal line";
};

if( `lres' == 1) {;
set more off;
list _corx _cory*;
};
quietly {;

if (`dgra'!=0) {; 
dis "END: WAIT FOR THE GRAPH...";

if ("`dci'"=="no"){;
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
subtitle("(order = `order')")
ytitle(`ytitle')
xtitle(Poverty line (z)) 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
plotregion(margin(zero))
graphregion(margin(medlarge))
legend(size(medsmall))
`options'
;

};


if ("`dci'"=="yes"){;

if ("`conf'"=="ts"){;
twoway `mcmd'
, 
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
subtitle("Confidence interval(`level'%) | (order = `order') ")
ytitle(`ytitle')
xtitle(Poverty line (z)) 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
plotregion(margin(zero))
graphregion(margin(medlarge))
legend(size(medsmall))
`options'
;
};

if ("`conf'"~="ts") {;
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
subtitle("`typeb' bound(`level'%) | (order = `order')")
ytitle(`ytitle')
xtitle(Poverty line (z)) 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
plotregion(margin(zero))
graphregion(margin(medlarge))
legend(size(medsmall))
`options'
;
};

};


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
};

}; // GRAPH YES




end;



