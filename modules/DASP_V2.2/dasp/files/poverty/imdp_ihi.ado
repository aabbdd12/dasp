
#delim ;
capture program drop imdp_ihi;
program define imdp_ihi, rclass;
version 9.2;
syntax varlist(min=1)[,  * ];
imdpov `varlist' ,  `options'  index(5) ; ;
end;

