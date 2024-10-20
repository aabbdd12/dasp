{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:dipov }{right:Dialog box:  {bf:{dialog dipov}}}
{hline}

{title: Differences between poverty indices} 

{p 8 10}{cmd:dipov}  {it:varlist}  {cmd:,} [ 
{cmd:FILE1(}{it:string}{cmd:)}  
{cmd:FILE2(}{it:string}{cmd:)} 
{cmd:HSIZE1(}{it:string}{cmd:)}  
{cmd:HSIZE2(}{it:string}{cmd:)} 
{cmd:COND1(}{it:string}{cmd:)}  
{cmd:COND2(}{it:string}{cmd:)}  
{cmd:HGroup(}{it:varlist}{cmd:)} 
{cmd:ALpha(}{it:real}{cmd:)}
{cmd:PLINE1(}{it:real}{cmd:)} 
{cmd:OPL1(}{it:string}{cmd:)} 
{cmd:PROP1(}{it:real}{cmd:)}
{cmd:PERC1(}{it:real}{cmd:)}
{cmd:PLINE2(}{it:real}{cmd:)}  
{cmd:OPL2(}{it:string}{cmd:)} 
{cmd:PROP2(}{it:real}{cmd:)}
{cmd:PERC2(}{it:real}{cmd:)} 
{cmd:TYPE(}{it:string}{cmd:)} 
{cmd:LEVEL(}{it:real}{cmd:)}
{cmd:CONF(}{it:string}{cmd:)}
{cmd:TEST(}{it:real}{cmd:)}
]

{p}where {p_end}

{p 8 8} {cmd:varlist} is a list of two variables of welfare (variable of welfare of the first distribution followed by that of the second distribution).  {p_end}

{title:Version} 15 and higher.

{title:Description}
 {p}{cmd:dipov}: To estimate the difference between poverty indices: {p_end}
 
{p 4 8}{inp:- FGT index.}{p_end}
{p 4 8}{inp:- Normalised FGT index.}{p_end}
{p 4 8}{inp:- EDE-FGT indices.}{p_end}
{p 4 8}{inp:- Normalised EDE-FGT index.}{p_end}
{p 4 8}{inp:- Watts poverty index.}{p_end}
{p 4 8}{inp:- Sen-Shorrocks-Thon poverty indices.}{p_end}
 

{title:Remarks:}
{p 4 6}{inp:1- Differences between FGT poverty indices}  Users should set their surveys' sampling design before using this module 
 (and to save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default. {p_end}
 {p 4 6}{inp:2- For each of the two distributions, users can use the data file currently in memory or a stored data file.} {p_end}

{title:Common options:}

{p 0 4} {cmdab:file1}    By default, the file in memory is used for the first distribution. If a stored file is to be used for the first distribution, select it with this option. {p_end}

{p 0 4} {cmdab:file2}    By default, the file in memory is used for the second distribution. If a stored file is to be used for the second distribution, select it with this option. {p_end}

{p 0 4} {cmdab:hsize1}    Household size for the first distribution. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design).{p_end}

{p 0 4} {cmdab:hsize2}    Household size for the second distribution. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:pline1}    To set the poverty line for the first distribution  (value or varname). {p_end}

{p 0 4} {cmdab:pline2}    To set the poverty line for the second distribution  (value or varname). {p_end}

{p 0 4} {cmdab:cond1}    To set a logical expression that will capture a socio-demographic group for the first distribution (for example, zone==3). See the help for {help operator}. {p_end}

{p 0 4} {cmdab:cond2}    To set a logical expression that will capture a socio-demographic group for the second distribution (for example, zone==2 & education==5). See the help for {help operator}.{p_end}

{p 0 4} {cmdab:hgroup}   Variable(s) that captures a socio-demographic group. For example, this variable could equal 1 for rural households and 2 for urban ones. When this option is used, the associated varlist should contain only one variable. 
                         Note that one can indicate more than one group variable. For instance: hgroup(gse sex zone).  {p_end}
						 
{p 0 4} {cmdab:level}     To set the confidence level of the confidence interval to be produced.{p_end}

{p 0 4} {cmdab:conf}     To set the type of confidence interval desired: "ts" for two-sided, "lb" for lower-bounded and "up" for upper-bounded.{p_end}

{p 0 4} {cmdab:test}   To test if the difference is equal to a given value. For instance, test(0.03). {p_end}



{title:Specigic index options:}
{p 0 4} {cmdab:FGT indices} {p_end}

{p 0 4} {cmdab:alpha}    To set the FGT parameter (alpha). By default, alpha=0.   {p_end}


{p 0 4} {cmdab:opl1}    To set the poverty line as a proportion of the mean "mean", the median "median" or the quantile "quantile" for the first distribution. {p_end}

{p 0 4} {cmdab:prop1}    To set the value to be used as the proportion of the mean or quantile for the first distribution. {p_end}

{p 0 4} {cmdab:perc1}    To set the percentile to be used if the option "quantile'' is selected in option "opl1" for the first distribution. {p_end}


{p 0 4} {cmdab:opl2}    To set the poverty line as a proportion of the mean "mean", the median "median" or the quantile "quantile" for the second distribution. {p_end}

{p 0 4} {cmdab:prop2}    To set the value to be used as the proportion of the mean or quantile for the second distribution. {p_end}

{p 0 4} {cmdab:perc2}    To set the percentile to be used if the option "quantile'' is selected in option "opl1" for the second distribution. {p_end}

{p 0 4} {cmdab:type}  To estimate non-normalised FGT (non normalised by the poverty line), select the option "not".  {p_end}



{p 4 10 2}
NOTE: All the examples illustrated in the present and in the following sections
      can be run by clicking on the blue hyperlinks.


{p 0 4}   {cmd:Example 1:}  Estimating the  difference in FGT0 indices between male household head (i.e. sex=1) and female household head (i.e. sex=2). {p_end}

sysuse bkf98I, replace , replace
dipov exppc exppc, hsize1(size) cond1(sex==1) hsize2(size) cond2(sex==2) pline1(60000) pline2(60000) alpha(0) inisave(myexample) index(fgt)

{txt}      ({stata "dasp_examples ex_dipov_01"    :example 1: click to run in command window})
{txt}      ({stata "dasp_examples ex_dipov_db_01 ":example 1: click to run in dialog box})



{p 0 4}  {cmd :Example 2:}  Estimating the difference in FGT indices across population groups,  and where the poverty line is the average per capita expenditures at population level. {p_end}

sysuse bkf98I.dta , replace
dipov exppc exppc, file1(https://www.dasp.cstip.ulaval.ca/dasp3/examples/data/bkf94I.dta) hsize1(size) hsize2(size) pline1(60000) pline2(pline) alpha(0) inisave(myexample) index(fgt)
{txt}      ({stata "dasp_examples ex_dipov_02"    :example 2: click to run in command window})
{txt}      ({stata "dasp_examples ex_dipov_db_02 ":example 2: click to run in dialog box})






{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}
