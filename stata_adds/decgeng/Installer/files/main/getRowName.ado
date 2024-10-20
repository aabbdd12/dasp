capture program drop getRowName
program define getRowName, rclass
  local thismatrix="`1'"
  local rowindex=`2'
  matrix TWO= `thismatrix', `thismatrix'
  matrix TEMPORARY=TWO[`rowindex',1..2]
  local rowname: rownames TEMPORARY
  return local matrixname="`thismatrix'"
  return scalar rowindex=`rowindex'
  return local rowname = "`rowname'"
end
