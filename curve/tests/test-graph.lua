require 'ext'
local Graph = require 'graph'
local chebyshev = require 'math.chebyshev'

local plots = table()
--[[ chebyshev plots
for i=1,5 do
    plots:insert{f = chebyshev.first[i].f}
end
--]]

-- [[ function approximation (first step to numeric integration)
    -- source function
local f = function(x) return x end 
local integralF = function(x) return .5*x*x-.5 end 
-- [=[
plots:insert{f=f}
plots:insert{f=integralF}
--]=]

-- [=[ bernstein -- check
local bernsteinApprox = require 'math.approx.bernstein'
plots:insert{f = bernsteinApprox(f,10)}
--]=]

--[=[ legendre
local gaussLegendreApprox = require 'math.approx.gauss-legendre'
print('gaussLegendreApprox ',gaussLegendreApprox )
plots:insert{f=gaussLegendreApprox(f,10)}
--]=]

--[=[ hermite
local gaussHermiteApprox = require 'math.approx.gauss-hermite'
plots:insert{f=gaussHermiteApprox(f,10)}

--]=]

--[=[ chebyshev
local gaussChebyshevApprox = require 'math.approx.gauss-chebyshev'
plots:insert{f=gaussChebyshevApprox}
--]=]
--]]

Graph{plots=plots, gridSize=vec3(10, 10, 10)}()
