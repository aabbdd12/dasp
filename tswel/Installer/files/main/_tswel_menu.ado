

cap program drop _tswel_menu
program define _tswel_menu
qui { 
/*window menu clear*/
window menu append submenu "stUser" "&TSWEL"
window menu append submenu "TSWEL"   "&Tobacco and Social Welfare" 
window menu append submenu "TSWEL"   "&Tobacco and Elasticities"

		
window menu append item "Tobacco and Social Welfare" /* 
        */   "Tobacco Tax Reform and Social Welfare"        "db ttrwel" 
			
window menu append item "Tobacco and Elasticities" /* 
        */   "Tobacco Tax and Elasticities by deciles"     "db tobelas" 
        
window menu append separator "TSWEL"   


window menu append item "TSWEL" /* 
        */   "TSWEL Package Manager "  "db tswel" 
  
window menu refresh
}
end
