{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:ipov }{right:Dialog box:  {bf:{dialog ipov}}}
{hline}
{title: Poverty Indices} 
{p 8 10}{cmd:ipov}  {it:varlist}  {cmd:,} 
[ 
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:HGroup(}{it:varlist}{cmd:)} 
{cmd:PLine(}{it:real}{cmd:)}  
{cmd:OPL(}{it:string}{cmd:)} 
{cmd:PROP(}{it:real}{cmd:)}
{cmd:PERC(}{it:real}{cmd:)}
{cmd:ALpha(}{it:real}{cmd:)} 
{cmd:TYPE(}{it:string}{cmd:)} 
{cmd:INDex(}{it:string}{cmd:)} 
{cmd:LEVEL(}{it:real}{cmd:)}
{cmd:CONF(}{it:string}{cmd:)} 
{cmd:DEC(}{it:integer}{cmd:)} 
{cmd:INISAVE(}{it:string}{cmd:)} 
]
 


{p}where {p_end}
{p 8 8} {cmd:varlist} is a list of variables. {p_end}


{title:Version} 15 and higher.

{title:Description}
 {p}{cmd:Poverty indices}  Users should set their surveys' sampling design before using this module 
 (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default. With {cmd:ipov}, the following poverty indices and their standard errors {p_end} will be estimated:

{p 4 8}{inp:- FGT index.}{p_end}
{p 4 8}{inp:- Normalised FGT index.}{p_end}
{p 4 8}{inp:- EDE-FGT indices.}{p_end}
{p 4 8}{inp:- Normalised EDE-FGT index.}{p_end}
{p 4 8}{inp:- Watts poverty index.}{p_end}
{p 4 8}{inp:- Sen-Shorrocks-Thon poverty indices.}{p_end}
 


{title:Common options:}

{p 0 4} {cmdab:hsize}    Household size. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:hgroup}   Variable(s) that captures a socio-demographic group. For example, this variable could equal 1 for rural households and 2 for urban ones. When this option is used, the associated varlist should contain only one variable. 
                         Note that one can indicate more than one group variable. For instance: hgroup(gse sex zone).  {p_end}

{p 0 4} {cmdab:alpha}    To set the FGT parameter (alpha). By default, alhpha=0.   {p_end}

{p 0 4} {cmdab:pline}    To set the poverty line (value or varname). {p_end}

{p 0 4} {cmdab:level}   To set the confidence level of the confidence interval to be produced. {p_end}

{p 0 4} {cmdab:conf}     To set the type of confidence interval desired: "ts" for two-sided, "lb" for lower-bounded and "up" for upper-bounded.{p_end}

{p 0 4} {cmdab:dec}    To set the number of decimals used in the display of results. {p_end}

{p 0 4} {cmdab:inisave} To save the easi dialog box information. Mainly, all inserted information in the dialog box will be save in this file. In another session, the user can open the project using the command easi_db_ini followed  by the name of project. {p_end}

{p 0 4} {cmdab:index}  To indicate the desired poverty index: {p_end}

{p 3 4} {cmdab:fgt:  }  The FGT poverty index. {p_end} 
{p 3 4} {cmdab:ede:  }  The equally-distributed-equivalent (EDE) index. {p_end} 
{p 3 4} {cmdab:watts:}  The Wattts poverty index. {p_end} 
{p 3 4} {cmdab:sst:  }  The Sen-Shorrocks-Thon index  index. {p_end} 


{title:Specigic index options:}
{p 0 4} {cmdab:FGT indices} {p_end}
{p 2 4} {cmdab:opl}     To set the poverty line as a proportion of the mean "mean", the median "median" or the quantile "quantile". {p_end}

{p 2 4} {cmdab:prop}    To set the value to be used as the proportion of the mean or quantile. {p_end}

{p 2 4} {cmdab:perc}    To set the percentile to be used if the option "quantile is selected in option "opl1". {p_end}

{p 2 4} {cmdab:type}   To estimate non-normalised FGT (non Normalized by the poverty line), select the option "not".  {p_end}





{p 4 10 2}
NOTE: All the examples illustrated in the present and in the following sections
      can be run by clicking on the blue hyperlinks.


{p 0 4}   {cmd:Example 1:}  Estimating the FGT0 indices across the socio-professional groups. {p_end}

sysuse bkf98I, replace
ipov exppc, alpha(0) hsize(size) hgroup(gse) index(fgt) pline(pline) inisave(example1)

{txt}      ({stata "dasp_examples ex_ipov_01"    :example 1: click to run in command window})
{txt}      ({stata "dasp_examples ex_ipov_db_01 ":example 1: click to run in dialog box})



{p 0 4}  {cmd :Example 2:}  Estimating the FGT1 indices across the socio-professional group,  and where the poverty line is the average per capita expenditures at population level. {p_end}

sysuse bkf98I, replace
ipov exppc, alpha(1) hsize(size) hgroup(gse) index(fgt) dec(4) opl(mean) prop(50) inisave(example2)

{txt}      ({stata "dasp_examples ex_ipov_02"    :example 2: click to run in command window})
{txt}      ({stata "dasp_examples ex_ipov_db_02 ":example 2: click to run in dialog box})


{p 0 4}  {cmd :Example 3:}  Estimating the FGT1 indices across the socio-professional group,  and where the poverty line is the average per capita expenditures at group level. {p_end}

sysuse bkf98I, replace
ipov exppc, alpha(1) hsize(size) hgroup(gse) index(fgt) opl(mean) prop(50) rel(group) inisave(example3)

{txt}      ({stata "dasp_examples ex_ipov_03"    :example 3: click to run in command window})
{txt}      ({stata "dasp_examples ex_ipov_db_03 ":example 3: click to run in dialog box})





{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}
