{smcl}
{* August 2021}{...}
{hline}
{hi:DASP 3.0 : Distributive Analysis Stata Package}{right:{bf:PEP}}
help for {hi:DASP 3.0 }{right:Help:  {bf:{helpb DASP}}}
{hline}

{title:Contents of DASP 3.01 package} 
{p2colset 10 25 27 2}{...}

{p 4 8}{cmd:- Poverty indices}{p_end}
{p2col :{helpb ipov:ipov}}Poverty indices{p_end}
{p2col :{helpb dipov:dipov}}Difference between poverty indices{p_end}
{p2col :{helpb cfgt:cfgt}}FGT CURVES{p_end}
{p2col :{helpb dicfgt:dicfgt}}Difference between FGT CURVES with confidence interval (dicfgt){p_end}
{p2col :{helpb cpoverty:cpoverty}}Poverty curves (cpoverty){p_end}

{p 4 8}{cmd:- Multidimensional poverty indices}{p_end}
{p2col :{helpb imdpov:imdpov}}Multidimensional poverty indices (imdpov){p_end}
{p2col :{helpb imoda:imoda}}Multiple overlapping deprivation analysis (MODA) indices{p_end}

{p 4 8}{cmd:- Poverty and targeting policies}{p_end}
{p2col :{helpb itargetg:itargetg}}Poverty and targeting by population groups{p_end}
{p2col :{helpb ogtpr:ogtpr}}Poverty and targeting by population groups with a fixed budget (ogtpr){p_end}
{p2col :{helpb itargetg2d:itargetg2d}}Bi-dimensional poverty and targeting by population groups (itargetg2d){p_end}
{p2col :{helpb itargetc:itargetc}}Poverty and targeting by income components{p_end}

{p 4 8}{cmd:- Marginal poverty impacts and poverty elasticities}{p_end}
{p2col :{helpb efgtgr:efgtgr}}FGT elasticity’s with respect to the average income growth (efgtgr).{p_end}
{p2col :{helpb efgtgro:efgtgro}}FGT elasticities with respect to average income growth with different approaches (efgtgro).{p_end}
{p2col :{helpb efgtineq:efgtineq}}FGT elasticity with respect to Gini inequality (efgtineq).{p_end}
{p2col :{helpb efgtine:efgtine}}FGT elasticity with respect to Gini-inequality with different approaches (efgtine).{p_end}
{p2col :{helpb efgtg:efgtg}}FGT elasticities with respect to within/between group components of inequality (efgtg).{p_end}
{p2col :{helpb efgtc:efgtc}}FGT elasticities with respect to within/between income components of inequality (efgtc).{p_end}

{p 4 8}{cmd:- Inequality indices}{p_end}
{p2col :{helpb ineq:ineq}}Inequality indices (ineq){p_end}
{p2col :{helpb dineq:dineq}}Difference between inequality indices (dineq){p_end}
{p2col :{helpb clorenz:clorenz}}Lorenz and concentration CURVES (clorenz).{p_end}
{p2col :{helpb diclorenz:diclorenz}}Differences between Lorenz/concentration curves with confidence interval (diclorenz){p_end}

{p 4 8}{cmd:- Multidimensional inequality indices}{p_end}
{p2col :{helpb imdi:imdi}}The Araar (2009) multidimensional inequality index{p_end}

{p 4 8}{cmd:- Polarisation indices}{p_end}
{p2col :{helpb ipola:ipola}}Polarisation indices (ipola){p_end}
{p2col :{helpb dipola:dipola}}Difference between polarisation indices (dipola){p_end}

