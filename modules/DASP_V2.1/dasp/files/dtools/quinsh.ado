*! version 1.0.0  21nov2008
/**************************************/
/* By   : Araar Abdelkrim  (2005)     */
/* Universite Laval, Quebec, Canada   */
/* email : aabd@ecn.ulaval.ca         */
/* Phone : 1 418 656 7507             */
/* module: quinsh                     */
/* Date  : 21-11-2008                 */
/**************************************/

#delim ;
capture program drop quinsh;
program define quinsh, rclass sortpreserve;
version 9.0;
syntax varlist(min=1)[,  hsize(varname) PARtition(int 4) DEC(int 6) DGRaph(int 0) type(string) vname(string)]; 
tokenize `varlist';
qui sort `1';
local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear;
tempvar fw;
qui gen `fw'=1;
if ("`hsize'"~="")   qui replace `fw' = `hsize';
if ("`hweight'"~="")       qui replace `fw'=`fw'*`hweight';
tempvar perc;
qui     gen `perc' =  sum(`fw');
qui replace `perc' = `perc'/`perc'[_N];
cap drop _qgr;
gen _qgr=1;

local pas = 1/`partition';
local step1=0;
local step2=`pas';
forvalues i=1/`partition'{;
qui replace _qgr=`i' if ((`perc'>`step1') & (`perc'<=`step2'));
local step1=`step2';
local step2=`step1'+`pas';
local po = `i';
};
qui count;
qui replace _qgr=`po' in `r(N)';

tempvar q_in_sh; gen `q_in_sh' = 0;
qui sum `1' [aw=`fw']; local su = `r(sum)';
tempvar mlab;
gen `mlab'="Quant_Group_";
if `partition'== 4 qui  replace `mlab'="Quartile_";
if `partition'== 5 qui  replace `mlab'="Quintile_";
if `partition'== 10 qui replace `mlab'="Decile_";

                        local qgroup ="Quantiles Groups (`partition' Partitions)";
if `partition'== 4      local qgroup="Quartiles";
if `partition'== 5      local qgroup="Quintiles";
if `partition'== 10     local qgroup="Deciles"; 

forvalues i=1/`partition'{;
                      qui sum `1' [aw=`fw'] if _qgr==`i'; 
if ("`type'"=="cum")  qui sum `1' [aw=`fw'] if _qgr<=`i'; 
qui replace `q_in_sh' = `r(sum)'/`su' in `i';

local z=""; if (`i'<=9 & `partition' > 9) local z="0";
qui replace `mlab' = `mlab'[`i']+"`z'"+"`i'" in `i';
};

				local title = "Income share" ;
if ("`type'"=="cum")	local title = "Cumulative income share" ;

tempname table;
	.`table'  = ._tab.new, col(2)  separator(0) lmargin(0);
	.`table'.width  20|24  ;
	.`table'.strcolor . .  ;
	.`table'.numcolor yellow yellow  ;
	.`table'.numfmt %16.0g  %16.`dec'f  ;
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
      .`table'.sep, top;
	.`table'.titles "Group  " "`title'" ;
	.`table'.sep, mid;
	forvalues i=1/`partition'{;
           		.`table'.row `mlab'[`i'] `q_in_sh'[`i']; 
	};
     .`table'.sep,bot;

#delim ;
if (`dgraph'==1) {;
preserve;
qui keep in 1/`partition';
sort `q_in_sh';
graph hbar (asis) `q_in_sh',
                over(`mlab', sort((first) `q_in_sh')  descending) stack
                title( "`title' by `qgroup'")
                 ;
restore;
};
if ("`vname'" ~="") {;
cap drop `vname';
gen `vname' = _qgr;
};
cap drop _qgr;
end;




