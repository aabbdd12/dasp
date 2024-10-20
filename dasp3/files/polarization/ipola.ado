#delimit ;
capture program drop ipola;
program define ipola, eclass;
version 9.2;
syntax varlist (min=1 max=1) [, 
HSize(varname)  HGroup(varname)
CONF(string) LEVEL(real 95) DEC(int 6)
INDEX(string)
BAND(string) INISAVE(string) *
ALpha(real 0.5) FAST(int 0) /* 1 et 4 */
NG(int 4) Beta(real 1) NITR(int 16) PRCS(real 0.000001)  GNumber(int 1) /* 3: add alpha */
];


 if "`index'" == ""  local index = "der" ;
 if ("`inisave'" ~="") {;
  qui asdbsave_dasp `0' diabox(ipola);
  };

 
if "`index'" == "der"  {;;
ipolder   `0' ;
};


if "`index'" == "fw" {;
ipolfw   `0';
};

if "`index'" == "egr" {;
ipoegr   `0';
};
  
if "`index'" == "ip" {;
dspol   `0';
};



end;