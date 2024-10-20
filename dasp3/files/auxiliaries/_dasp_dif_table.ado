#delim ;
set more off;


cap program drop _dasp_dif_table;
program define _dasp_dif_table, rclass;
version 9.2;
syntax varlist(min=2 max=2)[,  
NAME1(string) NAME2(string)
M1(real 1)  M2(real 1)
S1(real 1)  S2(real 1)
DF1(int 1)   DF2(int 1)
DIF(real 0) SDIF(real 1)
LEVEL(int 95) INDEP(int 0)
CONF(string)
TEST(string)
];


                 


if ("`conf'"=="") local conf="ts";
if ("`conf'"!="ts")   local lvl = (1-(100-`level')/100);
if ("`conf'"=="ts")   local lvl = (1-(100-`level')/200);
 /*local lvl = (1-(100-`level')/100);*/

/* Display table of mean, std err, etc. */

local cilc = 59;
		noi di in smcl in gr "{hline 9}{c TT}{hline 68}";

                 noi di in smcl in gr "Index    {c |}" /*
                 */ _col(14) "Estimate" _col(25) /*
                 */ "Std. Err." _col(41) "t" _col(47) /*
         */ "P>|t|" _col(`cilc') `"[`=strsubdp("`level'")'% Conf. Interval]"';
                 noi di in smcl in gr "{hline 9}{c +}{hline 68}"; 


                      local lbl = "%9.0g  `lb'";
 if ("`conf'"=="ub")  local lbl = "-infinity  ";

 
  
 local beg = 9 - length(`"`name1'"');
                 local tval = `m1'/`s1';
                 local pval = tprob(`df1',`tval');
                 local ub = `m1'-invttail(`df1',`lvl')*`s1';
                 local lb = `m1'+invttail(`df1',`lvl')*`s1';
if ("`conf'"=="ts") {;
                 noi di in smcl in gr _col(`beg') `"`name1'"' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %9.0g  `m1'   /*
                 */ _col(24) %9.0g  `s1'     /*
                 */ _col(35) %8.0g  `tval'   /*
                 */ _col(46) %6.4f  `pval'   /*
                 */ _col(58) %9.0g  `lb'  /*
                 */ _col(70) %9.0g  `ub';
                 };

if ("`conf'"=="lb")
                   {;
                noi di in smcl in gr _col(`beg') `"`name1'"' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %9.0g  `m1'   /*
                 */ _col(24) %9.0g  `s1'     /*
                 */ _col(35) %8.0g  `tval'   /*
                 */ _col(46) %6.4f  `pval'   /*
                 */ _col(58) %9.0g  `lb'   /*
                 */ _col(70) "+infinity " ;
                 };

if ("`conf'"=="ub") 
                   {;
                 noi di in smcl in gr _col(`beg') `"`name1'"' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %9.0g  `m1'   /*
                 */ _col(24) %9.0g  `s1'     /*
                 */ _col(35) %8.0g  `tval'   /*
                 */ _col(46) %6.4f  `pval'   /*
                 */ _col(58) "-infinity "      /*
                 */ _col(70)  %9.0g    `ub'   ;
                 };

 
 local beg = 9 - length(`"`name2'"');
                 local tval = `m2'/`s2';
                 local pval = tprob(`df2',`tval');
               local ub = `m2'-invttail(`df2',`lvl')*`s2';
               local lb = `m2'+invttail(`df2',`lvl')*`s2';
              if ("`conf'"=="ts") {;
                 noi di in smcl in gr _col(`beg') `"`name2'"' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %9.0g  `m2'   /*
                 */ _col(24) %9.0g  `s2'     /*
                 */ _col(35) %8.0g  `tval'   /*
                 */ _col(46) %6.4f  `pval'   /*
                 */ _col(58) %9.0g  `lb'  /*
                 */ _col(70) %9.0g  `ub' ;
                 };

if ("`conf'"=="lb")
                   {;
                noi di in smcl in gr _col(`beg') `"`name2'"' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %9.0g  `m2'   /*
                 */ _col(24) %9.0g  `s2'     /*
                 */ _col(35) %8.0g  `tval'   /*
                 */ _col(46) %6.4f  `pval'   /*
                 */ _col(58) %9.0g  `lb'   /*
                 */ _col(70) "+infinity " ;
                 };

if ("`conf'"=="ub") 
                   {;
                 noi di in smcl in gr _col(`beg') `"`name2'"' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %9.0g  `m2'   /*
                 */ _col(24) %9.0g  `s2'     /*
                 */ _col(35) %8.0g  `tval'   /*
                 */ _col(46) %6.4f  `pval'   /*
                 */ _col(58) "-infinity "      /*
                 */ _col(70)  %9.0g    `ub'   ;
                 };



        di in smcl in gr "{hline 9}{c +}{hline 68}";

                   local df  = `df1';
 if (`indep' == 0) local df  = `df1'+`df2' ;


 local beg = 9 - length(`"diff"');
                 local tval = `dif'/`sdif';
                 local pval = tprob(`df2',`tval');
               local ub = `dif'-invttail(`df',`lvl')*`sdif';
               local lb = `dif'+invttail(`df',`lvl')*`sdif';

                 if ("`conf'"=="ts") {;
                 noi di in smcl in gr _col(`beg') `"diff."' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %9.0g  `dif'   /*
                 */ _col(24) %9.0g  `sdif'     /*
                 */ _col(35) %8.0g  `tval'   /*
                 */ _col(46) %6.4f  `pval'   /*
                 */ _col(58) %9.0g  `lb'  /*
                 */ _col(70) %9.0g  `ub';
                 };
				 
				  return scalar pv= `pval';

if ("`conf'"=="lb")
                   {;
                 noi di in smcl in gr _col(`beg') `"diff."' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %9.0g  `dif'   /*
                 */ _col(24) %9.0g  `sdif'     /*
                 */ _col(35) %8.0g  `tval'   /*
                 */ _col(46) %6.4f  `pval'   /*
                 */ _col(58) %9.0g  `lb'   /*
                 */ _col(70) "+infinity " ;
                 };

if ("`conf'"=="ub") 
                   {;
                 noi di in smcl in gr _col(`beg') `"diff."' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %9.0g  `dif'   /*
                 */ _col(24) %9.0g  `sdif'     /*
                 */ _col(35) %8.0g  `tval'   /*
                 */ _col(46) %6.4f  `pval'   /*
                 */ _col(58) "-infinity "      /*
                 */ _col(70)  %9.0g    `ub'  ;
                 };


di in smcl in gr "{hline 9}{c BT}{hline 68}";


if ("`test'" ~= "") {;

/* Compute statistics. */

        local t  = (`dif'-`test')/`sdif';
        local se = `sdif';

        local p = tprob(`df',`t');
        if `t' > 0 { ;
                local pl = `p'/2;
                local pr = 1 - `pl';
        };
        else {;
                local pr = `p'/2;
                local pl = 1 - `pr';
        };




        
        di as txt _col(6) "estimate(diff) = estimate(" as res /// 
                abbrev(`"`name2'"',16) as txt ///
                " - " as res abbrev(`"`name1'"',16) as txt ")" ///
                as txt _col(67) "t = " as res %8.4f `t' ;



/* Display Ho. */


        di as txt " Ho: estimate(diff) = `test'" _col(50) as txt ///
                "degrees of freedom = " as res %8.0f `df' ;

    di;

/* Display Ha. */

        local tt : di %8.4f `t';
        local p1 : di %6.4f `pl';
        local p2 : di %6.4f `p';
        local p3 : di %6.4f `pr';

        
        _ttest center2 " Ha: est.(diff) < `test'"  /*
        */             " Ha: est.(diff) != `test'" /*
        */             " Ha: est.(diff)  > `test'";


        _ttest center2 "Pr(T < t) = @`p1'@"   /*
        */             "Pr(|T| > |t|) = @`p2'@" /*
        */             "Pr(T > t) = @`p3'@";

 di in smcl in gr "{hline 9}{hline 69}";
 };



      

end;

