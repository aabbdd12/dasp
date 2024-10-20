
{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:cnpe }{right:Dialog box:  {bf:{dialog cnpe}}}
{hline}


{title:Nonparametric regressions and derivatives of nonparametric regression}

{p 8 12}{cmd:cnpe}  {it:varlist}{cmd:,} [ 
{cmd:XVAR(}{it:varname}{cmd:)} 
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:HGroup(}{it:varname}{cmd:)} 
{cmd:BAND(}{it:real}{cmd:)} 
{cmd:TYPE(}{it:string}{cmd:)} 
{cmd:APProach(}{it:string}{cmd:)} 
{cmd:MIN(}{it:real}{cmd:)} 
{cmd:MAX(}{it:real}{cmd:)} 
{cmd:RTYPE(}{it:string}{cmd:)}  
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
 
{p}where {cmd:varlist} is a list of variables. {p_end}

{title:Version} 15.0 and higher.

{title:Description}

 
 {p}{cmd:cnpe} produces nonparametric regression curves and derivatives for these curves, for a given list of variables and according to population subgroups:{p_end}

{title:Options}

{p 0 4} {cmdab:xvar} to indicate the X-axis variable (required option). {p_end}

{p 0 4} {cmdab:hsize}   Household size. {p_end}
  
{p 0 4} {cmdab:hgroup}   Variable which conditions the analysis on a socio-demographic group. For example, this variable could equal 1 for rural households and 2 for urban ones. When this option is used, the associated varlist should contain only one variable. {p_end}
 
{p 0 4} {cmdab:band}    To indicate the desired bandwidth (by default, an "optimal" bandwidth is used). {p_end}

{p 0 4} {cmdab:approach}   The Nadaraya-Watson estimator is used by default. One can also use a local linear approach by choosing the option "approach(lle)". {p_end}

{p 0 4} {cmdab:type}    Select the option "dnp" to draw the derivatives of the regression with respect to the variable of the x-axis. {p_end}

{p 0 4} {cmdab:min}    To indicate the minimum range of the X-axis. {p_end}
 
{p 0 4} {cmdab:max}    To indicate the maximum range of the X-axis. {p_end}

{p 0 4} {cmdab:rtype}    Select the option "prc" to draw curves according to percentiles of X variable. {p_end}

{p 0 4} {cmdab:dif}     If option "c1" is selected, the differences between the first and the othercurves are displayed.{p_end}
 
{p 0 4} {cmdab:lres}    If option "1" is selected, the (x,y) coordinates of the curves are listed. {p_end}

{p 0 4} {cmdab:sres}    To save the coordinates of the curves in a Stata file, indicate the name of that file using this option. {p_end}

{p 0 4} {cmdab:dgra}    If option "0" is selected, the graph is not displayed. By default, the graph is displayed. {p_end}

{p 0 4} {cmdab:sgra}    To save the graph in Stata format (*.gph), indicate the name of the graph file using this option. {p_end}

{p 0 4} {cmdab:egra}    To export the graph in an EPS or WMF format, indicate the name of the graph file using this option. {p_end}

{p 0 4} {cmdab:dci}      To draw the confidence interval of curves, selected the option "yes". {p_end}

{p 0 4} {cmdab:level}    To set the confidence level of the confidence interval to be produced. {p_end}

{p 0 4} {cmdab:conf}     To set the type of confidence interval desired: "ts" for two-sided, "lb" for lower-bounded and "up" for upper-bounded.{p_end}
 



{dlgtab:Y-Axis, X-Axis, Title, Caption, Legend, Overall, By}

{phang}
{it:twoway_options} are any of the options documented in 
{it:{help twoway_options}}.  These include options for titling the graph 
(see {it:{help title_options}}), options for saving the graph to disk (see 
{it:{help saving_option}}), and the {opt by()} option (see 
{it:{help by_option}}).

{title:Examples}
sysuse can6.dta, replace
cnpe T B1 B2 B3, xvar(X) min(0) max(30000) 
cnpe T B1 B2 B3, xvar(X) min(0) max(30000) dci(yes)

{p 4 8}{inp:. cnpe pccons, xvar(ytot)}{p_end}
{p 4 8}{inp:. cnpe pccons pcy, xvar(ytot) hsize(hhsize) }{p_end}

{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}



