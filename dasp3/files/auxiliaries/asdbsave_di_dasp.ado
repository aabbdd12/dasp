

#delimit ;

capture program drop asdbsave_di_dasp;
program define asdbsave_di_dasp, rclass sortpreserve;
version 9.2;
syntax  namelist(min=2 max=2) [, FILE1(string) FILE2(string) HSize1(string) HSize2(string)
ALpha(real 0)  COND1(string) COND2(string)  HGroup(varlist)
PLINE1(string) OPL1(string) PROP1(real 50) PERC1(real 0.4)
PLINE2(string) OPL2(string) PROP2(real 50) PERC2(real 0.4)
type(string) LEVEL(real 95) CONF(string) DEC(int 6) BOOT(string) NREP(string) TEST(string)
RANK1(string)  RANK2(string)
EPSIlon(real 0.5)  THETA(real 1) p1(real 0.1) p2(real 0.2) p3(real 0.8) p4(real 0.9)
INISAVE(string) index(string) diabox(string)
FAST(int 0) BAND(string)
XFIL(string) XSHE(string)  XLAN(string) XTIT(string) MODREP(string)
dec1(int 4)
dec2(int 4)
];




local inisave = usubinstr("`inisave'","_`diabox'","",.) ;
tokenize "`inisave'" ,  parse(".");
local inisave = "`1'";



local mylist secp pr;

   tokenize `namelist';
   cap file close myfile;
   tempfile  myfile;
   local inisave = usubinstr("`inisave'","_`diabox'","",.) ;
   cap erase                "`inisave'_`diabox'.dasp" ;
   file open myfile   using "`inisave'_`diabox'.dasp", write replace ;
   
   
   if ("`inisave'"~="")  file write myfile `".`diabox'_dlg.main.dbsamex.setvalue "`inisave'""' _n; 
   
file write myfile `".`diabox'_dlg.main.cb_index.setvalue   `index'  "'  _n;
/* Common */ 	
file write myfile `".`diabox'_dlg.main.vn_gr.setvalue  `hgroup' "' _n;
file write myfile `".`diabox'_dlg.main.ed_gr.setvalue  `hgroup' "' _n;
if "`file1'"~="" {;	
file write myfile `".`diabox'_dlg.main.fi_d1.setvalue 2 "' _n;
file write myfile `".`diabox'_dlg.isLoading1.setfalse "'   _n;
file write myfile `".`diabox'_dlg.main.file_d1.setvalue "`file1'""' _n; 
file write myfile `".`diabox'_dlg.isLoading1.setfalse  "' _n; 
if ("`diabox'" == "dipov")  file write myfile `" GetLevels_DB  `file1' , mia(en_y_d1  en_hhs_d1 en_pl1) ndb(`diabox') "' _n;
if ("`diabox'" == "dineq")  file write myfile `" GetLevels_DB  `file1' , mia(en_y_d1  en_hhs_d1 en_rank_d1) ndb(`diabox') "' _n;
};

if "`file1'"=="" file write myfile `".`diabox'_dlg.main.vn_y_d1.setvalue   `1'  "'  _n;
if "`file1'"~="" file write myfile `".`diabox'_dlg.main.en_y_d1.setvalue   `1' "' _n; 
	
if "`file1'"=="" file write myfile `".`diabox'_dlg.main.vn_hhs_d1.setvalue  `hsize1' "' _n;
if "`file1'"~="" file write myfile `".`diabox'_dlg.main.en_hhs_d1.setvalue  `hsize1' "' _n; 	

if "`cond1'"~="" file write myfile `".`diabox'_dlg.main.chk_cd1.seton "' _n;
file write myfile `".`diabox'_dlg.main.ed_d1c1.setvalue "`cond1'""' _n;  

if "`file1'"==""  file write myfile `".`diabox'_dlg.main.vn_gr.setvalue  `hgroup' "' _n;
if "`file1'"~=""  file write myfile `".`diabox'_dlg.main.ed_gr.setvalue  `hgroup' "' _n;

