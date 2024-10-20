# delim ;
label drop _all;
label var strata  "Stratum in which a household lives"; 
label var psu     "Primary sampling unit";
label var weight  "Sampling weight";
label var size    "Household size";
label var totexp  "Total expenditures";
label var exppc   "Total expenditures per capita                                     ";
label var exppcz  "Total expenditures per capita deflated by (z_1994/z_1998)         ";
label var exppci  "Total expenditures per capita deflated by (IPC_1994/IPC_1998)     ";

label var expeqz  "Total expenditures per adult equivalent  deflated by (z_1994/z_1998)         ";
label var expeqi  "Total expenditures per adult equivalent  deflated by (IPC_1994/IPC_1998)     ";



label var gse "Socio-economic group of the household head";
label define lvgse   
                                                        
1 "Wage-earner (public sector)"                                      
2 "Wage-earner (private sector)"
3 "Artisan or trader"
4 "Other type of earner"
5 "Crop farmer"
6 "Subsistence farmer"
7 "Inactive"
;
label val gse lvgse;

label var sex "Sex of household head";
label def lvsex
1 Male
2 Female
;
label val sex lvsex;

label var zone "Residential area";
label def lvzone
1 Rural
2 Urban
;
label val zone lvzone;

