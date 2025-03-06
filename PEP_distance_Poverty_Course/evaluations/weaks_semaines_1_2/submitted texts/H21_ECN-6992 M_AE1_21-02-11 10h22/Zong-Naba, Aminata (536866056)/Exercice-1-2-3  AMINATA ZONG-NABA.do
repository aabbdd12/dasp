************11%

//Stata code for the exercise 1*****3.5%
//  Q1.1: 
clear
/* Insertion des données */ 
clear
input	region	income	hhsize
1	1	210	4
2	1	450	6
3	1	300	5
4	1	210	3
5	2	560	2
6	2	400	4
7	3	140	4
8	3	250	2
9	3	340	2
10	3	220	2
11	3	360	3
12	3	338	2
13	3	330	3
14	3	336	4

end

/* Generons le revenu par habitant (pcinc) */ 
gen pcinc = income/hhsize

//  Q1.2: 
/* Estimons le revenu moyen par habitant et le revenu total de notre population*/ 
sum pcinc [aw=hhsize]

//  Q1.3: 
gen     pline = 120
gen     pgap = 0
replace pgap = (pline-pcinc)/pline if (pcinc < pline)
sum     pgap [aw=hhsize]

//  Q1.4:Refaire la question 3 avec DASP*/
ifgt pcinc, pline(120) alpha(1) hsize(hhsize)

//  Q1.5:
gen     deflator = 1
replace deflator = .85 if region == 2
replace deflator = 1.2 if region == 3
gen     rpcinc = pcinc/deflator

// Q1.6
//refaire Q1.3 lorsque le seuil de pauvreté est 130*/
replace pline = 130
replace pgap  = (pline-rpcinc)/pline if (rpcinc < pline)
sum     pgap [aw=hhsize]
//refaire Q1.4 lorsque seuil de pauvreté est 130*/
ifgt    rpcinc, pline(130) alpha(1) hsize(hhsize)

//Insertion de donnée pour l'exercise 2***3%
clear
input	period	income	hhsize	na
1	1	29	4	2
2	1	50	3	2
3	1	36	4	3
1	2	30	4	2
2	2	48	3	3
3	2	46	5	2

end

/* Generons le revenu moyen par habitant */ 
gen pcinc = income/hhsize

/* le revenu moyen par habitant pour la premiere periode*/ 
sum pcinc [aw=hhsize] if period == 1

/* le revenu moyen par habitant pour la deuxieme periode*/ 
sum pcinc [aw=hhsize] if period == 2

/* Le revenu moyen par equivalence-adulte*/
gen aes = 1 + 0.6 * (na-1) + 0.4 * (hhsize-na) 
gen eainc = income/aes

/* Le revenu moyen par equivalence-adulte a la periode 1*/
sum  eainc[aw=hhsize] if period == 1

 /* Le revenu moyen par equivalence-adulte a la periode 2*/
sum  eainc[aw=hhsize] if period == 2

//Exercise 3*/**********4.5%
//Q3.1 La taille du menage*/
sum hhsize

//Q3.2
// depense par habitant par ordre croissant*/
sort pcexp

//* generons ps la proportion de la population echantillonnée avec les depenses */
sum hhsize
gen ps = hhsize/r(sum)

//* generons les variaables centiles(p) et quantiles(q)*/
gen p = sum(ps)
gen q = pcexp

#delimit ;
// Q3.3 la courbe de distribution cumulative
line  pcexp p, title(courbe cumulative) xtitle(centiles(y)) ytitle(Total expenditures per capita(x));

#delimit ;
// Q3.4 la courbe des quantiles
line  q p , title(courbe des quantiles)   xtitle(centile (p))  ytitle(quantile(p));
