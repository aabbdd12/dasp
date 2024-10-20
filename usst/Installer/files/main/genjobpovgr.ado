/********************************************************************************/
/*  Package       : USST //Usefull Stata Tools                                  */
/*  Version       :   0.10   //                       JUNE         2020         */
/*  Stata Version : Required  15.0 and higher                                   */
/*  Authors       : Abdelkrim Araar  // aabd@ecn.ulaval.ca                      */
/********************************************************************************/


#delimit ;



capture program drop mbasicpovgr;
program define mbasicpovgr, eclass;
syntax varlist(min=1) [, HSize(varname)  HGROUP(varname) AEHS(varname)  PLINE(varname)  ALpha(real 0) XRNAMES(string) TOT(int 0) MTRANS(int 1) CHANGE(string)];
preserve; 

tokenize `varlist';
_nargs   `varlist';
tempvar we ga0 ga10 ga1 hy;


if "`aehs'" == "" {;
tempvar aehs; qui g `aehs' = `hsize';
};



if "`hgroup'" == "" {;
tempvar hgroup; qui g `hgroup' = 1;
};

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
qui gen `we'=1;
if ("`hweight'"~="")    qui replace `we'=`we'*`hweight';


if "`stat'" == "" local stat = "exp_tt";

gen `ga0'  = 0;
gen `ga10' = 0;
gen `ga1'  = 0;
qui levelsof `hgroup', local(mygr);
local mystr `r(levels)';
local ngr `: word count `mystr'';
local ngr1 = `ngr' ;

tempname aa bb cc dd ee ;
matrix `aa' =J($indica,`ngr1',.) ;
matrix `bb' =J($indica,`ngr1',.) ;
matrix `cc' =J($indica,`ngr1',.) ;
matrix `dd' =J($indica,`ngr1',.) ;
matrix `ee' =J($indica,`ngr1',.) ;

tokenize `varlist' ;
tempvar pcexp;
qui gen `pcexp' = `1' ; 
tempvar apcexp;
                     qui gen     `apcexp' = `pcexp' ;
if ("`aehs'" ~= "" ) qui replace `apcexp' = `pcexp' *`hsize'/`aehs' ;

if (`alpha'==0 | `tot'==1)              qui replace `ga0' = `hsize'*(`pline'>`apcexp');
if (`alpha'~=0 & `tot'!=1)              qui replace `ga0' = `hsize'*((`pline'-`apcexp')/`pline')^`alpha' if (`pline'>`apcexp');

qui levelsof `hgroup', local(mygr);
local mystr `r(levels)';
local ngr `: word count `mystr'';
local i = 1;

foreach x of local mygr { ;
qui sum `hsize' [aweight= `we']  if `hgroup' == `x';
local denom = r(mean);
qui sum `ga0'   [aweight= `we']  if `hgroup' == `x';
matrix `aa'[1,`i'] = r(mean)/`denom';
local label : label (`hgroup') `x' ;
if "`label'" == "" local label = "Group_`x'" ;
local ltmp_`x' `""`label'""' ;
if (`tot'==1) {;
matrix `aa'[1,`i'] = r(sum);
};
local i = `i'+1 ;
};



tokenize `varlist' ;
forvalues s=2/$indica {;
local sp1 = `s' ;
tempvar apcexp`s' ;
qui gen `apcexp`s'' = ``s''*`hsize'/`aehs' ;
if (`alpha'==0 | `tot'==1) qui replace `ga1' = `hsize'*(`pline'>`apcexp`s'');
if (`alpha'~=0 & `tot'!=1) qui replace `ga1' = `hsize'*((`pline'-`apcexp`s'')/`pline')^`alpha' if (`pline'>`apcexp`s'');

tempvar ga10_`s';
qui gen `ga10_`s'' = `ga1'-`ga0';
loca ctmp_1  ;
local i = 1;
foreach x of local mygr { ;
qui sum `hsize' [aweight= `we'] if `hgroup' == `x';
local denom = r(mean);
qui sum `ga1' [aweight= `we']  if `hgroup' == `x';;
matrix `aa'[`sp1',`i'] = r(mean)/`denom';
if (`tot'==1) {;
matrix `aa'[`sp1',`i'] = r(sum);
};

local i = `i' + 1;
};

};



qui svydes;
local fr=`r(N_units)'-`r(N_strata)';

forvalues s=2/$indica {;
if ("`change'" == "abs") {;
if (`tot' !=1 ) qui svy: ratio `ga10_`s'' / `hsize' , over(`hgroup');
if (`tot' ==1 ) qui svy: total `ga10_`s''           , over(`hgroup');
};

if ("`change'" == "rel") {;
 qui svy: ratio `ga10_`s'' / `ga0' , over(`hgroup');
};

local sp1 = `s' ;
forvalues i=1/`ngr' {;
matrix `bb'[`sp1',`i'] = el(e(b),1,`i');
matrix `cc'[`sp1',`i'] = el(e(V),`i',`i')^0.5;
local tval = `bb'[`sp1',`i'] /`cc'[`sp1',`i'];
local pval = 1-2*(normal(abs(`tval'))-0.5);
matrix `dd'[`sp1',`i'] = `pval';
matrix `ee'[`sp1',`i'] = (`dd'[`sp1',`i']<=0.1)+(`dd'[`sp1',`i']<=0.05)+(`dd'[`sp1',`i']<=0.01);
/* dis `i' " : " el(e(b),1,`i')  " : "  el(e(V),`i',`i')^0.5 ; */
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
local matnames `aa' `bb' `cc' `dd' `ee' ;
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



