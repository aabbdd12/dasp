#delimit ;
capture program drop dipov;
program define dipov, eclass;
version 9.2;
syntax  namelist(min=2 max=2) [, FILE1(string) FILE2(string) HSize1(string) HSize2(string)
ALpha(real 0)  COND1(string) COND2(string) HGroup(string)
PLINE1(string) OPL1(string) PROP1(real 50) PERC1(real 0.4)
PLINE2(string) OPL2(string) PROP2(real 50) PERC2(real 0.4)
type(string) LEVEL(real 95) CONF(string) DEC(int 6) BOOT(string) NREP(string) TEST(string)
INISAVE(string) index(string)
XFIL(string) XSHE(string)  XLAN(string) XTIT(string) MODREP(string)
dec1(int 4)
dec2(int 4)
];


 if ("`inisave'" ~="") {;
  qui asdbsave_di_dasp `0' diabox(dipov);
  };
  
local indlist fgt ede watts sst ;
if "`index'" ~= "" {;
local fal = 1 ;
foreach name of local indlist {;
	if "`name'" == "`index'" local fal = 0;
};
if `fal' == 1 {;
	dis as error "Wrong index(`index') option. The please select an index among the following indices: fgt, ede, watts and sst.";
	exit;
};
};

if ("`pline1'" == "" & "`opl1'"  == "" ) {;
dis as error "The option pline1(.) is required.";
exit;
};

if ("`pline2'" == ""  & "`opl2'"  == "") {;
dis as error "The option pline2(.) is required.";
exit;
};
/*
if "`index'" == "fgt" {;
difgt `0';


};

if "`index'" == "watts" {;
diwatts `0';
};

if "`index'" == "sst" {;
disst `0';
};
*/
/*set trace on ;*/
set tracedepth 3;
gen_pov_2d `0';

end;