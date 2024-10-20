/* In the Stata command window, type the following commands:  */

clear all
set more off
net from http://dasp-two.vercel.app/shexp_beta_v2/Installer
net install shexp, force

/* Additional required ado files */
capture which eststo
if _rc==111 {
qui net from http://www.stata-journal.com/software/sj14-2
qui net install st0085_2.pkg
}
  