{smcl}
{* August 2021}{...}
{hline}
{hi:DASP : Distributive Analysis Stata Package}{right:{bf:PEP & WIDER}}
help for {hi:ungroup }{right:Dialog box:  {bf:{dialog ungroup}}}
{hline}

{title: Disaggregation of aggregated data} 

{p 8 10}{cmd:ungroup}  {it:varlist}  {cmd:,} [ 
{cmd:NOBS(}{it:int}{cmd:)} 
{cmd:PBOT(}{it:real}{cmd:)}  
{cmd:BNOBS(}{it:int}{cmd:)}
{cmd:PTOP(}{it:real}{cmd:)}
{cmd:TNOBS(}{it:int}{cmd:)} 
{cmd:DIST(}{it:real}{cmd:)} 
{cmd:ADJUST(}{it:int}{cmd:)}
{cmd:LORENZ(}{it:int}{cmd:)}
{cmd:FNAME}{it:string}{cmd:)}
 ]
 

{p}where {p_end}
{p 8 8} {cmd:varlist} is a list of two variables. The first is the vector of percentiles and the second is that of the corresponding income shares. {p_end}

{title:Version} 15.0 and higher.

{title:Description}
{p} The command {cmd:ungroup} generates disaggregated data using information on the aggregated data and on the form of the distribution to be assumed. {p_end}


{title:Options}

{p 0 4} {cmdab:nobs}        The total number of observations of the data to be generated. By default, this number is set to 1000. {p_end}

{p 0 4} {cmdab:pbot}          The percentage of the population that composes the bottom group.   {p_end}

{p 0 4} {cmdab:bnobs}        The number of observations of the bottom group. {p_end}

{p 0 4} {cmdab:ptop}          The percentage of the population that composes the top group.   {p_end}

{p 0 4} {cmdab:tnobs}        The number of observations of the top group. {p_end}

{p 0 4} {cmdab:dist}          The form of the distribution. The user can select among the six following forms: {p_end}
{p 4 6}{inp:1- Log normal (lnorm);} {p_end}
{p 4 6}{inp:2- Normal (norm);} {p_end}
{p 4 6}{inp:3- Uniform (unif);} {p_end}
{p 4 6}{inp:4- Beta Lorenz Curve (belc);} {p_end}
{p 4 6}{inp:5- Generalized Quadratic Lorenz Curve (gqlc);} {p_end}
{p 4 6}{inp:6- Singh-Maddala Distribution (sima).} {p_end}

{p 0 4} {cmdab:adjust}   By default, the generated distribution is adjusted using the Shorrocks and Wan (2008) procedure. To generate the data without such an adjustment, select 0 (adjust(0)). {p_end}

{p 0 4} {cmdab:lorenz}   To plot the Lorenz curves of the aggregated and generated data, use the option: lorenz(1). {p_end}

{p 0 4} {cmdab:fname}   By default, the generated data is saved in the local directory within a datafile named exp_data.dta. The user can choose another directory and/or another name. {p_end}


{title:Examples}
clear all
set obs 10
input p lp
 0.1 0.024152
 0.2 0.060375
 0.3 0.104297
 0.4 0.155698
 0.5 0.214394
 0.6 0.282915
 0.7 0.363893
 0.8 0.464582
 0.9 0.603820
 1.0 1.00000
 ungroup p lp, fname(mydata.dta) lorenz(1)


{title:Reference(s)}


{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos

{title:Reference(s)}
{p 4 4 2} Shorrocks, Anthony & Wan, Guanghua (2008), {browse "http://ideas.repec.org/p/unu/wpaper/rp2008-16.html":Ungrouping Income Distributions: Synthesising Samples for Inequality and Poverty Analysis Creation Date}, Working Papers UNU-WIDER Research Paper , World Institute for Development Economic Research (UNU-WIDER). {p_end} 
{p 4 4 2} Datt, Gaurav, (1998) {browse "http://ideas.repec.org/p/fpr/fcnddp/50.html":Computational tools for poverty measurement and analysis}, FCND discussion paper 50, International Food Policy Research Institute (IFPRI). {p_end} 
{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}
