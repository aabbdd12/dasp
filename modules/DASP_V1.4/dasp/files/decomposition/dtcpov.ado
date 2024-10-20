
/********************************************/
/* By: Araar Abdelkrim : aabd@ecn.ulaval.ca */
/********************************************/



/***********************************************************************/
/* This routine serves to compute the number of arguments in varlist    */
/* this also corresponds to the number of periods                       */


capture program drop nargs
program define nargs, rclass
syntax varlist(min=0)
quietly {
tokenize `varlist'
local k = 1
mac shift
while "``k''" ~= "" { 
local k = `k'+1 
}
}
global nper=`k' // Number of periods
qui count
global obsa=`r(N)' // Number of observations
return scalar narg = `k'
end




/**********************************************************************************/
/* Computing average household living standards for these retained periods     */


capture program drop mhor
program define mhor, rclass

quietly {
syntax varlist(min=0)
nargs `varlist'
local n = `r(narg)' // number of periods
tokenize `varlist'
capture drop mh
qui gen mh = 0

forvalues i = 1/`n' {
			    qui replace mh = mh + ``i''
                    }

qui replace mh=mh/`n'
return local varm mh
}
end



/*****************************************/
/* This routine serves to compute the gap */


capture program drop gap
program define gap, rclass
args stl pline

