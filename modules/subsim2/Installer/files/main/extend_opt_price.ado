/*************************************************************************/
/* SUBSIM: Subsidy Simulation Stata Toolkit  (Version 2.0)               */
/*************************************************************************/
/* Conceived by Dr. Araar Abdelkrim[1] and Dr. Paolo Verme[2]            */
/* World Bank Group (2012-2014)		                                 */
/* 									 */
/* [1] email : aabd@ecn.ulaval.ca                                        */
/* [1] Phone : 1 418 656 7507                                            */
/*									 */
/* [2] email : pverme@worldbank.org                                      */
/*************************************************************************/



#delimit ;
capture program drop extend_opt_price;
program define extend_opt_price, rclass;
version 9.2;
syntax anything  [ ,  SN(string)  QU(string) IT(string) IP(string) SU(string) FP(string)   EL(string)  PS(string) ];
local mylist sn qu it ip su fp el ps;
foreach name of local mylist {;
local ret ``name'' ;
return local `name' `ret';
};
end;


