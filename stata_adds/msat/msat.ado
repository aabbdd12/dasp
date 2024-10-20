*! version 1.0.0  Araar, Abdelkrim 2015april02
*! a movestay postcommand to the ATT and AUT
*! based on Fugile and Bosch (1995) approach




#delim ;
set more off;


cap program drop _dis_table_at;
program define     _dis_table_at;
version 9.2;
syntax anything [,  
NAME1(string) NAME2(string) NAME3(string)
M1(real 1)  M2(real 1) M3(real 1)
S1(real 1)  S2(real 1) S3(real 1)
LEVEL(int 95) 
];

 local lvl = (1-(100-`level')/200);


qui svydes;
local fr=`r(N_units)'-`r(N_strata)';

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
                 local pval = tprob(`fr',`tval');
                 local ub = `m1'-invttail(`fr',`lvl')*`s1';
                 local lb = `m1'+invttail(`fr',`lvl')*`s1';

                 noi di in smcl in gr _col(`beg') `"`name1'"' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %9.0g  `m1'   /*
                 */ _col(24) %9.0g  `s1'     /*
                 */ _col(35) %8.0g  `tval'   /*
                 */ _col(46) %6.4f  `pval'   /*
                 */ _col(58) %9.0g  `lb'  /*
                 */ _col(70) %9.0g  `ub' ;


 
 local beg = 9 - length(`"`name2'"');
                 local tval = `m2'/`s2';
                 local pval = tprob(`fr',`tval');
               local ub = `m2'-invttail(`fr',`lvl')*`s2';
               local lb = `m2'+invttail(`fr',`lvl')*`s2';
                 noi di in smcl in gr _col(`beg') `"`name2'"' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %9.0g  `m2'   /*
                 */ _col(24) %9.0g  `s2'     /*
                 */ _col(35) %8.0g  `tval'   /*
                 */ _col(46) %6.4f  `pval'   /*
                 */ _col(58) %9.0g  `lb'  /*
                 */ _col(70) %9.0g  `ub';
				 
 local beg = 9 - length(`"`name3'"');
                 local tval = `m3'/`s3';
                 local pval = tprob(`fr',`tval');
               local ub = `m3'-invttail(`fr',`lvl')*`s3';
               local lb = `m3'+invttail(`fr',`lvl')*`s3';
                 noi di in smcl in gr _col(`beg') `"`name3'"' /*
                */ in gr _col(10) "{c |}" in ye /*
                 */ _col(12) %9.0g  `m3'   /*
                 */ _col(24) %9.0g  `s3'     /*
                 */ _col(35) %8.0g  `tval'   /*
                 */ _col(46) %6.4f  `pval'   /*
                 */ _col(58) %9.0g  `lb'  /*
                 */ _col(70) %9.0g  `ub' ;			 
				  di in smcl in gr "{hline 9}{hline 69}";
dis "Note:" _col(7) "The estimated standard errors ommit the part of samplind errors related" ; 
dis         _col(7) "to the estimation of the Beta's coefficients with the ESR model." ;           

end;






#delim ;
cap program drop msat;
program define msat, rclass;
	version 11;
	syntax varlist(min=1 max=1)   [if] [in]  [, hsize(varname) expand(string) ];
    if ("`e(cmd)'" ~= "movestay") error 301;
	tokenize `varlist' ;
	quietly {;
	tempvar y11 y12 y21 y22;
	mspredict_ar `y11' , yc1_1 ; if ("`expand'" =="yes")  replace `y11'= exp(`y11') ;
	mspredict_ar `y21',  yc2_1 ;  if ("`expand'" =="yes") replace `y21'= exp(`y21') ;
	mspredict_ar `y12',  yc1_2 ;  if ("`expand'" =="yes") replace `y12'= exp(`y12') ;
	mspredict_ar `y22',  yc2_2 ;  if ("`expand'" =="yes") replace `y22'= exp(`y22') ;
	tempvar  hs;
	qui gen `hs'=1;
	if ("`hsize'" ~= "") qui replace `hs'=`hsize';
    qui svyset ;
    if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
    tempvar d1 d2  d3;
	qui gen      `d1' = `hs'*(`y11'-`y21') if `1'==1;
	qui gen      `d2' = `hs'*(`y12'-`y22') if `1'==0;;
	qui gen      `d3' = `d1' if `1'==1;
	qui replace  `d3' = `d2' if `1'==0;
    qui svy: ratio `d1'/`hs' if `1'==1;
	
	tempname aa bb cc  vaa vbb vcc ;
	matrix `aa' = e(b);
	local att = el(`aa',1,1);
	matrix `vaa' = e(V);
	local satt = el(`vaa',1,1)^0.5;
	
	qui svy: ratio `d2'/`hs' if `1'==0;
	matrix `bb' = e(b);
	local atu = el(`bb',1,1);
	matrix `vbb' = e(V);
	local satu = el(`vbb',1,1)^0.5;
	
    qui svy: ratio `d3'/`hs'; 
	matrix `cc' = e(b);
	local ate = el(`cc',1,1);
	matrix `vcc' = e(V);
	local sate = el(`vcc',1,1)^0.5;
	
	return scalar att  = `att' ;
	return scalar atu  = `atu' ;
	return scalar atu  = `ate' ;
	}; /* end quietly */
	
dis _n "Estimated treatment effects based on the endogenous switching regression model" ;
_dis_table_at at , 
name1("ATT")          name2("ATU")  name3("ATE")
m1(`att')             m2(`atu')    m3(`ate')
s1(`satt')            s2(`satu')    s3(`sate')
 ;

end; /* end msat */

