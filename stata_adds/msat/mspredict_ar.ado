*! version 2.0.0  28jun2005 M. Lokshin, Z. Sajaia
*! updated by Araar Abdelkrim to estimate the ATT and ATE based on Fugile and Bosch (1995) approach
#delim ;
cap program drop mspredict_ar;
program define mspredict_ar, rclass;
	version 8;
	syntax anything   [if] [in] [, PSel xb1 xb2 yc1_1 yc2_1 yc1_2 yc2_2 mills1 mills2 at];

	marksample touse;

	syntax newvarname [if] [in] [, PSel xb1 xb2 yc1_1 yc2_1 yc1_2 yc2_2 mills1 mills2 at];

	if ("`e(cmd)'" ~= "movestay") error 301;
	local check "`psel' `xb1' `xb2' `yc1_1' `yc2_1' `yc1_2' `yc2_2' `mills1' `mills2' `at'" ;
	if (wordcount("`check'")>1)  {;
		disp as error "Only one statistic is allowed" ;
		exit 198;
	};
	local nooptions = (wordcount("`check'")==0);

	/*quietly {;*/

	local y_reg1: word 1 of `e(depvar)';
	local y_reg2: word 2 of `e(depvar)';
	local y_prob: word 3 of `e(depvar)';
	
	tempname b TMP sigma1 sigma2 rho1 rho2 reg1 reg2 prob;
	matrix `b'   = e(b);
	matrix `TMP' = `b'[1,"lns0:_cons"];  // modified
	scalar `sigma1' = exp(`TMP'[1,1]);
	matrix `TMP' = `b'[1,"lns1:_cons"]; // modified
	scalar `sigma2' = exp(`TMP'[1,1]);
	matrix `TMP' = `b'[1,"r0:_cons"]  ; // modified
	scalar `rho1'   = tanh(`TMP'[1,1]);
	matrix `TMP' = `b'[1,"r1:_cons"]  ; // modified
	scalar `rho2'   = tanh(`TMP'[1,1]);
	matrix `TMP' = `b'[1,"`y_reg1':"];
	matrix `reg1'   = `TMP';
	matrix `TMP' = `b'[1,"`y_reg2':"];
	matrix `reg2'   = `TMP';
	matrix `TMP' = `b'[1,"select:"];  	// modified
	matrix `prob'   = `TMP';

	tempvar xb_prob x_b1 x_b2;
	matrix score `xb_prob'    = `prob'   if `touse';

	if (("`psel'"~="") | (`nooptions')) {;  		// psel or default
		noisily display as text "(Option psel assumed; Pr(`y_prob'))";
		generate `varlist' = norm(`xb_prob') if `touse';
		exit 0;
	}; // endif

	if ("`mills1'"~="") {;
		generate `varlist' = normden(`xb_prob')/norm(`xb_prob') if `touse';
		exit 0;
	};
	if ("`mills2'"~="") {;
		generate `varlist' = normden(`xb_prob')/(1-norm(`xb_prob')) if `touse';
		exit 0;
	};
		cap drop mills;
		gen mills =  normden(`xb_prob')/norm(`xb_prob') if `touse';
		
		sum mills  if `y_prob'==1;
	matrix score `x_b1'       = `reg1'   if `touse';	
	matrix score `x_b2'       = `reg2'   if `touse';	
	

	if ("`yc1_1'"~="") generate `varlist' = `x_b1'+`sigma1'*`rho1'*normden(`xb_prob')/norm(`xb_prob')     if `y_prob'==1;
	if ("`yc2_1'"~="") generate `varlist' = `x_b2'+`sigma2'*`rho2'*normden(`xb_prob')/norm(`xb_prob')     if `y_prob'==1;
	if ("`xb1'"  ~="") generate `varlist' = `x_b1';

	if ("`yc1_2'"~="") generate `varlist' = `x_b1'-`sigma1'*`rho1'*normden(`xb_prob')/(1-norm(`xb_prob')) if `y_prob'==0;
	if ("`yc2_2'"~="") generate `varlist' = `x_b2'-`sigma2'*`rho2'*normden(`xb_prob')/(1-norm(`xb_prob')) if `y_prob'==0;
	if ("`xb2'"  ~="") generate `varlist' = `x_b2';

	
	
	
    replace `varlist' = . if `touse'==0;
	/*}; // end quietly*/

end; // end mspredict

