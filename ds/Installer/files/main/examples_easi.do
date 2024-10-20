/* The Stata code suggested code */
#delimit;
use http://dasp.ecn.ulaval.ca/ds/data/mexico_cereal , replace;
save "C:/PDATA/data/mexico_cereal",replace;
sr_easi mexico_cereal , wdir("C:/PDATA/data/")
shares( wcorn wwheat wrice wother wcomp )
lnprices(luvcorn luvwheat luvrice luvother luvcomp)
lnexp(lnexp)
vdemo(age sex educa1-educa10 perso1-perso6)
rtool(C:\Program Files\R\R-3.4.4\bin\x64\R.exe)
power(5)
dec(6)
snames(corn wheat rice other comp)
inpz(0)
inpy(0)
inzy(0)
;
