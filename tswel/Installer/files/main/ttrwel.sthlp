{smcl}
{* June 2018}{...}
{hline}
{hi:TTRWEL : Tobacco Tax Reforms and WELl-being}
help for {hi:ttrwel }{right:Dialog box:  {bf:{dialog ttrwel}}}
{hline}
{title:Syntax} 
{p 8 10}{cmd:ttrwel}  {it:varlist (2 varnames)}  {cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:DECILE(}{it:varname}{cmd:)}  
{cmd:XFIL(}{it:string}{cmd:)} 
{cmd:FOLGR(}{it:string}{cmd:)}
{cmd:INISAVE(}{it:string}{cmd:)}  
{cmd:TJOBS(}{it:string}{cmd:)} 
{cmd:GJOBS(}{it:string}{cmd:)} 
{cmd:OPGRk: k:1...4:(}{it:Syntax }{cmd:)} 
{cmd:MIN(}{it:string}{cmd:)} 
{cmd:MAX(}{it:string}{cmd:)} 
{cmd:OGR(}{it:string}{cmd:)} 
{cmd:FELAS(}{it:string}{cmd:)} 
{cmd:ELASM(}{it:string}{cmd:)} 
{cmd:ELASL(}{it:string}{cmd:)} 
{cmd:ELASU(=(}{it:string}{cmd:)} 
{cmd:MEDEXP(}{it:real}{cmd:)} 
{cmd:TWYL(}{it:real}{cmd:)} 
{cmd:PRINC(}{it:real}{cmd:)} 
{cmd:DEC(}{it:int}{cmd:)} 
{cmd:STE(}{it:int}{cmd:)} 
]
 {p_end}
 {p} where  {p_end}
{p 8 8} {cmd:varlist (min=2 max=2)} The total household expenditures and the household expenditures on tobacco.{p_end}

{title:Description}
{p} The {cmd:ttrwel} module is conceived to automate the estimation the results of the tobacco tax reforms on social welfare based on the methods of Fuchs & Meneses  (2017).
the results are reported by deciles. 
{p_end}
 
{title:Sampling design} 
 {p} Users should set their surveys' sampling design before using this module 
 (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default. {p_end}

{title:The ttrwel results}  
{p} The following lists shows the produces tables and graphs:{p_end}

{p 2 8}{cmd:List of tables:}{p_end}
{p 4 8}{inp:[01] Table 10: Price elasticities)}{p_end} 

{p 4 8}{inp:[02] Table 20: Population and expenditures}{p_end} 

{p 4 8}{inp:[03] Table 30: Price increase (summary estimate in %) }{p_end}
{p 4 8}{inp:[04] Table 31: Price increase (passt estimate in %)}{p_end}
{p 4 8}{inp:[05] Table 32: Price increase (lower estimate in %)}{p_end}
{p 4 8}{inp:[06] Table 33: Price increase (medium estimate in %)}{p_end}
{p 4 8}{inp:[07] Table 34: Price increase (upper estimate in %)}{p_end}

{p 4 8}{inp:[08] Table 40: Medical expenses (summary estimate in %)}{p_end}
{p 4 8}{inp:[09] Table 41: Medical expenses (lower estimate in %)}{p_end}
{p 4 8}{inp:[10] Table 42: Medical expenses (medium estimate in %)}{p_end}
{p 4 8}{inp:[11] Table 43: Medical expenses (upper estimate in %)}{p_end}

{p 4 8}{inp:[12] Table 50: Life lost (summary estimate in %)}{p_end}
{p 4 8}{inp:[13] Table 51: Life lost (lower estimate in %)}{p_end}
{p 4 8}{inp:[14] Table 52: Life lost (medium estimate in %)}{p_end}
{p 4 8}{inp:[15] Table 53: Life lost (upper estimate in %)}{p_end}

{p 4 8}{inp:[16] Table 60: Total net loss (summary estimate in %)}{p_end}
{p 4 8}{inp:[17] Table 61: Total net loss (lower estimate in %)}{p_end}
{p 4 8}{inp:[18] Table 62: Total net loss (medium estimate in %)}{p_end}
{p 4 8}{inp:[19] Table 63: Total net loss (upper estimate in %)}{p_end}


