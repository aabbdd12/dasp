/*

Reference
Aronson, J. R., Johnson, P. and Lambert, P. J. (1994). Redistributive effect and unequal income tax treatment, 
The Economic Journal, Vol. 104, pp. 262-270.
Decomposition of total inequality into vertical and horizontal inequality using the:
*/



use can4.dta, replace

/*

 Vertical, Horizontal and Reranking RE Components
 Aronson, Johnson and Lambert (AJL-1994) Approach

*/

/* syntax 
ajldecs X N,  intmin(real 0) intmax(real 10000)  step(real 1000)   HSize(string)  STRata(string) PSU(string) PWeight(string)  GRoup(string) sg(int 1) detail(string) NRep(int 50) ]
X: gross income
N: Net income
OPTIONS
intmin: minimum range of income
intmax: maximum range of income
step: the bandwidth
HSize:  HH size
PWeight: sampling weight
STRata: Strata
PSU: primary sampling unit
GRoup: categrical variable (group)
sg: number of group (estimate if GRoup==sg)


*/
 
 ajldec  x n,  intmin(0)  intmax(100000) step(10000) 
  
 ajldecs x n,  intmin(0)  intmax(100000) step(10000) detail(yes)
 


