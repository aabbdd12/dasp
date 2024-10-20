

#delimit ;

capture program drop asdbsave_difgt;
program define asdbsave_difgt, rclass sortpreserve;
version 9.2;
syntax  namelist(min=2 max=2) [, FILE1(string) FILE2(string) HSize1(string) HSize2(string)
ALpha(real 0)  COND1(string) COND2(string) 
PLINE1(string) OPL1(string) PROP1(real 50) PERC1(real 0.4)
PLINE2(string) OPL2(string) PROP2(real 50) PERC2(real 0.4)
type(string) LEVEL(real 95) CONF(string) DEC(int 6) BOOT(string) NREP(string) TEST(string)
INISAVE(string) COMMAND(string)
];

tokenize "`inisave'" ,  parse(".");
local inisave = "`1'";
    

local mylist secp pr;

   tokenize `namelist';
   cap file close myfile;
   tempfile  myfile;
   cap erase "`inisave'_difgt.dasp" ;
   file open myfile   using "`inisave'_difgt.dasp", write replace ;
   if ("`inisave'"~="")  file write myfile `".difgt_dlg.main.dbsamex.setvalue "`inisave'""' _n; 

/* Common */ 	
set trace on ;
set tracedepth 2;
if "`file1'"~="" {;	
file write myfile `".difgt_dlg.main.fi_d1.setvalue 2 "' _n;
file write myfile `".difgt_dlg.isLoading1.settrue "'   _n;
file write myfile `".difgt_dlg.main.file_d1.setvalue "`file1'""' _n; 
file write myfile `".difgt_dlg.isLoading1.setfalse  "' _n; 
file write myfile `" GetLevels_DB  `file1' , mia(en_y_d1  en_hhs_d1 en_pl1) ndb(difgt) "' _n;
};

if "`file1'"=="" file write myfile `".difgt_dlg.main.vn_y_d1.setvalue   `1'  "'  _n;
if "`file1'"~="" file write myfile `".difgt_dlg.main.en_y_d1.setvalue   `1' "' _n; 
	
if "`file1'"=="" file write myfile `".difgt_dlg.main.vn_hhs_d1.setvalue  `hsize1' "' _n;
if "`file1'"~="" file write myfile `".difgt_dlg.main.en_hhs_d1.setvalue  `hsize1' "' _n; 	

if "`cond1'"~="" file write myfile `".difgt_dlg.main.chk_cd1.seton "' _n;
file write myfile `".difgt_dlg.main.ed_d1c1.setvalue "`cond1'""' _n;  



if "`file2'"~="" {;	
file write myfile `".difgt_dlg.main.fi_d2.setvalue 2 "' _n;
file write myfile `".difgt_dlg.isLoading2.settrue "'   _n;
file write myfile `".difgt_dlg.main.file_d2.setvalue "`file2'""' _n; 
file write myfile `".difgt_dlg.isLoading2.setfalse  "' _n; 
file write myfile `" GetLevels_DB  `file2' , mia(en_y_d2  en_hhs_d2 en_pl2) ndb(difgt) "' _n;
};

if "`file2'"=="" file write myfile `".difgt_dlg.main.vn_y_d2.setvalue   `2' "'  _n;
if "`file2'"~="" file write myfile `".difgt_dlg.main.en_y_d2.setvalue   `2' "' _n; 
	
if "`file2'"=="" file write myfile `".difgt_dlg.main.vn_hhs_d2.setvalue  `hsize2' "' _n;
if "`file2'"~="" file write myfile `".difgt_dlg.main.en_hhs_d2.setvalue  `hsize2' "' _n; 	

if "`cond2'"~="" file write myfile `".difgt_dlg.main.chk_cd2.seton "' _n;
file write myfile `".difgt_dlg.main.ed_d2c1.setvalue "`cond2'""' _n;  
/* Common */ 

/* Specific */
if "`pline1'" ~= "" {;
file write myfile `".difgt_dlg.main.rb_a1.seton  "'  _n;
if "`file1'"=="" file write myfile `".difgt_dlg.main.vn_pl1.setvalue   `pline1'  "'  _n;
if "`file1'"~="" file write myfile `".difgt_dlg.main.en_pl1.setvalue  `pline1' "' _n; 
};	

if "`pline1'" == "" {;
file write myfile `".difgt_dlg.main..rb_r1.seton `'"'  _n;
if "`opl1'" == "mean" {;
file write myfile `".difgt_dlg.main.cb_pl1.setvalue mean "'  _n;
file write myfile `".difgt_dlg.main.prop1.setvalue `prop1' "'  _n;
};

if "`opl1'" == "median" {;
file write myfile `".difgt_dlg.main.cb_pl1.setvalue median "'  _n;
file write myfile `".difgt_dlg.main.prop1.setvalue `prop1' "'  _n;
};

if "`opl1'" == "quantile" {;
file write myfile `".difgt_dlg.main.cb_pl1.setvalue quantile "'  _n;
file write myfile `".difgt_dlg.main.prop1.setvalue `prop1' "'  _n;
file write myfile `".difgt_dlg.main.perc1.setvalue `perc1' "'  _n;
};
};


if "`pline2'" ~= "" {;
file write myfile `".difgt_dlg.main.rb_a2.seton  "'  _n;
if "`file2'"=="" file write myfile `".difgt_dlg.main.vn_pl2.setvalue   `pline2'  "'  _n;
if "`file2'"~="" file write myfile `".difgt_dlg.main.en_pl2.setvalue  `pline2' "' _n; 
};

if "`pline2'" == "" {;
file write myfile `".difgt_dlg.main..rb_r2.seton `'"'  _n;
if "`opl2'" == "mean" {;
file write myfile `".difgt_dlg.main.cb_pl2.setvalue mean "'  _n;
file write myfile `".difgt_dlg.main.prop2.setvalue `prop2' "'  _n;
};

if "`opl2'" == "median" {;
file write myfile `".difgt_dlg.main.cb_pl2.setvalue median "'  _n;
file write myfile `".difgt_dlg.main.prop2.setvalue `prop2' "'  _n;
};

if "`opl2'" == "quantile" {;
file write myfile `".difgt_dlg.main.cb_pl2.setvalue quantile "'  _n;
file write myfile `".difgt_dlg.main.prop2.setvalue `prop2' "'  _n;
file write myfile `".difgt_dlg.main.perc2.setvalue `perc2' "'  _n;
};
};		

file write myfile `".difgt_dlg.main.ed_al.setvalue    `alpha'  "'  _n;
if "`type'" == "not" {;
file write myfile `".difgt_dlg.main.cb_nor.setvalue   2       "'  _n;
};

/*    Specific      */

/* Stat Inf */
if "`level'" ~= "" file write myfile `".difgt_dlg.confop.sp_level.setvalue  `level'  "'  _n;
if "`conf'" ~= ""  file write myfile `".difgt_dlg.confop.cb_ci.setvalue     `conf'  "'  _n;
if "`test'" ~= ""  {;
  file write myfile `".difgt_dlg.confop.ck_test.seton  "'  _n; 
  file write myfile `".difgt_dlg.confop.en_test.setvalue `test' "'  _n;   
}; 
/* Stat Inf */

set trace off;
file close myfile;




end;




