local bernstein = require 'math.bernstein'
-- TODO make this work for any interval and not just [0,1]
local function bernsteinApprox(f,n)
    return function(x)
        local sum = 0 
        for i=0,n do
            sum = sum + f(i/n) * bernstein(x,i,n) 
        end
        return sum
    end
end
return bernsteinApprox
