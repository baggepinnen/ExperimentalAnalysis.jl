using DataFrames
using GLM
using Plots
function getcolormap(name="jet", n=64)
  if name == "jet"
    return RGB{Float64}[RGB(
    clamp(min(4x - 1.5, -4x + 4.5) ,0.0,1.0),
    clamp(min(4x - 0.5, -4x + 3.5) ,0.0,1.0),
    clamp(min(4x + 0.5, -4x + 2.5) ,0.0,1.0)) for x in linspace(0.0,1.0,n)]
  end
end

const cm = getcolormap("jet", 64)



P2c(P) = cm[round(Int,(max(log10(P),-4)/4+1)*63)+1]
function Pvalues(model)
  cc = coef(model)
  se = stderr(model)
  zz = cc ./ se
  P = 2.0 * ccdf(Normal(), abs(zz))
end

"""
`scattermatrix(df::DataFrame; reglines = false)`

`scattermatrix(df::DataFrame, f::Formula; reglines = false)`

`scattermatrix(A::AbstractMatrix; reglines = false)`

`scattermatrix(m::RegressionModel)` Useful together with e.g. GLM.jl

`scattermatrix(models::Array{::RegressionModel})` Should only be used if all models have the same independent parameters, but predict different response

Plot a scatter matrix of a DataFrame, Linear regression model or a numerical matrix

Examples
```
ExperimentalAnalysis.scattermatrix(randn(10,3))
ExperimentalAnalysis.scattermatrix(DataFrame(randn(10,3)))
ExperimentalAnalysis.scattermatrix(DataFrame(randn(10,3)), reglines=true)
ExperimentalAnalysis.scattermatrix(DataFrame(randn(10,3)), f ~ x1 + x2)
ExperimentalAnalysis.scattermatrix(DataFrame(randn(10,3)), x3 ~ x1 + x2)
ExperimentalAnalysis.scattermatrix(randn(10,3),["x1", "x2", "x3"])
modela = lm(b ~ a + c, df)
modelb = lm(d ~ a + c, df)
ExperimentalAnalysis.scattermatrix([modela, modelb])
ExperimentalAnalysis.modelheatmap(["a", "b"], modela, modelb)
```
"""
function scattermatrix(df::DataFrame; reglines = false)
  N, Nparams = size(df)
  p = plot(layout=(Nparams, Nparams))
  # Plot df
  for (i,is) = enumerate(names(df))
    for (j,js) = enumerate(names(df))
      x = isa(df[Symbol(js)], Vector{Float64}) ? df[Symbol(js)] : convert(Array,df[Symbol(js)],0)
      if i != j
        y = isa(df[Symbol(js)], Vector{Float64}) ? df[Symbol(is)] : convert(Array,df[Symbol(is)],0)
        scatter!(p[i,j],x,y,legend=false,grid=true)
        if reglines
          k = [x ones(N)]\y
          px = [minimum(x), maximum(x)]
          plot!(p[i,j], px, k[1].*px + k[2], c=:red)
        end
      else
        plot!(p[i,j],x,l=:histogram, legend=false)
      end
    end
  end
  names_ = string.(names(df))
  for i = 1:Nparams
    plot!(p[1,i], title=("\$"*names_[i]*"\$"))
    plot!(p[i,1], ylabel=("\$"*names_[i]*"\$"))
  end
  for i = 1:Nparams-1, j = 1:Nparams
    plot!(p[i,j], xticks=Float64[])
  end
  for i = 1:Nparams, j = 2:Nparams
    plot!(p[i,j], yticks=Float64[])
  end
  return p
end

function scattermatrix(df::DataFrame, f::Formula; reglines = false)
  rhs = f.rhs.args
  @assert rhs[1] == :+ "Only addition formulas supported (a ~ b + c + d + e)"
  if isa(f.lhs, Expr)
    @assert f.lhs.args[1] == :+ "Only addition formulas supported (a + b ~ c + d + e)"
    scattermatrix_someofothers(df, f, reglines=reglines)
  else
    scattermatrix(df[Symbol.(rhs[2:end])], reglines=reglines)
  end
end

function scattermatrix{T<:AbstractString}(A::AbstractMatrix, names::AbstractVector{T}; reglines = false)
  df = DataFrame(Any[A[:,i] for i = 1:size(A,2)], Symbol.(names))
  scattermatrix(df, reglines=reglines)
end


function scattermatrix{T <: Real}(A::AbstractMatrix{T}; reglines = false)
  df = DataFrame(A)
  scattermatrix(df, reglines=reglines)
end


