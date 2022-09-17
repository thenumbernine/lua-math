local class = require 'ext.class'
local Complex = require 'math.complex'

-- represent coefficients in degree order.  self[1] is the 0'th degree
local Polynomial = class()

function Polynomial:init(...)
    local args = {...}
    for i=1,#args do
        -- assume it work as a number
        self[i] = args[i]
    end
end

function Polynomial:__call(x)
    local y = 0
    local xp = 1    -- current power of x.  starts at x^0, multiply x each iteration
    for i=1,#self do
        y = y + self[i] * xp
        xp = xp * x
    end
    return y
end

function Polynomial.__unm(a)
    if type(a) == 'number' then a = Polynomial(a) end
    local c = Polynomial()
    for i=1,#a do
        c[i] = -a[i]
    end
    c:removeLeadingZeroes()
    return c
end

function Polynomial.__eq(a,b)
    if type(a) == 'number' then a = Polynomial(a) end
    if type(b) == 'number' then b = Polynomial(b) end
    a:removeLeadingZeroes()
    b:removeLeadingZeroes()
    if #a ~= #b then return false end
    for i=1,#a do
        if a[i] ~= b[i] then return false end
    end
    return true
end

function Polynomial.__add(a,b)
    if type(a) == 'number' then a = Polynomial(a) end
    if type(b) == 'number' then b = Polynomial(b) end
    local c = Polynomial()
    for i=1,math.max(#a,#b) do
        c[i] = (a[i] or 0) + (b[i] or 0)
    end
    c:removeLeadingZeroes()
    return c
end

function Polynomial.__sub(a,b)
    if type(a) == 'number' then a = Polynomial(a) end
    if type(b) == 'number' then b = Polynomial(b) end
    local c = Polynomial()
    for i=1,math.max(#a,#b) do
        c[i] = (a[i] or 0) - (b[i] or 0)
    end
    c:removeLeadingZeroes()
    return c
end

function Polynomial.__mul(a,b)
    if type(a) == 'number' then a = Polynomial(a) end
    if type(b) == 'number' then b = Polynomial(b) end
    local c = Polynomial()
    for i=1,#a+#b-1 do
        local s = 0
        for j=1,i do
            s = s + (a[j] or 0) * (b[i-j+1] or 0)
        end
        c[i] = s
    end
    c:removeLeadingZeroes()
    return c
end

function Polynomial.__div(a,b)
    if type(a) == 'number' then a = Polynomial(a) end
    if type(b) == 'number' then b = Polynomial(b) end
    local q = Polynomial(Complex())
    local r = a
    local iter = 0
    local reason
    while r ~= Complex(0) and #r >= #b do
        local xn = #r - #b
        local t = table()
        for i=1,xn do
            t[i] = 0
        end
        t[#t+1] = r[#r] / b[#b]
        t = Polynomial(unpack(t))
        --print(q,r,xn,t)
        q = q + t
        r = r - t * b
        iter = iter + 1
        if iter > 100 then 
            reason = 'Polynomial::__div took too many iterations to converge'
            break
        end
    end
    return q, r, reason     -- using the operator throws away all but the first value 
end

function Polynomial:degree()
    self:removeLeadingZeroes()
    return #self-1
end

function Polynomial:diff()
    local dp = Polynomial()
    for i=1,#self-1 do
        dp[i] = self[i+1] * i
    end
    return dp
end

function Polynomial:removeLeadingZeroes()
    for i=#self,2,-1 do
        if self[i] == Complex(0) then self[i] = nil else break end
    end
end

-- find a root
function Polynomial:findRoot(x0)
    -- smallest step size before bailing out
    local epsilon = 1e-15
    -- calc derivatives
    local diff = self:diff()
    local diff2 = diff:diff()
    -- do our evaluation
    local x = Complex(x0)
    local iter = 0
    local reason
    while true do
        -- calculate poly to find root of - as well as derivs to be used
        local yp = self(x)
        local ydp = diff(x)
        local yd2p = diff2(x)
        -- [[ Laguerre's method
        if Complex.abs(yp) < epsilon then
            reason = 'function value too small near root'
            break
        end
        local g = ydp / yp
        local h = g * g - yd2p / yp
        local sqrtDiscriminant = Complex.sqrt(4 * (5 * h - g * g))
        local denom1 = (g + sqrtDiscriminant) 
        local denom2 = (g - sqrtDiscriminant) 
        local denom = Complex.abs(denom1) > Complex.abs(denom2) and denom1 or denom2
        if Complex.abs(denom) < epsilon then
            reason = 'step quotient denominator too small'
            break
        end
        local xn = x - 5 / denom
        --]]
        --[[ Halley's method
        local denom = 2 * ydp * ydp - yp * yd2p
        if Complex.abs(denom) < epsilon then
            reason = 'step quotient denominator too small'
            break
        end
        local xn = x - 2 * yp * ydp / denom 
        --]]
        --[[ Newton's method
        if Complex.abs(ydp) < epsilon then
            reason = 'derivative too small near root'
            break
        end
        local xn = x - yp / ydp
        --]]
        --[[ circular trust region
        local xn1 = x + (ydp - Complex.sqrt(ydp * ydp + 2 * yd2p * (ydp - yp) )) / yd2p
        local xn2 = x - (ydp + Complex.sqrt(ydp * ydp + 2 * yd2p * (ydp - yp) )) / yd2p
        local a1 = xn1 - x
        local a2 = xn2 - x
        local xn = Complex.abs(a1) < Complex.abs(a2) and xn1 or xn2 
        --]]
        local a = x - xn
        local la = Complex.abs(a)
        --print(iter,la)
        if la < epsilon then 
            reason = 'epsilon too small for step '..la
            break 
        end  -- reached the end of our calculations
        x = xn
        iter = iter + 1
        if iter > 100 then
            reason = 'Polynomial:findRoot took too many iterations to converge'
            break
        end
    end
    return x, reason
end

function Polynomial:findRoots()
    self:removeLeadingZeroes()
    local roots = table()
    if #self == 1 then
        --if self[1] == '0' then return range(-math.inf,math.inf) end
        --print('tried to get const roots')
    elseif #self == 2 then
        -- y = ax + b <=> x = -b/a
        local b, a = unpack(self)
        if self[2] ~= 0 then 
            roots:insert(-b/a)
        end
        --print('linear found roots',unpack(roots))
    elseif #self == 3 then
        -- y = ax^2 + bx + c <=> x = (-b+-sqrt(b^2-4ac))/(2a)
        local c, b, a = unpack(self)
        local discr = Complex.sqrt(b*b - 4*a*c)
        if discr == 0 then
            roots:insert(-b/(2*a))
        else
            roots:insert((-b+discr)/(2*a))
            roots:insert((-b-discr)/(2*a))
        end
        --print('quadratic found roots',unpack(roots))
    else
        -- find one root, factor it, recurse
        local root, reason = self:findRoot(0)
        roots:insert(root)
        -- divide by (x-root)
        --print('poly quotient found root',root,type(root))
        local q = self / Polynomial(-root, 1)
        --if #q == #self then error("polynomial division of root did not lower degree!") end
        roots:append(q:findRoots())
    end
    return roots
end

function Polynomial:__tostring()
    self:removeLeadingZeroes()
    local s = table()
    for i=#self,1,-1 do
        local xp
        if i == 1 then 
            xp = ''
        elseif i == 2 then
            xp = 'x'
        elseif i > 2 then
            xp = 'x^'..(i-1)
        end
        local c = self[i]
        if i > 1 and c == 1 then c = '' end
        if c ~= 0 then
            s:insert(c..xp)
        end
    end
    if #s == 0 then s:insert(0) end
    return s:concat(' + ')
end

function Polynomial.__concat(a,b) return tostring(a) .. tostring(b) end

return Polynomial
