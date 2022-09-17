local factorial = require 'math.factorial'
local function choose(n,i) -- TODO optimize plz
    return factorial(n) / (factorial(i) * factorial(n-i))
end
return choose