if "`file2'"~="" {;	
file write myfile `".`diabox'_dlg.main.fi_d2.setvalue 2 "' _n;
file write myfile `".`diabox'_dlg.isLoading2.setfalse "'   _n;
file write myfile `".`diabox'_dlg.main.file_d2.setvalue "`file2'""' _n; 
file write myfile `".`diabox'_dlg.isLoading2.setfalse  "' _n; 
if ("`diabox'" == "dipov")  file write myfile `" GetLevels_DB  `file2' , mia(en_y_d2  en_hhs_d2 en_pl2) ndb(`diabox') "' _n;
if ("`diabox'" == "dineq")  file write myfile `" GetLevels_DB  `file2' , mia(en_y_d2  en_hhs_d2 en_rank_d2) ndb(`diabox') "' _n;
};

if "`file2'"=="" file write myfile `".`diabox'_dlg.main.vn_y_d2.setvalue   `2' "'  _n;
if "`file2'"~="" file write myfile `".`diabox'_dlg.main.en_y_d2.setvalue   `2' "' _n; 
	
if "`file2'"=="" file write myfile `".`diabox'_dlg.main.vn_hhs_d2.setvalue  `hsize2' "' _n;
if "`file2'"~="" file write myfile `".`diabox'_dlg.main.en_hhs_d2.setvalue  `hsize2' "' _n; 	

if "`cond2'"~="" file write myfile `".`diabox'_dlg.main.chk_cd2.seton "' _n;
file write myfile `".`diabox'_dlg.main.ed_d2c1.setvalue "`cond2'""' _n;  
/* Common */ 

/* Specific to poverty */
if ("`diabox'" == "dipov") {;
if "`pline1'" ~= "" {;
file write myfile `".`diabox'_dlg.main.rb_a1.seton  "'  _n;
if "`file1'"=="" file write myfile `".`diabox'_dlg.main.vn_pl1.setvalue   `pline1'  "'  _n;
if "`file1'"~="" file write myfile `".`diabox'_dlg.main.en_pl1.setvalue  `pline1' "' _n; 
};	

if "`pline1'" == "" {;
file write myfile `".`diabox'_dlg.main..rb_r1.seton `'"'  _n;
if "`opl1'" == "mean" {;
file write myfile `".`diabox'_dlg.main.cb_pl1.setvalue mean "'  _n;
file write myfile `".`diabox'_dlg.main.prop1.setvalue `prop1' "'  _n;
};

if "`opl1'" == "median" {;
file write myfile `".`diabox'_dlg.main.cb_pl1.setvalue median "'  _n;
file write myfile `".`diabox'_dlg.main.prop1.setvalue `prop1' "'  _n;
};

if "`opl1'" == "quantile" {;
file write myfile `".`diabox'_dlg.main.cb_pl1.setvalue quantile "'  _n;
file write myfile `".`diabox'_dlg.main.prop1.setvalue `prop1' "'  _n;
file write myfile `".`diabox'_dlg.main.perc1.setvalue `perc1' "'  _n;
};
};


if "`pline2'" ~= "" {;
file write myfile `".`diabox'_dlg.main.rb_a2.seton  "'  _n;
if "`file2'"=="" file write myfile `".`diabox'_dlg.main.vn_pl2.setvalue   `pline2'  "'  _n;
if "`file2'"~="" file write myfile `".`diabox'_dlg.main.en_pl2.setvalue  `pline2' "' _n; 
};

if "`pline2'" == "" {;
file write myfile `".`diabox'_dlg.main..rb_r2.seton `'"'  _n;
if "`opl2'" == "mean" {;
file write myfile `".`diabox'_dlg.main.cb_pl2.setvalue mean "'  _n;
file write myfile `".`diabox'_dlg.main.prop2.setvalue `prop2' "'  _n;
};

if "`opl2'" == "median" {;
file write myfile `".`diabox'_dlg.main.cb_pl2.setvalue median "'  _n;
file write myfile `".`diabox'_dlg.main.prop2.setvalue `prop2' "'  _n;
};

if "`opl2'" == "quantile" {;
file write myfile `".`diabox'_dlg.main.cb_pl2.setvalue quantile "'  _n;
file write myfile `".`diabox'_dlg.main.prop2.setvalue `prop2' "'  _n;
file write myfile `".`diabox'_dlg.main.perc2.setvalue `perc2' "'  _n;
};
};		

file write myfile `".`diabox'_dlg.main.ed_al.setvalue    `alpha'  "'  _n;
if "`type'" == "not" {;
file write myfile `".`diabox'_dlg.main.cb_nor.setvalue   2       "'  _n;
};


 };
