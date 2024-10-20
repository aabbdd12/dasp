/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.1)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/


#delim ;
set more off;
capture program drop cpropoord;
program define cpropoord, rclass;
version 9.2;
syntax  namelist(min=2 max=2) [, 
FILE1(string) FILE2(string) 
HSize1(string) HSize2(string) 
 APP(string) TYPE(string) DEC(int 6) CRV(int 1)
COND1(string) COND2(string) 
LEVEL(real 95)  CONF(string) LRES(int 0) SRES(string) 
MIN(real 0) MAX(real 1) DGRA(int 1) DHOL(int 1) SGRA(string) EGRA(string) *];

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


if ("`app'"=="")    local app="abs";

if ("`crv'"=="")    local crv=1;

local order = 1;
if (`crv' > 3 )  {;
local order = 2;
local crv =`crv'-3;
};

cap matrix drop RES;

dis "ESTIMATION IN PROGRESS";

cpropoordi `namelist', file1(`file1')  file2(`file2') hsize1(`hsize1') hsize2(`hsize2')
order(`order') min(`min') max(`max') cond1(`cond1') cond2(`cond2') 
conf(`conf') level(`level') dec(`dec') crv(`crv');

dis "END: WAIT FOR THE GRAPH...";




cap drop _corx;  
cap drop _dif;    
cap drop  _lb;    
cap drop  _ub;   
mat colnames RES	= _corx _dif _lb _ub; 

svmat RES, name(col) ;

if (`min' == 0) {;
qui replace _corx =  0    in 1;
qui replace _dif  =  0    in 1;
qui replace _lb   =  0    in 1;
qui replace _ub   =  0    in 1;
};

local m5 = (`max'-`min')/5;
gen _nl=0;
qui keep in 1/101;

                   local mylist = "_corx _dif _lb _ub";
if("`conf'"=="lb") local mylist = "_corx _dif _lb";
if("`conf'"=="ub") local mylist = "_corx _dif _ub"; 

if( `lres' == 1) {;
set more off;
list `mylist';
};

local drhline = "";
if (`dhol'==1) local drhline ="(line   _nl _corx,  sort clcolor(gs9) lpattern(solid) `hor_line_opts' 
)";
quietly {;

if (`dgra'!=0) {;
                           local sapp= "Absolute";
if (`crv'==3 | `crv'==6 )  local sapp= "Relative";

if (`order'==1) {;
                      if (`crv'==1) local estima = "Q_2(p) - Q_1(p)";
                      if (`crv'==2) local estima = "( Q_2(p) - Q_1(p) ) / Q_2(p) ";
                      if (`crv'==3) local estima = "Q_2(p) /Q_1(p) - mu_2/mu_1 ";
                    };

if (`order'==2) {;
                      if (`crv'==1) local estima = "GL_2(p) - GL_1(p)";
                      if (`crv'==2) local estima = "(GL_2(p) - GL_1(p) ) / GL_2(p) ";
                      if (`crv'==3) local estima = "GL_2(p)/GL_1(p) - mu_2/mu_1 ";
                    };


local tit  = "`sapp' propoor curves"; // 
local stit = "(Order : s=`order' | Dif. = `estima')";

if("`conf'"=="ts") {;
twoway 
(rarea _lb _ub _corx, sort blcolor(ltbluishgray) 
blwidth(none)
blcolor(gs14) 
bfcolor(gs14) 
legend(order(1 "Confidence Interval"))
`conf_area_opts'
) 
(line _dif _corx, sort 
lcolor(black) 
lpattern(solid) 
legend(order(1 "Confidence interval (`level' %)" 2 "Estimated difference"))
title("`tit'")
subtitle("`stit'", size(small))
xtitle("Percentiles (p)") 
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
line  _dif _corx,
title("`tit'")
subtitle("`stit'", size(small))
xtitle("Percentiles (p)") 
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
( line  _lb _corx, 
lcolor(black) 
lpattern(dash)
`conf_line_opts')
`drhline'
;
};

if("`conf'"=="ub") {;

twoway
(
line  _dif _corx,
lcolor(black) 
lpattern(solid)
title("`tit'")
subtitle("`stit'", size(small) )
xtitle("Percentiles (p)") 
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
(line  _ub _corx, 
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






