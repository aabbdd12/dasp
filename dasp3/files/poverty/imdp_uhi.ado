
#delim ;
capture program drop imdp_uhi;
program define imdp_uhi, rclass;
version 9.2;
syntax varlist(min=1)[,  * ];
imdpov `varlist' ,  `options' index(6) ;
end;

