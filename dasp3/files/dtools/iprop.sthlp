{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:iprop }{right:Dialog box:  {bf:{dialog iprop}}}
{hline}

{title: Proportion index} 

{p 8 10}{cmd:iprop}  {it:varname}  {cmd:,} 
[   
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:LEVEL(}{it:real}{cmd:)}
{cmd:CONF(}{it:string}{cmd:)} 
{cmd:DEC(}{it:int}{cmd:)} 
]
 

{p}where {p_end}
{p 8 8} {cmd:varname} is the group variable. This variable captures a socio-demographic group. For example, this variable could equal 1 for rural households and 2 for urban ones. When this option is used, the associated varlist should contain only one variable. {p_end}



{title:Version} 15.0 and higher.

Users should set their surveys' sampling design before using this module 
(and then save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default. {cmd:iprop} estimates the following inequality indices and their standard errors {p_end}
{p 4 8}{inp:. Coefficient of variation index}{p_end}


{title:Description} 
{p}{cmd:Distribution:} To estimate the proportion or share of population groups.

{title:Options}

{p 0 4} {cmdab:hsize}   Household size. For example, to compute inequality at an individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}
 
{p 0 4} {cmdab:level}   To set the confidence level of the confidence interval to be produced. {p_end}

{p 0 4} {cmdab:conf}     To set the type of confidence interval desired: "ts" for two-sided, "lb" for lower-bounded and "up" for upper-bounded.{p_end}

{p 0 4} {cmdab:dec}    To set the number of decimals used in the display of results. {p_end}

{title:Examples}
sysuse bkf98I, replace 
iprop gse, hsize(size) 



{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}