/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 3.01)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2026)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/ 
/*************************************************************************/
/* efgtgr.dlg                                                            */
/*************************************************************************/


VERSION 15.0

INCLUDE _std_xlarge
DEFINE  _dlght 380
DEFINE  _dlgwd 890
INCLUDE header


DIALOG main, label("DASP| Decomposition of the FGT index by income components (using the Shapley value) --> dfgts command") tabtitle("Main")

BEGIN
  
   
 GROUPBOX intvar       10     10    430  150,                      ///
           label("Variables of interest: ")
           


  
  TEXT     tx_var1      20    +25    150      .,                 ///
             label("Welfare components:   ")  
  
  VARLIST  vl_list      150    @     280      .,                


           
  TEXT     tx_var2      20    +25    150      .,                 ///
           label("Size  variable:   ")  
                   
  VARNAME  vn_hs      150    @     280      .,                 ///
           option(hsize) 
  

 
           

  


  GROUPBOX chk_per  450    10  430 150,                         ///
           label("Parameters: ")        
                   
    TEXT txt_al     +10    +35    180      .,                 ///  
                  label("Parameter alpha:   ")                           
       
    EDIT  ed_al    +180    @     220      .,                 ///
              option(alpha)    default(0)    
           
  
   TEXT txt_pl     460     +35    180      .,                 ///  
                  label("Poverty line level (z):   ")        
   
   VARNAME    vn_pl   +180    @     220      .,                 ///
           option(pline)                              ///
      

                 

   
     DEFINE _x 700
     DEFINE _y 350
     
  INCLUDE _bu_svyset
END







DIALOG resop,  tabtitle("Results")

BEGIN
					
SPINNER  sp_dec    10       25      50	  .,		        /*
   		*/ label("Decimals")				/*
   		*/ min(0) default(6) max(12)				/*
  		*/ option(dec)

TEXT     sp_txt  70      25      160	  .,		                /*
   		*/ label("Number of decimals")	
   		
CHECKBOX   chk_opd     +240    @    150    .,                   ///
             label("Display standard errors") option(dste) default(1)

   CHECKBOX ck_xls  10    60  430 160,		///
		 label(`"Save results in Excel format"')               ///
		 groupbox						///
		 option("txls")					///
		 onclickoff(program resop_xls)                      ///
                 onclickon(program resop_xls)                    ///
                 default(0)
  


       TEXT  tx_nxfile     20    +25    40      .,                 ///  
                   label("File :")                                  ///      
            
        
       FILE  fnamex      80    @     330      .,                 ///
        label ("Browse...")    save option("xfil")                   ///
        filter("MetaFile (*.xml)|*.xml|*.* (*.*)|*.*")  

       TEXT     tx_she  20   +25      40     .,			/*
		*/ label("Sheet:")			/*
		*/
       EDIT     ed_she  80    @       330   .,			/*
		*/ label("sheet")				/*
		*/ option("xshe") default("table 01")			/*
		*/   

      

      TEXT    tx_lan       20    +45    50      .,                            ///
           label("Language:") 


       COMBOBOX cb_lan        80    @   330   .,                              ///
            dropdownlist contents(cb_lan) values(cb_lan_val)               ///
             default(en)     option(xlan)     onselchangelist(cond_change)     

       TEXT     tx_tit  20   +25      40     .,			/*
		*/ label("Title:")			/*
		*/
       EDIT     ed_tit  80    @       330   .,			/*
		*/ label("Bandwidth of kernel")				/*
		*/ option("xtit") default("Table ##: Decomposition of poverty by...")					/*
		*/   

END


LIST cb_lan
BEGIN
  English
  Franais
END


LIST cb_lan_val
BEGIN
  en
  fr
END



SCRIPT PREINIT
BEGIN
	create BOOLEAN has_cond1
	create BOOLEAN has_cond2	
END

LIST cond_change
BEGIN
	script cond1
	script cond2	
END


SCRIPT cond1
BEGIN
	has_cond1.settrue
	has_cond2.setfalse
	program check_conds
END

SCRIPT cond2
BEGIN
	has_cond1.setfalse
	has_cond2.settrue
	program check_conds
END




PROGRAM check_conds
BEGIN

if (has_cond1){
call resop.ed_tit.setvalue "Table ##: Decomposition of poverty by..."
}

if has_cond2{
call resop.ed_tit.setvalue "Tableau ##: Dcomposition de la pauvret par..."
}



END


PROGRAM resop_xls
BEGIN
if resop.ck_xls  {
call resop.tx_nxfile.enable
call resop.fnamex.enable
call resop.tx_she.enable
call resop.ed_she.enable
call resop.tx_lan.enable
call resop.cb_lan.enable
call resop.tx_tit.enable
call resop.ed_tit.enable
}

if !resop.ck_xls {
call resop.tx_nxfile.disable
call resop.fnamex.disable
call resop.tx_she.disable
call resop.ed_she.disable
call resop.tx_lan.disable
call resop.cb_lan.disable
call resop.tx_tit.disable
call resop.ed_tit.disable
}
END



HELP hlp1,   view("help dfgtg")
RESET res1


PROGRAM command
BEGIN

        
	put "dfgtg "
        require  main.vl_list
        varlist [main.vl_list]
	
	beginoptions  

	                optionarg main.vn_hs
	                
		       
			optionarg main.ed_al
			optionarg main.vn_pl

			optionarg resop.fnamex
                        optionarg resop.ed_she

			if !resop.cb_lan.isdefault(){
			optionarg resop.cb_lan
			}

			if !resop.ed_tit.isdefault(){
			optionarg resop.ed_tit
			}
			
			if !resop.chk_opd.isdefault(){
			optionarg resop.chk_opd
			}
					
			if !main.cb_nor.isdefault() {
		        optionarg main.cb_nor
			}
			if !resop.sp_dec.isdefault() {
			optionarg resop.sp_dec
			}
					
			
        
        
END