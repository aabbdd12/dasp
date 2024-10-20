{smcl}
{* August 2019}{...}
{hline}
{hi:SHEXP : Sharing Household EXPenditure model}{right:{bf: PEP}}
{hline}


{p 1 10}Syntax:  {cmd: shexp}  {it:varname} {cmd:,} [ 
{cmd:TOTPUB(}{it:varname}{cmd:)} 
{cmd:EXPEXM(}{it:varname}{cmd:)} 
{cmd:EXPEXF(}{it:varname}{cmd:)} 
{cmd:EXPEXK(}{it:varname}{cmd:)} 
{cmd:FSHARE(}{it:varname}{cmd:)} 
{cmd:VLIST(}{it:varlist}{cmd:)}
{cmd:ILIST(}{it:varlist}{cmd:)}
{cmd:LIENGM(}{it:varlist}{cmd:)}
{cmd:LIENGF(}{it:varlist}{cmd:)}
{cmd:LIENGK(}{it:varlist}{cmd:)}
{cmd:NKID(}{it:varname}{cmd:)}
{cmd:AVAGEK(}{it:varname}{cmd:)}
{cmd:NFEMALE(}{it:varname}{cmd:)}
{cmd:AVAGEF(}{it:varname}{cmd:)}
{cmd:NMALE(}{it:varname}{cmd:)}
{cmd:AVAGEM(}{it:varname}{cmd:)}
{cmd:NBOYS(}{it:varname}{cmd:)}
{cmd:OTHERV(}{it:varlist}{cmd:)}
{cmd:COLMOD(}{it:int}{cmd:)}
{cmd:TYMOD(}{it:int}{cmd:)}
{cmd:XFIL(}{it:string}{cmd:)}
{cmd:DEC(}{it:int}{cmd:)} 
{cmd:DREGRES(}{it:int}{cmd:)} 
{cmd:INISAVE(}{it:string}{cmd:)}  
]
{p_end}

{p 1 8} {cmd:varlist} should contains the varname of the household total expenditures). {p_end}

{p 1 8}Required version(s) : Stata 15.0 and higher / R version 3.60 and higher. {p_end}

{title:Description}
 {p}{cmd:SHEXP}  This module can be used to estimate the sharing household expenditure model, based on the approches developpebd by Bargain, O. , Lacroix, G. and L. Tiberti (2019). 
 It task is to prepare the data, to produce the R script, and then, to use intermediatelly the easi R package to estimate the model. In addition, for the non-prametric quadratic module specification, it
 displays the following results: {p_end}
 
{title:The SHEXP results}  
{p 2 8}{cmd: - List of tables:}{p_end}
{p 4 8}{inp:[01] Table 01: Sharing Rule Coeficients and theirs T-students. }{p_end}
{p 4 8}{inp:[02] Table 02: Poverty comparision: In progres.}{p_end}


{title:Options ((*) required (#) for the next version)}

{p 2 2} {cmd:Household and individual expenditures:}{p_end}
{p 4 8} {cmd:expexm:*} To indicate the male expenditure on the exclusive good. {p_end}
{p 4 8} {cmd:expexf:*} To indicate the female expenditure on the exclusive good. {p_end}
{p 4 8} {cmd:expexk:*} To indicate the kids expenditure on the exclusive good. {p_end}
{p 4 8} {cmd:fshare:*} To indicate the women's share in childless couples. {p_end}



{p 2 2} {cmd:Specification of the first model of total expenditures:}{p_end}
{p 4 8} {cmd:vlist:*} To indicate the list of variables for the estimation of the first model of total expenditures. {p_end}
{p 4 8} {cmd:ilist:} To indicate the list of instrumental variables for the estimation of the first model of total expenditures. {p_end}

{p 2 2} {cmd:Individual Engel curve specification:}{p_end}
{p 4 8} {cmd:liengm:*} To indicate the list of variables for the estimation of the demand model of male on the exlusif good. {p_end}
{p 4 8} {cmd:liengf:*} To indicate the list of variables for the estimation of the demand model of female on the exlusif good. {p_end}
{p 4 8} {cmd:liengk:*} To indicate the list of variables for the estimation of the demand model of fids on the exlusif good. {p_end}
{p 4 8} {cmd:engmod:}  Functional form (#): {p_end}
{p 6 8} {cmd:1-} Log  {p_end}
{p 6 8} {cmd:2-} Quadratic in log  {p_end}

{p 2 2} {cmd:Variables of the sharing rule specification:}{p_end}
{p 4 8} {cmd:nkids*:} To indicate the number of kids. {p_end}
{p 4 8} {cmd:nboys*:} To indicate the number of boys. {p_end}
{p 4 8} {cmd:nfemale*:} To indicate the number of females. {p_end}
{p 4 8} {cmd:nmale*:}  To indicate the number of males. {p_end}
{p 4 8} {cmd:avagek*:} To indicate the average age of kids. {p_end}
{p 4 8} {cmd:avagem*:} To indicate the average age of males. {p_end}
{p 4 8} {cmd:avagef*:} To indicate the average age of females. {p_end}
{p 4 8} {cmd:otherv:}  To indicate the varlist of the remaining variables. {p_end}

{p 4 8} {cmd:inisave:} To save the easi dialog box information. Mainly, all inserted information in the dialogue box will be save in this file. In another session, the user can open the project using the command easi_db_ini followed by the name of project. {p_end}
{p 4 8} {cmdab:dec}     To set the number of decimals used in the display of results. {p_end}


{p 4 8} {cmd:COLMOD(}{it:int}{cmd: To indicate the type of the colletive model (#))}{p_end}
{p 6 8} {cmd:1-} Complete model  {p_end}
{p 6 8} {cmd:2-} Rothbarth model {p_end}

{p 4 8} {cmd:TYMOD(}{it:int}{cmd: To indicate the type of identification)}{p_end}
{p 6 8} {cmd:1-} Nonparametric  {p_end}
{p 6 8} {cmd:2-} Dunbar et al (1).  {p_end}
{p 6 8} {cmd:3-} Dunbar et al (2).  {p_end}

{p 0 6} {cmd:xfil}   To indicate the name of Excel file, that will be used to save the results (*.xml format). {p_end}


{title:Examples}

{p 4 10 2}
NOTE: All the examples illustrated in the present and in the following sections
      can be run by clicking on the blue hyperlinks.

{title:Example 1:}
{cmd}
#delimit ; 
use http://dasp.ecn.ulaval.ca/shexp/examples/fdata.dta , replace; 
shexp totexp , 
expexm(excl_m) expexf(excl_f) expexk(excl_k) 
fshare(f_share)   
vlist(age edu  iwshare  urban nuclear) 
ilist(lind) 
liengf(agem2 urban nuclear) 
liengm(agem1 urban nuclear) 
liengk(nkid m_age  cwprice avage  urban  nuclear) 
nkid(nkid) 
avagek(avage) 
nboys(nboys)
otherv(iwshare urban  nuclear) 
colmod(1) tymod(1)  
inisave(mycexample) 
xfil(myres.xml)
;
{txt}      ({stata "shexp_examples ex_shexp_01":example 1: click to run in command window})
{txt}      ({stata "shexp_examples ex_shexp_db_01 ":example 1: click to run in dialog box})




{title:Author(s)}
Abdelkrim Araar and Luca Tiberti


{title:Reference(s)}
{p 4 8} • Olivier Bargain, Guy Lacroix and Luca Tiberti,(2019). Intra-household Allocation and Individual Poverty: An Assessment of Collective Models using Direct Evidence on Sharing".{p_end}

{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}
