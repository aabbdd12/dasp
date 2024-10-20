{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:datest }{right:Dialog box:  {bf:{dialog datest}}}
{hline}

{title: Hypothesis testing} 

{p 8 10}{cmd:datest}  {it:#}  {cmd:,} [ 
{cmd:est(}{it:real}{cmd:)} 
{cmd:ste(}{it:real}{cmd:)} 
{cmd:slevel(}{it:real}{cmd:)}
{cmd:df(}{it:real}{cmd:)} 
{cmd:dist(}{it:string}{cmd:)} 
 ]
 

{p}where {p_end}
{p 8 8} {cmd:#} is the hypothesized value (H0: est = #). {p_end}


{title:Version} 15.0 and higher.

{title:Description}
The command {cmd:datest} performs classical hypothesis testing.



{title:Options}

{p 0 4} {cmdab:est}    Estimated value. {p_end}

{p 0 4} {cmdab:ste}   Standard error of the estimate. {p_end}

{p 0 4} {cmdab:slevel}      To indicate the level of the test in (%). {p_end}

{p 0 4} {cmdab:dist}       By default the asymptotic distribution of the estimator is supposed to be normal. Select the option dist(tstud) for the t-student distribution. {p_end}

{p 0 4} {cmdab:df}       If the t-student distribution is selected, the user can specify its degree of freedom. {p_end}


{title:Examples}
datest 10.4, est(10) ste(0.8) slevel(10)  dgr(1)




{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}
