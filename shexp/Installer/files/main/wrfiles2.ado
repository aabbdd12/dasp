

#delimit cr
*set trace on
capture program drop wrfiles2
program define wrfiles2
version 9.2
syntax anything [,  list1(string) list2(string)   listf(string)  listm(string) listk(string) listzk(string) olistzk(string) nbf(int 2) nbm(int 2)  nbk(int 2)  nbzk(int 2) ]



local nbf1 = `nbf'+1
local nbm1 = `nbf'+1
local nbk1 = `nbf'+1

local nbf2 = `nbf'+2
local nbm2 = `nbf'+2
local nbk2 = `nbf'+2

cd "`anything'" 
cap rmdir St_R
cap mkdir St_R
if "`c(os)'"=="MacOSX" | "`c(os)'"=="UNIX" local prea = "~"





file close _all
file open rcode2 using  ML_CollDF_S.R, write replace
file write rcode2 ///
`"rm(list = ls())"' _newline ///
`"list.of.packages <- c("pacman", "foreign", "mvtnorm", "MASS", "gdata", "rio", "Matrix",  "dplyr", "pracma" , "maxLik" , "numDeriv" )"' _newline ///
`"new.packages  <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]"' _newline ///
`"if(length(new.packages)) install.packages(new.packages) "' _newline ///
`"pacman::p_load(foreign, mvtnorm, MASS, gdata, rio, Matrix,  dplyr, pracma , maxLik , numDeriv)"' _newline ///
`"mypath <- "`anything'""' _newline ///
`"setwd(mypath)"' _newline ///
`"source(file="Likelihood_CollDF_S.R")"' _newline ///
`"name="broad" ; good="Cl";"' _newline ///
`"betsig <- c(1,0,1,0,0,1)"' _newline ///
`"betsz <- c(`list1')"' _newline ///
`"betsf <- c(`list2')"' _newline ///
`"beta0 <- c(rep(0,`nbf2'+`nbm2'+`nbk2'+9), betsig, betsz , betsf)"' _newline ///
`"beta0"' _newline ///
`"data <- read.dta(paste0("mydata.dta"))"' _newline ///
`"attach(data)"' _newline ///
`"clistf   <- list(deflatexp_f , deflatexp_f2 )"' _newline ///
`"clistm   <- list(deflatexp_m , deflatexp_m2 )"' _newline ///
`"clistk   <- list(deflatexp_k , deflatexp_k2 )"' _newline ///
`"listf0   <- list( `listf' )"' _newline ///
`"listm0   <- list( `listm' )"' _newline ///
`"listk0   <- list( `listk' )"' _newline ///
`"listzkf  <-  list(`listzk')"' _newline ///
`"MaxRo_Cl <- maxBFGS(LogLik, grad = NULL, hess = NULL, start=beta0,control=list(iterlim=1500,printLevel=3,tol=1e-12,reltol=1e-12))"' _newline ///
`"beta0 <- as.matrix(MaxRo_Cl"' `"`=char(36)'"' `"estimate)"' _newline ///
`"beta0"' _newline ///
`"MaxRo_Cl_G <- jacobian(LogLik, MaxRo_Cl"' `"`=char(36)'"' `"estimate)"' _newline ///
`"LogLikSum <- function(b)"' `"`=char(123)'"' _newline ///
`"  LogLikSum <- sum(LogLik(b))"' _newline ///
`"`=char(125)'"' _newline ///
`"GradBHHH <- t(MaxRo_Cl_G)%*%MaxRo_Cl_G"' _newline ///
`"hess <- hessian(func=LogLikSum, MaxRo_Cl"' `"`=char(36)'"' `"estimate)"' _newline ///
`"std <- as.matrix(sqrt(diag(solve(GradBHHH))))"' _newline ///
`"MaxRo_Cl_Beta <- as.matrix(MaxRo_Cl"' `"`=char(36)'"' `"estimate)"' _newline ///
`"tstat <- as.matrix(MaxRo_Cl_Beta/std)"' _newline ///
`"rownames(MaxRo_Cl_Beta) <- "' _newline ///
`"  c("cf0""' 
forvalues i=1/`nbf' {
file write rcode2 `"  ,"cf`i'""' 
}
file write rcode2 `","' ///
`"    "cm0""'  
forvalues i=1/`nbm' {
file write rcode2 `"  ,"cm`i'""'
}
file write rcode2 `","' ///
`"    "ck0""'  
forvalues i=1/`nbk' {
file write rcode2 `" ,"ck`i'""'
}
file write rcode2 `"    ,"rf0","rf1", "rf2", "rf3", "rm0", "rm1", "rm2", "rm3","rk","' _newline ///
`"    "s11","s12","s13","s22","s23","s33","' _newline ///
`"    "z0""'  
local lay1 `olistzk' 
foreach name of local lay1 {
file write rcode2 `" ,"`name'_k""' 
}
file write rcode2 `"    , "f0""' 
foreach name of local lay1 {
file write rcode2 `" ,"`name'_f""' 
}
file write rcode2 `")"' 
file write rcode2 `"  "' _newline  ///
`"signe <- character(length(MaxRo_Cl_Beta))"' _newline ///
`"signe[(abs(tstat)>1.65)&(abs(tstat)<= 1.96)] <- "*""' _newline ///
`"signe[(abs(tstat)>1.96)&(abs(tstat)<= 2.575)] <- "**""' _newline ///
`"signe[(abs(tstat)>2.575)] <- "***""' _newline ///
`"signe[is.na(signe)] <- """' _newline ///
`"Resultats <- data.frame(rownames(MaxRo_Cl_Beta), MaxRo_Cl_Beta,std,tstat,signe,colSums(MaxRo_Cl_G))"' _newline ///
`"names(Resultats) <-c("Names","Para","Std","TStat","Seuil","Gradient")"' _newline ///
`"cat("Valeur de la fonction: ",MaxRo_Cl"' `"`=char(36)'"' `"maximum ,"\n","\n")"' _newline ///
`"print(Resultats,digits=3)"' _newline ///
`"cat("--------------------------------------------- ","\n")"' _newline ///
`"cat("(abs(tstat)>=1.60) & (abs(tstat)<= 1.64) <- -","\n")"' _newline ///
`"cat("(abs(tstat)> 1.65) & (abs(tstat)<= 1.96) <- *","\n")"' _newline ///
`"cat("(abs(tstat)> 1.96) & (abs(tstat)<= 2.58) <- **","\n")"' _newline ///
`"cat("(abs(tstat)> 2.58) <- ***","\n")"' _newline ///
`"export(Resultats, "Results.dta")"'  _newline 
file close rcode2
/*doedit  ML_CollDF_S.R*/



file close _all
cap file drop rcode2
file open rcode2 using  Likelihood_CollDF_S.R, write replace
file write rcode2 ///
`"  LogLik <- function(b){"'_newline ///
`" u_shexcl_f0 <- 0 "'_newline ///
`" u_shexcl_m0 <- 0 "'_newline ///
`" u_shexcl_k0 <- 0 "'_newline ///
`" sigma <- matrix(0,3,3)"'_newline ///
`" nlim <- length(listm0)+length(clistm)"'_newline ///
`" nlif <- length(listf0)+length(clistf)"'_newline ///
`" nlik <- length(listk0)+length(clistk)"'_newline ///
`" nzb<- length(listzkf)"'_newline ///
`" coef_f<- b[1:(nlif+1)]# 1 to 6"'_newline ///
`" coef_f0 <- b[(nlif+1)]"'_newline ///
`" coef_m<- b[(nlif+2):(nlif+nlim+2)] # 7 to 12"'_newline ///
`" coef_m0 <- b[(nlif+nlim+2)]"'_newline ///
`" coef_k<- b[(nlif+nlim+3):(nlif+nlim+nlik+3)]# 13 to 19"'_newline ///
`" coef_k0 <- b[(nlif+nlim+nlik+3)]"'_newline ///
`" newnum <- nlif+nlim+nlik+3"'_newline ///
`" rf0<- b[(newnum+1)];"'_newline ///
`" rf1<- b[(newnum+2)];"'_newline ///
`" rf2 <-b[(newnum+3)]; "'_newline ///
`" rf3 <-b[(newnum+4)]; "'_newline ///
`" rm0<- b[(newnum+5)];"'_newline ///
`" rm1<- b[(newnum+6)];"'_newline ///
`" rm2 <-b[(newnum+7)];"'_newline ///
`" rm3 <-b[(newnum+8)];"'_newline ///
`" rk<- b[(newnum+9)];#28"'_newline ///
`" snb <- newnum+9"'_newline ///
`" sigma[1,1] = b[(snb+1)]; #29"'_newline ///
`" sigma[2,1] = b[(snb+2)];"'_newline ///
`" sigma[2,2] = b[(snb+3)]"'_newline ///
`" sigma[3,1] = b[(snb+4)];"'_newline ///
`" sigma[3,2] = b[(snb+5)];"'_newline ///
`" sigma[3,3] = b[(snb+6)]; #34"'_newline ///
`" snc <- snb+6 #36"'_newline ///
`" coef_zk<- b[(snc+1):(snc+nzb+1)];"'_newline ///
`" coef_zk0 <- b[(snc+nzb+1)]"'_newline ///
`" coef_zf <- b[(snc+nzb+2):(snc+2*nzb+2)];"'_newline ///
`" coef_zf0 <-b[(snc+2*nzb+2)]"'_newline ///
`" omega <- t(sigma)%*%(sigma)"'_newline ///
`" gneta_f <- f_share "'_newline ///
`" gneta_m <- m_share"'_newline ///
`" deflatexp_f <- lnexp + log(gneta_f)"'_newline ///
`" deflatexp_f2 <- deflatexp_f**2"'_newline ///
`" deflatexp_m <- lnexp + log(gneta_m)"'_newline ///
`" deflatexp_m2 <- deflatexp_m**2"'_newline ///
`" clistf<- list(deflatexp_f , deflatexp_f2 )"'_newline ///
`" clistm<- list(deflatexp_m , deflatexp_m2 )"'_newline ///
`" listf <- do.call(c, list(listf0, clistf))"'_newline ///
`" listm <- do.call(c, list(listm0, clistm))"'_newline ///
`" names(clistf)"'_newline ///
`" names(clistm)"'_newline ///
`" u_shexcl_f0 <- shexcl_f - gneta_f*coef_f0"'_newline ///
`" for (i in 1:nlif){"'_newline ///
`" u_shexcl_f0 <- u_shexcl_f0- gneta_f*coef_f[i]*listf[[i]]"'_newline ///
`" }"'_newline ///
`" u_shexcl_f0<- u_shexcl_f0 -rf0*resid_lnexp"'_newline ///
`" u_shexcl_m0 <- shexcl_m - gneta_m*coef_m0 "'_newline ///
`" for (i in 1:nlim){"'_newline ///
`" u_shexcl_m0 <- u_shexcl_m0- gneta_m*coef_m[i]*listm[[i]]"'_newline ///
`" }"'_newline ///
`" u_shexcl_m0 <- u_shexcl_m0-rm0*resid_lnexp"'_newline ///
`" u_shexcl_k0<- 0"'_newline ///
`" names(listzkf)"'_newline ///
`" zk <-coef_zk0+ coef_zk[1]*listzkf[[1]]"'_newline ///
`" zf <-coef_zf0+ coef_zf[1]*listzkf[[1]]"'_newline ///
`" for (i in 2:nzb) {"'_newline ///
`" zk <- zk+ coef_zk[i]*listzkf[[i]]"'_newline ///
`" zf <- zf+ coef_zf[i]*listzkf[[i]]"'_newline ///
`" }"'_newline ///
`" zk[is.na(zk)] <- 0"'_newline ///
`" zf[is.na(zf)] <- 0"'_newline ///
`" gneta_k <- exp(zk)/(1+exp(zk)+exp(zf)) "'_newline ///
`" gneta_f <- exp(zf)/(1+exp(zk)+exp(zf)) "'_newline ///
`" gneta_m <- 1/(1+exp(zk)+exp(zf)) "'_newline ///
`" deflatexp_f <- lnexp + log(gneta_f) "'_newline ///
`" deflatexp_m <- lnexp + log(gneta_m) "'_newline ///
`" deflatexp_k <- lnexp + log(gneta_k) "'_newline ///
`" deflatexp_f2 <- deflatexp_f**2"'_newline ///
`" deflatexp_m2 <- deflatexp_m**2"'_newline ///
`" deflatexp_k2 <- deflatexp_k**2"'_newline ///
`" clistf<- list(deflatexp_f , deflatexp_f2 )"'_newline ///
`" clistm<- list(deflatexp_m , deflatexp_m2 )"'_newline ///
`" clistk<- list(deflatexp_k , deflatexp_k2 )"'_newline ///
`" listf <- do.call(c, list(listf0, clistf))"'_newline ///
`" listm <- do.call(c, list(listm0, clistm))"'_newline ///
`" listk <- do.call(c, list(listk0, clistk))"'_newline ///
`" names(clistf)"'_newline ///
`" names(clistm)"'_newline ///
`" names(clistk)"'_newline ///
`" u_shexcl_fb<-shexcl_f - gneta_f*coef_f0 "'_newline ///
`" for (i in 1:nlif){"'_newline ///
`" u_shexcl_fb <- u_shexcl_fb- gneta_f*coef_f[i]*listf[[i]]"'_newline ///
`" }"'_newline ///
`" u_shexcl_mb<-shexcl_m -gneta_m*coef_m0 "'_newline ///
`" for (i in 1:nlim){"'_newline ///
`" u_shexcl_mb <- u_shexcl_mb- gneta_m*coef_m[i]*listm[[i]]"'_newline ///
`" }"'_newline ///
`" u_shexcl_f1 <-u_shexcl_fb- rf1*resid_lnexp"'_newline ///
`" u_shexcl_f2 <-u_shexcl_fb- rf2*resid_lnexp"'_newline ///
`" u_shexcl_f3 <-u_shexcl_fb- rf3*resid_lnexp"'_newline ///
`" u_shexcl_m1 <-u_shexcl_mb- rm1*resid_lnexp"'_newline ///
`" u_shexcl_m2 <-u_shexcl_mb- rm2*resid_lnexp"'_newline ///
`" u_shexcl_m3 <-u_shexcl_mb- rm3*resid_lnexp"'_newline ///
`" u_shexcl_k1 <- shexcl_k-gneta_k*coef_k0"'_newline ///
`" for (i in 1:nlik){"'_newline ///
`" u_shexcl_k1 <- u_shexcl_k1- gneta_k*coef_k[i]*listk[[i]]"'_newline ///
`" }"'_newline ///
`" u_shexcl_k1 <- u_shexcl_k1- rk*resid_lnexp "'_newline ///
`" u_shexcl_k1[is.na(u_shexcl_k1)] <- 0"'_newline ///
`" u_shexcl_f0[is.na(u_shexcl_f0)] <- 0"'_newline ///
`" u_shexcl_m0[is.na(u_shexcl_m0)] <- 0"'_newline ///
`" u_shexcl_k0[is.na(u_shexcl_k0)] <- 0"'_newline ///
`" u_shexcl_f1[is.na(u_shexcl_f1)] <- 0"'_newline ///
`" u_shexcl_m1[is.na(u_shexcl_m1)] <- 0"'_newline ///
`" u_shexcl_k1[is.na(u_shexcl_k1)] <- 0"'_newline ///
`" u_shexcl_f2[is.na(u_shexcl_f2)] <- 0"'_newline ///
`" u_shexcl_m2[is.na(u_shexcl_m2)] <- 0"'_newline ///
`" u_shexcl_f3[is.na(u_shexcl_f3)] <- 0"'_newline ///
`" u_shexcl_m3[is.na(u_shexcl_m3)] <- 0"'_newline ///
`" u_shexcl_f <- u_shexcl_f0*(type==20) + u_shexcl_f1*(type==21) + u_shexcl_f2*(type==22) + u_shexcl_f3*(type==23)"'_newline ///
`" u_shexcl_m <- u_shexcl_m0*(type==20) + u_shexcl_m1*(type==21) + u_shexcl_m2*(type==22) + u_shexcl_m3*(type==23)"'_newline ///
`" u_shexcl_k <- u_shexcl_k0*(type==20) + u_shexcl_k1*(type>20)"'_newline ///
`" x <- cbind(u_shexcl_f,u_shexcl_m,u_shexcl_k)"'_newline ///
`" mu <- matrix(0,3,1)"'_newline ///
`" dens <- dmvnorm(x, mu, omega,log=TRUE)"'_newline ///
`" return(dens) "'_newline ///
`" }"'_newline 
file close rcode2
/*doedit  Likelihood_CollDF_S.R */
end


