
#delimit;
capture program drop mcjob21;
program define mcjob21, eclass;
version 9.2;
syntax varlist(min=1)[, HSize(varname) HGroup(varname) LAN(string) XRNAMES(string) AGGRegate(string) *];
aggrvar `varlist' , xrnames(`xrnames') aggregate(`aggregate');
local  slist  `r(slist)';
local  flist  `r(flist)';
local drlist  `r(drlist)';
mcjobstat `flist',   hs(`hsize') hgroup(`hgroup') lan(`lan')   xrnames(`slist')  stat(exp_tt);
cap drop `drlist';
tempname mat21 ;
matrix `mat21'= e(est);
ereturn matrix est = `mat21';
end;


