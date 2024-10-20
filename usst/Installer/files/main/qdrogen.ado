/********************************************************************************/
/*  Package       : USST //Usefull Stata Tools                                  */
/*  Version       :   0.10   //                       JUNE         2020         */
/*  Stata Version : Required  15.0 and higher                                   */
/*  Authors       : Abdelkrim Araar  // aabd@ecn.ulaval.ca                      */
/********************************************************************************/
/* Produced by Araar : based on the Stata command egen */
/* Main utility : drop automatically the variable if it is already in the data. */

capture program drop drogen
program define drogen,  sortpreserve
        version 6, missing


        local cvers = _caller()

        gettoken type 0 : 0, parse(" =(")
        gettoken name 0 : 0, parse(" =(")

        if `"`name'"'=="=" {
                local name `"`type'"'
                local type : set type
        }
        else {
                gettoken eqsign 0 : 0, parse(" =(")
                if `"`eqsign'"' != "=" {
                        error 198
                }
        }

       /* confirm new variable `name' */


        local myargs `0'
        gettoken args 0 : 0, parse(" ,") match(par)
		

      
        if `"`args'"' == "_all" | `"`args'"' == "*" {
                version 7.0, missing
                unab args : _all
                local args : subinstr local args "`_sortindex'"  "", all word
                version 6.0, missing
        }
        

		

        if `"`options'"' != "" { 
                local cma ","
        }
		
		
        tempvar dummy
        global GEN_Varname `name'
        version 7.0, missing
        global GEN_SVarname `_sortindex'
        version 6.0, missing
		cap drop `dummy'
	/*	dis "  capture quietly `vv' gen `type' `dummy' = `myargs' `if' `in' `cma'  `byopt' `options' " */
        capture noisily        `vv' generate `type' `dummy' = `myargs' `if' `in'  `cma' `byopt' `options'
        global GEN_SVarname
        global GEN_Varname
        if _rc { exit _rc }
        quietly count if missing(`dummy')
        if r(N) { 
                local s = cond(r(N)>1,"s","")
                //di in bl "(" r(N) " missing value`s' generated)"
        }
		cap drop `name'
        rename `dummy' `name'
end

set trace off



