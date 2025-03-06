******************************10%

*Exercise 1***********3%
*Inputting data*
input id region income hhsize
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
12 3 338 2
13 3 330 3
14 3 336 4
end
*generating per capita income(pcinc)*
gen pcinc= income/ hhsize
* Estimating the average per capita income*
sum pcinc[aw= hhsize]
* Estimating total incomes of the population*
total income
*generating a new variable per capita poverty gap(pgap)assuming poverty line is equal to 120*
gen pline=120
gen pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
*estimating the average poverty gap*
sum pgap [aw=hhsize]
*using DASP*
ifgt pcinc, alpha(1) hsize(hhsize) pline(120)
* generating a variable real per capita income(rpinc)*
gen deflator=1
replace deflator = 0.85 if region ==2
replace deflator = 0.8 if region ==3
gen rpinc= pcinc/ deflator
*re doing question 1.3 and 1.4 using real per capita income when the poverty line is 130*
sum rpinc [aw=hhsize]
replace pline = 130
replace pgap = (pline- rpinc )/pline if ( rpinc < pline)
sum pgap [aw=hhsize]
*using DASP*
ifgt rpinc , alpha(1) hsize(hhsize) pline(130)


*EXRCISE 2************2%
clear
*inputing data*
input id period income hhsize na
1 1 29 4 2
2 1 50 3 2
3 1 36 4 3
1 2 30 4 2
2 2 48 3 3
3 2 46 5 2
end
*estimating the average per capita income for each period*
gen pcinc = income/hhsize
sum pcinc [aw=hhsize] if period == 1
sum pcinc [aw=hhsize] if period == 2
*estimating the average per adult equivalent income for each period*
gen aes = 1 + 0.6 * (na-1) + 0.4 * (hhsize-na)
gen eainc = income/aes
*Estimating the average per adult-equivalent income: period 1*
sum eainc [aw=hhsize] if period == 1
*Estimating the average per adult-equivalent income: period 2*
sum eainc [aw=hhsize] if period == 2


*EXRCISE 3*************5%
clear
use "C:\Users\DHN1\Downloads\data_3.dta"
* to calculate population size of sampled households*
summarize psu
* ranking per capita expenditures in acending order*
sort pcexp
* genarating new variable population share(ps)*
sum hhsize
gen ps= hhsize/r(sum)
*generating the variable percentiles (p) and quantiles(q)*
gen p = sum(ps)
gen q = pcexp
*the cumulative distribution curve*
line p pcexp , title(The cumulative distribution curve) xtitle(The per capita expenditures (y))ytitle(F(y))
*the quantile curve*
line q p , title(The quantile curve) xtitle(the percentile (p)) ytitle(The quantile Q(p))
* using DASP to draw quantile curve*
db c_quantile
c_quantile pcexp, hsize(hhsize) hgroup(zone) min(0.0) max(0.9)
* Using DASP drawing the density curves of the per capita expenditures by sex of household head*
db cdensity
cdensity pcexp, hsize(hhsize) hgroup(sex) type(den) min(0) max(800000)

