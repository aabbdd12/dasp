{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:dfgtgr}{right:Dialog box:  {bf:{dialog dfgtgr}}}
{hline}

{title: Decomposition of the variation in the FGT index into growth and redistribution components} 

{p 8 10}{cmd:difgt}  {it:varlist}  {cmd:,} [ 
{cmd:FILE1(}{it:string}{cmd:)}  
{cmd:FILE2(}{it:string}{cmd:)} 
{cmd:HSIZE1(}{it:string}{cmd:)}  
{cmd:HSIZE2(}{it:string}{cmd:)} 
{cmd:COND1(}{it:string}{cmd:)}  
{cmd:COND2(}{it:string}{cmd:)}  
{cmd:ALpha(}{it:real}{cmd:)}
{cmd:PLINE(}{it:real}{cmd:)} 
{cmd:LEVEL(}{it:real}{cmd:)}
{cmd:CONF(}{it:string}{cmd:)}
{cmd:DEC(}{it:int}{cmd:)}
]

{p}where {p_end}

{p 8 8} {cmd:varlist} is a list of two variables of interest (variable of interest of the first distribution followed by that of the second distribution).  {p_end}

{title:Version} 15.0 and higher.

{title:Description}
 {p}{cmd:cpropoorp}: To decompose the variation in the FGT index between two periods into growth and redistrbution components. The methods used are based on: (see the detailed description below).{p_end}

{p 4 6}{inp:1- Datt and Ravallion (1991).} {p_end}
{p 4 6}{inp:2- the Shapley value.} {p_end}

See the help file for more details. 

 
{title:Remarks:}
{p 4 6}{inp:1- Users should set their surveys' sampling design before using this module 
 (and then save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default. {p_end}
 {p 4 6}{inp:2- For each of the two distributions, users can use the data file currently in memory or a stored data file.} {p_end}

{title:Options}


{p 0 4} {cmdab:file1}    By default, the file in memory is used for the first distribution. If a stored file is to be used for the first distribution, select it with this option. {p_end}

{p 0 4} {cmdab:file2}    By default, the file in memory is used for the second distribution. If a stored file is to be used for the second distribution, select it with this option. {p_end}

{p 0 4} {cmdab:hsize1}    Household size for the first distribution. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design).{p_end}

{p 0 4} {cmdab:hsize2}    Household size for the second distribution. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:cond1}    To set a logical expression that will capture a socio-demographic group for the first distribution (for example, zone==3). See the help for {help operator}. {p_end}

{p 0 4} {cmdab:cond2}    To set a logical expression that will capture a socio-demographic group for the second distribution (for example, zone==2 & education==5). See the help for {help operator}.{p_end}

{p 0 4} {cmdab:alpha}    To set the FGT parameter value (alpha). By default, alpha=0.   {p_end}

{p 0 4} {cmdab:pline}    To set the poverty line. {p_end}

{p 0 4} {cmdab:level}     To set the confidence level of the confidence interval to be produced.{p_end}

{p 0 4} {cmdab:conf}     To set the type of confidence interval desired: "ts" for two-sided, "lb" for lower-bounded and "up" for upper-bounded.{p_end}

{p 0 4} {cmdab:dec}      To set the number of decimals used in the display of results. {p_end}


{title:Examples}
sysuse bkf94I, replace
save   data94, replace
sysuse bkf98I, replace
save   data98, replace
dfgtgr exppc exppc,  pline(80000) file1(data94) hsize1(size)  file2(data98) hsize2(size) alpha(1)

{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}
