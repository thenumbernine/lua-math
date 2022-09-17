local nan = require 'math.nan'
local choose = require 'math.choose'
local function bernstein(x,i,n)
    if x >= 0 and x <= 1 then
        return choose(n,i) * (1-x)^(n-i) * x^i
    end
    return nan
end
return bernstein