/*    Specific      */

if ("`diabox'" == "dineq") {;

if "`rank1'" ~= "" {;
	if "`file1'"==""  file write myfile  `".`diabox'_dlg.main.vn_rank_d1.setvalue `rank1'  "'  _n;
	if "`file1'"~=""  file write myfile  `".`diabox'_dlg.main.en_rank_d1.setvalue `rank1'  "'  _n;
};
if "`rank2'" ~= "" {;
	if "`file2'"==""  file write myfile  `".`diabox'_dlg.main.vn_rank_d2.setvalue `rank2'  "'  _n;
	if "`file2'"~=""  file write myfile  `".`diabox'_dlg.main.en_rank_d2.setvalue `rank2'  "'  _n;
};

if "`epsilon'" ~= "" file write myfile `".`diabox'_dlg.main.edt_index5.setvalue `epsilon'   "'  _n;
if "`theta'" ~= "" file write myfile `".`diabox'_dlg.main.edt_index6.setvalue  `theta'  "'  _n;

if ("`index'" == "qr" ) {;
if "`p1'" ~= "" file write myfile `".`diabox'_dlg.main.edt_index81.setvalue  `p1' "'  _n;
if "`p2'" ~= "" file write myfile `".`diabox'_dlg.main.edt_index82.setvalue  `p2'  "'  _n;

};

if ("`index'" == "sr") {;
if "`p1'" ~= "" file write myfile `".`diabox'_dlg.main.edt_index91.setvalue `p1'  "'  _n;
if "`p2'" ~= "" file write myfile `".`diabox'_dlg.main.edt_index92.setvalue `p2'  "'  _n;
if "`p3'" ~= "" file write myfile `".`diabox'_dlg.main.edt_index93.setvalue `p3'  "'  _n;
if "`p4'" ~= "" file write myfile `".`diabox'_dlg.main.edt_index94.setvalue `p4' "'  _n;
};
};



	
if ("`diabox'" == "dipola") {;

if ("`index'" == "der" ) {;
                   file write myfile `".`diabox'_dlg.main.ed_al1.setvalue  `alpha' "'  _n;
if `fast' == 1     file write myfile `".`diabox'_dlg.main.chk_fast1.seton          "'  _n;
if "`band'"~= ""   file write myfile `".`diabox'_dlg.main.en_width1.setvalue  `band' "'  _n;
};

};

/* Stat Inf */
if "`level'" ~= "" file write myfile `".`diabox'_dlg.confop.sp_level.setvalue  `level'  "'  _n;
if "`conf'" ~= ""  file write myfile `".`diabox'_dlg.confop.cb_ci.setvalue     `conf'  "'  _n;


if "`test'" ~= ""  {;
  file write myfile `".`diabox'_dlg.confop.ck_test.seton  "'  _n; 
  file write myfile `".`diabox'_dlg.confop.en_test.setvalue `test' "'  _n;   
};
 
/* Stat Inf */

if "`dec1'" ~= ""  file write myfile `".`diabox'_dlg.resop.sp_dec1.setvalue `dec1'  "'  _n;  
if "`dec2'" ~= ""  file write myfile `".`diabox'_dlg.resop.sp_dec2.setvalue `dec2'  "'  _n;  



if "`xfil'" ~= ""  {;
	file write myfile `".`diabox'_dlg.resop.fnamex.setvalue `xfil'  "'  _n;  
	file write myfile `".`diabox'_dlg.resop.ck_xls.seton  "'  _n;  
};

if "`xshe'" ~= ""  file write myfile `".`diabox'_dlg.resop.ed_she.setvalue `xshe'  "'  _n;  
if "`xtit'" ~= ""  file write myfile `".`diabox'_dlg.resop.ed_tit.setvalue `xtit'  "'  _n;  
if "`modrep'" ~= ""  file write myfile `".`diabox'_dlg.resop.cb_modrep.setvalue `modrep'  "'  _n;  

file close myfile;




end;




