******************11,5%


*************4%

input //(a) group	inc1
1	1
1	2
1	9
 igini inc1

group	inc1
2	3
2	6
2	27
 igini inc1//
 
// (b)
 group	inc1
1	1
1	2
1	9
2	3
2	6
2	27
 igini inc1//
 
 //(c)
 group	inc1	inc2	inc3
1	1	2	2
1	2	2	4
1	9	2	18
2	3	6	2
2	6	6	4
2	27	6	18
dentropyg inc1, hgroup(gr) theta(0)
dentropyg inc2, hgroup(gr) theta(0)//
//1-2
dentropyg inc1, hgroup(gr) theta(0)
dentropyg inc2, hgroup(gr) theta(0)
dentropyg inc3, hgroup(gr) theta(0)//

//1-3
igini inc1
igini inc2
igini inc3 //

*exercice 2***4%

//2-1
gen pcincatA = pre_tax_income * (1.00-0.1)/hhsize
gen pcincatB = pre_tax_income * (1.00-0.1)/hhsize

scalar v_all_A = 6000*0.2*0.1/5
gen pceldA = nelderly *v_all_A/hhsize
    pceldB=0
	 
scalar child_all_A = 6000*0.8*0.1/15
scalar child_all_B = 6000*0.1/15 
gen pcallowA = nchild*child_all_A/hhsize
gen pcallowB = nchild*child_all_B/hhsize

gen dpcincA= pcincatA+ pceldA+ pcallowA
gen dpcincB= pcincatB+ pcallowB//

//2-2
igini dpcincA dpcincB , hsize(hhsize)//

//2-3
diginis pcincatA pceldA pcallowA , hsize(hhsize)
 diginis pcincatB pcallowB, hsize(hhsize)//
 
 //2-5 
 gen pcinc = pre_tax_income/hhsize
difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(0)//

//2-6
difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(1)//


*exercice3*3%
//3-1
svyset psu [pweight=sweight], strata(strata)//

//3-2
ifgt ae_exp, pline(21000) hs( hsize)//

//3-3
ifgt ae_exp, pline(21000) hs( hsize) hgroup(sex)//










