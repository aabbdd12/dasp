{smcl}
{* June 2018}{...}
{hline}
{hi:mcema : Market Competition and the Extensive Margin Analysis}
help for {hi:mcema }{right:Dialog box:  {bf:{dialog mcema}}}
{hline}
{title:Syntax} 
{p 2 10}{cmd:mcema}  {it:varlist (1 varnames)}  {cmd:,} [ 
{cmd:PRICE(}{it:varname}{cmd:)}  
{cmd:welfare(}{it:varname}{cmd:)}
{cmd:hszie(}{it:varname}{cmd:)}
{cmd:ICHANGE(}{it:varname}{cmd:)} 
{cmd:PCHANGE(}{it:varname}{cmd:)}  
{cmd:INCPAR(}{it:varname}{cmd:)}  
{cmd:HGROUP(}{it:varname}{cmd:)}
{cmd:INDCAT(}{it:varlist}{cmd:)} 
{cmd:INDCON(}{it:varlist}{cmd:)} 
{cmd:PSWP(}{it:real}{cmd:)} 
{cmd:PSWE(}{it:real}{cmd:)} 
{cmd:UM(}{it:int}{cmd:)} 
{cmd:DREG(}{it:int}{cmd:)} 
{cmd:DEC(}{it:int}{cmd:)} 
{cmd:XFIL(}{it:string}{cmd:)} 
{cmd:EXPSHARE(}{it:varname}{cmd:)}
{cmd:EWGR(}{it:varname}{cmd:)}
{cmd:MAPPR(}{it:int}{cmd:)} 
{cmd:GRMOD(}{it:varname}{cmd:)
{cmd:FEX(}{it:int}{cmd:)} 
{cmd:FPR(}{it:int}{cmd:)} 
{cmd:FIN(}{it:int}{cmd:)} 
{cmd:CINDCAT(}{it:varlist}{cmd:)} 
{cmd:CINDCON(}{it:varlist}{cmd:)} 
{cmd:OOPT(}{it:string}{cmd:)} 
INISAVE(string)
]
{p_end}
 {p} where the first component of the {cmd:varlist (min=2 max=2)} is a dummy variable of the household's consumption of the item of interest. The second is the household/individual expenditures on the item of interest.  
{p_end}
{title:Description}
{p} The {cmd:mcema} module is conceived to estimate the change in proportion of users or consumers implied by price changes. Also, it estimates the impact on well-being of the old and new consumers.  
{p_end}

{title:The MCEMA results}  
{p 2 8}{cmd: - List of tables:}{p_end}
{p 4 8}{inp:[01] Table 01: Estimates of the probability of consumption model(s).}{p_end}
{p 4 8}{inp:[02] Table 02: Estimated impact on the proportions of consumers.}{p_end}
{p 4 8}{inp:[03] Table 03: Estimates of the expenditures model.}{p_end}
{p 4 8}{inp:[04] Table 04: Estimated impact on well-being.}{p_end}
 
{title:Sampling design} 
{p} Users should set their surveys' sampling design before using this module(and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned  by default. {p_end}

{title:Version} 14.0 and higher.

{title:Options}

{title:- Probilistic model options:}
{p 3 4} {cmdab:welfare}  welfare variable as the per capita income or the per capita total expenditures. {p_end}
{p 3 4} {cmdab:hsize}   Household size. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling
    weights, best set in survey design). {p_end}
{p 3 4} {cmdab:incpar}      Variable that captures the groups welfare partition, as the decile, the quintile,etc.  {p_end}
{p 3 4} {cmdab:hgroup}      To indicate  groups variable.  {p_end}
{p 3 4} {cmdab:incint}      Select the option incint(1) to indicate the interaction between the household group dummies and the log_welfare variable.  {p_end}
{p 3 4} {cmdab:indcat}      The list of the independent variables that are categorical.  {p_end}
{p 3 4} {cmdab:indcon}      The list of the independent variables that are continues.  {p_end} 
{p 3 4} {cmdab:pswp}        To indicate the significance level criteria for the {it:{help stepwise}} selection of explanatory variables.{p_end} 
{p 3 4} {cmdab:um}          Add the option um(1) to use the coefficient of the first model in prediction of the probabilities. {p_end} 

