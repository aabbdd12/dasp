capture program drop add_data_examples
program define       add_data_examples
local cdir `c(pwd)'
local perd : sysdir PERSONAL
qui cd  "`perd'"
net from https://www.dasp.cstip.ulaval.ca/dasp3
net get     dasp_data, force
qui cd  "`cdir'"
end
