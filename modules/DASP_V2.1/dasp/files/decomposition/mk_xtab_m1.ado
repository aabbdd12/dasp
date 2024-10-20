
/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.1)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : mk_xtab_m1                                                  */
/*************************************************************************/


#delim ;
capture program drop mk_xtab_m1;
program define mk_xtab_m1, rclass;
version 9.2;
syntax anything [,  matn(string) dste(int 1) dec(int 6)
 xfil(string) xshe(string) xtit(string)  xlan(string) hsep(int 0) note(string)];

tokenize `namelist';
if (`dste'!=0 )                 local note1 = "[-] Standard errors are in italics.";
if (`dste'!=0 & "`xlan'"=="fr") local note1 = "[-] Les erreurs types sont en format italique.";

                local lnb= 2*$indica;
if (`dste'==0)  local lnb=   $indica;

                local frm = "SCCB0 N231`dec' N232`dec'";
if (`dste'==0)  local frm = "SCCB0 N230`dec'";
                local lst1 = rowsof(`matn')-2;
if (`dste'==0)  local lst1 = rowsof(`matn')-1;
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
