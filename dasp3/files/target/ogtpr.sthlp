{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:ogtpr }{right:Dialog box:  {bf:{dialog ogtpr}}}
{hline}

{title: Optimal Targeting Groups for Poverty Reduction} 

{p 8 10}{cmd:ogtpr}  {it:varlist}  {cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)} {cmd:HGroup(}{it:varname}{cmd:)} {cmd:PLine(}{it:real}{cmd:)}  {cmd:TRANS(}{it:real}{cmd:)  {cmd:PART(}{it:int}{cmd:)  {cmd:ERED(}{it:int}{cmd:)} 
{cmd:ALpha(}{it:real}{cmd:)} ]
 

{p}where {p_end}
{p 8 8} {cmd:varlist} is the variable of wellbeing (income). {p_end}


{title:Version} 15.0 and higher.

{title:Description}
 {p}{cmd:Poverty: Optimal Targeting by Population Groups}  {p_end}
 {p} Users should set their surveys' sampling design before using this module 
 (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default. {cmd:oogtpr} estimates the group-lumpsum transfers  to reduce optimally  the aggregate poverty for a given predefined budget of transfers.
{p_end}


{title:Options}

{p 0 4} {cmdab:hsize}        Household size. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:hgroup}       Variable that captures the socio-demographic group to be used in the decomposition. For example, for an urban-rural decomposition of poverty, this variable could equal 1 for rural households and 2 for urban ones. The associated varlist should contain only one variable. {p_end}

{p 0 4} {cmdab:alpha}        To set the FGT parameter (alpha). By default, alpha=0.   {p_end}

{p 0 4} {cmdab:pline}        To set the poverty line. {p_end}

{p 0 4} {cmdab:trans}        To set the fixed per capita lump sum transfer. {p_end}

{p 0 4} {cmdab:ered}         Set the value to one ( ered(1) ) to estimate the reduction in aggregate poverty and the quality of the group indicator. {p_end}

{p 0 4} {cmdab:dec}          To set the number of decimals used in the display of results. {p_end}



{title:Examples}
sysuse bkf98I.dta, replace
ogtpr exppc, hgroup(gse) hsize(size) alpha(0) pline(80000) trans(4000) part(1000) ered(1)




{title:Author(s)}
Abdelkrim Araar

{title:Reference(s)}  
{p 4 4 2} 1 - Araar Abdelkrim  and Luca Tiberti (2020)	{browse	"https://www.dasp.cstip.ulaval.ca/dasp3/refs/Optimal_Targeting_and_Poverty_Reduction_april2020.pdf": Optimal Population Group Targeting and Poverty Reduction},	mimeo {p_end}


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}



