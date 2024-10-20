

/*************************************************************************/
/* Stata SHEXP                              (Version 0.01)               */
/*************************************************************************/
/* Conceived  by Dr. Araar, Carlos & Luca Tiberti  (08-2019)             */
/* PEO and Universite Laval, Quebec, Canada                              */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* shexp.ado                                                             */
/*************************************************************************/



#delimit ;
capture program drop shexp;
program define shexp, eclas;
version 9.2;
syntax varlist(min=1 max=1) [, 
TOTPUB(varname)	
EXPEXM(varname)	
EXPEXF(varname)
EXPEXK(varname)	

FSHARE(varname)

	
VLIST(varlist)
ILIST(varlist)

LIENGF(varlist)	
LIENGM(varlist)
LIENGK(varlist)


NFEMALE(varname)
AVAGEF(varname)	

NMALE(varname)
AVAGEM(varname)	

NKID(varname)
AVAGEK(varname)	

NBOYS(varname)	
OTHERV(varlist)

COLMOD(int 1)
TYMOD(int 1)

TECHnique(string)
FROM(string)
INISAVE(string)
DEC(int 4)
XFIL(string)  
DGRA(int 1) 
*
];

preserve;
local option0 `options';
mlopts stdopts, `option0';
local ml_max_opt  `stdopts';
if "`technique'"=="" local technique = "bfgs" ;
#delimit ;
 if ("`inisave'" ~="") {;
  qui asdbsave_shexp `0' ;
  };
  

tokenize "`xfil'" ,  parse(".");
local tname "`1'.xml";
if "`xfil'" ~= ""  { ;
cap winexec   taskkill /IM excel.exe ;
tokenize "`xfil'" ,  parse(".");
local xfil "`1'.xml" ;
cap erase  "`1'.xml" ;
};
 
tokenize `varlist';
tempvar texpshm  texpshf   texpshk; 

if ("`fshare'"~= "") {;
tempvar tfshare;
qui gen `tfshare' = `fshare' ;
if ("`fshare'"~= "f_share") qui gen f_share  = `fshare';
cap drop m_share; 
qui gen m_share = 1- f_share;
cap drop k_share;
qui gen  k_share = 0;
} ;


local n1 : word count `liengf'; 
local n2 : word count `liengm'; 
local n3 : word count `liengk'; 
local n4 : word count `otherv'; 
local ncf  =  `n1'+3 ; 
local ncm  =  `n2'+3 ; 
local nck   = `n3'+3 ; 
local nczk  = `n4'+4 ;


local fncoef = (`ncm')+(`ncf')+(`nck')+2*(`nczk')+15;

local wdir   `c(pwd)';
local wdir = subinstr("`wdir'","\","/",.);
local fdata = c(filename);
tokenize `varlist';
cap drop lnexp ;  
qui gen  lnexp = log(`1') ; 
local    mylist `mylist' lnexp ;
local list m f k;
foreach car of local list {;
cap drop shexcl_`car';
qui gen  shexcl_`car'  = `expex`car''/`1';
};

if "`avagek'" ~= "avage" qui gen avage = `avagek' ; 
local mylist `mylist' avage;

 local mylist `mylist' m_share ;
 local mylist `mylist' f_share ;
 local mylist `mylist' k_share ;

 local mylist `mylist' shexcl_m ;
 local mylist `mylist' shexcl_f ;
 local mylist `mylist' shexcl_k ;

 local mylist `mylist' m_share ;
 local mylist `mylist' f_share ;
 local mylist `mylist' k_share ;


local mylist `otherv' ;
cap drop prom;
qui gen prom   =  `nboys'/`nkid';
qui replace prom=0 if `nkid'==0;
qui replace nkid = 3 if nkid>=3;


cap drop type;
qui gen type     =  20+`nkid';
cap drop gneta_*;
qui gen     gneta_f = f_share ;
qui gen     gneta_m = m_share;
qui gen     gneta_k = k_share;
cap drop  deflatexp_f;
cap drop  deflatexp_f2;
cap drop  deflatexp_m;
cap drop  deflatexp_m2;
cap drop  deflatexp_k;
cap drop  deflatexp_k2;
qui gen     deflatexp_f = lnexp + log(gneta_f);
qui replace deflatexp_f =0 if deflatexp_f==.;
qui gen     deflatexp_f2 = deflatexp_f^2;

qui gen     deflatexp_m = lnexp + log(gneta_m);
qui replace deflatexp_m =0 if deflatexp_m==.;
qui gen     deflatexp_m2 = deflatexp_m^2;

