{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:ipropoop }{right:Dialog box:  {bf:{dialog ipropoor}}}
{hline}

{title: Pro-poor indices} 

{p 8 10}{cmd:difgt}  {it:varlist}  {cmd:,} [ 
{cmd:FILE1(}{it:string}{cmd:)}  
{cmd:FILE2(}{it:string}{cmd:)} 
{cmd:HSIZE1(}{it:string}{cmd:)}  
{cmd:HSIZE2(}{it:string}{cmd:)} 
{cmd:COND1(}{it:string}{cmd:)}  
{cmd:COND2(}{it:string}{cmd:)}  
{cmd:ALpha(}{it:real}{cmd:)}
{cmd:PLINE(}{it:real}{cmd:)} 
{cmd:TYPE(}{it:string}{cmd:)} 
{cmd:LEVEL(}{it:real}{cmd:)}
{cmd:CONF(}{it:string}{cmd:)}
{cmd:DEC(}{it:int}{cmd:)}
]

{p}where {p_end}

{p 8 8} {cmd:varlist} is a list of two variables of interest (variable of interest of the first distribution followed by that of the second distribution).  {p_end}

{title:Version} 15.0 and higher.

{title:Description}
 {p}{cmd:cpropoorp}: To estimate pro-poor indices (see the detailed description below).{p_end}

 
{title:Remarks:}
{p 4 6}{inp:1- Differences between FGT poverty indices}  Users should set their surveys' sampling design before using this module 
 (and to save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default. {p_end}
 {p 4 6}{inp:2- For each of the two distributions, users can use the data file currently in memory or a stored data file.} {p_end}

{title:Options}


{p 0 4} {cmdab:file1}    By default, the file in memory is used for the first distribution. If a stored file is to be used for the first distribution, select it with this option. {p_end}

{p 0 4} {cmdab:file2}    By default, the file in memory is used for the second distribution. If a stored file is to be used for the second distribution, select it with this option. {p_end}

{p 0 4} {cmdab:hsize1}    Household size for the first distribution. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design).{p_end}

{p 0 4} {cmdab:hsize2}    Household size for the second distribution. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:cond1}    To set a logical expression that will capture a socio-demographic group for the first distribution (for example, zone==3). See the help for {help operator}. {p_end}

{p 0 4} {cmdab:cond2}    To set a logical expression that will capture a socio-demographic group for the second distribution (for example, zone==2 & education==5). See the help for {help operator}.{p_end}

{p 0 4} {cmdab:alpha}    To set the FGT parameter (alpha). By default, alpha=0.   {p_end}

{p 0 4} {cmdab:pline}    To set the poverty line. {p_end}

{p 0 4} {cmdab:type}  To estimate non-normalised FGT (non normalised by the poverty line), select the option "not".  {p_end}

{p 0 4} {cmdab:level}     To set the confidence level of the confidence interval to be produced.{p_end}

{p 0 4} {cmdab:conf}     To set the type of confidence interval desired: "ts" for two-sided, "lb" for lower-bounded and "up" for upper-bounded.{p_end}

{p 0 4} {cmdab:dec}   To set the number of decimals used in the display of results. {p_end}





{title:Detailed description:}

Consider a population of individuals, i = 1,...,n, 
with income y_i, and final weight w_i. Let f_i = w_i/N, where 

    i=n
N = SUM(w_i). When the data are unweighted, w_i = 1 and N = n. 
    i=1

Suppose that we have two distributions 1 and 2 and the poverty line is denoted by z. 
The FGT index can be written as follows:  
                        
	                     1    i=n            
	P(X, z, alpha)  =   ---   SUM (f_i)  p_i(x_i, z, alpha) 
	                     n    i=1           
        	                     
p_j(x_i, z, alpha) is the individual poverty function that determines the contribution
of individual i to total poverty P.  	                            
        	                                                     
	                                                               
	p_i(X, z, alpha)  =     ( (z - x_i)/z  )^alpha * I[z > x_i,]

The Watts index of poverty can be written as follows:  

	                     1    i=n            
	W(X, z)         =   ---   SUM (f_i)  w_i(x_i, z, alpha) 
	                     n    i=1  
where

       w_i(x_i, z)      =     ( -log(x_i/z) * I[z > x_i,]

	                         
The three pro-poor indices that are estimated are:   
                               
{title:[1] Chen and Ravallion index (2003)}    

	             W_1(X_1, z) - W_2(X_2, z)             	                                  
	Index1  =   ---------------------------
	                      F_1(z)  

{title:[2] Kakwani & Pernia (2000) index} 

	                 P_1(X_1, z, alpha) - P_2(X_2, z, alpha)             	                                  
	Index2  =  --------------------------------------------------
	            P_1(X_1, z, alpha) - P_1(X_1(mu_1/mu2), z, alpha)  

{title:[3] Kakwani, Khandker and Son (2003) -PEGR- index} 

	                 P_1(X_1, z, alpha) - P_2(X_2, z, alpha)             	                                  
	Index3  = g --------------------------------------------------
	             P_1(X_1, z, alpha) - P_1(X_1(mu_1/mu2), z, alpha) 

where the average growth rate is:

              g = mu_2/mu1 - 1

	                           	                                  
	Index4  =  Index3 - g


{title:Examples}

sysuse bkf94I, replace
save   data94, replace
sysuse bkf98I, replace
save   data98, replace
ipropoor exppc exppc,  pline(40000) file1(data94) hsize1(size)  file2(data98) hsize2(size)

{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos


{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}

