*******voir word
clear
input hhid region income hhsize
1 1 210 4
2 1 450 6
3 1 300 5
4 1 210 3
5 2 560 2
6 2 400 4
7 3 140 4
8 3 250 2
9 3 340 2
10 3 220 2
11 3 360 3
12 3 338 3
end
*region A = 1
*region B = 2
*region C = 3

*Q1. Generating per capita income
gen pcinc = income/hhsize
*Q2 estimating the average per capita income and the total incomes of our population.
sum  pcinc [aw=hhsize]
total(income)

*Q3
gen pline = 100
*generating per capita poverty gap
gen pgap = 0
*estimate its average (normalized by the poverty line)
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
sum pgap [aw=hhsize]


*Q4
ifgt pcinc, pline (100) alpha (1) hsize (hhsize)
*Q5
gen deflator = 1
replace deflator = 1.1 if region == 2 
replace deflator = 1.3 if region == 3
generate rpcinc = pcinc/deflator
sum rpcinc [aw=hhsize]

*Q6 Redo the question 1.3 and 1.4 using the real per capita income when the poverty line is 120
replace pline = 120
replace pgap = (pline-rpcinc)/pline if (rpcinc < pline)
sum pgap [aw=hhsize]
ifgt rpcinc, pline (120) alpha (1) hsize (hhsize)

