#delimit ;
capture program drop ineq;
program define ineq, eclass;
version 9.2;
syntax varlist (min=1) [, HSize(varname) HWeight(varname) RANK(varname) 
EPSIlon(real 0.5) THETA(real 1)  p1(real 0.1) p2(real 0.2) p3(real 0.8) p4(real 0.9) index(string) 
HGroup(varlist)  GNumber(int -1) CI(real 5)  CONF(string) LEVEL(real 95)  DEC1(int 6)  DEC2(int 6)  TYPE(string) INISAVE(string)
XFIL(string) XSHE(string)  XLAN(string) XTIT(string) MODREP(string)
];

 if "`index'" == ""  local index = "gini" ;
 if ("`inisave'" ~="") {;
  qui asdbsave_dasp `0' diabox(ineq);
  };
 
 

if "`index'" == "gini" | "`index'" == "agini" | "`index'" == "conc" | "`index'" == "aconc"  {;
if ("`index'" == "agini" | "`index'" == "aconc")  local type = "abs" ;
genjobgini   `0' type(`type');
};


if "`index'" == "atk" {;
genjobatk   `0';
};

if "`index'" == "entropy" {;
genjobent   `0';
};
  
if "`index'" == "covar" {;
genjobcvar   `0';
};

if "`index'" == "qr" | "`index'" == "sr" {;
genjobine  `0';
};
  

end;
