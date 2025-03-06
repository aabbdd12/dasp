***********8%
clear
set more off 

cd "Exercise 9-10-11\"

/*==============================================================================
						EXERCISE 1
==============================================================================*/

import excel "${path}input_data.xlsx", sheet("Sheet1") firstrow
replace identifier=subinstr(identifier,"Individual","",.)
destring identifier, force replace


** --> Question 1.1
	// union approach
	imdp_uhi w1 w2 w3, hsize(identifier) pl1(14) pl2(14) pl3(14) dec(3)
	// dasp approach
	ifgt w1 w2 w3, alpha(0) pline(14)

** --> Question 1.2: 
	// intersection approach
	imdp_ihi w1 w2 w3, pl1(10000) pl2(10000) pl3(10000)
	// dasp approach
	ifgt w1 w2 w3, alpha(0) pline(14)
 
** --> Question 1.3


** --> Question 1.4 
	imdp_afi w1 w2 w3, dcut(2) w1(1) pl1(14) w2(1) pl2(14) w3(1) pl3(14)

 
/*==============================================================================
						EXERCISE 2
==============================================================================*/

** --> Question 2.1 
	//
	imdp_bci w1 w2 w3, alpha(1) gamma(1) b1(1) pl1(14) b2(1) pl2(14) b3(1) pl3(14)

** --> Question 2.2
	// dasp approach
	ifgt w1 w2 w3, alpha(0) pline(14)

** --> Question 2.3
	forvalues i=1/3 {
		gen nw_`i'=((w1+w2+w3)/3)
	}
	imdp_bci nw_1 w2 w3, alpha(1) gamma(1) b1(1) pl1(14) b2(1) pl2(14) b3(1) pl3(14)

/*==============================================================================
						EXERCISE 3
==============================================================================*/

 ** Loading data
 use "${path}Canada_Incomes&Taxes_1996_2005_random_sample_3",clear
	drop if year==.
	
	
** --> Question 3.1
	preserve
	keep if year>=2005
	cnpe T, xvar(X) hsize(hhsize) min(1000) max(31000) ytitle(Per Capita Taxes) xtitle(Per Capital Gross Income) type(dnp)
	graph export "${path}T.png", as(png) name("Graph") replace
	
	cnpe B, xvar(X) hsize(hhsize) min(1000) max(31000) ytitle(Per Capita Taxes) xtitle(Per Capital Gross Income) type(dnp)
	graph export "${path}B.png", as(png) name("Graph") replace
	
	cnpe N, xvar(X) hsize(hhsize) min(1000) max(31000) ytitle(Per Capita Taxes) xtitle(Per Capital Gross Income) type(dnp)
	graph export "${path}N.png", as(png) name("Graph") replace
	
	restore

** --> Question 3.2
	preserve
	keep if inlist(year,1999,2002,2005)
	igini N, hsize(hhsize) hgroup(year)
	restore

** --> Question 3.3
	iprog T, ginc(X) hsize(hhsize) gobs(year) type(t) index(ka)

** --> Question 3.4
	keep if year>=2005
	cprog T, rank(T) hsize(hhsize) type(t) appr(tr) min(0.1)
	
** --> Question 3.5
	

â€