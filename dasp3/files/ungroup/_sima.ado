#delim ;

/* 
This program defines the log of the density function of SINGH & MADDALA. 
The sum of these log densities will be maximized by finding the three 
optimal parameters of the model.
*/

cap program drop _sima;
program define _sima;
	version 9.2;
	args lnf a b q;
	quietly replace `lnf' = ln(`a') + ln(`q')  - (`q'+1)*ln(1+($Sima/`b')^`a')   - `a'*ln(`b') + (`a'-1)*ln($Sima);
end;
