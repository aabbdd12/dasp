#delim ;
set more off;

cap program drop datest;
program define datest;
version 9.2;
syntax anything [,  
EST(real 10) STE(real 1)
SLEVEL(real 5) DF(int 100) 
DIST(string)
CONF(string)
dgr(int 0)
];



tokenize `anything';
local test = `1'; 
if ("`dist'"=="") local dist="norm";             
if ("`conf'"=="") local conf="ts";
local level = 100 - `slevel';
if ("`conf'"!="ts")   local lvl = (1-(100-`level')/100);
if ("`conf'"=="ts")   local lvl = (1-(100-`level')/200);


/* Display table of mean, std err, etc. */

if ("`dist'" == "tstud") {;

local cilc = 59;
		noi di in smcl in gr "{hline 9}{c TT}{hline 68}";

                 noi di in smcl in gr "         {c |}" /*
                 */ _col(14) "Est. val." _col(25) /*
                 */ "Std. Err." _col(41) "t" _col(47) /*
         */ "P>|t|" _col(`cilc') `"[`=strsubdp("`level'")'% Conf. interval]"';
                 noi di in smcl in gr "{hline 9}{c +}{hline 68}"; 


                      local lbl = "%9.0g  `lb'";
 if ("`conf'"=="ub")  local lbl = "-infinity  ";

 
  




 local beg = 9 - length(`"Estimates"');
                 local tval = `est'/`ste';
                 local pval = tprob(`df',`tval');
                 local ub = `est'-invttail(`df',`lvl')*`ste';
                 local lb = `est'+invttail(`df',`lvl')*`ste';

                 if ("`conf'"=="ts") {;
                 noi di in smcl in gr _col(`beg') `"Estimates"' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %9.0g  `est'   /*
                 */ _col(24) %9.0g  `ste'     /*
                 */ _col(35) %8.0g  `tval'   /*
                 */ _col(46) %6.4f  `pval'   /*
                 */ _col(58) %9.0g  `lb'  /*
                 */ _col(70) %9.0g  `ub';
                 };

if ("`conf'"=="lb")
                   {;
                 noi di in smcl in gr _col(`beg') `"Estimates"' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %9.0g  `est'   /*
                 */ _col(24) %9.0g  `ste'     /*
                 */ _col(35) %8.0g  `tval'   /*
                 */ _col(46) %6.4f  `pval'   /*
                 */ _col(58) %9.0g  `lb'   /*
                 */ _col(70) "+infinity " ;
                 };

if ("`conf'"=="ub") 
                   {;
                 noi di in smcl in gr _col(`beg') `"Estimates"' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %9.0g  `est'   /*
                 */ _col(24) %9.0g  `ste'     /*
                 */ _col(35) %8.0g  `tval'   /*
                 */ _col(46) %6.4f  `pval'   /*
                 */ _col(58) "-infinity "      /*
                 */ _col(70)  %9.0g    `ub'  ;
                 };


di in smcl in gr "{hline 9}{c BT}{hline 68}";


if ("`test'" ~= "") {;

/* Compute statistics. */

        local t  = (`est'-`test')/`ste';
        local se = `ste';

        local p = tprob(`df',`t');
        if `t' > 0 { ;
                local pl = `p'/2;
                local pr = 1 - `pl';
        };
        else {;
                local pr = `p'/2;
                local pl = 1 - `pr';
        };
        
      


/* Display Ho. */
    
	   di      as txt  " Sign. level = `slevel' %"  ///
	            _col(30) as txt  "D.F. =" as res %8.0f `df' ///
                as txt _col(67) "t = " as res %8.4f `t' ;
	
di in smcl in gr "{hline 9}{hline 69}";

/* Display Ha. */

        local tt : di %8.4f `t';
        local p1 : di %6.4f `pl';
        local p2 : di %6.4f `p';
        local p3 : di %6.4f `pr';

        
        _ttest center2 " H0: est. <  `test'"  /*
        */             " H0: est. == `test'" /*
        */             " H0: est. >  `test'";
       
       	_ttest center2 "     Against       "  /*
        */             "     Against       " /*
        */             "     Against       ";
       		
        _ttest center2 " H1: est. >= `test'"  /*
        */             " H1: est. != `test'" /*
        */             " H1: est. <= `test'";

       di;
        _ttest center2 "Pr(T < t) = @`p1'@"   /*
        */             "Pr(|T| > |t|) = @`p2'@" /*
        */             "Pr(T > t) = @`p3'@";
		
		 forvalues i=1/3{;
		 if (`slevel'/100 < `p`i'') {;
		 local dec`i' = "H0 is not rejected."; 
		 };
		 else {;
		 local dec`i' = "  H0 is rejected. ";
		 };
		 };
		 
        _ttest center2 " `dec1'"  /*
        */             " `dec2'" /*
		*/             " `dec3'"  /*
        */ ; 		
di in smcl in gr "{hline 9}{hline 69}";

 };

};

if ("`dist'" == "norm") {;

local cilc = 59;
		noi di in smcl in gr "{hline 9}{c TT}{hline 68}";

                 noi di in smcl in gr "         {c |}" /*
                 */ _col(14) "Est. val." _col(25) /*
                 */ "Std. Err." _col(41) "z" _col(47) /*
         */ "P>|z|" _col(`cilc') `"[`=strsubdp("`level'")'% Conf. interval]"';
                 noi di in smcl in gr "{hline 9}{c +}{hline 68}"; 


                      local lbl = "%9.0g  `lb'";
 if ("`conf'"=="ub")  local lbl = "-infinity  ";

 
 

 local beg = 9 - length(`"Estimates"');
                 local zval = `est'/`ste';
                 local pval = normal(`zval');
                 local ub = `est'+invnormal(`lvl')*`ste';
                 local lb = `est'-invnormal(`lvl')*`ste';

                 if ("`conf'"=="ts") {;
                 noi di in smcl in gr _col(`beg') `"Estimates"' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %9.0g  `est'   /*
                 */ _col(24) %9.0g  `ste'     /*
                 */ _col(35) %8.0g  `zval'   /*
                 */ _col(46) %6.4f  `pval'   /*
                 */ _col(58) %9.0g  `lb'  /*
                 */ _col(70) %9.0g  `ub';
                 };

if ("`conf'"=="lb")
                   {;
                 noi di in smcl in gr _col(`beg') `"Estimates"' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %9.0g  `est'   /*
                 */ _col(24) %9.0g  `ste'     /*
                 */ _col(35) %8.0g  `zval'   /*
                 */ _col(46) %6.4f  `pval'   /*
                 */ _col(58) %9.0g  `lb'   /*
                 */ _col(70) "+infinity " ;
                 };

if ("`conf'"=="ub") 
                   {;
                 noi di in smcl in gr _col(`beg') `"Estimates"' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %9.0g  `est'   /*
                 */ _col(24) %9.0g  `ste'     /*
                 */ _col(35) %8.0g  `zval'   /*
                 */ _col(46) %6.4f  `pval'   /*
                 */ _col(58) "-infinity "      /*
                 */ _col(70)  %9.0g    `ub'  ;
                 };


di in smcl in gr "{hline 9}{c BT}{hline 68}";


if ("`test'" ~= "") {;

/* Compute statistics. */

        local z  = (`est'-`test')/`ste';
        local se = `ste';
   
        
        local p = 1-2*(normal(abs(`z'))-0.5);
		if `z'>0 {;
		local pr = normal(abs(`z'));
		local pl =  1 - `pr';
		};
		else {;
		local pl = normal(abs(`z'));
		local pr =  1 - `pl';
		};
	
		     

/* Display Ho. */

        di      as txt  " Sign. level = `slevel' %"  ///
                as txt _col(67) "z = " as res %8.4f `z' ;
        
        di in smcl in gr "{hline 9}{hline 69}";
/* Display Ha. */

        local zz : di %8.4f `z';
        local p1 : di %6.4f `pl';
        local p2 : di %6.4f `p';
        local p3 : di %6.4f `pr';

        _ttest center2 " H0: est. <  `test'"  /*
        */             " H0: est. == `test'" /*
        */             " H0: est. >  `test'";

		_ttest center2 "     Against       "  /*
        */             "     Against       " /*
        */             "     Against       ";
		
        _ttest center2 " H1: est. >= `test'"  /*
        */             " H1: est. != `test'" /*
        */             " H1: est. <= `test'";

       di;
        _ttest center2 "Pr(Z < z) = @`p1'@"   /*
        */             "Pr(|Z| > |z|) = @`p2'@" /*
        */             "Pr(Z > z) = @`p3'@";
		
		 forvalues i=1/3{;
		 if (`slevel'/100 < `p`i'') {;
		 local dec`i' = "H0 is not rejected."; 
		 };
		 else {;
		 local dec`i' = "  H0 is rejected. ";
		 };
		 };
		 
        _ttest center2 " `dec1'"  /*
        */             " `dec2'" /*
		*/             " `dec3'"  /*
        */ ; 		
di in smcl in gr "{hline 9}{hline 69}";


};


};


if (`dgr'==1) {;
preserve;
qui count;
if `r(N)'<2001 qui set obs 2001;



if ("`conf'" == "ts") {;
local plb=`slevel'/200;
local pub=(200-`slevel')/200;
};

if ("`conf'" == "ub") local plb=`slevel'/100;

if ("`conf'" == "lb") local pub=(100-`slevel')/100;


tempvar F z x f;
qui gen `F'=(_n-1)*0.0005;


if ("`dist'"=="norm") {;   
qui gen `z'=invnormal(`F');
qui gen `x'=`est'+`ste'*`z';
qui gen `f'=normalden(`x',`est',`ste');
};


if ("`dist'"=="tstud")  {;
qui gen `z'=invttail(`df', `F');
qui gen `x'=`est'+`ste'*`z';
qui gen `f'=tden(`df', `z');
};


local pgr twoway  (line `f' `x', sort) ;
if ("`conf'"=="ts" | "`conf'"=="ub") local pgr `pgr' (area `f' `x' if `F'<=`plb', 
fcolor(blue%20) lcolor(blue%20) 
plotregion(margin(zero))
ylabel(, labsize(small))
plotregion(margin(zero))
legend(size(small))
graphregion(fcolor(white)) 
 xlabel(, nogrid)
 ylabel(, nogrid)
graphregion(margin(medlarge))
)
;
if ("`conf'"=="ts" | "`conf'"=="lb") local pgr `pgr' (area `f' `x' if `F'>=`pub', 
fcolor(blue%20) lcolor(blue%20) 
plotregion(margin(zero))
ylabel(, labsize(small))
plotregion(margin(zero))
legend(size(small))
graphregion(fcolor(white)) 
 xlabel(, nogrid)
 ylabel(, nogrid)
graphregion(margin(medlarge))
;
local pgr `pgr' , 
plotregion(margin(zero))
legend(order( 1 "Density function" 2 "Critical range" ))
xtitle(Level)
ytitle(Density f(x))
xline(`est' `test')
)
; 
`pgr';
restore;
};
end;



