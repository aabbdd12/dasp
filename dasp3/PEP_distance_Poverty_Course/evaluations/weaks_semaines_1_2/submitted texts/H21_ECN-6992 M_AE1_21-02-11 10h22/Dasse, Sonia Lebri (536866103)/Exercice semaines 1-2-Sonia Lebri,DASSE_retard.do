********************11.5%

//Stata code for the exercise 1*****4%
clear
/* Inserting the data */ 
clear

input 	region	income	hhsize
1	310	4
1	460	6
1	300	5
1	220	3
2	560	2
2	400	4
3	140	3
3	250	2
3	340	2
3	220	2
end

//  Q1: 
/* Generating variable the variable per capita income */ 
gen pcinc = income/hhsize

//  Q2: 
/* Estimating the average per capita income */ 
sum pcinc [aw=hhsize]

//  Q3: 
gen     pline = 120
gen     pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
sum     pgap [aw=hhsize]

//  Q4:
ifgt pcinc, pline(120) alpha(1) hsize(hhsize)

//  Q5:
gen     deflator = 1
replace deflator = 1.2 if region == 2
replace deflator = 1.4 if region == 3
gen     rpcinc = pcinc/deflator

// Q6
sum rpcinc [aw=hhsize]
replace pline = 110
replace pgap  = (pline-rpcinc)/pline if (rpcinc < pline)
sum     pgap [aw=hhsize]
ifgt    rpcinc, pline(110) alpha(1) hsize(hhsize)


//Stata code for the exercise 2 ***3%

. clear

. use "C:\Users\hp\Documents\Cours en ligne\Université Laval\Cours\ECN-6992_Measuring and Alleviating Poverty and Inequality\Exercices semaines 1 et 2_devoir\data_2.dta"

 //Q1* Generating the variable for per capita income */ 

 imean ae_exp, hsize(hhsize)

 //Q2
svyset psu [pweight=sweight], strata(strata)  
gen nominator   = hhsize*ae_exp
gen denominator = hhsize
svy: ratio nominator/denominator

//Q3

bysort region: su ae_exp

#delimit;
dimean ae_exp ae_exp, hsize1(hhsize) test(86480) cond1(strata==3 ) hsize2(hhsize) cond2(strata==1 ) conf(ub);

//Q4
#delimit;
dimean ae_exp ae_exp, hsize1(hhsize) test(0) cond1(sex==1) hsize2(hhsize) cond2(sex==2) conf(ub);


//Stata code for the exercise 3 ***5%

//Q1 Taille de la population échantillonnée
gen thhsize=psu*hhsize

// Q2
/* sorting the data by the per capita income */ 
sort pcexp

/* generating the variable of the proportion of population */
sum hhsize
gen ps = hhsize/r(sum)

/* generating the variable percentile and the quantiles */ 
gen p = sum(ps)
gen q = pcexp


//Q3
#delimit ;
line  p pcexp, title(The cumulative distribution curve) xtitle(the percentile (p)) ytitle(les dépenses par habitant(y));
 
// Q4
#delimit ;
line  q p , title(The quantile curve)   xtitle(the percentile (p))  ytitle(The quantile Q(p));

// Q5
c_quantile pcexp, hsize(sex)

// Q6
cdensity pcexp, hs(hhsize) band(3) min(0) max(1000000)

