cap program drop ll_shexp
program ll_shexp
args  lnf thetaf  cf1 cf2 thetam cm1 cm2 thetak ck1 ck2 rf0 rf1 rf2 rf3 rm0 rm1  rm2 rm3 rk siga11 siga21 siga22 siga31 siga32 siga33  thetazf   thetazk
cap matrix drop siga
matrix define siga = J(3,3,0)
matrix siga[1,1] = `siga11'[1]
matrix siga[2,1] = `siga21'[1]
matrix siga[2,2] = `siga22'[1]
matrix siga[3,1] = `siga31'[1]
matrix siga[3,2] = `siga32'[1]
matrix siga[3,3] = `siga33'[1]
cap matrix drop miomega
matrix define miomega = siga'*siga
tempvar u_shexcl_f0 u_shexcl_m0 u_shexcl_k0  u_shexcl_f1  u_shexcl_m1  u_shexcl_f2  u_shexcl_m2  u_shexcl_f3  u_shexcl_m3  u_shexcl_k1  
  
cap drop  `gneta_k' `gneta_f' `gneta_m'
tempvar    gneta_k   gneta_f   gneta_m
qui gen double `gneta_f' = $f_ys 
qui gen double `gneta_m' = $m_ys 
qui gen double `gneta_k' = 0
   
qui replace `gneta_k' = 0 if `gneta_k'==0
qui replace `gneta_f' = 0 if `gneta_f'==0
qui replace `gneta_m' = 0 if `gneta_m'==0

cap drop  `deflatexp_f' `deflatexp_f2' `deflatexp_m' `deflatexp_m2' `deflatexp_k' `deflatexp_k2'
tempvar    deflatexp_f   deflatexp_f2   deflatexp_m   deflatexp_m2   deflatexp_k   deflatexp_k2
qui gen double `deflatexp_f' = $lny  + ln(`gneta_f') 
qui gen double `deflatexp_m' = $lny  + ln(`gneta_m')
qui gen double `deflatexp_k' = 0
qui gen double `deflatexp_f2' =  `deflatexp_f'^2
qui gen double `deflatexp_m2' =  `deflatexp_m'^2
qui gen double `deflatexp_k2' = 0
 
tempvar   u_shexcl_f0   u_shexcl_m0   u_shexcl_k0
qui gen double `u_shexcl_f0' =   $sef - `gneta_f'*(`thetaf'  + `cf1'*`deflatexp_f'  + `cf2'*`deflatexp_f2') - `rf0'*$rlnexp
qui gen double `u_shexcl_m0' =   $sem - `gneta_m'*(`thetam'  + `cm1'*`deflatexp_m'  + `cm2'*`deflatexp_m2') - `rm0'*$rlnexp
qui gen double `u_shexcl_k0' =  0
 
cap drop `zk'
cap drop `zf'
tempname zk zf
qui gen double  `zk' =  `thetazk'
qui gen double  `zf' =  `thetazf'
qui replace `zk'=0 if `zk' == .
qui replace `zf'=0 if `zf' == .

cap drop  `gneta_k' `gneta_f' `gneta_m'
tempvar    gneta_k   gneta_f   gneta_m
qui  gen `gneta_k' = exp(`zk')/(1+exp(`zk')+exp(`zf')) 
qui  gen `gneta_f' = exp(`zf')/(1+exp(`zk')+exp(`zf')) 
qui  gen `gneta_m' =        1 /(1+exp(`zk')+exp(`zf')) 
qui  replace `gneta_k' = 0 if `gneta_k'==0
qui  replace `gneta_f' = 0 if `gneta_f'==0
qui  replace `gneta_m' = 0 if `gneta_m'==0
  
