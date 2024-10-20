
/* TASKS 

Inputs:
for each group a martrix // Last pop matrix
group names gr1 | gr2 |...
*/



#delim ;
set more off;

cap program drop tabstr;
program define tabstr, rclass;
syntax namelist(min=1)[,   dec1(int 4)   dec2(int 4)   dec3(int 4)   dec4(int 4) dec5(int 4)   dec6(int 4) ];
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

cap program drop _dis_dasp_table_pl;
program define _dis_dasp_table_pl, rclass;
version 9.2;
syntax namelist(min=1)[,  
NAME1(string) 
M1(real 1)  
S1(real 1)  
DF1(int 1) 
LEVEL(int 95) 
CONF(string)
hgroup(varlist)
dec1(int 4)   dec2(int 4)   dec3(int 2)   dec4(int 4) dec5(int 4)   dec6(int 4) 
pop(int 1)
gro(int 1)
];


if "`conf'" == "" local conf = "ts" ;


if "`level'" == "" local level = 95 ;                 
tokenize `namelist' ;
local nmat: word count `namelist' ;
tabstr `namelist', dec1(`dec1')   dec2(`dec2')   dec3(`dec3')   dec4(`dec4') dec5(`dec5')   dec6(`dec6') ;
local wic1=r(wic1) ;
local wic2=r(wic2) ;
local wic3=r(wic3) +1 ;

if ("`hgroup'" ~= "") {;
tokenize `hgroup';
_nargs   `hgroup' ;
local wfc = 18;
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
if "`hgroup'" == "" local wfc = 11; 

local ltmp_pop `"Population"' ;
local wfc = max(`wfc', 11 );




if ("`conf'"=="") local conf="ts";
if ("`conf'"!="ts")   local lvl = (1-(100-`level')/100);
if ("`conf'"=="ts")   local lvl = (1-(100-`level')/200);
 /*local lvl = (1-(100-`level')/100);*/

/* Display table of mean, std err, etc. */

if `gro'==1 local crtit = "Population groups" ;
local beg =  `wfc'+5;
local bz0 = `beg' +1;
local bz1 = 13+ `beg' - 9 ;
local bz11 = `beg' + `wic1' - 5 ;
local bz2 = `bz1' +2 + `wic1' ;
local bz3 = `bz2'+ 2 + `wic2' ;
local bz4 = `bz3'+ 12 ;
local bz5 = `bz4'+ 12 ;
local bz6 = `bz5'+ 11 ;
local bz7 = `bz6'+ `wic3' ;

/*
forvalues i=1/4 {;
	dis `bal`i'' " : " `bz`i'' ;
};
*/
local bal1 = `bz11' +1 ;
local bal2 = `bz2' +3 ;
local bal3 = `bz3' +4 ;
local bal4 = `bz4'   ;
local bal5 = `bz5'   ;
local bal6 = `bz6'   ;
local bal7 = `bz6'+ 10   ;


local hbl = `bz7' - `beg' + `wic3'-2 ;

local beg0 = `beg' ;
tokenize `namelist' ;

		noi di in smcl in gr "{hline `beg'}{c TT}{hline `hbl'}";

                 noi di in smcl in gr "{yellow:`crtit'}   " in gr _col(`beg') " {c |}" /*
                 */ _col(`bal1') "Estimate" _col(`bal2') /*
                 */ "Std. Err." _col(`bal3') "t" _col(`bal4') /*
         */ "P>|t|" _col(`bal5') `"[`=strsubdp("`level'")'% Conf. Interval]"'  _col(`bal7')  "  P.Line" ;
		 noi di in smcl in gr "{hline `beg'}{c +}{hline `hbl'}" as smcl; 


                      local lbl = "%9.0g  `lb'";
 if ("`conf'"=="ub")  local lbl = "-infinity  ";
                local nmat1 = `nmat';
 if (`pop' == 1)  local nmat1 =  `nmat' - 1;
 

 if (`gro' == 1) {;
 forvalues g=1/`nmat1' {;
  local ngr = rowsof(``g'');
  local tt = `beg0'-length(`"`lhgroup_`g''"') ;
  noi di in smcl in gr _col(`tt')  `"{yellow:{it:`lhgroup_`g''}}"'  as result in gr _col(`bz0') "{c |}" in ye in smcl;
 forvalues i=1/`ngr' {;
 
 /* set trace on ; */
   local m1 = el(``g'',`i', 1) ;
   local s1 = el(``g'',`i', 2) ;
   local pl = el(``g'',`i', 3) ;
   

   /*
   local ll = int(`m1') ;
   local zz = "`ll'";
   local vv = length("`zz'");
  /* dis "icit: `i' : `vv'" ; */
  */ 
  local beg = 9 - length(`"`name1'"');
                 local tval = `m1'/`s1';
                 local pval = tprob(`df1',`tval');
                 local ub = `m1'-invttail(`df1',`lvl')*`s1';
                 local lb = `m1'+invttail(`df1',`lvl')*`s1';
if ("`conf'"=="ts") {;
                 noi di in smcl in gr _col(`beg') `"- `ltmp_`g'_`i''"' /*
                */ in gr _col(`bz0') "{c |}" in ye /*
                 */ _col(`bz1') %`wic1'.`dec1'f  `m1'   /*
                 */ _col(`bz2') %`wic2'.`dec2'f  `s1'     /*
                 */ _col(`bz3') %9.0g  `tval'   /*
                 */ _col(`bz4') %6.4f  `pval'   /*
                 */ _col(`bz5')  %`wic1'.`dec1'f  `lb'  /*
                 */ _col(`bz6')  %`wic1'.`dec1'f   `ub' /*
				 */ _col(`bz7')   %`wic3'.`dec3'f `pl' ;
                 };

if ("`conf'"=="lb")
                   {;
                 noi di in smcl in gr _col(`beg') `"- `ltmp_`g'_`i''"' /*
                */ in gr _col(`bz0') "{c |}" in ye /*
                 */ _col(`bz1') %`wic1'.`dec1'f  `m1'   /*
                 */ _col(`bz2') %`wic2'.`dec2'f  `s1'     /*
                 */ _col(`bz3') %8.0g  `tval'   /*
                 */ _col(`bz4') %6.4f  `pval'   /*
                 */ _col(`bz5') %`wic1'.`dec1'f  `lb'  /*
                 */ _col(`bz6') "+infinity " /*
				 */ _col(`bz7')   %`wic3'.`dec3'f  `pl' ;
                 };

if ("`conf'"=="ub") 
                   {;
                  noi di in smcl in gr _col(`beg') `"- `ltmp_`g'_`i''"' /*
                */ in gr _col(`bz0') "{c |}" in ye /*
                 */ _col(`bz1') %`wic1'.`dec1'f  `m1'   /*
                 */ _col(`bz2') %`wic2'.`dec2'f  `s1'     /*
                 */ _col(`bz3') %8.0g  `tval'   /*
                 */ _col(`bz4') %6.4f  `pval'   /*
                 */ _col(`bz5') "-Infinity "  /*
                 */ _col(`bz6')  %`wic1'.`dec1'f   `ub' /*
				 */ _col(`bz7')   %`wic3'.`dec3'f  `pl' ;
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
		local m1 = el(``nmat'',1, 1) ;
        local s1 = el(``nmat'',1, 2) ;
		local pl = el(``nmat'',1, 3) ;

  local beg = 9 - length(`"`name1'"');
                 local tval = `m1'/`s1';
                 local pval = tprob(`df1',`tval');
                 local ub = `m1'-invttail(`df1',`lvl')*`s1';
                 local lb = `m1'+invttail(`df1',`lvl')*`s1';
if ("`conf'"=="ts") {;
                 noi di in smcl in gr _col(`tt')  `"{yellow:{it:Population}}"'  as result in gr _col(`bz0') "{c |}"  in ye in smcl /*
                 */ _col(`bz1') %`wic1'.`dec1'f  `m1'   /*
                 */ _col(`bz2') %`wic2'.`dec2'f  `s1'     /*
                 */ _col(`bz3') %9.0g  `tval'   /*
                 */ _col(`bz4') %6.4f  `pval'   /*
                 */ _col(`bz5')  %`wic1'.`dec1'f   `lb'  /*
                 */ _col(`bz6')  %`wic1'.`dec1'f   `ub' /*
				 */ _col(`bz7')   %`wic3'.`dec3'f  `pl' ;
                 };

if ("`conf'"=="lb")
                   {;
                 noi di in smcl in gr _col(`tt')  `"{yellow:{it:Population}}"'  as result in gr _col(`bz0') "{c |}"  in ye in smcl /*
                 */ _col(`bz1') %`wic1'.`dec1'f  `m1'   /*
                 */ _col(`bz2') %`wic2'.`dec2'f  `s1'     /*
                 */ _col(`bz3') %8.0g  `tval'   /*
                 */ _col(`bz4') %6.4f  `pval'   /*
                 */ _col(`bz5')  %`wic1'.`dec1'f   `lb'  /*
                 */ _col(`bz6') "+infinity " /*
				 */ _col(`bz7')   %`wic3'.`dec3'f `pl' ;
                 };

if ("`conf'"=="ub") 
                   {;
                 noi di in smcl in gr _col(`tt')  `"{yellow:{it:Population}}"'  as result in gr _col(`bz0') "{c |}"  in ye in smcl /*
                 */ _col(`bz1') %`wic1'.`dec1'f  `m1'   /*
                 */ _col(`bz2') %`wic2'.`dec2'f  `s1'     /*
                 */ _col(`bz3') %8.0g  `tval'   /*
                 */ _col(`bz4') %6.4f  `pval'   /*
                 */ _col(`bz5') "-Infinity "  /*
                 */ _col(`bz6')  %`wic1'.`dec1'f   `ub' /*
				 */ _col(`bz7')   %`wic3'.`dec3'f  `pl' ;
                 };
		
     noi di in smcl in gr "{hline `beg0'}{c BT}{hline `hbl'}"  in ye;
 };
 
 if (`pop' == 2) {;
local nvars =rowsof(_ms_pop) ;
  local rowname: rownames _ms_pop;
  qui tokenize  `rowname' ;
 forvalues i=1/`nvars' {;
  local ltmp_`i' ="``i''" ;
  local tt = `beg0'-length(`"`ltmp_`i''"') ;
	 if `gro' == 1   noi di in smcl in gr "{hline `beg'}{c +}{hline `hbl'}";
		local m1 = el(_ms_pop,`i', 1) ;
        local s1 = el(_ms_pop,`i', 2) ;
	    local pl = el(_ms_pop,`i', 3) ;

  local beg = 9 - length(`"`name1'"');
                 local tval = `m1'/`s1';
                 local pval = tprob(`df1',`tval');
                 local ub = `m1'-invttail(`df1',`lvl')*`s1';
                 local lb = `m1'+invttail(`df1',`lvl')*`s1';
if ("`conf'"=="ts") {;
                 noi di in smcl in gr _col(`tt')  `"{yellow:{it:`ltmp_`i''}}"'  as result in gr _col(`bz0') "{c |}"  in ye in smcl /*
                 */ _col(`bz1') %`wic1'.`dec1'f  `m1'   /*
                 */ _col(`bz2') %`wic2'.`dec2'f  `s1'     /*
                 */ _col(`bz3') %9.0g  `tval'   /*
                 */ _col(`bz4') %6.4f  `pval'   /*
                 */ _col(`bz5')  %`wic1'.`dec1'f   `lb'  /*
                 */ _col(`bz6')  %`wic1'.`dec1'f   `ub' /*
				 */ _col(`bz7')  %`wic3'.`dec3'f `pl' ;
                 };

if ("`conf'"=="lb")
                   {;
                 noi di in smcl in gr _col(`tt')  `"{yellow:{it:`ltmp_`i''}}"'  as result in gr _col(`bz0') "{c |}"  in ye in smcl /*
                 */ _col(`bz1') %`wic1'.`dec1'f  `m1'   /*
                 */ _col(`bz2') %`wic2'.`dec2'f  `s1'     /*
                 */ _col(`bz3') %8.0g  `tval'   /*
                 */ _col(`bz4') %6.4f  `pval'   /*
                 */ _col(`bz5')  %`wic1'.`dec1'f   `lb'  /*
                 */ _col(`bz6') "+infinity " /*
				 */ _col(`bz7')  %`wic3'.`dec3'f  `pl' ;
                 };

if ("`conf'"=="ub") 
                   {;
                 noi di in smcl in gr _col(`tt')  `"{yellow:{it:`ltmp_`i''}}"'  as result in gr _col(`bz0') "{c |}"  in ye in smcl /*
                 */ _col(`bz1') %`wic1'.`dec1'f  `m1'   /*
                 */ _col(`bz2') %`wic2'.`dec2'f  `s1'     /*
                 */ _col(`bz3') %8.0g  `tval'   /*
                 */ _col(`bz4') %6.4f  `pval'   /*
                 */ _col(`bz5') "-Infinity "  /*
                 */ _col(`bz6')  %`wic1'.`dec1'f   `ub' /*
				 */ _col(`bz7')   %`wic3'.`dec3'f  `pl' ;
                 };
		

 };
     noi di in smcl in gr "{hline `beg0'}{c BT}{hline `hbl'}"  in ye;
 };
       
       

end;


