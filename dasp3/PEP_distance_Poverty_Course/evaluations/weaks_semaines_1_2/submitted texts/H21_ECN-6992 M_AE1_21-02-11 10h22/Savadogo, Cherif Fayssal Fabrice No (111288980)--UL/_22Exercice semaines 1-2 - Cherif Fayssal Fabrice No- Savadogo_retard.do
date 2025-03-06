******************8%

// Exercice 1************3.5%
// Q1:
clear
/* Saisie des données */
clear
input hhid region income hhsize
1 1 310 4
2 1 460 6
3 1 300 5
4 1 220 3
5 2 560 2
6 2 400 4
7 3 140 3
8 3 250 2
9 3 340 2
10 3 220 2
end

/* Générer le revenu par habitant */
generate pcinc = income/hhsize

// Q2:
/* Estimez le revenu moyen par habitant */
summarize pcinc
total r(mean)
/* Le revenu total */

// Q3
/* Générer la variable inensité de pauvreté */
generate pline = 120
generate pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
/*Estimez sa moyenne */
summarize pgap

// Q4
/* Faisons la question Q3 avec DASP */
ifgt pcinc, pline(120) alpha(1) hsize(hhsize)

//Q5
/* Générer la variable (deflator) */
generate deflator = 1
replace deflator = 0.8 if region == 2
replace deflator = 0.6 if region == 3
/* Générer la variable du revenu réel par habitant */
generate rpcinc = pcinc/deflator

//Q6
summarize rpcinc
replace pline = 110
replace pgap = (pline-rpcinc)/pline if (rpcinc < pline)
summarize pgap
ifgt rpcinc, pline(110) alpha(1) hsize(hhsize)




// Exercice 3**********4.5%
// Q1 Taille du ménage
total hhsize

// Q2
sort pcexp

/* Générer la part de la part de la population */
summarize hhsize
generate ps = hhsize / r(mean)

/* Générer les variables centiles et quantiles */
summarize ps
generate p = r(mean)
generate q = pcexp

// Q3 La courbe de distribution cumulative
line  pcexp p, title(The cumulative distribution) xtitle(centile (y)) ytitle(F(y))

//Q4 La courbe quantile
line  q p , title(The quantile curve) xtitle(the percentile (p)) ytitle(The quantile Q(p))

// Q5 En utilisamt DASP
c_quantile sex, hsize(hhsize)
