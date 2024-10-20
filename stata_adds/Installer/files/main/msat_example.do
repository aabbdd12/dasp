


set more off
clear all
set seed 1234
set obs 1000

gen region = 1 in 1/300
replace region = 2 in 301/600
replace region = 3 in 601/1000

gen age = min(int(runiform()*65+15), 65)
replace age = age+5 if region==1
gen educ = min(int(runiform()*5+1), 6)

set seed 7421
gen treatment=3*runiform()*(region==1)+0.5*runiform()*(region==2)+0.5*runiform()*(region==3)+(0.2+0.8*runiform())*(age> 30)
replace treatment = treatment > 1
local a = 0.60
local b = 0.009
gen e= `a'*runiform()
sum e if treatment ==1
qui replace e = e - r(mean) if treatment ==1
sum e if treatment ==0
qui replace e = e - r(mean) if treatment ==0

local at = 2
gen income = 60+0.5*educ+`b'*age+`at'*treatment + e



gen income0 =income - `at'*treatment
gen ins = (0.5+uniform())*age
regress ins income0
predict inst, res

gen pw=1
xi: psmatch2 treatment i.region inst , outcome(income) cal(0.01) pw(pw) ate
return list
local psm_att = r(att)
local psm_ate = r(ate)
local psm_atu = r(atu)


gen lincome = log(income)
set seed 5241
xi: movestay lincome educ , select(treatment i.region inst )
msat treatment, expand(yes)
return list
local esr_att = r(att)
local est_ate = r(ate)
local esr_atu = r(atu)

gen region2= region==2
gen region3= region==3
etregress income i.treatment#c.( educ ) , treat(treatment = region2 region3 inst) vce(robust) poutcomes
margins r.treatment , contrast(nowald) subpop(treatment) vce(unconditional)
local etr_att= el(r(b),1,1)
gen untreatment = treatment!=1
margins r.treatment , contrast(nowald) subpop(untreatment) vce(unconditional)
local etr_atu= el(r(b),1,1)

gen      PSM= `psm_att' in 1
replace  PSM= `psm_atu' in 2

gen      ESR= `esr_att' in 1
replace  ESR= `esr_atu' in 2

gen      ETR= `etr_att' in 1
replace  ETR= `etr_atu' in 2

gen     STAT = "ATT" in 1
replace STAT = "ATU" in 2

tabdis STAT in 1/2 , cell(PSM ESR ETR)

 
