local class = require 'ext.class'
local vec3 = require 'vec3'

local NURBSCurve = class()

function NURBSCurve:init(args)
    local controlPoints = assert(args.controlPoints, "expected controlPoints")
    local knots = assert(args.knots, "expected knots") 
    
    self.controlPoints = table()
    for _,cpt in ipairs(controlPoints) do
        self.controlPoints:insert(vec3(unpack(cpt)))
    end

    self.knots = table(knots)

    self.degree = args.degree or 3
    
    if #self.knots ~= #self.controlPoints + self.degree + 1 then
        print('num knots',#self.knots)
        print('num cpts',#self.controlPoints)
        print('num degrees',self.degree)
        error 'invalid'
    end

    self.optimize = args.optimize
end

local epsilon = 1e-9

--[[
C(t) = (sum i=1,n N(t,i,n) P(i)) / (sum i=1,n N(t,i,n))
--]]
function NURBSCurve:__call(t)
    -- sum of basis functions ...
    local x = vec3()
    local total = 0
    
    if self.optimize == 1 then
    -- [[ only evaluate the used control points
        local firstKnot = self:findKnot(t)
        if debugline then
            debugline:insert(t..'\t'..firstKnot)
        end
        for i=firstKnot, math.min(firstKnot+self.degree+1, #self.controlPoints - 1) do
            local basisFunctionValue = self:basisFunction(t,i+1,self.degree)
            x = x + self.controlPoints[i+1] * basisFunctionValue 
            total = total + basisFunctionValue
        end
    --]]
    else
    -- [[ evaluate all control points
        for i=0,#self.controlPoints - 1 do
            local basisFunctionValue = self:basisFunction(t,i+1,self.degree)
            x = x + self.controlPoints[i+1] * basisFunctionValue 
            total = total + basisFunctionValue
        end
    --]]
    end

    if math.abs(total) >= epsilon then
        x = x / total
    end
    return x
end

-- find the latest knot before the provided parameter
-- no later than #self.knots - self.degree
function NURBSCurve:findKnot(t)
    for i = 0, #self.knots - self.degree - 1 do
        if self.knots[i+1+self.degree+1] >= t then
            return i
        end
    end
    return #self.knots - self.degree - 1
end

--[[
N[i,n](t) = f[i,n](t) * N[i,n-1](t) + g[i+1,n](t) * N[i+1,n-1](t)
--]]
function NURBSCurve:basisFunction(t,i,n)
    -- [[ piecewise heaveside influence for degree 0
    -- these are not needed unless you explicitly evaluate a degree-0 curve (piecewise stepping from control point to control point)
    if n == 0 then
        if t >= self.knots[i] and t <= self.knots[i+1] then
            return 1
        else
            return 0
        end
    end
    --]]
  
    -- for all cases, f(t,i,n) and g(t,i+1,n) are used, so calculate them here
    --local leftWeight = self:f(t,i,n)
    -- [[ inline f & g
    local leftWeight = 0
    if i < 1 or i+n > #self.knots then 
        print('degree',self.degree)
        print('n',n)
        print('i',i)
        error('out of bounds')
    end
    if math.abs(self.knots[i+n] - self.knots[i]) >= epsilon then
        leftWeight = (t - self.knots[i]) / (self.knots[i+n] - self.knots[i])
    end
    --]]
    
    --local rightWeight = self:g(t,i+1,n)
    -- [[ inline f & g
    local rightWeight = 0
    if math.abs(self.knots[i+1+n] - self.knots[i+1]) >= epsilon then
        rightWeight = (self.knots[i+1+n] - t) / (self.knots[i+1+n] - self.knots[i+1])
    end
    --]]

    -- [[ base for case n=1
    if n == 1 then
        local lhs = 0
        if t >= self.knots[i] and t <= self.knots[i+1] then
            lhs = leftWeight 
        end
        
        local rhs = 0
        if t >= self.knots[i+1] and t <= self.knots[i+2] then
            rhs = rightWeight 
        end

        return lhs + rhs
    end
    --]]
    -- general, recursive case:
    return leftWeight * self:basisFunction(t,i,n-1)
        + rightWeight * self:basisFunction(t,i+1,n-1)
end

function NURBSCurve:f(t,i,n)
    if math.abs(self.knots[i+n] - self.knots[i]) < epsilon then return 0 end
    return (t - self.knots[i]) / (self.knots[i+n] - self.knots[i])
end

function NURBSCurve:g(t,i,n)
    if math.abs(self.knots[i+n] - self.knots[i]) < epsilon then return 0 end
    return (self.knots[i+n] - t) / (self.knots[i+n] - self.knots[i])
end

--[[
C'(t) = [(sum i=1,n N'(t,i,n) P(i)) (sum i=1,n N(t,i,n)) - (sum i=1,n N(t,i,n) P(i)) (sum i=1,n N'(t,i,n))] / (sum i=1,n N(t,i,n))^2
alternatively:
C'(t) = [sum i=1,n sum j=1,n N'(t,i,n) * (P(i) - P(j)) * N(t,j,n)] / [sum i=1,n N(t,i,n)]^2
--]]
function NURBSCurve:deriv(t)
    -- quotient rule of two sums
    local sumBasisValues = 0
    local sumBasisDerivatives = 0
    local sumPointsTimesBasisValues = vec3()
    local sumPointsTimesBasisDerivatives = vec3()
    for i=0,self.degree do
        local basisValue = self:basisFunction(t,i+1,self.degree)
        local basisDerivative = self:basisFunctionDerivative(t,i+1,self.degree)
        sumPointsTimesBasisValues = sumPointsTimesBasisValues + self.controlPoints[i+1] * basisValue 
        sumPointsTimesBasisDerivatives = sumPointsTimesBasisDerivatives + self.controlPoints[i+1] * basisDerivative
        sumBasisValues = sumBasisValues + basisValue
        sumBasisDerivatives = sumBasisDerivatives + basisDerivative
    end
    return (sumPointsTimesBasisDerivatives * sumBasisValues - sumPointsTimesBasisValues * sumBasisDerivatives) / (sumBasisValues * sumBasisValues)
end

--[[
N'[i,n](t) = f'[i,n](t) * N[i,n-1](t) + f[i,n](t) * N'[i,n-1](t) 
    + g'[i+1,n](t) * N[i+1,n-1](t) + g[i+1,n](t) * N'[i+1,n-1](t)
--]]
function NURBSCurve:basisFunctionDerivative(t,i,n)
    if n == 1 then
        return 
            (t >= self.knots[i] and t <= self.knots[i+1]
            and self:df(t,i,n) or 0)
            +
            (t >= self.knots[i+1] and t <= self.knots[i+2]
            and self:dg(t,i+1,n) or 0)
    end
    if n == 0 then return 0 end -- the function is just piecewise constant, so the deriv is zero (except where undefined, but in such case the limit is zero, so...)
    local f = self:f(t,i,n)
    local g = self:g(t,i,n)
    local df = self:df(t,i,n)
    local dg = self:dg(t,i,n)
    return df * self:basisFunction(t,i,n-1)
        + f * self:basisFunctionDerivative(t,i,n-1)
        + dg * self:basisFunction(t,i+1,n-1)
        + g * self:basisFunction(t,i+1,n-1)
end

function NURBSCurve:df(t,i,n)
    if self.knots[i+n] == self.knots[i] then return 0 end
    return 1 / (self.knots[i+n] - self.knots[i])
end

function NURBSCurve:dg(t,i,n)
    if self.knots[i+n] == self.knots[i] then return 0 end
    return -1 / (self.knots[i+n] - self.knots[i])
end

-- returns the arclength of the curve
function NURBSCurve:arclength(n)
    return self:arclenghtEuler(n)
end

function NURBSCurve:arclengthEuler(n)
    -- Euler:
    local len = 0
    n = n or 100
    local lastpt = self(0)
    for i=1,n do
        local pt = self(i/n)
        len = len + (pt - lastpt):length()
        lastpt = pt
    end
    return len
end

-- arclengthBezier wouldn't be too hard to implement ...

--[[
all gaussian quadrature integration:
xi's are the roots of the polynomial between 0-1
(most polynomials have a parameter 'n' that coincides with the # of roots)
--]]

local chebyshev = require 'math.chebyshev'    -- global scope atm ...
function NURBSCurve:arclengthChebyshev(n)
    -- Gaussian quadrature (Chebyshev or any other quadrature)
    -- integral from a to b of f(x) dx = (b - a) / 2 integral from -1 to 1 of f( (b-a)/2 z + (a+b)/2) dz
    -- in our case a = 0, b = max(knots[i]), and f(x) = || d/dt NurbsCurve(t) ||
    -- iteration 0
    local sum = 0
    local a = 0
    local b = 1
    for i=1,n do
        sum = sum + chebyshev.first[n].weights[i] * 
            self:deriv( (b-a)/2 * chebyshev.first[n].roots[i] + (a+b)/2 ):length()
    end
    sum = sum * (b - a) / 2 
    return sum
end

function NURBSCurve:arclengthAdamsBashforth(n)
    local a = 0     -- parameterization endpoints
    local b = 1
    -- base case
    local l = 1     -- level
    local n = 2^l+1 -- number of nodes
    local h = (b - a) / n   -- step size for this level
    local t = table{a, (a+b)/2, b}  -- vector of parameters where we evaluate our to-be-integrated formula 
    local y = t:map(function(t) return self:deriv(t):length() end)  -- vector of formula evaluations at parameter locations
    local s = h/3*(y[1] + 4 * y[2] + y[3])
    -- recursive case
    while true do
        l = l + 1
        local s2 = s    -- copy old to new
        -- subtract differences in 4's and 2's of simpson integral evaluation
        s2 = s2 - 2 * y[2]
        -- insert new terms
        table.insert(t, 3, (t[2] + t[3]) / 2)
        table.insert(y, 3, self:deriv(t[3]):length())
        table.insert(t, 2, (t[1] + t[2]) / 2)
        table.insert(y, 2, self:deriv(t[2]):length())
        -- add new terms to integral 
        s2 = s2 + 4 * y[2] + 4 * y[4]
        -- divide our step size (and incorporate it into the arclength)
        s2 = s2 / 2
        -- complain about error
        -- simpson error is h^4/180*(b-a)*sup_xi|d^4[f(xi)]/dxi^4]|
        -- so to accurately minimize it, I need analytically the 4th derivative of the magnitude of the derivative of the curve
    end
end

return NURBSCurve
