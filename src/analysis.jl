using DataFrames
using GLM
using Plots


function scattermatrix(df::DataFrame)
  (N, Nparams) = size(df)
  p = Plots.subplot(n = Nparams^2, nr=Nparams)
  # Plot df
  for (i,is) = enumerate(names(df))
    for (j,js) = enumerate(names(df))
      if i != j
        Plots.scatter!(p[i,j],df[Symbol(js)],df[Symbol(is)],legend=false)
      else
        Plots.plot!(p[i,j],df[Symbol(is)],l=:histogram, legend=false)
      end
    end
  end
  names_ = names(df)
  for i = 1:Nparams
    plot!(p[1,i], title=names_[i])
    plot!(p[i,1], ylabel=names_[i])
  end
  return p
end

function scattermatrix(df::DataFrame, f::Formula)
  rhs = f.rhs.args
  @assert rhs[1] == :+ "Only addition formulas supported (a ~ b + c + d + e)"
  scattermatrix(df[map(Symbol,rhs[2:end])])
end

# Potential Bug in DataFrames
# function scattermatrix{T<:AbstractString}(A::AbstractMatrix, names::AbstractVector{T})
#   df = DataFrame([A[:,i] for i = 1:size(A,2)], map(Symbol,names))
#   scattermatrix(df)
# end



function scattermatrix(A::AbstractMatrix)
  df = DataFrame(A)
  scattermatrix(df)
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
