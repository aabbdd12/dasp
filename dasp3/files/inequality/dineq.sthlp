{smcl}
{* January 2007}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:dineq }{right:Dialog box:  {bf:{dialog dineq}}}
{hline}
{title: Difference between inequality indices} 
{p 8 10}{cmd:dineq}  {it:varlist}  {cmd:,} [ 
{cmd:FILE1(}{it:string}{cmd:)}  
{cmd:FILE2(}{it:string}{cmd:)} 
{cmd:RANK1(}{it:varname}{cmd:)}  
{cmd:RANK2(}{it:varname}{cmd:)} 
{cmd:HSIZE1(}{it:string}{cmd:)}  
{cmd:HSIZE2(}{it:string}{cmd:)} 
{cmd:COND1(}{it:string}{cmd:)}  
{cmd:COND2(}{it:string}{cmd:)}  
{cmd:HGroup(}{it:varlist}{cmd:)} 
{cmd:LEVEL(}{it:real}{cmd:)}
{cmd:CONF(}{it:string}{cmd:)}
{cmd:TEST(}{it:real}{cmd:)}
]

{p}where {p_end}
{p 8 8} {cmd:varlist} is a list of two variables of welfare (variable of welfare of the first distribution followed by that of the second distribution).  {p_end}
{title:Version} 15 and higher.
{title:Description}
 {p}{cmd:dineq}: To estimate the difference between inequality indices: {p_end}
 
{p 4 8}{inp:- Gini index.}{p_end}
{p 4 8}{inp:- Absolute Gini index.}{p_end}
{p 4 8}{inp:- Concentration index.}{p_end}
{p 4 8}{inp:- Absolute concentration index.}{p_end}
{p 4 8}{inp:- Atkinson index.}{p_end}
{p 4 8}{inp:- Generalised entropy index.}{p_end}
{p 4 8}{inp:- Coefficient of variation index.}{p_end}
{p 4 8}{inp:- Quantile ratio index .}{p_end}
{p 4 8}{inp:- Share ratio index.}{p_end}

{title:Remark(s)}
{p 4 6}{inp:1- Difference between inequality indices}  Users should set their surveys' sampling design before using this module  (and to save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned  by default. {p_end}
{p 4 6}{inp:2- For each of the two distributions, users can use the data file currently in memory or a stored data file.} {p_end}

{title:Common options:}
{p 0 4} {cmdab:file1}    By default, the file in memory is used for the first distribution. If a stored file is to be used for the first distribution, select it with this option. {p_end}
{p 0 4} {cmdab:file2}    By default, the file in memory is used for the second distribution. If a stored file is to be used for the second distribution, select it with this option. {p_end}
{p 0 4} {cmdab:hsize1}    Household size for the first distribution. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design).{p_end}

{p 0 4} {cmdab:hsize2}    Household size for the second distribution. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:cond1}    To set a logical expression that will capture a socio-demographic group for the first distribution (for example, zone==3). See the help for {help operator}. {p_end}
{p 0 4} {cmdab:cond2}    To set a logical expression that will capture a socio-demographic group for the second distribution (for example, zone==2 & education==5). See the help for {help operator}.{p_end}

{p 0 4} {cmdab:hgroup}   Variable(s) that captures a socio-demographic group. For example, this variable could equal 1 for rural households and 2 for urban ones. When this option is used, the associated varlist should contain only one variable. 
                         Note that one can indicate more than one group variable. For instance: hgroup(gse sex zone).  {p_end}

{p 0 4} {cmdab:level}     To set the confidence level of the confidence interval to be produced.{p_end}
{p 0 4} {cmdab:conf}     To set the type of confidence interval desired: "ts" for two-sided, "lb" for lower-bounded and "up" for upper-bounded.{p_end}
{p 0 4} {cmdab:test}   To test if the difference is equal to a given value. For instance, test(0.03). {p_end}
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



{title:Specific options of indices:}
{p 0 4} {cmdab:Concentration and absolute concentration indices} {p_end}
{p 2 4} {cmdab:rank1}    To set the ranking variable for the first distribution. {p_end}
{p 2 4} {cmdab:rank2}    To set the ranking variable for the second distribution.{p_end}
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

{p 0 4}   {cmd:Example 1:}  Estimating the difference between Gini indices by population groups (years: 1998 vs 1994)). Also, testing if the estimated difference at population level is significant. {p_end}
sysuse bkf94I,  replace
save file_1994, replace
sysuse bkf98I,  replace
save file_1998, replace
dineq exppc exppc, file1(file_1994) hsize1(size) file2(file_1998) hsize2(size) test(0) inisave(myexample) index(gini) hgroup(gse sex)
{txt}      ({stata "dasp_examples ex_dineq_01"    :example 1: click to run in command window})
{txt}      ({stata "dasp_examples ex_dineq_db_01 ":example 1: click to run in dialog box})

{p 0 4}  {cmd :Example 2:}  Estimating the difference between generalised entropy indices -theta=0- (years: 1998 || Male vs Female headed households)). Also, testing if the estimated difference is significant. {p_end}
sysuse bkf98I, replace
dineq exppc exppc, hsize1(size) cond1(sex==1) hsize2(size) cond2(sex==2) theta(0) test(0) inisave(myexample) index(entropy)
{txt}      ({stata "dasp_examples ex_dineq_02"    :example 2: click to run in command window})
{txt}      ({stata "dasp_examples ex_dineq_db_02 ":example 2: click to run in dialog box})

{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos

{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}
