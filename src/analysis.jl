using DataFrames
using GLM
using PyPlot

@debug function pairs(data)
  (nobs, nvars) = size(data)
  p = Plots.subplot(n = nvars^2, nr=nvars)
  # Plot data
  for (i,is) = enumerate(names(data))
    for (j,js) = enumerate(names(data))
      if i != j
        Plots.scatter!(p[i,j],data[Symbol(js)],data[Symbol(is)])
      else
        Plots.plot!(p[i,j],data[Symbol(is)],l=:histogram)
      end
    end
  end
  names_ = names(data)
  for i = 1:nvars
    plot!(p[1,i], title=names_[i])
    plot!(p[i,1], ylabel=names_[i])
  end

end

# Example


A = readcsv("results.csv");

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



pairs(df[[:percentage, :galacosidase, :endomannanase, :Biocelulasa, :Firstratio, :Secondratio, :Duration]])
