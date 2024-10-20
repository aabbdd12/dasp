
/* TASKS 

Inputs:
for each group a martrix // Last pop matrix
group names gr1 | gr2 |...
*/



#delim ;
set more off;

cap program drop tabstr;
program define tabstr, rclass;
syntax namelist(min=1)[,   dec1(int 4)   dec2(int 4)   dec3(int 4)   dec4(int 4) dec5(int 4)   dec6(int 4)  dec7(int 4)   dec8(int 4)   dec9(int 4)  ];
local nmat: word count `namelist' ;  
tokenize `namelist' ;
local nr = rowsof(`1');
local nc = colsof(`1');
forvalues c=1/`nc' {;
local sc_`c' = 9;
forvalues m=1/`nmat' {;
forvalues r=1/`nr'   {;
   local val = el(``m'',`r',`c') ;
   local ll = int(`val') ;
   local zz = "`ll'";
   local vv = length("`zz'");
   local vv = max(1, `vv') ;
   local sc_`c' = max(`sc_`c'', `vv'+`dec`c'' + 1);
};	
};
/* dis "col `c' : " `sc_`c'' ; */
local sc_`c' = max(9, `sc_`c'');
return scalar wic`c' = `sc_`c'' ;
};


end;

cap program drop _dis_dasp_table_2d ;
program define _dis_dasp_table_2d, rclass;
version 9.2;
syntax namelist(min=1)[,  
NAME1(string) 
M1(real 1)  
S1(real 1)  
FILE1(string) FILE2(string) 
DF(int 1) 
LEVEL(int 95) 
CONF(string)
hgroup(namelist)
dec1(int 4)   dec2(int 4)   dec3(int 4)   dec4(int 4) dec5(int 4)   dec6(int 4) 
pop(int 1)
gro(int 1)
test(string)
index(string)
];
preserve ;
local slevel = 100-`level' ;
local ddep=0;
local nvars = 1;
if ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) local ddep=1;


if "`file1" ~="" & `ddep' == 0 { ;
qui use "`file1'", replace; 
};


if "`conf'" == "" local conf = "ts" ;
if "`level'" == "" local level = 95 ;                 
tokenize `namelist' ;
local nmat: word count `namelist' ;
tabstr `namelist', dec1(`dec1')   dec2(`dec2')   dec3(`dec3')   dec4(`dec4') dec5(`dec5')   dec6(`dec6') ;
local wic1=r(wic1) ;
local wic2=r(wic3) ;
local wic3=r(wic5) ;
local wic4=r(wic6) ;

local wfc = 18;
// set trace on ;
if ("`hgroup'" ~= "") {;
tokenize `hgroup';
_nargs   `hgroup' ;

local nhgroups = $indica;
forvalues i=1/$indica {;
local hgroup_`i' = "``i''" ;
local lhgroup_`i' = "``i''" ;

local tmp  ``i'' ;
local lab: variable label `tmp';

if ("`lab'" ~= "" )  local lhgroup_`i' = "`lab'" ;
local wfc = max(`wfc', strlen("`lhgroup_`i''") );    
};



forvalues g=1/`nhgroups' { ;
qui levelsof `hgroup_`g'', local(mygr);
local mystr `r(levels)';
local i = 1;
foreach x of local mygr {;
local ngr `: word count `mystr'' ;
local label : label (`hgroup_`g'') `x' ;

if `"`label'"' == "`x'" local label = "Group_`hgroup_`g''_`x'" ;
local ltmp_`g'_`i' `"`label'"' ;
local i = `i'+1;
local wfc = max(`wfc', strlen("`label'")+1 );
};
};

};
local ltmp_pop `"Population"' ;
local wfc = max(`wfc', 11 );




if ("`conf'"=="") local conf="ts";
if ("`conf'"!="ts")   local lvl = (1-(100-`level')/100);
if ("`conf'"=="ts")   local lvl = (1-(100-`level')/200);
 /*local lvl = (1-(100-`level')/100);*/

