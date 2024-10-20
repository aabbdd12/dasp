
#delim;
set more off;
/*******************************/
/* Installing the DASP package */
/*******************************/
net from c:/dasp;
net install dasp.pkg, force replace;


/*******************************/
/*        Appendix IFGT        */
/*******************************/

/*Q.1*/

use  "C:\data\bkf94.dta", clear;
do   "C:\do_files\lab_bkf94.do";
label list;


/*Q.2*/

svyset psu [pweight=weight], strata(strata) vce(linearized);
save "C:\data\bkf94I.dta", replace;
svydes; 

/*Q.3*/
ifgt exppc expeq, hsize(size) alpha(0) pline(41099);

/*Q.4*/

ifgt exppc, hsize(size) alpha(0) opl(median) prop(60);

/*Q.5*/

ifgt exppc, hsize(size) alpha(0) hgroup(sex) pline(41099);

/*Q.6*/

ifgt exppc, hsize(size) alpha(0) hgroup(sex) pline(41099) dec(4) level(99);



/*******************************/
/*        Appendix DIFGT       */
/*******************************/

/*Q.1*/

 /* db difgt; */

/*Q.2*/

difgt exppcz exppc, alpha(0) 
file1(C:\DATA\bkf98I.dta) hsize1(size) 
file2(C:\DATA\bkf94I.dta) hsize2(size) 
pline1(41099) pline2(41099);

/*Q.3*/

difgt exppcz exppc, alpha(0) 
file1(C:\DATA\bkf98I.dta) hsize1(size) cond1(zone==1 ) 
file2(C:\DATA\bkf94I.dta) hsize2(size) cond2(zone==1 ) 
pline1(41099) pline2(41099);

/*Q.4*/

difgt exppcz exppc, alpha(0) 
file1(C:\DATA\bkf98I.dta) hsize1(size) cond1(zone==2 ) 
file2(C:\DATA\bkf94I.dta) hsize2(size) cond2(zone==2 ) 
pline1(41099) pline2(41099);

/*Q.5*/

difgt exppcz exppc, alpha(0) 
file1(C:\DATA\bkf98I.dta) hsize1(size) cond1(zone==2 & sex==1) 
file2(C:\DATA\bkf94I.dta) hsize2(size) cond2(zone==2 & sex==1) 
pline1(41099) pline2(41099);



/*******************************/
/*        Appendix CFGT        */
/*******************************/


/*Q.1*/

use "C:\data\bkf94I.dta", replace;

/*Q.2*/

/* db cfgt; */

/*Q.3*/

cfgt exppc expeq, alpha(0) hsize(size) min(0) max(100000) subtitle(Burkina 1994);


/*Q.4*/

cfgt exppc, alpha(0) hsize(size) hgroup(sex) min(0) max(100000) subtitle(Burkina 1994);

/*Q.5*/

cfgt exppc, alpha(0) hsize(size) hgroup(zone) 
dif(c1) min(0) max(100000) 
sgra(C:\Stata_graphs\graph1.gph) 
egra(C:\Stata_graphs\graph1.wmf) 
lres(1);

/*Q.6*/

cfgt exppc, alpha(1) hsize(size) hgroup(zone) 
dif(c1) min(0) max(100000) 
sgra(C:\Stata_graphs\graph1.gph) 
egra(C:\Stata_graphs\graph1.wmf) 
lres(1);



/*******************************/
/*        Appendix CFGTS       */
/*                 CFGTS2D     */
/*******************************/


/*Q.1*/

use "C:\data\bkf94I.dta", replace;
/* db cfgts; */
cfgts exppc, alpha(0) hsize(size) min(0) max(100000);

/*Q.2*/

/* db cfgts2d; */

cfgts2d exppc exppcz, alpha(0) min(0) max(100000) 
file1(C:\DATA\bkf94I.dta) hsize1(size) 
file2(C:\DATA\bkf98I.dta) hsize2(size)
;

/*Q.3*/

cfgts2d exppc exppcz, alpha(1) min(0) max(100000) 
file1(C:\DATA\bkf94I.dta) hsize1(size) 
file2(C:\DATA\bkf98I.dta) hsize2(size)
;


/*******************************/
/*        Appendix DOMPOV      */
/*******************************/

/*Q.1*/

/* db dompov;*/
dompov exppc exppcz, order(2) 
file1(C:\DATA\bkf94I.dta) hsize1(size) 
file2(C:\DATA\bkf98I.dta) hsize2(size)
;


/*******************************/
/*       Appendix DGFGT        */
/*******************************/

/*Q.1*/

use "C:\data\bkf94I.dta", clear;
/* db dfgtg; */
dfgtg exppc, hgroup(gse) hsize(size) alpha(1) pline(41099);

/*Q.2*/

dfgtg exppc, hgroup(gse) hsize(size) alpha(1) pline(41099) dstd(0) dec(4);



/*******************************/
/*     Appendix CLORENZ        */
/*******************************/

/*Q.1*/

use "C:\data\can6.dta", clear;
/* db  igini; */
clorenz X N;

/*Q.2*/

clorenz X T B1 B2 B3, rank(X);

/*Q.3*/

use "C:\data\bkf94I.dta", clear; 
clorenz expeq, hsize(size) hgroup(zone);


/*******************************/
/*   Appendix IGINI/GIGINI     */
/*******************************/


/*Q.1*/

use "C:\data\can6.dta", clear;
/* db  igini; */
igini X N;

/*Q.2*/

igini T N, rank(X);

/*Q.3*/

/* db digini; */
digini expeqz expeq, 
file1(C:\DATA\bkf98I.dta) hsize1(size) 
file2(C:\DATA\bkf94I.dta) hsize2(size);


/*******************************/
/*        Appendix CDENSITY    */
/*                 C_QUANTILE  */
/*                 CNPE        */
/*******************************/

/*Q.1*/

use "C:\data\can6.dta", clear;
/* db cdensity; */
cdensity X N, min(0) max(60000);


/*Q.2*/

/* db c_quantile; */
c_quantile X N, min(0) max(0.8);


/*Q.3*/


/* db cnpe; */
gen B= B1 + B2 + B3;
/* db cnpe; */
cnpe T B, xvar(X) min(0) max(60000) app(lle);


/*Q.4*/

cnpe T B, xvar(X) min(0) max(60000) app(lle) type(dnp);




