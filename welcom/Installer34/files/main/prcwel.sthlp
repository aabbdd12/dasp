{smcl}
{* January 2020}{...}
{hline}
{hi:WELCOM : Price Change(s) and WELl-being}
help for {hi:prcwel }{right:Dialog box:  {bf:{dialog prcwel}}}
{hline}
{title: Price Change(s) and WELl-being, poverty and inequality} 
{p 8 10}{cmd:prcwel}  {it:varlist (1 varnames)}  {cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:HGroup(}{it:varname}{cmd:)}
{cmd:PLine(}{it:real}{cmd:)}  
{cmd:NITEMS(}{it:int}{cmd:)} 
{cmd:XFIL(}{it:string}{cmd:)} 
{cmd:INISAVE(}{it:string}{cmd:)}  
{cmd:MEAS(}{it:int}{cmd:)} 
{cmd:MODEL(}{it:int}{cmd:)} 
{cmd:SUBS(}{it:real}{cmd:)}
{cmd:MATPEL(}{it:string}{cmd:)} 
{cmd:MATIEL(}{it:string}{cmd:)} 
{cmd:STOM(}{it:int}{cmd:)} 
{cmd:THETA(}{it:real}{cmd:)}
{cmd:EPSILON(}{it:real}{cmd:)}
{cmd:TJOBS(}{it:string}{cmd:)} 
{cmd:ITk:  k:1...10:(}{it:Syntax }{cmd:)} 
{cmd:SN(}{it:string}{cmd:)} 
{cmd:IT(}{it:varname}{cmd:)} 
{cmd:PRC(}{it:varname}{cmd:)} 
{cmd:ELAS(}{it:varname}{cmd:)} 
{cmd:GVIMP(}{it:int}{cmd:)} 
]
 
{p}where {p_end}
{p 8 8} {cmd:varlist} The total per capita expenditures.{p_end}

{title:Description}
 {p}{cmd: Price Change(s) and WELl-being}  {p_end}
 {p}{cmd:prcwel} estimates the impact of price change(s) on well-being, poverty and inequality. {p_end}
 {title:Version} 11.0 and higher.
 {p} Users should set their surveys' sampling design before using this module 
 (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default. {p_end}
{p 8 8} {cmd: prcwel} module is belonging the package WELCOM. It is conceived to automate the estimation the results of the price change(s)impacts on well-being.  By default, the results are reported by quinitiles,  but the user can indicate any other partition of the population.  The following list shows the produces tables:{p_end}

{p 2 8}{cmd:List of tables:}{p_end}
{p 4 8}{inp:[01] Table 1.1: Information on used variables }{p_end}
{p 4 8}{inp:[02] Table 1.2: Population and expenditures}{p_end} 

{p 4 8}{inp:[03] Table 2.1: Total expenditures at population level (in currency) }{p_end}
{p 4 8}{inp:[04] Table 2.2: Average expenditures per household (in currency)}{p_end}
{p 4 8}{inp:[05] Table 2.3: Average expenditures per capita (in currency)}{p_end}

{p 4 8}{inp:[06] Table 3.1: Structure of expenditure on products (in %) s}{p_end}
{p 4 8}{inp:[07] Table 3.2: Expenditure shares (in %)}{p_end}
{p 4 8}{inp:[08] Table 3.3: Proportion of consumers with non-nil expenditures (in %)}{p_end}

{p 4 8}{inp:[09] Table 4.1: Total impact on well-being (at population level and in currency) }{p_end}
{p 4 8}{inp:[10] Table 4.2: Impact on the per capita well-being}{p_end}
{p 4 8}{inp:[11] Table 4.3: Impact on per capita well-being (in %) }{p_end}
{p 4 8}{inp:[12] Table 4.4: Impact on per capita well-being (consumers with non-nil expenditures)}{p_end}

{p 4 8}{inp:[13] Table 5.1: The market power and the poverty headcount}{p_end}
{p 4 8}{inp:[14] Table 5.2: The market power and the poverty gap}{p_end}
{p 4 8}{inp:[15] Table 5.3: The market power and the squared poverty gap}{p_end}

{p 4 8}{inp:[16] Table 6.1: The market power and the inequality: Gini index}{p_end}
{p 4 8}{inp:[17] Table 6.2: The market power and the inequality: Atkinson index}{p_end}
{p 4 8}{inp:[18] Table 6.3: The market power and the inequality: Entropy index}{p_end}
{p 4 8}{inp:[19] Table 6.4: The market power and the inequality: Ratio index}{p_end}


{title:Options}

{p 0 4} {cmdab:hsize}        Household size. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best 
> set in survey design). {p_end}

