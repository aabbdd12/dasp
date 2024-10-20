/********************************************************************************/
/*  Package       : USST //Usefull stat2gra Tools                                  */
/*  Version       :   0.10   //                       JUNE         2020         */
/*  stat2gra Version : Required  15.0 and higher                                   */
/*  Authors       : Abdelkrim Araar  // aabd@ecn.ulaval.ca                      */
/********************************************************************************/


#delimit ;
capture program drop mbasicstatgr;
program define mbasicstatgr, eclass;
syntax varlist(min=1 max=1) [, HSize1(varname) HSize2(varname) HGROUP(varname)   DENOM(varname) XRNAMES(string) stat(string) MTRANS(int 1) CHANGE(string) DIF1(int 0)];
preserve; 
tokenize `varlist';
_nargs   `varlist';
tempvar we1 we2 ga0 ga10 ga1 hy;

if "`hsize1'" == "" {;
tempvar hsize1; qui g `hsize1' = 1;
};


if "`hsize2'" == "" {;
tempvar hsize2; qui g `hsize2' = 1;
};

if "`hgroup'" == "" {;
tempvar hgroup; qui g `hgroup' = 1;
};

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
qui gen `we1'=1;
qui gen `we2'=1;
if ("`hsize1'"~="")      qui replace `we1'=`we1'*`hsize1';
if ("`hsize2'"~="")      qui replace `we2'=`we2'*`hsize2';
if ("`hweight'"~="")     qui replace `we1'=`we1'*`hweight';
if ("`hweight'"~="")     qui replace `we2'=`we2'*`hweight';

if "`stat'" == "" local stat = "mean";


if "`denom'" ~= "" {;
cap drop `deno';
tempvar  deno;
qui gen `deno' = `hsize'*`denom';
} ;

qui levelsof `hgroup', local(mygr);
local mystr `r(levels)';
local ngr `: word count `mystr'';
local ngr1 = `ngr' ;


tempname aa1 aa2 bb cc dd ee ;
matrix `aa1' =J(1,`ngr',.) ;
matrix `aa2' =J(1,`ngr',.) ;
matrix `bb' =J(1,`ngr',.) ;
matrix `cc' =J(1,`ngr',.) ;
matrix `dd' =J(1,`ngr',.) ;
matrix `ee' =J(1,`ngr',.) ;

qui svydes;
local fr=`r(N_units)'-`r(N_strata)';

qui levelsof `hgroup', local(mygr);
local mystr `r(levels)';
local ngr `: word count `mystr'';
local i = 1;

foreach x of local mygr { ;
if ("`stat'" == "mean") {;
qui sum `1'   [aweight= `we1']     if `hgroup' == `x';
matrix `aa1'[1,`i'] = r(`stat');
qui sum `1'   [aweight= `we2']     if `hgroup' == `x';
matrix `aa2'[1,`i'] = r(`stat');
};

if ("`stat'" == "prop") {;
qui sum `we1'    if `hgroup' == `x'; local m1= `r(sum)' ;
qui sum `we1'                      ; local m2= `r(sum)' ;
matrix `aa1'[1,`i'] = `m1'/`m2'*100;
qui sum `we2'    if `hgroup' == `x'; local m1= `r(sum)' ;
qui sum `we2'                      ; local m2= `r(sum)' ;
matrix `aa2'[1,`i'] = `m1'/`m2'*100;
};

local label : label (`hgroup') `x' ;
local label = subinstr("`label'", "." , "_" , .) ;
if "`label'" == "" local label = "Group_`x'" ;
local ltmp_`x' `""`label'""' ;

tempvar  me1 me2 hs1 hs2 ;

if ("`stat'" == "mean") {;
qui gen `me1' = `hsize1'*(`1')*(`hgroup' == `x')  ;
qui gen `me2' = `hsize2'*(`1')*(`hgroup' == `x')   ;
qui gen `hs1' = `hsize1'*(`hgroup' == `x')  ;
qui gen `hs2' = `hsize2'*(`hgroup' == `x')   ;
};
if ("`stat'" == "prop") {;
qui gen `me1' = `hsize1'*(`hgroup' == `x')  ;
qui gen `me2' = `hsize2'*(`hgroup' == `x')   ;
qui gen `hs1' = `hsize1'  ;
qui gen `hs2' = `hsize2'  ;
};
qui svy :  mean  `me1' `hs1'  `me2'  `hs2' ;
qui nlcom (_b[`me1']/_b[`hs1']) - (_b[`me2']/_b[`hs2']), iterate(50000);
matrix `bb'[1,`i'] = `aa1'[1,`i']-`aa2'[1,`i'];
matrix `cc'[1,`i'] = el(e(V),`i',`i')^0.5;
local tval = `bb'[1,`i'] /`cc'[1,`i'];
local pval = 1-2*(normal(abs(`tval'))-0.5);
matrix `dd'[1,`i'] = `pval';
matrix `ee'[1,`i'] = (`dd'[1,`i']<=0.1)+(`dd'[1,`i']<=0.05)+(`dd'[1,`i']<=0.01);

local i = `i'+1 ;


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
               local matnames `aa1' `aa2' ;
if `dif1' == 1 local matnames `aa1' `aa2' `aa' `bb' `cc' `dd' `ee' ;

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




capture program drop genjobstatgr;
program define genjobstatgr, eclass;
version 15;
syntax varlist(min=1)[, 
hsize1(varname) 
hsize2(varname)   
HGROUP(varlist)
DENOM(varname)
XRNAMES(string) 
LAN(string) 
STAT(string)
MTRANS(int 0)
esheet(string) modrep(string) 
fexcel(string) etitle(string) eformat(string)
note1(string) note2(string) note3(string) note4(string)  note5(string) 
note6(string) note7(string) note8(string) note9(string)  note10(string) 
note11(string) note12(string) note13(string) note14(string)  note15(string) 
note16(string) note17(string) note18(string) note19(string)  note20(string)  
CHANGE(string)
dec1(int 2)
dec2(int 2)
DIF1(int 0)
GRT1(string)
GRT2(string)
];


version 15;
*set trace on;
preserve;

timer clear;
timer on 1;

local rnam ;
local lctmp_1 "" ;

if ("`xrnames'"~="") {;
local xrna  "`xrnames'" ;
local xrna : subinstr local xrna " " ",", all ; 
local xrna : subinstr local xrna "|" " ", all ;
local count : word count `xrna';
tokenize "`xrna'";
forvalues i = 1/`count' {;
	local `i': subinstr local `i' "," "", all ;
	    local lctmp_`i' = substr("``i''",1,30);
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



tempvar _ths1 _ths2 ;
qui gen  `_ths1'=1;
qui gen  `_ths2'=1;
if ( "`hsize1'"!="") qui replace `_ths1'=`hsize1';
if ( "`hsize2'"!="") qui replace `_ths2'=`hsize2';
if ( "`change'"=="") local change = abs;

cap svy: total;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
#delimit cr

forvalues i=1/`nhgroups' {
mbasicstatgr  `varlist' ,  hsize1(`_ths1') hsize2(`_ths2') hgroup(`hgroup_`i'') denom(`denom') xrnames(`xrnames') stat(`stat') mtrans(0) change(`change') dif1(`dif1')
#delimit cr
matrix _ee1_`i' = e(res1)'
matrix _ee2_`i' = e(res2)'
if (`dif1'==1) {
matrix _aa_`i' = e(res3)'
matrix _bb_`i' = e(res6)'
}
}


mbasicstatgr `varlist' ,  hsize1(`_ths1')  hsize2(`_ths2') hgroup(``i'') denom(`denom') xrnames(`xrnames') stat(`stat') mtrans(0) change(`change')  dif1(`dif1')
#delimit cr
matrix _ee1_pop = e(res1)'
matrix _ee2_pop = e(res2)'
if (`dif1'==1) {
matrix _aa_pop = e(res3)'
matrix _bb_pop = e(res6)'
}


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
/*
local p1=  1
local p2=  `posl' +1
local p3 = `posl' +2
local p4 = `posl' +3
local p5 = `posl' +4
local np = `p4'  +`nrows'+1
local np1 = `np'  -1
local  fp = `ip' + 2*`ncols'
local tnrows = `nrows'+4

*/

local tnrows = 0
forvalues g=1/`nhgroups' { 

local nrows_`g' = rowsof(_aa_`g')
forvalues i=1/`nrows_`g'' {
if (`dif1'==1) {
forvalues j=1/`ncols' {
local p  = (`j'-1)*2+2
local p1 = `p' + 1 
local p2 = `p' + 2
 
local tmp0 =  string(round(el(_ee1_`g',`i',`j'),0.00001) , "%12.`dec1'f")
local coeff01 : display "`tmp0'"	
local tmp0 =  string(round(el(_ee2_`g',`i',`j'),0.00001) , "%12.`dec1'f")
local coeff02 : display "`tmp0'"	
local tmp2  = el(_bb_`g',`i',`j')
local tmp1               =  string(round(el(_aa_`g',`i',`j'),0.00001) , "%12.`dec1'f")
if ("`change'"=="rel")  local tmp1    =  string(round(el(_aa_`g',`i',`j')*100,0.00001) , "%12.`dec2'f")+"%"
local coeff : display "`tmp1'""`sign`tmp2''"	

local z = `p'-1

local ma1_`g'_`i'_`z'  = "`coeff01'"
local ma2_`g'_`i'_`z' = "`coeff02'"
local ma3_`g'_`i'_`z' = "`coeff'" 
local wowi= max(`wowi', strlen("`coeff0'")+1 )
local wowi= max(`wowi', strlen("`coeff'")+1  )
}
}

}
local tnrows = `tnrows' + `nrows_`g'' + 1
}



local wfc = 10
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
 

if (`dif1'==1) {
forvalues j=1/`ncols' {
local p  = (`j'-1)*2+2
local p1 = `p' + 1 
local p2 = `p' + 2
local tmp0 =  string(round(el(_ee1_pop,1,`j'),0.00001) , "%12.`dec1'f")
local coeff01 : display "`tmp0'"	
local tmp0 =  string(round(el(_ee2_pop,1,`j'),0.00001) , "%12.`dec1'f")
local coeff02 : display "`tmp0'"	
local tmp2  = el(_bb_pop,`i',`j')
local tmp1               =  string(round(el(_aa_pop,1,`j'),0.00001) , "%12.`dec2'f")
if ("`change'"=="rel")  local tmp1    =  string(round(el(_aa_pop,1,`j')*100,0.00001) , "%12.`dec2'f")+"%"
local coeff : display "`tmp1'""`sign`tmp2''"	
local z = `p'-1

local ma1_pop_1_`z'  = "`coeff01'"
local ma2_pop_1_`z' =  "`coeff02'"
local ma3_pop_1_`z' = "`coeff'" 
local wowi= max(`wowi', strlen("`coeff0'")+1 )
local wowi= max(`wowi', strlen("`coeff'")+1  )
/*dis `j' " "`z' " " `ma1_pop_`i'_`z'' " "  `ma2_pop_`i'_`z'' " "  `ma3_pop_`i'_`z'' */
}
}




local tnrows = `tnrows' +  6
local rpr = 2*`ncols'
local pos = `tnrows'+1
local np  = `tnrows'
               local  fp =    `ncols'+1
if `dif1' == 1 local  fp =  4 ///2*`ncols'

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
capture mata: b.clear_sheet("`esheet'")
capture mata: b.add_sheet("`esheet'")
}
mata: b.set_sheet("`esheet'")
mata: b.set_mode("open")

mata: r =(2,`tnrows')
mata: c =(2,`fp')
mata: b.set_font(r,c, "Cambria", 10 , "black")
mata: b.set_sheet_gridlines("`esheet'", "off")
mata: r =(2,4)
mata: c =(2,`tnrows')
mata: b.set_font_bold(r,c, "on")
mata: b.put_string(1, 1,"`etitle'")
mata: b.set_font(1,1,"Cambria", 13)
mata: b.set_font_bold(1,1,"on")
mata: b.set_column_width(1, 1, `wfc')
local mylcol = "102 153 255"
local myfc1 =  "221 235 247"
local myfc2 =  "219 245 244"
mata: b.set_top_border((3,3), (1,`fp'), "medium" , ("`mylcol'"))
mata: b.set_fill_pattern((3,3), (1,`fp'), "solid", "`myfc1'" , "`myfc1'") 
mata: b.set_bottom_border((3,3), (1,`fp'), "thin" , ("`mylcol'"))
mata: b.set_bottom_border((4,4), (1,`fp'), "thin" , ("`mylcol'"))
mata: b.set_fill_pattern((4,4), (1,`fp'), "solid", "`myfc2'" , "`myfc2'") 
mata: b.set_fill_pattern((`tnrows',`tnrows'), (1,`fp'), "solid", "`myfc2'" , "`myfc2'") 
mata: b.set_right_border((3,`tnrows'), (1,1), "thin" , ("`mylcol'"))
mata: b.set_top_border((`tnrows',`tnrows'), (1,`fp'), "thin" , ("`mylcol'"))
mata: b.set_bottom_border((`tnrows',`tnrows'), (1,`fp'), "medium" , ("`mylcol'"))

forvalues i=2/`np' {
mata: b.set_column_width(`i', `i' , `wowi') 
	 }
mata: b.set_font((3,`tnrows'),(1,1), "Cambria", 10 , "black")	 
mata: b.set_font_bold((3,`tnrows'),(1,1), "on")	
mata: b.set_font_bold((`tnrows',`tnrows'), (1,`fp'), "on")	
mata: b.put_string(`pos', 1 ,  "Notes:")
mata: b.set_number_format(`pos', `fp', "text")


mata: pos=5
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
forvalues j=1/1  {
local jj = `j'
mata: j =strtoreal(st_local("jj"))
mata: r = i+1
mata: c = j+1
mata: c1 = c+1
mata: c2 = c1+1


mata: b.put_string(pos,  c, st_local(sprintf("ma1_%g_%g_%g", g, i , j )))
mata: b.put_string(pos, c1, st_local(sprintf("ma2_%g_%g_%g", g, i , j )))
mata: b.put_string(pos, c2, st_local(sprintf("ma3_%g_%g_%g", g, i , j )))
}
mata: pos=pos+1
}
}



mata: pos=pos+1
mata: b.put_string(pos, 1, "`ltmp_pop'")
forvalues j=1/1  {
local jj = `j'
mata: j =strtoreal(st_local("jj"))
mata: c = j+1
mata: c1 = c+1
mata: c2 = c1+1

mata: b.put_string(pos, c,   st_local(sprintf("ma1_pop_%g_%g", 1 , 1 )))
mata: b.put_string(pos, c1,  st_local(sprintf("ma2_pop_%g_%g", 1 , 1 )))
mata: b.put_string(pos, c2,  st_local(sprintf("ma3_pop_%g_%g", 1 , 1 )))
}


mata: b.put_string(4, 1 ,  "Groups:")
mata: b.set_font_italic(4,1,"on")
mata: b.put_string(`pos', 1 ,  "Notes:")

mata: b.set_font(r,c, "Cambria", 10 , "black")


if ("`change'"=="rel") local arl = " (in %)"


forvalues i=5/`tnrows' {
local x = `i' - 4
forvalues j=1/`ncols' {
               local p  = (`j'-1)*2+2
if `j' != 1  & (`dif1'==1) local p  = (`j'-1)*2+1
local p1 = `p' + 2 
if `i' == 5   {	
mata: b.put_string(3, `p' ,  "`lctmp_`j''")

if (`dif1'==1) {
mata: b.put_string(4, 2 ,  "`grt1'")
mata: b.put_string(4, 3 ,  "`grt2'")
mata: b.put_string(4, 4,  "Change `arl'")
mata: b.set_left_border((3,`np'),(`p',`p') , "thin" , ("`mylcol'"))
}
}

if (`dif1'==1) {
if `j' != 1 & `i' == 5  {
mata: b.set_sheet_merge("`esheet'", (3,3),(`p',`p1'))
} 
}
}
}

mata: b.put_string(`pos', 1 ,  "Notes:")
mata: b.set_font_bold(`pos',1,"on")


if (`dif1'==1) local pos = `pos'+1
mata: r =(`pos',`pos'+20)
mata: c =(1,1)
mata: b.set_font(r,c, "Cambria", 9 , "black")

if ("`stat'"  == "mean" | "`stat'"  == "" ) local measu "average" 
if ("`stat'" == "total" ) local measu "total" 
if ("`stat'" == "ratio" ) local measu "ratio" 

mata: b.put_string(`pos', 1 , " [1]- The statistic is the `measu'")
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
	
mata: b.set_vertical_align((3,`tnrows'),(2,`fp') , "center")
mata: b.set_horizontal_align((3,4),(2,`fp') , "center")

mata: b.close_book()
set trace off
di as txt `"(output written to {browse "`fexcel'.xlsx""})"'  

restore

timer off 2
/*timer list 2 */




#delimit cr
end


/*
genjobstat2gr dtot_deflated , hsize1(hsize1) hsize2(hsize2)  hgroup(gra) dif(1)  ///
etitle("My title") esheet(Maysheet)  fexcel("Myexcel")      modrep(replace) stat(mean) dif1(1)) 
*/