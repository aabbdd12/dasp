*! version 1.00  JUNE-2017  Abdelkrim Araar , Sergio Olivieri  and Carlos Rodriguez Castelan 

/*************************************************************************/
/* MIWEL: Market Imperfection and WELl-beinfg Stata Toolkit (Version 1.0)*/
/*************************************************************************/
/* World Bank Group (2017-2018)		                                 */
/* 									 */
/* [1] email : aabd@ecn.ulaval.ca                                        */
/* [1] Phone : 1 418 656 7507                                            */
/*************************************************************************/


cap program drop _miwel_menu
program define _miwel_menu
qui { 
/*window menu clear*/
window menu append submenu "stUser" "&MIWEL"
window menu append submenu "MIWEL"   "&Market concentration" 

		
window menu append item "Market concentration" /* 
        */   "Market concentration and well-being"        "db mcwel" 
			
		
window menu append separator "MIWEL"   


window menu append item "MIWEL" /* 
        */   "MIWEL Package Manager "  "db miwel" 
  
window menu refresh
}
end
