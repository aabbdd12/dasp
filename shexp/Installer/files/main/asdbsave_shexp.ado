

#delimit ;

capture program drop asdbsave_shexp;
program define asdbsave_shexp, rclass sortpreserve;
version 9.2;
syntax varlist(min=1 max=1) [, 
TOTPUB(varname)	
EXPEXM(varname)	
EXPEXF(varname)
EXPEXK(varname)	

FSHARE(varname)

VLIST(varlist)
ILIST(varlist)

LIENGF(varlist)	
LIENGM(varlist)
LIENGK(varlist)

NKID(varname)
AVAGEK(varname)	

NFEMALE(varname)
AVAGEF(varname)	

NMALE(varname)
AVAGEM(varname)	

NBOYS(varname)	
OTHERV(varlist)

COLMOD(int 1)
TYMOD(int 1)

TECHnique(string)
FROM(string)
INISAVE(string)
DEC(int 4)
XFIL(string)  
DGRA(int 1) 
* 
*
];


tokenize "`inisave'" ,  parse(".");
local inisave = "`1'";
    

local mylist secp pr;

   tokenize `varlist';
   cap file close myfile;
   tempfile  myfile;
   cap erase "`inisave'.shexp" ;
   file open myfile   using "`inisave'.shexp", write replace ;
   if ("`inisave'"~="")  file write myfile `".shexp_dlg.main.dbsamex.setvalue "`inisave'""' _n; 
    
file write myfile `".shexp_dlg.main.var_totexp.setvalue "`1'""' _n;
file write myfile `".shexp_dlg.main.var_totpub.setvalue "`totpub'""' _n;

file write myfile `".shexp_dlg.main.var_expexm.setvalue "`expexm'""' _n;
file write myfile `".shexp_dlg.main.var_expexf.setvalue "`expexf'""' _n;
file write myfile `".shexp_dlg.main.var_expexk.setvalue "`expexk'""' _n;

file write myfile `".shexp_dlg.main.var_fshare.setvalue "`fshare'""' _n;

file write myfile `".shexp_dlg.main.varlist_texp.setvalue "`vlist'""' _n;
file write myfile `".shexp_dlg.main.inslist_texp.setvalue "`ilist'""' _n;

file write myfile `".shexp_dlg.main.var_liengf.setvalue "`liengf'""' _n;
file write myfile `".shexp_dlg.main.var_liengm.setvalue "`liengm'""' _n;
file write myfile `".shexp_dlg.main.var_liengk.setvalue "`liengk'""' _n;


file write myfile `".shexp_dlg.main.var_nmales.setvalue "`nmale'""' _n;
file write myfile `".shexp_dlg.main.var_avagem.setvalue "`avagem'""' _n;

file write myfile `".shexp_dlg.main.var_nfemales.setvalue "`nfemale'""' _n;
file write myfile `".shexp_dlg.main.var_avagef.setvalue "`avagef'""' _n;

file write myfile `".shexp_dlg.main.var_nkids.setvalue "`nkid'""' _n;
file write myfile `".shexp_dlg.main.var_avagek.setvalue "`avagek'""' _n;

file write myfile `".shexp_dlg.main.var_nboys.setvalue "`nboys'""' _n;
file write myfile `".shexp_dlg.main.var_other.setvalue "`otherv'""' _n;

file write myfile `".shexp_dlg.main.cb_cmod.setvalue "`colmod'""' _n;
file write myfile `".shexp_dlg.main.cb_tyd.setvalue "`tymod'""' _n;




/*
IN PROG
file write myfile `".shexp_dlg.max_ml.cb_tech.setvalue "`technique'""' _n;
file write myfile `".shexp_dlg.max_ml.ed_from.setvalue "`from'""' _n; 
if "`difficult'"~="" file write myfile `".shexp_dlg.max_ml.ck_diff.seton "' _n;
ck_diff         option(difficult)                                               
sp_iter_i       option(iterate)         
                                 

rb_trace_pa     option(trace)
rb_nolog_pa     option(nolog) last
ck_trace        option(trace)
ck_grad         option(gradient)
ck_show         option(showstep)
ck_hess         option("hessian")                                               
ck_shownr       option(showtolerance)

ed_tol               option(tolerance) 
ed_nrtol             option(nrtolerance) default(1e-5)
ed_ltol              option(ltolerance) default(1e-7)
ed_gtol              option(gtolerance)
ck_nonrtol           option(nonrtolerance)                                           ///
ed_from              option(from)
*/

if ("`dregres'"=="1")         file write myfile `".shexp_dlg.resop.ck_dregres.seton "' _n; 
if ("`dislas'"=="1")          file write myfile `".shexp_dlg.resop.ck_dislas.seton "' _n; 
   if ("`rtool'"~="") {;
   file write myfile `".shexp_dlg.main.drtool.setvalue "`rtool'""' _n;
   };
   
 /* if ("`dec'"   ~="")             file write myfile `".shexp_dlg.resop.sp_dec.setvalue "`dec'""' _n; */
 
   if ("`xfil'"~="") {;
   file write myfile `".shexp_dlg.resop.xfil.setvalue "`xfil'""' _n;
   };

 /* file write myfile `"cap use `nfile' , replace"'  _n; 
 
  */
 file close myfile;




end;




