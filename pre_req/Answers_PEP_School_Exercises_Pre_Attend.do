

/********* Ansewrs **************/

*PART I: 	Exploring the data  

#delim cr
  
*Exercise 1:  

/* 1 */
use data\Nigeria_04I.dta, clear 
count 

/* 2 */
bysort strata : count 
tab strata
 
/* 3 */
tabstat sweight, statistics( sum ) by(strata) columns(variables) format(%10.2g)

/* 4 */
cap drop fw
gen fw = sweight*hsize
tabstat fw, statistics( sum ) by(strata) columns(variables) format(%10.2g)

/* 5 */
svy: tabulate sector zone, tab(hsize) format(%10.4f)

/* 6 */ 
sum pcexp 

/* 7 */
sum pcexp  [aweight = fw] 

/* 8 */
mean pcexp  [aweight = fw] 

/* 9 */
cap drop spcexp ;
gen spcexp  = hsize*pcexp 
svy: ratio spcexp/hsize

/* 10 */
by sex, sort : summarize pcexp  [aweight = fw], detail

/* 11 */
bysort zone: tabstat pcexp  [aweight = fw], stats(mean)  
table  zone [aweight = fw], contents(mean pcexp)  

/* 12 */
table  zone sector [aweight = fw], contents(mean pcexp)


*PART II:	Monetary poverty


//Exercise 1 
*1.1
use "data\Uganda_99.dta", clear
svyset psu, strata(strata) vce(linearized) singleunit(missing)

*1.2
imean welfare, hsize(hsize)

*1.3
svyset psu [pweight=sweight], strata(strata) vce(linearized) singleunit(missing)
imean welfare, hsize(hsize)

*1.4
imean hsize

*1.5
cnpe hsize, xvar(welfare) min(0) max(60000)




*Exercise 2

*2.1
use "data\Uganda_99I.dta", clear
ifgt welfare, alpha(0) hsize(hsize) pline(21136)
ifgt welfare, alpha(1) hsize(hsize) pline(21136)

*2.2
gen hhwelfare  = hsize*welfare
ifgt hhwelfare, alpha(0) pline(110178)
ifgt hhwelfare, alpha(1) pline(110178)

*2.3

//The average poverty line becomes more demanding for smaller-size households



*Exercise 3
*3.1
use "data\Uganda_99I.dta", clear
ifgt welfare, alpha(0) hsize(hsize) pline(21136)

*3.2
ifgt welfare, alpha(0) hsize(hsize) opl(mean) prop(50)

*3.3
ifgt welfare, alpha(0) hsize(hsize) opl(median) prop(50)




*Exercise 4
*4.1
use "data\Uganda_99I.dta", clear
dfgtg welfare, hgroup(sex) hsize(hsize) alpha(0) pline(21136)


*4.2	Decompose total poverty according to the region of household head (region).  
dfgtg welfare, hgroup(region) hsize(hsize) alpha(0) pline(21136)

*4.3

*4.4
dfgtg welfare, hgroup(activity) hsize(hsize) alpha(1) pline(21136)

*4.5


*4.7
dfgtgr welfare welfare, alpha(0) pline(21136) file1(C:\pep-school\exercises\data\Uganda_92I.dta) hsize1(hsize) file2(C:\pep-school\exercises\data\Uganda_99I.dta) hsize2(hsize)