{p 4 8}{cmd:- Decompositions of distributive indices}{p_end}
{p2col :{helpb dfgtg:dfgtg}}FGT Poverty: decomposition by population subgroups (dfgtg){p_end}
{p2col :{helpb dfgts:dfgts}}FGT Poverty: decomposition by income components using the Shapley value (dfgts){p_end}
{p2col :{helpb dmdafg:dmdafg}}Alkire and Foster (2011) MD index: decomposition by population subgroups (dmdafg){p_end}
{p2col :{helpb dmdafs:dmdafs}}Alkire and Foster (2011) MD index: decomposition by dimensions using the Shapley value (dmdafs){p_end}
{p2col :{helpb dfgtgr:dfgtgr}}Decomposition of the variation in FGT indices into growth and redistribution components (dfgtgr){p_end}
{p2col :{helpb dfgtg2d:dfgtg2d}}Decomposition of change in FGT poverty by poverty and population group components –sectoral decomposition- (dfgtg2d).{p_end}
{p2col :{helpb dtcpov:dtcpov}}Decomposition of FGT poverty by transient and chronic poverty components (dtcpov){p_end}
{p2col :{helpb diginis:diginis}}Inequality: decomposition by income sources (diginis){p_end}
{p2col :{helpb rbdineq:rbdineq}}Regression-based decomposition of inequality by income sources{p_end}
{p2col :{helpb diginig:diginig}}Gini index: decomposition by population subgroups (diginig).{p_end}
{p2col :{helpb dentropyg:dentropyg}}Generalised entropy indices of inequality: decomposition by population subgroups (dentropyg).{p_end}
{p2col :{helpb dpolag:dpolag}}Polarisation: decomposition of the DER index by population groups (dpolag){p_end}
{p2col :{helpb dpolas:dpolas}}Polarisation: decomposition of the DER index by income sources (dpolas){p_end}

{p 4 8}{cmd:- Progressivity of taxes and benefits}{p_end}
{p2col :{helpb iprog:iprog}}Progressivity indices{p_end}
{p2col :{helpb cprog:cprog}}Checking the progressivity of taxes or transfers{p_end}
{p2col :{helpb cprogtb:cprogtb}}Checking the progressivity of transfer vs tax{p_end}

{p 4 8}{cmd:- Poverty dominance}{p_end}
{p2col :{helpb dompov:dompov}}Poverty dominance (dompov){p_end}
{p2col :{helpb domineq:domineq}}Inequality dominance (domineq){p_end}
{p2col :{helpb cdomc:cdomc}}Consumption dominance curves (cdomc){p_end}
{p2col :{helpb cdomc2d:cdomc2d}}Difference/Ratio between consumption dominance curves (cdomc2d){p_end}
{p2col :{helpb dombdpov:dombdpov}}DASP and bi-dimensional poverty dominance (dombdpov){p_end}

{p 4 8}{cmd:- Propoor indices and curves}{p_end}
{p2col :{helpb ipropoor:ipropoor}}Pro-poor indices{p_end}
{p2col :{helpb gicur:gicur}}Growth incidence curve (gicur){p_end}
{p2col :{helpb cpropoorp:cpropoorp}}Primal pro-poor curves{p_end}
{p2col :{helpb cpropoord:cpropoord}}Dual pro-poor curves{p_end}

{p 4 8}{cmd:- Benefit Incidence Analysis}{p_end}
{p2col :{helpb bian:bian}}Benefit incidence analysis{p_end}
{p2col :{helpb imbi:imbi}}Marginal benefit incidence analysis (imbi){p_end}

{p2col :{helpb ungroup:ungroup}}Disaggregating grouped data{p_end}

{p 4 8}{cmd:- Distributive tools}{p_end}
{p2col :{helpb c_quantile:c_quantile}}Quantile curves (c_quantile){p_end}
{p2col :{helpb quinsh:quinsh}}Income share and cumulative income share by group quantiles (quinsh){p_end}
{p2col :{helpb cdensity:cdensity}}Density curves (cdensity){p_end}
{p2col :{helpb cnpe:cnpe}}Nonparametric regression curves (cnpe){p_end}
{p2col :{helpb sjdensity:sjdensity}}Joint density functions{p_end}
{p2col :{helpb sjdistrub:sjdistrub}}Joint distribution functions{p_end}
{p2col :{helpb datest:datest}}Hypothesis testing{p_end}

