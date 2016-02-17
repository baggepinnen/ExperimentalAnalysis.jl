using ExperimentalAnalysis
using Base.Test
using DataFrames
using GLM
# write your own tests here
@test perform_example_analysis() == nothing
scattermatrix(randn(10,3))
scattermatrix(DataFrame(randn(10,3)), f ~ x1 + x2)
scattermatrix(DataFrame(randn(10,3)), x3 ~ x1 + x2)
# scattermatrix(randn(10,3),["x1", "x2", "x3"])
modela = lm(x1 ~ x2 + x3, DataFrame(randn(10,3)))
modelb = lm(x1 ~ x2 + x3, DataFrame(randn(10,3)))
modelheatmap(["a", "b"], modela, modelb)
modelheatmap(["a", "b"], [modela, modelb])
