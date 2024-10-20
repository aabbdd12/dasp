/*
Decomposition of total inequality into vertical and horizontal inequality using the:
*/


use can4.dta, replace

/*
REFERENCES:

Duclos, J.-Y., Jalbert, V. and Araar, A. (2003). 
Classical horizontal inequity and reranking: an integrated approach, 
Research on Economic Inequality, Vol. 10, pp. 65100

Jean-Yves Duclos & Peter J. Lambert, 2000. "A normative and statistical 
approach to measuring classical horizontal inequity," Canadian Journal of Economics, Canadian Economics Association, vol. 33(1), pages 87-113, February

Note that the DJA decomposition is equivalent to that of  Duclos and Lambert (2000)
when the parameter rho = 1

*/

/* syntax 
dja X N,  HWeight(varname) HSize(varname) HGroup(varname) NGroup(string) RHO(real 2.0) EPS(real 0.5) BAND(string)
X: gross income
N: Net income
OPTIONS
HSize:  HH size
HWeight: sampling weight
STRata: Strata
PSU: primary sampling unit

RHO(real 2.0) 
EPS(real 0.5) 
BAND(string)


*/
 
dja  x n


dja  x n, rho(1.0)  

 