{p 2 8}{cmd:List of graphs:}{p_end}
{p 4 8}{inp:[01] Figure 01: Income Gains: Direct Effect of Taxes}{p_end}
{p 4 8}{inp:[02] Figure 02: Income Gains: Medical Costs of Tobacco Taxes}{p_end}
{p 4 8}{inp:[03] Figure 03: Income Gains: Life lost}{p_end}
{p 4 8}{inp:[04] Figure 04: Total Income Effect: Direct and Indirect Effect of Taxes}{p_end}


{title:Version} 14.0 and higher.

{title:Options}

{p 0 4} {cmdab:hsize}        Household size. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:decile}       Variable that captures the decile groups.  {p_end}



{p 0 6} {cmd:xfil}   To indicate the name of Excel file, that will be used to save the results (*.xml format). {p_end}
{p 0 6} {cmd:folgr}   To indicate the name the folder in which the graph results will be saved. {p_end}
{p 0 6} {cmd:inisave:}    To save the TTRWEL project information. Mainly, all inserted information in the dialogue box will be save in this file. In another session, the user can open the project using the command asubini followed by the name of project. This command will initialise all of the information of the aTTRWEL dialog box. {p_end}


{p 0 6} {cmd:tjobs:}    You may want to produce only a subset of tables. In such case, you have to select the desired tables by indicating their codes with the option tjobs. 
For instance: tjops(1 2) . See also: {bf:{help jtables_ttr}}. {p_end}

{p 0 6} {cmd:gjobs:}    You may want to produce only a subset of graphs. In such case, you have to select the desired graphs by indicating their codes with the option gjobs. 
For instance: gjops(1 2) . See also: {bf:{help jgraphs_ttr}}. {p_end}

{p 0 6} {cmd:opgr{cmd:g} and g:1...4::}    Inserting options of graph g by using the following syntax: {p_end}
{p 6 12} {cmd:min:}    To indicate the minimum of the range of x-Axis of figure k. {p_end}
{p 6 12} {cmd:max:}    To indicate the maximum of the range of x-Axis of figure k. {p_end}
{p 6 12} {cmd:opt:}    To indicate additional twoway graph options of figure k. {p_end}
{phang}
{it:twoway_options} are any of the options documented in 
{it:{help twoway_options}}.  These include options for titling the graph 
(see {it:{help title_options}}), options for saving the graph to disk (see 
{it:{help saving_option}}), and the {opt by()} option (see 
{it:{help by_option}}).

{p 6 12} {cmd:felas:}    To indicate  the path and the name of the Stata data file that contains the elasticities by deciles. {p_end}
{p 6 12} {cmd:elasm:}    To indicate name of the variable of the medium elasticity. {p_end}
{p 6 12} {cmd:elasl:}    To indicate name of the variable of the lower elasticity. {p_end}
{p 6 12} {cmd:elasu:}    To indicate name of the variable of the upper elasticity. {p_end}
{p 6 12} {cmd:mexexp:}   To indicate the total population medical expenditures on the tobacco illnesses. {p_end}
{p 6 12} {cmd:tyll:}     To indicate the total years of life lost due to tobacco consumption at population level. {p_end}
{p 6 12} {cmd:princ:}    To indicate the price increase of the simulated tobacco tax reform. {p_end}
{p 6 12} {cmd:dec:}    To indicate number of decimals of the displayed results. {p_end}
{p 6 12} {cmd:ste:}    Add the option ste(0) to do not display the tables with the standard erors. {p_end}


{title:Example(s):}
ttrwel rhexp rs_exp_cigarettes, hsize(member)  decile(decile) ///
inisave(C:\example\myproj)  felas(C:\example\data\elas_banglad.dta) ///
elasm(elas_m) elasl(elas_l) elasu(elas_u) medexp(5729166666.666667) twyl(3288506) princ(.25) ///
xfil(C:\example\results\myres.xml)  dec(6) ste(1)  folgr(C:\example\results\)
 
{title:Author(s)}
Abdelkrim Araar and Alan Fuchs Tarlovsky.  

{title:Reference(s)}  
Fuchs Tarlovsky,Alan & Meneses,Francisco Jalles, 2017. "Are tobacco taxes really regressive ? evidence from Chile,"
Policy Research Working Paper Series 7988, The World Bank.

{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}











