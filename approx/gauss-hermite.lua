--[[
evaluates the infinite integral of f(x)
by approximating with the Gauss-Hermite formula / Hermite polynomials
--]]
local hermite = require 'math.hermite'
local factorial = require 'math.factorial'
local sqrtpi = math.sqrt(math.pi)
function gaussHermite.approx(f,n)
    local sum = 0
    for i=1,n do
        local xi = require 'math.nan'   --... the kth zero of hermite(x,n)
        local wi = (2^(n-1) * factorial(n) * sqrtpi)
                / (n * hermite(xi,n-1))^2
        sum = sum + wi * math.exp(xi*xi) * f(xi)
    end
    return sum
end
return gaussHermite