{p 0 4} {cmdab:hgroup}       Variable that captures the socio-demographic group to be used in the decomposition. For example, for an urban-rural decomposition of poverty, this variable could equal 1 for rural hou
> seholds and 2 for urban ones. The associated varlist should contain only one variable. The user also can indicate the number of partitions of the population (for instance, 10 for deciles) {p_end}

{p 0 4} {cmdab:pline}        To set the poverty line. {p_end}

{p 0 6} {cmd:nitems}   To indicate the number of items used in the simulation. For instance, if we plan to estimate the two independent market powers of gasoline and electricity  (we assume that we have the two v
> ariables of expenditures on these two items) the number of items is then two. {p_end}

{p 0 6} {cmd:it{cmd:k}: and k:1...10:}    To insert information on the item k by using the following syntax: {p_end}

{p 6 12}  {cmd:sn:}      To indicate the short label of the item. {p_end}
{p 6 12}  {cmd:it:}      To indicate the varname of the item. {p_end}
{p 6 12}  {cmd:prc:}     To indicate the varname of the proportional price change of the item. {p_end}
{p 6 12}  {cmd:elas:}    To indicate the varname of own price elasticity of the item. {p_end}

{p 0 6} {cmd:meas}   To indicate the method used to estimate the impact on well-being. By default, the Lasperyres measurement (first order taylor approximation) is used.  For the second order Taylor approximation, we can also indicate the own price elasticities.  When the option is set to 3 (meas(3)), the measurement is the of the equivalent variation. Choose number 4 for the compensated variation measurement. {p_end}

{p 0 6} {cmd:stom}   For the second order Taylor approximation, the user can indicate the disared measurement to be approximated. {p_end}

{p 6 12}  {cmd:stom(1)}      To approximate the CS measurement. {p_end}
{p 6 12}  {cmd:stom(2)}      To approximate the EV measurement. {p_end}
{p 6 12}  {cmd:stom(3)}      To approximate the CV measurement. {p_end}

{p 0 6} {cmd:matpel}   To indicate the name of squared matrix of price elasticities (optional for stom(1) and required for stom(2) or stom(3)) . {p_end}

{p 0 6} {cmd:matiel}   To indicate the name of row matrix of income elasticities (required for stom(2) or stom(3)) . {p_end}

{p 0 6} {cmd:model}   To indicate the model of consumer preferences. ( (1) Cobb-Douglas (2) CES ). {p_end}

{p 0 6} {cmd:subs}   To indicate the level of the constant elasticity of substition of the CES function. {p_end}

{p 0 6} {cmd:gvimp}   Indicate 1 to generate a new variable(s) that will contain the per capita impact on wellbeing. This option will not function with the qualifiers if/in. {p_end}

{p 0 6} {cmd:epsilon}   To indicate the parameter for the estimation of the Atkinson index of inequality. {p_end}

{p 0 6} {cmd:theta}   To indicate the parameter for the estimation of the generalised entropy index of inequality. {p_end}

{p 0 6} {cmd:xfil}   To indicate the name of Excel file, that will be used to save the results (*.xml format). {p_end}

{p 0 6} {cmd:inisave:}    To save the prcwel project information. Mainly, all inserted information in the dialogue box will be save in this file. In another session, the user can open the project using the command prcwel followed by the name of project. This command will initialize all of the information of the asubsim dialog box. {p_end}

{p 0 6} {cmd:tjobs:}    You may want to produce only a subset of tables. In such case, you have to select the desared tables by indicating their codes with the option tjobs. 
For instance: tjops(11 21) . See also: {bf:{help jtables_mc}}. {p_end}


{title:Example(s):}

