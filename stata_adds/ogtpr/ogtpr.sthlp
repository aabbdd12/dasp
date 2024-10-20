{smcl}
{* January 2017}{...}
{hline}
{hi:OGTPR : Optimal Targeting Groups for Poverty Reduction}
help for {hi:ogtpr }{right:Dialog box:  {bf:{dialog ogtpr}}}
{hline}

{title: Optimal Targeting Groups for Poverty Reduction} 

{p 8 10}{cmd:ogtpr}  {it:varlist}  {cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)} {cmd:HGroup(}{it:varname}{cmd:)} {cmd:PLine(}{it:real}{cmd:)}  {cmd:TRANS(}{it:real}{cmd:)  {cmd:PART(}{it:int}{cmd:)  {cmd:ERED(}{it:int}{cmd:)} 
{cmd:ALpha(}{it:real}{cmd:)} ]
 

{p}where {p_end}
{p 8 8} {cmd:varlist} is the variable of wellbeing (income). {p_end}


{title:Version} 9.2 and higher.

{title:Description}
 {p}{cmd:Poverty: Optimal Targeting by Population Groups}  {p_end}
 {p} Users should set their surveys' sampling design before using this module 
 (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default. {cmd:oogtpr} estimates thegroups lump sum transfers  to reduce optimally  the aggregate poverty for a given predefined budget of transfers.
{p_end}


{title:Options}

{p 0 4} {cmdab:hsize}        Household size. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:hgroup}       Variable that captures the socio-demographic group to be used in the decomposition. For example, for an urban-rural decomposition of poverty, this variable could equal 1 for rural households and 2 for urban ones. The associated varlist should contain only one variable. {p_end}

{p 0 4} {cmdab:alpha}        To set the FGT parameter (alpha). By default, alpha=0.   {p_end}

{p 0 4} {cmdab:pline}        To set the poverty line. {p_end}

{p 0 4} {cmdab:trans}        To set the fixed per capita lump sum transfer. {p_end}

{p 0 4} {cmdab:ered}         Set the value to one ( ered(1) ) to estimate the reduction in aggregate poverty and the quality of the group indicator. This option requires the  {browse	"http://dasp-two.vercel.app": DASP Stata package} {p_end}

{p 0 4} {cmdab:dec}          To set the number of decimals used in the display of results. {p_end}



{title:Examples}

{p 4 8}{inp:. ogtpr income, pline(10000) trans(1000) alpha(1) hgroup(education) ered(1)}{p_end}



{title:Author(s)}
Abdelkrim Araar

{title:Reference(s)}  
{p 4 4 2} 1 - Araar Abdelkrim (2017)	{browse	"http://dasp-two.vercel.app/references/OptTarg_Araar&Tiberti_March_2017.pdf": Optimal Population Group Targeting and Poverty Reduction},	mimeo {p_end}


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}



