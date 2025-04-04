{smcl}
{* May 2007}{...}
{hline}
{hi:DASP : Distributive Analysis Stata Package}{right:{bf:PEP, CIRPEE, World Bank and UNDP}}
help for {hi:imdi }{right:Dialog box:  {bf:{dialog imdi}}}
{hline}

{title: Multidimensional inequality index (Araar(2008))} 

{p 8 10}{cmd:diginis}  {it:varlist}  {cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:HGroup(}{it:varname}{cmd:)} 
{cmd:APPR(}{it:string}{cmd:)} 
{cmd:TYPE(}{it:string}{cmd:)
{cmd:ISHAR(}{it:string}{cmd:)
{cmd:DEC(}{it:int}{cmd:)}]
 

{p}where {p_end}
{p 8 8} {cmd:varlist} is a list of variables (dimension variables). {p_end}


{title:Version} 15 and higher.

{title:Description}
The command {cmd:imdi} Estimates the Araar 2008 MDI index of inequality.

{title:Remark}
{p}Users should set their surveys' sampling design before using this module  (and to save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned  by default. {p_end}


{title:Options}

{p 0 4} {cmdab:hsize}        Household size. For example, to compute inequality at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:hgroup}   Variable which conditions the analysis on a socio-demographic group. For example, this variable could equal 1 for rural households and 2 for urban ones. When this option is used, the associated varlist should contain only one variable. {p_end}

{p 0 4} {cmdab:type}         If "abs" is selected, the index is the absolute MDIindex. {p_end}

{p 0 4} {cmdab:ishare}        By default the dimensional weight is 1/D where D is the number of dimensions. Select "yes" option to weight by the income shares (see the reference Araar(2009) for more details) . {p_end}

{p 0 4} {cmdab:lam"k"}     parameters used to estimate the MDI index (see the reference Araar(2009) for more details). {p_end}

{p 0 4} {cmdab:lambda} if this parameter is specified, this makes that lam"k" = lambda for all k. 

{p 0 4} {cmdab:dec}          To set the number of decimals used in the display of results. {p_end}




{title:Examples}
sysuse imdi_data.dta, replace
imdi nsc_hab nsc_etu nsc_san, hsize(size) hgroup(area) lam1(0.5) lam2(0.5) lam3(0.5) 


{title:Reference(s)}
{p 4 4 2} Araar Abdelkrim (2009). {browse "http://www.cirpee.org/recherche/cahiers_du_cirpee/2009/":OThe Hybrid Multidimensional Index of Inequality}, W.P 45-09 CIRPEE, University Laval. {p_end}



{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}
