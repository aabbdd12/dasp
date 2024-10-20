#delimit ;
capture program drop ipov;
program define ipov, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) HGroup(varlist) ALpha(real 0) PLine(string) 
OPL(string) PROP(real 50) PERC(real 0.4) REL(string) type(string) INDex(string) CONF(string) LEVEL(real 95)  INISAVE(string)
 DEC1(int 6)  DEC2(int 6)  XFIL(string) XSHE(string)  XLAN(string) XTIT(string) MODREP(string)
];

 if "`index'" == ""  local index = "fgt" ;
 if ("`inisave'" ~="") {;
  qui asdbsave_dasp `0' diabox(ipov);
  };
 
 
genjobpova   `0';

end;