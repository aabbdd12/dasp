{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:cprogbt }{right:Dialog box:  {bf:{dialog cprogtb}}}
{hline}

{title:Lorenz and concentration curves}

{p 8 12}{cmd:cprogbt}  {it:varlist}[min=2, max=2]{cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:HGroup(}{it:varname}{cmd:)} 
{cmd:RANK(}{it:varname}{cmd:)} 
{cmd:TYPE(}{it:string}{cmd:)} 
{cmd:MIN(}{it:real}{cmd:)} 
{cmd:MAX(}{it:real}{cmd:)} 
{cmd:APPR(}{it:string}{cmd:)} 
{cmd:LRES(}{it:int}{cmd:)} 
{cmd:SRES(}{it:string}{cmd:)} 
{cmd:DGRA(}{it:string}{cmd:)} 
{cmd:SGRA(}{it:string}{cmd:)} 
{cmd:EGRA(}{it:string}{cmd:)}]

{syntab :Y-Axis, X-Axis, Title, Caption, Legend, Overall}
{synopt :{it:{help twoway_options}}}any of the options documented in 
{bind:{bf:[G]} {it:twoway_options}}{p_end}
{synoptline}

{p}where {cmd:varlist} is a list of transfer (B) and tax (T) variables respectively. {p_end}

{title:Version} 15.0 and higher.

{title:Description}
 
{p}{cmd:cprogbt} produces progressivity curves to check if a tranfer B is more progressive that a tax T.(components).{p_end}
{p}Let X be a gross income.{p_end}
{p 4 8}{inp:. A transfer B is more Tax-Redistribution (TR) progressive than a tax T if: }{p_end}
{p 4 8}{inp:. PR(p) =  C_B(p) + C_T(p)- 2L_X(p) > 0 for all p in ]0, 1[ }{p_end}



{p 4 8}{inp:. A transfer B is more Income-Redistribution (IR) progressive than a tax T if: }{p_end}
{p 4 8}{inp:. PR(p) = C_X+B(p) - C_X-T(p) > 0 for all p in ]0, 1[ }{p_end}





{title:Options}
 
{p 0 4} {cmdab:hweight} The sampling weight variable . {p_end}

{p 0 4} {cmdab:hsize}   Household size. For example, to compute inequality at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design).{p_end}
  
{p 0 4} {cmdab:hgroup}   Variable that captures a socio-demographic group. For example, this variable could equal 1 for rural households and 2 for urban ones. When this option is used, the associated varlist should contain only one variable. If the values of Variable {it:hgroup} are labelled, the graphs that will be produced will automatically show these labels. {p_end}
 
{p 0 4} {cmdab:rank}    Required to set the ranking variable, which is the gross income denoted by x above. {p_end}
 

{p 0 4} {cmdab:min}    To set the minimum value for the range of the horizontal (poverty line) axis. {p_end}
 
{p 0 4} {cmdab:max}    To set the maximum value for the range of the horizontal (poverty line) axis. {p_end}

{p 0 4} {cmdab:appr}     By default is TR. Select option "IR" for Income Redistrbution approach. {p_end}

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
sysuse can6,replace 
cprogbt B1 T, rank(X)



{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}

