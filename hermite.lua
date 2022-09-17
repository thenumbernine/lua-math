--[[
hermite polynomials
H[n](x) = 2*x*H[n-1](x) - 2*(n-1)*H[n-2](x)
--]]
local function hermite(x,n)
    -- base cases:
    if n == 0 then return 1 end
    if n == 1 then return 2*x end
    -- recursive relation:
    return 2*x*hermite(x,n-1) - 2*(n-1)*hermite(x,n-2)
end

