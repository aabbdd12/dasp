{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:dmdafs }{right:Dialog box:  {bf:{dialog dmdafs}}}
{hline}

{title:Decomposition of the Alkire and Foster (2011) Multidimensional Poverty Index by Dimensions using the Shapley Approach} 
{p 8 10}{cmd:dmdafs}  {it:varlist}  {cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:HGroup(}{it:varname}{cmd:)} 
{cmd:w1(}{it:real}{cmd:)}-{cmd:w6(}{it:real}{cmd:)}
{cmd:pl1(}{it:real}{cmd:)}-{cmd:pl6(}{it:real}{cmd:)} 
{cmd:dcut(}{it:real}{cmd:)}
{cmd:CONF(}{it:string}{cmd:)} 
{cmd:XFIL(}{it:string}{cmd:)}
{cmd:MODREP(}{it:string}{cmd:)}
]
 

{p}where {p_end}
{p 8 8} {cmd:varlist} is a list of variables. {p_end}


{title:Version} 15.0 and higher.

{title:Description}
 {p}{cmd:Decomposition of the Alkire and Foster (2011) Multidimensional Poverty Index}  Users should set their surveys' sampling design before using this module 
 (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default. 




{title:Options} 

{p 2 4} {cmdab:hsize}    Household size. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 2 4} {cmdab:hgroup}   Variable that captures a socio-demographic group. For example, this variable could equal 1 for rural households and 2 for urban ones. When this option is used, the associated varlist should contain only one variable. {p_end}


{p 2 4} {cmdab:w"j"}    Weight parameters used to estimate the index [8] (see the detailed description below). By default, these parameters are set to 1.  (j is between 1 and 6). {p_end}

{p 2 4} {cmdab:dcut}    Parameter used to estimate index [8] (see the detailed description below).  By default, this parameter is set to 0.5.   {p_end}

{p 2 4} {cmdab:pl"j"}     Poverty line for the attribute j (j is between 1 and 6). {p_end}

{p 2 4} {cmdab:level}    To set the confidence level of the confidence interval to be produced. {p_end}

{p 2 4} {cmdab:conf}     To set the type of confidence interval desired: "ts" for two-sided, "lb" for lower-bounded and "up" for upper-bounded.{p_end}

{p 2 4} {cmdab:dec}      To set the number of decimals used in the display of results. {p_end}

{p 2 8} {cmd:xfil}   To indicate the name of the Excel file, that will be used to save the results . {p_end}

{p 2 8} {cmd:xtit}   To indicate the name of the table of the Excel file. {p_end}

{p 2 8} {cmd:modrep}   Add the option modrep(modify) to modify the Excel file instead of replacing it. {p_end}


{title:Detailed description:}

Consider a population of individuals , i = 1,...,n, 
with income y_i, and sampling weight w_i. Let f_i = w_i/N, where 
    i=n
N = SUM(w_i). When the data are unweighted, w_i = 1 and N = n. 
    i=1

Suppose that j = 1,...,K, denotes the j_ith dimension of poverty 
and z_j denotes the poverty line for dimension j. A general form 
for additive multidimensional poverty indices can be written as: 
                	                            
        	                          
	             1    i=n            
	P(X,z)  =   ---   SUM (f_i)  p(X_i, z) 
	             n    i=1           
        	                     
p(X_i, z) is the individual poverty function that determines the contribution of individual i to total poverty P.  



	                

{title:Alkire and Foster (2011) index}   	                            

        	                                                     

	                K                                                          K                                        

	p(X_i, z)  =    SUM w_j ( (z_j - x_i,j) / z_j )^alpha * I(i is poor)  /   SUM w_j

	                j=1         					           j=1                               	                                              
	where 

        I(i is poor) = 1 if SUM_j w_j I(z_j > x_i,j)   > dcut and zero otherwise and dcut refers to a dimensional cutoff. 


{title:Example:}
sysuse targeting.dta, replace
dmdafs tot98eq haz, dcut(0.5) pl1(1790) pl2(8)		

{title:Authors}

Abdelkrim Araar

Jean-Yves Duclos

        



{title:Contact}

If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}	                          