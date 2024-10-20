{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:difgt }{right:Dialog box:  {bf:{dialog dfgtg2d}}}
{hline}

{title: The sectoral decomposition of the differences between FGT poverty indices} 

{p 8 10}{cmd:difgt}  {it:varlist}  {cmd:,} [ 
{cmd:FILE1(}{it:string}{cmd:)}  
{cmd:FILE2(}{it:string}{cmd:)} 
{cmd:HSIZE1(}{it:string}{cmd:)}  
{cmd:HSIZE2(}{it:string}{cmd:)}
{cmd:HGROUP(}{it:string}{cmd:)}  
{cmd:ALpha(}{it:real}{cmd:)}
{cmd:PLINE(}{it:real}{cmd:)} 
{cmd:REF(}{it:string}{cmd:)} 
]

{p}where {p_end}

{p 8 8} {cmd:varlist} is a list of two variables of interest (variable of interest of the first distribution followed by that of the second distribution).  {p_end}

{title:Version} 15.0 and higher.

{title:Description}
 {p}{cmd:difgt}: To estimate: {p_end}
 
{p 4 8}{inp:. The the sectoral decomposition components of the difference between FGT poverty indices.}{p_end}
{p 4 8}{inp:. The standard errors taking full account of survey design}{p_end}
 

{title:Remarks:}
{p 4 6}{inp:1-  Users should set their surveys' sampling design before using this module (and to save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned  by default.} {p_end}
{p 4 6}{inp:2-  For each of the two distributions, users can use the data file currently in memory or a stored data file.} {p_end}

{title:Options}


{p 0 4} {cmdab:file1}    By default, the file in memory is used for the first distribution. If a stored file is to be used for the first distribution, select it with this option. {p_end}

{p 0 4} {cmdab:file2}    By default, the file in memory is used for the second distribution. If a stored file is to be used for the second distribution, select it with this option. {p_end}

{p 0 4} {cmdab:hsize1}    Household size for the first distribution. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design).{p_end}

{p 0 4} {cmdab:hsize2}    Household size for the second distribution. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:hgroup}    Variable that captures a socio-demographic group. For example, this variable could equal 1 for rural households and 2 for urban ones. When this option is used, the associated varlist should contain only one variable. {p_end}

{p 0 8} {cmdab: Note you must have same name for group variable with the same modalities for the two distributions.} 

{p 0 4} {cmdab:alpha}    To set the FGT parameter (alpha). By default, alpha=0.   {p_end}

{p 0 4} {cmdab:pline}    To set the poverty line. {p_end}

{p 0 4} {cmdab:ref}     To set the reference period of the decomposition (1=intial=1, 2=final). Further, the user can set its value to zero (ref(0)) in order to perform the decomposition with the Shapley approach. {p_end}


{title:Examples}
sysuse bkf94I,  replace
save file_1994, replace
sysuse bkf98I,  replace
save file_1998, replace
dfgtg2d exppc expeqz, file1(file_1994.dta) hsize1(size) file2(file_1998.dta) hsize2(size) alpha(0) pline(40000) hgroup(sex) ref(0)

{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}

