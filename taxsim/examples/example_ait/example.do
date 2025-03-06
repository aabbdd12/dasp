#delimit ;
set more off ;
cd C:\taxsim1\example\ ;
use "tunisia_2014_inc.dta", clear ;

itschset initial_it, inisave(nitial_tunisia) nrange(6) exempt(0) mxb1(1500) mxb2(5000) mxb3(10000) mxb4(20000) mxb5(50000) tax1(0) tax2(0.15) tax3(0.20) tax4(0.25) tax5(0.30) tax6(0.35) ;

itschset final_it1, inisave(C:\taxsim1\example\initial_tunisia1) nrange(8) exempt(0) mxb1(1500) mxb2(4000) mxb3(10000) mxb4(20000) mxb5(40000) mxb6(46000) mxb7(60000) tax1(0) tax2(.12) tax3(.22) tax4(.27) tax5(.29) tax6(.30) tax7(0.33) tax8(0.36) ;

itschset final_it2, inisave(C:\taxsim1\example\initial_tunisia2) nrange(8) exempt(0) mxb1(1500) mxb2(4000) mxb3(10000) mxb4(20000) mxb5(40000) mxb6(46000) mxb7(60000) tax1(0) tax2(.12) tax3(.23) tax4(.26) tax5(.28) tax6(.33) tax7(0.34) tax8(0.37) ;
itschdes initial_it final_it1 final_it2, dgra(1) ;

db aitsim ;


