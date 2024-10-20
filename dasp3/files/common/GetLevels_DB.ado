capture program drop GetLevels_DB
program define GetLevels_DB
	syntax anything [, mia(string) ndb(string)]
	qui describe using "`anything'",  varl
	local mylist `r(varlist)'

	/*capture {*/
		/* dynamic_list_control is a helper class
		 * for managing dynamic list conrols.
		 */
		 
		 local nvar = wordcount("`mia'")
		 tokenize "`mia'"
		 forvalues i = 1/`nvar' {
		.dlist_`i' = .dynamic_list_control.new , dialogname(`ndb') controlname(main.``i'')
		.dlist_`i'.setList, newlist(`mylist')
		 }
	/*}*/
	capture classutil drop .dlist*
end