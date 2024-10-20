{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:domineq }{right:Dialog box:  {bf:{dialog domineq}}}
{hline}

{title: Inequality dominance} 

{p 8 10}{cmd:domineq}  {it:varlist}  {cmd:,} [ 
{cmd:FILE1(}{it:string}{cmd:)}  
{cmd:FILE2(}{it:string}{cmd:)} 
{cmd:RANK1(}{it:varname}{cmd:)}  
{cmd:RANK2(}{it:varname}{cmd:)} 
{cmd:HSIZE1(}{it:string}{cmd:)}  
{cmd:HSIZE2(}{it:string}{cmd:)} 
{cmd:COND1(}{it:string}{cmd:)}  
{cmd:COND2(}{it:string}{cmd:)}  
{cmd:TYPE(}{it:string}{cmd:)}
{cmd:DEC(}{it:int}{cmd:)}
]

{p}where {p_end}

{p 8 8} {cmd:varlist} is a list of two variables (variables of interest for the first and the second distributions).  {p_end}

{title:Version} 15.0 and higher.

{title:Description}
 {p}{cmd:domineq}: can be used to: {p_end}
 
{p 4 8}{inp:. Test for inequality dominance using Lorenz curves;}{p_end}
{p 4 8}{inp:. Test for progressivity based on Lorenz and concentration curves.}{p_end}
 

{title:Remark(s)}
{p 4 6}{inp:1-  Users should set their surveys' sampling design before using this module 
 (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default. {p_end}
 {p 4 6}{inp:2- For each of the two distributions, users can use the data file currently in memory or a stored data file.} {p_end}

 {p 4 6}{inp:3- This module is based on Araar's (2006) theoretical developments.} {p_end}
{title:Options}


{p 0 4} {cmdab:file1}    By default, the file in memory is used for the first distribution. If a stored file is to be used for the first distribution, select it with this option. {p_end}

{p 0 4} {cmdab:file2}    By default, the file in memory is used for the second distribution. If a stored file is to be used for the second distribution, select it with this option. {p_end}

{p 0 4} {cmdab:hsize1}    Household size for the first distribution. For example, to compute inequality at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design).{p_end}

{p 0 4} {cmdab:hsize2}    Household size for the second distribution. For example, to compute inequality at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:rank1}    To set the ranking variable for the first distribution. {p_end}

{p 0 4} {cmdab:rank2}    To set the ranking variable for the second distribution.{p_end}

{p 0 4} {cmdab:cond1}    To set a logical expression that will capture a socio-demographic group for the first distribution (for example, zone==3). See the help for {help operator}. {p_end}

{p 0 4} {cmdab:cond2}    To set a logical expression that will capture a socio-demographic group for the second distribution (for example, zone==2 & education==5). See the help for {help operator}.{p_end}

{p 0 4} {cmdab:level}     To indicate the confidence level. {p_end}

{p 0 4} {cmdab:conf}      To set the type of confidence interval desired: "ts" for two-sided, "lb" for lower-bounded and "up" for upper-bounded.{p_end}

{p 0 4} {cmdab:dec}    To set the number of decimals used in the display of results. {p_end}


{title:Examples}

sysuse bkf94I,  replace
save file_1994, replace
sysuse bkf98I,  replace
save file_1998, replace
domineq exppc exppcz, file1(file_1994.dta) hsize1(size) file2(file_1998.dta) hsize2(size) type(nor)

{title:Reference(s)}
{p 4 4 2} Araar Abdelkrim (2006).{browse "https://papers.ssrn.com/sol3/papers.cfm?abstract_id=938555": Poverty, Inequality & Stochastic Dominance, the Theory and Practice: Illustration with Burkina Faso Surveys},  CIRPEE, WP:34-06, Laval University.{p_end}


{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}


