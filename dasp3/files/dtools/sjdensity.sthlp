{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:sjdensity}{right:Dialog box:  {bf:{dialog sjdensity}}}
{hline}

{title:Joint density surface}

{p 8 12}{cmd:sjdensity}  {it:varlist}{cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:HGroup(}{it:varname}{cmd:)} 
{cmd:NGroup(}{it:int}{cmd:)}
{cmd:BAND1(}{it:real}{cmd:)}
{cmd:BAND2(}{it:real}{cmd:)}
{cmd:MIN1(}{it:real}{cmd:)} 
{cmd:MAX1(}{it:real}{cmd:)} 
{cmd:PAR1(}{it:real}{cmd:)} 
{cmd:MIN2(}{it:real}{cmd:)} 
{cmd:MAX2(}{it:real}{cmd:)} 
{cmd:PAR2(}{it:real}{cmd:)} 
{cmd:LRES(}{it:int}{cmd:)} 
{cmd:SRES(}{it:string}{cmd:)} 
{cmd:SRESG(}{it:string}{cmd:)} 
{cmd:LAB1(}{it:real}{cmd:)}
{cmd:LAB2(}{it:real}{cmd:)}
{cmd:TITLE(}{it:real}{cmd:)}
{cmd:SGEMF(}{it:real}{cmd:)}
]
 
 
{p} where {cmd:varlist} is a list of the two variables of interest (X,Y). {p_end}

{title:Version} 15.0 and higher.

{title:Description}
 
 {p}{cmd:sjdensity} produces a bidimensional joint density in the form of a surface. The Gaussian kernel approach is used to estimate that density.{p_end}

{title:Options}
 
{p 0 4} {cmdab:hsize}    Household size. For example, if the population of interest is the population of individuals, one should weight household observations by household size.{p_end}
  
{p 0 4} {cmdab:hgroup}   Variable that conditions the analysis on a socio-demographic group. For example, this variable could equal 1 for rural households and 2 for urban ones. When this option is used, the associated varlist should contain only one variable. {p_end}

{p 0 4} {cmdab:ngroup}   Identification number of the group to select. {p_end}
 
{p 0 4} {cmdab:band1}    To indicate the desired bandwidth for the variable X.  (By default, an "optimal" bandwidth is used (see for instance Silverman (1986)). {p_end}

{p 0 4} {cmdab:band2}    To indicate the desired bandwidth for the variable Y.  (By default, an "optimal" bandwidth is used (see for instance Silverman (1986)). {p_end}

{p 0 4} {cmdab:min1}      The minimum value of the range of the X-axis. {p_end}
 
{p 0 4} {cmdab:max1}      The maximum value of the range of the X-axis. {p_end}

{p 0 4} {cmdab:par1}      The number of partitions of the range of the X-axis (an integer). {p_end}

{p 0 4} {cmdab:min2}      The minimum value of the range of the Y-axis. {p_end}
 
{p 0 4} {cmdab:max2}      The maximum value of the range of the Y-axis. {p_end}

{p 0 4} {cmdab:par2}      The number of partitions of the range of the Y-axis (an integer). {p_end}

{p 0 4} {cmdab:lab1}    To indicate the label for dimension 1. {p_end}

{p 0 4} {cmdab:lab2}    To indicate the label for dimension 2.{p_end}

{p 0 4} {cmdab:title}    To indicate the main title for the graph.{p_end}
 
{p 0 4} {cmdab:lres}      If option "1" is selected, the coordinates of the curves are listed. {p_end}

{p 0 4} {cmdab:sres}    To save the coordinates of the curves in a Stata file, indicate the name of that file using this option. {p_end}

{p 0 4} {cmdab:sresg}    To save the coordinates of the curves in a GnuPlot-ASCII file, indicate the name of that file using this option. {p_end}

{p 0 4} {cmdab:sgemf}    To save the graph in *.emf format. This format can be easily inserted in Word documents. To do this, select in Word the mainmenu Insert->Picture-> From file. {p_end}

{title:Remark}

The user has to initialise the sampling weight with the command {help svyset} before using this module to take into account this weight in the estimation of the results.

{title:Examples}
sysuse can6, replace 
sjdensity X N, max1(40000) par1(40) max2(40000) par2(40)


{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}
