{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:cdf }{right:Dialog box:  {bf:{dialog cdf}}}
{hline}

{title:Cumulative Distribution Function curves}

{p 8 12}{cmd:cdf}  {it:varlist}{cmd:,} [  {cmd:HSize(}{it:varname}{cmd:)} 
{cmd:HGroup(}{it:varname}{cmd:)} {cmd:TYPE(}{it:string}{cmd:)} {cmd:ALpha(}{it:real}{cmd:)} {cmd:MIN(}{it:real}{cmd:)} 
{cmd:MAX(}{it:real}{cmd:)}  {cmd:LRES(}{it:int}{cmd:)} {cmd:SRES(}{it:string}{cmd:)} 
{cmd:DGRA(}{it:string}{cmd:)} {cmd:SGRA(}{it:string}{cmd:)} {cmd:EGRA(}{it:string}{cmd:)}]

{syntab :Y-Axis, X-Axis, Title, Caption, Legend, Overall}
{synopt :{it:{help twoway_options}}}any of the options documented in 
{bind:{bf:[G]} {it:twoway_options}}{p_end}
{synoptline}
 
{p}where {cmd:varlist} is a list of variables. {p_end}

{title:Version} 15.0 and higher.

{title:Description}
 
 {p}{cmd:cdf} Cumulative Distribution Function curves:{p_end}
 

 

{title:Notes:}

{p 0 4} {cmdab:hweight} Users should set their surveys' sampling design {help svyset} before using this module 
 (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default. {p_end}
 
 
{title:Options:} 

{p 0 4} {cmdab:hsize}   Household size. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}
  
{p 0 4} {cmdab:hgroup}   Variable that captures a socio-demographic group. For example, this variable could equal 1 for rural households and 2 for urban ones. When this option is used, the associated varlist should contain only one variable. If the values of Variable {it:hgroup} are labelled, the graphs that will be produced will automatically show these labels.  {p_end}
  
{p 0 4} {cmdab:min}    To set the minimum value for the range of the horizontal (poverty line) axis. {p_end}
 
{p 0 4} {cmdab:max}    To set the maximum value for the range of the horizontal (poverty line) axis. {p_end}
 
{p 0 4} {cmdab:dif}     If option "c1" is selected, the differences between the first and the othercurves are displayed.{p_end}
 
{p 0 4} {cmdab:lres}    If option "1" is selected, the (x,y) coordinates of the curves are listed. {p_end}

{p 0 4} {cmdab:sres}    To save the coordinates of the curves in a Stata file, indicate the name of that file using this option. {p_end}

{p 0 4} {cmdab:dgra}    If option "0" is selected, the graph is not displayed. By default, the graph is displayed. {p_end}

{p 0 4} {cmdab:sgra}    To save the graph in Stata format (*.gph), indicate the name of the graph file using this option. {p_end}

{p 0 4} {cmdab:egra}    To export the graph in an EPS or WMF format, indicate the name of the graph file using this option. {p_end}


{dlgtab:Y-Axis, X-Axis, Title, Caption, Legend, Overall, By}

{phang}
{it:twoway_options} are any of the options documented in 
{it:{help twoway_options}}.  These include options for titling the graph 
(see {it:{help title_options}}), options for saving the graph to disk (see 
{it:{help saving_option}}), and the {opt by()} option (see 
{it:{help by_option}}).

{title:Examples}
sysuse bkf98I, replace 
cdf exppcz, hsize(size) hgroup(sex) min(0) max(40000) lres(1)


{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}
