
#delim ;
capture program drop imdp_mfi;
program define imdp_mfi, rclass;
version 9.2;
syntax varlist(min=1)[,  * ];
imdpov `varlist' ,  `options'  index(3) ; ;
end;

