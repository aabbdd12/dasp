
*  ----------------------------------------------------------------------------
*  1. Main program                                                             
*  ----------------------------------------------------------------------------
cap program drop shexp_examples
program shexp_examples
version 9.2
args EXAMPLE
set more off
`EXAMPLE'
end



cap program drop ex_shexp_01
program ex_shexp_01
#delimit ; 
use http://dasp-two.vercel.app/shexp/examples/fdata.dta , replace; 
shexp totexp , 
expexm(excl_m) expexf(excl_f) expexk(excl_k) 
fshare(f_share) 
vlist(age edu  iwshare  urban nuclear) 
ilist(lind) 
liengf(agem2 urban nuclear) 
liengm(agem1 urban nuclear) 
liengk(nkid m_age  cwprice avage  urban  nuclear) 
nkid(nkid) 
avagek(avage) 
nboys(nboys)
otherv(iwshare urban  nuclear) 
colmod(1) tymod(1)  
inisave(mycexample) 
xfil(myres.xml)
;

end;

#delimit cr
cap program drop ex_shexp_db_01
program ex_shexp_db_01
use http://dasp-two.vercel.app/shexp/examples/fdata.dta , replace
discard
db shexp
.shexp_dlg.main.dbsamex.setvalue "mycexample"
.shexp_dlg.main.var_totexp.setvalue "totexp"
.shexp_dlg.main.var_expexm.setvalue "excl_m"
.shexp_dlg.main.var_expexf.setvalue "excl_f"
.shexp_dlg.main.var_expexk.setvalue "excl_k"
.shexp_dlg.main.var_fshare.setvalue "f_share"
.shexp_dlg.main.varlist_texp.setvalue "age edu iwshare urban nuclear"
.shexp_dlg.main.inslist_texp.setvalue "lind"
.shexp_dlg.main.var_liengf.setvalue "agem2 urban nuclear"
.shexp_dlg.main.var_liengm.setvalue "agem1 urban nuclear"
.shexp_dlg.main.var_liengk.setvalue "nkid m_age cwprice avage urban nuclear"
.shexp_dlg.main.var_nkids.setvalue "nkid"
.shexp_dlg.main.var_avagek.setvalue "avage"
.shexp_dlg.main.var_nboys.setvalue "nboys"
.shexp_dlg.main.var_other.setvalue "iwshare urban nuclear"
.shexp_dlg.main.cb_cmod.setvalue "1"
.shexp_dlg.main.cb_tyd.setvalue "1"
.shexp_dlg.resop.xfil.setvalue "myres.xml"
#delimit cr
end
