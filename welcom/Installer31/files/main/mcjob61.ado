


#delimit;
capture program drop mcjob61;
program define mcjob61, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) HGroup(varname) LAN(string) XRNAMES(string)  AGGRegate(string) PCEXP(varname)  WAPPR(int 1) MODEL(int 1) GVIMP(int 0) SUBS(real 0.4) MOVE(int 1) STEP(int 1)];

tokenize  `varlist';
_nargs    `varlist';




tempvar price_def;
qui gen `price_def' = 1;
forvalues i=1/$indica {;
tempvar Variable EST`i';
qui gen `EST`i''= 0;
local pointa = `step'+1;

if (`move'==-1 )  local prc`i' =  el(tab1_`i', 1, colsof(tab1_`i'))-el(tab1_`i', `pointa', colsof(tab1_`i'));
if (`move'== 1)   local prc`i' = -el(tab1_`i', 1, colsof(tab1_`i'))+el(tab1_`i', `pointa', colsof(tab1_`i'));


if (`wappr'==1) imwmc ``i'' , prc(`prc`i'') hsize(`hsize') move(`move');

if (`wappr'==2 & `model' ==1 ) {;
                  imwmc_cob_doug ``i'' , prc(`prc`i'') hsize(`hsize') pcexp(`pcexp') meas(`wappr') move(`move');
				  qui replace `price_def' = `price_def' * __tdef;
				 };
				 
if (`wappr'==3 & `model' ==1 ) {;
                  imwmc_cob_doug ``i'' , prc(`prc`i'') hsize(`hsize') pcexp(`pcexp') meas(`wappr') move(`move');
				  qui replace `price_def' = `price_def' * __tdef;
				 }; 
				 
				 
if (`wappr'==2 & `model' ==2 ) {;
                  imwmc_ces ``i'' , prc(`prc`i'') hsize(`hsize') pcexp(`pcexp') meas(`wappr') subs(`subs') move(`move');
				  qui replace `price_def' = `price_def' * __tdef;
				 };
				 
if (`wappr'==3 & `model' ==2 ) {;
                  imwmc_ces ``i'' , prc(`prc`i'') hsize(`hsize') pcexp(`pcexp') meas(`wappr')  subs(`subs') move(`move');
				  qui replace `price_def' = `price_def' * __tdef;
				 }; 
				 
				
tempvar imwmc_``i'' ;
qui gen  `imwmc_``i''' = __imwmc;
local nlist `nlist' `imwmc_``i''' ;
cap drop __imwmc;
cap drop __tdef;

};



if (`wappr'==2 & `model' ==1) {;
tempvar tot_imp;
qui gen `tot_imp' =`move'*( 1 / `price_def' -  1 )*`pcexp' ;
mcjobgini `tot_imp',   hs(`hsize') aehs(`aehs')  lan(`lan')   xrnames(`slist')  pcexp(`pcexp')    move(`move');
tempname mat61tot ;
matrix `mat61tot'= e(est); 
};
 
 

if (`wappr'==3 & `model' ==1) {;
tempvar tot_imp;
qui gen `tot_imp' =`move'*( 1- `price_def')*`pcexp' ;
mcjobgini `tot_imp',   hs(`hsize') aehs(`aehs')  lan(`lan')   xrnames(`slist')  pcexp(`pcexp')    move(`move');
tempname mat61tot ;
matrix `mat61tot'= e(est); 
};
 
  if ((`wappr'==2 | `wappr'==3) & `model' ==2) {;
 forvalues i=1/$indica {;
if (`move'==-1 )  local prc`i' =  el(tab1_`i', 1, colsof(tab1_`i'))-el(tab1_`i', `pointa', colsof(tab1_`i'));
if (`move'== 1)   local prc`i' = -el(tab1_`i', 1, colsof(tab1_`i'))+el(tab1_`i', `pointa', colsof(tab1_`i'));
};
 
if $indica<10 {;
local j = $indica+1;
  forvalues i=`j'/10 {;
  local prc`i' = 0;
  };
  };
imwmc_ces_all `varlist' , 
prc1(`prc1')  prc2(`prc2')   prc3(`prc3')  prc4(`prc4')   prc5(`prc5') 
prc6(`prc6')  prc7(`prc7')   prc8(`prc8')  prc9(`prc9')   prc10(`prc10')  
hsize(`hsize') pcexp(`pcexp') meas(`wappr')  subs(`subs') move(`move');
tempvar tot_imp;
qui gen `tot_imp' = __imwmc; 
cap drop  __imwmc;
mcjobgini `tot_imp',  hs(`hsize') aehs(`aehs')  lan(`lan')   xrnames(`slist')  pcexp(`pcexp')    move(`move');
tempname mat61tot ;
matrix `mat61tot'= e(est); 
};



aggrvar `nlist' , xrnames(`xrnames') aggregate(`aggregate');

local  slist  `r(slist)';
local  flist  `r(flist)';
local drlist  `r(drlist)';
mcjobgini `flist',   hs(`hsize') aehs(`aehs')  lan(`lan')   xrnames(`slist')  pcexp(`pcexp')    move(`move');
cap drop `drlist';
tempname mat61 ;
matrix `mat61'= e(est);

if (`wappr'!=1) {;
local rowsize = rowsof(`mat61');
local colsize = colsof(`mat61');
forvalues i=1/`rowsize' {;
 matrix `mat61'[ `i',`colsize'] = el(`mat61tot',`i',1);
};

};

ereturn matrix est = `mat61';

end;



