{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:ineq }{right:Dialog box:  {bf:{dialog ineq}}}
{hline}
{title: Inequality Indices} 
{p 8 10}{cmd:ineq}  {it:varlist}  {cmd:,}
[ 
{cmd:RANK(}{it:varname}{cmd:)}  
{cmd:EPSIlon(}{it:real}{cmd:)} 
{cmd:THETA(}{it:real}{cmd:)} 
{cmd:P1(}{it:real}{cmd:)} 
{cmd:P2(}{it:real}{cmd:)} 
{cmd:P3(}{it:real}{cmd:)} 
{cmd:P4(}{it:real}{cmd:)} 
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:HGroup(}{it:varlist}{cmd:)} 
{cmd:LEVEL(}{it:real}{cmd:)}
{cmd:CONF(}{it:string}{cmd:)} 
{cmd:DEC(}{it:int}{cmd:)} 
{cmd:TYPE(}{it:string}{cmd:)} 
{cmd:INISAVE(}{it:string}{cmd:)} 
]
 

{p}where {p_end}
{p 8 8} {cmd:varlist} is a list of variables. {p_end}


{title:Version} 10 and higher.

{title:Description}
 {p}{cmd:Inequality indices}  Users should set their surveys' sampling design before using this module 
 (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default. With {cmd:ineq}, the following ineqilaity indices and their standard errors  will be estimated: {p_end}

{p 4 8}{inp:- Gini index.}{p_end}
{p 4 8}{inp:- Absolute Gini index.}{p_end}
{p 4 8}{inp:- Concentration index.}{p_end}
{p 4 8}{inp:- Absolute concentration index.}{p_end}
{p 4 8}{inp:- Atkinson index.}{p_end}
{p 4 8}{inp:- Generalised entropy index.}{p_end}
{p 4 8}{inp:- Coefficient of variation index.}{p_end}
{p 4 8}{inp:- Quantile ratio index .}{p_end}
{p 4 8}{inp:- Share ratio index.}{p_end}
  
{title:Common options:}

{p 0 4} {cmdab:hsize}   Household size. For example, to compute inequality at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:hgroup}   Variable(s) that captures a socio-demographic group. For example, this variable could equal 1 for rural households and 2 for urban ones. When this option is used, the associated varlist should contain only one variable. 
                         Note that one can indicate more than one group variable. For instance: hgroup(gse sex zone).  {p_end}
{p 0 4} {cmdab:level}   To set the confidence level of the confidence interval to be produced. {p_end}

{p 0 4} {cmdab:conf}     To set the type of confidence interval desired: "ts" for two sided, "lb" for lower-bounded and "up" for upper-bounded.{p_end}

{p 0 4} {cmdab:dec}    To set the number of decimals used in the display of results. {p_end}


{p 0 4} {cmdab:index}  To indicate the desired inequality index: {p_end}

{p 3 4}  {cmdab:gini:}  Gini index.{p_end}
{p 3 4}  {cmdab:agini:}  Absolute Gini index.{p_end}
{p 3 4}  {cmdab:conc:}  Concentration index.{p_end}
{p 3 4}  {cmdab:aconc:}  Absolute concentration index.{p_end}
{p 3 4}  {cmdab:atk:}  Atkinson index.{p_end}
{p 3 4}  {cmdab:entropy:}  Generalised entropy index.{p_end}
{p 3 4}  {cmdab:covar:}  Coefficient of variation index.{p_end}
{p 3 4}  {cmdab:qr:}  Quantile ratio index.{p_end}
{p 3 4}  {cmdab:sr:}  Share ratio index.{p_end}

{p 0 4} {cmdab:inisave} To save the easi dialog box information. Mainly, all inserted information in the dialog box will be save in this file. In another session, the user can open the project using the command dasp_db_ini followed  by the name of project. {p_end}

{title:Specific options of indices:}
{p 0 4} {cmdab:Concentration and absolute concentration indices} {p_end}
{p 2 4} {cmdab:rank}       If a ranking variable is indicated, concentration indices are estimated instead of Gini indices. {p_end}

{p 0 4} {cmdab:Atkinson index} {p_end}
{p 2 4} {cmdab:epsilon}     The value of the parameter epsilon (see the users' manual for mor details). By default, this parameter is set to 0.5. {p_end}

{p 0 4} {cmdab:Generalised entropy index} {p_end}
{p 2 4} {cmdab:theta}     The value of the parameter theta (see the users' manual for mor details). By default, this parameter is set to 1. {p_end}

{p 0 4} {cmdab:Quantile ratio index} {p_end}
{p 2 4} {cmdab:p1-p2}     Percentile values. {p_end}

{p 0 4} {cmdab:Share ratio index} {p_end}
{p 2 4} {cmdab:p1-p4}     Percentile values. {p_end}

{title:Detailed description:}

Quantile ratio
==============
Denote Q(p1) and Q(p2) the quantiles at percentiles p1 and p2 (by default p1=0.1, p2=0.9).

The quantile ratio is defined as:
                        
                             Q(p1)              
                    QR  =   ------   
                             Q(p2)  

Share ratio
==============
Let GL(p1), GL(p2), GL(p3) and Gl(p4) be the Generalised Lorenz curve at percentiles p1, p2, p3 and p4 respectively (by default p1=0.1, p2=0.2, p3=0.8, p2=0.9).

The share ratio is defined as:
                        
                             GL(p2) - GL(p1)              
                    SR  =   -----------------   
                             GL(p4) - GL(p3)              



 

{p 4 10 2}
NOTE: All the examples illustrated in the present and in the following sections
      can be run by clicking on the blue hyperlinks.


{p 0 4}   {cmd:Example 1:}  Estimating the Gini indices across the socio-professioonal groups. {p_end}

sysuse bkf98I, replace
ineq exppc, hsize(size) hgroup(gse sex) index(gini) inisave(myexample)

{txt}      ({stata "dasp_examples ex_ineq_01"    :example 1: click to run in command window})
{txt}      ({stata "dasp_examples ex_ineq_db_01 ":example 1: click to run in dialog box})



{p 0 4}  {cmd :Example 2:}  Estimating the FGT1 indices across the socio-professioonal group,  and where the poverty line is the average per capita expenditures at population level. {p_end}

sysuse bkf98I, replace
ineq exppc, hsize(size) hgroup(gse) index(atk) inisave(myexample)

{txt}      ({stata "dasp_examples ex_ineq_02"    :example 2: click to run in command window})
{txt}      ({stata "dasp_examples ex_ineq_db_02 ":example 2: click to run in dialog box})


{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}
