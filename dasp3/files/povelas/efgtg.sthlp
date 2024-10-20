{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:efgtg }{right:Dialog box:  {bf:{dialog efgtg}}}
{hline}

{title:Description}
{p 8 8} 
The module {cmd:efgtg} estimates FGT elasticities with respect to total inequality as well as with respect to within/between group components of inequality.

{title:Syntax}

{p 8 10}{cmd:efgtg}  {it:varlist}  {cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)} {cmd:HGroup(}{it:varname}{cmd:)} {cmd:PLine(}{it:real}{cmd:)}  
{cmd:ALpha(}{it:real}{cmd:)} 
{cmd:PRC(}{it:real}{cmd:)} {cmd:INDex(}{it:string}{cmd:)} ]
 

{p}where {p_end}
{p 8 8} {cmd:varlist} Living standards (e.g., income or consumption). {p_end}


{title:Version} 15.0 and higher.

{title:Remark}
 {p} Users should set their surveys' sampling design before using this module 
 (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default.
{p_end}


{title:Options}

{p 0 4} {cmdab:hsize}        Household size. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:hgroup}       Variable that captures the socio-demographic group to be used in the decomposition. For example, for an urban-rural decomposition of poverty, this variable could equal 1 for rural households and 2 for urban ones. The associated varlist should contain only one variable. {p_end}

{p 0 4} {cmdab:alpha}         To set the FGT parameter (alpha). By default, alpha=0.   {p_end}

{p 0 4} {cmdab:pline}        To set the poverty line. {p_end}

{p 0 4} {cmdab:prc}          Proportional change in total inequality (ex. prc=0.01). {p_end}

{p 0 4} {cmdab:dec}          To set the number of decimals used in the display of results. {p_end}

{title:Reference(s)}

{p 4 4 2} Araar Abdelkrim and Jean-Yves Duclos (2007). {browse "https://papers.ssrn.com/sol3/papers.cfm?abstract_id=1023643":Poverty and Inequality Components: a Micro Framework}, W.P. 35-07 CIRPEE, Université Laval. {p_end}
{p 4 4 2} Kakwani, N. (1993) "Poverty and economic growth with application to Côte D’Ivoire", Review of Income and Wealth, 39(2): 121:139. {p_end}


{title:Examples}

sysuse Nigeria_2004I, replace
efgtg income, pline(10000) alpha(1) hgroup(education)

{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}



