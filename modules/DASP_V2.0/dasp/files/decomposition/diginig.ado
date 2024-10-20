/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.0)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universit Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/


capture program drop nargs
program define nargs, rclass
version 9.2
syntax varlist(min=0)
quietly {
tokenize `varlist'
local k = 1
mac shift
while "``k''" ~= "" { 
local k = `k'+1 
}
}
global indica=`k'
end



#delim ;
cap program drop digini2;  
program define digini2, rclass ;    
version 9.2;         
syntax varlist (min=1 max=1) [, HSize(varname) HWeight(varname) HGroup(varname)  GNumber(int -1) TYPE(string)];
preserve;
tokenize `varlist';
                     qui drop if `1'>=. ;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;

tempvar  hs0 hs fw fw0  sw sw0;


gen `hs0'=1;
if ("`hsize'"!="")      qui replace `hs0'  = `hsize';
gen `fw0'= `hs0';
if ("`hweight'"!= "")   qui replace `fw0'  = `fw0'*`hweight';

gen `hs'=`hs0';
gen `fw'=`fw0';

tempvar _in;
if ("`hgroup' "!= "")  {;
 qui replace `hs' = `hs' * (`hgroup' == `gnumber');
 qui replace `fw' = `fw' * (`hgroup' == `gnumber');
};


//=================
if ("`rank'"=="") sort `1', stable;
if ("`rank'"!="") sort `rank' , stable;


tempvar smw smwy l1smwy ca;
gen `smw'  =sum(`fw');
gen `smwy' =sum(`1'*`fw');
gen `l1smwy'=0;
local mu=`smwy'[_N]/`smw'[_N];
local suma=`smw'[_N];
qui count;
forvalues i=2/`r(N)' { ;
qui replace `l1smwy'=`smwy'[`i'-1]  in `i';
};

gen `ca'=`mu'+`1'*((1.0/`smw'[_N])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[_N])*(2.0*`l1smwy'+`fw'*`1'); 
qui sum `ca' [aw=`fw'], meanonly; 
local gini=`r(mean)'/(2.0*`mu');
local xi = `r(mean)';
tempvar vec_a vec_b theta v1 v2 sv1 sv2;
qui count;

            local fx=0;
            gen `v1'=`fw'*`1';
            gen `v2'=`fw';
            gen `sv1'=sum(`v1');
            gen `sv2'=sum(`v2') ;
            qui replace `v1'=`sv1'[`r(N)']   in 1;
		qui replace `v2'=`sv2'[`r(N)']   in 1;

            forvalues i=2/`r(N)'  {;
            qui replace `v1'=`sv1'[`r(N)']-`sv1'[`i'-1]   in `i';
		qui replace `v2'=`sv2'[`r(N)']-`sv2'[`i'-1]   in `i';
            } ;
           
            gen `theta'=`v1'-`v2'*`1';

           forvalues i=1/`r(N)' {;
                qui replace `theta'=`theta'[`i']*(2.0/`suma')  in `i';
                local fx=`fx'+`fw'[`i']*`1'[`i'];
            };            
            local fx=`fx'/`suma';
            gen `vec_a' = `hs'*((1.0)*`ca'+(`1'-`fx')+`theta'-(1.0)*(`xi'));
            if ("`type'"=="")     gen `vec_b' =  2*`hs'*`1';
		if ("`type'"=="abs")  gen `vec_b' =  2*`hs';


tempvar smw smwy l1smwy ca;
gen `smw'  =sum(`fw0');
gen `smwy' =sum(`1'*`fw0');
gen `l1smwy'=0;
local mu=`smwy'[_N]/`smw'[_N];
local suma=`smw'[_N];
qui count;
forvalues i=2/`r(N)' { ;
qui replace `l1smwy'=`smwy'[`i'-1]  in `i';
};

gen `ca'=`mu'+`1'*((1.0/`smw'[_N])*(2.0*`smw'-`fw0')-1.0) - (1.0/`smw'[_N])*(2.0*`l1smwy'+`fw0'*`1'); 
qui sum `ca' [aw=`fw0'], meanonly; 
local gini0=`r(mean)'/(2.0*`mu');
local xi0 = `r(mean)';
tempvar vec_c vec_d theta v1 v2 sv1 sv2;
qui count;

         
            local fx=0;
            gen `v1'=`fw0'*`1';
            gen `v2'=`fw0';
            gen `sv1'=sum(`v1');
            gen `sv2'=sum(`v2') ;
            qui replace `v1'=`sv1'[`r(N)']   in 1;
		qui replace `v2'=`sv2'[`r(N)']   in 1;

            forvalues i=2/`r(N)'  {;
            qui replace `v1'=`sv1'[`r(N)']-`sv1'[`i'-1]   in `i';
		qui replace `v2'=`sv2'[`r(N)']-`sv2'[`i'-1]   in `i';
            } ;
           
            gen `theta'=`v1'-`v2'*`1';

           forvalues i=1/`r(N)' {;
                qui replace `theta'=`theta'[`i']*(2.0/`suma')  in `i';
                local fx=`fx'+`fw0'[`i']*`1'[`i'];
            };            
            local fx=`fx'/`suma';
            gen `vec_c' = `hs0'*((1.0)*`ca'+(`1'-`fx')+`theta'-(1.0)*(`xi0'));
            if ("`type'"=="")     gen `vec_d' =  2*`hs0'*`1';
	      if ("`type'"=="abs")  gen `vec_d' =  2*`hs0';

qui svy: ratio `vec_c'/`vec_d';
cap drop matrix _aa;
matrix _aa=e(b);
return scalar gini =el(_aa,1,1);
cap drop matrix _vv;
matrix _vv=e(V);
return scalar stdg =el(_vv,1,1)^0.5;
cap drop matrix _vv;


//=================

tempvar vec_aa vec_bb vec_cc vec_dd;

gen   `vec_aa' = `hs0';           
gen   `vec_bb' = `hs0'*`1';  
gen   `vec_cc' = `hs';
gen   `vec_dd' = `hs'*`1';



qui svy: mean `vec_a' `vec_b' `vec_c' `vec_d' `vec_aa' `vec_bb' `vec_cc' `vec_dd'  ;
cap drop matrix _aa;
matrix _aa=e(b);
global ws1=el(_aa,1,1);
global ws2=el(_aa,1,2);
global ws3=el(_aa,1,3);
global ws4=el(_aa,1,4);
global ws5=el(_aa,1,5);
global ws6=el(_aa,1,6);
global ws7=el(_aa,1,7);
global ws8=el(_aa,1,8);

///Gini index

local est1= $ws1/$ws2;
cap drop matrix mat;
matrix mat=e(V);
cap drop matrix gra;
matrix gra=
(
1/$ws2\
-$ws1/$ws2^2\
0\
0\
0\
0\
0\
0
);
cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std1= el(_zz,1,1)^0.5; 

return scalar est1 = `est1';
return scalar std1 = `std1';


/// Pop. Share

local est2= $ws7/$ws5;
cap drop matrix gra;
matrix gra=
(
0\
0\
0\
0\
-$ws7/$ws5^2\
0\
1/$ws5\
0
);
cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std2= el(_zz,1,1)^0.5;  

return scalar est2 = `est2';
return scalar std2 = `std2';


/// Inc. Share

local est3= $ws8/$ws6;
cap drop matrix gra;
matrix gra=
(
0\
0\
0\
0\
0\
-$ws8/$ws6^2\
0\
1/$ws6
);
cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std3= el(_zz,1,1)^0.5;  

return scalar est3 = `est3';
return scalar std3 = `std3';




if ("`type'"=="") {;
/// Abs. Cont
local est4= 0.5*(($ws1*$ws7)/($ws5*$ws6));
cap drop matrix gra;
matrix gra=
(
($ws7)/($ws5*$ws6)\
0\
0\
0\
-($ws1*$ws7)/($ws5^2*$ws6)\
-($ws1*$ws7)/($ws6^2*$ws5)\
($ws1)/($ws5*$ws6)\
0
);
cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std4= 0.5*el(_zz,1,1)^0.5;  

return scalar est4 = `est4';
return scalar std4 = `std4';


/// Rel. Cont

local est5= ($ws1*$ws7)/($ws5*$ws3);
cap drop matrix gra;
matrix gra=
(
$ws7/($ws5*$ws3)\
0\
-($ws1*$ws7)/($ws3^2*$ws5)\
0\
-($ws1*$ws7)/($ws5^2*$ws3)\
0\
($ws1)/($ws5*$ws3)\
0
);

cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std5= el(_zz,1,1)^0.5;  

return scalar est5 = `est5';
return scalar std5 = `std5';


};


if ("`type'"=="abs") {;
/// Abs. Cont
local est4= (($ws1*$ws7^2)/($ws5^2*$ws2));
cap drop matrix gra;
matrix gra=
(
($ws7^2)/($ws5^2*$ws2)\
-($ws1*$ws7^2)/($ws2^2*$ws5^2)\
0\
0\
-(2*$ws1*$ws7^2)/($ws5^3*$ws2)\
0\
(2*$ws7*$ws1)/($ws5^2*$ws2)\
0
);
cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std4= el(_zz,1,1)^0.5;  

return scalar est4 = `est4';
return scalar std4 = `std4';


/// Rel. Cont

local est5= ($ws1*$ws7)/($ws5*$ws3);
cap drop matrix gra;
matrix gra=
(
$ws7/($ws5*$ws3)\
0\
-($ws1*$ws7)/($ws3^2*$ws5)\
0\
-($ws1*$ws7)/($ws5^2*$ws3)\
0\
($ws1)/($ws5*$ws3)\
0
);

cap matrix drop _zz;
matrix _zz=gra'*mat*gra;
local std5= el(_zz,1,1)^0.5;  

return scalar est5 = `est5';
return scalar std5 = `std5';


};




return scalar mug   = $ws8/$ws7;

end;     








cap program drop diginig;
program define diginig, rclass;
syntax varlist (min=1 max=1) [, 
HGroup(varname) HSize(varname)  STD(string) dec(int 4)
LEVEL(real 95) DSTD(int 1) TYPE(string)
XFIL(string) XSHE(string) XLAN(string) XTIT(string)];

#delim cr;
version 9.2



if ("`hgroup'"!="") {
preserve
capture {
local lvgroup:value label `hgroup'
if ("`lvgroup'"!="") {
uselabel `lvgroup' , replace
qui count
forvalues i=1/`r(N)' {
local tem=value[`i']
local grlab`tem' = label[`i']
}
}
}
restore
preserve
qui tabulate `hgroup', matrow(gn)
svmat int gn
global indica=r(r)
tokenize `varlist'
}
if ("`hgroup'"=="") {
tokenize `varlist'
_nargs    `varlist'
preserve
}