scattermatrix(model::DataFrames.DataFrameRegressionModel) = scattermatrix([model])
function scattermatrix{T<:DataFrames.DataFrameRegressionModel}(models::AbstractVector{T})
  Nparams = size(models[1].model.pp.X,2)-1
  Nmodels = length(models)
  p = plot(layout=(Nmodels, Nparams))


  # Plot df
  for (i,model) = enumerate(models)
    df = model.mf.df
    data = model.model.pp.X[:,2:end]
    y = df[:,1]
    names_ = names(df)
    plot!(p[i,1], ylabel=("\$"*string(names_[1])*"\$"))
    # P-value color coding
    P = Pvalues(model)
    yhat = predict(model)
    for j = 1:size(data,2)
      x = data[:,j]
      scatter!(p[i,j],x,y,legend=false,grid=true)
      # Regline
      minx,mini = findmin(x)
      maxx,maxi = findmax(x)
      py = yhat[[mini, maxi]]
      px = [minx, maxx]

      plot!(p[i,j], px, py, c=P2c(P[j+1]))
    end
  end
  names_ = map(x->replace(string(x),"&","\\cdot"),models[1].mf.terms.terms)
  for i = 1:Nparams
    plot!(p[1,i], title=("\$"*names_[i]*"\$"))
  end
  for i = 1:Nmodels-1, j = 1:Nparams
    plot!(p[i,j], xticks=Float64[])
  end
  for i = 1:Nmodels, j = 2:Nparams
    plot!(p[i,j], yticks=Float64[])
  end
  return p

end

function scattermatrix_someofothers(df::DataFrame, f::Formula; reglines = false)

  Nl = length(f.lhs.args)-1
  Nr = length(f.rhs.args)-1
  p = plot(layout=(Nr, Nl))
  # Plot df
  namesl = Array(AbstractString,Nl)
  namesr = Array(AbstractString,Nr)
  for (i,is) = enumerate(f.lhs.args[2:end])
    for (j,js) = enumerate(f.rhs.args[2:end])
      namesl[i] = "\$"*string(is)*"\$"
      namesr[j] = "\$"*string(js)*"\$"
      x = df[js]
      if is != js
        scatter!(p[i,j],x,df[is],legend=false, grid=true)
        if reglines
          k = [x.data ones(size(x,1))]\(df[is].data)
          px = [minimum(x), maximum(x)]
          plot!(p[i,j], px, k[1].*px + k[2], c=:red)
        end
      else
        plot!(p[i,j],df[is],l=:histogram, legend=false)
      end
    end
  end

  for i = 1:Nr
    plot!(p[1,i], title=namesr[i])
  end
  for i = 1:Nl
    plot!(p[i,1], ylabel=namesl[i])
  end
  for i = 1:Nl-1, j = 1:Nr
    plot!(p[i,j], xticks=Float64[])
  end
  for i = 1:Nl, j = 2:Nr
    plot!(p[i,j], yticks=Float64[])
  end
  return p
end





modelheatmap{T<: AbstractString}(modelnames::AbstractArray{T}, models...) = modelheatmap(modelnames, collect(models))

function modelheatmap(model::DataFrames.DataFrameRegressionModel)
  modelnames = [string(model.mf.terms.eterms[1])]
  modelheatmap(modelnames,[model])
end

function modelheatmap{T<:DataFrames.DataFrameRegressionModel}(models::AbstractArray{T})
  modelnames = AbstractString[string(models[i].mf.terms.eterms[1]) for i = eachindex(models)]
  modelheatmap(modelnames,models)
end

"""
Plot a model heatmap

example:
```
modela = lm(b ~ a + c, df)
modelb = lm(d ~ a + c, df)
ExperimentalAnalysis.modelheatmap(modela, modelb)
```

`modelheatmap(modelnames::AbstractArray, models::AbstractArray)`

`modelheatmap(models::AbstractArray)`

`modelheatmap(model::DataFrameRegressionModel)`

`modelheatmap(modelnames::AbstractArray, models...)`
"""
function modelheatmap{T<:DataFrames.DataFrameRegressionModel, D<: AbstractString}(modelnames::AbstractArray{D}, models::AbstractArray{T})
  Nmodels = length(models)
  Nparams = length(coef(models[1].model))
  P = Array(Float64, Nparams, Nmodels)
  coefnames = GLM.coeftable(models[1]).rownms
  tickvec = ["\$"*replace(coefnames[i],"&","\\cdot")*"\$" for i = 1:Nparams]
  for (i,mm) in enumerate(models)
    P[:,i] = Pvalues(mm.model)
  end
  logP = max(log10(P),-4)
  p = heatmap(logP', xticks=(eachindex(tickvec)-1, tickvec), yticks=(eachindex(modelnames)-1, modelnames), title="log(P)-values", colorbar=true)
end


#

# Example

function perform_example_analysis()
  A = readcsv(joinpath(dirname(@__FILE__),"results.csv"));

  df = DataFrame(Any[A[2:end,i] for i = 1:size(A,2)], Symbol.(A[1,:][:]));
  pool!(df,[:Location, :Substract, :Trial]);

  for name in names(df)
    s = Symbol(name)
    if !isa(df[s], DataArrays.PooledDataArray)
      df[s] = Float64.(df[s])
    end
  end

  df = df[14:end,:];

  model = lm(percentage ~ galacosidase +  endomannanase + Firstratio + Duration, df)

  scattermatrix(df[[:percentage, :galacosidase, :endomannanase, :Biocelulasa, :Firstratio, :Secondratio, :Duration]]);gui()
  scattermatrix(model);gui()
  modelheatmap(model);gui()

  return nothing
end
