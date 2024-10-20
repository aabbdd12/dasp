#delimit ;
capture program drop dineq;
program define dineq, eclass;
syntax  namelist(min=2 max=2) [, FILE1(string) FILE2(string) 
RANK1(string)  RANK2(string)
HSize1(string) HSize2(string)
COND1(string)  COND2(string)  
HGROUP(string)
TYPE(string) LEVEL(real 95) CONF(string) TEST(string) 
EPSIlon(real 0.5)  THETA(real 1) p1(real 0.1) p2(real 0.2) p3(real 0.8) p4(real 0.9)
INISAVE(string) index(string) BOOT(string) NREP(string) TEST(string)
XFIL(string) XSHE(string)  XLAN(string) XTIT(string) MODREP(string)
dec1(int 4)
dec2(int 4)
TEST(string)
];


 if "`index'" == ""  local index = "gini" ;
 if ("`inisave'" ~="") {;
  qui asdbsave_di_dasp `0' diabox(dineq);
  };

  /*
 if "`index'" == "gini"  dis "Index :  Gini index";
 if "`index'" == "agini" dis "Index :  Absolute Gini index";
 if "`index'" == "conc"  dis "Index :  Concentration index";
 if "`index'" == "aconc" dis "Index :  Absolute concentration index";
 
 if "`index'" == "atk"     dis "Index :  Atkinson index";
 if "`index'" == "entropy" dis "Index :  Generalised entropy index";
 if "`index'" == "covar"   dis "Index :  Coefficient of variation index";
 if "`index'" == "qr"   dis "Index :    Quantile ratio index ";
 if "`index'" == "sr"   dis "Index :    Share ratio index ";
*/

local indlist gini agini conc aconc atk entropy covar qr sr ;
if "`index'" ~= "" {;
local fal = 1 ;
foreach name of local indlist {;
	if "`name'" == "`index'" local fal = 0;
};
if `fal' == 1 {;
	dis as error "Error: The option index(`index') is not allowed. The please select an index among the following indices: `indlist'.";
	exit;
};
};
 if ("`index'" == "agini" | "`index'" == "aconc")  local type = "abs" ;
gen_ineq_2d  `0' ;

end;
