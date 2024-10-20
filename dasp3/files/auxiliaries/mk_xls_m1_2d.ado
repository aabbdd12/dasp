

/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : mk_xtab_m1                                                  */
/*************************************************************************/


#delimit ;
capture program drop mk_xls_m1_2d;
program define mk_xls_m1_2d, rclass;
version 15.0;
syntax namelist(min=1)[,   DF1(int 1)   LEVEL(int 95)  CONF(string) hgroup(namelist)
dec1(int 4)   dec2(int 4)   dec3(int 4)   dec4(int 4) dec5(int 4)   dec6(int 4) 
pop(int 1) gro(int 1) dste(int 0)
xfil(string) xshe(string) xtit(string)  xlan(string) hsep(int 0) note(string)  modrep(string) FCNAME(string) eformat(string)
note1(string) note2(string) note3(string) note4(string)  note5(string) 
note6(string) note7(string) note8(string) note9(string)  note10(string)
note11(string) note12(string) note13(string) note14(string)  note15(string) 
note16(string) note17(string) note18(string) note19(string)  note20(string)  
dislink(int 1)
perclast(int 1)
FILE1(string) FILE2(string) 
];


tokenize "`xfil'" ,  parse(".");
local xfil = "`1'";

preserve ;
local ddep=0;
local nvars = 1;
if ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) local ddep=1;


if "`file1" ~="" & `ddep' == 0 { ;
qui use "`file1'", replace; 
};


tokenize `namelist';
if "`conf'" == "" local conf = "ts" ;

if "`level'" == "" local level = 95 ; 
if "`modrep'" == ""  local modrep = "replace" ;             
tokenize `namelist' ;
local nmat: word count `namelist' ;
tabstr `namelist', dec1(`dec1')   dec2(`dec2')   dec3(`dec3')   dec4(`dec4') dec5(`dec5')   dec6(`dec6') ;

local wic1=max(r(wic1), r(wic3), r(wic5))+2 ;

//set trace on ;
if ("`hgroup'" ~= "")  {;
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

if  ("`hgroup'" == "")  local wfc = 11;
local ltmp_pop `"Population"' ;
local wfc = max(`wfc', 11 );




if ("`conf'"=="") local conf="ts";
if ("`conf'"!="ts")   local lvl = (1-(100-`level')/100);
if ("`conf'"=="ts")   local lvl = (1-(100-`level')/200);
 /*local lvl = (1-(100-`level')/100);*/

/* Display table of mean, std err, etc. */

if `gro'==1 local crtit = "Population groups" ;

#delimit cr

//qui {


mata: file = st_local("xfil")
mata: nc   = strtoreal(st_local("fp"))
mata: nr   = strtoreal(st_local("pos"))
mata: b=xl()

if ("`modrep'"=="replace") {
cap erase "`xfil'.xlsx"
mata: b.create_book("`xfil'", "`xshe'" , "xlsx", "locale")
}

if ("`modrep'"=="modify") {
mata: b.load_book(file)
capture mata: b.clear_sheet("`xshe'")
capture mata: b.add_sheet("`xshe'")
}
mata: b.set_sheet("`xshe'")
mata: b.set_mode("open")

