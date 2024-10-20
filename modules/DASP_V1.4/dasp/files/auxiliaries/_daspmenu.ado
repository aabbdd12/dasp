
cap program drop _daspmenu
program define _daspmenu
qui { 
window menu clear
window menu append submenu "stUser" "&DASP"
window menu append submenu "DASP"   "&Inequality"
window menu append submenu "DASP"   "&Polarization"
window menu append submenu "DASP"   "&Poverty"
window menu append separator "DASP" 
window menu append submenu "DASP"   "&Pro-poor"
window menu append submenu "DASP"   "&Poverty elasticities"
window menu append separator "DASP" 
window menu append submenu "DASP"   "&Decomposition"
window menu append submenu "DASP"   "&Dominance"
window menu append submenu "DASP"   "&Curves"
window menu append submenu "DASP"   "&Distributive tools"
window menu append separator "DASP" 
window menu append submenu "DASP"   "&Benefit analysis"

window menu append item "Poverty" /* 
        */   "FGT and EDE-FGT indices"         "db ifgt"

window menu append item "Poverty" /* 
        */   "Difference Between FGT indices"  "db difgt"
        
window menu append separator "Poverty"

window menu append item "Poverty" /* 
        */   "Multidimensional poverty indices"  "db imdpov"


window menu append item "Poverty elasticities" /* 
        */   "FGT: within/between group inequality"  "db efgtg"
window menu append item "Poverty elasticities" /* 
        */   "FGT: within/between income source inequality"  "db efgtc"

window menu append item "Inequality" /* 
        */   "Gini and concentration indices"  "db igini"

      

window menu append item "Inequality" /* 
        */   "Difference between Gini/concentration indices"  "db digini"
        
window menu append separator "Inequality"  

window menu append item "Inequality" /* 
        */   "Generalised entropy indices"  "db ientropy"
        
window menu append item "Inequality" /* 
        */   "Difference between generalised entropy indices"  "db dientropy"

window menu append separator "Inequality" 

window menu append item "Inequality" /* 
        */   "Quantile/Share ratios"  "db inineq"
        
window menu append item "Inequality" /* 
        */   "Difference between quantile/share ratios"  "db dinineq"




window menu append item "Polarization" /* 
        */   "DER Polarization index"  "db ipolar"

      

window menu append item "Polarization" /* 
        */   "Difference between DER polarization indices"  "db dipolar"
        



window menu append item "Decomposition" /* 
        */   "FGT: Decomposition by groups"    "db dfgtg"
window menu append item "Decomposition" /* 
        */   "FGT: Growth and redistribution"    "db dfgtgr"        
window menu append item "Decomposition" /* 
        */   "FGT: Decomposition into transient and chronic components"    "db dtcpov"

        
window menu append separator "Decomposition" 

window menu append item "Decomposition" /* 
        */   "Generalised entropy: Decomposition by groups"    "db dentropyg"
        
window menu append separator "Decomposition"  

window menu append item "Decomposition" /* 
        */   "Gini: Decomposition by groups"    "db diginig"      
window menu append item "Decomposition" /* 
        */   "Gini: Decomposition by income sources"    "db diginis"
        

window menu append item "Distributive tools" "Density curves" "db cdensity"

window menu append separator "Distributive tools"

window menu append item "Distributive tools" "Joint density surfaces"      "db sjdensity"
window menu append item "Distributive tools" "Joint distribution surfaces" "db sjdistrub"

window menu append separator "Distributive tools"

window menu append item "Distributive tools" "Quantile curves" "db c_quantile"
        
window menu append item "Distributive tools" "Non parametric regression curves" "db cnpe"



window menu append item "Curves" "FGT: Curves"                                                  "db cfgt"
window menu append item "Curves" "FGT: Curve with C.I."                                         "db cfgts"
window menu append item "Curves" "FGT: Difference between curves with C.I."                 "db cfgts2d"  
window menu append separator "Curves"
window menu append item "Curves" "Poverty gap/cumulative poverty gap curves" "db cpoverty"
window menu append separator "Curves"
window menu append item "Curves" "Lorenz/concentration curves"                                                 "db clorenz"
window menu append item "Curves" "Lorenz/concentration curve with C.I."                                        "db clorenzs"
window menu append item "Curves" "Lorenz/concentration: differences between curves with C.I."              "db clorenzs2d"

window menu append item "Dominance" /* 
        */   "Poverty dominance"    "db dompov"
        
window menu append item "Dominance" /* 
        */   "Inequality dominance"    "db domineq"   
        
window menu append separator "Dominance"

window menu append item "Dominance" /* 
        */   "Bi-dimensional poverty dominance"    "db dombdpov"  

window menu append item "Pro-poor" /* 
        */   "Pro-poor indices"    "db ipropoor" 

window menu append item "Pro-poor" /* 
        */   "Pro-poor curves: primal approach"    "db cpropoorp" 
window menu append item "Pro-poor" /* 
        */   "Pro-poor curves: dual approach"    "db cpropoord" 
                  


window menu append item "Benefit analysis" /* 
        */   "Benefit incidence analysis"    "db bian" 

window menu refresh
}
end
