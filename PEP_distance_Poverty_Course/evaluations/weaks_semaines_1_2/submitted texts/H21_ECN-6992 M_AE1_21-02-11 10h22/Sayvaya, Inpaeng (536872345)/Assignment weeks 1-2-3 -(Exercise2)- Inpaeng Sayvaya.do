


******3%
use "D:\Inpaeng-PhD Scholarshipn\PEP Online Training Program\Assessments\data_2.dta" 
*2.1 Using the file data_2, estimate the average per adult equivalent expenditures without using the sampling weight and by using the DASP command imean. What does this statistic refer to?
*A:
imean ae_exp , hsize(hhsize)
*2.2 By using the variables strata, psu and the sampling weight variable, initialise the sampling design, and then estimate the average per adult equivalent expenditure.  
*A:
svyset _n [pweight=sweight], strata(strata)
gen nominator   = hhsize*ae_exp
gen denominator = hhsize
svy: ratio nominator/denominator
*2.3 Test whether the average per adult equivalent expenditure in region 1 is higher than the double of that of region 3. 
*A:
dimean ae_exp ae_exp , hsize1(hhsize) test(2) cond1(strata==3 ) hsize2(hhsize) cond2(strata==1 ) conf(ub)
*2.4 Using the DASP command dimean test whether the average per adult equivalent expenditure for male household heads is higher than that of female households headed.  Briefly discuss your results.
*A
gen sex_id= sex
dimean ae_exp ae_exp , hsize1(hhsize) test(0) cond1( sex_id ==2) hsize2(hhsize) cond2( sex_id ==1 ) conf(ub)
