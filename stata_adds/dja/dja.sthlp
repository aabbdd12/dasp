{smcl}
{* February 2006}{...}
{hline}
{hi:DASP : Distributive Analysis Stata Package}{right:({hi:Araar Abdelkrim}, 2006, CIRPEE: Laval University)}
help for {hi:dja (version 1.0) }
{hline}

{title:Redistributive Effect of Inequality (RE):} 

{p 8 10}{cmd:dja}  {it:varlist}  {cmd:,} [ {cmd:HWeight(}{it:varname}{cmd:)} {cmd:HSize(}{it:varname}{cmd:)}  {cmd:RHO(}{it:real}{cmd:)}  {cmd:EPS(}{it:real}{cmd:)} ]
 

{p}where {p_end}
{p 8 8} {cmd:varlist} is a list of two variables that are the gross and net income variables. {p_end}


{title:Description}

{p}{cmd:Decomposition:} to perform the decomposition of RE to vertical and horizontal and reranking inequalities.{p_end}

{title:Options}

{p 0 4} {cmdab:hsize}   Household size. For example, if the variable of interest is income per capita, one should weight observations by the household size.{p_end}

{p 0 4} {cmdab:hweight}  Sampling weight at the level of the household. {p_end}

{p 0 4} {cmdab:hgroup}   variable which indicates the household group. For example, this variable equals to 1 for households that live in rural area and 2 for those that live in urban area. When this option is used, varlist should contain only one variable. If values of the variable {it:hgroup} are labelled, the produced graphs contain automatically these labels. {p_end}

{p 0 4} {cmdab:ngroup}    To indicate the selected group number. {p_end}

{p 0 4} {cmdab:rho}     Parameter of social avesion to the vertical inequality. By default (rho=2.0).   {p_end}

{p 0 4} {cmdab:eps}     Parameter of social avesion to the horizontal inequality.  By default (rho=0.5). {p_end}

{p 0 4} {cmdab:ngroup}    To indicate the selected group number. {p_end}



{title:Examples}

{p 4 8}{inp:. dja G_inc N_inc, hw(weight) }{p_end}

{title:Related references}
{p 4 8} Jean-Yves Duclos, Vincent Jalbert et Abdelkrim Araar (2003), {browse "http://132.203.59.36/CIRPEE/cahierscirpee/2003/description/descrip0306.htm":Classical Horizontal Inequity and Reranking: an Integrating Approach}, CIRPÉE - Working Paper: 03-06.{p_end} 
{title:Author(s)}

{p 4 2 2} If you observe any problems:

Araar  Abdelkrim:  {browse "mailto:aabd@ecn.ulaval.ca"}


