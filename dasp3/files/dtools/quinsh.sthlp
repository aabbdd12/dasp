{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:quinsh }
{hline}

{title: Income share and cumulative income share by quantile groups} 

{p 8 10}{cmd:quinsh}  {it:varname}  {cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)}
{cmd:PARtition(}{it:int}{cmd:)}
{cmd:TYPE(}{it:string}{cmd:)}
{cmd:VNAME(}{it:string}{cmd:)}
{cmd:DEC(}{it:string}{cmd:)}
{cmd:DGRaph(}{it:string}{cmd:)}]
 


{title:Version} 15.0 and higher.

{title:Description}
{cmd:quinsh}  estimates the income share and cumulative income share by percentile group partitions. For instance, if the indicated group partition is 5, income shares are provided by quintiles}  

{p}Users should set their surveys' sampling design before using this module (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default. 
{p_end}

{title:Options}

{p 0 4} {cmdab:hsize}        Household size. For example, to compute individual-based income shares, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:partition}       Indicate the number of group partitions. For instance, 5 for quintiles, 10 for deciles, etc. {p_end}

{p 0 4} {cmdab:type}       Select the option type(cum) to estimate cumulative income shares. {p_end}

{p 0 4} {cmdab:type}       Indicate the name of the variable that contains the group indicator to be generated. {p_end}

{p 0 4} {cmdab:dec}          To set the number of decimals used in the display of results. {p_end}

{p 0 4} {cmdab:dgraph}          Indicate 1 if you would like to plot a graph bar of income shares. {p_end}


{title:Examples}
sysuse bkf98I, replace
quinsh exppcz, hsize(size) partition(10) dgraph(1)


{title:Authors}
Abdelkrim Araar
Duclos Jean-Yves

{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}



