/********************************************************************************/
/*  Package       : USST //Usefull Stata Tools                                  */
/*  Version       :   0.10   //                       JUNE         2020         */
/*  Stata Version : Required  15.0 and higher                                   */
/*  Authors       : Abdelkrim Araar  // aabd@ecn.ulaval.ca                      */
/********************************************************************************/


#delimit ;
capture program drop mbasicstat;
program define mbasicstat, eclass;
syntax varlist(min=1) [, HSize(varname) HGROUP(varname)   DENOM(varname) XRNAMES(string) STAT(string) MTRANS(int 1) CHANGE(string) DIF1(int 0)];
preserve; 
tokenize `varlist';
_nargs   `varlist';
tempvar we ga0 ga10 ga1 hy;

if "`hsize'" == "" {;
tempvar hsize; qui g `hsize' = 1;
};


if "`hgroup'" == "" {;
tempvar hgroup; qui g `hgroup' = 1;
};

local hweight=""; 
cap qui svy: total `1'; 
local hweight=`"`e(wvar)'"';
cap ereturn clear; 
qui gen `we'=1;
if ("`hsize'"~="")      qui replace `we'=`we'*`hsize';
if ("`hweight'"~="")    qui replace `we'=`we'*`hweight';

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


tempname aa bb cc dd ee ;
matrix `aa' =J($indica,`ngr',.) ;
matrix `bb' =J($indica,`ngr',.) ;
matrix `cc' =J($indica,`ngr',.) ;
matrix `dd' =J($indica,`ngr',.) ;
matrix `ee' =J($indica,`ngr',.) ;


qui levelsof `hgroup', local(mygr);
local mystr `r(levels)';
local ngr `: word count `mystr'';
local i = 1;

foreach x of local mygr { ;
qui sum `1'   [aweight= `we']  if `hgroup' == `x';
matrix `aa'[1,`i'] = r(`stat');
if "`denom'" ~= "" {
qui sum `deno' [aweight= `we']    if `hgroup' == `x';
matrix `aa'[1,`i'] = `aa'[1,`i']/r(`stat');	
};
local label : label (`hgroup') `x' ;
if "`label'" == "" local label = "Group_`x'" ;
local ltmp_`x' `""`label'""' ;
local i = `i'+1 ;
};



forvalues s=2/$indica {;
local sp1 = `s' ;
tempvar  pcexp`s' ;
qui gen `pcexp`s'' = ``s'' ;
cap drop `nom_`i''
tempvar  nom_`i'
qui gen `nom_`i'' =  `hsize'*`pcexp`s'';


tempvar  di_`s';
qui gen `di_`s'' = `hsize'*(``s'' -`1') ;
/* local ctmp_1  `""Initial""' ; */
local i = 1;

foreach x of local mygr { ;
qui sum `pcexp`s''   [aweight= `we']  if `hgroup' == `x';
matrix `aa'[`sp1',`i'] = r(`stat');
if "`denom'" ~= "" {;
qui sum `deno' [aweight= `we']         if `hgroup' == `x';
matrix `aa'[1,`i'] = [`sp1',`i']/r(`stat');	
};
local i = `i' + 1;
};

};

matrix aaa = `aa'' ;

if (`dif1'==1) {;
tempvar vfirst;
qui gen `vfirst' = `hsize'*`1';

qui svydes;
local fr=`r(N_units)'-`r(N_strata)';

forvalues s=2/$indica {;
if("`change'" == "abs") {;
if ("`stat'"=="mean") qui svy: ratio   `di_`s''/`hsize'  , over(`hgroup');
if ("`stat'"=="sum")  qui svy: total  `di_`s'' , over(`hgroup');
if ("`denom'"~=""  )  qui svy: ratio  `di_`s''/`deno' , over(`hgroup');
};

if("`change'" == "rel") {;
if ("`stat'"=="mean") qui svy: ratio  `di_`s''/`vfirst' , over(`hgroup');
};
local sp1 = `s' ;
forvalues i=1/`ngr' {;
matrix `bb'[`sp1',`i'] = el(e(b),1,`i');
matrix `cc'[`sp1',`i'] = el(e(V),`i',`i')^0.5;
local tval = `bb'[`sp1',`i'] /`cc'[`sp1',`i'];
local pval = 1-2*(normal(abs(`tval'))-0.5);
matrix `dd'[`sp1',`i'] = `pval';
matrix `ee'[`sp1',`i'] = (`dd'[`sp1',`i']<=0.1)+(`dd'[`sp1',`i']<=0.05)+(`dd'[`sp1',`i']<=0.01);
};


};


