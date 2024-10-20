

#delimit ;

capture program drop asdbsave_dasp;
program define asdbsave_dasp, rclass sortpreserve;
version 9.2;
syntax varlist(min=1)[, HSize(varname) HGroup(varlist) ALpha(real 0) PLine(string) 
OPL(string) PROP(real 50) PERC(real 0.4) REL(string) type(string) INDex(string) CONF(string)
RANK(varname)  EPSIlon(real 0.5) THETA(real 1)  p1(real 0.1) p2(real 0.2) p3(real 0.8) p4(real 0.9)
LEVEL(real 95) DEC1(int 6) DEC2(int 6) INISAVE(string) diabox(string)
FAST(int 0) BAND(string) NG(int 4) Beta(real 1) NITR(int 16) PRCS(real 0.000001)  GNumber(int 1)
XFIL(string) XSHE(string)  XLAN(string) XTIT(string) MODREP(string)
];


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
tokenize `varlist' ;

file write myfile `".`diabox'_dlg.main.vn_y.setvalue   `varlist'  "'  _n;
file write myfile `".`diabox'_dlg.main.vn_hs.setvalue  `hsize' "' _n;
file write myfile `".`diabox'_dlg.main.vn_gr.setvalue  `hgroup' "' _n;
	

if ("`diabox'" == "ipov") {;
   if "`type'" ~= "" file write myfile `".`diabox'_dlg.main.cb_nor.setvalue   `type'  "'  _n;
/* Specific */
if "`pline'" ~= "" {;
file write myfile `".`diabox'_dlg.main.rb_a1.seton  "'  _n;
file write myfile `".`diabox'_dlg.main.vn_pl1.setvalue   `pline'  "'  _n;
};	

if "`pline'" == "" {;
file write myfile `".`diabox'_dlg.main..rb_r1.seton `'"'  _n;

if "`opl'" == "mean" {;
file write myfile `".`diabox'_dlg.main.cb_pl1.setvalue mean "'  _n;
file write myfile `".`diabox'_dlg.main.prop1.setvalue `prop' "'  _n;
};

if "`opl'" == "median" {;
file write myfile `".`diabox'_dlg.main.cb_pl1.setvalue median "'  _n;
file write myfile `".`diabox'_dlg.main.prop1.setvalue `prop' "'  _n;
};

if "`opl'" == "quantile" {;
file write myfile `".`diabox'_dlg.main.cb_pl1.setvalue quantile "'  _n;
file write myfile `".`diabox'_dlg.main.prop1.setvalue `prop' "'  _n;
file write myfile `".`diabox'_dlg.main.perc1.setvalue `perc' "'  _n;
};

file write myfile `".`diabox'_dlg.main.cb_rela.setvalue `rel' "'  _n;

file write myfile `".`diabox'_dlg.main.ed_al.setvalue    `alpha'  "'  _n;
};

};

if ("`diabox'" == "ineq") {;

if "`rank'" ~= "" file write myfile  `".`diabox'_dlg.main.var_index34.setvalue `rank'  "'  _n;
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
	


	
if ("`diabox'" == "ipola") {;

if ("`index'" == "der" ) {;
                   file write myfile `".`diabox'_dlg.main.ed_al1.setvalue  `alpha' "'  _n;
if `fast' == 1     file write myfile `".`diabox'_dlg.main.chk_fast1.seton          "'  _n;
if "`band'"~= ""   file write myfile `".`diabox'_dlg.main.en_width1.setvalue  `band' "'  _n;
};

if ("`index'" == "egr" ) {;
					file write myfile `".`diabox'_dlg.main.ed_al3.setvalue  `alpha' "'  _n;
					file write myfile `".`diabox'_dlg.main.ed_be3.setvalue  `beta' "'   _n;
					file write myfile `".`diabox'_dlg.main.ed_ngr3.setvalue  `ng' "'   _n;
					file write myfile `".`diabox'_dlg.main.ed_nit3.setvalue  `nitr' "'   _n;
					file write myfile `".`diabox'_dlg.main.ed_prc3.setvalue  `prcs' "'   _n;

};

if ("`index'" == "in" ) {;

                    file write myfile `".`diabox'_dlg.main.ed_al4.setvalue  `alpha' "'  _n;
					if `fast' == 1     file write myfile `".`diabox'_dlg.main.chk_fast4.seton          "'  _n;
					if "`band'"~= ""   file write myfile `".`diabox'_dlg.main.en_width4.setvalue  `band' "'  _n;

};

};


/*    Specific      */

/* Stat Inf */
if "`level'" ~= "" file write myfile `".`diabox'_dlg.confop.sp_level.setvalue  `level'  "'  _n;
if "`conf'" ~= ""  file write myfile `".`diabox'_dlg.confop.cb_ci.setvalue     `conf'  "'  _n;
if "`test'" ~= ""  {;
  file write myfile `".`diabox'_dlg.confop.ck_test.seton  "'  _n; 
  file write myfile `".`diabox'_dlg.confop.en_test.setvalue `test' "'  _n;   
}; 

if "`dec1'" ~= ""  file write myfile `".`diabox'_dlg.resop.sp_dec1.setvalue `dec1'  "'  _n;  
if "`dec2'" ~= ""  file write myfile `".`diabox'_dlg.resop.sp_dec1.setvalue `dec2'  "'  _n;  



if "`xfil'" ~= ""  {;
	file write myfile `".`diabox'_dlg.resop.fnamex.setvalue `xfil'  "'  _n;  
	file write myfile `".`diabox'_dlg.resop.ck_xls.seton  "'  _n;  
};
 

if "`xshe'" ~= ""  file write myfile `".`diabox'_dlg.resop.ed_she.setvalue `xshe'  "'  _n;  
if "`xtit'" ~= ""  file write myfile `".`diabox'_dlg.resop.ed_tit.setvalue `dec1'  "'  _n;  
if "`modrep'" ~= ""  file write myfile `".`diabox'_dlg.resop.cb_modrep.setvalue `modrep'  "'  _n;  



						
/* Stat Inf */

file close myfile;




end;