cap drop  `deflatexp_fa' `deflatexp_f2a' `deflatexp_ma' `deflatexp_m2a' `deflatexp_ka' `deflatexp_k2a'
tempvar    deflatexp_fa   deflatexp_f2a   deflatexp_ma   deflatexp_m2a   deflatexp_ka   deflatexp_k2a
qui        gen double `deflatexp_fa'   = $lny  + log(`gneta_f') 
qui  gen double `deflatexp_ma'   = $lny  + log(`gneta_m')
qui  gen double `deflatexp_ka'  = $lny  + log(`gneta_k')
qui  replace `deflatexp_fa' = 0 if `deflatexp_fa'==.
qui  replace `deflatexp_ma' = 0 if `deflatexp_ma'==.
qui  replace `deflatexp_ka' = 0 if `deflatexp_ka'==.
qui  gen double `deflatexp_f2a'  =  `deflatexp_fa'^2
qui  gen double `deflatexp_m2a'  =  `deflatexp_ma'^2
qui  gen double `deflatexp_k2a'  =  `deflatexp_ka'^2
	
 cap drop `u_shexcl_f1'  `u_shexcl_m1'  `u_shexcl_f2'  `u_shexcl_m2'  `u_shexcl_f3'  `u_shexcl_m3'  `u_shexcl_k1'
 tempvar   u_shexcl_f1    u_shexcl_m1    u_shexcl_f2    u_shexcl_m2    u_shexcl_f3    u_shexcl_m3    u_shexcl_k1    
  qui gen  double `u_shexcl_f1' =  $sef -  `gneta_f'*(`thetaf' + `cf1'*`deflatexp_fa' + `cf2'*`deflatexp_f2a') - `rf1'*$rlnexp 
  qui gen  double `u_shexcl_m1' =  $sem -  `gneta_m'*(`thetam' + `cm1'*`deflatexp_ma'  + `cm2'*`deflatexp_m2a') - `rm1'*$rlnexp   
  
  qui gen double  `u_shexcl_f2' =  $sef - `gneta_f'*(`thetaf'   + `cf1'*`deflatexp_fa'  + `cf2'*`deflatexp_f2a') - `rf2'*$rlnexp 
  qui gen double  `u_shexcl_m2' =  $sem - `gneta_m'*(`thetam'   + `cm1'*`deflatexp_ma'  + `cm2'*`deflatexp_m2a') - `rm2'*$rlnexp   

  qui gen double  `u_shexcl_f3' = $sef - `gneta_f'*(`thetaf'  + `cf1'*`deflatexp_fa'  + `cf2'*`deflatexp_f2a') - `rf3'*$rlnexp 
  qui gen double  `u_shexcl_m3' = $sem - `gneta_m'*(`thetam'  + `cm1'*`deflatexp_ma'  + `cm2'*`deflatexp_m2a') - `rm3'*$rlnexp  
  qui gen double  `u_shexcl_k1' = $sek - `gneta_k'*(`thetak'  + `ck1'*`deflatexp_ka'  + `ck2'*`deflatexp_k2a' ) - `rk'*$rlnexp
  
   
/* LLF*/
   local lista  u_shexcl_f0  u_shexcl_m0  u_shexcl_k0  u_shexcl_f1  u_shexcl_m1  u_shexcl_k1 u_shexcl_f2  u_shexcl_m2 u_shexcl_f3  u_shexcl_m3
   foreach name of local lista {
   qui replace ``name'' = 0 if ``name'' == .
   }
cap drop `u_shexcl_f' `u_shexcl_m' `u_shexcl_k'
tempvar   u_shexcl_f   u_shexcl_m   u_shexcl_k
qui gen double  `u_shexcl_f' =   `u_shexcl_f0'*(type==20) + `u_shexcl_f1'*(type==21) + `u_shexcl_f2'*(type==22) + `u_shexcl_f3'*(type==23)
qui gen double  `u_shexcl_m' =   `u_shexcl_m0'*(type==20) + `u_shexcl_m1'*(type==21) + `u_shexcl_m2'*(type==22) + `u_shexcl_m3'*(type==23)  
qui gen double  `u_shexcl_k' =   `u_shexcl_k0'*(type==20) + `u_shexcl_k1'*(type>20)
 
cap matrix drop minv
matrix minv = syminv(miomega)
local det   = det(miomega)

//set trace on
cap drop `rss'
tempvar   rss
qui gen double `rss' = 0
local vnm1 u_shexcl_f
local vnm2 u_shexcl_m 
local vnm3 u_shexcl_k
forvalues i=1/3 {
cap drop   `comp`i''
tempvar    comp`i'
qui gen double `comp`i'' = 0
forvalues j=1/3 {
qui  replace `comp`i'' = `comp`i''  + ``vnm`j'''*el(minv,`j',`i') 
}
qui replace `rss' = `rss' + ``vnm`i'''*`comp`i''
}

qui replace `lnf'  = -0.50000000*log(`det') - 0.5000000*3.0000000*log(2*_pi) - 0.5*(`rss')

end
