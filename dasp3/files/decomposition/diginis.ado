
#delimit ;
capture program drop diginis;
program define diginis, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname)  HGroup(varname)  APPR(string) SAPPR(string) TYPE(string) CONF(string)
LEVEL(real 95) DEC(int 6) DSTE(int 1)  XFIL(string) XSHE(string) XLAN(string) XTIT(string) MODREP(string)];

if ("`appr'"~="sha") {;
	diginisr `0';
};

if ("`appr'"=="sha") {;
	dsginis  `0';
};


end;