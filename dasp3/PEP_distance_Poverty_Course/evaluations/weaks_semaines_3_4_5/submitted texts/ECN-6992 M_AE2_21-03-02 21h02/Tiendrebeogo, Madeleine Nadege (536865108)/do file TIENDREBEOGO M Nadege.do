
  ___  ____  ____  ____  ____ (R)
 /__    /   ____/   /   ____/
___/   /   /___/   /   /___/   14.2   Copyright 1985-2015 StataCorp LLC
  Statistics/Data Analysis            StataCorp
                                      4905 Lakeway Drive
     MP - Parallel Edition            College Station, Texas 77845 USA
                                      800-STATA-PC        http://www.stata.com
                                      979-696-4600        stata@stata.com
                                      979-696-4601 (fax)

Single-user 8-core Stata perpetual license:
       Serial number:  10699393
         Licensed to:  Andrey
                       

Notes:
      1.  Unicode is supported; see help unicode_advice.
      2.  Maximum number of variables is set to 5000; see help set_maxvar.
      3.  New update available; type -update all-

Checking for updates...
(contacting http://www.stata.com)
bad serial number
unable to check for update; verify Internet settings are correct.

*************4%
. *(1 variable, 10 observations pasted into data editor)

. DROP
command DROP is unrecognized
r(199);

. drop pre_tax_income

. *(1 variable, 8 observations pasted into data editor)

. gen pcincatA= pre_tax_income*(1-0.1)

. *(1 variable, 8 observations pasted into data editor)

. rename pcincatA aprtaxe

. gen pcincatA= pre_tax_income*(1-0.1)/ hhsize

. gen pcincatA= aprtaxe/ hhsize
variable pcincatA already defined
r(110);

. gen pcincatA1= aprtaxe/ hhsize

. drop pcincatA1

. gen pcincatB= pre_tax_income*0.1

. gen 60%tax= pcincatB*0.6
60 invalid name
r(198);

. gen tax_A= pcincatB*0.6

. sum tax_A

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
       tax_A |          8          90    69.97436       27.6        228

. summarize tax_A

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
       tax_A |          8          90    69.97436       27.6        228

. total tax_A

Total estimation                  Number of obs   =          8

--------------------------------------------------------------
             |      Total   Std. Err.     [95% Conf. Interval]
-------------+------------------------------------------------
       tax_A |        720   197.9174      251.9997        1188
--------------------------------------------------------------

. gen pcuincA= (total tax_A)/60
totaltax_A not found
r(111);

. gen total tax_A=720
variable tax_A already defined
r(110);

. gen pcuincA= 720/60

. gen pcuincB=0

. gen pcallow= tax_A*0.4

. drop pcallow

. gen pcallow= pcincatB*0.4

. total pcallow

Total estimation                  Number of obs   =          8

--------------------------------------------------------------
             |      Total   Std. Err.     [95% Conf. Interval]
-------------+------------------------------------------------
     pcallow |        480   131.9449      167.9998    792.0002
--------------------------------------------------------------

. gen pcallowA= 480/30

. total pcincatB

Total estimation                  Number of obs   =          8

--------------------------------------------------------------
             |      Total   Std. Err.     [95% Conf. Interval]
-------------+------------------------------------------------
    pcincatB |       1200   329.8623      419.9996        1980
--------------------------------------------------------------

. gen pcallowB=1200/30

. gen dpcincA= pcincatA+ pcuincA+ pcallowA

. gen dpcincB= pcincatB+ pcuincB+ pcallowB

. net from C:\DASP_V2.3\dasp
---------------------------------------------------------------------------------------------------------------------------------------------
C:\DASP_V2.3\dasp\
===================================================
---------------------------------------------------------------------------------------------------------------------------------------------

Version       : Version   2.3
Date          : May      2013
Stata Version : Required  10.0 and higher

Author:
DASP is conceived by:

Dr. Abdelkrim Araar  :  aabd@ecn.ulaval.ca
Dr. Jean-Yves Duclos : jyves@ecn.ulaval.ca

The two follwing sub-packages  must be  installed to run DASP.
===================================================

PACKAGES you could -net describe-:
    dasp_p1           Distributive Analysis Stata Package: PART   I
    dasp_p2           Distributive Analysis Stata Package: PART  II
    dasp_p3           Distributive Analysis Stata Package: PART III
    dasp_p4           Distributive Analysis Stata Package: PART  IV
---------------------------------------------------------------------------------------------------------------------------------------------

. net install dasp_p1.pkg, force replace
checking dasp_p1 consistency and verifying not already installed...

the following files will be replaced:
    c:\ado\plus\i\igini.ado
    c:\ado\plus\i\igini.hlp
    c:\ado\plus\i\igini.dlg
    c:\ado\plus\d\digini.ado
    c:\ado\plus\d\digini.hlp
    c:\ado\plus\d\digini.dlg
    c:\ado\plus\i\iatkinson.ado
    c:\ado\plus\i\iatkinson.hlp
    c:\ado\plus\i\iatkinson.dlg
    c:\ado\plus\d\diatkinson.ado
    c:\ado\plus\d\diatkinson.hlp
    c:\ado\plus\d\diatkinson.dlg
    c:\ado\plus\i\ientropy.ado
    c:\ado\plus\i\ientropy.hlp
    c:\ado\plus\i\ientropy.dlg
    c:\ado\plus\d\dientropy.ado
    c:\ado\plus\d\dientropy.hlp
    c:\ado\plus\d\dientropy.dlg
    c:\ado\plus\i\icvar.ado
    c:\ado\plus\i\icvar.hlp
    c:\ado\plus\i\icvar.dlg
    c:\ado\plus\d\dicvar.ado
    c:\ado\plus\d\dicvar.hlp
    c:\ado\plus\d\dicvar.dlg
    c:\ado\plus\i\inineq.ado
    c:\ado\plus\i\inineq.hlp
    c:\ado\plus\i\inineq.dlg
    c:\ado\plus\d\dinineq.ado
    c:\ado\plus\d\dinineq.hlp
    c:\ado\plus\d\dinineq.dlg
    c:\ado\plus\i\imdi.ado
    c:\ado\plus\i\imdi.hlp
    c:\ado\plus\i\imdi.dlg
    c:\ado\plus\i\ipolder.ado
    c:\ado\plus\i\ipolder.hlp
    c:\ado\plus\i\ipolder.dlg
    c:\ado\plus\d\dipolder.ado
    c:\ado\plus\d\dipolder.hlp
    c:\ado\plus\d\dipolder.dlg
    c:\ado\plus\i\ipolfw.ado
    c:\ado\plus\i\ipolfw.hlp
    c:\ado\plus\i\ipolfw.dlg
    c:\ado\plus\d\dipolfw.ado
    c:\ado\plus\d\dipolfw.hlp
    c:\ado\plus\d\dipolfw.dlg
    c:\ado\plus\i\ipoegr.ado
    c:\ado\plus\i\ipoegr.hlp
    c:\ado\plus\i\ipoegr.dlg
    c:\ado\plus\d\dspol.ado
    c:\ado\plus\d\dspol.hlp
    c:\ado\plus\d\dspol.dlg
    c:\ado\plus\c\c_quantile.ado
    c:\ado\plus\c\c_quantile.hlp
    c:\ado\plus\c\c_quantile.dlg
    c:\ado\plus\c\cdensity.ado
    c:\ado\plus\c\cdensity.hlp
    c:\ado\plus\c\cdensity.dlg
    c:\ado\plus\c\cnpe.ado
    c:\ado\plus\c\cnpe.hlp
    c:\ado\plus\c\cnpe.dlg
    c:\ado\plus\q\quinsh.ado
    c:\ado\plus\q\quinsh.hlp
    c:\ado\plus\q\quinsh.dlg
    c:\ado\plus\c\cfgt.ado
    c:\ado\plus\c\cfgt.hlp
    c:\ado\plus\c\cfgt.dlg
    c:\ado\plus\c\cfgts.ado
    c:\ado\plus\c\cfgts.hlp
    c:\ado\plus\c\cfgts.dlg
    c:\ado\plus\c\cfgtsm.ado
    c:\ado\plus\c\cfgtsm.dlg
    c:\ado\plus\c\cfgts2d.ado
    c:\ado\plus\c\cfgts2d.hlp
    c:\ado\plus\c\cfgts2d.dlg
    c:\ado\plus\c\cpoverty.ado
    c:\ado\plus\c\cpoverty.hlp
    c:\ado\plus\c\cpoverty.dlg
    c:\ado\plus\c\clorenz.ado
    c:\ado\plus\c\clorenz.hlp
    c:\ado\plus\c\clorenz.dlg
    c:\ado\plus\c\clorenzs.ado
    c:\ado\plus\c\clorenzs.hlp
    c:\ado\plus\c\clorenzs.dlg
    c:\ado\plus\c\clorenzsm.ado
    c:\ado\plus\c\clorenzsm.dlg
    c:\ado\plus\c\clorenzs2d.ado
    c:\ado\plus\c\clorenzs2d.hlp
    c:\ado\plus\c\clorenzs2d.dlg
    c:\ado\plus\c\cprog.ado
    c:\ado\plus\c\cprog.hlp
    c:\ado\plus\c\cprog.dlg
    c:\ado\plus\c\cprogbt.ado
    c:\ado\plus\c\cprogbt.hlp
    c:\ado\plus\c\cprogbt.dlg

installing into c:\ado\plus\...
installation complete.

. 
. net install dasp_p2.pkg, force replace
checking dasp_p2 consistency and verifying not already installed...

the following files will be replaced:
    c:\ado\plus\d\dompov.ado
    c:\ado\plus\d\dompov.hlp
    c:\ado\plus\d\dompov.dlg
    c:\ado\plus\d\domineq.ado
    c:\ado\plus\d\domineq.hlp
    c:\ado\plus\d\domineq.dlg
    c:\ado\plus\s\sjdensity.ado
    c:\ado\plus\s\sjdensity.hlp
    c:\ado\plus\s\sjdensity.dlg
    c:\ado\plus\s\sjdistrub.ado
    c:\ado\plus\s\sjdistrub.hlp
    c:\ado\plus\s\sjdistrub.dlg
    c:\ado\plus\i\ifgt.ado
    c:\ado\plus\i\ifgt.hlp
    c:\ado\plus\i\ifgt.dlg
    c:\ado\plus\d\difgt.ado
    c:\ado\plus\d\difgt.hlp
    c:\ado\plus\d\difgt.dlg
    c:\ado\plus\i\iwatts.ado
    c:\ado\plus\i\iwatts.hlp
    c:\ado\plus\i\iwatts.dlg
    c:\ado\plus\d\diwatts.ado
    c:\ado\plus\d\diwatts.hlp
    c:\ado\plus\d\diwatts.dlg
    c:\ado\plus\i\isst.ado
    c:\ado\plus\i\isst.hlp
    c:\ado\plus\i\isst.dlg
    c:\ado\plus\d\disst.ado
    c:\ado\plus\d\disst.hlp
    c:\ado\plus\d\disst.dlg
    c:\ado\plus\e\efgtgr.ado
    c:\ado\plus\e\efgtgr.hlp
    c:\ado\plus\e\efgtgr.dlg
    c:\ado\plus\e\efgtineq.ado
    c:\ado\plus\e\efgtineq.hlp
    c:\ado\plus\e\efgtineq.dlg
    c:\ado\plus\e\efgtg.ado
    c:\ado\plus\e\efgtg.hlp
    c:\ado\plus\e\efgtg.dlg
    c:\ado\plus\e\efgtc.ado
    c:\ado\plus\e\efgtc.hlp
    c:\ado\plus\e\efgtc.dlg
    c:\ado\plus\i\itargetg.ado
    c:\ado\plus\i\itargetg.hlp
    c:\ado\plus\i\itargetg.dlg
    c:\ado\plus\i\itargetc.ado
    c:\ado\plus\i\itargetc.hlp
    c:\ado\plus\i\itargetc.dlg
    c:\ado\plus\i\ipropoor.ado
    c:\ado\plus\i\ipropoor.hlp
    c:\ado\plus\i\ipropoor.dlg
    c:\ado\plus\c\cpropoorp.ado
    c:\ado\plus\c\capropoor.ado
    c:\ado\plus\c\crpropoor.ado
    c:\ado\plus\c\cpropoorp.hlp
    c:\ado\plus\c\cpropoorp.dlg
    c:\ado\plus\c\cpropoord.ado
    c:\ado\plus\c\cpropoordi.ado
    c:\ado\plus\c\cpropoord.hlp
    c:\ado\plus\c\cpropoord.dlg
    c:\ado\plus\b\bian.ado
    c:\ado\plus\b\bian.dlg
    c:\ado\plus\b\bian.hlp
    c:\ado\plus\i\imbi.ado
    c:\ado\plus\i\imbi.dlg
    c:\ado\plus\i\imbi.hlp
    c:\ado\plus\u\ungroup.ado
    c:\ado\plus\_\_sima.ado
    c:\ado\plus\_\_inidis.ado
    c:\ado\plus\_\_expadj.ado
    c:\ado\plus\_\_expex.ado
    c:\ado\plus\_\_cumdis.ado
    c:\ado\plus\u\ungroup.dlg
    c:\ado\plus\u\ungroup.hlp
    c:\ado\plus\d\dombdpov.ado
    c:\ado\plus\d\dombdpov.hlp
    c:\ado\plus\d\dombdpov.dlg
    c:\ado\plus\w\wgnuplot.exe
    c:\ado\plus\_\_daspmenu.ado
    c:\ado\plus\_\_nargs.ado
    c:\ado\plus\r\resop.idlg
    c:\ado\plus\d\dasp_line_opts1.idlg
    c:\ado\plus\d\dasp_gr_res_opts.idlg
    c:\ado\plus\d\dasp_dif_line_opts.idlg
    c:\ado\plus\d\dasp_conf_opts.idlg
    c:\ado\plus\_\_stat_inf.idlg
    c:\ado\plus\x\xml_taba.hlp
    c:\ado\plus\x\xml_taba.ado
    c:\ado\plus\x\xml_taba_options.txt
    c:\ado\plus\_\_dasp_dif_table_ifgt.ado
    c:\ado\plus\_\_dasp_dif_table.ado
    c:\ado\plus\g\graph_header.idlg

installing into c:\ado\plus\...
installation complete.

. 
. net install dasp_p3.pkg, force replace
checking dasp_p3 consistency and verifying not already installed...

the following files will be replaced:
    c:\ado\plus\m\mk_xtab_m1.ado
    c:\ado\plus\d\dfgtg.ado
    c:\ado\plus\d\dfgtg.hlp
    c:\ado\plus\d\dfgtg.dlg
    c:\ado\plus\d\dfgts.ado
    c:\ado\plus\d\dfgts.hlp
    c:\ado\plus\d\dfgts.dlg
    c:\ado\plus\d\distable.ado
    c:\ado\plus\d\dmdafs.ado
    c:\ado\plus\d\dmdafs.hlp
    c:\ado\plus\d\dmdafs.dlg
    c:\ado\plus\d\dtcpov.ado
    c:\ado\plus\d\dtcpov.hlp
    c:\ado\plus\d\dtcpov.dlg
    c:\ado\plus\d\dentropyg.ado
    c:\ado\plus\d\dentropyg.hlp
    c:\ado\plus\d\dentropyg.dlg
    c:\ado\plus\d\dfgtgr.ado
    c:\ado\plus\d\dfgtgr.hlp
    c:\ado\plus\d\dfgtgr.dlg
    c:\ado\plus\d\dfgtg2d.ado
    c:\ado\plus\d\dfgtg2d.hlp
    c:\ado\plus\d\dfgtg2d.dlg
    c:\ado\plus\d\diginis.ado
    c:\ado\plus\d\diginis.hlp
    c:\ado\plus\d\diginis.dlg
    c:\ado\plus\d\dsginis.ado
    c:\ado\plus\d\dsginis.hlp
    c:\ado\plus\d\dsginis.dlg
    c:\ado\plus\d\dsineqs.ado
    c:\ado\plus\d\dsineqs.hlp
    c:\ado\plus\d\dsineqs.dlg
    c:\ado\plus\r\rbdineq.ado
    c:\ado\plus\r\rbdineq.hlp
    c:\ado\plus\r\rbdineq.dlg
    c:\ado\plus\s\shapar.ado
    c:\ado\plus\d\diginig.ado
    c:\ado\plus\d\diginig.hlp
    c:\ado\plus\d\diginig.dlg
    c:\ado\plus\d\dpolag.ado
    c:\ado\plus\d\dpolag.hlp
    c:\ado\plus\d\dpolag.dlg
    c:\ado\plus\d\dmdafg.ado
    c:\ado\plus\d\dmdafg.hlp
    c:\ado\plus\d\dmdafg.dlg
    c:\ado\plus\d\dpolas.ado
    c:\ado\plus\d\dpolas.hlp
    c:\ado\plus\d\dpolas.dlg
    c:\ado\plus\i\imean.ado
    c:\ado\plus\i\imean.hlp
    c:\ado\plus\i\imean.dlg
    c:\ado\plus\d\dimean.ado
    c:\ado\plus\d\dimean.hlp
    c:\ado\plus\d\dimean.dlg
    c:\ado\plus\i\iprop.ado
    c:\ado\plus\i\iprop.hlp
    c:\ado\plus\i\iprop.dlg
    c:\ado\plus\d\diprop.ado
    c:\ado\plus\d\diprop.hlp
    c:\ado\plus\d\diprop.dlg
    c:\ado\plus\d\datest.ado
    c:\ado\plus\d\datest.hlp
    c:\ado\plus\d\datest.dlg

installing into c:\ado\plus\...
installation complete.

. 
. net install dasp_p4.pkg, force replace
checking dasp_p4 consistency and verifying not already installed...

the following files will be replaced:
    c:\ado\plus\c\cdf.ado
    c:\ado\plus\c\cdf.hlp
    c:\ado\plus\c\cdf.dlg
    c:\ado\plus\c\cdomc.ado
    c:\ado\plus\c\cdomc.hlp
    c:\ado\plus\c\cdomc.dlg
    c:\ado\plus\c\cdomc2d.ado
    c:\ado\plus\c\cdomc2d.hlp
    c:\ado\plus\c\cdomc2d.dlg
    c:\ado\plus\c\cdomc2r.ado
    c:\ado\plus\c\cdomc2r.hlp
    c:\ado\plus\c\cdomc2r.dlg
    c:\ado\plus\e\efgtgro.ado
    c:\ado\plus\e\efgtgro.hlp
    c:\ado\plus\e\efgtgro.dlg
    c:\ado\plus\e\efgtine.ado
    c:\ado\plus\e\efgtine.hlp
    c:\ado\plus\e\efgtine.dlg
    c:\ado\plus\i\imdp_afi.ado
    c:\ado\plus\i\imdp_afi.dlg
    c:\ado\plus\i\imdp_afi.hlp
    c:\ado\plus\i\imdp_bci.ado
    c:\ado\plus\i\imdp_bci.dlg
    c:\ado\plus\i\imdp_bci.hlp
    c:\ado\plus\i\imdp_cmr.ado
    c:\ado\plus\i\imdp_cmr.dlg
    c:\ado\plus\i\imdp_cmr.hlp
    c:\ado\plus\i\imdp_ewi.ado
    c:\ado\plus\i\imdp_ewi.dlg
    c:\ado\plus\i\imdp_ewi.hlp
    c:\ado\plus\i\imdp_ihi.ado
    c:\ado\plus\i\imdp_ihi.dlg
    c:\ado\plus\i\imdp_ihi.hlp
    c:\ado\plus\i\imdp_mfi.ado
    c:\ado\plus\i\imdp_mfi.dlg
    c:\ado\plus\i\imdp_mfi.hlp
    c:\ado\plus\i\imdp_tsu.ado
    c:\ado\plus\i\imdp_tsu.dlg
    c:\ado\plus\i\imdp_tsu.hlp
    c:\ado\plus\i\imdp_uhi.ado
    c:\ado\plus\i\imdp_uhi.dlg
    c:\ado\plus\i\imdp_uhi.hlp
    c:\ado\plus\i\imdpov.ado
    c:\ado\plus\i\imoda.ado
    c:\ado\plus\i\imoda.dlg
    c:\ado\plus\i\imoda.hlp

installing into c:\ado\plus\...
installation complete.

. _daspmenu

. igini pcincatA pcincatB, hsize(hhsize)

    Index            :  Gini index
    Household size   :  hhsize
-----------------------------------------------------------------------------------------------
                   Variable   |       Estimate            STE             LB              UB  
------------------------------+----------------------------------------------------------------
1: GINI_pcincatA              |        0.395556        0.049440        0.278649        0.512462
2: GINI_pcincatB              |        0.385363        0.063372        0.235512        0.535214
-----------------------------------------------------------------------------------------------

. igini pcincatA, hsize(hhsize)

    Index            :  Gini index
    Household size   :  hhsize
-----------------------------------------------------------------------------------------------
                   Variable   |       Estimate            STE             LB              UB  
------------------------------+----------------------------------------------------------------
1: GINI_pcincatA              |        0.395556        0.049440        0.278649        0.512462
-----------------------------------------------------------------------------------------------

. igini pcincatB, hsize(hhsize)

    Index            :  Gini index
    Household size   :  hhsize
-----------------------------------------------------------------------------------------------
                   Variable   |       Estimate            STE             LB              UB  
------------------------------+----------------------------------------------------------------
1: GINI_pcincatB              |        0.385363        0.063372        0.235512        0.535214
-----------------------------------------------------------------------------------------------

. diginis dpcincA, dpcincB
option dpcincB not allowed
r(198);

. diginis dpcincA

    Decomposition of the Gini Index by Incomes Sources: Rao's (1969) Approach.
  +------------------------------------------------------------------------------------+
  |         Sources   |      Income      Concentration      Absolute        Relative   |
  |                   |       Share       Index           Contribution    Contribution |
  |-------------------+----------------------------------------------------------------|
  |1: dpcincA         |        1.000000        0.340239        0.340239        1.000000|
  |                   |        0.000000        0.041108        0.041108        0.000000|
  |-------------------+----------------------------------------------------------------|
  |             Total |        1.000000            ---         0.340239        1.000000|
  |                   |        0.000000            ---         0.041108        0.000000|
  +------------------------------------------------------------------------------------+

. dfgts dpcincA dpcincB, hsize(hhsize) alpha(0) pline(10000)

    Decomposition of the FGT index by income components (using the Shapley value).
    Execution  time :          0.38 second(s)
    Parameter alpha :          0.00
    Poverty line    :      10000.00
    FGT index       :      1.000000
    Household size  :  hhsize
  +---------------------------------------------------------------------+
  |          Sources   |      Income         Absolute        Relative   |
  |                    |       Share       Contribution    Contribution |
  |--------------------+------------------------------------------------|
  |1: dpcincA          |        0.522613        0.000000               .|
  |2: dpcincB          |        0.477387        0.000000               .|
  |--------------------+------------------------------------------------|
  |              Total |        1.000000        0.000000        1.000000|
  +---------------------------------------------------------------------+


------------------------------------------------------------
Marginal contributions:
------------------------------------------------------------

-----------------------------------
    Source |    level_1     level_2
-----------+-----------------------
1: dpcincA |   0.000000    0.000000
2: dpcincB |   0.000000    0.000000
-----------------------------------

. gen impot= pre_tax_income*0.1

. drop pcincatB

. gen pcincatB= pre_tax_income- impot

. drop pcincatB

. gen pcincatB= (pre_tax_income- impot)/ hhsize

. gen dpcincB= pcincatB+ pcuincB+ pcallowB
variable dpcincB already defined
r(110);

. drop dpcincB

. gen dpcincB= pcincatB+ pcuincB+ pcallowB

. igini pcincatA pcincatB, hsize(hhsize)

    Index            :  Gini index
    Household size   :  hhsize
-----------------------------------------------------------------------------------------------
                   Variable   |       Estimate            STE             LB              UB  
------------------------------+----------------------------------------------------------------
1: GINI_pcincatA              |        0.395556        0.049440        0.278649        0.512462
2: GINI_pcincatB              |        0.395556        0.049440        0.278649        0.512462
-----------------------------------------------------------------------------------------------

. dfgts dpcincA dpcincB, hsize(hhsize) alpha(0) pline(10000)

    Decomposition of the FGT index by income components (using the Shapley value).
    Execution  time :          0.26 second(s)
    Parameter alpha :          0.00
    Poverty line    :      10000.00
    FGT index       :      1.000000
    Household size  :  hhsize
  +---------------------------------------------------------------------+
  |          Sources   |      Income         Absolute        Relative   |
  |                    |       Share       Contribution    Contribution |
  |--------------------+------------------------------------------------|
  |1: dpcincA          |        0.485981        0.000000               .|
  |2: dpcincB          |        0.514019        0.000000               .|
  |--------------------+------------------------------------------------|
  |              Total |        1.000000        0.000000        1.000000|
  +---------------------------------------------------------------------+


------------------------------------------------------------
Marginal contributions:
------------------------------------------------------------

-----------------------------------
    Source |    level_1     level_2
-----------+-----------------------
1: dpcincA |   0.000000    0.000000
2: dpcincB |   0.000000    0.000000
-----------------------------------

. save "C:\Users\Toshiba\Desktop\exo1 do.dta"
file C:\Users\Toshiba\Desktop\exo1 do.dta saved

. gen povline=100

. *(1 variable, 8 observations pasted into data editor)

. gen povline=100
variable povline already defined
r(110);

. collapse(sum)variable tab income
variable variable not found
r(111);

. *(1 variable, 8 observations pasted into data editor)

. *(1 variable, 8 observations pasted into data editor)

. *(1 variable, 8 observations pasted into data editor)

. difgt dpcincb pcincatb, alpha(0) hsize1(hhsize) hsize2(hhsize) pline1(100) pline2(100)
------------------------------------------------------------------------------------------
Variable |   Estimate   Std. Err.       t     P>|t|       [95% Conf. interval]  Pov. line
---------+--------------------------------------------------------------------------------
 dpcincb |  .1333333    .1323562   1.00738   0.3473      -.1796394     .446306       100
pcincatb |  .3666667    .1835415   1.99773   0.0859        -.06734    .8006734       100
---------+--------------------------------------------------------------------------------
    diff.|  .2333333    .1579588   1.47718   0.1831      -.1401799    .6068465      ---
------------------------------------------------------------------------------------------

. difgt dpcincb pcincatb, alpha(0) hsize1(hhsize) cond1(dpcincb<100 ) hsize2(hhsize) cond2(pcincatb<100 ) pline1(100) pline2(100)
------------------------------------------------------------------------------------------
Variable |   Estimate   Std. Err.       t     P>|t|       [95% Conf. interval]  Pov. line
---------+--------------------------------------------------------------------------------
 dpcincb |         1           0         .        .              1           1       100
pcincatb |         1           0         .        .              1           1       100
---------+--------------------------------------------------------------------------------
    diff.|         0    2.44e-11         0   1.0000      -5.77e-11    5.77e-11      ---
------------------------------------------------------------------------------------------

. 





exercice 3****1,5%




. use "C:\Users\Toshiba\Desktop\COURS PEP 2021\exo 4-5\data_3.dta", clear

. gen fgt0=
invalid syntax
r(198);

. gen povline=21000

. ifgt ae_exp, alpha(0) hsize(hsize) pline(21000)

    Poverty index   :  FGT index
    Household size  :  hsize
    Sampling weight :  sweight
    Parameter alpha :  0.00
-----------------------------------------------------------------------------------------------
   Variable   |       Estimate            STE             LB              UB         Pov. line
--------------+--------------------------------------------------------------------------------
ae_exp        |        0.316088        0.013949        0.288713        0.343464        21000.00
-----------------------------------------------------------------------------------------------

. ifgt ae_exp, alpha(0) hsize(sex) hgroup(hsize) pline(21000)

    Poverty index   :  FGT index
    Household size  :  sex
    Sampling weight :  sweight
    Group variable  :  hsize
    Parameter alpha :  0.00
---------------------------------------------------------------------------------------------------
          Group   |       Estimate            STE             LB              UB         Pov. line
------------------+--------------------------------------------------------------------------------
1: Group_1        |        0.108424        0.028103        0.053270        0.163577        21000.00
2: Group_2        |        0.089398        0.022988        0.044282        0.134514        21000.00
3: Group_3        |        0.212987        0.051018        0.112860        0.313114        21000.00
4: Group_4        |        0.280312        0.034253        0.213087        0.347536        21000.00
5: Group_5        |        0.341717        0.039669        0.263864        0.419569        21000.00
6: Group_6        |        0.340915        0.034690        0.272834        0.408995        21000.00
7: Group_7        |        0.389481        0.033039        0.324639        0.454322        21000.00
8: Group_8        |        0.396688        0.049682        0.299185        0.494192        21000.00
9: Group_9        |        0.385457        0.049162        0.288973        0.481941        21000.00
10: Group_10      |        0.452038        0.066099        0.322315        0.581761        21000.00
11: Group_11      |        0.315334        0.076059        0.166063        0.464605        21000.00
12: Group_12      |        0.300575        0.093648        0.116785        0.484366        21000.00
13: Group_13      |        0.258344        0.100198        0.061698        0.454989        21000.00
14: Group_14      |        0.466900        0.170669        0.131951        0.801850        21000.00
15: Group_15      |        0.004455        0.004810       -0.004986        0.013896        21000.00
16: Group_16      |        0.620859        0.215776        0.197386        1.044333        21000.00
17: Group_17      |        0.382904        0.206129       -0.021638        0.787445        21000.00
18: Group_18      |        0.000000        0.000000        0.000000        0.000000        21000.00
20: Group_20      |        0.497916        0.341505       -0.172309        1.168142        21000.00
21: Group_21      |        0.325122        0.274183       -0.212981        0.863225        21000.00
22: Group_22      |        0.000000        0.000000        0.000000        0.000000        21000.00
23: Group_23      |        1.000000        0.000000        1.000000        1.000000        21000.00
24: Group_24      |        0.000000        0.000000        0.000000        0.000000        21000.00
25: Group_25      |        0.000000        0.000000        0.000000        0.000000        21000.00
------------------+--------------------------------------------------------------------------------
Population        |        0.276359        0.016594        0.243793        0.308925        21000.00
---------------------------------------------------------------------------------------------------

. 
. 
