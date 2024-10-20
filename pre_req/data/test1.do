      
  

use data/mroz, clear

reg lwage educ exper expersq 


heckman lwage educ exper expersq, select(inlf=nwifeinc educ exper expersq age kidslt6 kidsge6) twostep


heckman lwage educ exper expersq nwifeinc age kidslt6 kidsge6, select(inlf=nwifeinc educ exper ///
	expersq age kidslt6 kidsge6) twostep mills(lambda)

use data/mroz, clear

probit inlf nwifeinc motheduc fatheduc huseduc exper expersq age kidslt6 kidsge6
predict xb, xb
cap drop lambda
gen lambda = normalden(xb)/normal(xb)
ivreg lwage (educ =nwifeinc motheduc fatheduc huseduc age kidslt6 kidsge6 ) exper expersq lambda
