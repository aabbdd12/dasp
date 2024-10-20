{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:efgtc }{right:Dialog box:  {bf:{dialog efgtc}}}
{hline}

{title:Description}
{p 8 8} 
The module {cmd:efgtc} estimates FGT poverty elasticities with respect to total inequality as well as with respect to within/between income components of inequality.

{title:Syntax}

{p 8 10}{cmd:efgtc}  {it:varlist}  {cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)} {cmd:INC(}{it:varname}{cmd:)} {cmd:PLine(}{it:real}{cmd:)}  
{cmd:ALpha(}{it:real}{cmd:)} 
{cmd:PRC(}{it:real}{cmd:)} {cmd:INDex(}{it:string}{cmd:)} ]
 

{p}where {p_end}
{p 8 8} {cmd:varlist} The list of income components. {p_end}
{p 8 8} {cmd:TOT}     The total income. {p_end}

{title:Version} 15.0 and higher.

{title:Remark}
 {p} Users should set their surveys' sampling design before using this module 
 (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default.
{p_end}


{title:Options}

{p 0 4} {cmdab:hsize}        Household size. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:alpha}        To set the FGT parameter (alpha). By default, alpha=0.   {p_end}

{p 0 4} {cmdab:pline}        To set the poverty line. {p_end}

{p 0 4} {cmdab:appr}         By default, no income sources are included in the estimation. To use a truncated approach, choose the option appr(trn). See reference [1]. {p_end}

{p 0 4} {cmdab:prc}          Proportional change in total inequality (ex. prc=0.01). {p_end}

{p 0 4} {cmdab:dec}          To set the number of decimals used in the display of results. {p_end}

{title:Reference(s)}
{p 4 4 2} Araar Abdelkrim and Jean-Yves Duclos (2007). {browse "https://papers.ssrn.com/sol3/papers.cfm?abstract_id=1023643":Poverty and Inequality Components: a Micro Framework}, W.P. 35-07 CIRPEE, Universite Laval. {p_end}


{title:Examples}
sysuse Nigeria_2004I, replace
efgtc source1 source2 source3, tot(income) hsize(hhsize) alpha(0) pline(10000) prc(1)

{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos

{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}