capture program drop genjobpovgr;
program define genjobpovgr, eclass;
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
ALPHA(real 0)
pline(varname)
CHANGE(string)
TOT(int 0)
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
	    local j = `i' + 1;
	    local lctmp_`i' = substr("``i''",1,30);
};
};


_nargs    `varlist';
local roma = $indica*6;
forvalues i =1/`roma' {;
	    local j = `i' + $indica;
	    local lctmp_`j' = substr("`lctmp_`i''",1,30) ;
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


forvalues j=1/`nsgr' {;
forvalues i=1/`nhgroups' {;

//set trace on ;
set tracedepth 2;
mbasicpovgr `varlist' ,  hsize(__hs`j')    hgroup(`hgroup_`i'') alpha(`alpha') pline(`pline')  xrnames(`xrnames') tot(`tot') mtrans(0) change(`change');
if `j' == 1 {;
matrix _ee_`i' = e(res1)';
matrix _aa_`i' = e(res2)';
matrix _bb_`i' = e(res5)';
};

if `j'>1 {;
matrix _ee_`i' = _ee_`i',e(res1)';
matrix _aa_`i' = _aa_`i',e(res2)';
matrix _bb_`i' = _bb_`i',e(res5)';
};


};
mbasicpovgr `varlist' ,  hsize(__hs`j')   alpha(`alpha') pline(`pline')  xrnames(`xrnames') tot(`tot') mtrans(0) change(`change') ;
if `j' == 1 {;
matrix _ee_pop = e(res1)';
matrix _aa_pop = e(res2)';
matrix _bb_pop = e(res5)';
};

if `j'>1 {;
matrix _ee_pop = _ee_pop,e(res1)';
matrix _aa_pop = _aa_pop,e(res2)';
matrix _bb_pop = _bb_pop,e(res5)';
};

};
/*
matrix rr = _ee_pop';
matrix list  rr;
*/


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

if `alpha'==0 & `tot' == 0 {
	local tmp0 =  string(round(el(_ee_`g',`i',`j')*100,0.0000001) , "%9.`dec1'f")
	local coeff0 : display "`tmp0'%"	
}

if `alpha'!=0  {
	local tmp0 =  string(round(el(_ee_`g',`i',`j'),0.0000001) , "%9.`dec1'f")
	local coeff0 : display "`tmp0'%"	
}


if `tot' == 1 {
	local tmp0 =  string(round(el(_ee_`g',`i',`j'),0.0000001) , "%12.0f")
	local coeff0 : display "`tmp0'"	
}

local tmp2  = el(_bb_`g',`i',`j')
local tmp1 =  string(round(el(_aa_`g',`i',`j'),0.0000001) , "%9.`dec2'f")
local coeff : display "`tmp1'%""`sign`tmp2''"

if `alpha'==0 & `tot' == 0 {
	local tmp1 =  string(round(el(_aa_`g',`i',`j')*100,0.0000001) , "%9.`dec2'f")
	local coeff : display "`tmp1'%""`sign`tmp2''"
}  

if `alpha'!=0  {
	local tmp1 =  string(round(el(_aa_`g',`i',`j'),0.0000001) , "%9.`dec2'f")
	local coeff : display "`tmp1'%""`sign`tmp2''"
}  


if `tot' == 1 {
	local tmp1 =  string(round(el(_aa_`g',`i',`j'),0.0000001) , "%12.0f")
	local coeff : display "`tmp1'""`sign`tmp2''"
}  
	
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

local tmp0 =  string(round(el(_ee_pop,1,`j'),0.00001) , "%9.`dec1'f")
local coeff0 : display "`tmp0'"	

if `alpha'==0 & `tot' == 0 {
	local tmp0 =  string(round(el(_ee_pop,1,`j')*100,0.0000001) , "%9.`dec1'f")
	local coeff0 : display "`tmp0'%"	
}

if `alpha'!=0  {
	local tmp0 =  string(round(el(_ee_pop,1,`j'),0.0000001) , "%9.`dec1'f")
	local coeff0 : display "`tmp0'%"	
}


if `tot' == 1 {
	local tmp0 =  string(round(el(_ee_pop,1,`j'),0.0000001) , "%12.0f")
	local coeff0 : display "`tmp0'"	
}

local tmp2  = el(_bb_pop,1,`j')
local tmp1 =  string(round(el(_aa_pop,1,`j'),0.0000001) , "%9.`dec2'f")
local coeff : display "`tmp1'%""`sign`tmp2''"

if `alpha'==0 & `tot' == 0 {
	local tmp1 =  string(round(el(_aa_pop,1,`j')*100,0.0000001) , "%9.`dec2'f")
	local coeff : display "`tmp1'%""`sign`tmp2''"
}  

if `alpha'!=0  {
	local tmp1 =  string(round(el(_aa_pop,1,`j'),0.0000001) , "%9.`dec2'f")
	local coeff : display "`tmp1'%""`sign`tmp2''"
}  


if `tot' == 1 {
	local tmp1 =  string(round(el(_aa_pop,1,`j'),0.0000001) , "%12.0f")
	local coeff : display "`tmp1'""`sign`tmp2''"
}  
	
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


                   local measu "headcout" 
if (`alpha' == 1 ) local measu "poverty gap" 
if (`alpha' == 2 ) local measu "squared poverty gap" 
if (`tot'   == 1 ) local measu "number of total poors" 
mata: b.put_string(`pos', 1 , " [1]- Poverty measurement is the `measu'")
local pos = `pos'+1
mata: b.put_string(`pos', 1 , " [2]- Sympols of significance levels: * p<0.10, ** p<0.05, *** p<0.01")
local pos = `pos'+1
mata: b.put_string(`pos', 1 , " [3]- Significance levels: only reported for the statistic -change-")

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





