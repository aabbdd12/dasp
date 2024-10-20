{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:iprog }{right:Dialog box:  {bf:{dialog iprog}}}
{hline}

{title:Lorenz and concentration curves}

{p 8 12}{cmd:iprog}  {it:varlist}{cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:GOBS(}{it:varname}{cmd:)} 
{cmd:GINC(}{it:varname}{cmd:)} 
{cmd:TYPE(}{it:string}{cmd:)} 
]



{p}where {cmd:varlist} is a list of variables. {p_end}

{title:Version} 15.0 and higher.

{title:Description}
 
{p}{cmd:iprog} estimates the progressivity indices for a given list of variables (components).{p_end}
{p} Let X be gross income.{p_end}
{p 4 8}{inp:. The Kakwani index for tax T is: }{p_end}
{p 4 8}{inp:. KAK_T =  CONC_T - GINI_X  }{p_end}

{p 4 8}{inp:. The Kakwani index for transfer B is: }{p_end}
{p 4 8}{inp:. KAK_T =  GINI_X - CONC_B }{p_end}

{p 4 8}{inp:. The Reunold and Smolensky index for tax T is: }{p_end}
{p 4 8}{inp:. KAK_T =  GINI_X - CONC_X-T }{p_end}

{p 4 8}{inp:. The Reunold and Smolensky index for transfer B is: }{p_end}
{p 4 8}{inp:. KAK_T =   CONC_X+B -GINI_X }{p_end}


{title:Options}
 

{p 0 4} {cmdab:hsize}   Household size. For example, to compute inequality at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design).{p_end}
  
{p 0 4} {cmdab:gobs}   Grouping variable of observations. The observations can be divided by years or by population groups. {p_end}
 
{p 0 4} {cmdab:ginc}    Required to set the ranking variable, which is usually gross income, denoted by X above. {p_end}
 
{p 0 4} {cmdab:type}    By default is Tax. Select option "b" for transfer components. {p_end}

{p 0 4} {cmdab:index}     By default is the Kakwani index. Select option "rs" for Reynold and Smolensky index. {p_end}

{p 0 4} {cmdab:level}   To set the confidence level of the confidence interval to be produced. {p_end}

{p 0 4} {cmdab:conf}     To set the type of confidence interval desired: "ts" for two-sided, "lb" for lower-bounded and "up" for upper-bounded.{p_end}

{p 0 4} {cmdab:dec}    To set the number of decimals used in the display of results. {p_end}


{title:Examples}
 
sysuse can6, replace
iprog T, ginc(X) type(t) index(ka)


{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}

