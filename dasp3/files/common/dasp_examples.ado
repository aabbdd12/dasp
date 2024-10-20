/*
*  ----------------------------------------------------------------------------
*  1. Main program                                                             
*  ----------------------------------------------------------------------------
*/
cap program drop dasp_examples
program dasp_examples
version 14
args EXAMPLE
set more off
`EXAMPLE'
end

/* POVERTY EXAMPLES */

cap program drop ex_ipov_01
program ex_ipov_01
sysuse bkf98I, replace
ipov exppc, alpha(0) hsize(size) hgroup(gse) index(fgt) pline(pline) inisave(example1)
end



cap program drop ex_ipov_db_01
program ex_ipov_db_01
sysuse bkf98I, replace
discard
db ipov
.ipov_dlg.main.dbsamex.setvalue "example1"
.ipov_dlg.main.cb_index.setvalue   fgt  
.ipov_dlg.main.vn_y.setvalue   exppc  
.ipov_dlg.main.vn_hs.setvalue  size 
.ipov_dlg.main.vn_gr.setvalue  gse 
.ipov_dlg.main.rb_a1.seton  
.ipov_dlg.main.vn_pl1.setvalue   pline  
.ipov_dlg.confop.sp_level.setvalue  95  
.ipov_dlg.resop.sp_dec1.setvalue 6 
.ipov_dlg.resop.sp_dec2.setvalue 6 
end

cap program drop ex_ipov_02
program ex_ipov_02
sysuse bkf98I, replace
ipov exppc, alpha(0) hsize(size) hgroup(gse) index(fgt) pline(pline) inisave(example1)
ipov exppc, alpha(1) hsize(size) hgroup(gse) index(fgt)  opl(mean) prop(50) inisave(example2)
end



cap program drop ex_ipov_db_02
program ex_ipov_db_02
sysuse bkf98I, replace 
discard
db ipov
.ipov_dlg.main.dbsamex.setvalue "example2"
.ipov_dlg.main.cb_index.setvalue   fgt  
.ipov_dlg.main.vn_y.setvalue   exppc  
.ipov_dlg.main.vn_hs.setvalue  size 
.ipov_dlg.main.vn_gr.setvalue  gse 
.ipov_dlg.main..rb_r1.seton 
.ipov_dlg.main.cb_pl1.setvalue mean 
.ipov_dlg.main.prop1.setvalue 50 
.ipov_dlg.main.cb_rela.setvalue  
.ipov_dlg.main.ed_al.setvalue    1  
.ipov_dlg.confop.sp_level.setvalue  95  
.ipov_dlg.resop.sp_dec1.setvalue 6 
.ipov_dlg.resop.sp_dec2.setvalue 6  
end


cap program drop ex_ipov_03
program ex_ipov_03
sysuse bkf98I, replace
ipov exppc, alpha(1) hsize(size) hgroup(gse) index(fgt) opl(mean) prop(50) rel(group) inisave(example3)
end



cap program drop ex_ipov_db_03
program ex_ipov_db_03
sysuse bkf98I, replace
discard
db ipov
.ipov_dlg.main.dbsamex.setvalue "example2"
.ipov_dlg.main.cb_index.setvalue   fgt  
.ipov_dlg.main.vn_y.setvalue   exppc  
.ipov_dlg.main.vn_hs.setvalue  size 
.ipov_dlg.main.vn_gr.setvalue  gse 
.ipov_dlg.main..rb_r1.seton 
.ipov_dlg.main.cb_pl1.setvalue mean 
.ipov_dlg.main.prop1.setvalue 50 
.ipov_dlg.main.cb_rela.setvalue group
.ipov_dlg.main.ed_al.setvalue    1  
.ipov_dlg.confop.sp_level.setvalue  95  
.ipov_dlg.resop.sp_dec1.setvalue 6 
.ipov_dlg.resop.sp_dec2.setvalue 6   
end






cap program drop ex_dipov_01
program ex_dipov_01
sysuse bkf98I, replace
dipov exppc exppc, hsize1(size) cond1(sex==1) hsize2(size) cond2(sex==2) pline1(60000) pline2(60000) alpha(0) inisave(myexample) index(fgt)
end

cap program drop ex_dipov_db_01
program ex_dipov_db_01
sysuse bkf98I, replace
discard
db dipov
.dipov_dlg.main.dbsamex.setvalue "myexample"
.dipov_dlg.main.cb_index.setvalue   fgt  
.dipov_dlg.main.vn_y_d1.setvalue   exppc  
.dipov_dlg.main.vn_hhs_d1.setvalue  size 
.dipov_dlg.main.chk_cd1.seton 
.dipov_dlg.main.ed_d1c1.setvalue "sex==1"
.dipov_dlg.main.vn_y_d2.setvalue   exppc 
.dipov_dlg.main.vn_hhs_d2.setvalue  size 
.dipov_dlg.main.chk_cd2.seton 
.dipov_dlg.main.ed_d2c1.setvalue "sex==2"
.dipov_dlg.main.rb_a1.seton  
.dipov_dlg.main.vn_pl1.setvalue   60000  
.dipov_dlg.main.rb_a2.seton  
.dipov_dlg.main.vn_pl2.setvalue   60000  
.dipov_dlg.main.ed_al.setvalue    0  
.dipov_dlg.confop.sp_level.setvalue  95 
end

cap program drop ex_dipov_02
program ex_dipov_02
sysuse bkf94I, replace
save file_1994, replace
sysuse bkf98I, replace
dipov exppc exppc, file1(file_1994.dta) hsize1(size) hsize2(size) pline1(60000) pline2(pline) hgroup(sex zone gse) alpha(0) xfil(example.xlsx) xshe(Table 01) inisave(myexample) index(fgt)
end

cap program drop ex_dipov_db_02
program ex_dipov_db_02
sysuse bkf94I, replace
save file_1994, replace
sysuse bkf98I, replace
discard
db dipov
.dipov_dlg.main.dbsamex.setvalue "myexample"
.dipov_dlg.main.cb_index.setvalue   fgt  
.dipov_dlg.main.vn_gr.setvalue sex zone gse  
.dipov_dlg.main.ed_gr.setvalue sex zone gse
.dipov_dlg.main.fi_d1.setvalue 2 
.dipov_dlg.isLoading1.setfalse 
.dipov_dlg.main.file_d1.setvalue "file_1994.dta"
.dipov_dlg.isLoading1.setfalse  
 GetLevels_DB  file_1994.dta , mia(en_y_d1  en_hhs_d1 en_pl1) ndb(dipov) 
.dipov_dlg.main.en_y_d1.setvalue   exppc 
.dipov_dlg.main.en_hhs_d1.setvalue  size 
.dipov_dlg.main.ed_d1c1.setvalue ""
.dipov_dlg.main.ed_gr.setvalue   
.dipov_dlg.main.vn_y_d2.setvalue   exppc 
.dipov_dlg.main.vn_hhs_d2.setvalue  size 
.dipov_dlg.main.ed_d2c1.setvalue ""
.dipov_dlg.main.rb_a1.seton  
.dipov_dlg.main.en_pl1.setvalue  60000 
.dipov_dlg.main.rb_a2.seton  
.dipov_dlg.main.vn_pl2.setvalue   pline  
.dipov_dlg.main.ed_al.setvalue    0  
.dipov_dlg.confop.sp_level.setvalue  95  
.dipov_dlg.resop.sp_dec1.setvalue 4  
.dipov_dlg.resop.sp_dec1.setvalue 4  
.dipov_dlg.resop.fnamex.setvalue example.xlsx  
.dipov_dlg.resop.ck_xls.seton  
.dipov_dlg.resop.ed_she.setvalue Table 01   
end


/* INEQUALITY EXAMPLES*/

cap program drop ex_ineq_01
program ex_ineq_01
sysuse bkf98I, replace
ineq exppc, hsize(size) hgroup(gse sex) index(gini) inisave(myexample)
end

sysuse bkf98I


cap program drop ex_ineq_db_01
program ex_ineq_db_01
sysuse bkf98I, replace
discard
db ineq
.ineq_dlg.main.dbsamex.setvalue "myexample"
.ineq_dlg.main.cb_index.setvalue   gini  
.ineq_dlg.main.vn_y.setvalue   exppc  
.ineq_dlg.main.vn_hs.setvalue  size 
.ineq_dlg.main.vn_gr.setvalue  gse sex
.ineq_dlg.main.edt_index5.setvalue .5   
.ineq_dlg.main.edt_index6.setvalue  1  
.ineq_dlg.confop.sp_level.setvalue  95  
.ineq_dlg.resop.sp_dec1.setvalue 6 
.ineq_dlg.resop.sp_dec2.setvalue 6   
end

cap program drop ex_ineq_02
program ex_ineq_02
sysuse bkf98I, replace
ineq exppc, hsize(size) hgroup(gse) index(atk) inisave(myexample)
end



cap program drop ex_ineq_db_02
program ex_ineq_db_02
sysuse bkf98I, replace 
discard
db ineq
.ineq_dlg.main.dbsamex.setvalue "myexample"
.ineq_dlg.main.cb_index.setvalue   atk  
.ineq_dlg.main.vn_y.setvalue   exppc  
.ineq_dlg.main.vn_hs.setvalue  size 
.ineq_dlg.main.vn_gr.setvalue  gse sex
.ineq_dlg.main.edt_index5.setvalue .5   
.ineq_dlg.main.edt_index6.setvalue  1  
.ineq_dlg.confop.sp_level.setvalue  95  
.ineq_dlg.resop.sp_dec1.setvalue 6 
.ineq_dlg.resop.sp_dec2.setvalue 6 
end




cap program drop ex_dineq_01
program ex_dineq_01
sysuse bkf94I,  replace
save file_1994, replace
sysuse bkf98I,  replace
save file_1998, replace
dineq exppc exppc, file1(file_1994) hsize1(size) file2(file_1998) hsize2(size) test(0) inisave(myexample) index(gini) hgroup(gse sex)
end



cap program drop ex_dineq_db_01
program ex_dineq_db_01
sysuse bkf94I,  replace
save file_1994, replace
sysuse bkf98I,  replace
save file_1998, replace
discard
db dineq
.dineq_dlg.main.dbsamex.setvalue "myexample"
.dineq_dlg.main.cb_index.setvalue   gini  
.dineq_dlg.main.fi_d1.setvalue 2 
.dineq_dlg.isLoading1.setfalse 
.dineq_dlg.main.file_d1.setvalue "file_1994"
.dineq_dlg.isLoading1.setfalse  
 GetLevels_DB  file_1994 , mia(en_y_d1  en_hhs_d1 en_rank_d1) ndb(dineq) 
.dineq_dlg.main.en_y_d1.setvalue   exppc 
.dineq_dlg.main.en_hhs_d1.setvalue  size 
.dineq_dlg.main.ed_d1c1.setvalue ""
.dineq_dlg.main.fi_d2.setvalue 2 
.dineq_dlg.isLoading2.setfalse 
.dineq_dlg.main.file_d2.setvalue "file_1998"
.dineq_dlg.isLoading2.setfalse  
 GetLevels_DB  file_1998 , mia(en_y_d2  en_hhs_d2 en_rank_d2) ndb(dineq) 
.dineq_dlg.main.en_y_d2.setvalue   exppc 
.dineq_dlg.main.en_hhs_d2.setvalue  size 
.dineq_dlg.main.ed_d2c1.setvalue ""
.dineq_dlg.main.edt_index5.setvalue .5   
.dineq_dlg.main.edt_index6.setvalue  1  
.dineq_dlg.main.vn_gr.setvalue  gse sex
.dineq_dlg.main.ed_gr.setvalue  gse sex
.dineq_dlg.confop.sp_level.setvalue  95  
.dineq_dlg.confop.ck_test.seton  
.dineq_dlg.confop.en_test.setvalue 0 
end

cap program drop ex_dineq_02
program ex_dineq_02
sysuse bkf98I, replace
dineq exppc exppc, hsize1(size) cond1(sex==1) hsize2(size) cond2(sex==2) theta(0) test(0) inisave(myexample) index(entropy)
end



cap program drop ex_dineq_db_02
program ex_dineq_db_02
sysuse bkf98I, replace 
discard
db dineq
.dineq_dlg.main.dbsamex.setvalue "myexample"
.dineq_dlg.main.cb_index.setvalue   entropy  
.dineq_dlg.main.vn_y_d1.setvalue   exppc  
.dineq_dlg.main.vn_hhs_d1.setvalue  size 
.dineq_dlg.main.chk_cd1.seton 
.dineq_dlg.main.ed_d1c1.setvalue "sex==1"
.dineq_dlg.main.vn_y_d2.setvalue   exppc 
.dineq_dlg.main.vn_hhs_d2.setvalue  size 
.dineq_dlg.main.chk_cd2.seton 
.dineq_dlg.main.ed_d2c1.setvalue "sex==2"
.dineq_dlg.main.edt_index5.setvalue .5   
.dineq_dlg.main.edt_index6.setvalue  0  
.dineq_dlg.confop.sp_level.setvalue  95  
.dineq_dlg.confop.ck_test.seton  
.dineq_dlg.confop.en_test.setvalue 0 
end




/* POLARISATION EXAMPLES*/

cap program drop ex_ipola_01
program ex_ipola_01
sysuse bkf98I, replace
ipola exppc, hsize(size) hgroup(zone) index(der) inisave(myexample) fast(1) alpha(0.5) 
end

sysuse bkf98I


cap program drop ex_ipola_db_01
program ex_ipola_db_01
sysuse bkf98I, replace
discard
db ipola
.ipola_dlg.main.dbsamex.setvalue "myexample"
.ipola_dlg.main.cb_index.setvalue   der  
.ipola_dlg.main.vn_y.setvalue   exppc  
.ipola_dlg.main.vn_hs.setvalue  size 
.ipola_dlg.main.vn_gr.setvalue  zone 
.ipola_dlg.main.ed_al1.setvalue  .5 
.ipola_dlg.main.chk_fast1.seton          
.ipola_dlg.confop.sp_level.setvalue  95  
.ipola_dlg.resop.sp_dec.setvalue 6 
end

cap program drop ex_ipola_02
program ex_ipola_02
sysuse bkf98I, replace
ipola exppc, hsize(size) hgroup(gse) index(fw) inisave(myexample) 
end



cap program drop ex_ipola_db_02
program ex_ipola_db_02
sysuse bkf98I, replace 
discard
db ipola
.ipola_dlg.main.dbsamex.setvalue "myexample"
.ipola_dlg.main.cb_index.setvalue   fw  
.ipola_dlg.main.vn_y.setvalue   exppc  
.ipola_dlg.main.vn_hs.setvalue  size 
.ipola_dlg.main.vn_gr.setvalue  gse 
.ipola_dlg.confop.sp_level.setvalue  95  
.ipola_dlg.resop.sp_dec.setvalue 6  
 
end




cap program drop ex_dipola_01
program ex_dipola_01
sysuse bkf94I,  replace
save file_1994, replace
sysuse bkf98I,  replace
save file_1998, replace
dipola exppc exppc, file1(file_1994) hsize1(size) file2(file_1998) hsize2(size) test(0) inisave(myexample) index(der) fast(1)
end



cap program drop ex_dipola_db_01
program ex_dipola_db_01
sysuse bkf94I,  replace
save file_1994, replace
sysuse bkf98I,  replace
save file_1998, replace
discard
db dipola
.dipola_dlg.main.dbsamex.setvalue "myexample"
.dipola_dlg.main.cb_index.setvalue   der  
.dipola_dlg.main.fi_d1.setvalue 2 
.dipola_dlg.isLoading1.setfalse 
.dipola_dlg.main.file_d1.setvalue "file_1994"
.dipola_dlg.isLoading1.setfalse  
 GetLevels_DB  file_1994 , mia(en_y_d1  en_hhs_d1) ndb(dipola) 
.dipola_dlg.main.en_y_d1.setvalue   exppc 
.dipola_dlg.main.en_hhs_d1.setvalue  size 
.dipola_dlg.main.ed_d1c1.setvalue ""
.dipola_dlg.main.fi_d2.setvalue 2 
.dipola_dlg.isLoading2.setfalse 
.dipola_dlg.main.file_d2.setvalue "file_1998"
.dipola_dlg.isLoading2.setfalse  
 GetLevels_DB  file_1998 , mia(en_y_d2  en_hhs_d2) ndb(dipola) 
.dipola_dlg.main.en_y_d2.setvalue   exppc 
.dipola_dlg.main.en_hhs_d2.setvalue  size 
.dipola_dlg.main.ed_d2c1.setvalue ""
.dipola_dlg.main.chk_fast1.seton  
.dipola_dlg.confop.en_test.setvalue 0 
.dipola_dlg.confop.ck_test.seton 
end

cap program drop ex_dipola_02
program ex_dipola_02
sysuse bkf98I, replace
dipola exppc exppc, hsize1(size) cond1(sex==1) hsize2(size) cond2(sex==2) test(0) inisave(myexample) index(fw) 
end



cap program drop ex_dipola_db_02
program ex_dipola_db_02
sysuse bkf98I, replace 
discard
db dipola
.dipola_dlg.main.dbsamex.setvalue "myexample"
.dipola_dlg.main.cb_index.setvalue   fw  
.dipola_dlg.main.vn_y_d1.setvalue   exppc  
.dipola_dlg.main.vn_hhs_d1.setvalue  size 
.dipola_dlg.main.chk_cd1.seton 
.dipola_dlg.main.ed_d1c1.setvalue "sex==1"
.dipola_dlg.main.vn_y_d2.setvalue   exppc 
.dipola_dlg.main.vn_hhs_d2.setvalue  size 
.dipola_dlg.main.chk_cd2.seton 
.dipola_dlg.main.ed_d2c1.setvalue "sex==2"
.dipola_dlg.confop.sp_level.setvalue  97 
.dipola_dlg.confop.ck_test.seton 
.dipola_dlg.confop.en_test.setvalue 0 
end






