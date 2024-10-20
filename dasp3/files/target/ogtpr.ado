/*************************************************************************/
/*Optimal Group Trageting & Poverty Reduction                            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  02-2017              */
/* Universite Laval , Quebec, Canada                                     */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  :   OGTPR                                                     */
/*************************************************************************/

set more off

#delim ;

capture program drop tgpr22;
program define tgpr22, rclass;
version 9.2;
args www yyy al type pline min max gr preci;
local maxa = `max' ;
forvalues i=1/$indica {;
local max = `maxa' ;
preserve;
qui sum `www' ; 
local s1=r(sum);
qui sum `www' if (`gr'==gn1[`i']);  
local s2=r(sum);
local phig= `s2'/`s1' ;
if ("`gr'" ~="") qui keep if (`gr'==gn1[`i']);
cap drop if `yyy'>=.;
cap drop if `www'>=.;
tempvar ww wy ra rp ftgpr gap;
gen double  `gap' = 0;
qui replace `gap' = ((`pline'-`yyy')) if (`pline'>`yyy');
qui sum `gap';
local  mgap`ng' = `r(max)' ;
global mgap`ng' = `r(max)' ;
gen double `ftgpr'=0;
gen double `ra'=0;
local max = min(`max'/`phig' , `mgap`ng'');
local pas = (`max'-`min')/(`preci');
local tmp =  `preci' ;
if (_N<`tmp') qui cap set obs `tmp';
forvalues j=1/`tmp' {;
qui replace `ra'=`min'+(`j'-1)*`pas' in `j' ;
cap drop `rp';
tempvar rp;
gen `rp' = 0;
if (`al'== 0) qui replace `rp' = (`pline'>`yyy')*((`yyy'+`ra'[`j']/`phig')>`pline') ;
if (`al'== 1) qui replace `rp' = min(`ra'[`j']/`phig', (`pline'-`yyy'))/`pline' if (`pline'>`yyy');
if (`al' != 0 &  `al' != 1 ) qui replace `rp' = ((`pline'-`yyy')/`pline')^`al' -((`pline'-min(`yyy'+`ra'[`j']/`phig',`pline'))/`pline')^`al'   if (`pline'>`yyy');
qui sum `rp' [aweight= `www'] ;
qui replace `ftgpr'= `phig'*`r(mean)'  in `j' ;
};
qui replace `ftgpr' =  `ftgpr'/(`ra') in 2/`tmp';
qui replace `ftgpr' =  0 in 1;
qui keep in 1/`tmp'; 
gsort - `ftgpr'     `ra'  ; 
local gtrans`i' = `ra'[1];
local dcp`i'    = `ftgpr'[1];
local max`i'  = `max' ;
restore;
};



local v = 1;
local mv = `v';
local   maxdcp = `dcp1' ;
local   gtrans = `gtrans1'  ;

forvalues v=2/$indica       {;
if ( `dcp`v'' > `maxdcp' )  {;
local mv = `v';
local  maxdcp = `dcp`mv'' ;
local  gtrans = `gtrans`mv'' ;
};
};

return scalar gtrans = `gtrans' ; 
return scalar ogr = `mv' ; 
end;





/***************************************/
/*  perfect-reduc                      */
/***************************************/
capture program drop perfectred;
program define perfectred, rclass;
syntax varlist(min=1 max=1) [, FWeight(string)  PLINE(string) ALpha(real 0) TRANS(real 100000)];

tokenize `varlist';
tempvar fw ga hy;
gen `hy' = `1';
gen `fw'=   1;
if ("`fweight'"~="")    qui replace `fw'=`fw'*`fweight';
qui sum `fw'; local suma = `r(sum)' ;

cap drop ptrans;
gen ptrans=0;
 
tempvar     ga  ga1 ga2    ;
gen `ga1' = 0;
gen `ga2' = 0;
gen double  `ga' = 0       if `pline'<=`hy'  ;
qui replace `ga' = ((`pline'-`hy')) if (`pline'>`hy');
*set trace on ;


*keep if     `ga'!=0  ;
tempvar npoor tvar;
gen `tvar' = 0 ;
gen `npoor' = (`pline'>`hy' );
if (`alpha' == 0)  gsort    `ga'   `npoor'  ;
if (`alpha' >= 1)  gsort   -`ga'   `npoor'  ;
local pos = 1;
local rem= `trans'*`suma';
while `rem' > 0  {;
qui replace `tvar' = min(`ga'[`pos'], `rem'/`fw'[`pos']) in `pos';
local rem = `rem'-`tvar'[`pos']*`fw'[`pos'] ;
local pos =`pos' + 1 ; 
};
cap drop ptrans;
gen ptrans = `tvar';

tempvar thy;
gen `thy' = `hy'+ `tvar' ;
 qui replace `ga1' = ((`pline'-`hy')/`pline')^`alpha'  if  (`pline'>`hy');
 qui replace `ga2' = ((`pline'-`thy')/`pline')^`alpha' if  (`pline'>`thy');
 qui sum `ga1' [aw=`fw'];  local rs1 = r(mean); 
 qui sum `ga2' [aw=`fw'];  local rs2 = r(mean); 
 return scalar pr = `rs2' - `rs1'; 



end;



/***************************************/
/* pfgt                                 */
/***************************************/
capture program drop pfgt;
program define pfgt, rclass;
syntax varlist(min=1 max=1) [, FWeight(string) HGroup(string) GNumber(integer 1)  PLINE(string) ALpha(real 0) type(string)];
tokenize `varlist';
tempvar fw ga hy;
gen `hy' = `1';
gen `fw'=1;
if ("`fweight'"~="")    qui replace `fw'=`fw'*`fweight';
if ("`hgroup'" ~="")    qui replace `fw'=`fw'*(`hgroup'==`gnumber');
gen `ga' = 0;
if (`alpha'==0) qui replace `ga' = (`pline'>`hy');
if (`alpha'~=0) qui replace `ga' = ((`pline'-`hy'))^`alpha' if (`pline'>`hy');
qui sum `ga' [aweight= `fw'];
local pfgt = r(mean);
if ("`type'" == "nor" & `alpha' !=0) local pfgt = `pfgt' /(`pline'^`alpha');
return scalar pfgt = `pfgt';
end;




capture program drop ogtpr;
program define ogtpr, rclass;
version 9.2;
syntax varlist(min=1)[,  HSize(varname) HGroup(varname) ALpha(real 0)  PLine(real 100000)  TRANS(real 100000)  PART(int 400) DEC(int 3) ered(real 0)];


if ("`hgroup'"!="") {;
preserve;
capture {;
local lvgroup:value label `hgroup';
if ("`lvgroup'"!="") {;
uselabel `lvgroup' , replace;
qui count;
forvalues i=1/`r(N)' {;
local tem=value[`i'];
local grlab`tem' = label[`i'];
};
};
};
restore;

qui tabulate `hgroup', matrow(gn);
cap drop gn1;
svmat int gn;
global indica=r(r);
tokenize `varlist';
};
if ("`hgroup'"=="") {;
tokenize `varlist';
_nargs    `varlist';

};

local hweight=""; 
cap qui svy: total `1'; 

cap if (`e(wvar)') local hweight=`"`e(wvar)'"';
if ("`e(wvar)'"~="`hweight'") dis as txt in blue " Warning: sampling weight is initialized but not found.";
timer clear 1;
timer on 1;
qui count;
local nobser = `r(N)' ;
tempvar Variable  EST1 EST2 EST3 EST4;
qui gen `Variable'="";
qui gen `EST1'=0;
qui gen `EST2'=0;
qui gen `EST3'=0;
qui gen `EST4'=0;


tempvar fw;
local _cory  = "";
local label = "";
quietly{;
gen `fw'=1;
if ("`hsize'"  ~="")      replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")      replace `fw'=`fw'*`hweight';
};
local ll=20;
qui count;
qui sum `1';
if ("`min'"  =="")      local min =`r(min)';
if ("`max'"  =="")      local max =`r(max)';
if ("`type'"  =="")     local type ="yes";



forvalues k = 1/$indica {;
if ("`hgroup'"!="") {;
local kk = gn1[`k'];
local k1 = gn1[1];
local label`f'  : label (`hgroup') `kk';
local labelg1   : label (`hgroup') `k1';
if ( "`label1'" == "")   local labelg1    = "Group: `k1'";
if ( "`label`f''" == "") local label`f'   = "Group: `kk'";
local ll=max(`ll',length("`label`f''"));
qui replace `Variable' = "`label`f''" in `k';
pfgt `1', fweight(`fw') pline(`pline') alpha(`alpha') hgroup(`hgroup') gnumber(`kk') type(nor); 
qui replace `EST1'      = `r(pfgt)' in `k';
};
};




qui sum `fw'; 
local s2=r(sum);

forvalues k = 1/$indica {;
local f=`k';
local label`f'  =  "``k''";
qui sum `fw' if `hgroup' ==  gn1[`f']; 
local s1_`k' =r(sum);
local phi_`k' = `s1_`k'' / `s2' ;
qui replace `EST2'      = `phi_`k''*100 in `k';
};



tempvar ga phg opti;

forvalues k = 1/$indica {;
local gr_`k' = gn1[`k'];
local  cost_`k' =0;
local  ocost_`k' =0;
local  comp_`k' =1;
};






tgpr22 `fw' `1' `alpha' `type'  `pline' 0 `trans' `hgroup' `part';


local tmp = `r(ogr)' ;
local mv = `tmp'; 

local dcost = `trans'; 
local costag = `r(gtrans)' ;

local  cost_`mv' = min(`costag', `dcost');
local  ocost_`mv' = `cost_`mv'' ; 
local tcost= 0;
forvalues z=1/$indica {;
local tcost=  `tcost'+(`cost_`z''); 
};

local dcost = `trans'-`tcost';


local h = 1 ;

qui sum `fw'; 
local s2=r(sum);

forvalues k = 1/$indica {;
local f=`k';
local label`f'  =  "``k''";
qui sum `fw' if `hgroup' ==  gn1[`f']; 
local s1_`k' =r(sum);
local phi_`k' = `s1_`k'' / `s2' ;
qui replace `EST2'      = `phi_`k''*100 in `k';
};

dis "Sequence ..." 1  ":   Remaining p.c. budget " %10.3f `dcost'  " over " %10.3f  `trans' ;

local loop = 1;
while `dcost' > 0  & `loop' == 1 {;

tempvar ytr;
qui gen `ytr' = `1' ;
forvalues g=1/$indica {;
local tmp = gn1[`g'] ;
qui replace `ytr' = `ytr' +  (`cost_`g'' / `phi_`g'') * (`hgroup'==`tmp') ;
};

                   local npart = `part';
if (`alpha' != 0) local npart = max(2,int((`dcost'/`trans')*`part'));
tgpr22 `fw' `ytr' `alpha' `type'  `pline' 0 `dcost' `hgroup' `npart' ;

local tmp = `r(ogr)' ;
local mv = `tmp'; 
local omv=`mv' ;
local costag = `r(gtrans)' ;
if `r(gtrans)' == 0 {;
local loop = 0 ;
};

local  cost_`mv' =  `cost_`mv'' + min(`costag' , `dcost'   ); 

local tcost= 0;
forvalues z=1/$indica {;
local tcost=  `tcost'+(`cost_`z''); 
};

local dcost = `trans'-`tcost';

if `dcost' <=`trans'/10000 {;
local cost_`mv' = `cost_`mv'' +`dcost';
local dcost = 0;
};

if  ( `cost_`mv''  == $mgap`mv' ) local comp_`mv' = 0;


local h = `h'+1; 


 
dis "Sequence ..." `h'  ":   Remaining p.c. budget " %10.3f `dcost'  " over " %10.3f  `trans' ;

};
cap drop `1'_tr;
qui gen `1'_tr = `1';
forvalues v=1/$indica {;
local gk = gn1[`v'] ;
qui replace `EST3'      = `cost_`v''/`phi_`v'' in `v' ;
qui replace `EST4'      = `cost_`v'' in `v' ;
qui replace `1'_tr = `1'_tr + `cost_`v''/`phi_`v''*(`hgroup'==`gk'); 
};

timer off 1;
qui timer list 1;
local ptime = `r(t1)';
tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width |`ll'|16 16 16 16|;
	
	.`table'.strcolor . . yellow .  .;
	.`table'.numcolor yellow yellow . yellow  yellow;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f  %16.`dec'f;
	
	di _n as text "{col 4} Optimal Targeting of Groups for Poverty Reduction";
     di as text  "{col 5}Number of observations      :{col 30}" %-10.0f `nobser'  ;
	 di as text  "{col 5}Time of computation       : {col 30}" %-10.2f `ptime'  "second(s)";
	   di as text     "{col 5}Per capita transfer       :  " %10.2f `trans';
	   di as text     "{col 5}Used per capita transfer  :  " %10.2f `trans'-`dcost';
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";
                            di  as text "{col 5}Parameter alpha : "  %5.2f `alpha'       ;
    
	.`table'.sep, top;
	.`table'.titles "Group  " "Fgt Index"  "Population "  "  Optimal G.P.C. "  " Optimal P.C."  ;
	.`table'.titles "       " "         "  "   Share   "   "Transfer"   "Transfer"  ;
	.`table'.sep, mid;
	
	local nalt = "ddd";
	forvalues i=1/$indica{;
            .`table'.numcolor white yellow yellow yellow yellow  ;
		  .`table'.row `Variable'[`i'] `EST1'[`i']  `EST2'[`i'] `EST3'[`i'] `EST4'[`i']  ;    
		  };
  .`table'.sep,bot;

*set trace on ;


tempvar trs ;
gen `trs'= 0;
forvalues v=1/$indica {;
local kk = gn1[`v'];
qui replace `trs' = `cost_`v''/`phi_`v'' if   (`hgroup'==`kk');
};

if (`ered' == 1) {;
            capture findfile difgt.ado ;
            local filelist `"`r(fn)'"';
			if "`filelist'"=="" {;
            di in r "The DASP difgt.ado not found (to estimate the change in poverty): Install DASP package from: https://www.dasp.cstip.ulaval.ca";
            exit 198;

			};


cap drop `1'_tr;
qui gen `1'_tr  = `1' + `trs' ;
di _n as text "{col 1} Total Poverty Reduction";
difgt  `1' `1'_tr , pline1(`pline')  pline2(`pline') hsize1(`hsize') hsize2(`hsize') alpha(`alpha') ;
cap drop matrix aa;
matrix aa=e(di);
//cap drop `1'_tr;

qui perfectred `1' , fweight(`fw')  pline(`pline') alpha(`alpha') trans(`trans');
if `alpha'==0 | `alpha'>=1 {;
dis _n _col(5) "- Redution with imperfect targeting (in %)      :" _col(52) %9.3f (el(aa,1,1)*100)  ;
return scalar r1 = (el(aa,1,1)*100);
return scalar r2 = -(r(pr)*100);
return scalar r3 = `ptime' / 60;
dis _col(5)    "- Redution with  perfect targeting (in %)      :" _col(52) %9.3f (r(pr)*100)  ;
dis _col(5)    "- The quality of the targeting indicator (in %):" _col(52) %9.3f abs((el(aa,1,1)/r(pr))*100)  ;
};
}; 

cap drop gn1;

*set trace on ;
*set tracedepth 1;
tempvar poor rtran;

gen `poor'   = (`1'<`pline');
gen  `rtran' = `trs'>0;

lab var `poor' "Poor";
lab var `rtran' "  Targeted";
cap label drop yn;
lab define yn 0 "No" 1 "Yes" ;
lab val `poor'  yn;
lab val `rtran' yn;
di _n as text "{col 1} Targeting by transfers and poverty status";
tab `poor' `rtran' [aw=`fw'], cell nofreq ;


end;