{title:- Expenditure model options: }
{p 3 4} {cmd:mappr :} to indicate the main approach to estimate the expected expenditures of the potential new users.  {p_end}
{p 6 4} [1] - Add the option mappr(1) if you would like to estimate the expected expenditures of new consumers based on population groups, as the PSUs for instance. {p_end}
{p 6 4} [2] - Add the option mappr(2) if you would like to estimate the expected expenditures of new consumers based on an OLS regression model.{p_end}
{p 3 4} {cmdab:ewgr}     with the option mappr(1), indicate  varname of the population groups to be used. For instance, if the PSU is indicated, the expected expenditures of the new users is equal to the average exenditures within his primary sampling unit.  {p_end}
{p 3 4} {cmdab:fex}      To indicate the functional for of expenditures (dependant variable).  {p_end} 
{p 6 4} [1] - Expenditures {p_end}
{p 6 4} [2] - Log of expenditures.{p_end}
{p 3 4} {cmdab:fpr}      To indicate the functional for of price (dependant variable).  {p_end} 
{p 6 4} [1] - Price {p_end}
{p 6 4} [2] - Log of price.{p_end}
{p 6 4} [3] - Do not use the price variable.{p_end}
{p 3 4} {cmdab:fin}      To indicate the functional for of welfare (dependant variable).  {p_end} 
{p 6 4} [1] - welfare {p_end}
{p 6 4} [2] - Log of welfare.{p_end}
{p 3 4} {cmdab:cindcat}      The list of the independent variables that are categorical.  {p_end}
{p 3 4} {cmdab:cindcon}      The list of the independent variables that are continues.  {p_end} 
{p 3 4} {cmdab:oopt}      To indicate the other(s) options of the regression (ex. oopt(nocons robust) ).    {p_end} 
{p 3 4} {cmdab:pswe}      To indicate the significance level criteria for the {it:{help stepwise}} selection of explanatory variables.{p_end} 
{p 3 4} {cmdab:grmod}      To  estimate the impact on well-being by popolation groups indicated in grmod().{p_end} 

{title:- Results options: }
{p 3 4} {cmd:xfil :}        To indicate  the path and the name of the  excel (*.xml) file to save the results. {p_end}
{p 3 4} {cmd:dec:}          To indicate number of decimals of the displayed results. {p_end}
{p 3 4} {cmd:dreg:}         Add the option dregres(1) to display full results of the estimations. {p_end}

{p 4 8} {cmd:inisave:} To save the mcema dialog box information. Mainly, all inserted information in the dialog box will be save in this file. In another session, the user can open the project using the command mcema_db_ini followed by the name of project. {p_end}

{title:Examples}

{p 4 10 2}
NOTE: All the examples illustrated in the present and in the following sections
      can be run by clicking on the blue hyperlinks.


{title:Example 1:  Using a regression model for the prediction of expenditures on mobile communications. }
{cmd}
#delimit ; 
use http://dasp.ecn.ulaval.ca/welcom/examples/mc/Mexico_2014_Cellphones.dta , replace; 
mcema d_cell pc_exp_cell, mappr(2) welfare(pc_income) hsize(hhsize) hgroup(tam_loc) 
indcat(socio educ) indcon(hhsize) pswp(.05) pchange(pchange) ichange(change_in_income) 
expshare(eshare) ewgr(quintile) um(1) dec(3) fpr(3) fin(2) cindcat(sex educ) cindcon(age) 
inisave(myexp1) xfil(myres1)
;
{txt}      ({stata "welcom_examples ex_mcema_01":example 1: click to run in command window})
{txt}      ({stata "welcom_examples ex_mcema_db_01 ":example 1: click to run in dialog box})


{title:Example 2:  Using average expenditures in PSU's for the prediction of expenditures on mobile communications. }
{cmd}
#delimit ; 
use http://dasp.ecn.ulaval.ca/welcom/examples/mc/Mexico_2014_Cellphones.dta , replace; 
mcema d_cell pc_exp_cell, grmod(psu) welfare(pc_income) hsize(hhsize) hgroup(tam_loc) 
indcat(socio educ) indcon(hhsize) pswp(.05) pchange(pchange) ichange(change_in_income) 
expshare(eshare) ewgr(quintile) um(1) dec(3) inisave(myexp2) xfil(myres2)
;;
{txt}      ({stata "welcom_examples ex_mcema_02":example 2: click to run in command window})
{txt}      ({stata "welcom_examples ex_mcema_db_02 ":example 2: click to run in dialog box})


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}

