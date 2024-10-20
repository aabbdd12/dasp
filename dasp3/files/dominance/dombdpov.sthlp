{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:dombdpov }{right:Dialog box:  {bf:{dialog dombdpov}}}
{hline}

{title: Differences between bi-dimensional multiplicative FGT poverty indices (BD-FGT) with confidence intervals} 

{p 8 10}{cmd:dombdpov}  {it:varlist}  {cmd:,} [ 
{cmd:FILE1(}{it:string}{cmd:)}  
{cmd:FILE2(}{it:string}{cmd:)} 
{cmd:HSIZE1(}{it:string}{cmd:)}  
{cmd:HSIZE2(}{it:string}{cmd:)} 
{cmd:COND1(}{it:string}{cmd:)}  
{cmd:COND2(}{it:string}{cmd:)}  
{cmd:ALPHA1(}{it:real}{cmd:)}
{cmd:ALPHA2(}{it:real}{cmd:)}
{cmd:LEVEL(}{it:real}{cmd:)}
{cmd:CONF(}{it:string}{cmd:)}
{cmd:DIF(}{it:int}{cmd:)}
{cmd:LB(}{it:int}{cmd:)}
{cmd:UB(}{it:int}{cmd:)}
{cmd:MIN1(}{it:real}{cmd:)} 
{cmd:MAX1(}{it:real}{cmd:)} 
{cmd:PAR1(}{it:real}{cmd:)} 
{cmd:MIN2(}{it:real}{cmd:)} 
{cmd:MAX2(}{it:real}{cmd:)} 
{cmd:PAR2(}{it:real}{cmd:)} 
{cmd:LRES(}{it:int}{cmd:)} 
{cmd:SRES(}{it:string}{cmd:)} 
{cmd:SRESG(}{it:string}{cmd:)} 
{cmd:LAB1(}{it:real}{cmd:)}
{cmd:LAB2(}{it:real}{cmd:)}
{cmd:TITLE(}{it:real}{cmd:)}
{cmd:SGEMF(}{it:real}{cmd:)}

]



{p}where {p_end}

{p 8 8} {cmd:varlist} is a list of four variables of interest (two first two are the two variables of interest for the first distribution 
followed by the two variables of interest for the second distribution).  {p_end}

{title:Version} 15.0 and higher.

{title:Description}
 {p}{cmd:dombdpov}: To estimate the differences between bi-dimensional multiplicative FGT poverty (BD-FGT) surfaces with confidence interval.{p_end}

 
{title:Remarks:}
{p 4 7} 1- Users should set their surveys' sampling design before using this module  (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default. {p_end}
{p 4 7} 2- For each of the two distributions, users can use the data file currently in memory or a stored data file. {p_end}

{title:Options}


{p 0 4} {cmdab:file1}    By default, the file in memory is used for the first distribution. If a stored file is to be used for the first distribution, select it with this option. {p_end}

{p 0 4} {cmdab:file2}    By default, the file in memory is used for the second distribution. If a stored file is to be used for the second distribution, select it with this option. {p_end}

{p 0 4} {cmdab:hsize1}    Household size for the first distribution. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design).{p_end}

{p 0 4} {cmdab:hsize2}    Household size for the second distribution. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:cond1}    To set a logical expression that will capture a socio-demographic group for the first distribution (for example, zone==3). See the help for {help operator}. {p_end}

{p 0 4} {cmdab:cond2}    To set a logical expression that will capture a socio-demographic group for the second distribution (for example, zone==2 & education==5). See the help for {help operator}.{p_end}

{p 0 4} {cmdab:alpha1}    To set the BD-FGT parameter (alpha) for the first dimension. By default, alpha1=0.   {p_end}

{p 0 4} {cmdab:alpha2}    To set the BD-FGT parameter (alpha) for the second dimension. By default, alpha2=0.   {p_end}

{p 0 4} {cmdab:min1}      The minimum value of the range of the X-axis. {p_end}
 
{p 0 4} {cmdab:max1}      The maximum value of the range of the X-axis. {p_end}

{p 0 4} {cmdab:par1}      The number of partitions of the range of the X-axis (an integer). {p_end}

{p 0 4} {cmdab:min2}      The minimum value of the range of the Y-axis. {p_end}
 
{p 0 4} {cmdab:max2}      The maximum value of the range of the Y-axis. {p_end}

{p 0 4} {cmdab:par2}      The number of partitions of the range of the Y-axis (an integer). {p_end}
 
{p 0 4} {cmdab:lres}      If option "1" is selected, the coordinates of the surfaces are listed. {p_end}

{p 0 4} {cmdab:sres}    To save the coordinates of the curves in a Stata file, indicate the name of that file using this option. {p_end}

{p 0 4} {cmdab:sresg}    To save the coordinates of the curves in a GnuPlot-ASCII file, indicate the name of that file using this option. {p_end}

{p 0 4} {cmdab:level}   To set the confidence level of the confidence interval to be produced. {p_end}

{p 0 4} {cmdab:conf}     To set the type of confidence interval desired: "ts" for two-sided, "lb" for lower-bounded and "up" for upper-bounded.{p_end}

{p 0 4} {cmdab:dif}     By default its values is setted to 1. Select 0 if you do not like to plot the surface difference.{p_end}

{p 0 4} {cmdab:lb}    Select 1 if you like to plot the surface lower bound of the confidence interval.{p_end}

{p 0 4} {cmdab:ub}    Select 1 if you like to plot the surface upper bound of the confidence interval.{p_end}


{title:Examples}


sysuse bkf94I,  replace
save file_1994, replace
sysuse bkf98I,  replace
save file_1998, replace
dombdpov exppc gse exppcz gse, alpha1(0) alpha2(0) max1(100000) max2(4) file1(file_1994.dta) hsize1(size) title(romario 1) file2(file_1998.dta) hsize2(size)

{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}

