
*  ----------------------------------------------------------------------------
*  1. Main program                                                             
*  ----------------------------------------------------------------------------
cap program drop welcom_examples
program welcom_examples
version 9.2
args EXAMPLE
set more off
`EXAMPLE'
end




*  ----------------------------------------------------------------------------
*  1- DUVM                                                          
*  ----------------------------------------------------------------------------

cap program drop ex_duvm_01
program ex_duvm_01
#delimit ; 
use http://dasp.ecn.ulaval.ca/welcom/examples/ds/Mexico_2014_Cereals.dta , replace; 
duvm corn wheat rice other, 
hhsize(hhsize) expend(hh_current_inc) hweight(sweight) cluster(psu) region(rururb) 
inisave(ex1_duvm_db)  indcat(sex educ )  indcon(age)   xfil(myfile) 
 ;
#delimit cr
end


cap program drop ex_duvm_02
program ex_duvm_02
#delimit ; 
use http://dasp.ecn.ulaval.ca/welcom/examples/ds/Mexico_2014_Cereals.dta , replace; 
duvm corn wheat rice other, 
hhsize(hhsize) expend(hh_current_inc) hweight(sweight) cluster(psu) region(rururb) 
inisave(ex2_duvm_db)  indcat(sex educ )  indcon(age)   xfil(myfile)
boot(50)
 ;
#delimit cr
end

cap program drop ex_duvm_03
program ex_duvm_03
#delimit ; 
use http://dasp.ecn.ulaval.ca/welcom/examples/ds/Mexico_2014_Cereals.dta , replace; 
duvm corn wheat rice other, 
hhsize(hhsize) expend(hh_current_inc) hweight(sweight) cluster(psu) region(rururb) 
inisave(ex3_duvm_db)  indcat(sex educ )  indcon(age)   xfil(myfile) 
hgroup(decile)
 ;
#delimit cr              
end

cap program drop ex_duvm_db_01
program ex_duvm_db_01
use http://dasp.ecn.ulaval.ca/welcom/examples/ds/Mexico_2014_Cereals.dta , replace
discard
db duvm
.duvm_dlg.main.dbsamex.setvalue "ex1_duvm_db"
.duvm_dlg.main.name_items.setvalue "corn wheat rice other"
.duvm_dlg.main.vn_hhsize.setvalue "hhsize"
.duvm_dlg.main.vn_hhexp.setvalue "hh_current_inc"
.duvm_dlg.main.vn_hhwe.setvalue  "sweight"
.duvm_dlg.main.vl_indcat.setvalue  "sex educ "
.duvm_dlg.main.vl_indcon.setvalue  "age"
.duvm_dlg.main.vn_cluster.setvalue "psu"
.duvm_dlg.main.vn_region.setvalue "rururb"
.duvm_dlg.resop.sp_dec.setvalue "3"
.duvm_dlg.resop.n_boot.setvalue "0"
#delimit cr
end


cap program drop ex_duvm_db_02
program ex_duvm_db_02
use http://dasp.ecn.ulaval.ca/welcom/examples/ds/Mexico_2014_Cereals.dta , replace
discard
db duvm
.duvm_dlg.main.dbsamex.setvalue "ex2_duvm_db"
.duvm_dlg.main.name_items.setvalue "corn wheat rice other"
.duvm_dlg.main.vn_hhsize.setvalue "hhsize"
.duvm_dlg.main.vn_hhexp.setvalue "hh_current_inc"
.duvm_dlg.main.vn_hhwe.setvalue  "sweight"
.duvm_dlg.main.vl_indcat.setvalue  "sex educ "
.duvm_dlg.main.vl_indcon.setvalue  "age"
.duvm_dlg.main.vn_cluster.setvalue "psu"
.duvm_dlg.main.vn_region.setvalue "rururb"
.duvm_dlg.resop.sp_dec.setvalue "3"
.duvm_dlg.resop.n_boot.setvalue "50"
#delimit cr
end


cap program drop ex_duvm_db_03
program ex_duvm_db_03
use http://dasp.ecn.ulaval.ca/welcom/examples/ds/Mexico_2014_Cereals.dta , replace
discard
db duvm
.duvm_dlg.main.dbsamex.setvalue "ex3_duvm_db"
.duvm_dlg.main.name_items.setvalue "corn wheat rice other"
.duvm_dlg.main.vn_hhsize.setvalue "hhsize"
.duvm_dlg.main.vn_hhexp.setvalue "hh_current_inc"
.duvm_dlg.main.vn_hhwe.setvalue  "sweight"
.duvm_dlg.resop.vn_dec.setvalue "decile"
.duvm_dlg.main.vl_indcat.setvalue  "sex educ "
.duvm_dlg.main.vl_indcon.setvalue  "age"
.duvm_dlg.main.vn_cluster.setvalue "psu"
.duvm_dlg.main.vn_region.setvalue "rururb"
.duvm_dlg.resop.sp_dec.setvalue "3"
.duvm_dlg.resop.n_boot.setvalue "0"
#delimit cr
end



*  ----------------------------------------------------------------------------
*  2- WQUAIDS                                                         
*  ----------------------------------------------------------------------------

cap program drop ex_wquaids_01
program ex_wquaids_01
#delimit ; 
use http://dasp.ecn.ulaval.ca/welcom/examples/ds/Mexico_2014_Cereals.dta , replace;
wquaids wcorn wwheat wrice wother wcomp, anot(9.5) 
prices(pcorn pwheat price pother pcomp) 
snames(Corn Wheat Rice Other_cereal Rest) 
expend(hh_current_inc) hweight(sweight) 
model(1) inisave(myproj.wquaids) 
dregres(0) xfil(myfil) dislas(0);
#delimit cr
end

cap program drop ex_wquaids_02
program ex_wquaids_02
#delimit ; 
use http://dasp.ecn.ulaval.ca/welcom/examples/ds/Mexico_2014_Cereals.dta , replace; 
set seed 1234;
bsample 2000;
wquaids wcorn wwheat wrice wother wcomp, anot(9.5) 
prices(pcorn pwheat price pother pcomp) 
snames(Corn Wheat Rice Other_cereal Rest) 
expend(hh_current_inc) hweight(sweight) 
model(1) inisave(myproj.wquaids) 
demographics(age isMale) dregres(1) xfil(myfil) dislas(0);
#delimit cr
end

cap program drop ex_wquaids_db_01
program ex_wquaids_db_01
use http://dasp.ecn.ulaval.ca/welcom/examples/ds/Mexico_2014_Cereals.dta , replace
discard
db wquaids
.wquaids_dlg.main.dbsamex.setvalue "ex1_quaids_db"
.wquaids_dlg.main.name_items.setvalue "wcorn wwheat wrice wother wcomp"
.wquaids_dlg.main.name_snames.setvalue "Corn Wheat Rice Other_cereal Rest"
.wquaids_dlg.main.vn_hhexp.setvalue "hh_current_inc"
.wquaids_dlg.main.vn_hhwe.setvalue  "sweight"
.wquaids_dlg.main.name_prices.setvalue  "pcorn pwheat price pother pcomp"
.wquaids_dlg.main.ed_al0.setvalue "9.5"
.wquaids_dlg.resop.eldecfile.setvalue "myfil"
.wquaids_dlg.resop.sp_dec.setvalue "3"
#delimit cr
end


cap program drop ex_wquaids_db_02
program ex_wquaids_db_02
use http://dasp.ecn.ulaval.ca/welcom/examples/ds/Mexico_2014_Cereals.dta , replace
discard
db wquaids
.wquaids_dlg.main.dbsamex.setvalue "ex2_quaids_db"
.wquaids_dlg.main.name_items.setvalue "wcorn wwheat wrice wother wcomp"
.wquaids_dlg.main.name_snames.setvalue "Corn Wheat Rice Other_cereal Rest"
.wquaids_dlg.main.vn_hhexp.setvalue "hh_current_inc"
.wquaids_dlg.main.vn_hhwe.setvalue  "sweight"
.wquaids_dlg.main.vl_inddemo.setvalue  "age isMale"
.wquaids_dlg.main.name_prices.setvalue  "pcorn pwheat price pother pcomp"
.wquaids_dlg.resop.ck_dregres.seton 
.wquaids_dlg.main.ed_al0.setvalue "9.5"
.wquaids_dlg.resop.eldecfile.setvalue "myfil"
.wquaids_dlg.resop.sp_dec.setvalue "3"
#delimit cr
end


*  ----------------------------------------------------------------------------
*  3- EASI                                                         
*  ----------------------------------------------------------------------------


cap program drop ex_easi_01
program ex_easi_01
#delimit ; 
use http://dasp.ecn.ulaval.ca/welcom/examples/ds/Mexico_2014_Cereals.dta , replace;
set seed 1234;
bsample 4000;
 sr_easi wcorn wwheat wrice wother wcomp, 
 prices(pcorn pwheat price pother pcomp) 
 snames(corn wheat rice other comp) 
 expenditure(hh_current_inc) inisave(myproj) 
 rtool(C:\Program Files\R\R-3.4.4\bin\x64\R.exe) 
 demographics(age isMale educa2 educa3 educa4 educa5 educa6 educa7) 
 dec(4) dregres(1) dislas(0) 
 xfil(myres) 
 power(3) 
 inpy(1) inpz(0) inzy(0)
;
#delimit cr
end

cap program drop ex_easi_02
program ex_easi_02
#delimit ; 
use http://dasp.ecn.ulaval.ca/welcom/examples/ds/Mexico_2014_Cereals.dta , replace;
set seed 1234;
bsample 4000;
 sr_easi wcorn wwheat wrice wother wcomp, 
 prices(pcorn pwheat price pother pcomp) 
 snames(corn wheat rice other comp) 
 expenditure(hh_current_inc) inisave(myproj) 
 rtool(C:\Program Files\R\R-3.4.4\bin\x64\R.exe) 
 demographics(age isMale educa2 educa3 educa4 educa5 educa6 educa7) 
 dec(4) dregres(1) dislas(0) 
 xfil(myres) 
 power(5) 
 inpy(1) inpz(1) inzy(0);
#delimit cr
end

cap program drop ex_easi_db_01
program ex_easi_db_01
use http://dasp.ecn.ulaval.ca/welcom/examples/ds/Mexico_2014_Cereals.dta , replace
set seed 1234
bsample 4000
discard
db sr_easi
.sr_easi_dlg.main.dbsamex.setvalue "ex1_easi_db"
.sr_easi_dlg.main.name_items.setvalue "wcorn wwheat wrice wother wcomp"
.sr_easi_dlg.main.name_snames.setvalue "corn wheat rice other comp"
.sr_easi_dlg.main.vn_hhexp.setvalue "hh_current_inc"
.sr_easi_dlg.main.vl_inddemo.setvalue  "age isMale educa2 educa3 educa4 educa5 educa6 educa7"
.sr_easi_dlg.main.name_prices.setvalue  "pcorn pwheat price pother pcomp"
.sr_easi_dlg.main.sp_pow.setvalue  3
.sr_easi_dlg.resop.ck_dregres.seton 
.sr_easi_dlg.main.ck_inpy.seton 
.sr_easi_dlg.main.drtool.setvalue "C:\Program Files\R\R-3.4.4\bin\x64\R.exe"
.sr_easi_dlg.resop.sp_dec.setvalue "4"
.sr_easi_dlg.resop.eldecfile.setvalue "myres"
#delimit cr
end


cap program drop ex_easi_db_02
program ex_easi_db_02
use http://dasp.ecn.ulaval.ca/welcom/examples/ds/Mexico_2014_Cereals.dta , replace
set seed 1234
bsample 4000
discard
db sr_easi
.sr_easi_dlg.main.dbsamex.setvalue "ex2_easi_db"
.sr_easi_dlg.main.name_items.setvalue "wcorn wwheat wrice wother wcomp"
.sr_easi_dlg.main.name_snames.setvalue "corn wheat rice other comp"
.sr_easi_dlg.main.vn_hhexp.setvalue "hh_current_inc"
.sr_easi_dlg.main.vl_inddemo.setvalue  "age isMale educa2 educa3 educa4 educa5 educa6 educa7"
.sr_easi_dlg.main.name_prices.setvalue  "pcorn pwheat price pother pcomp"
.sr_easi_dlg.main.sp_pow.setvalue  5
.sr_easi_dlg.resop.ck_dregres.seton 
.sr_easi_dlg.main.ck_inpy.seton 
.sr_easi_dlg.main.ck_inpz.seton 
.sr_easi_dlg.main.drtool.setvalue "C:\Program Files\R\R-3.4.4\bin\x64\R.exe"
.sr_easi_dlg.resop.sp_dec.setvalue "4"
.sr_easi_dlg.resop.eldecfile.setvalue "myres"
#delimit cr
end
