{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:dpolas }{right:Dialog box:  {bf:{dialog dpolas}}}
{hline}

{title:Decomposition of the Duclos, Esteban and Ray polarization index by income sources} 

{p 8 10}{cmd:dpolas}  {it:varlist}  {cmd:,} 
[   
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:HGroup(}{it:varname}{cmd:)} 
{cmd:ALpha(}{it:real}{cmd:)}
{cmd:FAST(}{it:int}{cmd:)}
{cmd:DEC(}{it:int}{cmd:)} 
]
 

{p}where {p_end}
{p 8 8} {cmd:varlist} is a list of variables (income components or income sources). {p_end}

{title:Version} 15.0 and higher.

{title:Description}
{p} This module can be used to perform a decomposition of the DER polarization index (see reference 3) by income sources. {p_end} 
{p} Users should set their surveys' sampling design before using this module (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned by default. {p_end}


{title:Options}

{p 0 4} {cmdab:hsize}   Household size. For example, to compute polarization at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:hgroup}   Variable that identifies the socio-demographic groups. For example, this variable could equal 1 for rural households and 2 for urban ones. When this option is used, the associated varlist should contain only one variable. {p_end}

{p 0 4} {cmdab:alpha}   The parameter alpha (see references). {p_end}

{p 0 4} {cmdab:fast}    Option for computing the kernel density function. If "1" is chosen, CF-Kernel is used (see Ref_2) . {p_end}

{p 0 4} {cmdab:dec}    To set the number of decimals used in the display of results. {p_end}


{title:References}  

{p 4 4 2} 1_ Araar Abdelkrim (2008) {browse "http://www.ecineq.org/ecineq_ba/papers/Araar.pdf":On the Decomposition of Polarization Indices: Illustrations with Chinese and Nigerian Household Surveys.}, CIRPEE W.P. 08-06 {p_end}

{p 4 4 2} 2_ Duclos, Esteban and Ray (2003)  {browse "http://dad.ecn.ulaval.ca/features/files/DuclosEstebanRay-sept03.pdf":Polarization Concepts, Measurement, Estimation.}, CIRPEE W.P. 01-03{p_end}


{title:Examples}
sysuse Nigeria_2004I, replace
dfgts source1-source6, , hsize(hhsize) fast(1)



{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}