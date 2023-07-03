--[[
Chebyshev polynomials:
recurrence relation:
T[0](x) = 1
U[-1](x) = 0
T[n+1](x) = x * T[n](x) - (1 - x*x) * U[n-1](x)
U[n](x) = x * U[n-1](x) + T[n](x)
derivative:
T'[n](x) = n * U[n-1](x)
--]]
local chebyshev = {}

chebyshev.first = {
    [0] = {f = function(x) return 1 end},
    [1] = {f = function(x) return x end},
    [2] = {f = function(x) return -1 + x*x*2 end},
    [3] = {f = function(x) return x*(-3 + x*x*4) end},
    [4] = {f = function(x) return 1 + x*x*(-8 + x*x*8) end},
    [5] = {f = function(x) return x*(5 + x*x*(-20 + x*x*16)) end},
    [6] = {f = function(x) return -1 + x*x*(18 + x*x*(-48 + x*x*32)) end},
    [7] = {f = function(x) return x*(-7 + x*x*(56 + x*x*(-112 + x*x*64))) end},
    [8] = {f = function(x) return 1 + x*x*(-32 + x*x*(160 + x*x*(-256 + x*x*128))) end},
    [9] = {f = function(x) return x*(9 + x*x*(-120 + x*x*(432 + x*x*(-576 + x*x*256)))) end},
    [10] = {f = function(x) return -1 + x*x*(50 + x*x*(-400 + x*x*(1120 + x*x*(-1280 + x*x*512)))) end},
    --[11] = {f = function(x) return x*(-11 + x*x*(220 + x*x*(-1232 + x*x*(2816 + x*x*(-2816 + x*x*1024))))) end},
}

chebyshev.second = {
    [0] = {f = function(x) return 1 end},
    [1] = {f = function(x) return x*2 end},
    [2] = {f = function(x) return -1 + x*x*4 end},
    [3] = {f = function(x) return x*(-4 + x*x*8) end},
    [4] = {f = function(x) return 1 + x*x*(-12 + x*x*16) end},
    [5] = {f = function(x) return x*(6 + x*x*(-32 + x*x*32)) end},
    [6] = {f = function(x) return -1 + x*x*(24 + x*x*(-80 + x*x*64)) end},
    [7] = {f = function(x) return x*(-8 + x*x*(80 + x*x*(-192 + x*x*128))) end},
    [8] = {f = function(x) return 1 + x*x*(-40 + x*x*(240 + x*x*(-448 + x*x*246))) end},
    [9] = {f = function(x) return x*(10 + x*x*(-160 + x*x*(672 + x*x*(-1024 + x*x*512)))) end},
}

for n=0,#chebyshev.first do
    local chebyshevPoly = chebyshev.first[n]
    chebyshevPoly.roots = table()
    chebyshevPoly.weights = table()
    for k=1,n do
        -- k'th chebyshev root:
        local x = math.cos(math.pi/2 * (2*k-1)/n)
        chebyshevPoly.roots[k] = math.cos(math.pi/2 * (2*k-1)/n)
        -- k'th chebyshev weight for gaussian quadrature:
        local deriv = k * chebyshev.second[k-1].f(x) 
        chebyshevPoly.weights[k] = 1/math.sqrt(1 - x*x) 
    end
end

return chebyshev

