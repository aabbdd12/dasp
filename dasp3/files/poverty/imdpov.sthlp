{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:imdp_cmr }{right:Dialog box:  {bf:{dialog imdpov}}}
{hline}

{title:Multidimensional poverty index} 

{p 8 10}{cmd:imdpov}  {it:varlist}  {cmd:,} [ 
{cmd:HSize(}{it:varname}{cmd:)} 
{cmd:HGroup(}{it:varname}{cmd:)}
{cmd:INDEX(}{it:int}{cmd:)} 
{cmd:NDIMS(}{it:int}{cmd:)}
{cmd:PINFO(}{it:string}{cmd:)}
{cmd:a1(}{it:real}{cmd:)}-{cmd:a10(}{it:real}{cmd:)}
{cmd:b1(}{it:real}{cmd:)}-{cmd:b10(}{it:real}{cmd:)}
{cmd:al1(}{it:real}{cmd:)}-{cmd:al10(}{it:real}{cmd:)}
{cmd:pl1(}{it:real}{cmd:)}-{cmd:pl10(}{it:real}{cmd:)}
{cmd:w1(}{it:real}{cmd:)}-{cmd:w10(}{it:real}{cmd:)}
{cmd:alpha(}{it:real}{cmd:)}
{cmd:gamma(}{it:real}{cmd:)}
{cmd:dcut(}{it:real}{cmd:)}
{cmd:PLV(}{it:varname}{cmd:)} 
{cmd:ALV(}{it:varname}{cmd:)} 
{cmd:AV(}{it:varname}{cmd:)} 
{cmd:BV(}{it:varname}{cmd:)} 
{cmd:LEVEL(}{it:real}{cmd:)}
{cmd:CONF(}{it:string}{cmd:)} 
{cmd:DEC(}{it:int}{cmd:)}
]


 
{p}where {p_end}
{p 8 8} {cmd:varlist} can be is a list of variables (dimensional welfares). {p_end}


{title:Version} 15.0 and higher.

{title:Description}
 {p}{imdpov:Multidimensional Poverty Indices}  Users should set their surveys' sampling design before using this module 
 (and save their data files). If the sampling design is not set, simple-random sampling (SRS) will be automatically assigned 
by default.  {p_end} 

{title:Description} 
{p}{cmd:imdpov}: To estimate one of the following multidimensional poverty indices: {p_end}
 
{p 4 8}{inp:- Chakravarty, Mukherjee, and Ranade (1998) multidimensional poverty index.}{p_end}
{p 4 8}{inp:- Extended Watts Multidimensional Poverty Index.}{p_end}
{p 4 8}{inp:- Multiplicative FGT index.}{p_end}
{p 4 8}{inp:- Tsui_2002 index.}{p_end}
{p 4 8}{inp:- Intersection Multidimensional Poverty Index.}{p_end}
{p 4 8}{inp:- Union Headcount Multidimensional Poverty Index.}{p_end}
{p 4 8}{inp:- Bourguignon and Chakravarty_2003 Multidimensional Poverty Index.}{p_end}
{p 4 8}{inp:- Alkire and Foster (2011) Multidimensional Poverty Index.}{p_end} 


{title:Chakravarty, Mukherjee, and Ranade (1998) multidimensional poverty index} 

{title:Common options:}

{p 0 4} {cmdab:hsize}    Household size. For example, to compute poverty at the individual level, one will want to weight household-level observations by household size (in addition to sampling weights, best set in survey design). {p_end}

{p 0 4} {cmdab:hgroup}   Variable that captures a socio-demographic group. For example, this variable could equal 1 for rural households and 2 for urban ones. When this option is used, the associated varlist should contain only one variable. {p_end}

{p 0 4} {cmdab:index}  To indicate the number of the desired MD poverty index: {p_end}