{p 4 8}{inp: use http://dasp.ecn.ulaval.ca/welcom/examples/mc_example.dta , clear}{p_end}
{p 4 8}{inp: prcwel communication, hsize(hsize) pline(pline) gvimp(1) typemc(3)}{p_end}


{title:Examples}

{p 4 10 2}
NOTE: All the examples illustrated in the present and in the following sections
      can be run by clicking on the blue hyperlinks.
          
          
{title:Example 1: Estimating the impact using one item}
{cmd}
use http://dasp.ecn.ulaval.ca/welcom/examples/mc/Mexico_2014.dta , replace; 
gen prc_Cereals        =  0.08;
prcwel pc_income, hsize(hhsize) pline(pline) gvimp(1) 
inisave(mcwel_example_03) nitems(1)  
it1( sn(Cereals)       it(pcexp_cereal)  prc(prc_Cereals)  ) 
epsilon(.5)  
xfil(myexample1)  
;
{txt}      ({stata "welcom_examples ex_prc_01    ":example 1: click to run in command window})
{txt}      ({stata "welcom_examples ex_prc_db_01 ":example 1: click to run in dialog box})

{title:Example 2: Estimating the impact using three items}
{cmd}
#delimit ; 
use http://dasp.ecn.ulaval.ca/welcom/examples/mc/Mexico_2014.dta , replace; 
gen prc_Combustible    = -0.10;
gen prc_Communication  = -0.06;
gen prc_Cereals        =  0.08;
prcwel pc_income, hsize(hhsize) pline(pline) gvimp(1) 
inisave(mcwel_example_03) nitems(3)  
it1( sn(Combustible)   it(pcexp_comb)    prc(prc_Combustible)   ) 
it2( sn(Communication) it(pcexp_comu)    prc(prc_Communication)   ) 
it3( sn(Cereals)       it(pcexp_cereal)  prc(prc_Cereals)  ) 
epsilon(.5)  
xfil(myexample1)  
;
{txt}      ({stata "welcom_examples ex_prc_02    ":example 2: click to run in command window})
{txt}      ({stata "welcom_examples ex_prc_db_02 ":example 2: click to run in dialog box})



{title:Example 3: Estimating the impact using three items with the Taylor second order approximation of CS and using variables of price elasticities}
{cmd}
#delimit ; 
use http://dasp.ecn.ulaval.ca/welcom/examples/mc/Mexico_2014.dta , replace; 
gen prc_Combustible    = -0.10;
gen prc_Communication  = -0.06;
gen prc_Cereals        =  0.08;
prcwel pc_income, hsize(hhsize) pline(pline) gvimp(1) 
inisave(mcwel_example_03) nitems(3)  meas(2)
it1( sn(Combustible)   it(pcexp_comb)    prc(prc_Combustible)     elas(elas1) ) 
it2( sn(Communication) it(pcexp_comu)    prc(prc_Communication)   elas(elas2) ) 
it3( sn(Cereals)       it(pcexp_cereal)  prc(prc_Cereals)         elas(elas3) ) 
epsilon(.5)   xfil(myexample3)  
;
{txt}      ({stata "welcom_examples ex_prc_03    ":example 3: click to run in command window})
{txt}      ({stata "welcom_examples ex_prc_db_03 ":example 3: click to run in dialog box})


{title:Example 4: Estimating the impact using three items with the Taylor second order approximation of EV and using price and income matrices of elasticities}
{cmd}
#delimit ;
use http://dasp.ecn.ulaval.ca/welcom/examples/ds/Mexico_2014_Cereals_F.dta, replace;
preserve;
qui keep if wcorn!=.;
qui duvm corn wheat rice other, hhsize(hhsize) expend(hh_current_inc) hweight(sweight) cluster(psu) region(rururb) inisave(ex3_duvm_db) indcat(sex educ) indcon(age) csb(0) dregres(0) hgroup(decile);
restore;
matrix elas_price = e(elprice);
matrix elas_income= e(elincome);
gen pc_corn  = -0.1 ;
gen pc_wheat = 0.08 ;
gen pc_rice = -0.06 ;
gen pc_other = 0.05 ;
prcwel pc_income, hsize(hhsize) pline(pline) meas(2) sotm(2) inisave(example4) gvimp(0) nitems(4) matpel(elas_price) matiel(elas_income) it1( sn(Corn) it(pc_exp_corn) prc(pc_corn) ) it2( sn(Wheat) it(pc_exp_wheat) prc(pc_wheat) ) it3( sn(Rice) it(pc_exp_rice) prc(pc_rice) ) it4( sn(Other_Cereals) it(pc_exp_other) prc(pc_other) ) xfil(myexample4)   
;
{txt}      ({stata "welcom_examples ex_prc_04    ":example 4: click to run in command window})
{txt}      ({stata "welcom_examples ex_prc_db_04 ":example 4: click to run in dialog box})




{title:Author(s)}
Abdelkrim Araar, Carlos Rodriguez Castelan, Eduardo Alonso Malasquez Carbonel and Rogelio Granguillhome Ochoa

{title:Reference(s)}  


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}











