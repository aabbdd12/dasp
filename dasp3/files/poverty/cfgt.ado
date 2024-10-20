#delim ;
capture program drop cfgt;
program define cfgt, rclass;
version 9.2;
syntax varlist(min=1)[,  HSize(varname) HGroup(varname) ALpha(real 0) 
type(string)  LRES(int 0) SRES(string) CONF(string) LEVEL(real 95) DCI(string)
 DIF(string) MIN(string) MAX(string) DGRA(int 1) SGRA(string) EGRA(string) *];
 
if  "`dci'" ~= "yes"  {;
cfgtl   `0';
};

if  "`dci'" == "yes" {;
cfgtm   `0';
};
 
 
 
 end;