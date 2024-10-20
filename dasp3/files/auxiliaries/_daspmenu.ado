
cap program drop _daspmenu
program define _daspmenu
qui { 
window menu clear
window menu append submenu "stUser" "&DASP"
window menu append submenu "DASP"   "&Inequality"
window menu append submenu "DASP"   "&Multidimensional inequality"
window menu append submenu "DASP"   "&Progressivity"
window menu append separator "DASP" 
window menu append submenu "DASP"   "&Polarization"
window menu append separator "DASP" 
window menu append submenu "DASP"   "&Poverty"
window menu append submenu "DASP"   "&Multidimensional poverty"
window menu append separator "DASP" 
window menu append submenu "DASP"   "&Pro-poor"
window menu append submenu "DASP"   "&Poverty and targeting policies"
window menu append submenu "DASP"   "&Poverty elasticities"
window menu append separator "DASP" 
window menu append submenu "DASP"   "&Decomposition"
window menu append submenu "DASP"   "&Dominance"
window menu append submenu "DASP"   "&Distributive tools"
window menu append separator "DASP" 
window menu append submenu "DASP"   "&Benefit analysis"
window menu append separator "DASP" 
window menu append submenu "DASP"   "&Disaggregating data"
window menu append separator "DASP" 
window menu append item "DASP" /* 
        */   "DASP Package Manager "  "db dasp" 


window menu append item "Poverty" /* 
        */   "Poverty indices"         "db ipov"
		window menu append item "Poverty" /* 
        */   "Difference between poverty indices"         "db dipov"
window menu append separator "Poverty" 		
window menu append item      "Poverty" "FGT: Curves"                                    "db cfgt"
window menu append item      "Poverty" "FGT: Difference between curves"                 "db dicfgt" 
window menu append item      "Poverty" "Poverty gap/cumulative poverty gap curves"   "db cpoverty" 

		
window menu append item "&Multidimensional poverty" /* 		
*/ "Multidimensional poverty indices"   "db imdpov"

window menu append separator "&Multidimensional poverty"

window menu append item "&Multidimensional poverty" /* 
*/ "Multiple Overlapping Deprivation Analysis"   "db imoda"
  





window menu append item "Poverty elasticities" /* 
        */   "FGT: Poverty elasticity with respect to growth"      "db efgtgr" 
window menu append item "Poverty elasticities" /*
        */    "FGT: Poverty elasticity with respect to inequality"  "db efgtineq"
window menu append separator "Poverty elasticities"  
window menu append item "Poverty elasticities" /* 
        */   "FGT: Poverty elasticity with respect to growth: different approaches"      "db efgtgro" 
window menu append item "Poverty elasticities" /*
        */    "FGT: Poverty elasticity with respect to inequality: different approaches"  "db efgtine"
window menu append separator "Poverty elasticities" 
window menu append item "Poverty elasticities" /*
            */ "FGT: within/between group inequality"  "db efgtg"
window menu append item "Poverty elasticities" /* 
        */   "FGT: within/between income source inequality"  "db efgtc"

window menu append item "Inequality" /* 
        */   "Inequality/concentration indices"  "db ineq"

window menu append item "Inequality" /* 
        */   "Difference between inquality/concentration indices"  "db dineq"
		
window menu append separator "Inequality" 	

	
window menu append item "Inequality" "Lorenz/concentration curves"                                                        "db clorenz"
window menu append item "Inequality" "Lorenz/concentration: differences between Lorenz/concentration curves"              "db diclorenz"

        
	
window menu append item "Multidimensional inequality" /* 
        */   "Multidimensional inequality indices (Araar 2009)"  "db imdi"
		

window menu append item "Progressivity" /* 
        */   "Progressivity indices"  "db iprog"
		
window menu append separator "Progressivity"
window menu append item "Progressivity" "Progressivity curve(s): Taxes or transfers" "db cprog"
window menu append item "Progressivity" "Progressivity curve   : Transfer vs tax" "db cprogtb"
		
				
		


window menu append item "Polarization" /* 
        */   "Polarization indices"  "db ipola"

window menu append item "Polarization" /* 
        */   "Difference between polarization indices"  "db dipola"
        
 
window menu append item "Decomposition" /* 
        */   "FGT: Decomposition by groups"           "db dfgtg"
window menu append item "Decomposition" /* 
        */   "FGT: Decomposition by income sources"    "db dfgts"

window menu append item "Decomposition" /* 
        */   "FGT: Growth and redistribution"    "db dfgtgr"  
        
window menu append item "Decomposition" /* 
        */   "FGT: Sectoral decomposition"      "db dfgtg2d"  
        
window menu append item "Decomposition" /* 
        */   "FGT: Decomposition into transient and chronic components"    "db dtcpov"

        
window menu append separator "Decomposition" 

window menu append item "Decomposition" /* 
        */   "Foster and Alkire (2007) index: by groups"                                   "db dmdafg"
window menu append item "Decomposition" /* 
        */   "Foster and Alkire (2007) index: by dimensions using the Shapley approach"     "db dmdafs"
		
		window menu append separator "Decomposition" 

window menu append item "Decomposition" /* 
        */   "Generalized entropy: Decomposition by groups"    "db dentropyg"
        
window menu append separator "Decomposition"  

window menu append item "Decomposition" /* 
        */   "Gini: Decomposition by groups"    "db diginig"    

window menu append item "Decomposition"   /*
*/          "Gini: Decomposition by income sources"  "db diginis"
 

window menu append separator "Decomposition"  
window menu append item "Decomposition" /* 
        */   "Inequality decomposition by groups"               "db dsineqg"         
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

window menu append item "Distributive tools" "Cumulative distribution function "      "db cdf"

window menu append separator "Distributive tools"

window menu append item "Distributive tools" "Quantile curves" "db c_quantile"
window menu append item "Distributive tools" "Income/Cumulative income shares" "db quinsh"

window menu append separator "Distributive tools"
window menu append item "Distributive tools" "Nonparametric regression curves" "db cnpe"

window menu append separator "Distributive tools"

window menu append item "Distributive tools" "Mean" "db imean"
window menu append item "Distributive tools" "Difference between means" "db dimean"
window menu append item "Distributive tools" "Proportion" "db iprop"
window menu append item "Distributive tools" "Difference between proportions" "db diprop"
window menu append separator "Distributive tools"

window menu append item "Distributive tools" "Hypothesis testing" "db datest"







window menu append item "Dominance" /* 
        */   "Poverty dominance"    "db dompov"
        
window menu append item "Dominance" /* 
        */   "Inequality dominance"    "db domineq"   
        
window menu append separator "Dominance"

window menu append item "Dominance" /* 
        */   "Bi-dimensional poverty dominance"    "db dombdpov"  
		

window menu append separator "Dominance"
window menu append item "Dominance" "Consumption dominance curves"                                                 "db cdomc"
window menu append item "Dominance" "Difference -Ratio- between consumption dominance curves"                      "db cdomc2d"



window menu append item "Poverty and targeting policies" /* 
        */   "Targeting by population groups"    "db itargetg" 
		
window menu append item "Poverty and targeting policies" /* 
        */   "Targeting by population groups and fixed budget"    "db ogtpr" 		

window menu append item "Poverty and targeting policies" /* 
        */   "Bi-dimensional poverty and targeting by population groups"    "db itargetg2d" 
        

window menu append item "Poverty and targeting policies" /* 
        */   "Targeting by income components"    "db itargetc" 

window menu append item "Pro-poor" /* 
        */   "Pro-poor indices"    "db ipropoor" 
		
window menu append item "Pro-poor" /* 
        */   "Pro-poor curves: Growth Incidence Curve"    "db gicur" 		

window menu append item "Pro-poor" /* 
        */   "Pro-poor curves: primal approach"    "db cpropoorp" 
window menu append item "Pro-poor" /* 
        */   "Pro-poor curves: dual approach"    "db cpropoord" 
                  


window menu append item "Benefit analysis" /* 
        */   "Benefit incidence analysis"    "db bian" 
window menu append item "Benefit analysis" /* 
        */   "Marginal benefit incidence analysis"    "db imbi" 

		
		
window menu append item "Disaggregating data" /* 
        */   "Disaggregating grouped data"    "db ungroup" 

        


       
       
window menu refresh
}
end
