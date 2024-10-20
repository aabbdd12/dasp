/********************************************************************************/
/*  Package       : USST //Usefull Stata Tools                                  */
/*  Version       :   0.10   //                       JUNE         2020         */
/*  Stata Version : Required  15.0 and higher                                   */
/*  Authors       : Abdelkrim Araar  // aabd@ecn.ulaval.ca                      */
/********************************************************************************/

#delimit ;


#delimit ;
capture program drop mbasicginigr;
program define mbasicginigr, eclass;  
version 15;   

      
syntax varlist (min=1) [, HSize(varname) HWeight(varname) RANK(varname) HGroup(varname) CI(real 5)  LEVEL(real 95) XRNAMES(string) MTRANS(int 1) diff1 CHANGE(string)];
preserve;
tokenize `varlist';
_nargs   `varlist';
version 15 ;
if "`hsize'" == "" {;
tempvar hsize; qui g `hsize' = 1;
};

 
if "`hgroup'" == "" {;
tempvar hgroup; qui g `hgroup' = 1;
};

if "`change'" == "" local change = "abs";

if "`denom'" ~= "" {;
cap drop `deno';
tempvar  deno;
qui gen `deno' = `hsize'*`denom';
} ;

qui levelsof `hgroup', local(mygr);
local mystr `r(levels)';
local ngr `: word count `mystr'';



tempname aa bb cc dd ee ff;
matrix `aa' =J($indica,`ngr',.) ;
matrix `bb' =J($indica,`ngr',.) ;
matrix `cc' =J($indica,`ngr',.) ;
matrix `dd' =J($indica,`ngr',.) ;
matrix `ee' =J($indica,`ngr',.) ;
matrix `ff' =J($indica,`ngr',.) ;

qui levelsof `hgroup', local(mygr);
local mystr `r(levels)';
local ngr `: word count `mystr'';
local i = 1;

                     qui drop if `1'>=. ;
if ("`hsize'"!="")   qui drop if `hsize'>=.;
if ("`hweight'"!="") qui drop if `hweight'>=.;


tempvar  hs sw fw ;
qui gen double `sw'=1.0;
qui gen double `hs'=1.0;
if ("`hweight'"!="")   qui replace `sw'=`hweight';
if ("`hsize'"!="")     qui replace `hs' = `hsize';

qui gen double `fw'=`hs'*`sw';

local tpos = 0; 
foreach x of local mygr { ;
qui count  if `hgroup' == `x';
local  N`x' = `r(N)';
local  FN`x'  = `tpos' + 1;
local  FN2`x' = `tpos' + 2;
local  EN`x' = `tpos'+`r(N)';
local  tpos  = `tpos'+`r(N)';
/* dis `x' "   " `FN`x'' "   " `EN`x''  ; */
} ;

tempvar ngrroup;
qui gen `ngrroup' = `hgroup' ;

forvalues i = 1/$indica { ;

if ("`rank'"=="") sort `hgroup' ``i''   , stable;
if ("`rank'"!="") sort `hgroup' ``i''`rank' , stable;


local list1 smw smwy l1smwy ca vec_a vec_b theta v1 v2 sv1 sv2 v1 v2 vfx theta; 
foreach name of local list1 {;
cap drop ``name'' ;
};
cap drop `smw';
cap drop `smwy';
cap drop `llsmwy';
cap drop `ca';
tempvar smw smwy l1smwy ca;
qui gen  double `smw'  =0;
qui gen  double `smwy' =0;
qui gen double `l1smwy'=0;
qui gen double  `ca'= 0;
//gen suma = 0;

foreach x of local mygr { ;
qui replace `smw'  =sum(`fw')        if `hgroup' == `x';
qui replace `smwy' =sum(``i''*`fw')  if `hgroup' == `x';
};



foreach x of local mygr { ;
local mu`x'  =`smwy'[`EN`x'']/`smw'[`EN`x''];
local suma`x'=`smw'[`EN`x''];
qui replace `l1smwy'=`smwy'[_n-1]   if `hgroup' == `x';
qui replace `l1smwy' = 0 in `FN`x'' if `hgroup' == `x'; 
qui replace `ca'=`mu`x''+``i''*((1.0/`smw'[`EN`x''])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[`EN`x''])*(2.0*`l1smwy'+`fw'*``i'') if `hgroup' == `x'; 
qui sum `ca' [aw=`fw']  if `hgroup' == `x', meanonly; 
local gini_`x'=`r(mean)'/(2.0*`mu`x'');
if  ("`type'" == "abs") local gini_`x'=`r(mean)'/(2.0);
local xi`x' = `r(mean)';
};