quietly {
capture drop gap
qui gen gap=0
qui replace gap = (`pline'-`stl')/`pline' if (`pline'>`stl')
return local varg gap
}

end

/****************************************************/
/* This routine serve to compute the FGT index      */


capture program drop fgtaz
program define fgtaz, rclass
args we stl pline alpha  // Arguments are respectively : Final weight / Standard of living (income) / alpha / poverty line
quietly {
tempvar ga
qui gen `ga' = 0
if (`alpha'==0) qui replace `ga' = (`pline'>`stl')
if (`alpha'~=0) qui replace `ga' = ((`pline'-`stl')/`pline')^`alpha' if (`pline'>`stl')
sum `ga' [aweight= `we']
local fgt = r(mean)
return local fgt `fgt'
}
end



/************************************************************************/
/* This routine serves to draw randomly an integer in [1, $nrep]        */
/* where $nrep is the number of periods                                 */       

capture program drop alean
program define alean, rclass
local aa=uniform()
local aa=int(`aa'*$nper+1)
local pos=`aa'
return local pos `aa'
end



set more off
/*******************************************************************/
/* Performing the bootstrap approach to estimate the bias          */
/* The bias is linked to the small number of periods used          */
/* to compute chronic poverty.                                  */
/* See the theoretical part                                        */                                          

capture program drop biasjrv
program define biasjrv
syntax varlist(min=1) [, PLine(real 1) ALpha(real 1) NRep (int 100)]
tokenize `varlist'
capture drop sgap
qui gen sgap=0


tokenize `varlist'
local bmui  = 0
local bsgi  = 0
local k=1
forvalues i = 1/$obsa  {
quietly{
forvalues h = 1/`nrep' {
local mui = 0
local sgi = 0
forvalues j = 1/$nper {
                      local aa=uniform()
			    local aa=int(`aa'*$nper+1)
		          local pos=`aa'
		          local mui =`mui'+``pos''[`i']  
                      }
 local mui =`mui'/$nper
 local sgi = (`pline'>`mui')*((`pline' - `mui')/`pline')^`alpha'
 local bsgi = `bsgi'+`sgi'
 }
 local bsgi=`bsgi'/`nrep'
 qui replace sgap = `bsgi' in `i'
}

local j = round(`i'*100/$obsa)
if (`j'==`k') {
if (`j'==1) dis "ESTIMATION IN PROGRESS"
if (`j'!=101)  dis "." ,  _continue
if (`j'/10==round(`j'/10)) dis " "  %4.0f `j' " %"
local k=`k'+1
if (`j'==100) dis "END"
}
}
end







/************************************************************************/
/*      Decomposing total poverty to transient & chronic components     */
/*              Jalan & Ravallion Approach 1998			      	*/
/************************************************************************/

set more off
capture program drop dtcrj 
program define dtcrj, rclass
version 9.2
syntax varlist(min=1) [, STrata(string) PSU(string) HSize(varname) PLine(real -1) ALpha(real -1) CBIas(string) NRep (int 100) Cens(string) DEC(int 3) ] 
preserve
tokenize `varlist'





qui svydes 
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized)
local hweight=""
cap qui svy: total `1'
local hweight=`"`e(wvar)'"'
cap ereturn clear
tempvar pw si
qui gen `pw'=1 
if ("`hweight'"!="") qui replace `pw' = `hweight'

qui gen `si'=1
if ("`hsize'"!="") qui replace `si' = `hsize'


nargs `varlist' /* nombre de période */
local np = `r(narg)'
if ("`cens'"=="yes") {
forvalues i = 1/`np'  {
			      qui replace ``i'' = min(``i'',`pline')

              	      }
                     }


if ("`pline'"=="-1") {
disp as error " You need to specify pline()"
exit
}
if ("`alpha'"=="-1") {
disp as error " You need to specify alpha()
exit
}





/*********************************************************/
/* Computing average household income : msdl 	 */


quietly{
tempvar msdl
mhor `varlist'
qui gen  `msdl' = `r(varm)'
}



/**********************************************************/
/* Computing total poverty  : tfgt                    */


quietly{
local tfgt = 0
nargs `varlist' /* nombre de période */
local np = `r(narg)'
tempvar ga tga mtga si nsi var bias
qui gen `ga' = 0
qui gen `tga'= 0
qui gen `var'= 0
qui gen `bias'=0


qui gen `si' = 1.0
if ("`hsize'" != "") qui replace `si' =  `si'*`hsize'
forvalues i = 1/`np' {
			       qui replace `ga' = 0
		               if (`alpha'==0) qui replace `ga' = `si'*(`pline'> ``i'' )
                           if (`alpha'~=0) qui replace `ga' = `si'*((`pline'-``i'')/`pline')^`alpha' if (`pline'>``i'')
			       qui replace `tga' = `tga' + `ga' 
			       qui replace `var' = `var' + ((``i''-`msdl')/`pline')^2 
              	    }

}

qui gen `nsi' = `si'*`np'
qui svy: ratio `tga'/`nsi'

matrix cc= e(b)
local tfgt = el(cc,1,1)
matrix cc= e(V)
local stfgt = (el(cc,1,1))^0.5



/*********************************************************/
/* Computing chronic poverty :cftg                   */

tempvar cga
qui gen `cga' = 0
if (`alpha'==0) qui replace `cga' = `si'*(`pline'> `msdl' )
if (`alpha'~=0) qui replace `cga' = `si'*((`pline'-`msdl')/`pline')^`alpha' if (`pline'>`msdl')

qui svy: ratio `cga'/`si'
matrix cc= e(b)
local cfgt = el(cc,1,1)
matrix cc= e(V)
local scfgt = (el(cc,1,1))^0.5



/*********************************************************/
/* Computing transient poverty :cftg                   */

qui replace `tga'=`tga'-`np'*`cga'
qui svy: ratio `tga'/`nsi'
matrix cc= e(b)
local trfgt = el(cc,1,1)
matrix cc= e(V)
local strfgt = (el(cc,1,1))^0.5

//====

/*********************************************************/
/* Computing the bias if this option is selected         */


if ("`cbias'"=="anal") {
qui replace `var' = `var'/(`np'-1)
qui replace `bias' = `si'*(`alpha'*(1-`alpha'))/(2*`np')*`var'*((`pline'-`msdl')/`pline')^(`alpha'-2)  if (`pline'>`msdl')
qui svy: ratio `bias'/`si'
matrix cc= e(b)
local bia = el(cc,1,1)
matrix cc= e(V)
local sbias  = (el(cc,1,1))^0.5
local bcfgt  = max(0,`cfgt'+`bia')
local btrfgt = max(0,`tfgt'-`bcfgt')
qui replace `tga' =  max(0,`tga'-`np'*`bias')
qui replace `ga'  = max(0,`ga'+`bias')
qui svy: ratio `tga'/`nsi'
qui matrix cc= e(V)
local sbtrfgt = (el(cc,1,1))^0.5
qui svy: ratio `ga'/`si'
qui matrix cc= e(V)
local sbcfgt = (el(cc,1,1))^0.5
}


if ("`cbias'"=="boot") {

biasjrv `varlist', pl(`pline') al(`alpha') nr(`nrep')

quietly{
tempvar finw bia
qui gen `finw' = `si'*`pw'
sum sgap [aweight=`finw']
local bootcfgt=`r(mean)'
local bia   = `bootcfgt'-`cfgt'
local sbias = .
local bcfgt  = `cfgt'-`bia'
local sbcfgt  = .
local btrfgt = `tfgt'-`bcfgt'
local sbtrfgt = .




}
/*********************************************************/

}



/*********************************************************/
/* Displaying all results                               */

    
   
    


#delim ;
      disp in white "     "_col(5)"- Decomposition of total poverty into transient and chronic components.     ";
      disp in white "     "_col(5)"- Jalan and Ravallion approach (1998).      ";
if ("`cbias'"=="") {;
 tempname table;
	.`table'  = ._tab.new, col(3);
	.`table'.width  16|16 16  ;
	.`table'.strcolor . . yellow  ;
	.`table'.numcolor yellow yellow . ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f ;
      disp in white " Poverty line      :" _col(25) in yellow %8.2f `pline';       				 
      disp in white " alpha             :" _col(25) in yellow %8.2f `alpha' ;
      disp in white " # of observations :" _col(25) in yellow %8.0f $obsa;
      disp in white " # of periods      :" _col(25) in yellow %8.0f `np';
      .`table'.sep, top;
	.`table'.titles "Components  " "Estimate"  "STD "  ;
      .`table'.sep, mid;
      .`table'.row "Transient" `trfgt'  `strfgt'; 
      .`table'.row "Chronic  " `cfgt'  `scfgt';
  .`table'.sep,mid;
  .`table'.numcolor white white   white;
  .`table'.row "Total    " `tfgt'  `stfgt';
  .`table'.sep,bot;

};

if ("`cbias'"=="anal" | "`cbias'"=="boot") {;
 tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width  16|16 16|16 16 ;
	.`table'.strcolor . . yellow yellow yellow  ;
	.`table'.numcolor yellow yellow . . . ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f  %16.`dec'f ;
      disp in white " Poverty line      :" _col(25) in yellow %8.2f `pline';       				 
      disp in white " alpha             :" _col(25) in yellow %8.2f `alpha' ;
      disp in white " # of observations :" _col(25) in yellow %8.0f $obsa;
      disp in white " # of periods      :" _col(25) in yellow %8.0f `np';
      .`table'.sep, top;
      .`table'.reset, col(3) ;
      .`table'.width  16|32|32 ;
      .`table'.titles "Bias  " "With bias correction  "   "Without bias correction  "   ;
      .`table'.sep,mid;
	 .`table'.reset, col(5); 
      .`table'.width  16|16 16|16 16 ;
	.`table'.strcolor . . yellow yellow yellow  ;
	.`table'.numcolor yellow yellow . . . ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f  %16.`dec'f ;
	.`table'.titles "Components  " "Estimate"  "STD " "Estimate"  "STD "  ;
      .`table'.sep, mid;
      .`table'.row "Bias" `bia'  `sbias' "---"  "---"; 
      .`table'.row "Transient" `btrfgt' `sbtrfgt' `trfgt'  `strfgt'; 
      .`table'.row "Chronic  " `bcfgt'  `sbcfgt' `cfgt'  `scfgt';
  .`table'.sep,mid;
  .`table'.numcolor white white   white white   white;
  .`table'.row "Total    " `tfgt'  `stfgt'   `tfgt'  `stfgt';
  .`table'.sep,bot;

};


#delim cr

/* results */
return scalar tfgt  = `tfgt'
return scalar cfgt  = `cfgt'
return scalar trfgt = `trfgt'
if ("`cbias'" != "") {
return scalar bias   = `bias'
return scalar btrfgt = `btrfgt'
return scalar bcfgt  = `bcfgt'
}

cap drop mh 
cap drop sgap
restore
end





/*******************************************************************/
/* Performing the bootstrap approach to estimate the bias          */
/* The bias if linked to the small number of periods used          */
/* to compute the chronic poverty.                                  */
/* See the theoretical part                                        */                                          
set more off
capture program drop biasda
program define biasda
syntax varlist(min=1) [, PLine(real 1) ALpha(real 1) NRep (int 100)]
tokenize `varlist'
capture drop sgap
qui gen sgap=0


tokenize `varlist'
local k=1

forvalues i = 1/$obsa  {
quietly{
local bsgi  = 0
forvalues h = 1/`nrep' {
local s1 = 0
forvalues j = 1/$nper  {
                      local aa=uniform()
			    local aa=int(`aa'*$nper+1)
		          local pos=`aa'
		          if(`pline'> ``pos''[`i'])  local s1 =`s1'+((`pline'-``pos''[`i'])/`pline')^`alpha'  
			    }
 
 local s1 =(`s1'/$nper)^(1/`alpha')
 local bsgi = `bsgi'+`s1'
 }
 local bsgi=`bsgi'/`nrep'
 qui replace sgap = `bsgi' in `i'

}


local j = round(`i'*100/$obsa)
if (`j'==`k') {
if (`j'==1) dis "ESTIMATION IN PROGRESS"
if (`j'!=101)  dis "." ,  _continue
if (`j'/10==round(`j'/10)) dis " "  %4.0f `j' " %"
local k=`k'+1
if (`j'==100) dis "END"
}

}

end



/************************************************************************/
/*      Decomposing total poverty into transient & chronic components     */
/*              DAJ Approach 2005			      	            */
/************************************************************************/

set more off
capture program drop dtcda 
program define dtcda, rclass
version 9.2
syntax varlist(min=1) [,  HSize(varname) PLine(real -1) ALpha(real -1) CBIas(string) NRep (int 100) Cens(string) DEC(int 3)] 
preserve
quietly{
tokenize `varlist'
tempvar si

cap svy: total `1'
if ( "`r(settings)'"==", clear") svyset _n, vce(linearized)

nargs `varlist' /* nombre de période */
local np = `r(narg)'
if ("`cens'"=="yes") {
forvalues i = 1/`np'  {
			      qui replace ``i'' = min(``i'',`pline')
              	     }
                     }


if ("`pline'"=="-1") {
disp as error " You need to specify pline()"
exit
}
if ("`alpha'"=="-1" | `alpha'<0)  {
disp as error " You need to specify alpha() greater than -1"
exit
}


}


/*********************************************************/
/* Computing average household income : msdl 	   */


quietly{
tempvar msdl
mhor `varlist'
qui gen  `msdl' = `r(varm)'
}



/**********************************************************/
/* Computing total poverty  : tfgt                    */

quietly{
local tfgt = 0
nargs `varlist' /* nombre de période */
local np = `r(narg)'
tempvar ga g1 tga tg1 mtga si nsi var bias
qui gen `ga' = 0
qui gen `tga'= 0
qui gen `g1' = 0
qui gen `tg1'= 0
qui gen `var'= 0
qui gen `bias'=0
qui gen `si' = 1.0
if ("`hsize'" != "") qui replace `si' =  `si'*`hsize'
forvalues i = 1/`np' {
			       qui replace  `ga' = 0
				 qui replace  `g1' = 0
		                if (`alpha'==0) qui replace `ga' = `si'*(`pline'> ``i'' )
                                if (`alpha'~=0) qui replace `ga' = `si'*((`pline'-``i'')/`pline')^`alpha' if (`pline'>``i'')
			       qui  qui replace `g1' = `si'*((`pline'-``i'')/`pline') if (`pline'>``i'')
			       qui replace `tga' = `tga' + `ga' 
			       qui replace `tg1' = `tg1' + `g1'
			       
              	    }

}

tempvar pag 
qui gen `pag'= `tga'/(`si'*`np')
forvalues i = 1/`np' { 

			       qui replace  `ga' = 0
		             if (`alpha'==0) qui replace `ga' = (`pline'> ``i'')
                         if (`alpha'~=0) qui replace `ga' = ((`pline'-``i'')/`pline')^`alpha' if (`pline'>``i'')
				 qui replace `var' = `var' + (1/(`np'-1))*(`ga' - `pag')^2           
 
                     }


/*********************************************************/
/* Computing the total poverty                           */


qui gen `nsi' = `si'*`np'

qui svy: ratio `tga'/`nsi'

matrix cc= e(b)
local tfgt = el(cc,1,1)^(1/`alpha')
matrix vv= e(V)
local stfgt = (el(vv,1,1))^0.5*(1/`alpha')*el(cc,1,1)^(1/`alpha'-1)



/*********************************************************/
/* Computing the transient poverty :cftg                 */

tempvar theta_i gam_i gaanal_i sgaanal_i

qui gen `gam_i'  = (`tga'/(`np'*`si'))^(1/`alpha')
qui gen `gaanal_i' = (`tg1'/(`np'*`si'))
qui gen `sgaanal_i' = `tg1'/`np'
qui gen `theta_i' = `si'*(`gam_i'-`gaanal_i')

qui svy: ratio `sgaanal_i'/`si'
matrix cc= e(b)
local gaanal = el(cc,1,1)
matrix cc= e(V)
local sgaanal = (el(cc,1,1))^0.5

qui svy: ratio `theta_i'/`si'
matrix cc= e(b)
local trfgt = el(cc,1,1)
matrix cc= e(V)
local strfgt = (el(cc,1,1))^0.5

/*********************************************************/
/* Computing the chronic poverty :cftg                   */


local cfgt = `tfgt'-`trfgt'
local scfgt = 0
local ccalpha=1
local calpha = `tfgt'-`trfgt'-`gaanal'

qui svy: mean `tga' `sgaanal_i' `theta_i' `nsi' `si' 
qui nlcom (_b[`tga']/_b[`nsi'])^(1/`alpha')-(_b[`theta_i']/_b[`si'])
matrix cc= r(V)
local scfgt = (el(cc,1,1))^0.5

qui nlcom (_b[`tga']/_b[`nsi'])^(1/`alpha')-(_b[`theta_i']/_b[`si'])  - (_b[`sgaanal_i']/_b[`si'])
matrix cc= r(V)
local scalpha = (el(cc,1,1))^0.5

//nlcom (_b[`theta_i']/_b[`si'])
//nlcom (_b[`sgaanal_i']/_b[`si'])


/*********************************************************/
/* Computing the bias if this option is selected         */

if ("`cbias'"=="anal") {

local ctfgt = `tfgt'
local sctfgt = `stfgt'

tempvar cbiaso scgam_i cgam_i ctheta_i the
qui gen `cbiaso'=0
qui replace `cbiaso' = (`alpha'-1)/(2*`np'*`alpha'^2)*`var'*`pag'^((1-2*`alpha')/`alpha') if (`gam_i'>0)
qui gen `cgam_i' = max(0,`gam_i'+`cbiaso')
qui gen `ctheta_i' = max(0,`si'*(`cgam_i'-`gaanal_i'))

qui svy: ratio `ctheta_i'/`si'
matrix cc= e(b)
local  ctrfgt = el(cc,1,1)
matrix cc= e(V)
local  sctrfgt = (el(cc,1,1))^0.5
local ccalpha = max(0,`ctfgt'-`ctrfgt'-`gaanal')
local sccalpha = 0
local ccfgt = max(0,`ctfgt'-`ctrfgt')
local sccfgt = 0

cap drop _Gga
qui gen _Gga=`si'*`cgam_i'^`alpha'
qui svy: ratio _Gga/`si'
matrix cc= e(b)
local  test1 = el(cc,1,1)
local test1 = `test1'^(1/`alpha')
cap drop _Gg1
qui gen _Gg1=`si'*`cgam_i'
qui svy: ratio _Gg1/`si'
matrix cc= e(b)
local  test2 = el(cc,1,1)
local calgal=`test1'-`test2'
local calgal=`ctfgt'-`test2'


qui svy: mean `tga' `cgam_i' `sgaanal_i' `ctheta_i' `nsi' `si' 
qui nlcom (_b[`tga']/_b[`nsi'])^(1/`alpha')-(_b[`ctheta_i']/_b[`si'])
matrix cc= r(V)
local sccfgt = (el(cc,1,1))^0.5

qui nlcom (_b[`tga']/_b[`nsi'])^(1/`alpha')-(_b[`ctheta_i']/_b[`si'])  - (_b[`sgaanal_i']/_b[`si'])
matrix cc= r(V)
local sccalpha = (el(cc,1,1))^0.5


}





if ("`cbias'"=="boot") {
biasda `varlist', pl(`pline') al(`alpha') nr(`nrep')
quietly{
tempvar finw biaso cgi scgi ctheta_i
qui gen `biaso' = sgap - `gam_i'
qui gen `cgi' = `si'*( `gam_i' - `biaso')^(`alpha')
qui svy: ratio `cgi'/`si'
matrix cc= e(b)
local pctfgt = el(cc,1,1)^(1/`alpha')
local psctfgt = (el(vv,1,1))^0.5*(1/`alpha')*el(cc,1,1)^(1/`alpha'-1)
local ctfgt = `tfgt'
local sctfgt = `stfgt'
qui gen `scgi'=(`cgi'/`si')^(1/`alpha')
qui gen `ctheta_i' = max(0,`si'*(`scgi'-`gaanal_i'))
qui svy: ratio `ctheta_i'/`si'
matrix cc= e(b)
local  ctrfgt = el(cc,1,1)
matrix cc= e(V)
local  sctrfgt = (el(cc,1,1))^0.5
local ccalpha = `ctfgt'-`ctrfgt'-`gaanal'
local sccalpha = 0
local ccfgt = `ctfgt'-`ctrfgt'
local sccfgt = 0

qui svy: mean `tga' `cgam_i' `sgaanal_i' `ctheta_i' `nsi' `si' 
qui nlcom (_b[`tga']/_b[`nsi'])^(1/`alpha')-(_b[`ctheta_i']/_b[`si'])
matrix cc= r(V)
local sccfgt = (el(cc,1,1))^0.5

qui nlcom (_b[`tga']/_b[`nsi'])^(1/`alpha')-(_b[`ctheta_i']/_b[`si'])  - (_b[`sgaanal_i']/_b[`si'])
matrix cc= r(V)
local sccalpha = (el(cc,1,1))^0.5

}


/*********************************************************/

}



/*********************************************************/
/* Displaying all results                               */


#delim ;
      disp in white "     "_col(5)"- Decomposition of total poverty into transient and chronic components.     ";
      disp in white "     "_col(5)"- Duclos, Araar and Giles (2006) approach.      ";
if ("`cbias'"=="") {;
 tempname table;
	.`table'  = ._tab.new, col(3);
	.`table'.width  16|16 16  ;
	.`table'.strcolor . . yellow  ;
	.`table'.numcolor yellow yellow . ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f ;
      disp in white " Poverty line      :" _col(25) in yellow %8.2f `pline';       				 
      disp in white " alpha             :" _col(25) in yellow %8.2f `alpha' ;
      disp in white " # of observations :" _col(25) in yellow %8.0f $obsa;
      disp in white " # of periods      :" _col(25) in yellow %8.0f `np';
      .`table'.sep, top;
	.`table'.titles "Components  " "Estimate"  "STD "  ;
      .`table'.sep, mid;
      .`table'.row "Gamma_1  " `gaanal'   `sgaanal'; 
      .`table'.row "C_alpha  " `calpha'   `scalpha';
      .`table'.sep,mid;
      .`table'.row "Transient" `trfgt'  `strfgt'; 
      .`table'.row "Chronic  " `cfgt'  `scfgt';
  .`table'.sep,mid;
  .`table'.numcolor white white   white;
  .`table'.row "Total    " `tfgt'  `stfgt';
  .`table'.sep,bot;

};

if ("`cbias'"=="anal" | "`cbias'"=="boot") {;
 tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width  16|16 16|16 16 ;
	.`table'.strcolor . . yellow yellow yellow  ;
	.`table'.numcolor yellow yellow . . . ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f  %16.`dec'f ;
      disp in white " Poverty line      :" _col(25) in yellow %8.2f `pline';       				 
      disp in white " alpha             :" _col(25) in yellow %8.2f `alpha' ;
      disp in white " # of observations :" _col(25) in yellow %8.0f $obsa;
      disp in white " # of periods      :" _col(25) in yellow %8.0f `np';
      .`table'.sep, top;
      .`table'.reset, col(3) ;
      .`table'.width  16|32|32 ;
      .`table'.titles "Bias  " "With bias correction  "   "Without bias correction  "   ;
      .`table'.sep,mid;
	 .`table'.reset, col(5); 
      .`table'.width  16|16 16|16 16 ;
	.`table'.strcolor . . yellow yellow yellow  ;
	.`table'.numcolor yellow yellow . . . ;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f  %16.`dec'f ;
	.`table'.titles "Components  " "Estimate"  "STD " "Estimate"  "STD "  ;
      .`table'.sep, mid; 
      .`table'.row "Gamma_1  " `gaanal'    `sgaanal'    `gaanal'    `sgaanal'; 
      .`table'.row "C_alpha  "    `ccalpha'    `sccalpha'  `calpha'    `scalpha';
      .`table'.sep,mid;
      .`table'.row "Transient"   `ctrfgt'  `sctrfgt'  `trfgt'  `strfgt'; 
      .`table'.row "Chronic  " `ccfgt'   `sccfgt' `cfgt'   `scfgt'   ;
  .`table'.sep,mid;
  .`table'.numcolor white white   white white   white;
  .`table'.row "Total    " `tfgt'  `stfgt'   `tfgt'  `stfgt';
  .`table'.sep,bot;

};


#delim cr


return scalar tfgt  = `tfgt'
return scalar gaanal = `gaanal'
return scalar calpha =`calpha'
return scalar cfgt  = `cfgt'
return scalar trfgt = `trfgt'
if ("`cbias'"=="anal") {
return scalar bias   = `bias'
return scalar ctfgt = `ctfgt'
return scalar ccfgt  = `ccfgt'
return scalar ctrfgt = `ctrfgt'
return scalar ccalpha =`ccalpha'
}
cap drop mh 
cap drop sgap

end


#delim ;
set more off;
capture program drop dtcpov ;
program define dtcpov, rclass;
version 9.2;
syntax varlist(min=1) [,  HSize(varname) PLine(real -1) ALpha(real -1) APPRoach(string) CBIas(string) NRep (int 100) Cens(string) DEC(int 3)] ;
preserve;


if ("`approach'"=="jr" | "`approach'"=="") {;
dtcrj `varlist', hsize(`hsize') pline(`pline') alpha(`alpha') cbias(`cbias') nrep(`nrep') cens(`cens') dec(`dec'); 
};

if ("`approach'"=="dag") {;
dtcda `varlist', hsize(`hsize') pline(`pline') alpha(`alpha') cbias(`cbias') nrep(`nrep') cens(`cens')  dec(`dec'); 
};

end;





