"""
##Functions

`scattermatrix(df::DataFrame)`

`scattermatrix(df::DataFrame, f::Formula)`

`scattermatrix(A::AbstractMatrix)`

`scattermatrix{T<:AbstractString}(A::AbstractMatrix, names::AbstractVector{T})`

`modelheatmap{T<:DataFrameRegressionModel}(modelnames, models::AbstractArray{T})`


##Usage examples
```
using ExperimentalAnalysis, DataFrames, GLM
```

```
perform_example_analysis()
df1 = DataFrame(randn(10,4))
df2 = DataFrame(10randn(10,4))
modela = lm(x1 ~ x2 + x3, df1)
modelb = lm(x1 ~ x2 + x3, df2)
modelheatmap(["a", "b"], modela, modelb)
modelheatmap(["a", "b"], [modela, modelb])
```

The following formula syntax may be used, interpreted as: plot `x3` and `x4` as functions of `x1` and `x2`
```
scattermatrix(df1, x3 + x4 ~ x1 + x2)
```
"""
module ExperimentalAnalysis
export perform_example_analysis, scattermatrix, modelheatmap
include("analysis.jl")

end # module
