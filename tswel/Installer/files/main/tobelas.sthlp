{smcl}
{* June 2018}{...}
{hline}
{hi:TOBELAS : Tobacco Price Elasticity}
help for {hi:tobelas }{right:Dialog box:  {bf:{dialog tobelas}}}
{hline}
{title:Syntax} 
{p 8 10}{cmd:tobelas}  {it:varlist (2 varnames)}  {cmd:,} [ 
{cmd:DECILE(}{it:varname}{cmd:)}  
{cmd:INDCAT(}{it:varlist}{cmd:)} 
{cmd:INDCON(}{it:varlist}{cmd:)} 
{cmd:DREGRES(}{it:int}{cmd:)} 
{cmd:DGRA(}{it:int}{cmd:)} 
{cmd:DEC(}{it:int}{cmd:)} 
{cmd:ELASFILE(}{it:string}{cmd:)} 
]
 {p_end}
 {p} where  {p_end}
{p 8 8} {cmd:varlist (min=2 max=2)} The household' purchased quantity of ciguarettes and the household' price -or unit value- .{p_end}

{title:Description}
{p} The {cmd:tobelas} module is conceived to estimate the tobacco price elasicity by deciles.  
{p_end}
 
{title:Sampling design} 
 {p} Users should set their surveys' sampling design before using this module 
 (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default. {p_end}


{title:Version} 14.0 and higher.

{title:Options}


{p 0 4} {cmdab:decile}      Variable that captures the decile groups.  {p_end}

{p 0 4} {cmdab:indcat}      The list of the indepandent variables that are categorical.  {p_end}

{p 0 4} {cmdab:indcont}     The list of the indepandent variables that are continues.  {p_end}  

{it:twoway_options} are any of the options documented in 
{it:{help twoway_options}}.  These include options for titling the graph 
(see {it:{help title_options}}), options for saving the graph to disk (see 
{it:{help saving_option}}), and the {opt by()} option (see 
{it:{help by_option}}).

{p 6 12} {cmd:elasfile:}    To indicate  the path and the name of the Stata data file to save the elasticities by deciles. {p_end}
{p 6 12} {cmd:dec:}         To indicate number of decimals of the displayed results. {p_end}
{p 6 12} {cmd:dgra:}        Add the option dgra(1) to display graph of elasticities by deciles. {p_end}
{p 6 12} {cmd:dregres:}     Add the option dregres(1) to display full results of the estimations. {p_end}



{title:Example(s):}
tobelas quantity pricet, decile(decile) indcat(sex) indcon(lnx age) dec(4) dregres(0) dgra(0)
 
{title:Author(s)}
Abdelkrim Araar and Alan Fuchs Tarlovsky.  

{title:Reference(s)}  
Fuchs Tarlovsky,Alan & Meneses,Francisco Jalles, 2017. "Are tobacco taxes really regressive ? evidence from Chile,"
Policy Research Working Paper Series 7988, The World Bank.

{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}











