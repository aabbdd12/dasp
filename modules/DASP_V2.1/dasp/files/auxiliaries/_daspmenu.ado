
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
window menu append submenu "DASP"   "&Poverty and targeting policies"
window menu append submenu "DASP"   "&Poverty elasticities"
window menu append separator "DASP" 
window menu append submenu "DASP"   "&Decomposition"
window menu append submenu "DASP"   "&Dominance"
window menu append submenu "DASP"   "&Curves"
window menu append submenu "DASP"   "&Distributive tools"
window menu append separator "DASP" 
window menu append submenu "DASP"   "&Benefit analysis"
window menu append separator "DASP" 
window menu append submenu "DASP"   "&Disaggregating data"
window menu append separator "DASP"
window menu append submenu "DASP"   "&Hypothesis tests" 


window menu append item "Poverty" /* 
        */   "FGT and EDE-FGT indices"         "db ifgt"

window menu append item "Poverty" /* 
        */   "Difference between FGT indices"  "db difgt"
        
window menu append separator "Poverty"         
window menu append item "Poverty" /* 
	        */   "Watts index"         "db iwatts"
	
window menu append item "Poverty" /* 
        */   "Difference between Watts indices"  "db diwatts"

window menu append separator "Poverty"           
window menu append item "Poverty" /* 
		        */   "Sen-Shorrocks-Thon index"         "db isst"
		
window menu append item "Poverty" /* 
        */   "Difference between Sen-Shorrocks-Thon indices"  "db disst"
        
window menu append separator "Poverty"

window menu append item "Poverty" /* 
        */   "Multidimensional poverty indices"  "db imdpov"


window menu append item "Poverty elasticities" /* 
        */   "FGT: Poverty elasticity with respect to growth"      "db efgtgr" 
window menu append item "Poverty elasticities" /*
        */    "FGT: Poverty elasticity with respect to inequality"  "db efgtineq"
window menu append separator "Poverty elasticities"   
window menu append item "Poverty elasticities" /*
            */ "FGT: within/between group inequality"  "db efgtg"
window menu append item "Poverty elasticities" /* 
        */   "FGT: within/between income source inequality"  "db efgtc"

window menu append item "Inequality" /* 
        */   "Gini and concentration indices"  "db igini"

      

window menu append item "Inequality" /* 
        */   "Difference between Gini/concentration indices"  "db digini"
        
window menu append separator "Inequality"  

window menu append item "Inequality" /* 
        */   "Atkinson indices"  "db iatkinson"

     
window menu append item "Inequality" /* 
        */   "Difference between Atkinson indices"  "db diatkinson"
        
window menu append separator "Inequality"  

window menu append item "Inequality" /* 
        */   "Generalized entropy indices"  "db ientropy"
        
window menu append item "Inequality" /* 
        */   "Difference between generalized entropy indices"  "db dientropy"


window menu append separator "Inequality"  

window menu append item "Inequality" /* 
	        */   "Coefficient of variation"  "db icvar"
	        
window menu append item "Inequality" /* 
        */   "Difference between coefficients of variation"  "db dicvar"

window menu append separator "Inequality" 

window menu append item "Inequality" /* 
        */   "Quantile/share ratios"  "db inineq"
        
window menu append item "Inequality" /* 
        */   "Difference between quantile/share ratios"  "db dinineq"


window menu append item "Polarization" /* 
        */   "DER polarization indices"  "db ipolder"

window menu append item "Polarization" /* 
        */   "Difference between DER polarization indices"  "db dipolder"
        
 window menu append separator  "Polarization" 
       
 window menu append item "Polarization" /* 
 
	        */   "Foster & Wolfson polarization index"  "db ipolfw"
	
window menu append item "Polarization" /* 
        */   "Difference between Foster & Wolfson polarization indices"  "db dipolfw"
        
window menu append separator  "Polarization" 
window menu append item "Polarization" /* 
        */   "Esteban, Gradin and Ray (1999) polarization index"  "db ipoegr"
        
window menu append separator  "Polarization" 
	window menu append item "Polarization" /* 
        */   "Permanyer (2008) index"  "db dspol"

window menu append item "Decomposition" /* 
        */   "FGT: Decomposition by groups"           "db dfgtg"
window menu append item "Decomposition" /* 
        */   "FGT: Decomposition by income sources"    "db dfgts"

window menu append item "Decomposition" /* 
        */   "FGT: Growth and redistribution"    "db dfgtgr"        
window menu append item "Decomposition" /* 
        */   "FGT: Decomposition into transient and chronic components"    "db dtcpov"

        
window menu append separator "Decomposition" 

window menu append item "Decomposition" /* 
        */   "Generalized entropy: Decomposition by groups"    "db dentropyg"
        
