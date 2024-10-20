{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:gicur }{right:Dialog box:  {bf:{dialog gicur}}}
{hline}

{title: Growth incidence curve} 

{p 8 10}{cmd:gicur}  {it:varlist}  {cmd:,} [ 
{cmd:FILE1(}{it:string}{cmd:)}  
{cmd:FILE2(}{it:string}{cmd:)} 
{cmd:HSIZE1(}{it:string}{cmd:)}  
{cmd:HSIZE2(}{it:string}{cmd:)} 
{cmd:COND1(}{it:string}{cmd:)}  
{cmd:COND2(}{it:string}{cmd:)}  
{cmd:ALpha(}{it:real}{cmd:)}
{cmd:MIN(}{it:real}{cmd:)} 
{cmd:MAX(}{it:real}{cmd:)} 
{cmd:TYPE(}{it:string}{cmd:)} 
{cmd:LEVEL(}{it:real}{cmd:)}
{cmd:CONF(}{it:string}{cmd:)}
{cmd:LRES(}{it:int}{cmd:)} 
{cmd:SRES(}{it:string}{cmd:)} 
{cmd:DGRA(}{it:string}{cmd:)} 
{cmd:SGRA(}{it:string}{cmd:)} 
{cmd:EGRA(}{it:string}{cmd:)}
]

{syntab :Y-Axis, X-Axis, Title, Caption, Legend, Overall}
{synopt :{it:{help twoway_options}}}any of the options documented in 
{bind:{bf:[G]} {it:twoway_options}}{p_end}
{synoptline}

{p}where {p_end}

{p 8 8} {cmd:varlist} is a list of two variables of interest (variable of interest of the first distribution followed by that of the second distribution).  {p_end}

{title:Version} 15.0 and higher.

{title:Description}
 {p}{cmd:gicur}: To estimate growth incidence curve (see the detailed description below).{p_end}

{title:Remarks:}

{p 4 7}{inp:1- Users should set their surveys' sampling design before using this module  (and to save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned by default.} {p_end}
{p 4 7}{inp:2- For each of the two distributions, users can use the data file currently in memory or a stored data file.} {p_end}

{title:Options}


{p 0 4} {cmdab:file1}    By default, the file in memory is used for the first distribution. If a stored file is to be used for the first distribution, select it with this option. {p_end}

{p 0 4} {cmdab:file2}    By default, the file in memory is used for the second distribution. If a stored file is to be used for the second distribution, select it with this option. {p_end}

{p 0 4} {cmdab:hsize1}    Household size for the first distribution. For example, to compute poverty at the invididual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design).{p_end}

{p 0 4} {cmdab:hsize2}    Household size for the second distribution. For example, to compute poverty at the invididual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:cond1}    To set a logical expression that will capture a socio-demographic group for the first distribution (for example, zone==3). See the help for {help operator}. {p_end}

{p 0 4} {cmdab:cond2}    To set a logical expression that will capture a socio-demographic group for the second distribution (for example, zone==2 & education==5). See the help for {help operator}.{p_end}



{p 0 4} {cmdab:min}    To set the minimum value for the range of the horizontal (poverty line) axis. {p_end}
 
{p 0 4} {cmdab:max}    To set the maximum value for the range of the horizontal (poverty line) axis. {p_end}
 
{p 0 4} {cmdab:lres}    If option "1" is selected, the (x,y) coordinates of the curves are listed. {p_end}

{p 0 4} {cmdab:sres}    To save the coordinates of the curves in a Stata file, indicate the name of that file using this option. {p_end}

{p 0 4} {cmdab:dgra}    If option "0" is selected, the graph is not displayed. By default, the graph is displayed. {p_end}

{p 0 4} {cmdab:sgra}    To save the graph in Stata format (*.gph), indicate the name of the graph file using this option. {p_end}

{p 0 4} {cmdab:egra}    To export the graph in an EPS or WMF format, indicate the name of the graph file using this option. {p_end}

{p 0 4} {cmdab:level}   To set the confidence level of the confidence interval to be produced. {p_end}

{p 0 4} {cmdab:conf}     To set the type of confidence interval desired: "ts" for two sided, "lb" for lower-bounded and "up" for upper-bounded.{p_end}


{title:Detailed description:}

Let the following notation:

Q(p) : quantile at percentile p.

                                  
{title:[1] Growth incidence curve}    
     	                                              
 
	GIC(p)  =  ( Q_2(p) - Q_1(p) ) / Q_1(p) 
	                              
{title:Examples}

sysuse bkf94I, replace
save data94, replace
sysuse bkf98I, replace
save data98, replace
gicur exppc exppc, min(0) max(1) file1(data94) hsize1(size) file2(data98) hsize2(size)

{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}

