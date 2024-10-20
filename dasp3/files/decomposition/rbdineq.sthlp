{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:rbdineq }{right:Dialog box:  {bf:{dialog rbdineq}}}
{hline}

{title: Decomposition of inequality indices by income components} 

{p 8 10}{cmd:rbdineq}  {it:varlist}  {cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:APPR(}{it:string}{cmd:)}
{cmd:Index(}{it:string}{cmd:)}
{cmd:METHOD(}{it:string}{cmd:)}
{cmd:NOCONSTANT}
{cmd:EPSilon(}{it:real}{cmd:)}
{cmd:THETA(}{it:real}{cmd:)}
{cmd:DREGRES(}{it:int}{cmd:)}
{cmd:DEC(}{it:string}{cmd:)}
 ]
 

{p}where {p_end}
{p 8 8} {cmd:varlist} is a list of variables (income components or income sources). {p_end}


{title:Version} 15.0 and higher.

{title:Description}
{p} The command {cmd:rbdineq} uses the regression-based decomposition approach to decompose inequality indices by income sources. 
The decomposition is performed using the Shapley value or the analytical approach. With the Shapley approach, the user can select among the following inequality indices {p_end}
{p 4 8}{inp:. Gini}{p_end}
{p 4 8}{inp:. Atkinson}{p_end}
{p 4 8}{inp:. Coefficient of variation}{p_end}
{p 4 8}{inp:. Generalized entropy}{p_end}
{title:Options}

{p} With the analytical approach, the user can select among the following inequality indices {p_end}
{p 4 8}{inp:. Gini}{p_end}
{p 4 8}{inp:. Squared coefficient of variation}{p_end}

{title:Options}

{p 0 4} {cmdab:hsize}          Household size. For example, to compute inequality at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:appr}        By default, the Shapley approach  is used. To use the analytical one, select the option appr(analytical). {p_end}

{p 0 4} {cmdab:method}        By default, when a component is missing from a set, we replace it by its mean value. To replace it by zero, select the option method(zero). {p_end}

{p 0 4} {cmdab:index}    To select the inequality index. By default, the Gini index is used.   {p_end}

{p 4 8}{inp:. gini:  Gini}{p_end}
{p 4 8}{inp:. atk :  Atkinson}{p_end}
{p 4 8}{inp:. cvar:  Coefficient of variation}{p_end}
{p 4 8}{inp:. scvar: Squared coefficient of variation}{p_end}
{p 4 8}{inp:. ge  :  Generalized entropy}{p_end}


{p 0 4} {cmdab:epsilon}    To set the Atkinson parameter (epsilon), if this index is selected. By default, theta=0.5.   {p_end}

{p 0 4} {cmdab:theta}      To set the generalized entropy parameter (theta), if this index is selected. By default, alhpha=0.5.   {p_end}

{p 0 4} {cmdab:model}       By default, the linear model specification is used. Select the option model(semilog) for a log linear specification. {p_end}

{p 0 4} {cmdab:noconstant}       Add this option to supress the constant term. {p_end}

{p 0 4} {cmdab:dregres}       Add the option dregres(1) to display the regression results. {p_end}

{p 0 4} {cmdab:dec}          To set the number of decimals used in the display of results. {p_end}

{title:Examples}
sysuse Nigeria_2004I, replace
rbdineq income, indcat(zone sector) indcon(hhsize) model(semilog) hsize(hhsize) noconstant dregres(1)

{title:Reference(s)}
{p 4 4 2} Abdelkrim Araar and Jean-Yves Duclos (2008), {browse "http://dad.ecn.ulaval.ca/pdf_files/shap_dec_aj.pdf" :An algorithm for computing the Shapley Value}, Mimeo, PEP and CIRPEE, Universite Laval. {p_end} 
An algorithm for computing the Shapley Value



{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}
