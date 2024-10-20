/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
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
MIN(real 0) MAX(real 1) DGRA(int 1) DHOL(int 1) SGRA(string) EGRA(string) NONA(string) SMOOTH(string) BAND(string)  *];

preserve;

if ("`conf'"=="")      local conf="ts";
if ("`nona'"=="anon")  local nona="";
if ("`smooth'"=="")  local smooth="yes";

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
conf(`conf') level(`level') dec(`dec') crv(`crv') nona(`nona') smooth(`smooth') band(`band');

local gr=r(gr);

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

gen _gr=`gr';
                   local mylist = "_corx _dif _lb _ub";
if("`conf'"=="lb") local mylist = "_corx _dif _lb";
if("`conf'"=="ub") local mylist = "_corx _dif _ub"; 

if( `lres' == 1) {;
set more off;
list `mylist';
};

local drhline = "";
if (`dhol'==1) local drhline           "(line   _nl _corx,  sort clcolor(gs9) lpattern(solid) `hor_line_opts' )";
               local drgline           "(line   _gr _corx,  sort clcolor(blue) lpattern(longdash))";
			   

quietly {;

if (`dgra'!=0) {;
                           local sapp= "absolute";
if (`crv'==3 | `crv'==6 )  local sapp= "relative";

                           local fstr= "Non-anonymous ";

						   
if ("`nona'"=="")      local fstr = "Anonymous "; 
				       local ref = "";
if ("`nona'"~="")      local ref = "Ref. period = `nona' | ";


if (`order'==1) {;
                      if (`crv'==1) local estima = "Q{subscript:2}(p) - Q{subscript:1}(p)";
                      if (`crv'==2) local estima = "( Q{subscript:2}(p) - Q{subscript:1}(p) ) / Q{subscript:1}(p) ";
                      if (`crv'==3) local estima = "Q_2(p) /Q{subscript:1}(p) - {&mu}{subscript:2}/{&mu}{subscript:1} ";
                    };

if (`order'==2) {;
                      if (`crv'==1) local estima = "GL{subscript:2}(p) - GL{subscript:1}(p)";
                      if (`crv'==2) local estima = "(GL{subscript:2}(p) - GL{subscript:1}(p) ) / GL{subscript:2}(p) ";
                      if (`crv'==3) local estima = "GL{subscript:2}(p)/GL{subscript:1}(p) - {&mu}{subscript:2}/{&mu}{subscript:1} ";
                    };
 

local tit  = "`fstr'`sapp' propoor curves"; // 
local stit = "( `ref' Order : s=`order' | Dif. = `estima')";

if("`conf'"=="ts") {;
twoway 
(rarea _lb _ub _corx, sort blcolor(ltbluishgray) 
fcolor(red) 
fintensity(10) 
lcolor(none) 
legend(order(1 "Confidence Interval"))
`conf_area_opts'
) 
(line _dif _corx, sort 
lcolor(black) 
lpattern(solid) 
legend(order(1 "Confidence interval (`level' %)" 2 "Estimated difference" 3 "Growth in average"))
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
`drgline'
`drhline'

,
graphregion(fcolor(white))
plotregion(margin(zero))
 xlabel(, nogrid)
 ylabel(, nogrid)
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
graphregion(fcolor(white))
lcolor(black) 
lpattern(solid)
legend(
label(1 "Difference")
label(2 "Lower bound of `level'% confidence interval")
label(3 "Null horizontal line")
)
`options'
`dif_line_opts'
plotregion(margin(zero))
legend(size(small))
 xlabel(, nogrid)
 ylabel(, nogrid)
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
graphregion(fcolor(white)) 
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