global indica=r(r)

cap svy: total `1'
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized)
local ll=length("`1': `grlab`1''")

local hweight=""
cap qui svy: total `1' set more off
local hweight=`"`e(wvar)'"'
cap ereturn clear
tempvar fw
quietly{
gen `fw'=1
if ("`hsize'"  ~="")     replace `fw'=`fw'*`hsize'
if ("`hweight'"~="")     replace `fw'=`fw'*`hweight'
}


tempvar _muk
qui gen `_muk'=0

qui count

qui sum `fw'
local suma = `r(sum)'

cap drop component Pop_Share Rel_Contr Abs_Contr Total
#delim ;
tempvar Variable EST EST1 EST2 EST3 EST4 EST5 STD STD1 STD2 STD3 STD4 STD5;
qui gen `Variable'="";
qui gen `EST'=.;
qui gen `STD'=.;

qui gen `EST2'=.;
qui gen `STD2'=.;

qui gen `EST3'=.;
qui gen `STD3'=.;

qui gen `EST4'=.;
qui gen `STD4'=.;

qui gen `EST5'=.;
qui gen `STD5'=.;

local t1=0;
local t2=0;
local t3=0;
local t4=0;
local t5=0;
local acon=0;
local rcon=0;

#delim cr;
local nobsa=$indica+1
forvalues k = 1/$indica {
local kk = gn1[`k']
if ( "`grlab`k''" == "") local grlab`k' = "Group_`kk'"
local ttt=gn1[`k']

digini2 `1', hw(`hweight') hs(`hsize') hgroup(`hgroup') gnumber(`ttt') type(`type')

#delim ;
local t1=`t1'+`r(est3)';
qui replace `_muk'=`r(mug)'     if (`hgroup'==gn1[`k']);
local k1= (`k'-1)*2+1;
local k2= (`k'-1)*2+2;
qui replace `EST'      = `r(est1)' in `k1';
qui replace `EST'      = `r(std1)' in `k2';

qui replace `EST2'      = `r(est2)' in `k1';
qui replace `EST2'      = `r(std2)' in `k2';

qui replace `EST3'      = `r(est3)' in `k1';
qui replace `EST3'      = `r(std3)' in `k2';

qui replace `EST4'      = `r(est4)' in `k1';
qui replace `EST4'      = `r(std4)' in `k2';

qui replace `EST5'      = `r(est5)'      in `k1';
qui replace `EST5'      = `r(std5)'      in `k2';

local acon= `acon'+ `r(est4)';
local rcon= `rcon'+ `r(est5)';
if ( "`grlab`kk''" == "") local grlab`kk' = "Group_`kk'";
qui replace `Variable' = "`kk': `grlab`kk''" in `k1';
local ll=max(`ll',length("`kk': `grlab`kk''"));

local gini = `r(gini)';
local stdg = `r(stdg)';

};

local ll=`ll'+2;

local kk1 = `k2'+1;
local kk2 = `k2'+2;
local kk3 = `k2'+3;
local kk4 = `k2'+4;
local kk5 = `k2'+5;
local kk6 = `k2'+6;
local kk7 = `k2'+7;
local kk8 = `k2'+8;


qui replace `Variable' = "Within"  in `kk1';


qui replace `EST4'      = `acon' in `kk1';


qui replace `EST5'      = `acon'/`gini' in `kk1';




qui digini2 `_muk', hw(`hweight') hs(`hsize') hgroup(`hgroup') gnumber(1) type(`type');
local betw=`r(gini)';

qui replace `Variable' = "Beetwin"  in `kk3';


qui replace `EST4'      = `betw' 	in `kk3';


qui replace `EST5'      = `betw'/`gini' 	in `kk3';



qui replace `Variable' = "Overlap"  in `kk5';


local residue = `gini' - `betw' - `acon' ;
qui replace `EST4'      = `residue' 	in `kk5';


qui replace `EST5'      = `residue'/`gini' 	  in `kk5';


 
qui replace `Variable' = "Population"  in `kk7';
qui replace `EST'      = `gini'  in `kk7';
qui replace `EST'      = `stdg'  in `kk8';

qui replace `EST2'      = 1 in `kk7';
qui replace `EST2'      = 0 in `kk8';

qui replace `EST3'      = 1 in `kk7';
qui replace `EST3'      = 0 in `kk8';

qui replace `EST4'      = `gini' in `kk7';
qui replace `EST4'      = `stdg' in `kk8';

qui replace `EST5'      = 1 in `kk7';
qui replace `EST5'      = 0 in `kk8';


                       local tind ="";
if ("`type'"=="abs")   local tind ="Absolute ";
	tempname table;
	.`table'  = ._tab.new, col(6);
	.`table'.width |`ll'|12 12 12 12 12|;
	.`table'.strcolor . . . yellow . . ;
	.`table'.numcolor yellow yellow yellow . yellow yellow ;
	.`table'.numfmt %12.0g  %12.`dec'f  %12.`dec'f %12.`dec'f %12.`dec'f %12.`dec'f;
	di _n as text "{col 4} Decomposition of the `tind'Gini Index by Groups";
       if ("`hsize'"!="")   di as text     "{col 5}Household size  :  `hsize'";
       if ("`hweight'"!="") di as text     "{col 5}Sampling weight :  `hweight'";
       if ("`hgroup'"!="")  di as text     "{col 5}Group variable  :  `hgroup'";
     
	.`table'.sep, top;
	.`table'.titles "            " "Gini     "  "Population" "Income " "Absolute  " "Relative  " ;
	.`table'.titles "Group       " "index    "  "Shere     " "Share  " "Contrib.  " "Contrib.  " ;
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`k2'{;
        
             if (`i'/2!=round(`i'/2))  .`table'.numcolor white yellow yellow  yellow yellow yellow ;
             if !(`i'/2!=round(`i'/2)) .`table'.numcolor white green green  green  green green ;
		  if (`dstd'==1 | (`i'/2!=round(`i'/2))) .`table'.row `Variable'[`i'] `EST'[`i']  `EST2'[`i'] `EST3'[`i'] `EST4'[`i'] `EST5'[`i'];	        
              };
                
                
 .`table'.sep, mid;

.`table'.numcolor white yellow yellow  yellow yellow yellow ;
.`table'.row `Variable'[`kk1'] "---"  "---" "---" `EST4'[`kk1'] `EST5'[`kk1'];
if (`dstd'==1){;
.`table'.numcolor white green   green green green green ;
.`table'.row `Variable'[`kk2'] "---"  "---"  "---"  "---"  "---";
};




.`table'.numcolor white yellow yellow  yellow yellow yellow ;
.`table'.row `Variable'[`kk3'] "---"  "---" "---" `EST4'[`kk3'] `EST5'[`kk3'];
if (`dstd'==1){;
.`table'.numcolor white green   green green green green ;
.`table'.row `Variable'[`kk4'] "---"  "---"  "---"  "---"  "---";
};

.`table'.numcolor white yellow yellow  yellow yellow yellow ;
.`table'.row `Variable'[`kk5'] "---"  "---" "---" `EST4'[`kk5'] `EST5'[`kk5'];
if (`dstd'==1){;
.`table'.numcolor white green   green green green green ;
.`table'.row `Variable'[`kk6'] "---"  "---"  "---"  "---"  "---";
};

              
  .`table'.sep, mid;
.`table'.numcolor white yellow yellow  yellow yellow yellow ;
.`table'.row `Variable'[`kk7'] `EST'[`kk7']  `EST2'[`kk7'] `EST3'[`kk7'] `EST4'[`kk7'] `EST5'[`kk7'];
if (`dstd'==1){;
.`table'.numcolor white green   green green green green ;
.`table'.row `Variable'[`kk8'] `EST'[`kk8']  `EST2'[`kk8']  `EST3'[`kk8'] `EST4'[`kk8'] `EST5'[`kk8'];
};


	.`table'.sep,bot;


//===============


cap drop __compa;
qui gen __compna=`Variable';

