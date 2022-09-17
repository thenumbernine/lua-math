require 'ext'
local class = require 'ext.class'
local vec3 = require 'vec3'
local Polynomial = require 'math.polynomial'
local Complex = require 'math.complex'

local BezierCurve = class()

function BezierCurve:init(args)
    local controlPoints = assert(args.controlPoints, "expected controlPoints")
    
    self.controlPoints = table()
    for _,cpt in ipairs(controlPoints) do
        self.controlPoints:insert(vec3(unpack(cpt)))
    end
end

--[[
evaluate Bezier curve at t, for t within the inteval [0,1]
--]]
function BezierCurve:__call(t)
    local x = vec3()
    for i=1,4 do
        x = x + self.controlPoints[i] * (self.basisFunctions[i])(t) 
    end
    return x
end

--[[
Bernstein polynomials: 
    B[p,q](t) = (p choose q) * (1 - t)^(q - p) * t^p
              = q!/(p!*(q-p)!) * (1 - t)^(q - p) * t^p
t is in the interval [0,1]
q is the degree of the polynomial (fixed at 3 for this)
p is the index of the Bernstein polynomial: an integer from 0 to q
--]]
BezierCurve.basisFunctions = {
    function(t) return (1-t)^3 end,         -- B[0,3]
    function(t) return 3 * (1-t)^2 * t end, -- B[1,3]
    function(t) return 3 * (1-t) * t^2 end, -- B[2,3]
    function(t) return t^3 end,             -- B[3,3]
}

--[[
c(t) = c0 (1-t)^3 + c1 3 t (1-t)^2 + c2 3 t^2 (1-t) + c3 t^3
...in polynomial form...
c(t) = c0 (1 - 3t + 3t^2 - t^3) + c1 3t (1 - 2t + t^2) + c2 3t^2 (1 - t) + c3 t^3
c(t) = c0 (1 - 3t + 3t^2 - t^3) + c1 (3t - 6t^2 + 3t^3) + c2 (3t^2 - 3t^3) + c3 t^3
c(t) = (c0 - 3t c0 + 3t^2 c0 - t^3 c0) + (3t c1 - 6t^2 c1 + 3t^3 c1) + (3t^2 c2 - 3t^3 c2) + t^3 c3
c(t) = c0 + t (-3 c0 + 3 c1) + t^2 (3 c0 - 6 c1 + 3 c2) + t^3 (-c0 + 3 c1 - 3 c2 + c3)
c(t) = (-c0 + 3 c1 - 3 c2 + c3) t^3 + (3 c0 - 6 c1 + 3 c2) t^2 + (-3 c0 + 3 c1) t + c0
returns in degree order (i.e. constant first, linear second, etc)
--]]
function BezierCurve:polyVectors()
    local a = -self.controlPoints[1] 
        + 3 * self.controlPoints[2]
        - 3 * self.controlPoints[3]
        + self.controlPoints[4]
    local b = 3 * self.controlPoints[1]
            - 6 * self.controlPoints[2]
            + 3 * self.controlPoints[3]
    local c = -3 * self.controlPoints[1]
            + 3 * self.controlPoints[2]
    local d = self.controlPoints[1]
    return d,c,b,a
end

--[[
closest point on bezier curve to our desired point

d/dx|(ax^3 + bx^2 + cx + d) - p|^2 = 0
d/dx|c(x)-p|^2 = 0
d/dx[c(x)^2 - 2 c(x) . p + p^2] = 0
2 c(x) . c'(x) - 2 c'(x) . p = 0
2 (c(x) - p) . c'(x) = 0
(c(x) - p) . c'(x) = 0
(ax^3 + bx^2 + cx + d-p) . (3ax^2 + 2bx + c) = 0
3 a.a x^5 
    + 5 a.b x^4 
    + (4 a.c + 2 b.b) x^3 
    + (3 b.c + 3 (d-p).a) x^2 
    + (c.c + 2 b.(d-p)) x 
    + c.(d-p) = 0
solve the poly:
p5 x^5 + p4 x^4 + p3 x^3 + p2  x^2 + p1  x + p0 = 0

start in the middle of our parameterization: x = 1/2 or so
and newton iterate!
x[n+1] = x[n] - f(x) / f'(x)
or subdivide or something!
--]]
function BezierCurve:closestPointParameter(pt)
    local d, c, b, a = self:polyVectors()
    d = d - pt   -- offset up front.  all our calculations use the offset constant term, so don't bother keep the original
    -- represent coefficients in degree order.  p[1] is the 0'th degree
    local epsilon = 1e-5
    -- create a poly representation of the function of the distance-squared
    local poly = Polynomial(
        c:dot(d),   --constant
        c:lengthSq() + 2 * b:dot(d),     --linear
        3 * b:dot(c) + 3 * a:dot(d),  --quadratic
        4 * a:dot(c) + 2 * b:lengthSq(),   --cubic
        5 * a:dot(b),   --quartic
        3 * a:lengthSq())  --quintic
    local xs = poly:findRoots() -- get its roots (coinciding with min/max of poly)
        :map(function(x) return Complex.real(x) end)           -- only use real part
        :map(function(x) return math.clamp(x,0,1) end)   -- clamp them to within [0,1] 
    xs:insert(1,0)  -- put a 0 at beginning
    xs:insert(1)    -- put a 1 at end
    local bestx, bestlx
    for _,x in ipairs(xs) do
        local px = self(x)
        local lx = (px - pt):lengthSq()
        if not bestx or lx < bestlx then
            bestlx = lx
            bestx = x
        end
    end
    return bestx
end

function BezierCurve:closestPoint(pt)
    return self(self:closestPointParameter(pt))
end

return BezierCurve

