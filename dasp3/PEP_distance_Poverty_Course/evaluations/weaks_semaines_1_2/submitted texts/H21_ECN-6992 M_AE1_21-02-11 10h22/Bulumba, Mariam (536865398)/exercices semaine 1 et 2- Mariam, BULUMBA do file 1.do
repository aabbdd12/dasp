********9.5%

//*code stata pour l'exercice 1*********4%
// Q1:
clear
/* insertion des données */
clear
input region income hhsize
1      1      310    4
2      1      460    6
3      1      300    5
4      1      220    3
5      2      560    2
6      2      400    4
7      3      140    3
8      3      250    2
9      3      340    2
10     3      220    2
end
/* generating variable the variable per capita income */
gen pcinc = income/hhsize
//Q2
/*estimation du revenu moyen par habitant */
sum pcinc [aw=hhsize] 
/*estimation du revenu total de la population */
sum (income)
// Q3:
gen pline = 120
gen pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
sum pgap [aw=hhsize]

// Q4:
ifgt pcinc, pline(120) alpha(1) hsize(hhsize)

// Q5:
gen deflator = 1
replace deflator = 1.2 if region == 2
replace deflator = 1.4 if region == 3
gen rpcinc = pcinc/deflator
 
// Q6
sum rpcinc [aw=hhsize]
replace pline = 110
replace pgap = (pline-rpcinc)/pline if (rpcinc < pline)
sum pgap [aw=hhsize]
ifgt rpcinc, pline(110) alpha(1) hsize(hhsize)




