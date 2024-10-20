*! version 1.00  JUNE-2017  Abdelkrim Araar , Sergio Olivieri  and Carlos Rodriguez Castelan 

/*************************************************************************/
/* WELCOM: Market Imperfection and WELl-beinfg Stata Toolkit (Version 1.0)*/
/*************************************************************************/
/* World Bank Group (2017-2018)		                                 */
/* 									 */
/* [1] email : aabd@ecn.ulaval.ca                                        */
/* [1] Phone : 1 418 656 7507                                            */
/*************************************************************************/


cap program drop _welcom_menu
program define _welcom_menu
qui { 
/*window menu clear*/
window menu append submenu "stUser" "&WELCOM"
window menu append submenu "WELCOM"   "&Market concentration" 
window menu append submenu "WELCOM"   "&Demand System Models"

		
window menu append item "Market concentration" /* 
        */   "Market concentration and well-being"        "db mcwel" 
			
		
window menu append separator "WELCOM"   

window menu append item "Demand System Models" /* 
        */   "The DUVM model"        "db duvm" 
window menu append item "Demand System Models" /* 
        */   "The AIDS/QUAIDS model(s)"        "db wquaids" 
window menu append item "Demand System Models" /* 
        */   "The EASI model"        "db sr_easi" 


window menu append item "WELCOM" /* 
        */   "WELCOM Package Manager "  "db welcom" 
  
window menu refresh
}
end
