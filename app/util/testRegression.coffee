regression = require './regression.min.js'

linear = regression 'linear', [[1,2], [2,4], [6,8]]

poly = regression 'polynomial', [[0,1],[32, 67],[12, 79]], 4
console.log poly