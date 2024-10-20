
===================================================================================
HOW TO INSTALL DASP 2.0 ?
===================================================================================
STEP A:
=======

Before using modules of this package, users have
to update the executable Stata file  to Stata 9.2   or higher:
http://www.stata.com/support/updates/stata9.html 
update the ado files:                                                          
http://www.stata.com/support/updates/stata9/ado/

STEP B:
=======

Copy the folder dasp in the directory c:
Make sure that you have c:/dasp/dasp_p1.pkg, c:/dasp/dasp_p2.pkg, c:/dasp/dasp_p3.pkg  and c:/dasp/stata.toc;

In the Stata command window, type the following commands:

net from c:/dasp
net install dasp_p1, force
net install dasp_p2, force 
net install dasp_p3, force

STEP C:
=======

copy the file profile.do in the directory c:/ado/personal (create a new folder "personal" if this does not exist); 
open again Stata and select from the mainmenu USER => DASP

===================================================================================
If you note any problems, please contact Abdelkrim Araar: mailto:aabd@ecn.ulaval.ca
===================================================================================