tokenize `namelist'
local tnrows = 2
forvalues i=1/`nmat' {
	local tnrows = `tnrows' + rowsof(``i'') + 2
}

if `pop' == 1 & `gro' == 1  local tnrows = `tnrows'  -1 
local fp = 9
mata: r =(2,`tnrows')
mata: c =(2,`fp')
mata: b.set_font(r,c, "Cambria", 10 , "black")
mata: b.set_sheet_gridlines("`xshe'", "off")
mata: r =(2,4)
mata: c =(2,`tnrows')
mata: b.set_font_bold(r,c, "on")
mata: b.put_string(1, 1,"`xtit'")
mata: b.set_font(1,1,"Cambria", 13)
mata: b.set_font_bold(1,1,"on")
mata: b.set_column_width(1, 1, `wfc')
mata: b.set_column_width(2, 5, `wic1' )
mata: b.set_column_width(6, 7, 10 )
mata: b.set_column_width(8, 9, `wic1' )


local mylcol = "102 153 255"
local myfc1 =  "221 235 247"
local myfc2 =  "219 245 244"
local myfc3 =  "243 250 255"
mata: b.set_top_border((3,3), (1,`fp'), "medium" , ("`mylcol'"))
mata: b.set_bottom_border((3,3), (1,`fp'), "thin" , ("`mylcol'"))

if (`gro') == 1 {	
mata: b.set_fill_pattern((3,3), (1,`fp'), "solid", "`myfc1'" , "`myfc1'") 
}
if `pop'==1 {
if `gro' == 1 mata: b.set_fill_pattern((`tnrows',`tnrows'), (1,`fp'), "solid", "`myfc2'" , "`myfc2'") 
if `gro' == 0 mata: b.set_top_border((`tnrows',`tnrows'), (1,`fp'), "thin" , ("`mylcol'"))
mata: b.set_top_border((`tnrows',`tnrows'), (1,`fp'), "thin" , ("`mylcol'"))
}

if `gro'==1 {
mata: b.set_bottom_border((`tnrows',`tnrows'), (1,`fp'), "medium" , ("`mylcol'"))
}

mata: b.put_string(3, 2,"Estimate 1")
mata: b.put_string(3, 3,"Estimate 2")
mata: b.put_string(3, 4,"Difference")
mata: b.put_string(3, 5,"Std. Err.")
mata: b.put_string(3, 6,"t-stud.")
mata: b.put_string(3, 7,"P-Val.")
mata: b.set_sheet_merge("`xshe'", (3,3),(8,9))
mata: b.put_string(3, 8, "[`=strsubdp("`level'")'% Conf. Interval]") 
forvalues c=2/9 {
mata: b.set_horizontal_align(3, `c',"center")
}


/*
forvalues i=2/`np' {
mata: b.set_column_width(`i', `i' , `wowi') 
         }
		 */
		 		 local pos = `tnrows'+1
if (`gro' == 1) {

mata: b.set_font((3,`tnrows'),(1,1), "Cambria", 10 , "black")    
mata: b.set_font_bold((3,`tnrows'),(1,1), "on") 
mata: b.set_font_bold((`tnrows',`tnrows'), (1,`fp'), "on")  
}    
if ("`note1'" ~= "") mata: b.put_string(`pos', 1 ,  "Notes:")
mata: b.set_number_format(`pos', `fp', "text")

mata: pos=4
local ndec1 .
if `dec1'> 0 {
	forvalues i=1/`dec1' {
	local ndec1 `ndec1'0
	}
}

local ndec2 .
if `dec2'> 0 {
	forvalues i=1/`dec2' {
	local ndec2 `ndec2'0
	}
}

if (`gro' == 1) {

forvalues g = 1/`nhgroups' { 
local gg = `g'
mata: b.put_string(pos, 1, `"`lhgroup_`g''"')
mata: b.set_font(pos, 1,"Cambria", 11 , "blue")
mata: b.set_horizontal_align(pos, 1,"right")
mata: b.set_font_bold(pos, 1,"on")
mata: b.set_font_italic(pos, 1,"on")
mata: b.set_fill_pattern((pos,pos), (1,9), "solid", "`myfc3'" , "`myfc3'") 
mata: pos=pos+1
mata: g =strtoreal(st_local("gg")) 
local nrowsg = rowsof(``g'')
forvalues i=1/`nrowsg'   {
mata: b.put_string(pos, 1,"`ltmp_`g'_`i''")  

local m1    = el(``g'',`i',1)
local s1    = el(``g'',`i',2)
local m2    = el(``g'',`i',3)
local s2    = el(``g'',`i',4)
local dif   = el(``g'',`i',5)
local sdif  = el(``g'',`i',6)
local tval  = `dif'/`sdif'
local pval  = tprob(`df1',`tval')
local ub    = `dif'-invttail(`df1',`lvl')*`sdif'
local lb    = `dif'+invttail(`df1',`lvl')*`sdif'

mata: b.put_number(pos, 2, `m1')
mata: b.put_number(pos, 3, `m2')
mata: b.put_number(pos, 4, `dif')
mata: b.put_number(pos, 5, `sdif')
mata: b.put_number(pos, 6, `tval')
mata: b.put_number(pos, 7, `pval')
if ("`conf'" == "ts" | "`conf'" == "lb")  mata: b.put_number(pos, 8, `lb')
if ("`conf'" == "ts" | "`conf'" == "ub")  mata: b.put_number(pos, 9, `ub')
if ("`conf'" == "lb")  mata: b.put_string(pos, 9, "+Infinity")  
if ("`conf'" == "ub")  mata: b.put_string(pos, 8, "-Infinity")  
     
mata: b.set_number_format(pos, 2, "#`ndec1'")
mata: b.set_number_format(pos, 3, "#`ndec1'")
mata: b.set_number_format(pos, 4, "#`ndec1'")
mata: b.set_number_format(pos, 5, "#`ndec2'")
mata: b.set_number_format(pos, 6, "#0.000000")
mata: b.set_number_format(pos, 7, "#0.0000")
if ("`conf'" == "ts" | "`conf'" == "lb")   mata: b.set_number_format(pos, 8, "#`ndec1'")
if ("`conf'" == "ts" | "`conf'" == "ub")   mata: b.set_number_format(pos, 9, "#`ndec1'")
if ("`conf'" == "lb")  {
	mata: b.put_string(pos, 9, "+Infinity") 
	mata: b.set_horizontal_align(pos, 9,"right")
}
if ("`conf'" == "ub") {
	 mata: b.put_string(pos, 8, "-Infinity")  
	 mata: b.set_horizontal_align(pos, 8,"right")
    }

mata: pos=pos+1
}
mata: pos=pos+1
}

}

if `gro' ==  0 {
	mata: pos=pos
}

if `pop' ==  1 {
local m1  = el(_ms_pop,1,1)
local s1  = el(_ms_pop,1,2)
local m2  = el(_ms_pop,1,3)
local s2  = el(_ms_pop,1,4)
local dif  = el(_ms_pop,1,5)
local sdif  = el(_ms_pop,1,6)
local tval = `dif'/`sdif'
local pval = tprob(`df1',`tval')
local ub = `dif'-invttail(`df1',`lvl')*`sdif'
local lb = `dif'+invttail(`df1',`lvl')*`sdif'
mata: b.put_number(pos, 2, `m1')
mata: b.put_number(pos, 3, `m2')
mata: b.put_number(pos, 4, `dif')
mata: b.put_number(pos, 5, `sdif')
mata: b.put_number(pos, 6, `tval')
mata: b.put_number(pos, 7, `pval')
if ("`conf'" == "ts" | "`conf'" == "lb")  mata: b.put_number(pos, 8, `lb')
if ("`conf'" == "ts" | "`conf'" == "ub")  mata: b.put_number(pos, 9, `ub')
if ("`conf'" == "lb")  mata: b.put_string(pos, 9, "+Infinity")  
if ("`conf'" == "ub")  mata: b.put_string(pos, 8, "-Infinity") 
mata: b.set_number_format(pos, 2, "#`ndec1'")
mata: b.set_number_format(pos, 3, "#`ndec1'")
mata: b.set_number_format(pos, 4, "#`ndec1'")
mata: b.set_number_format(pos, 5, "#`ndec2'")
mata: b.set_number_format(pos, 6, "#0.000000")
mata: b.set_number_format(pos, 7, "#0.0000")
if ("`conf'" == "ts" | "`conf'" == "lb")   mata: b.set_number_format(pos, 8, "#`ndec1'")
if ("`conf'" == "ts" | "`conf'" == "ub")   mata: b.set_number_format(pos, 9, "#`ndec1'")
if ("`conf'" == "lb")  {
	mata: b.put_string(pos, 9, "+Infinity") 
	mata: b.set_horizontal_align(pos, 9,"right")
}
if ("`conf'" == "ub") {
	 mata: b.put_string(pos, 8, "-Infinity")  
	 mata: b.set_horizontal_align(pos, 8,"right")
    }
mata: b.put_string(pos, 1, `"Population"')
mata: b.set_font(pos, 1,"Cambria", 11 , "blue")
mata: b.set_horizontal_align(pos, 1,"right")
mata: b.set_font_bold(pos, 1,"on")
mata: b.set_font_italic(pos, 1,"on")
}
/*
local pos = `tnrows'+1
mata: b.set_font((3,`tnrows'),(1,1), "Cambria", 10 , "black")    
mata: b.set_font_bold((3,`tnrows'),(1,1), "on") 
mata: b.set_font_bold((`tnrows',`tnrows'), (1,`fp'), "on")      
mata: b.put_string(`pos', 1 ,  "Notes:")
mata: b.set_number_format(`pos', `fp', "text")
*/

local mylcol = "102 153 255"
local myfc1 =  "221 235 247"
local myfc2 =  "219 245 244"
mata: b.set_top_border((3,3), (2,`fp'), "medium" , ("`mylcol'"))
mata: b.set_bottom_border((3,3), (2,`fp'), "thin" , ("`mylcol'"))
mata: b.set_fill_pattern((3,3), (2,`fp'), "solid", "`myfc1'" , "`myfc1'") 
if (`pop'==1 & `gro'==1 ) {
mata: b.set_fill_pattern((`tnrows',`tnrows'), (2,`fp'), "solid", "`myfc2'" , "`myfc2'") 
mata: b.set_top_border((`tnrows',`tnrows'), (2,`fp'), "thin" , ("`mylcol'"))
mata: b.set_bottom_border((`tnrows',`tnrows'), (2,`fp'), "medium" , ("`mylcol'"))
}

mata: b.set_font(`pos', 1, "Cambria", 11 , "black")
mata: b.set_font(r,c, "Cambria", 10 , "black")

mata: b.set_font((`pos',`pos'),(2,9), "Cambria", 10 , "black") 
mata: b.set_font((`tnrows',`tnrows'),(2,9), "Cambria", 11 , "black") 
mata: b.set_font((`tnrows',`tnrows'),(1,1), "Cambria", 11 , "black") 
mata: r =(2,`tnrows')
mata: c =(2,`fp')
mata: b.set_font(r,c, "Cambria", 10 , "black")
if `gro' == 1 {
mata: b.set_bottom_border((`tnrows',`tnrows'), (1,`fp'), "medium" , ("`mylcol'"))
}

if `gro' == 0 {
	local tnro1 = `tnrows' -1
mata: b.set_bottom_border((`tnro1',`tnro1'), (1,`fp'), "medium" , ("`mylcol'"))
}

if `pop'==1 {
if `gro' == 1 mata: b.set_fill_pattern((`tnrows',`tnrows'), (1,`fp'), "solid", "`myfc2'" , "`myfc2'") 
if `gro' == 0 mata: b.set_top_border((`tnrows',`tnrows'), (1,`fp'), "thin" , ("`mylcol'"))
mata: b.set_top_border((`tnrows',`tnrows'), (1,`fp'), "thin" , ("`mylcol'"))
mata: b.set_font((`tnrows',`tnrows'),(1,1), "Cambria", 11 , "black") 
}

if (`gro') == 1 mata: b.set_right_border((3,`tnrows'), (1,1), "thin" , ("`mylcol'"))
if (`gro') == 1 mata: b.set_right_border((3,`tnrows'), (3,3), "thin" , ("`mylcol'"))
if (`gro') == 0 mata: b.set_right_border((3,4), (1,1), "thin" , ("`mylcol'"))
if (`gro') == 0 mata: b.set_right_border((3,4), (3,3), "thin" , ("`mylcol'"))

if (`gro'==0) local pos = `pos'-1

if ("`note1'" ~= "") mata: b.put_string(`pos', 1 ,  "Notes:")
mata: b.set_font_bold(`pos',1,"on")



local pos = `pos'-1
mata: r =(`pos',`pos'+20)
mata: c =(1,1)
mata: b.set_font(r,c, "Cambria", 9 , "black")


        forvalues i =1/20 {
                if ("`note`i''"~="") {
                local  j = `pos' + `i'+1
                mata: b.put_string(`j', 1, " - `note`i''")

        }
        }
mata: b.set_font((`tnrows',`tnrows'),(1,1), "Cambria", 11 , "black") 
mata: b.set_font_bold((`tnrows',`tnrows'),(2,9), "on")
    /*    
mata: b.set_vertical_align((3,`tnrows'),(2,2*`ncols') , "center")
mata: b.set_horizontal_align((3,4),(2,2*`ncols') , "center")
*/
mata: b.close_book()

set trace off
di as txt `"(output written to {browse "`xfil'.xlsx""})"'  








#delimit cr

#delimit ;

end;



