
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
capture program drop mk_xls;
program define mk_xls, rclass;
version 15.0;
syntax anything [,  matn(string) dste(int 1) dec(int 3) xfil(string) xshe(string) xtit(string)  xlan(string) hsep(int 0) note(string)
esheet(string) modrep(string) FCNAME(string)
fexcel(string) etitle(string) eformat(string)
note1(string) note2(string) note3(string) note4(string)  note5(string) 
note6(string) note7(string) note8(string) note9(string)  note10(string)
note11(string) note12(string) note13(string) note14(string)  note15(string) 
note16(string) note17(string) note18(string) note19(string)  note20(string)  
dec1(int 2)
dec2(int 2)
dislink(int 1)
perclast(int 1)
];


tokenize `namelist';
if (`dste'!=0 )                 local note1 = "[-] Standard errors are in italics.";
if (`dste'!=0 & "`xlan'"=="fr") local note1 = "[-] Les erreurs types sont en format italique.";

 if ("`modrep'"=="" )  local modrep = "replace" ;



                local frm = "SCCB0 N231`dec' N232`dec'";
if (`dste'==0)  local frm = "SCCB0 N230`dec'";
                local lst1 = rowsof(`matn')-2;
if (`dste'==0)  local lst1 = rowsof(`matn')-1;

#delimit ;
local xrnames  $rnamn ;
if ("`xrnames'"~="") {;

local xrna  "`xrnames'";
local xrna : subinstr local xrna " " ",", all ;
local xrna : subinstr local xrna "@" " ", all ;
local count : word count `xrna';
tokenize "`xrna'";

forvalues i = 1/`count' {;
local rnam`i': subinstr local `i' "," " ", all ;
/*dis strtrim("`rnam`i''"); */
    local ltmp_1_`i' =  strtrim("`rnam`i''");
};
};

#delimit ;
local xrnames  $cnamn ;
if ("`xrnames'"~="") {;
local xrna  "`xrnames'";
local xrna : subinstr local xrna " " ",", all ;
local xrna : subinstr local xrna "@" " ", all ;
local count : word count `xrna';
tokenize "`xrna'";
forvalues i = 1/`count' {;
local cnam`i': subinstr local `i' "," " ", all ;
local coln_`i' =  strtrim("`cnam`i''");
};
};


#delimit cr


                local tnrows = rowsof(`matn')-1
if `dste' ==1   local tnrows = rowsof(`matn')-2
local ncols = colsof(`matn') 

local tnrows = `tnrows' +  6
if `dste' !=1 local tnrows = `tnrows'- 1 
local tnrows1 = `tnrows' -1
if `dste' !=1 local tnrows1 = `tnrows1'+ 1 
local rpr = `ncols' 
local pos = `tnrows'+1
local np  = `tnrows'
local  fp =  `ncols'+1
local wowi = 16
local wfc = 30

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

mata: r =(2,`tnrows')
mata: c =(2,`fp')
mata: b.set_font(r,c, "Cambria", 11 , "black")
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
local myfc3 =  "051 153 255"
local myfc4 =  "217 225 242"
mata: b.set_top_border((3,3), (1,`fp'), "medium" , ("`mylcol'"))
mata: b.set_fill_pattern((3,3), (1,`fp'), "solid", "`myfc1'" , "`myfc1'") 
mata: b.set_bottom_border((3,3), (1,`fp'), "thin" , ("`mylcol'"))
mata: b.set_bottom_border((4,4), (1,`fp'), "thin" , ("`mylcol'"))
mata: b.set_fill_pattern((4,4), (1,`fp'), "solid", "`myfc2'" , "`myfc2'") 

mata: b.set_fill_pattern((`tnrows1',`tnrows'), (1,`fp'), "solid", "`myfc2'" , "`myfc2'") 

mata: b.set_right_border((3,`tnrows'), (1,1), "thin" , ("`mylcol'"))
mata: b.set_top_border((`tnrows1',`tnrows1'), (1,`fp'), "thin" , ("`mylcol'"))
mata: b.set_bottom_border((`tnrows',`tnrows'), (1,`fp'), "medium" , ("`mylcol'"))


forvalues i=2/`np' {
mata: b.set_column_width(`i', `i' , `wowi') 
         }
		 
		 
/*

forvalues i=1/16 {
	forvalues j=1/4 {
	    local ma_1_`i'_`j' = el(`matn' , `i' , `j')
	}
}


*/


mata: b.set_font((3,`tnrows'),(1,1), "Cambria", 11 , "black")    
mata: b.set_font_bold((`tnrows1',`tnrows'),(1,1), "on") 
mata: b.set_font_bold((`tnrows',`tnrows'), (1,`fp'), "on")      
mata: b.put_string(`pos', 1 ,  "Notes:")
mata: b.set_number_format(`pos', `fp', "text")
mata: b.set_number_format((2,4), (3,6), "number_d2" )

mata: pos=4

local nhgroups = 1



mata: zz=st_matrix("`matn'") 



forvalues g = 1/`nhgroups' { 
local gg = `g'
mata: b.put_string(pos, 1, "`hgroup_`g''")
mata: b.set_font(pos, 1,"Cambria", 11 , "blue")
mata: b.set_horizontal_align(pos, 1,"right")
mata: b.set_font_bold(pos, 1,"on")
mata: b.set_font_italic(pos, 1,"on")

mata: pos=pos+1
mata: g =strtoreal(st_local("gg")) 
local nrowsg = rowsof(`matn')

        

local v = -1
				
forvalues i=1/`nrowsg'   {
mata: b.put_string(pos, 1,"`ltmp_`g'_`i''") 

local ii = `i'
mata: i =strtoreal(st_local("ii"))
forvalues j=1/`ncols'  {
local jj = `j'
mata: j =strtoreal(st_local("jj"))
mata: r = i+1
mata: c = j+1
mata: b.put_number(pos, c, zz[i..i,j..j])

if ((`v')^`i' == 1 & `dste'==1) {
	mata: b.set_font(pos,c, "Cambria", 10 , "`myfc3'") 
}

}
mata: pos=pos+1
}
}

mata: b.set_fill_pattern((`tnrows1',`tnrows'), (1,`fp'), "solid", "`myfc2'" , "`myfc2'") 

mata: b.set_right_border((3,`tnrows'), (1,1), "thin" , ("`mylcol'"))
mata: b.set_top_border((`tnrows1',`tnrows1'), (1,`fp'), "thin" , ("`mylcol'"))
mata: b.set_bottom_border((`tnrows',`tnrows'), (1,`fp'), "medium" , ("`mylcol'"))

local ncolsp1 = `ncols'+1
mata: rows = (5,`tnrows')
mata: cols = (2,`ncolsp1')



mata: b.set_horizontal_align(rows, cols, "center")
mata: b.set_font(rows, cols,"Cambria", 11)
local ndec .
if `dec'> 0 {
	forvalues i=1/`dec' {
	local ndec `ndec'0
	}
}
mata: b.set_number_format(rows, cols, "#`ndec'")
local ncolp1 = `ncols'+1
mata: rows = (5,`tnrows')
mata: cols = (`ncolp1',`ncolp1')
if (`perclast' == 1) {
mata: b.set_number_format(rows, cols, "percent_d2")
}

mata: b.put_string(4, 1 ,  "`fcname':")
mata: b.set_font_italic(4,1,"on")
mata: b.set_font_italic(4,1,"on")
mata: b.set_horizontal_align(4,1,"left")
mata: b.put_string(`pos', 1 ,  "Notes:")

mata: b.set_font(r,c, "Cambria", 10 , "black")



mata: fmt_id1 = b.add_fmtid()
mata: b.fmtid_set_text_wrap(fmt_id1, "on")

forvalues j=1/`ncols' { 

	local i = `j'+1
mata: b.put_string(3, `i' ,  "`coln_`j''")
mata: b.set_horizontal_align(3, `i' ,  "center")
mata: b.set_vertical_align(3, `i' ,  "top")
mata: b.set_text_wrap(3, `i', "on")


}

local note1 " Values in blue are standard errors." 

mata: b.put_string(`pos', 1 ,  "Notes:")
mata: b.set_font_bold(`pos',1,"on")
local pos = `pos'+1

forvalues n=1/10 {
	if "`note`n''" ~="" {

mata: r =(`pos',`pos'+20)
mata: c =(1,1)
mata: b.set_font(r,c, "Cambria", 9 , "black")
if "`note`n''" ~="" mata: b.put_string(`pos', 1 , "[`n']- `note`n''") 
local pos = `pos'+1
	}
}
  
mata: b.set_vertical_align((3,`tnrows'),(2,2*`ncols') , "center")
mata: b.set_horizontal_align((3,4),(2,2*`ncols') , "center")

mata: b.close_book()


if (`dislink' == 1) di as txt `"(output written to {browse "`fexcel'.xlsx""})"'

#delimit ;
end;



