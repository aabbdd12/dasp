{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:c_quantile}{right:Dialog box:  {bf:{dialog cdensity}}}
{hline}

{title:Density curves}

{p 8 12}{cmd:cdensity}  {it:varlist}{cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:HGroup(}{it:varname}{cmd:)} 
{cmd:BAND(}{it:real}{cmd:)}
{cmd:BCOR(}{it:string}{cmd:)}
{cmd:BORDER(}{it:int}{cmd:)}
{cmd:TYPE(}{it:string}{cmd:)} 
{cmd:MIN(}{it:real}{cmd:)} 
{cmd:MAX(}{it:real}{cmd:)} 
{cmd:DIF(}{it:string}{cmd:)} 
{cmd:LRES(}{it:int}{cmd:)} 
{cmd:SRES(}{it:string}{cmd:)} 
{cmd:DGRA(}{it:string}{cmd:)} 
{cmd:SGRA(}{it:string}{cmd:)} 
{cmd:EGRA(}{it:string}{cmd:)}]


 {syntab :Y-Axis, X-Axis, Title, Caption, Legend, Overall}
 {synopt :{it:{help twoway_options}}}any of the options documented in 
 {bind:{bf:[G]} {it:twoway_options}}{p_end}
{synoptline}
 
{p} where {cmd:varlist} is a list of variables. {p_end}

{title:Version} 15.0 and higher.

{title:Description}
 
 {p}{cmd:cdensity} produces the density or the derivative of the density for a given list of variables and according to population subgroups:{p_end}

{title:Options}
 
{p 0 4} {cmdab:hsize}   Household size. For example, if the population of interest is the population of individuals, one should weight household observations by household size.{p_end}
  
{p 0 4} {cmdab:hgroup}   Variable that conditions the analysis on a socio-demographic group. For example, this variable could equal 1 for rural households and 2 for urban ones. When this option is used, the associated varlist should contain only one variable. {p_end}

{p 0 4} {cmdab:type}    Select the option "dde" to draw the derivative of the density with respect to the variable on the x-axis. {p_end}

{p 0 4} {cmdab:bcor}    Select the option "renor" to perform the boundary-bias correction with the renormalization approach. Select the option reflecs for the reflection approach.{p_end}

{p 0 4} {cmdab:border}    To indicate the order of correction (between 1 and 3) for the boundary-bias correction with the renormalization approach. {p_end}
  
{p 0 4} {cmdab:band}    To indicate the desired bandwidth.  (By default, an "optimal" bandwidth is used (see for instance Silverman (1986)). {p_end}

{p 0 4} {cmdab:min}    The minimum value of the range of the X-axis. {p_end}
 
{p 0 4} {cmdab:max}    The maximum value of the range of the X-axis. {p_end}

{p 0 4} {cmdab:xval}   To estimate the density for a given value. {p_end}

{p 0 4} {cmdab:popb}   By default, the estimated density for a given value refers to the proportion of the group population with that level. Use the option popb(2) to estimate that proportion, but relative to the whole population. {p_end}
 
{p 0 4} {cmdab:lres}    If option "1" is selected, the coordinates of the curves are listed. {p_end}

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
sysuse bkf98I.dta, replace 
cdensity exppcz, hsize(size) hgroup(sex) popb(1) min(0) max(300000)



{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos

{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}
