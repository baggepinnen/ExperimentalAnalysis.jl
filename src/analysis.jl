using DataFrames
using GLM
using Plots
import PyPlot

"""
`scattermatrix(df::DataFrame)`

`scattermatrix(df::DataFrame, f::Formula)`

`scattermatrix(A::AbstractMatrix)`

Plot a scatter matrix of a DataFrame or a numerical matrix
"""
function scattermatrix(df::DataFrame)
  (N, Nparams) = size(df)
  p = Plots.subplot(n = Nparams^2, nr=Nparams)
  # Plot df
  for (i,is) = enumerate(names(df))
    for (j,js) = enumerate(names(df))
      if i != j
        Plots.scatter!(p[i,j],df[Symbol(js)],df[Symbol(is)],legend=false,grid=false)
      else
        Plots.plot!(p[i,j],df[Symbol(is)],l=:histogram, legend=false)
      end
    end
  end
  names_ = names(df)
  for i = 1:Nparams
    plot!(p[1,i], title="\$"*names_[i]*"\$")
    plot!(p[i,1], ylabel="\$"*names_[i]*"\$")
  end
  for i = 1:Nparams-1, j = 1:Nparams
    plot!(p[i,j], xticks=Float64[])
  end
  for i = 1:Nparams, j = 2:Nparams
    plot!(p[i,j], yticks=Float64[])
  end
  return p
end

function scattermatrix(df::DataFrame, f::Formula)
  rhs = f.rhs.args
  @assert rhs[1] == :+ "Only addition formulas supported (a ~ b + c + d + e)"
  if isa(f.lhs, Expr)
    @assert f.lhs.args[1] == :+ "Only addition formulas supported (a + b ~ c + d + e)"
    scattermatrix_someofothers(df, f)
  else
    scattermatrix(df[map(Symbol,rhs[2:end])])
  end
end

function scattermatrix{T<:AbstractString}(A::AbstractMatrix, names::AbstractVector{T})
  df = DataFrame(Any[A[:,i] for i = 1:size(A,2)], map(Symbol,names))
  scattermatrix(df)
end



function scattermatrix(A::AbstractMatrix)
  df = DataFrame(A)
  scattermatrix(df)
end




function scattermatrix_someofothers(df::DataFrame, f::Formula)

  Nl = length(f.lhs.args)-1
  Nr = length(f.rhs.args)-1
  p = Plots.subplot(n = Nl*Nr, nr=Nl)
  # Plot df
  namesl = Array(AbstractString,Nl)
  namesr = Array(AbstractString,Nr)
  for (i,is) = enumerate(f.lhs.args[2:end])
    for (j,js) = enumerate(f.rhs.args[2:end])
      namesl[i] = "\$"*string(is)*"\$"
      namesr[j] = "\$"*string(js)*"\$"
      if is != js
        Plots.scatter!(p[i,j],df[js],df[is],legend=false, grid=false)
      else
        Plots.plot!(p[i,j],df[is],l=:histogram, legend=false)
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


modelheatmap(modelnames, models...) = modelheatmap(modelnames, collect(models))
function modelheatmap{T<:DataFrames.DataFrameRegressionModel}(modelnames, models::AbstractArray{T})
    Nmodels = length(models)
    Nparams = length(coef(models[1].model))
    P = Array(Float64, Nparams, Nmodels)
    coefnames = GLM.coeftable(models[1]).rownms
    tickvec = ["\$"*coefnames[i]*"\$" for i = 1:Nparams]
    for (i,mm) in enumerate(models)
        cc = coef(mm.model)
        se = stderr(mm.model)
        zz = cc ./ se
        P[:,i] = 2.0 * ccdf(Normal(), abs(zz))
    end
    logP = max(log10(P),-4)
    p = PyPlot.matshow(logP')
    PyPlot.xticks(eachindex(tickvec)-1, tickvec)
    PyPlot.yticks(eachindex(modelnames)-1, modelnames)
    PyPlot.colorbar()
    p
end




# Example

function perform_example_analysis()
  A = readcsv(Pkg.dir("ExperimentalAnalysis","src","results.csv"));

  df = DataFrame([A[2:end,i] for i = 1:size(A,2)], map(Symbol,A[1,:][:]));
  pool!(df,[:Location, :Substract, :Trial]);

  for name in names(df)
    s = Symbol(name)
    if !isa(df[s], DataArrays.PooledDataArray)
      df[s] = map(Float64,df[s])
    end
  end

  df = df[14:end,:];

  model = lm(percentage ~ galacosidase +  endomannanase + Firstratio + Duration, df)

  scattermatrix(df[[:percentage, :galacosidase, :endomannanase, :Biocelulasa, :Firstratio, :Secondratio, :Duration]])

  return nothing
end