forvalues s=2/$indica {;
local sp1 = `s' ;
if("`change'" == "abs") {;
if ("`stat'"=="mean") qui svy: mean  `di_`s'' ;
if ("`stat'"=="sum")  qui svy: total `di_`s'' ;
if ("`denom'"~=""  )  qui svy: ratio  `di_`s''/`deno'      ;
};
if("`change'" == "rel") {;

if ("`stat'"=="mean") qui svy: ratio  `di_`s''/`vfirst' ;
};

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
               local matnames `aa' ;
if `dif1' == 1 local matnames `aa' `bb' `cc' `dd' `ee' ;

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



capture program drop genjobstat;
program define genjobstat, eclass;
version 15;
syntax varlist(min=1)[, 
HSize(varname)  
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



tempvar _ths;
qui gen  `_ths'=1;
if ( "`hsize'"!="") qui replace `_ths'=`hsize';
if ( "`change'"=="") local change == abs;

cap svy: total;
if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
#delimit cr

forvalues i=1/`nhgroups' {
mbasicstat  `varlist' ,  hsize(`_ths')  hgroup(`hgroup_`i'') denom(`denom') xrnames(`xrnames') stat(`stat') mtrans(0) change(`change') dif1(`dif1')
#delimit cr
matrix _ee_`i' = e(res1)'
if (`dif1'==1) {
matrix _aa_`i' = e(res2)'
matrix _bb_`i' = e(res5)'
}
}


mbasicstat `varlist' ,  hsize(`_ths')  hgroup(``i'') denom(`denom') xrnames(`xrnames') stat(`stat') mtrans(0) change(`change')  dif1(`dif1')
#delimit cr
matrix _ee_pop = e(res1)'
if (`dif1'==1) {
matrix _aa_pop = e(res2)'
matrix _bb_pop = e(res5)'
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
if `j' != 1 local p  = (`j'-1)*2+1
local p1 = `p' + 1 
local tmp0 =  string(round(el(_ee_`g',`i',`j'),0.00001) , "%12.`dec1'f")
local coeff0 : display "`tmp0'"	
local tmp2  = el(_bb_`g',`i',`j')
local tmp1               =  string(round(el(_aa_`g',`i',`j'),0.00001) , "%12.`dec1'f")
if ("`change'"=="rel")  local tmp1    =  string(round(el(_aa_`g',`i',`j')*100,0.00001) , "%12.`dec2'f")+"%"
local coeff : display "`tmp1'""`sign`tmp2''"	
local z = `p'-1
local z1 = `p1'-1
local ma_`g'_`i'_`z' = "`coeff0'"
local ma_`g'_`i'_`z1' = "`coeff'" 
local wowi= max(`wowi', strlen("`coeff0'")+1 )
local wowi= max(`wowi', strlen("`coeff'")+1  )
}
}

if (`dif1'==0) {
forvalues j=1/`ncols' {
local tmp0 =  string(round(el(_ee_`g',`i',`j'),0.00001) , "%12.`dec1'f")
local coeff0 : display "`tmp0'"	
local ma_`g'_`i'_`j' = "`coeff0'"
local wowi= max(`wowi', strlen("`coeff0'")+1 )
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
if `j' != 1 local p  = (`j'-1)*2+1
local p1 = `p' + 1 
local tmp0 =  string(round(el(_ee_pop,1,`j'),0.00001) , "%12.`dec1'f")
local coeff0 : display "`tmp0'"	
local tmp2  = el(_bb_pop,1,`j')
local tmp1               =  string(round(el(_aa_pop,1,`j'),0.00001) , "%12.`dec2'f")
if ("`change'"=="rel")  local tmp1    =  string(round(el(_aa_pop,1,`j')*100,0.00001) , "%12.`dec2'f")+"%"
local coeff : display "`tmp1'""`sign`tmp2''"	
local z = `p'-1
local z1 = `p1'-1
local ma_pop_1_`z' = "`coeff0'"
local ma_pop_1_`z1' = "`coeff'" 
local wowi= max(`wowi', strlen("`coeff0'")+1 )
local wowi= max(`wowi', strlen("`coeff'")+1  )
}
}


if (`dif1'==0) {
forvalues j=1/`ncols' {
local tmp0 =  string(round(el(_ee_pop,1,`j'),0.00001) , "%12.`dec1'f")
local coeff0 : display "`tmp0'"	
local ma_pop_1_`j' = "`coeff0'"
local wowi= max(`wowi', strlen("`coeff0'")+1 )
}
}


local tnrows = `tnrows' +  6
local rpr = 2*`ncols'
local pos = `tnrows'+1
local np  = `tnrows'
               local  fp =    `ncols'+1
if `dif1' == 1 local  fp =  2*`ncols'

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
forvalues j=1/`fp'  {
local jj = `j'
mata: j =strtoreal(st_local("jj"))
mata: r = i+1
mata: c = j+1
mata: b.put_string(pos, c, st_local(sprintf("ma_%g_%g_%g", g, i , j )))
}
mata: pos=pos+1
}
}



mata: pos=pos+1
mata: b.put_string(pos, 1, "`ltmp_pop'")
forvalues j=1/`fp'  {
local jj = `j'
mata: j =strtoreal(st_local("jj"))
mata: c = j+1
mata: b.put_string(pos, c, st_local(sprintf("ma_pop_%g_%g", 1 , j )))
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
if (`dif1'==0) local p  = (`j'-1)  +2
if `j' != 1  & (`dif1'==1) local p  = (`j'-1)*2+1
local p1 = `p' + 1 
if `i' == 5   {	
mata: b.put_string(3, `p' ,  "`lctmp_`j''")

if (`dif1'==1) {
mata: b.put_string(4, `p' ,  "Level")
mata: b.put_string(4, `p1',  "Change `arl'")
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

 
