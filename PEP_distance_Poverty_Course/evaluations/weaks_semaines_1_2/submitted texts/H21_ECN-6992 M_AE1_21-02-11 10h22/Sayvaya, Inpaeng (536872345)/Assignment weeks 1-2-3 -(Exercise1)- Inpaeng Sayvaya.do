**********7%


use "D:\Inpaeng-PhD Scholarshipn\PEP Online Training Program\Assessments\Data_Exercise1-(Assigment weeks 1 and 2).dta" 
*Using the file “Data_Exercise1-(Assigment weeks 1 and 2)”
*Assignment weeks 1 and 2
*Exercise 1 (4%)*****************4%
*Q 1.1: Using Stata, generate per capita income (pcinc).
*A:
gen pcinc = income/hhsize
*Q 1.2: Using Stata, estimate the average per capita income and the total income of our population.
*A: 
summarize pcinc income
*Q 1.3: Assume that, the poverty line is equal to 120, generate the variable per capita poverty gap (pgap), and then estimate its average (the per capita poverty gap should be normalized by the poverty line).
*A: 
gen pgap= 120-pcinc
summarize pgap
*Q 1.4: Redo the question Q 1.3 using DASP.
*A: 
ifgt pcinc, alpha(0) hsize(hhsize) pline(120)
*Q 1.5: Assume that the purchasing power in region B is higher than that of region A by 20% and that of region C is higher than that of region A by 40%. In the case where the region A is the region of reference, generate the variable (deflator) as a price deflator index, and then generate the variable real per capita income (rpcinc).
*A: 
*Generate the variable (deflator)
gen deflator= 100 if region_id == 1
replace deflator = 100+(100*0.2) if region_id ==2
replace deflator = 100+(100*0.4) if region_id ==3
*Generate the variable real per capita income (rpcinc)
gen rpcinc = (pcinc/deflator)*100
*Q 1.6: Redo the question 1.3 and 1.4 using the real per capita income when the poverty line is 110.
*A: 
*Redo the question 1.3 
gen rpgap= 110-rpcinc
summarize rpgap
*Redo the question 1.4
ifgt rpcinc, alpha(0) hsize(hhsize) pline(110)
