{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:imoda }{right:Dialog box:  {bf:{dialog imoda}}}
{hline}

{title:Multiple Overlapping Deprivation Analysis} 

{p 8 10}{cmd:imoda}  {it:varlist}  {cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:HGroup(}{it:varname}{cmd:)} 
{cmd:pl1(}{it:real}{cmd:)}-{cmd:pl3(}{it:real}{cmd:)}
{cmd:sn1(}{it:real}{cmd:)}-{cmd:sn3(}{it:real}{cmd:)}
{cmd:LEVEL(}{it:real}{cmd:)}
{cmd:CONF(}{it:string}{cmd:)} 
{cmd:DETAIL(}{it:int}{cmd:)}
]
 

{p}where {p_end}
{p 8 8} {cmd:varlist} is a list of three dimensional variables. {p_end}


{title:Version} 15.0 and higher.

{title:Description}
 {p}{cmd:Multiple Overlapping Deprivation Analysis}  Users should set their surveys' sampling design before using this module 
 (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default. 



{title:Options} 

{p 0 4} {cmdab:hsize}    Household size. For example, to compute poverty at the individual level, one will want to weight household-level observations 
by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:hgroup}   Variable that captures a socio-demographic group. For example, this variable could equal 1 for rural households and 2 
for urban ones. When this option is used, the associated varlist should contain only one variable. {p_end}

{p 0 4} {cmdab:pl"j"}     Poverty line for attribute j (j is between 1 and 3). {p_end}

{p 0 4} {cmdab:sn"j"}     The short name for attribute j (j is between 1 and 3). {p_end}

{p 0 4} {cmdab:level}    To set the confidence level of the confidence interval to be produced. {p_end}

{p 0 4} {cmdab:conf}     To set the type of confidence interval desired: "ts" for two-sided, "lb" for lower-bounded and "up" for upper-bounded.{p_end}

{p 0 4} {cmdab:dec}      To set the number of decimals used in the display of results. {p_end}

{p 0 4} {cmdab:detail}      Add the option detail(1) to display more detailed results. {p_end}

{title:Detailed description:}
{p 0 4}    -   The imoda module produces a series of multidimensional poverty indices in order to show the incidence of deprivation in each dimension. Further, this application 
estimates the incidence of multi-deprivation in different combinations of dimensions.
In this application, the number of dimensions is set to three. Further, multidimensional
poverty is measured by the headcount (union and intersection headcount indices) and the Alkire and Foster 
M0 index for different levels of the dimensional cut-off.
{p_end}

{title:Example:}
sysuse imdi_data, replace
imoda nsc_hab nsc_etu nsc_san, hsize(size) pl1(1) pl2(1) pl3(1) sn1(Housing) sn2(Education) sn3(Health)

{title:Authors}

Abdelkrim Araar
Jean-Yves Duclos

        



{title:Contact}

If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}	                          