tempvar vec_a_`i' vec_b_`i' theta v1 v2 sv1 sv2;

      

qui gen `v1'=`fw'*``i'';
qui gen `v2'=`fw';

qui gen `sv1'=0;
qui gen `sv2'= 0;

tempvar vfx ;
cap drop `vfx' ;
qui gen `vfx' =0;
cap drop `vec_a_`i'';
cap drop `vec_b_`i'';
cap drop `theta';
qui  gen `vec_a_`i'' = 0 ;
qui  gen `vec_b_`i'' = 0 ;
qui  gen `theta' = 0; 
foreach x of local mygr { ;
qui replace `sv1'=sum(`v1') if `hgroup' == `x';
qui replace `sv2'=sum(`v2') if `hgroup' == `x';

qui replace `v1'=`sv1'[`EN`x'']   in `FN`x''    if `hgroup' == `x';
qui replace `v2'=`sv2'[`EN`x'']   in `FN`x''   	if `hgroup' == `x';	
qui replace `v1'=`sv1'[`EN`x'']-`sv1'[_n-1] in `FN2`x''/`EN`x'' if `hgroup' == `x';
qui replace `v2'=`sv2'[`EN`x'']-`sv2'[_n-1] in `FN2`x''/`EN`x'' if `hgroup' == `x';
qui replace `vfx' = sum(`fw'*``i'')  if `hgroup' == `x';
local fx_`x' = `vfx'[`EN`x'']/`suma`x''; 
qui replace    `theta'=(`v1'-`v2'*``i'')*(2.0/`suma`x'')  if `hgroup' == `x';
qui replace `vec_a_`i'' = `hs'*((1.0)*`ca'+(``i''-`fx_`x'')+`theta'-(1.0)*(`xi`x'')) if `hgroup' == `x';
};

