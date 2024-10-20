
#delim ;
capture program drop imdp_ewi;
program define imdp_ewi, rclass;
version 9.2;
syntax varlist(min=1)[,  * ];
imdpov `varlist' ,  `options'  index(2) ; ;
end;

