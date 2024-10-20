{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:diginis }{right:Dialog box:  {bf:{dialog diginis}}}
{hline}

{title: Decomposition of the Gini index of inequality by income sources} 

{p 8 10}{cmd:diginis}  {it:varlist}  {cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:APPR(}{it:string}{cmd:)} 
{cmd:SAPPR(}{it:string}{cmd:)} 
{cmd:TYPE(}{it:string}{cmd:)}
{cmd:XFIL(}{it:string}{cmd:)}
{cmd:XSHE(}{it:string}{cmd:)}
{cmd:MODREP(}{it:string}{cmd:)}
 ]
 

{p}where {p_end}
{p 8 8} {cmd:varlist} is a list of variables (income sources). {p_end}


{title:Version} 15.0 and higher.

{title:Description}
The command {cmd:diginis} decomposes the Gini index of inequality by income sources and provides standard errors on elements of the decompositions.

{title:Remark}
{p}Users should set their surveys' sampling design before using this module  (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned  by default. {p_end}


{title:Options}

{p 2 4} {cmdab:hsize}        Household size. For example, to compute inequality at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 2 4} {cmdab:appr}         By default, Rao's approach (1969) is used. To use the Lerman and Yitzhaki (1985) approach, choose appr(lay). To use the Araar (2006) approach, choose the option appr(ara). For the Shapley approach, use the option appr(sha). {p_end}
 
{p 2 4} {cmdab:type}         If "abs" is selected, the decomposed index is the absolute Gini index. {p_end}

{p 2 4} {cmdab:sappr}        This option is for the Shapley approach. By default, when a component is missing from a set, we replace it by its mean value. To replace it by zero, select the option appr(zero). {p_end}

{p 2 4} {cmdab:dec}          To set the number of decimals used in the display of results. {p_end}

{p 2 4} {cmdab:dste}         If "0" is selected, standard errors are not displayed. {p_end}

{p 2 8} {cmd:xshe}   To indicate the name of the sheet of the Excel file. {p_end}

{p 2 8} {cmd:xtit}   To indicate the name of the table of the Excel file. {p_end}

{p 2 8} {cmd:modrep}   Add the option modrep(modify) to modify the Excel file instead of replacing it. {p_end}

{title:Examples}
sysuse Nigeria_2004I.dta, replace
diginis source1 source2  source3, hsize(hhsize)
diginis source1 source2  source3, hsize(hhsize) appr(sha)


{title:Reference(s)}
{p 4 4 2} Araar Abdelkrim (2006_a). {browse "https://papers.ssrn.com/sol3/papers.cfm?abstract_id=877147":On the Decomposition of the Gini Coefficient: an Exact Approach, with an Illustration Using Cameroonian Data}, W.P 02-06 CIRPEE, Universite Laval. {p_end}
{p 4 4 2} Araar Abdelkrim (2006_b). {browse "http://dad.ecn.ulaval.ca/technical_notes/note12/Ref/ABS_GINI_Araar.pdf":The Absolute Gini Coefficient: Decomposition and Stochastic Dominance}, W.P 02-06 CIRPEE, Universite Laval. {p_end}
{p 4 4 2} Lerman, R. I. , and S. Yitzhaki. "Income Inequality Effects by Income Source: A New Approach and Applications to the United States." Review of Economics and Statistics 67 (1985): 151-56. {p_end}
{p 4 4 2} Abdelkrim Araar and Jean-Yves Duclos (2008), {browse "http://dad.ecn.ulaval.ca/pdf_files/shap_dec_aj.pdf":An algorithm for computing the Shapley Value}, Mimeo, PEP and CIRPEE, Universite Laval. {p_end} 

{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}
