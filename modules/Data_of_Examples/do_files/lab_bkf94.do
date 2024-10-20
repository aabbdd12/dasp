# delim ;

/* To drop all label values                     */
label drop _all;  

/* To assign labels */                                                                     
label var strata   "Stratum in which a household lives";    
     
label var psu      "Primary sampling unit";
label var weight   "Sampling weight";
label var size     "Household size";
label var totexp   "Total household expenditures";
label var exppc    "Total household expenditures per capita";
label var expeq    "Total household expenditures per adult equivalent";
label var gse      "Socio-economic group of the household head";

/* To define the label values that will be assigned to the categorical variable gse */

label define lvgse   
                                                        
1 "Wage-earner (public sector)"                                      
2 "Wage-earner (private sector)"
3 "Artisan or trader"
4 "Other type of earner"
5 "Crop farmer"
6 "Subsistence farmer"
7 "Inactive"
;

/*To assign the label values "lvgse" to the variable gse */           
label val gse lvgse;        
                                                        
label var sex       "Sex of household head";
label def lvsex
1 Male
2 Female
;

label val sex lvsex;

label var zone     "Residential area";
label def lvzone
1 Rural
2 Urban
;

label val zone lvzone;
