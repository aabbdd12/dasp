
#delimit ;
capture program drop cnpe;
program define cnpe, rclass sortpreserve;
version 9.2;
syntax varlist(min=1)[, 
XVAR(varname) 
HWeight(varname) 
HSize(varname) 
HGroup(varname) 
BAND(real 0) 
TYPE(string)
APProach(string) 
MIN(string) 
MAX(string)
RTYPE(string)
XVAL(string)
CONF(string) LEVEL(real 95)  DCI(string) 
LRES(int 0)  SRES(string) VGEN(string) DGRA(int 1) SGRA(string) EGRA(string) *];


 if  "`dci'" ~= "yes"  {;
cnpel   `0';
};

if  "`dci'" == "yes" {;
cnpeci   `0';
};
 


end;