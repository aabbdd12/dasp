{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:ipola }{right:Dialog box:  {bf:{dialog ipola}}}
{hline}
{title: Inequality Indices} 
{p 8 10}{cmd:ipola}  {it:varlist}  {cmd:,}
[ 
{cmd:ALpha(}{it:real}{cmd:)}  
{cmd:FAST(}{it:int}{cmd:)} 
{cmd:BAND(}{it:real}{cmd:)} 
{cmd:NG(}{it:int}{cmd:)} 
{cmd:Beta(}{it:real}{cmd:)}  
{cmd:NITR(}{it:int}{cmd:)}  
{cmd:PRCS(}{it:real}{cmd:)}   
{cmd:GNumber(}{it:inr}{cmd:)} 
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:HGroup(}{it:varname}{cmd:)} 
{cmd:LEVEL(}{it:real}{cmd:)}
{cmd:CONF(}{it:string}{cmd:)} 
{cmd:DEC(}{it:int}{cmd:)} 
{cmd:TYPE(}{it:string}{cmd:)} 
{cmd:INISAVE(}{it:string}{cmd:)} 
]
 

{p}where {p_end}
{p 8 8} {cmd:varlist} is a list of variables. {p_end}


{title:Version} 10 and higher.

{title:Description}
 {p}{cmd:Inequality indices}  Users should set their surveys' sampling design before using this module 
 (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default. With {cmd:ipola}, the following polarization indices and their standard errors  will be estimated: {p_end}

{p 4 8}{inp:- Duclos Esteban and Ray index of polarization (2004).}{p_end}
{p 4 8}{inp:- Foster and Wolfson (1992).}{p_end}
{p 4 8}{inp:- Esteban, Gradin and Ray (1999).}{p_end}
{p 4 8}{inp:- INaki Permanyer (2008).}{p_end}
  
{title:Common options:}

{p 0 4} {cmdab:hsize}   Household size. For example, to compute polarization at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:hgroup}  Variable that captures a socio-demographic group. For example, this variable could equal 1 for rural households and 2 for urban ones. When this option is used, the associated varlist should contain only one variable. {p_end}

{p 0 4} {cmdab:level}   To set the confidence level of the confidence interval to be produced. {p_end}

{p 0 4} {cmdab:conf}     To set the type of confidence interval desired: "ts" for two-sided, "lb" for lower-bounded and "up" for upper-bounded.{p_end}

{p 0 4} {cmdab:dec}    To set the number of decimals used in the display of results. {p_end}


{p 0 4} {cmdab:index}  To indicate the desired polarization index: {p_end}

{p 3 4}  {cmdab:der:}  Duclos Esteban and Ray index of polarization (2004).}{p_end}
{p 3 4}  {cmdab:fw:}  Foster and Wolfson (1992).}{p_end}
{p 3 4}  {cmdab:egr:}  Esteban, Gradin and Ray (1999).}{p_end}
{p 3 4}  {cmdab:in:}  INaki Permanyer (2008).}{p_end}

{p 0 4} {cmdab:inisave} To save the easi dialog box information. Mainly, all inserted information in the dialog box will be save in this file. In another session, the user can open the project using the command dasp_db_ini followed  by the name of project. {p_end}

{title:Specific options of indices:}
{p 0 4} {cmdab:Duclos Esteban and Ray index of polarization (2004)} {p_end}
{p 2 4} {cmdab:alpha}   The parameter alpha (see the main reference). {p_end}
{p 2 4} {cmdab:fast}    Option for computing the kernel density function. If "1" is chosen, CF-Kernel is used (see Ref_2) . {p_end}
{p 2 4} {cmdab:band}    To indicate the desired bandwidth.  (By default, an "optimal" bandwidth is used (see for instance Silverman (1986)). {p_end}


{p 0 4} {cmdab:Esteban, Gradin and Ray (1999)} {p_end}
{p 2 4} {cmdab:alpha}   The parameter alpha (default value 1). {p_end}
{p 2 4} {cmdab:beta}   The parameter beta (default value 1). {p_end}
{p 2 4} {cmdab:ng}   Number of groups for the partition. by default it is equal to 4. {p_end}
{p 2 4} {cmdab:nitr}   Maximum number of iterations for convergence to the optimal partitioning of groups. by default it is equal to 16. {p_end}
{p 2 4} {cmdab:prcs}   Level of precision for convergence to the optimal partition of groups. By default it is equal to 0.000001. {p_end}


{p 0 4} {cmdab:INaki Permanyer (2008)} {p_end}

{p 2 4} {cmdab:alpha}   The parameter alpha (see the main reference). {p_end}
{p 2 4} {cmdab:fast}    Option for computing the kernel density function. If "1" is chosen, CF-Kernel is used (see Ref_2) . {p_end}
{p 2 4} {cmdab:band}    To indicate the desired bandwidth.  (By default, an "optimal" bandwidth is used (see for instance Silverman (1986)). {p_end}



 

{p 4 10 2}
NOTE: All the examples illustrated in the present and in the following sections
      can be run by clicking on the blue hyperlinks.


{p 0 4}   {cmd:Example 1:}  Estimating the Duclos Esteban and Ray index of polarization across the zones. {p_end}

sysuse bkf98I, replace
ipola exppc, hsize(size) hgroup(gse) index(der) inisave(myexample)

{txt}      ({stata "dasp_examples ex_ipola_01"    :example 1: click to run in command window})
{txt}      ({stata "dasp_examples ex_ipola_db_01 ":example 1: click to run in dialog box})



{p 0 4}  {cmd :Example 2:}  Estimating the Foster and Wolfson indices across the socio-professional group.  {p_end}

sysuse bkf98I, replace
ipola exppc, hsize(size) hgroup(gse) index(fw) inisave(myexample)

{txt}      ({stata "dasp_examples ex_ipola_02"    :example 2: click to run in command window})
{txt}      ({stata "dasp_examples ex_ipola_db_02 ":example 2: click to run in dialog box})


{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:References}  

{p 4 4 2} 1_ Duclos, Esteban and Ray (2003)  {browse "http://dad.ecn.ulaval.ca/features/files/DuclosEstebanRay-sept03.pdf":polarization Concepts, Measurement, Estimation.}, CIRPE W.P. 01-03{p_end}
{p 4 4 2} 2_ Tian Z. & all (1999)  "Fast Density Estimation Using CF-kernel for Very Large Databases". {browse "http://portal.acm.org/citation.cfm?id=312266"}{p_end}
{p 4 4 2} 3_ Iñaki Permanyer (2008)   {browse "http://ideas.repec.org/p/aub/autbar/736.08.html":The Measurement of Social Polarization in a Multi-group Context}, UFAE and IAE Working Papers 736.08, Unitat de Fonaments de l'Anàlisi Econòmica (UAB and Institut d'Anàlisi Econòmica (CSIC). {p_end}



{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}
