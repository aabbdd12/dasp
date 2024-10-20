{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:dginig }{right:Dialog box:  {bf:{dialog diginig}}}
{hline}

{title: Decomposition of Gini index of inequality by groups} 

{p 8 10}{cmd:diginig}  {it:varname}  {cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:HGroup(}{it:varname}{cmd:)}  
{cmd:TYPE(}{it:string}{cmd:)} 
{cmd:XFIL(}{it:string}{cmd:)}
{cmd:XSHE(}{it:string}{cmd:)}
{cmd:MODREP(}{it:string}{cmd:)}
]
 

{p}where {p_end}
{p 8 8} {cmd:varname} is variable of interest (e.g., income per capita). {p_end}


{title:Version} 15.0 and higher.

{title:Description}
  {cmd:dginig} decomposes the Gini index of inequality by groups and provides standard errors on elements of the decompositions.

{title:Remark}
{p}Users should set their surveys' sampling design before using this module  (and then save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned  by default. {p_end}


{title:Options}

{p 2 4} {cmdab:hsize}        Household size. For example, to compute inequality at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 2 4} {cmdab:hgroup}       Variable that captures the socio-demographic group to be used in the decomposition. For example, for an urban-rural decomposition of poverty, this variable could equal 1 for rural households and 2 for urban ones. The associated varlist should contain only one variable. {p_end}

{p 2 4} {cmdab:type}         If "abs" is selected, the decomposed index is the absolute Gini index. {p_end}

{p 2 4} {cmdab:dec}          To set the number of decimals used in the display of results. {p_end}

{p 2 4} {cmdab:dste}         If "0" is selected, standard errors are not displayed. {p_end}

{p 2 8} {cmd:xfil}   To indicate the name of the Excel file, that will be used to save the results . {p_end}

{p 2 8} {cmd:xshe}   To indicate the name of the sheet of the Excel file. {p_end}

{p 2 8} {cmd:xtit}   To indicate the name of the table of the Excel file. {p_end}

{p 2 8} {cmd:modrep}   Add the option modrep(modify) to modify the Excel file instead of replacing it. {p_end}


{title:Examples}
sysuse bkf98I, replace
diginig exppc, hgroup(gse) hsize(size) dec(4)

{title:Reference(s)}
{p 4 4 2} Araar Abdelkrim (2006). {browse "https://papers.ssrn.com/sol3/papers.cfm?abstract_id=877147":On the Decomposition of the Gini Coefficient: an Exact Approach, with an Illustration Using Cameroonian Data}, W.P 02-06 CIRPEE, Universite Laval. {p_end}

{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}



