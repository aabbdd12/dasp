

To install dasp 3.0: 

1-	Load the zipped folder dasp3: https://dasp.ecn.ulaval.ca/dasp3.rar
2-	unzip and copy the folder in a given directory, ex: C:/temp/dasp3
3-	run the following Stata commands:

set more off
net from C:/temp/dasp3
net install dasp_p1, force
net install dasp_p2, force
net install dasp_p3, force
net install dasp_p4, force
net install dasp_p5, force
net install dasp_p6, force
cap adddmenu profile.do _daspmenu
cap add_data_examples




 