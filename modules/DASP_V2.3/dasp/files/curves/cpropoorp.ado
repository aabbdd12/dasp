/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/


#delim ;

capture program drop cpropoorp;
program define cpropoorp, rclass;
version 9.2;
syntax  namelist(min=2 max=2) [, 
FILE1(string) FILE2(string) 
HSize1(string) HSize2(string) 
ORDER(real 1) APP(string) CONS(real 0) TYPE(string) DEC(int 6)
COND1(string) COND2(string)
LEVEL(real 95)  CONF(string) LRES(int 0) SRES(string) 
MIN(string) MAX(string) DGRA(int 1) DHOL(int 1) SGRA(string) EGRA(string) *];

preserve;

if ("`conf'"=="")  local conf="ts";

  _get_gropts , graphopts(`options') getallowed(conf_area_opts conf_line_opts dif_line_opts hor_line_opts);
        local options `"`s(graphopts)'"';
        local conf_area_opts `"`s(conf_area_opts)'"';
        local conf_line_opts `"`s(conf_line_opts)'"';
        local dif_line_opts `"`s(dif_line_opts)'"';
        local hor_line_opts `"`s(hor_line_opts)'"';
qui count;
if (`r(N)'<101) qui set obs 101;



local alpha = `order'-1;

if ("`app'"=="")    local app="abs";
if ("`app'"=="abs") local type ="not";
if ("`app'"=="rel") local type ="nor";

cap matrix drop RES;

dis "ESTIMATION IN PROGRESS";
if ("`app'"=="abs") {;
capropoor `namelist', file1(`file1')  file2(`file2') hsize1(`hsize1') hsize2(`hsize2')
alpha(`alpha') min(`min') max(`max') cond1(`cond1') cond2(`cond2') 
cons(`cons') type(`type') conf(`conf') level(`level') dec(`dec');
};

if ("`app'"=="rel") {;
crpropoor `namelist', file1(`file1')  file2(`file2') hsize1(`hsize1') hsize2(`hsize2')
alpha(`alpha') min(`min') max(`max') cond1(`cond1') cond2(`cond2') 
 type(`type') conf(`conf') level(`level') dec(`dec');
};
dis "END: WAIT FOR THE GRAPH...";




cap drop _pline;  
cap drop _dif;    
cap drop  _lb;    
cap drop  _ub;   
mat colnames RES	= _pline _dif _ub _lb; 
svmat RES, name(col) ;


local m5 = (`max'-`min')/5;
gen _nl=0;
qui keep in 1/101;

                   local mylist = "_pline _dif _lb _ub";
if("`conf'"=="lb") local mylist = "_pline _dif _lb";
if("`conf'"=="ub") local mylist = "_pline _dif _ub"; 

if( `lres' == 1) {;
set more off;
list `mylist';
};

local drhline = "";
if (`dhol'==1) local drhline ="(line   _nl _pline,  sort clcolor(gs9) lpattern(solid) `hor_line_opts' 
)";
quietly {;

if (`dgra'!=0) {;
                     local sapp   = "Absolute";
if ("`app'"=="rel")  local sapp   = "Relative";
                     local estima = "P_2(z+cons., a=s-1) - P_1(z, a=s-1)";
if ("`app'"=="rel")  local estima = "P_2( (m2/m1)z, a=s-1) - P_1(z,a=s-1)";

local tit  = "`sapp' propoor curve"; // 
local stit = "(Order : s=`order' | Dif. = `estima')";

if("`conf'"=="ts") {;
twoway 
(rarea _lb _ub _pline, sort blcolor(ltbluishgray) 
blwidth(none)
blcolor(gs14) 
bfcolor(gs14) 
legend(order(1 "Confidence Interval"))
`conf_area_opts'
) 
(line _dif _pline, sort 
lcolor(black) 
lpattern(solid) 
legend(order(1 "Confidence interval (`level' %)" 2 "Estimated difference"))
title("`tit'")
subtitle("`stit'", size(small))
xtitle("Poverty line (z)") 
plotregion(margin(zero))
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max', labsize(small))
ylabel(, labsize(small))
`dif_line_opts'
`options'
)
`drhline'
; 
};

if("`conf'"=="lb") {;

twoway 
(
line  _dif _pline,
title("`tit'")
subtitle("`stit'", size(small))
xtitle("Poverty line (z)") 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max')
plotregion(margin(zero))
lcolor(black) 
lpattern(solid)
legend(
label(1 "Difference")
label(2 "Lower bound of `level'% confidence interval")
label(3 "Null horizontal line")
)
`options'
`dif_line_opts'
)
( line  _lb _pline, 
lcolor(black) 
lpattern(dash)
`conf_line_opts')
`drhline'
;
};

if("`conf'"=="ub") {;

twoway
(
line  _dif _pline,
lcolor(black) 
lpattern(solid)
title("`tit'")
subtitle("`stit'", size(small) )
xtitle("Poverty line (z)") 
xscale(range(`min' `max'))
xlabel(`min'(`m5')`max')
plotregion(margin(zero))
legend(
label(1 "Difference")
label(2 "Upper bound of `level'% confidence interval")
label(3 "Null horizontal line")
)
`options'
`dif_line_opts'
)
(line  _ub _pline, 
`conf_line_opts'
lcolor(black) 
lpattern(dash)
)

`drhline'
;
};






};
cap matrix drop _xx;
if( "`sres'" ~= "") {;
keep  `mylist';
save `"`sres'"', replace;
};

if( "`sgra'" ~= "") {;
graph save `"`sgra'"', replace;
};

if( "`egra'" ~= "") {;
graph export `"`egra'"', replace;
};

};



qui restore;

end;