qui  replace  `vec_b_`i'' =  2*`hs'*``i'';




if  ("`type'" == "abs") qui replace `vec_b_`i''  =  2*`hs';
qui  svy: ratio (`vec_a_`i''/`vec_b_`i'') , over(`hgroup'); 

forvalues v=1/`ngr' {;
matrix `aa'[`i',`v'] = el(e(b), 1 , `v');
matrix `bb'[`i',`v'] = el(e(V), `v' , `v')^0.5;
};

 
version 15 ;
qui svy: ratio (`vec_a_`i''/`vec_b_`i'') (`vec_a_1'/`vec_b_1') , over(`ngrroup') coeflegend ;
local pos = 1 ;
foreach v of local mygr { ;
if ("`change'"=="abs")   qui nlcom     _b[_ratio_1:`v'] -  _b[_ratio_2:`v'] ; 
if ("`change'"=="rel")   qui nlcom   ( _b[_ratio_1:`v'] -  _b[_ratio_2:`v'])/_b[_ratio_2:`v'] ;
if ("`change'"=="abs") matrix `cc'[`i',`pos'] = el(r(b), 1 , 1);
if ("`change'"=="rel") matrix `cc'[`i',`pos'] = el(r(b), 1 , 1);
matrix `dd'[`i',`pos'] = el(r(V), 1 , 1)^0.5;
local tval = `cc'[`i',`pos'] /`dd'[`i',`pos'];
local pval = 1-2*(normal(abs(`tval'))-0.5);
matrix `ee'[`i',`pos'] = `pval';
matrix `ff'[`i',`pos'] = (`ee'[`i',`pos']<=0.1)+(`ee'[`i',`pos']<=0.05)+(`ee'[`i',`pos']<=0.01);
local pos = `pos' + 1 ;
};


};


local rnam;
if ("`xrnames'"~="") {;
local xrna  "`xrnames'";
local xrna : subinstr local xrna " " ",", all ;
local xrna : subinstr local xrna "|" " ", all ;
local count : word count `xrna';
tokenize "`xrna'";
forvalues i = 1/`count' {;
	local `i': subinstr local `i' "," "", all ;
	    local tmp = substr("``i''",1,30);
	    local rnam `"`rnam' "`tmp'""';
	
};
};
local matnames `aa' `bb' `cc' `dd' `ee' `ff' ;
local i = 1;
foreach name of local matnames {;

qui matrix colnames `name' = 
`ltmp_1' `ltmp_2' `ltmp_3' `ltmp_4'  `ltmp_5' `ltmp_6'  `ltmp_7' `ltmp_8'  `ltmp_9' `ltmp_10'   
`ltmp_11' `ltmp_12' `ltmp_13' `ltmp_14'  `ltmp_15' `ltmp_16'  `ltmp_17' `ltmp_18'  `ltmp_19' `ltmp_20' 
;
qui matrix rownames `name' = `rnam' ;
if (`mtrans' == 1) matrix `name' = `name'' ;

ereturn matrix res`i' = `name';
local i=`i' + 1;
};



end;    



capture program drop genjobginigr;
program define genjobginigr, eclass;
version 15;
syntax varlist(min=1)[, 
HSize(varname)  
GHSize(varlist)
HGROUP(varlist)
AEHS(varname)  
PCEXP(varname)
XRNAMES(string) 
SCOLNames(string)
LAN(string) 
STAT(string)
CHANGE(string)
MTRANS(int 0)
esheet(string) modrep(string) 
fexcel(string) etitle(string) eformat(string)
note1(string) note2(string) note3(string) note4(string)  note5(string) 
note6(string) note7(string) note8(string) note9(string)  note10(string)
note11(string) note12(string) note13(string) note14(string)  note15(string) 
note16(string) note17(string) note18(string) note19(string)  note20(string)  
dec1(int 2)
dec2(int 2)
];


version 15;
*set trace on;
preserve;

timer clear;
timer on 1;
if "`change'" == "" local change = "abs";
local rnam ;
if ("`xrnames'"~="") {;
local xrna  "`xrnames'" ;
local xrna : subinstr local xrna " " ",", all ; 
local xrna : subinstr local xrna "|" " ", all ;
local count : word count `xrna';
tokenize "`xrna'";
forvalues i = 1/`count' {;
	local `i': subinstr local `i' "," "", all ;
	    local j         = `i' + 1;
	    local lctmp_`i' = substr("``i''",1,30);
};
};


_nargs    `varlist';
local roma = $indica*6;
forvalues i =1/`roma' {;
	    local        j  =  `i' +  $indica;
	    local lctmp_`j' =  substr("`lctmp_`i''",1,30) ;
};


local cnam ;
if ("`scolnames'"~="") {;
local xcna  "`scolnames'" ;
local xcna : subinstr local xcna " " ",", all ; 
local xcna : subinstr local xcna "|" " ", all ;
local count : word count `xcna';
tokenize "`xcna'";
forvalues i = 1/`count' {;
	local `i': subinstr local `i' "," "", all ;
	    local j = `i' + 1;
	    local scname_`i' = substr("``i''",1,30);
};
};


tokenize `hgroup';
_nargs   `hgroup' ;
local nhgroups = $indica;
forvalues i=1/$indica {;
local hgroup_`i' = "``i''" ;    
};


tokenize  `pcexp' `varlist';
_nargs    `pcexp' `varlist';
local indica2 = $indica+1;


tokenize `varlist';
_nargs    `varlist';
local indica2 = $indica+2;



tempvar _ths;
qui gen  `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';

cap svy: total;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);


//set trace on ;
cap drop __hs*;
local nsgr = 0;
foreach var of varlist `ghsize' {;
local nsgr = `nsgr' +1;
qui gen __hs`nsgr' = `var';
};