{p 3 4} {cmdab:1: } Chakravarty, Mukherjee, and Ranade (1998) multidimensional poverty index.}{p_end}
{p 3 4} {cmdab:2: } Extended Watts Multidimensional Poverty Index.}{p_end}
{p 3 4} {cmdab:3: } Multiplicative FGT index.}{p_end}
{p 3 4} {cmdab:4: } Tsui_2002 index.}{p_end}
{p 3 4} {cmdab:5: } Intersection Multidimensional Poverty Index.}{p_end}
{p 3 4} {cmdab:6: } Union Headcount Multidimensional Poverty Index.}{p_end}
{p 3 4} {cmdab:7: } Bourguignon and Chakravarty_2003 Multidimensional Poverty Index.}{p_end}
{p 3 4} {cmdab:8: } Alkire and Foster (2011) Multidimensional Poverty Index.}{p_end} 
{p 0 4} {cmd:poinf: } To indicate the form of information about welfare dimensions (name of variables of dimensions on items, their corresponding parameters, etc). When variables are used to initialise the information, the value must add the option pinfo(vars). {p_end}
{p 4 4} {cmd:NOTES:}   {p_end}
{p 6 9} {cmd:1-}    If the option pinfo(vars) is added, the varlist of the command will contain a string variable. The first value of this variable is the varname of the welfare variable of dimension 1, the second is varname of the welfare variable of dimension 2, and so on. {p_end}
{p 6 9} {cmd:2-}   Also, the parameters of dimensions are indicated by variables: {p_end}
{p 10 4} {cmd:}    - The option plv(varname) instead of pl1() pl2()...pl10(). {p_end}
{p 10 4} {cmd:}    - The option av(varname) instead of a1() a2()...a10().  {p_end}
{p 10 4} {cmd:}    - The option alv(varname) instead of al1() al2()...al10().  {p_end}
{p 10 4} {cmd:}    - The option bv(varname) instead of b1() pl2()...b10().  {p_end}
{p 6 9} {cmd:}         Note that the imdpov supports more that 10 dimensions when the option pinfo(vars) is used. {p_end}
 

{title:Specific options:}
{p 2 4} {cmdab: - Chakravarty, Mukherjee, and Ranade (1998)Index} {p_end}
{p 4 4} {cmdab:a"j"}    Parameters used to estimate the index (see the detailed description below). By default, these parameters are set to 1.  (j is between 2 and 10). {p_end}
{p 4 4} {cmdab:alpha}   Parameter used to  estimate the index   (see the detailed description below).  By default, this parameter is set to 0.   {p_end}
{p 4 4} {cmdab:pl"j"}     Poverty line for the attribute j (j is between 1 and 10). {p_end}

{p 2 4} {cmdab: - Extended Watts index} {p_end}
{p 4 4} {cmdab:a"j"}    Parameters used to estimate the index (see the detailed description below). By default, these parameters are set to 1.  (j is between 2 and 10). {p_end}
{p 4 4} {cmdab:pl"j"}     Poverty line for the attribute j (j is between 1 and 10). {p_end}

{p 2 4} {cmdab: - Multiplicative FGT Index} {p_end}
{p 4 4} {cmdab:al"j"}     Parameters used to estimate the index (see the detailed description below). By default, these parameters are set to 0.  (j is between 1 and 10). {p_end}
{p 4 4} {cmdab:pl"j"}     Poverty line for the attribute j (j is between 1 and 10). {p_end}

{p 2 4} {cmdab: - Tsui (2002) Index} {p_end}
{p 4 4} {cmdab:b"j"}     Parameters used to this index (see the detailed description below). By default, these parameters are set to 1.  (j is between 1 and 10). {p_end}
{p 4 4} {cmdab:pl"j"}     Poverty line for the attribute j (j is between 1 and 10). {p_end}

