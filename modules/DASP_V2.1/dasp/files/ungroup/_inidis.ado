/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 1.5  )          */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2010)          */
/* Université Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : _inidis                                                     */
/*************************************************************************/

#delim;
cap program drop _inidis;
program define _inidis;
version 9.2;
syntax varlist(min=4 max=4)[,  nclass(int 1) dist(string) ];

tokenize `varlist';

cap drop _y;

/*******LOG NORMAL DISTRBUTION         *******/
local nclass_1 = `nclass' - 1;

if ("`dist'"=="lnorm") {;
tempvar  zF;
tempvar      sig_k; 
qui gen     `sig_k'=.;
qui replace `sig_k'= invnormal(`1'[_n])-invnormal(`2'[_n])    in 1/`nclass_1';
qui sum     `sig_k' in 1/`nclass_1', meanonly; 
local        sig   = `r(mean)';
qui      gen `zF'  = invnorm(`3');
qui      gen _y   = exp(`zF'*`sig');
};

/*******NORMAL DISTRBUTION         *******/
local nclass_1 = `nclass' - 1;

if ("`dist'"=="norm") {;
tempvar  zF;
tempvar      sig_k; 
qui gen     `sig_k'=.;
qui replace `sig_k'= invnormal(`1'[_n])-invnormal(`2'[_n])    in 1/`nclass_1';
qui sum     `sig_k' in 1/`nclass_1', meanonly; 
local        sig   = `r(mean)';
qui      gen `zF'  = invnorm(`3');
qui      gen _y   =  `zF'*`sig';
qui     sum _y;
qui     replace _y   =  _y+abs(`r(min)');
};

/*******GENERALIZED QUADRATIC LORENZ CURVE ******/
if ("`dist'"=="gqlc") {;
tempvar dep aa bb cc;
qui gen `dep' = `2'*(1-`2');
qui gen `aa'  = (`1'^2-`2');
qui gen `bb'  = `2'*(`1'-1);
qui gen `cc'  = `1'-`2';
qui regress `dep' `aa' `bb' `cc' in 1/`nclass', noconstant;
tempname g;  matrix `g'= e(b);
local a=`g'[1,1]; 
local b=`g'[1,2]; 
local c=`g'[1,3]; 
local e=(`a'+`b'+`c'+1);
local m=`b'^2-4*`a';
local n=-2*`b'*`e'-4*`c';    
qui gen _y = - `b'/2 - (2*`m'*`3' + `n')/(4*(`m'*`3'^2+`n'*`3'+ `e'^2)^0.5) ;
qui count if _y!=.;

if (`r(N)'==0) {;
        di in r "The selected distribution is not consistant with the aggregated data.";
        di in r "Select another distribution.";
	  exit 198;
exit;
};


};


/************** BETA LORENZ CURVE ************/
if ("`dist'"=="belc") {;
tempvar dep gg dd;
qui gen `dep' = log(`1'-`2');
qui gen `gg'  = log(`1');
qui gen `dd'  = log(1-`1');
qui regress `dep' `gg' `dd' in 1/`nclass';
tempname c;  matrix `c'= e(b);
local gam=    `c'[1,1]; 
local del=    `c'[1,2]; 
local tet=exp(`c'[1,3]);
qui gen _y = 1 - `tet'*`3'^`gam'*(1-`3')^`del'*(`gam'/`3' - `del'/(1-`3')) ;
qui count if _y!=.;

if (`r(N)'==0) {;
        di in r "The selected distribution is not consistant with the aggregated data.";
        di in r "Select another distribution.";
	  exit 198;
exit;
};
};

/************** UNIFORM DISTRIBUTION     ************/
if ("`dist'"=="unif") {;
qui gen _y = `3';
};


/************** SING & MADDALA (1976) DISTRIBUTION   ************/
if ("`dist'"=="sima") {;
	tempvar       twe;    qui gen `twe'=.;
	qui replace  `twe' = `1'[1]             in 1;
	qui replace  `twe' = `1'[_n]-`1'[_n-1]  in 2/`nclass';

	tempvar       trueMu_k; qui gen      `trueMu_k'=.;
	qui replace  `trueMu_k' = (`2'[1])/(`1'[1])                                in 1;
	qui replace  `trueMu_k' = (`2'[_n]-`2'[_n-1])/(`1'[_n]-`1'[_n-1]) in 2/`nclass';

      global Sima "`trueMu_k'";
      ml model lf _sima (a: `avar') (b: `bvar')  (q: `qvar')  [aw=`twe'] in 1/`nclass', maximize  ; 
	tempname c; matrix `c' = e(b); 
	local a = `c'[1,1]; local b = `c'[1,2]; local q = `c'[1,3];
      qui gen _y = `b' * ( (1-`3')^(-1/`q') - 1 )^(1/`a');
};

qui sum  _y [aw=`4'], meanonly;
qui replace _y = _y/`r(mean)';
end;





