
#delim ;
capture program drop imdp_tsu;
program define imdp_tsu, rclass;
version 9.2;
syntax varlist(min=1)[,  * ];
imdpov `varlist' ,  `options'  index(4) ; ;
end;

