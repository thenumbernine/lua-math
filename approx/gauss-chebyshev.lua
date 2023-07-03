local chebyshev = require 'math.chebyshev'
local function gaussChebyshevApprox(f,n)
    return function(x)
        if x < -1 or x > 1 then return require 'math.nan' end
        local sum = 0
        local a = -1
        local b = x
        local n = 10
        for i=1,n do
            local xi = (b-a)/2 * chebyshev.first[n].roots[i] + (a+b)/2
            local wi = chebyshev.first[n].weights[i]
            local fxi = f(xi) 
            sum = sum + wi * math.sqrt(1 - xi * xi) * fxi 
        end
        sum = sum * (b - a) / 2
        return sum
    end
end
return gaussChebyshevApprox