{p 2 4} {cmdab: - Intersection Headcount Index} {p_end}
{p 4 4} {cmdab:alpha}   Parameter used to estimate the index (see the detailed description below).  By default, this parameter is set to 0.   {p_end}
{p 4 4} {cmdab:pl"j"}     Poverty line for the attribute j (j is between 1 and 6). {p_end}

{p 2 4} {cmdab: - Union Headcount Index} {p_end}
{p 4 4} {cmdab:alpha}   Parameter used to estimate the index (see the detailed description below).  By default, this parameter is set to 0.   {p_end}
{p 4 4} {cmdab:pl"j"}     Poverty line for the attribute j (j is between 1 and 6). {p_end}


{p 2 4} {cmdab: - Bourguignon and Chakravarty_2003 Index} {p_end}
{p 4 4} {cmdab:alpha}   Parameter used to estimate the index (see the detailed description below).  By default, this parameter is set to 0.   {p_end}
{p 4 4} {cmdab:gamma}   Parameter used to estimate  the index  (see the detailed description below).  By default, this parameter is set to 1.   {p_end}
{p 4 4} {cmdab:pl"j"}     Poverty line for the attribute j (j is between 1 and 10). {p_end}
{p 4 4} {cmdab:b"j"}     the parameter beta of the dimension j (j is between 1 and 10). {p_end}


{p 2 4} {cmdab: -  Alkire and Foster (2011)  Index} {p_end}
{p 4 4} {cmdab:w"j"}    Weight parameters used to estimate the index [8] (see the detailed description below). By default, these parameters are set to 1.  (j is between 1 and 6). {p_end}
{p 4 4} {cmdab:dcut}    Parameter used to estimate index [8] (see the detailed description below).  By default, this parameter is set to 0.5.   {p_end}
{p 4 4} {cmdab:pl"j"}     Poverty line for the attribute j (j is between 1 and 6). {p_end}

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


{title:1- Chakravarty et al (1998) index}   	                            
         
	                 K                                         

	p(X_i, z)  =    SUM a_j ( (z_j - x_i,j) / z_j )^alpha

	                j=1   
					
{title:2- Extended Watts index} 

	                K                                         

	p(X_i, z)  =   SUM a_j ln ( z_j/ min(z_j ; x_i,j))     

	               j=1                                        
					
 
{title:3- Multiplicative FGT index} 

	                 K                                         

	p(X_i, z)  =    PRO  ( (z_j - x_i,j) / z_j )_+^al_j

	                j=1

					
{title:4- Tsui (2002) index} 

	                 K                                         

	p(X_i, z)  =    PRO  ( z_j/ min(z_j ; x_i,j))^b_j - 1

	                j=1
					

{title:5- Intersection  Index} 

	                K                                         

	p(X_i, z)  =    PRO  I( z_j>x_i,j)

	                j=1
					
{title:6- Union  Index} 

	                        K                                         

	p(X_i, z) =1 - PRO  I( z_j<x_i,j))

	                       j=1
					
{title:7- Bourguignon and Chakravarty (2003)  Index} 

                      _           _ 
                
  p(X_i, z)  = SUM_j |  b_j* C_j,i | ^[alpha/gamma]

                      -           - 
where:

       C_j,i = ( (z_j - x_i,j)/z_j )_+^gamma  
	   
	   
{title:8- Alkire and Foster (2011) Index}   	                            

        	                                                     
	                K                                                          K                                        

	p(X_i, z)  =    SUM w_j ( (z_j - x_i,j) / z_j )^alpha * I(i is poor)  /   SUM w_j

	                j=1         					           j=1                               	                                              
	where 

        I(i is poor) = 1 if SUM_j w_j I(z_j > x_i,j)   > dcut and zero otherwise; dcut refers to a dimensional cutoff. 	   
	   

{title:Authors}
Abdelkrim Araar
Jean-Yves Duclos

        



{title:Contact}
If you note any problems, please contact {bf:Abdelkrim Araar:} {browse "mailto:aabd@ecn.ulaval.ca"}	                          
