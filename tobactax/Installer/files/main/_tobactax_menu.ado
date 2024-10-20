

cap program drop _tobactax_menu
program define   _tobactax_menu
qui { 
/*window menu clear*/
window menu append submenu "stUser" "&TOBACTAX"
window menu append submenu "TOBACTAX"   "&Tobacco and Taxes" 
window menu append submenu "TOBACTAX"   "&Tobacco and Elasticities"

		
window menu append item "Tobacco and Taxes" /* 
        */   "Tobacco and Tax Reform"        "db tobatref" 
			
window menu append item "Tobacco and Elasticities" /* 
        */   "Tobacco Tax and Elasticities by deciles"     "db tobelas" 
        
window menu append separator "TOBACTAX"   


window menu append item "TOBACTAX" /* 
        */   "TOBACTAX Package Manager "  "db tobactax" 
  
window menu refresh
}
end
