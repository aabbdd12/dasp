/********************************************/
/* By: Araar Abdelkrim : aabd@ecn.ulaval.ca */
/* JEL decomposition  : 19/08/2005          */
/********************************************/


#delim ;
cap program drop ajldecs;
program define ajldecs, rclass;
version 8.0;
syntax varlist(min=2 max=2) [, 
intmin(real 0) intmax(real 10000)  step(real 1000)   
HSize(string)  STRata(string) PSU(string) PWeight(string) 
GRoup(string) sg(int 1) detail(string) NRep(int 50) ];
preserve;
qui tokenize `varlist';
#delim cr;
sort `1'
gen lb=0
gen ub=0
qui drop if (`1'<`intmin')
qui drop if (`1'>`intmax')
global nc=floor((`intmax'-`intmin')/`step')
gen grou = 0
qui count
if (`r(N)'<$nc) set obs $nc
qui count
forvalues i=1/$nc {
	qui replace lb =`intmin'+`step'*(`i'-1) in `i'
      qui replace ub =`intmin'+`step'*(`i')   in `i'
      forvalues j=1/`r(N)' {
                           
    	            if ((`1'[`j'] >= lb[`i']) & (`1'[`j'] < ub[`i']))  {
                            qui replace grou =`i' in `j'
                    }
                 

                if ($nc==`i') {
						 if ((`1'[`j'] >= lb[`i']) & (`1'[`j'] <= ub[`i']))  {
                                      qui replace grou =`i' in `j'
                                    }

					}
                   
                }
                   

}

#delim ;
qui cajldec `1' `2' grou , intmin(`intmin') intmax(`intmax') step(`step') 
hsize("`hsize'") strata(`strata') psu(`psu') pweight(`pweight')
group(`group') sg(`sg');
#delim cr

cap gen indices       = ""
qui gen estimate      = 0

qui replace indices = "Gini (X)  : G_X " in 1
qui replace indices = "Gini (N)  : G_N " in 2
qui replace indices = "Redis Ef  : RE  " in 3
qui replace indices = "Gini (Mu) : G_0 " in 4
qui replace indices = "Hor. Ineq : H   " in 5
qui replace indices = "Ver. Ineq : V   " in 6
qui replace indices = "Reranking : R   " in 7
qui replace indices = "Tax Rate  : g   " in 8
qui replace indices = "Kakwani   : K_T " in 9
qui replace indices = "K_T/(1-g) : V*  " in 10

qui replace estimate =  `r(res1)'           in 1
qui replace estimate =  `r(res2)'           in 2
qui replace estimate =  `r(res3)'           in 3
qui replace estimate =  `r(res4)'           in 4
qui replace estimate =  `r(res5)'           in 5
qui replace estimate =  `r(res6)'           in 6
qui replace estimate =  `r(res7)'           in 7
qui replace estimate =  `r(res8)'           in 8
qui replace estimate =  `r(res9)'           in 9
qui replace estimate =  `r(res10)'          in 10

#delim ;
if ("`detail'"!="yes") qui bootstrap `" cajldec `1' `2' grou , intmin(`intmin') intmax(`intmax') step(`step') 
hsize("`hsize'") strata(`strata') psu(`psu') pweight(`pweight')
group(`group') sg(`sg')"' 
r(res1) r(res2) r(res3) r(res4) r(res5) r(res6) r(res7) r(res8) r(res9) r(res10)
, reps(`nrep') dots;

if ("`detail'"=="yes") bootstrap `" cajldec `1' `2' grou , intmin(`intmin') intmax(`intmax') step(`step') 
hsize("`hsize'") strata(`strata') psu(`psu') pweight(`pweight')
group(`group') sg(`sg')"' 
r(res1) r(res2) r(res3) r(res4) r(res5) r(res6) r(res7) r(res8) r(res9) r(res10)
, reps(`nrep') dots;

#delim cr
matrix cc=e(se)
gen std=0
forvalues i=1/10 {
				 qui replace std = el(cc,1, `i') in `i'
                 }


qui keep in 1/10
set more off
      disp in green _newline "{hline 70}"
      disp in white "     "_col(15)" Vertical, Horizontal and Reranking RE Components"
      disp in white "     "_col(15)" Aronson, Johnson and Lambert (AJL-1994) Approach    "   
      disp in green "{hline 70}" 
      disp in white " Min_X                   :" _col(25) in yellow %8.2f `intmin'
      disp in white " Max_X                   :" _col(25) in yellow %8.2f `intmax'				 
      disp in white " Bandwidth               :" _col(25) in yellow %8.2f `step' 
      disp in white " Numbers of groups       :" _col(25) in yellow %8.0f $nc 
	disp in white " Numbers of replications :" _col(25) in yellow %8.0f `nrep'  
tabdis indices, cellvar(estimate std) concise 
end




