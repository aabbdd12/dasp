#delimit ;
use http://dasp.ecn.ulaval.ca/ds/data/mydata , replace;
local indepvars i.sex age i.marital i.education i.activity ;
duvm  cereal bread flour  semolina couscous pasta , hsize(hhsize) expend(hhexp) cluster(cluster) region(region) indepvars(`indepvars') hweight(sweight)  csb(no) boot(0);

duvm  cereal bread flour  semolina couscous pasta , hsize(hhsize) expend(hhexp) cluster(cluster) region(region) indepvars(`indepvars') hweight(sweight)  csb(yes) boot(0);

