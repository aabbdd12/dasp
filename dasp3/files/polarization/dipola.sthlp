{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:dipola }{right:Dialog box:  {bf:{dialog dipola}}}
{hline}

{title: Difference between polarization indices} 

{p 8 10}{cmd:dipola}  {it:varlist}  {cmd:,} [ 
{cmd:FILE1(}{it:string}{cmd:)}  
{cmd:FILE2(}{it:string}{cmd:)} 
{cmd:RANK1(}{it:varname}{cmd:)}  
{cmd:RANK2(}{it:varname}{cmd:)} 
{cmd:HSIZE1(}{it:string}{cmd:)}  
{cmd:HSIZE2(}{it:string}{cmd:)} 
{cmd:COND1(}{it:string}{cmd:)}  
{cmd:COND2(}{it:string}{cmd:)}  
{cmd:LEVEL(}{it:real}{cmd:)}
{cmd:CONF(}{it:string}{cmd:)}
{cmd:TEST(}{it:real}{cmd:)}
]


{p}where {p_end}

{p 8 8} {cmd:varlist} is a list of two variables of welfare (variable of welfare of the first distribution followed by that of the second distribution).  {p_end}

{title:Version} 15 and higher.

{title:Description}
 {p}{cmd:dipola}: To estimate the difference between polarization indices: {p_end}
 
{p 4 8}{inp:- Duclos Esteban and Ray index of polarization (2004).}{p_end}
{p 4 8}{inp:- Foster and Wolfson (1992).}{p_end}


{title:Remark(s)}
{p 4 6}{inp:1- Difference between polarization indices}  Users should set their surveys' sampling design before using this module  (and to save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned  by default. {p_end}
{p 4 6}{inp:2- For each of the two distributions, users can use the data file currently in memory or a stored data file.} {p_end}


{title:Common options:}

{p 0 4} {cmdab:file1}    By default, the file in memory is used for the first distribution. If a stored file is to be used for the first distribution, select it with this option. {p_end}

{p 0 4} {cmdab:file2}    By default, the file in memory is used for the second distribution. If a stored file is to be used for the second distribution, select it with this option. {p_end}

{p 0 4} {cmdab:hsize1}    Household size for the first distribution. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design).{p_end}

{p 0 4} {cmdab:hsize2}    Household size for the second distribution. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:cond1}    To set a logical expression that will capture a socio-demographic group for the first distribution (for example, zone==3). See the help for {help operator}. {p_end}

{p 0 4} {cmdab:cond2}    To set a logical expression that will capture a socio-demographic group for the second distribution (for example, zone==2 & education==5). See the help for {help operator}.{p_end}

{p 0 4} {cmdab:level}     To set the confidence level of the confidence interval to be produced.{p_end}

{p 0 4} {cmdab:conf}     To set the type of confidence interval desired: "ts" for two-sided, "lb" for lower-bounded and "up" for upper-bounded.{p_end}

{p 0 4} {cmdab:test}   To test if the difference is equal to a given value. For instance, test(0.03). {p_end}

{p 0 4} {cmdab:index}  To indicate the desired polarization index: {p_end}

{p 3 4}  {cmdab:der:}  Duclos Esteban and Ray index of polarization (2004).{p_end}
{p 3 4}  {cmdab:fw: }  Foster and Wolfson (1992).{p_end}


{title:Specific options of indices:}
{p 0 4} {cmdab:Duclos Esteban and Ray index of polarization (2004)} {p_end}
{p 2 4} {cmdab:alpha}   The parameter alpha (see the main reference). {p_end}
{p 2 4} {cmdab:fast}    Option for computing the kernel density function. If "1" is chosen, CF-Kernel is used (see Ref_2) . {p_end}
{p 2 4} {cmdab:band}    To indicate the desired bandwidth.  (By default, an "optimal" bandwidth is used (see for instance Silverman (1986)). {p_end}




 

{p 4 10 2}
NOTE: All the examples illustrated in the present and in the following sections can be run by clicking on the blue hyperlinks.


{p 0 4}   {cmd:Example 1:}  Estimating the difference between DER indices (years: 1998 vs 1994)). Also, testing if the estimated difference is significant. {p_end}

sysuse bkf94I,  replace
save file_1994, replace
sysuse bkf98I,  replace
save file_1998, replace
dipola exppc exppc, file1(file_1994) hsize1(size) file2(file_1998) hsize2(size) test(0) inisave(myexample) index(der)

{txt}      ({stata "dasp_examples ex_dipola_01"    :example 1: click to run in command window})
{txt}      ({stata "dasp_examples ex_dipola_db_01 ":example 1: click to run in dialog box})



{p 0 4}  {cmd :Example 2:}  Estimating the difference between FW indices -theta=0- (years: 1998 || Male vs Female headed households)). Also, testing if the estimated difference is significant. {p_end}. {p_end}

sysuse bkf98I, replace
dipola exppc exppc, hsize1(size) cond1(sex==1) hsize2(size) cond2(sex==2)  test(0) inisave(myexample) index(fw)

{txt}      ({stata "dasp_examples ex_dipola_02"    :example 2: click to run in command window})
{txt}      ({stata "dasp_examples ex_dipola_db_02 ":example 2: click to run in dialog box})


{p 4 4 2} 1_ Duclos, Esteban and Ray (2003)  {browse "http://dad.ecn.ulaval.ca/features/files/DuclosEstebanRay-sept03.pdf":polarization Concepts, Measurement, Estimation.}, CIRPE W.P. 01-03{p_end}
{p 4 4 2} 2_ Tian Z. & all (1999)  "Fast Density Estimation Using CF-kernel for Very Large Databases". {browse "http://portal.acm.org/citation.cfm?id=312266"}{p_end}


{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos



{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}


