/********************************************************************************/
/*  Package       : USST //Usefull Stata Tools                                  */
/*  Version       :   0.10   //                       JUNE         2020         */
/*  Stata Version : Required  15.0 and higher                                   */
/*  Authors       : Abdelkrim Araar  // aabd@ecn.ulaval.ca                      */
/********************************************************************************/
capture program drop putexmat
program define putexmat
version 15
#delimit ;
syntax namelist (min=1 max=1) [, esheet(string) modrep(string) fexcel(string) etitle(string) eformat(string) posl(int 1) posc(string) 
note1(string) note2(string) note3(string) note4(string)  note5(string) 
note6(string) note7(string) note8(string) note9(string)  note10(string) 
];
#delimit cr
if "`modrep'"=="" local modrep modify
qui {
tokenize `namelist'
local nrows = rowsof(`1')
local ncols = colsof(`1')
local mymatrix `1'
local     posilt A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 
local     posilt2 `posilt'
tokenize `posilt'
foreach name of local posilt2 {
forvalues i=1/26 {
local posilt `posilt' `name'``i''
}	
}
local aa= wordcount("`posilt'")
tokenize  `posilt'
forvalues i=1/702 {
if "``i''"	== "`posc'" local ip =  `i'
}


local  fp = `ip' + `ncols'
dis   `ip' "  ``ip'' "
dis   `fp' "  ``fp'' "
local ip ``ip'' 
local fp ``fp'' 
tokenize `namelist'

	if "`eformat'" == "" local eformat  = "number_d2"
    local p1=  `posl'
	local p2=  `posl' +1
	local p3 = `posl' +2
	local np = `p3'  +`nrows'
	
   	putexcel set "`fexcel'", `modrep'   sheet("`esheet'", replace) 
    putexcel     `ip'`p3':`fp'`p3'  , bold border(bottom) font(Cambria, 10, black) overwritefmt hcenter
	putexcel     `ip'`p3':`ip'`np'  , bold border(right)  font(Cambria, 10, black) overwritefmt right
	putexcel     `ip'`p2':`fp'`p2'  `ip'`p3':`fp'`p3'  `ip'`np':`fp'`np' , border(bottom)
	putexcel     `ip'`p1' = "`etitle'" , bold  font(Cambria, 13, black) 
	putexcel     `ip'`p3' = matrix(`mymatrix'),  hcenter font(Cambria, 10, black) names nformat(`eformat') 
	putexcel     `ip'`p3':`ip'`np'  , left
	if ("`note1'"~="") {
		local j = `np' + 1
		putexcel     `ip'`j' = "Notes:" , bold  font(Cambria, 10, black) 
	}
	forvalues i =1/10 {
		if ("`note`i''"~="") {
		local  j = `np' + 1 + `i'
		qui putexcel   `ip'`j' = " - `note`i''" ,   font(Cambria, 9, black) 
	}
	}
	/*putexcel save	// ver 16 */	
}

  
   di as txt `"(output written to {browse "`fexcel'""})"' 
end



