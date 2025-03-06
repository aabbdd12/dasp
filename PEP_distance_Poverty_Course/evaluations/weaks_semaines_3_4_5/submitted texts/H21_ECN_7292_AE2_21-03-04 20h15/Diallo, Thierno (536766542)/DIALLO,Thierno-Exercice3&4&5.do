******12,5%

// Exercice1************4%

clear all

input groupe inc1 inc2 inc3

        groupe       inc1       inc2       inc3
  1 2 16 2
  1 4 16 4
  1 18 16 18
  2 4 32 2
  2 8 32 4
  2 36 32 18
  end

// Question 1.1 : Le programme ci-dessous donne les resultats a la question a et b:
 
 igini inc1, hgroup(gr)

 //c)
dentropyg inc1, hgroup(gr) theta(0)
dentropyg inc2, hgroup(gr) theta(0)

//Question 1.2

dentropyg inc1, hgroup(gr) theta(0)
dentropyg inc2, hgroup(gr) theta(0)
dentropyg inc3, hgroup(gr) theta(0)

// Question 1.3
 
 igini inc*
 
 
 
 //Exercice2***5%
 
 
 clear all
 input identifier	pre_tax_income  hhsize	nchild
 1 480 8 4
 2 1200 10 6
 3 460 6 4
 4 2500 6 2
 5 3800 8 2
 6 560 8 4
 7 1240 6 2
 8 1760 8 6
 end
 
 //Question 2.1
 gen pcincatA = pre_tax_income * (1.00-0.1)/hhsize
gen	pcincatB = pre_tax_income * (1.00-0.1)/hhsize
 
scalar taxeA=6000*0.1
scalar taxeB=6000*0.1
 
gen pcuincA=taxeA*0.6/30 //revenu universel par habitant
gen pcuincB=0

scalar child_all_A =taxeA*0.4/15 // allocation par enfant
scalar child_all_B=taxeB/15 // allocation par enfant

gen pcallowA=nchild*child_all_A/hhsize // allocation pour enfant
gen pcallowB=nchild*child_all_B/hhsize // allocation pour enfant

gen dpcincA=pcincatA + pcuincA + pcallowA
gen dpcincB=pcincatB + pcuincB + pcallowB
 
 // Question 2.2
igini dpcincA dpcincB , hsize(hhsize)

// Question 2.3
diginis pcincatA pcuincA pcallowA, hsize(hhsize)
diginis pcincatB pcuincB pcallowB, hsize(hhsize)
 
 // Question 2.5
 
gen pcinc = pre_tax_income/hhsize
difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(0)

// Question 2.6
difgt dpcincB pcinc, hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100) alpha(1)
 
 
 
 
 //Exercice3**3%
 
 
  // Question 3.1
 
clear
cd "C:\Users\dmadj\Desktop\Hiver2021\Mesure&AllegementDeLaPauvrete\AssementsEvaluations\Sem3&4&5"
use "data_3.dta" , replace
svyset psu [pweight=sweight], strata(strata)

// Question 3.2

ifgt ae_exp, pline(21000) hs( hsize)

// Question 3.3

ifgt ae_exp, pline(21000) hs( hsize) hgroup(sex)
