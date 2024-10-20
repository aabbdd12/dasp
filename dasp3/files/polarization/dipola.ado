

#delimit ;
capture program drop dipola;
program define dipola, eclass;
version 9.2;
syntax  namelist(min=2 max=2) [, FILE1(string) FILE2(string) 
HSize1(string) HSize2(string)
COND1(string)  COND2(string)  
CONF(string) LEVEL(real 95) DEC(int 6)
INDEX(string)  TEST(string)
 INISAVE(string) *
ALpha(real 0.5) FAST(int 0) BAND(string)

];



 if "`index'" == ""  local index = "der" ;
 if ("`inisave'" ~="") {;
  qui asdbsave_di_dasp `0' diabox(dipola);
  };

 if "`index'" == "der"  dis "Index :  Duclos Esteban and Ray index of polarization (2004)";
 if "`index'" == "fw" dis   "Index :  Foster and Wolfson (1992)";

  
  
  
if "`index'" == "der"  {;;
dipolder   `0' ;
};


if "`index'" == "fw" {;
dipolfw   `0';
};




end;