forvalues i=1/`nhgroups' {;
forvalues j=1/`nsgr' {;
//set trace on ;
set tracedepth 2;
mbasicginigr `varlist' ,  hsize(__hs`j')    hgroup(`hgroup_`i'')  xrnames(`xrnames')   mtrans(0) change(`change');
forvalues s=1/6 {;
	//matrix list  e(res`s') ;
};

if `j' == 1 {;
matrix _ee_`i' = e(res1)';
matrix _aa_`i' = e(res3)';
matrix _bb_`i' = e(res6)';
};

if `j'>1 {;
matrix _ee_`i' = _ee_`i',e(res1)';
matrix _aa_`i' = _aa_`i',e(res3)';
matrix _bb_`i' = _bb_`i',e(res6)';
};


};
};
/*
matrix rr = _ee_1;
matrix list  rr;
matrix list _aa_1;
*/


forvalues i=1/`nhgroups' {;
forvalues j=1/`nsgr' {;

mbasicginigr `varlist' ,  hsize(__hs`j')   xrnames(`xrnames')  mtrans(0) change(`change');
if `j' == 1 {;
matrix _ee_pop = e(res1)';
matrix _aa_pop = e(res3)';
matrix _bb_pop = e(res6)';
};

if `j'>1 {;
matrix _ee_pop = _ee_pop,e(res1)';
matrix _aa_pop = _aa_pop,e(res3)';
matrix _bb_pop = _bb_pop,e(res6)';
};

};
};



#delimit cr



timer off  1
/* timer list 1 */
timer on   2
//qui {

local nrows = rowsof(_aa_1)
local ncols = colsof(_aa_1)




//set trace on 
local sign0 ""
local sign1 "*"
local sign2 "**"
local sign3 "***"

//} // end qui
local wowi = 12


local tnrows = 0
forvalues g=1/`nhgroups' { 
local nrows_`g' = rowsof(_aa_`g')
forvalues i=1/`nrows_`g'' {
forvalues j=1/`ncols' {

            local p  = (`j'-1)*2+2
if `j' != 1 local p  = (`j'-1)*2+1
local p1 = `p' + 1 

local tmp0 =  string(round(el(_ee_`g',`i',`j'),0.00001) , "%9.`dec1'f")
local coeff0 : display "`tmp0'"	

local tmp2  = el(_bb_`g',`i',`j')
                         
						local tmp1    =  string(round(el(_aa_`g',`i',`j'),0.00001) , "%12.`dec2'f")
if ("`change'"=="rel")  local tmp1    =  string(round(el(_aa_`g',`i',`j')*100,0.00001) , "%12.`dec2'f")
                        local coeff : display "`tmp1'""`sign`tmp2''"
if ("`change'"=="rel")  local coeff : display "`tmp1'%""`sign`tmp2''"	

local z  = `p'-1
local z1 = `p1'-1
local ma_`g'_`i'_`z' = "`coeff0'"
local ma_`g'_`i'_`z1' = "`coeff'" 
local wowi= max(`wowi', strlen("`coeff0'")+1 )
local wowi= max(`wowi', strlen("`coeff'")+1  )
}
}
local tnrows = `tnrows' + `nrows_`g'' + 1
}



local wfc = 10
local ma_pop_1_`z' = "`coeff0'"
local ma_pop_1_`z1' = "`coeff'" 
local wowi= max(`wowi', strlen("`coeff0'")+1 )
local wowi= max(`wowi', strlen("`coeff'")+1  )
forvalues g=1/`nhgroups' { 
qui levelsof `hgroup_`g'', local(mygr)
local mystr `r(levels)'
local i = 1
foreach x of local mygr {
local ngr `: word count `mystr''
local label : label (`hgroup_`g'') `x' 
if `"`label'"' == "" local label = "Group_`hgroup_`g''_`x'" 
local ltmp_`g'_`i' `"`label'"' 
local i = `i'+1
local wfc = max(`wfc', strlen("`label'")+1 )

}
}

local ltmp_pop `"Population"' 
local wfc = max(`wfc', 11 )



forvalues j=1/`ncols' {

            local p  = (`j'-1)*2+2
if `j' != 1 local p  = (`j'-1)*2+1
local p1 = `p' + 1 

local tmp0 =  string(round(el(_ee_pop,1,`j'),0.0000001) , "%12.`dec1'f")
local coeff0 : display "`tmp0'"	


	local tmp0 =  string(round(el(_ee_pop,1,`j'),0.0000001) , "%12.`dec1'f")
	local coeff0 : display "`tmp0'"	




local tmp2  = el(_bb_pop,1,`j')
                        local tmp1 =  string(round(el(_aa_pop,1,`j'),0.0000001) , "%12.`dec2'f")
if ("`change'"=="rel")  local tmp1    =  string(round(el(_aa_pop,1,`j')*100,0.00001) , "%12.`dec2'f")
                        local coeff : display "`tmp1'""`sign`tmp2''"
if ("`change'"=="rel")  local coeff : display "`tmp1'%""`sign`tmp2''"
	
local z  = `p'-1
local z1 = `p1'-1
local ma_pop_1_`z' = "`coeff0'"
local ma_pop_1_`z1' = "`coeff'" 
local wowi= max(`wowi', strlen("`coeff0'")+1 )
local wowi= max(`wowi', strlen("`coeff'")+1  )
/* dis `z' ":: `ma_pop_1_`z''  ::: "  el(_ee_pop,1,`j') */
}





//local tnrows = `tnrows' +  6
local rpr = 2*`ncols'-1
local pos = `tnrows'+1
local np  = `tnrows'
local fp =  2*`ncols'+1
local fp1 =  2*`ncols'



local tnrows = `tnrows' +  6
local rpr = (($indica-1)*2+1)*`nsgr'+1

local pos = `tnrows'+1
local np  = `tnrows'
local fp =  (($indica-1)*2+1)*`nsgr'+`nsgr'
local fp1 = (($indica-1)*2+1)*`nsgr'+1 


local xn = `ncols'+1
local xm = `ncols'/`nsgr'+1



/*
set trace on 
set tracedepth 1
*/

mata: file = st_local("fexcel")
mata: nc   = strtoreal(st_local("fp"))
mata: nr   = strtoreal(st_local("pos"))
mata: b=xl()

if ("`modrep'"=="replace") {
cap erase "`fexcel'.xlsx"
mata: b.create_book("`fexcel'", "`esheet'" , "xlsx", "locale")
}

if ("`modrep'"=="modify") {
mata: b.load_book(file)
capture mata: b.delete_sheet("`esheet'")
mata: b.add_sheet("`esheet'")
}
mata: b.set_sheet("`esheet'")
mata: b.set_mode("open")

mata: r =(2,`tnrows'+1)
mata: c =(2,`fp')
mata: b.set_font(r,c, "Cambria", 10 , "black")
mata: b.set_sheet_gridlines("`esheet'", "off")
mata: r =(2,5)
mata: c =(2,`tnrows'+1)
mata: b.set_font_bold(r,c, "on")
mata: b.put_string(1, 1,"`etitle'")
mata: b.set_font(1,1,"Cambria", 13)
mata: b.set_font_bold(1,1,"on")
mata: b.set_column_width(1, 1, `wfc')
local mylcol = "102 153 255"
local myfc1 =  "221 235 247"
local myfc2 =  "219 245 244"
local myfc3 =  "160 244 224"
mata: b.set_top_border((3,3), (1,`fp1'), "medium" , ("`mylcol'"))
mata: b.set_fill_pattern((3,3), (1,`fp1'), "solid", "`myfc3'" , "`myfc3'") 
mata: b.set_bottom_border((3,3), (1,`fp1'), "thin" , ("`mylcol'"))

mata: b.set_top_border((4,4), (1,`fp1'), "medium" , ("`mylcol'"))
mata: b.set_fill_pattern((4,4), (1,`fp1'), "solid", "`myfc1'" , "`myfc1'") 
mata: b.set_bottom_border((4,4), (1,`fp1'), "thin" , ("`mylcol'"))

mata: b.set_bottom_border((5,5), (1,`fp1'), "thin" , ("`mylcol'"))
mata: b.set_fill_pattern((5,5), (1,`fp1'), "solid", "`myfc2'" , "`myfc2'") 
mata: b.set_fill_pattern((`tnrows'+1,`tnrows'+1), (1,`fp1'), "solid", "`myfc2'" , "`myfc2'") 
mata: b.set_right_border((3,`tnrows'+1), (1,1), "thin" , ("`mylcol'"))
mata: b.set_top_border((`tnrows'+1,`tnrows'+1), (1,`fp1'), "thin" , ("`mylcol'"))
mata: b.set_bottom_border((`tnrows'+1,`tnrows'+1), (1,`fp1'), "medium" , ("`mylcol'"))


forvalues i=2/`np' {
mata: b.set_column_width(`i', `i' , `wowi') 
	 }
	 
mata: b.set_font((4,`tnrows'+1),(1,1), "Cambria", 10 , "black")	 
mata: b.set_font_bold((4,`tnrows'+1),(1,1), "on")	
mata: b.set_font_bold((`tnrows'+1,`tnrows'+1), (1,`fp1'), "on")	
mata: b.put_string(`pos'+1, 1 ,  "Notes:")
mata: b.set_number_format(`pos'+1, `fp1', "text")

mata: pos=6

forvalues g = 1/`nhgroups' { 
local gg = `g'
mata: b.put_string(pos, 1, "`hgroup_`g''")
mata: b.set_font(pos, 1,"Cambria", 11 , "blue")
mata: b.set_horizontal_align(pos, 1,"right")
mata: b.set_font_bold(pos, 1,"on")
mata: b.set_font_italic(pos, 1,"on")

mata: pos=pos+1
mata: g =strtoreal(st_local("gg")) 
local nrowsg = rowsof(_aa_`g')
forvalues i=1/`nrowsg'   {
mata: b.put_string(pos, 1,"`ltmp_`g'_`i''")  
local ii = `i'
mata: i =strtoreal(st_local("ii"))
local bar = 2+($indica-1)*2+1
local bar1 = `bar'-1


local fp2 = `fp'+1
forvalues j=1/`fp2'  {
if (`j'<`bar') {
local jj = `j'
mata: j =strtoreal(st_local("jj"))
mata: r = i+1
mata: c = j+1
mata: b.put_string(pos, c, st_local(sprintf("ma_%g_%g_%g", g, i , j )))
}

if (`j'>`bar'+1  & `j'<(2*`bar' )) {
local jj = `j'-1
mata: j =strtoreal(st_local("jj"))
mata: r = i+1
mata: c = j
mata: b.put_string(pos, c, st_local(sprintf("ma_%g_%g_%g", g, i , j )))
}


if (`j'>2*`bar'+1  & `j'<(3*`bar' )) {
local jj = `j'-2
mata: j =strtoreal(st_local("jj"))
mata: r = i+1
mata: c = j-1
mata: b.put_string(pos, c, st_local(sprintf("ma_%g_%g_%g", g, i , j )))
}

}
mata: pos=pos+1
}
}



mata: pos=pos+1
mata: b.put_string(pos, 1, "`ltmp_pop'")

forvalues j=1/`fp2'  {
if (`j'<`bar') {
local jj = `j'
mata: j =strtoreal(st_local("jj"))
mata: r = i+1
mata: c = j+1
mata: b.put_string(pos, c, st_local(sprintf("ma_pop_%g_%g", 1 , j )))
}

if (`j'>`bar'+1  & `j'<(2*`bar' )) {
local jj = `j'-1
mata: j =strtoreal(st_local("jj"))
mata: r = i+1
mata: c = j
mata: b.put_string(pos, c, st_local(sprintf("ma_pop_%g_%g", 1 , j )))
}


if (`j'>2*`bar'+1  & `j'<(3*`bar' )) {
local jj = `j'-2
mata: j =strtoreal(st_local("jj"))
mata: r = i+1
mata: c = j-1
mata: b.put_string(pos, c, st_local(sprintf("ma_pop_%g_%g", 1 , j )))
}

}






mata: b.put_string(3, 1 ,  "Populations")
mata: b.set_font(3,1, "Cambria", 12 , "black")
mata: b.set_horizontal_align(3,1,"right")
mata: b.set_font_bold(3,1,"on")

forvalues g=1/`nsgr' {
local v = 1+(`g'-1)*2*($indica-1)+`g'
mata: b.put_string(3, `v'        ,  "`scname_`g''")	
mata: b.set_font(3,`v', "Cambria", 12 , "black")
}



mata: b.set_sheet_merge("`esheet'", (3,3),(2,`fp'/3))
mata: b.set_sheet_merge("`esheet'", (3,3),(`fp'/3+1, 2*`fp'/3-1))
mata: b.set_sheet_merge("`esheet'", (3,3),(2*`fp'/3, `fp'-2))


mata: b.set_right_border((3,`tnrows'+1), (`fp'/3,`fp'/3), "thin" , ("`mylcol'"))
mata: b.set_right_border((3,`tnrows'+1), (2*`fp'/3-1,2*`fp'/3-1), "thin" , ("`mylcol'"))

mata: b.put_string(5, 1 ,  "Inter-groups:")
mata: b.set_font_italic(4,1,"on")
mata: b.put_string(`pos'+1, 1 ,  "Notes:")

mata: b.set_font(r,c, "Cambria", 10 , "black")


if ("`change'"=="rel") local arl = " (in %)"



forvalues i=5/`tnrows' {
local x = `i' - 4
forvalues j=1/`ncols' {
                   local p  = (`j'-1)*2+2
if `j' != 1        local p  = (`j'-1)*2+1
if `j' >=   `xm'+1 local p  = (`j'-1)*2
if `j' >= 2*`xm'   local p  = (`j'-1)*2-1
local p1 = `p' + 1 
if `i' == 5    {	

mata: b.put_string(4, `p' ,  "`lctmp_`j''")
mata: b.put_string(5, `p' ,  "Level")
mata: b.put_string(5, `p1',  "Change `arl'")
mata: b.set_left_border((4,`np'+1),(`p',`p') , "thin" , ("`mylcol'"))
/*if `j' != 1  & `j' != `xm' 	dis `p' " HHH " `p1' */
//mata: b.set_sheet_merge("`esheet'", (4,4),(`p',`p1'))
} 
}


}



local pos = `pos'+1

mata: b.put_string(`pos', 1 ,  "Notes:")
mata: b.set_font_bold(`pos',1,"on")

local pos = `pos'+1
mata: r =(`pos'-1,`pos'+20)
mata: c =(1,1)
mata: b.set_font(r,c, "Cambria", 11 , "black")
mata: r =(`pos' ,`pos'+20)
mata: c =(1,1)
mata: b.set_font(r,c, "Cambria", 9 , "black")


  
if ("`stat'"  == "mean" | "`stat'"  == "" ) local measu "average" 
if ("`stat'" == "total" ) local measu "total" 


mata: b.put_string(`pos', 1 , " [1]- The ginistic is the `measu'")
local pos = `pos'+1
mata: b.put_string(`pos', 1 , " [2]- Sympols of significance levels: * p<0.10, ** p<0.05, *** p<0.01")
local pos = `pos'+1
mata: b.put_string(`pos', 1 , " [3]- Significance levels: only reported for the ginistic -change-")

		forvalues i =1/20 {
		if ("`note`i''"~="") {
		local  j = `pos' + `i'+1
		mata: b.put_string(`j', 1, " - `note`i''")

	}
	}
	
mata: b.set_vertical_align((3,`tnrows'),(2,2*`ncols') , "center")
mata: b.set_horizontal_align((3,4),(2,2*`ncols') , "center")

mata: b.close_book()

set trace off
di as txt `"(output written to {browse "`fexcel'.xlsx""})"'  

restore

timer off 2
/*timer list 2 */


#delimit cr
end




