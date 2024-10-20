set more off
clear

sjlog using switch_probit1, replace
use switch_probit_example
switch_probit works age age2 wedu_2-wedu_5 hhsize hhsize2 reg_*, ///
 select(migrant age age2 wedu_2-wedu_5 hhsize hhsize2 reg_* pmigrants)
sjlog close, replace

sjlog using switch_probit2, replace
predict tt, tt
summarize tt if (migrant == 1)
sjlog close, replace
