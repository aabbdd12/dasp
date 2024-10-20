#delimit ;
use http://dasp.ecn.ulaval.ca/ds/data/mydata , replace;
local indepvars  sex age i.marital i.education i.activity ;
xi: wquaids wcereal-wpasta, anot(10) lnprices(luvcereal-luvpasta) expenditure(hhexp) demographics(`indepvars')   hweight(sweight);
