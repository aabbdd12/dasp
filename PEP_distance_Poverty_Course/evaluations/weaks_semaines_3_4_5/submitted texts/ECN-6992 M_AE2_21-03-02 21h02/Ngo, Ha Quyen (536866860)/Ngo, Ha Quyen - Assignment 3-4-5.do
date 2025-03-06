***************12,5%

// WEEKS 1-2-3 ASSIGNMENT
// NGO, HA QUYEN


// EXERCISE 1 ==================================================================4%

// Q1.1a - Q1.1b:
/* Inserting the data */ 
clear
input 	group 	inc1 inc2 inc3
	1	2	16		2
	1	4	16		4
	1	18	16		18
	2	4	32		2
	2	8	32		4
	2	36	32		18
end

diginig inc1, hgroup(group)

// Q1.1c:
diginig inc1, hgroup(group)
diginig inc2, hgroup(group)

dentropyg inc1, hgroup(group) theta(0)
dentropyg inc2, hgroup(group) theta(0)

// Q1.2:
dentropyg inc1, hgroup(group) theta(0)
dentropyg inc2, hgroup(group) theta(0)
dentropyg inc3, hgroup(group) theta(0)

// Q1.3:
igini inc*


// EXERCISE 2 ==================================================================5.5%

// Q2.1:
clear
/* Insert the data */ 
input identifier pre_tax_income  hhsize nchild
1	480		8	4
2	1200	10	6
3	460		6	4
4	2500	6	2
5	3800	8	2
6	560		8	4
7	1240	6	2
8	1760	8	6
end

/* Generate the per capita post tax income */ 
gen pcincatA = pre_tax_income * (1.00-0.1)/hhsize
gen pcincatB = pre_tax_income * (1.00-0.1)/hhsize

/* Generate the per capita post tax income */ 
scalar  total_tax = 12000*0.1
gen pcuincA = total_tax*0.6/60
gen pcuincB = 0

/* Generate the per capita child allowances  */ 
gen child_all_A = total_tax*0.4/30
gen child_all_B = total_tax/30
gen  pcallowA = nchild*child_all_A/hhsize
gen  pcallowB = nchild*child_all_B/hhsize

/* Generate the per capita disposable income  */ 
gen dpcincA = pcincatA+ pcuincA+ pcallowA
gen dpcincB = pcincatB+ pcuincB+ pcallowB

// Q2.2:
igini dpcinc*, hsize(hhsize)

// Q2.3:
diginis pcincatA pcuincA pcallowA, hsize(hhsize)
diginis pcincatB pcuincB pcallowB, hsize(hhsize)

// Q2.5:
gen pcinc = pre_tax_income/hhsize
difgt dpcincB pcinc, hsize1(hhsize)  hsize2(hhsize) pline1(100) pline2(100) alpha(0)

// Q2.6
difgt dpcincB pcinc, hsize1(hhsize)  hsize2(hhsize) pline1(100) pline2(100) alpha(1)


// EXERCISE 3 ==================================================================3%

clear
use "/Users/partsofqueenie/Downloads/data_3.dta", clear

// Q3.1:
svyset psu [pweight=sweight], strata(strata)

// Q3.2:
ifgt ae_exp, pline(21000) hs(hsize)

// Q3.3:
ifgt ae_exp, pline(21000) hs(hsize) hgroup(sex)