/* Display table of mean, std err, etc. */

if `gro'==1  local crtit = "Population groups" ;
if `pop'==2  local crtit = "Varnames" ;
local beg =  `wfc'+5;
local bz0 = `beg' +1;
local bz1 = 14+ `beg' - 9 ;
local bz11 = `beg' + `wic1' - 5 ;
local bz2  =  `bz1' +4 + `wic1';
local bz3  =  `bz2' +4 + `wic2';
local bz4  = `bz3'  +4 + `wic3' ;
local bz5  = `bz4'+ 2 + `wic4' ;
local bz6  = `bz5'+ 12 ;
local bz7 = `bz6'+ 8 ;
local bz8 = `bz7'+ 11 ;

/*
forvalues i=1/4 {;
	dis `bal`i'' " : " `bz`i'' ;
};
*/
local bal1 = `bz11' +1 ;
local bal2 = `bz2'  ;
local bal3 = `bz3' -1 ;
local bal4 = `bz4' +1   ;
local bal5 = `bz5'+4  ;
local bal6 = `bz6'   ;
local bal7 = `bz7'   ;
local hbl = `bz8' - `beg' + 7 ;
local beg0 = `beg' ;



local hbl = `bz8' - `beg' + 7 ;

local beg0 = `beg' ;
tokenize `namelist' ;

		noi di in smcl in gr "{hline `beg'}{c TT}{hline `hbl'}";
		
         noi di in smcl in gr "{yellow:`crtit'}   " in gr _col(`beg') " {c |}" /*
                                 */ _col(`bal1') "Estimate1" /*
								 */ _col(`bal2') "Estimate2"  /*
                              */ _col(`bal3') "Difference" _col(`bal4') /*
                 */ "Std. Err." _col(`bal5') "t" _col(`bal6') /*
				 */ "P>|t|" _col(`bal7') `"[`=strsubdp("`level'")'% Conf. Interval]"';
                  noi di in smcl in gr "{hline `beg'}{c +}{hline `hbl'}" as smcl;
				  

                      local lbl = "%9.0g  `lb'";
 if ("`conf'"=="ub")  local lbl = "-infinity  ";
                local   nmat1 = `nmat';
 if (`pop' == 1 | `pop' == 2)  local nmat1 =  `nmat' - 1;
 

 if (`gro' == 1) {;
 forvalues g=1/`nmat1' {;
  local ngr = rowsof(``g'');
  local tt = `beg0'-length(`"`lhgroup_`g''"') ;
  noi di in smcl in gr _col(`tt')  `"{yellow:{it:`lhgroup_`g''}}"'  as result in gr _col(`bz0') "{c |}" in ye in smcl;
 forvalues i=1/`ngr' {;
 
 /* set trace on ; */
   local m1 = el(``g'',`i', 1) ;
   local m2 = el(``g'',`i', 3) ;
   local dif = el(``g'',`i', 5) ;
   local ste = el(``g'',`i', 6) ;

   /*
   local ll = int(`m1') ;
   local zz = "`ll'";
   local vv = length("`zz'");
  /* dis "icit: `i' : `vv'" ; */
  */ 
  local beg = 9 - length(`"`name1'"');
                 local tval = `dif'/`ste';
                 local pval = tprob(`df',`tval');
                 local ub = `dif'-invttail(`df',`lvl')*`ste';
                 local lb = `dif'+invttail(`df',`lvl')*`ste';
if ("`conf'"=="ts") {;
                 noi di in smcl in gr _col(`beg') `"- `ltmp_`g'_`i''"' /*
                */ in gr _col(`bz0') "{c |}" in ye /*
                 */ _col(`bz1') %`wic1'.`dec1'f  `m1'   /*
                 */ _col(`bz2') %`wic2'.`dec1'f  `m2'     /*
				 */ _col(`bz3') %`wic3'.`dec1'f  `dif'     /*
				 */ _col(`bz4') %`wic4'.`dec1'f  `ste'     /*
                 */ _col(`bz5') %9.0g  `tval'   /*
                 */ _col(`bz6') %6.4f  `pval'   /*
                 */ _col(`bz7') %9.0g  `lb'  /*
                 */ _col(`bz8') %9.0g  `ub' ;
                 };
				 
				

if ("`conf'"=="lb")
                   {;
                 noi di in smcl in gr _col(`beg') `"- `ltmp_`g'_`i''"' /*
                */ in gr _col(`bz0') "{c |}" in ye /*
			     */ _col(`bz1') %`wic1'.`dec1'f  `m1'   /*
                 */ _col(`bz2') %`wic2'.`dec1'f  `m2'     /*
				 */ _col(`bz3') %`wic3'.`dec1'f  `dif'     /*
				 */ _col(`bz4') %`wic4'.`dec1'f  `ste'     /*
                 */ _col(`bz5') %9.0g  `tval'   /*
                 */ _col(`bz6') %6.4f  `pval'   /*
                 */ _col(`bz7') %9.0g  `lb'  /*
                 */ _col(`bz8') "+infinity " ;
                 };

if ("`conf'"=="ub") 
                   {;
                  noi di in smcl in gr _col(`beg') `"- `ltmp_`g'_`i''"' /*	
				  */ in gr _col(`bz0') "{c |}" in ye /*
				  */ _col(`bz1') %`wic1'.`dec1'f  `m1'   /*
                 */ _col(`bz2') %`wic2'.`dec1'f  `m2'     /*
				 */ _col(`bz3') %`wic3'.`dec1'f  `dif'     /*
				 */ _col(`bz4') %`wic4'.`dec1'f  `ste'     /*
                 */ _col(`bz5') %9.0g  `tval'   /*
                 */ _col(`bz6') %6.4f  `pval'   /*
                 */ _col(`bz7') "-Infinity "   /*
                 */ _col(`bz8') %9.0g  `ub' ;
                 };

 };
 if `g'<`nmat1' dis   _col(`bz0') "{c |}" in ye;;
 };
 local beg =  `wfc'+5;
 if `pop'==0  di in smcl in gr "{hline `beg'}{c BT}{hline `hbl'}" in ye;
 
 };
 
 if `pop'==1 {;
	  local tt = `beg0'-length(`"Population"') ;
	 if `gro' == 1   noi di in smcl in gr "{hline `beg'}{c +}{hline `hbl'}";
   local m1 = el(_ms_pop,1, 1) ;
   local m2 = el(_ms_pop,1, 3) ;
   local dif = el(_ms_pop,1, 5) ;
   local ste = el(_ms_pop,1, 6) ;

   /*
   local ll = int(`m1') ;
   local zz = "`ll'";
   local vv = length("`zz'");
  /* dis "icit: `i' : `vv'" ; */
  */ 
  local beg = 9 - length(`"`name1'"');
                 local tval = `dif'/`ste';
                 local pval = tprob(`df',`tval');
                 local ub = `dif'-invttail(`df',`lvl')*`ste';
                 local lb = `dif'+invttail(`df',`lvl')*`ste';
				 
				 local sdif = `ste' ;
if ("`conf'"=="ts") {;
                 noi di in smcl in gr _col(`tt')  `"{yellow:{it:Population}}"' /*
                */ in gr _col(`bz0') "{c |}" in ye /*
                 */ _col(`bz1') %`wic1'.`dec1'f  `m1'   /*
                 */ _col(`bz2') %`wic2'.`dec1'f  `m2'     /*
				 */ _col(`bz3') %`wic3'.`dec1'f  `dif'     /*
				 */ _col(`bz4') %`wic4'.`dec1'f  `ste'     /*
                 */ _col(`bz5') %9.0g  `tval'   /*
                 */ _col(`bz6') %6.4f  `pval'   /*
                 */ _col(`bz7') %9.0g  `lb'  /*
                 */ _col(`bz8') %9.0g  `ub' ;
                 };
				 
				

if ("`conf'"=="lb")
                   {;
                 noi di in smcl in gr _col(`tt')  `"{yellow:{it:Population}}"'/*
                */ in gr _col(`bz0') "{c |}" in ye /*
			     */ _col(`bz1') %`wic1'.`dec1'f  `m1'   /*
                 */ _col(`bz2') %`wic2'.`dec1'f  `m2'     /*
				 */ _col(`bz3') %`wic3'.`dec1'f  `dif'     /*
				 */ _col(`bz4') %`wic4'.`dec1'f  `ste'     /*
                 */ _col(`bz5') %9.0g  `tval'   /*
                 */ _col(`bz6') %6.4f  `pval'   /*
                 */ _col(`bz7') %9.0g  `lb'  /*
                 */ _col(`bz8') "+infinity " ;
                 };

if ("`conf'"=="ub") 
                   {;
                 noi di in smcl in gr _col(`tt')  `"{yellow:{it:Population}}"' /*	
				  */ in gr _col(`bz0') "{c |}" in ye /*
				  */ _col(`bz1') %`wic1'.`dec1'f  `m1'   /*
                 */ _col(`bz2') %`wic2'.`dec1'f  `m2'     /*
				 */ _col(`bz3') %`wic3'.`dec1'f  `dif'     /*
				 */ _col(`bz4') %`wic4'.`dec1'f  `ste'     /*
                 */ _col(`bz5') %9.0g  `tval'   /*
                 */ _col(`bz6') %6.4f  `pval'   /*
                 */ _col(`bz7') "-Infinity "   /*
                 */ _col(`bz8') %9.0g  `ub' ;
                 };
     noi di in smcl in gr "{hline `beg0'}{c BT}{hline `hbl'}"  in ye;
	 
	 
 };
 
 
 if (`pop' == 2) {;
 
local nvars =rowsof(_mss_pop) ;
   local rowname: rownames _mss_pop;
   qui tokenize  `rowname' ;
   
 forvalues i=1/`nvars' {;
  local ltmp_`i' ="``i''" ;
 /* set trace on ; */
   local m1 = el(_mss_pop,`i', 1) ;
   local m2 = el(_mss_pop,`i', 3) ;
   local dif = el(_mss_pop,`i', 5) ;
   local ste = el(_mss_pop,`i', 6) ;
   


   
   /*
   local ll = int(`m1') ;
   local zz = "`ll'";
   local vv = length("`zz'");
  /* dis "icit: `i' : `vv'" ; */
  */ 
  local beg = 9 - length(`"`name1'"');
                 local tval = `dif'/`ste';
                 local pval = tprob(`df',`tval');
                 local ub = `dif'-invttail(`df',`lvl')*`ste';
                 local lb = `dif'+invttail(`df',`lvl')*`ste';
if ("`conf'"=="ts") {;
                 noi di in smcl in gr _col(`beg') `"- `ltmp_`i''"' /*
                */ in gr _col(`bz0') "{c |}" in ye /*
                 */ _col(`bz1') %`wic1'.`dec1'f  `m1'   /*
                 */ _col(`bz2') %`wic2'.`dec1'f  `m2'     /*
				 */ _col(`bz3') %`wic3'.`dec1'f  `dif'     /*
				 */ _col(`bz4') %`wic4'.`dec1'f  `ste'     /*
                 */ _col(`bz5') %9.0g  `tval'   /*
                 */ _col(`bz6') %6.4f  `pval'   /*
                 */ _col(`bz7') %9.0g  `lb'  /*
                 */ _col(`bz8') %9.0g  `ub' ;
                 };
				 
				

if ("`conf'"=="lb")
                   {;
                 noi di in smcl in gr _col(`beg') `"- `ltmp_`i''"' /*
                */ in gr _col(`bz0') "{c |}" in ye /*
			     */ _col(`bz1') %`wic1'.`dec1'f  `m1'   /*
                 */ _col(`bz2') %`wic2'.`dec1'f  `m2'     /*
				 */ _col(`bz3') %`wic3'.`dec1'f  `dif'     /*
				 */ _col(`bz4') %`wic4'.`dec1'f  `ste'     /*
                 */ _col(`bz5') %9.0g  `tval'   /*
                 */ _col(`bz6') %6.4f  `pval'   /*
                 */ _col(`bz7') %9.0g  `lb'  /*
                 */ _col(`bz8') "+infinity " ;
                 };

if ("`conf'"=="ub") 
                   {;
                  noi di in smcl in gr _col(`beg') `"- `ltmp_`i''"' /*	
				  */ in gr _col(`bz0') "{c |}" in ye /*
				  */ _col(`bz1') %`wic1'.`dec1'f  `m1'   /*
                 */ _col(`bz2') %`wic2'.`dec1'f  `m2'     /*
				 */ _col(`bz3') %`wic3'.`dec1'f  `dif'     /*
				 */ _col(`bz4') %`wic4'.`dec1'f  `ste'     /*
                 */ _col(`bz5') %9.0g  `tval'   /*
                 */ _col(`bz6') %6.4f  `pval'   /*
                 */ _col(`bz7') "-Infinity "   /*
                 */ _col(`bz8') %9.0g  `ub' ;
                 };

 };
     noi di in smcl in gr "{hline `beg0'}{c BT}{hline `hbl'}"  in ye;
 };
       

	   
if ("`test'" ~= "") {;
       local name1 = upper("D2_`index'");
       local name2 = upper("D1_`index'");

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

/*
        return scalar pvl= `pl';
        return scalar pvu= `pr';
    */    
	     di in smcl in gr "{dup 81:=}";
	    di as txt _col(2) "Statistical Inferences  "  ;
		 di in smcl in gr "{hline 9}{hline 72}";
		 
        di as txt _col(2) "- The statistic" _col(40) " = (" as res /// 
                abbrev(`"`name1'"',16) as txt ///
                " - " as res abbrev(`"`name2')"',16)  ;   
						 
                dis  _col(2) as txt  "- The estimate   (ma)       " as res _col(44) " =" %10.6f  `dif'  ; 
				dis  _col(2) as txt  "- The test value (m0)       " as res _col(44) " =" %10.6f  `test'  ; 
				dis  _col(2) as txt  "- The STE             " as res _col(44) " ="  %10.5f  `sdif'  ; 
				dis  _col(2) as txt  "- The t-student -(ma-m0)/ste- of the test" as res _col(44)" =  "%10.4f  `t' ;
			    dis  _col(2) as txt  "- The degree of freedom " as res _col(44)" =  "%10.0f  `df' ;



/* Display Ho. */

 di in smcl in gr "{hline 9}{hline 72}";
        di  as txt "  Results of the three potential tests with a significance level of `slevel'% :";
di in smcl in gr "{hline 9}{hline 72}";

    di;

/* Display Ha. */

        local tt : di %8.4f `t';
        local p1 : di %6.4f `pl';
        local p2 : di %6.4f `p';
        local p3 : di %6.4f `pr';

		        _ttest center2 " H0: est.(diff) <  `test'"  /*
        */             " H0: est.(diff) == `test'" /*
        */             " H0: est.(diff) >  `test'";

		
				        _ttest center2 " Against"  /*
        */                     " Against"  /*
        */                     " Against" ;

        
        _ttest center2 " H1: est.(diff) >= `test'"  /*
        */             " H1: est.(diff) != `test'" /*
        */             " H1: est.(diff) <= `test'";


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


   di in smcl in gr "{dup 81:=}";
 };
end;
