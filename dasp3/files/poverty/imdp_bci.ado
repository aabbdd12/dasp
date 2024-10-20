
#delim ;
capture program drop imdp_bci;
program define imdp_bci, rclass;
version 9.2;
syntax varlist(min=1)[,  * ];
imdpov `varlist' ,  `options'  index(7) ; ;
end;

