
#delim ;
capture program drop imdp_cmr;
program define imdp_cmr, rclass;
version 9.2;
syntax varlist(min=1)[,  * ];
imdpov `varlist' ,  `options'  index(1) ; ;
end;

