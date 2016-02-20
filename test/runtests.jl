import ExperimentalAnalysis
using Base.Test
using DataFrames
using GLM
# write your own tests here

df = DataFrame(a = randn(10),b = randn(10),c = randn(10),d = randn(10))
df[2,2] = NA

@test ExperimentalAnalysis.perform_example_analysis() == nothing
ExperimentalAnalysis.scattermatrix(randn(10,3))
ExperimentalAnalysis.scattermatrix(df)
ExperimentalAnalysis.scattermatrix(df, reglines=true)
ExperimentalAnalysis.scattermatrix(df, f ~ a + b)
ExperimentalAnalysis.scattermatrix(df, c ~ a + b)
ExperimentalAnalysis.scattermatrix(randn(10,3),["x1", "x2", "x3"])



modela = lm(b ~ a + c, df)
modelb = lm(d ~ a + c, df)
ExperimentalAnalysis.scattermatrix([modela, modelb])
ExperimentalAnalysis.modelheatmap([modela, modelb])
ExperimentalAnalysis.modelheatmap(["a", "b"], modela, modelb)
ExperimentalAnalysis.modelheatmap(["a", "b"], [modela, modelb])
