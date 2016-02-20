import ExperimentalAnalysis
using Base.Test
using DataFrames
using GLM
# write your own tests here
@test ExperimentalAnalysis.perform_example_analysis() == nothing
ExperimentalAnalysis.scattermatrix(randn(10,3))
ExperimentalAnalysis.scattermatrix(DataFrame(randn(10,3)))
ExperimentalAnalysis.scattermatrix(DataFrame(randn(10,3)), reglines=true)
ExperimentalAnalysis.scattermatrix(DataFrame(randn(10,3)), f ~ x1 + x2)
ExperimentalAnalysis.scattermatrix(DataFrame(randn(10,3)), x3 ~ x1 + x2)
ExperimentalAnalysis.scattermatrix(randn(10,3),["x1", "x2", "x3"])

df = DataFrame(a = randn(10),b = randn(10),c = randn(10),d = randn(10))
modela = lm(b ~ a + c, df)
modelb = lm(d ~ a + c, df)
ExperimentalAnalysis.scattermatrix([modela, modelb])
ExperimentalAnalysis.modelheatmap([modela, modelb])
ExperimentalAnalysis.modelheatmap(["a", "b"], modela, modelb)
ExperimentalAnalysis.modelheatmap(["a", "b"], [modela, modelb])
