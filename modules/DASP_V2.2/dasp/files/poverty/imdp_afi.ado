
#delim ;
capture program drop imdp_afi;
program define imdp_afi, rclass;
version 9.2;
syntax varlist(min=1)[,  * ];
imdpov `varlist' ,  `options'  index(8) ; ;
end;