qui gen     deflatexp_k = lnexp + log(gneta_k);
qui replace deflatexp_k =0 if deflatexp_k==.;
qui gen     deflatexp_k2 = deflatexp_k^2;

qui regress lnexp `vlist'   `ilist'                    if type== 20 ;
cap drop res20;
qui predict double res20 , res;
qui replace res20=0 if res20==.;

qui regress lnexp  `vlist' `ilist' avage prom nkid if  type> 20;
cap drop resm20;
qui predict double resm20 , res;
qui replace resm20=0 if resm20==.;
qui g double resid_lnexp = res20*(type==20)+resm20*(type>20);

qui drop res20;
qui drop resm20;


 
#delimit cr
qui {
cap drop lnexp  
qui gen lnexp = log(`1') 
reg lnexp nkid avage  prom `otherv' deflatexp_k deflatexp_k2 if type>20
local tmp = round(_b[_cons],0.0000001)
local list1 `tmp'
foreach var of varlist nkid avage  prom  `otherv' {
local tmp = round(_b[`var'],0.0000001)
local list1 `list1' , `tmp'
local stlist1 `stlist1'  `tmp'
}
local tmp = round(_b[_cons],0.0000001)
local stlist1 `stlist1' `tmp'


qui reg lnexp nkid avage  prom  `otherv' deflatexp_k deflatexp_k2 i if type==20
local tmp = round(_b[_cons],0.0000001)
local list2 `tmp'
foreach var of varlist nkid avage  prom  `otherv' {
local tmp = round(_b[`var'],0.000001)
local list2 `list2' , `tmp'
local stlist2 `stlist2' `tmp'
}
local tmp = round(_b[_cons],0.0000001)
local stlist2 `stlist2' `tmp'

}



/*
dis "`list1'" 
dis "`list2'" 
*/
local liengzk  nkid avage  prom  `otherv'
local olistzk  nkid avage  prom  `otherv'
#delimit ;

/*
local nother = 0;
foreach var of varlist `otherv' {;
local nother = `nother' + 1;
if `nother'== 1 local otherl `otherl'  `var' ;
if `nother'!= 1 local otherl `otherl' , `var' ;
};
*/

local lgend f m k zk;
foreach g   of local lgend {;
local count = 0;
foreach var of varlist `lieng`g'' {;
if `count' == 0  local list`g'  `list`g'' `var' ;
if `count' != 0  local list`g'  `list`g'' , `var' ;
local count = 1;
};
};


/*set trace on ; */
local nbf = `ncf'-1;
local nbm = `ncm'-1;
local nbk = `nck'-1;
local nbzk = `nczk'-1;



global  m_ys "m_share" ;
global  f_ys "f_share" ;
global  k_ys "k_share" ;
global  rlnexp "resid_lnexp";
global  lny "lnexp";
global  sef  "shexcl_f";
global  sem  "shexcl_m";
global  sek  "shexcl_k";


local nzeros = `nbf'+`nbm'+`nbk'+12 ; 
forvalues i=1/`nzeros'   {;
local inzero  `inzero'   0;
};
                 local inilista  `inzero' 1 0 1 0 0 1 `stlist1' `stlist2' ;
if "`from'"!=""  local inilista  `from' ;

 ml model lf ll_shexp    
 (eq_f: `liengf')  /cf1 /cf2   
 (eq_m: `liengm' ) /cm1 /cm2   
 (eq_k: `liengk' ) /ck1 /ck2  
 /rf0 /rf1  /rf2  /rf3 /rm0 /rm1 /rm2 /rm3 /rk 
 /siga11 /siga21 /siga22 /siga31 /siga32 /siga33  
 (eqk: `olistzk') 
 (eqf: `olistzk') 
, technique(`technique')  ;
ml init `inilista' , copy;
ml max , `ml_max_opt' ;

estimates store mod1; 

xml_tab mod1,  format(sclb0 ncrr3 nccr3) stats(N pr2) ///
save(`xfil') replace   keep(eqf: eqk:) ///
cblanks(2) cwidth(0 200, 3 4)  long cnames(Coefficients "S.E.")  ///
sheet(Results)  ///
lines(_cons 2 LAST_ROW 13 COL_NAMES 2 EST_NAMES 2) ///
title("Estimated Results");
restore;



if "`xfil'" ~= ""  { ;
di as txt `"(output written to {browse "`xfil'"})"';
};

end;


