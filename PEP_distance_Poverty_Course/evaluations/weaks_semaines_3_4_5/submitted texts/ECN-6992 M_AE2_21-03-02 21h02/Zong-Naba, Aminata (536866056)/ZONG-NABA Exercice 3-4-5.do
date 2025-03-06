**********12%

//Exercice3//****3%

input group	inc1	inc2	inc3
1	2	16	2
1	4	16	4
1	18	16	18
2	4	32	2
2	8	32	4
2	36	32	18

//Q1.1//
igini inc1, hgroup(group)
igini inc1, hsize(group) hgroup(group)
dentropyg inc1, hgroup(gr) theta(0)
dentropyg inc2, hgroup(gr) theta(0)

//Q1.2//
dentropyg inc1, hgroup(gr) theta(0)
dentropyg inc2, hgroup(gr) theta(0)
dentropyg inc3, hgroup(gr) theta(0)

//Q1.3//
igini inc1 inc2 inc3,hsize(group)

clear
//Exercice2//*********5%

input pre_tax_income 	hhsize	nchild
480	8	4
1200	10	6
460	6	4
2500	6	2
3800	8	2
560	8	4
1240	6	2
1760	8	6
end
//Q2.1//
gen pcincatA = pre_tax_income*(1.00-0.1)/hhsize
gen pcincatB = pre_tax_income * (1.00-0.1)/hhsize
//generer taxeA//
gen taxe= pre_tax_income- pcincatA*hhsize
gen pcuincA = taxe*0.6/hhsize
gen pcuincB = 0
//allocation A//
gen pcallowA = taxe*0.4/30
//taxeB// 
gen taxeB = pre_tax_income - pcincatB*hhsize
//allocation B//
gen pcallowB = taxeB*0.4/30
//Revenu disponible par habitant//
gen dpcincA = pcincatA + pcuincA + pcallowA
gen dpcincB = pcincatB + pcuincB + pcallowB

//Q2.2 utilisons DASP pour mesurer les inegalité de revenu//
igini dpcincA dpcincB, hsize(hhsize)

//Q2.3//
diginis pcincatA pcuincA pcallowA, hsize(hhsize)
diginis pcincatB pcuincB pcallowB, hsize(hhsize)

//Q2.4 VOIR WORD//
//Q2.5//
gen pcinc = pre_tax_income/hhsize
difgt dpcincB pcinc, hsize1(hhsize)  hsize2(hhsize) pline1(100) pline2(100) alpha(1)

//Q2.6//
difgt dpcincB pcinc, hsize1(hhsize)  hsize2(hhsize) pline1(100) pline2(100) alpha(1)
clear

//Exercice3//*******3%

//Q3.1//
svyset psu [pweight=sweight], strata(strata)

//Q3.2//
ifgt ae_exp, pline(21000) hs( hsize)

//Q3.3//
ifgt ae_exp, pline(21000) hs( hsize) hgroup(sex)
