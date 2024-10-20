/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2012)          */
/* Université Laval, Quebec, Canada                                    */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : clorenz                                                     */
/*************************************************************************/


#delim ;

capture program drop clorenz;
program define clorenz, rclass;
version 9.2;
syntax varlist(min=1)[, HWeight(varname) HSize(varname) HGroup(varname)
 RANK(varname) MIN(real 0) MAX(real 1) type(string) DIF(string)
 LRES(int 0)  SRES(string) DGRA(int 1) SGRA(string) EGRA(string) POP(string) 
 CONF(string) LEVEL(real 95) LEVEL(real 95) DCI(string) *];
 
 if  "`dci'" ~= "yes"  {;
clorenzl   `0';
};

if  "`dci'" == "yes" {;
clorenzm   `0';
};
 

end;
