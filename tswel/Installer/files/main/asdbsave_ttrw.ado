



#delimit ;

capture program drop asdbsave_ttrw;
program define asdbsave_ttrw, rclass sortpreserve;
version 9.2;
syntax varlist (min=2 max=2) [if] [in] [,  
HSize(string)  
DECile(string)
INISave(string) 
CONF(string) 
LEVEL(real 95)

XFIL(string)
TJOBS(string) 
GJOBS(string) 
FOLGR(string)
OPGR1(string) OPGR2(string)  OPGR3(string) 
FELAS(string)

ELASM(string)
ELASL(string)
ELASU(string)

MEDEXP(string)
TYLL(string)
PRINC(real 0.25)
DEC(int 6)
STE(int 0)
];


tokenize "`inisave'" ,  parse(".");
local inisave = "`1'";
    

local mylist min max ogr;
forvalues i=1/3 {;
if ("`opgr`i''"~="") {;
extend_opt_graph test , `opgr`i'' ;
foreach name of local mylist {;
local `name'`i' = r(`name');
if  "``name'`i''"=="." local `name'`i' = "" ;
};
};
};



local mylist secp pr;

   tokenize `varlist';
   cap file close myfile;
   tempfile  myfile;
   cap erase "`inisave'.trw" ;
   file open myfile   using "`inisave'.trw", write replace ;
   if ("`inisave'"~="")  file write myfile `".ttrwel_dlg.main.dbsamex.setvalue "`inisave'""' _n;
   file write myfile `".ttrwel_dlg.main.vn_pcexp.setvalue "`1'""' _n;
   file write myfile `".ttrwel_dlg.main.vn_tex.setvalue "`2'""' _n;
    if ("`hsize'"~="") file write myfile `".ttrwel_dlg.main.vn_hhs.setvalue "`hsize'""' _n;
	if ("`decile'"~="") file write myfile `".ttrwel_dlg.main.vn_dec.setvalue "`decile'""' _n;
    if ("`felas'"~="") file write myfile `".ttrwel_dlg.main.fnamex_ela.setvalue "`felas'""' _n;   
  
    if ("`elasm'"~="") file write myfile `".ttrwel_dlg.main.ed_velasm.setvalue "`elasm'""' _n;
    if ("`elasl'"~="") file write myfile `".ttrwel_dlg.main.ed_velasl.setvalue "`elasl'""' _n;
	if ("`elasu'"~="") file write myfile `".ttrwel_dlg.main.ed_velasu.setvalue "`elasu'""' _n;
    if ("`medexp'"~="") file write myfile `".ttrwel_dlg.main.ed_ehealth.setvalue "`medexp'""' _n;
    if ("`tyll'"~="")   file write myfile `".ttrwel_dlg.main.ed_wtime.setvalue "`tyll'""' _n;
	if ("`princ'"~="")   file write myfile `".ttrwel_dlg.main.ed_princ.setvalue "`princ'""' _n;
    
     if ("`folgr'"~="")  {;
   file write myfile `".ttrwel_dlg.gr_options_ttr.ck_folgr.seton"' _n;
   file write myfile `".ttrwel_dlg.gr_options_ttr.ed_folgr.setvalue "`folgr'""' _n;
   };

   
    if ("`tjobs'"~="") {;
   file write myfile `".ttrwel_dlg.tb_options_ttr.ck_tables.seton"' _n;
   file write myfile `".ttrwel_dlg.tb_options_ttr.ed_tab.setvalue "`tjobs'""' _n;
   };
   
   if ("`gjobs'"~="") {;
   file write myfile `".ttrwel_dlg.gr_options_ttr.ck_graphs.seton"' _n;
   file write myfile `".ttrwel_dlg.gr_options_ttr.ed_gra.setvalue "`gjobs'""' _n;
   };
   
   if ("`xfil'"~="") {;
   file write myfile `".ttrwel_dlg.tb_options_ttr.ck_excel.seton"' _n;
   file write myfile `".ttrwel_dlg.tb_options_ttr.fnamex.setvalue "`xfil'""' _n;
   };
   
  if (`ste'==1)     file write myfile `".ttrwel_dlg.tb_options_ttr.chk_ste.seton "' _n; 
  if (`dec'==1)     file write myfile `".ttrwel_dlg.tb_options_ttr.sp_dec.setvalue "`dec'""' _n;
  
  
   forvalues i=1/4 {;
   if ("`min`i''"~="")  file write myfile `".ttrwel_dlg.gr_options_ttr.en_min`i'.setvalue "`min`i''""' _n;
   if ("`max`i''"~="")  file write myfile `".ttrwel_dlg.gr_options_ttr.en_max`i'.setvalue "`max`i''""' _n;
   if ("`ogr`i''"~="")  file write myfile `".ttrwel_dlg.gr_options_ttr.en_opt`i'.setvalue `"`ogr`i''"' "' _n;
   };
   


 /* file write myfile `"cap use `nfile' , replace"'  _n; */
 file close myfile;







end;

