{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:dfgts }{right:Dialog box:  {bf:{dialog dfgts}}}
{hline}

{title: Decomposition of the FGT index by income components} 

{p 8 10}{cmd:dfgts}  {it:varlist}  {cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:PLine(}{it:real}{cmd:)}  
{cmd:ALpha(}{it:real}{cmd:)}
{cmd:DEC(}{it:string}{cmd:)}
{cmd:STE(}{it:real}{cmd:)}  
{cmd:ALpha(}{it:real}{cmd:)}
{cmd:XFIL(}{it:string}{cmd:)}
{cmd:XSHE(}{it:string}{cmd:)}
{cmd:MODREP(}{it:string}{cmd:)}
 ]
 

{p}where {p_end}
{p 8 8} {cmd:varlist} is a list of variables (income components or income sources). {p_end}


{title:Version} 15.0 and higher.

{title:Description}
{p} The command {cmd:dfgts} decomposes the allevation of FGT poverty by income components and provides standard errors on elements of the decompositions. 
Without any source, the FGT index is equal to 1. The decomposition is performed using the Shapley value. {p_end}

{title:Remark}
{p}Users should set their surveys' sampling design before using this module  (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned  by default. {p_end}


{title:Options}

{p 2 4} {cmdab:hsize}        Household size. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 2 4} {cmdab:alpha}         To set the FGT parameter (alpha). By default, alpha=0.   {p_end}

{p 2 4} {cmdab:pline}        To set the poverty line. {p_end}

{p 2 4} {cmdab:dec}          To set the number of decimals used in the display of results. {p_end}

{p 2 4} {cmdab:ste}          If "yes" is selected, standard errors are displayed. {p_end} 

{p 2 8} {cmd:xfil}   To indicate the name of the Excel file, that will be used to save the results . {p_end}

{p 2 8} {cmd:xshe}   To indicate the name of the sheet of the Excel file. {p_end}

{p 2 8} {cmd:xtit}   To indicate the name of the table of the Excel file. {p_end}

{p 2 8} {cmd:modrep}   Add the option modrep(modify) to modify the Excel file instead of replacing it. {p_end}

{title:Examples}
sysuse Nigeria_2004I, replace
dfgts source1-source6, hsize(hhsize) alpha(0) pline(10000)


{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}
