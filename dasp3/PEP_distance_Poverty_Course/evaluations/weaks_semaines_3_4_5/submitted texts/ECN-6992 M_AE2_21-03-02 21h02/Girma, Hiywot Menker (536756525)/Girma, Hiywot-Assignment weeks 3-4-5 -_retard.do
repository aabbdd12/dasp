**********12%


//Excercise 1*****4%
//Question 1.1 a 
gen inc11=inc1 if group==1
gen inc12=inc1 if group==2
igini inc11 inc12

//Question 1.1 c 
theildeco inc1 , byg(group)
theildeco inc2 , byg(group)

//Question 1.2
dentropyg inc1, hgroup(group) theta(0)
dentropyg inc2, hgroup(group) theta(0)
dentropyg inc3, hgroup(group) theta(0)

//Question 1.3
igini inc1 inc2 inc3

//Excercise 2************5%
//Question 2.1
*per capita post tax income with the scenario A; 
 gen pcincatA=pre_tax_income*(1-0.1)/hhsize
 
*per capita post tax income with the scenario B;
gen pcincatB=pre_tax_income*(1-0.1)/hhsize


scalar child_allA=6000*(0.1/15)*0.8
scalar elderly_allA=6000*(0.1/5)*0.2
scalar child_allB=6000*(0.1/15)*1
scalar elderly_allB=6000*(0.1/5)*0

*per capita elderly pension with the scenario A;
gen pceldA=nelderly*elderly_allA/hhsize

*per capita elderly pension with the scenario B;
gen pceldB=nelderly*elderly_allB 
 
*per capita child allowances with the scenario A;
gen pcallowA=nchild*child_allA/hhsize
 
*per capita child allowances with the scenario B;
gen pcallowB=nchild*child_allB/hhsize

*per capita disposable income with the scenario A (pcincatA+ pceldA+ pcallowA);
gen dpcincA= pcincatA+pceldA+pcallowA

*per capita disposable income with the scenario B (pcincatB+ pceldB + pcallowB)
gen dpcincB=pcincatB+ pceldB + pcallowB

//Question 2.2

igini dpcincA dpcincB , hsize( hhsize)

//Question 2.3
digini dpcincA dpcincB , hsize( hhsize)

digini pcincatA pceldA , hsize( hhsize)
digini pcincatA pcallowA , hsize( hhsize)
digini pcincatB pcallowB , hsize( hhsize)

//Question 2.5
difgt  pcincatB dpcincB, pline1(100) pline2(100) hsize( hhsize)

//Question 2.6

difgt  pcincatB dpcincB, pline1(100) pline2(100) hsize( hhsize) alpha(1)


//Excercise 3******3%

//Question 3.1
svyset psu [pweight=sweight], strata(strata)

//Question 3.2
ifgt ae_exp, pline(21000) hs(hsize)

//Question 3.3
ifgt ae_exp, pline(21000) hs(hsize) hgroup(sex)