window menu append separator "Decomposition"  

window menu append item "Decomposition" /* 
        */   "Gini: Decomposition by groups"    "db diginig"    

window menu append submenu "Decomposition"   "&Gini: Decomposition by income sources" 
 
window menu append item "Gini: Decomposition by income sources" /* 
        */   "Analytical approach"    "db diginis"
        
window menu append item "Gini: Decomposition by income sources" /* 
        */   "Shapley approach"       "db dsginis"
window menu append separator "Decomposition"         
window menu append item "Decomposition" /* 
        */   "Inequality decomposition by income sources"       "db dsineqs"    
window menu append separator "Decomposition"         
window menu append item "Decomposition" /* 
        */   "Regression-based decomposition of inequality"       "db rbdineq"  
        
window menu append separator "Decomposition" 
        

window menu append item "Decomposition" /* 
        */   "DER: Decomposition by population groups"    "db dpolag" 
        
window menu append item "Decomposition" /* 
        */   "DER: Decomposition by income sources"      "db dpolas" 



window menu append item "Distributive tools" "Density curves" "db cdensity"

window menu append separator "Distributive tools"

window menu append item "Distributive tools" "Joint density surfaces"      "db sjdensity"
window menu append item "Distributive tools" "Joint distribution surfaces" "db sjdistrub"


window menu append separator "Distributive tools"

window menu append item "Distributive tools" "Quantile curves" "db c_quantile"
window menu append item "Distributive tools" "Income/Cumulative income shares" "db quinsh"

window menu append separator "Distributive tools"
window menu append item "Distributive tools" "Non parametric regression curves" "db cnpe"

window menu append separator "Distributive tools"

window menu append item "Distributive tools" "Mean" "db imean"
window menu append item "Distributive tools" "Difference between means" "db dimean"
window menu append separator "Distributive tools"

window menu append item "Distributive tools" "Hypothesis testing" "db datest"




window menu append item "Curves" "FGT: Curves"                                                   "db cfgt"

window menu append submenu "Curves"   "&FGT curve(s) with confidence interval" 

window menu append item "FGT curve(s) with confidence interval" "One curve"                 "db cfgts"
window menu append item "FGT curve(s) with confidence interval" "Multiple curves"           "db cfgtsm"

window menu append item "Curves" "FGT: Difference between curves with C.I."                 "db cfgts2d"  

window menu append separator "Curves"
window menu append item "Curves" "Poverty gap/cumulative poverty gap curves" "db cpoverty"
window menu append separator "Curves"
window menu append item "Curves" "Lorenz/concentration curves"                                                  "db clorenz"

window menu append submenu "Curves"   "&Lorenz/concentration curve(s) with confidence interval" 

window menu append item "Lorenz/concentration curve(s) with confidence interval" "One curve"                 "db clorenzs"
window menu append item "Lorenz/concentration curve(s) with confidence interval" "Multiple curves"           "db clorenzsm"
window menu append item "Curves" "Lorenz/concentration: differences between curves with C.I."              "db clorenzs2d"

window menu append separator "Curves"
window menu append item "Curves" "Progressivity curve(s): Taxes or transfers" "db cprog"
window menu append item "Curves" "Progressivity curve   : Transfer vs tax" "db cprogbt"

window menu append separator "Curves"
window menu append item "Curves" "Consumption dominance curves"                                             "db cdomc"
window menu append item "Curves" "Difference between/Ratio of consumption dominance curves"                     "db cdomc2d"


window menu append item "Dominance" /* 
        */   "Poverty dominance"    "db dompov"
        
window menu append item "Dominance" /* 
        */   "Inequality dominance"    "db domineq"   
        
window menu append separator "Dominance"

window menu append item "Dominance" /* 
        */   "Bi-dimensional poverty dominance"    "db dombdpov"  


window menu append item "Poverty and targeting policies" /* 
        */   "Targeting by population groups"    "db itargetg" 

window menu append item "Poverty and targeting policies" /* 
        */   "Targeting by income components"    "db itargetc" 

window menu append item "Pro-poor" /* 
        */   "Pro-poor indices"    "db ipropoor" 

window menu append item "Pro-poor" /* 
        */   "Pro-poor curves: primal approach"    "db cpropoorp" 
window menu append item "Pro-poor" /* 
        */   "Pro-poor curves: dual approach"    "db cpropoord" 
                  


window menu append item "Benefit analysis" /* 
        */   "Benefit incidence analysis"    "db bian" 

		
window menu append item "Hypothesis tests" /* 
        */   "Hypothesis testing"    "db datest" 
		
window menu append item "Disaggregating data" /* 
        */   "Disaggregating grouped data"    "db ungroup" 

        

        
       
window menu refresh
}
end