local lng = ($indica*2+8);
qui keep in 1/`lng';

if ("`xlan'"=="fr") {;
local k1=$indica*2+1;
local k2=$indica*2+3;
local k3=$indica*2+5;
qui replace __compna = "Intra-groupes" in `k1';
qui replace __compna = "Inter-groupes" in `k2';
qui replace __compna = "Rsidu"        in `k3';
};
forvalues i=1(2)`lng'  {;
local temn=__compna[`i'];
               local rnam `"`rnam' "`temn'""';
if (`dstd'~=0) local rnam `"`rnam' " ""';
};

if (`dstd'==0) {;
local bf=`lng'/2+1;
forvalues j=2(1)`bf'{;
qui drop in `j';
};
};



global rnam `"`rnam'"';

tempname zz;

qui mkmat	 `EST'  `EST2' `EST3' `EST4' `EST5',	matrix(`zz');




local lnb= 2*$indica;


                    local index = "Gini index"; 
if ("`xlan'"=="fr") local index = "Indice de Gini";

local cnam;
local cnam `"`cnam' "`index'""';
if ("`xlan'"~="fr")  local cnam `"`cnam' "Population share""';
if ("`xlan'"=="fr")  local cnam `"`cnam' "Proportion de la population""';
if ("`xlan'"~="fr")  local cnam `"`cnam' "Income share""'; 
if ("`xlan'"=="fr")  local cnam `"`cnam' "Proportion du revenu total""';
if ("`xlan'"~="fr")  local cnam `"`cnam' "Absolute contribution""';
if ("`xlan'"=="fr")  local cnam `"`cnam' "Contribution absolue""';
if ("`xlan'"~="fr")  local cnam `"`cnam' "Relative contribution""';
if ("`xlan'"=="fr")  local cnam `"`cnam' "Contribution relative""';
global cnam `"`cnam'"';

                     local xtit = "Table ##: Decomposition of the Gini index by...";
if ("`xlan'"=="fr")  local xtit = "Tableau ##: Dcomposition de l'indice de Gini selon...";
if ("`xtit'"~="")    local xtit = "`xtit'";

if ("`xfil'" ~="") {;
mk_xtab_m1 `1' ,  matn(`zz') dec(`dec') xfil(`xfil') xshe(`xshe') xtit(`xtit') xlan(`xlan') dstd(`dstd');
};

//===============

end;

