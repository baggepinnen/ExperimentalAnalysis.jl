using ExperimentalAnalysis
using Base.Test
using DataFrames
# write your own tests here
@test perform_example_analysis() == nothing
scattermatrix(randn(10,3))
scattermatrix(DataFrame(randn(10,3)), f ~ x1 + x2)
# scattermatrix(randn(10,3),["x1", "x2", "x3"])
