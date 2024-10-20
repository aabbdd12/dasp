
/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 1.4)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2008)          */
/* Université Laval, Quebec, Canada                                    */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : mk_xtab_m1                                                  */
/*************************************************************************/


#delim ;
capture program drop mk_xtab_m1;
program define mk_xtab_m1, rclass;
version 9.2;
syntax anything [,  matn(string) dstd(int 1) dec(int 6)
 xfil(string) xshe(string) xtit(string)  xlan(string) hsep(int 0) note(string)];

tokenize `namelist';
if (`dstd'!=0 )                 local note1 = "[-] Standard errors are in italics.";
if (`dstd'!=0 & "`xlan'"=="fr") local note1 = "[-] Les erreurs types sont en format italique.";

                local lnb= 2*$indica;
if (`dstd'==0)  local lnb=   $indica;

                local frm = "SCCB0 N231`dec' N232`dec'";
if (`dstd'==0)  local frm = "SCCB0 N230`dec'";
                local lst1 = rowsof(`matn')-2;
if (`dstd'==0)  local lst1 = rowsof(`matn')-1;
xml_tab `matn', save(`xfil') sheet(`xshe')
newappend
rnames($rnam)
cnames($cnam)
title(`xtit')  
lines(0 13 COL_NAMES 2 `lnb' 2 `lst1'  2 LAST_ROW 13)  
notes( "`note1'" ,  "`note'")
font("Courier New" 8)
format((S2110) (`frm'))
;
end;
