local GLApp = require 'glapp'
local vec3 = require 'vec.vec3'
local class = require 'ext.class'
local table = require 'ext.table'
local gl = require 'gl'
local NURBSCurve = require 'math.curve.nurbs'
local BezierCurve = require 'math.curve.bezier'

local curves = table()

    -- # cpts = # knots - # degrees - 1
local function pickNRandomPoints(n)
    local pts = table()
    for i=1,n do
        pts:insert(vec3(
            math.random()-.5,
            math.random()-.5,
            math.random()-.5
        ))
    end
    return pts
end

local function pickKnots(n,degree)
    local knots = table()
    for i=1,degree+1 do
        knots:insert(0)
    end
    local rampcount = n - 2 * (degree + 1)
    for i=1,rampcount do
        knots:insert(i/(rampcount+1))
    end
    for i=1,degree+1 do
        knots:insert(1)
    end
    return knots
end

--[[ single curve segments (non-piecewise)

-- cubic curve
curves:insert(NURBSCurve{
    degree = 3, 
    controlPoints = pickNRandomPoints(4),
    knots = pickKnots(8,3),
})

-- quadratic curve 
curves:insert(NURBSCurve{
    degree = 2,
    controlPoints = pickNRandomPoints(3),
    knots = pickKnots(6,2),
})

-- line
curves:insert(NURBSCurve{
    degree = 1,
    controlPoints = pickNRandomPoints(2),
    knots = pickKnots(4, 1),
})
--]]

--[[ piecewise curves

-- line
-- [=[ 
curves:insert(NURBSCurve{
    degree = 1,
    controlPoints = pickNRandomPoints(5),
    knots = pickKnots(7,1),
})
--]=]

-- quadratic
curves:insert(NURBSCurve{
    degree = 2,
    controlPoints = pickNRandomPoints(6),
    knots = pickKnots(9,2),
})
--]]

--[[ bunch of random crap
for i=1,20 do
    local degree = math.random(1,5)
    local numcpts = math.random(degree+1, degree+10)
    local numknots = numcpts + degree + 1

    curves:insert(NURBSCurve{
        degree = degree,
        controlPoints = pickNRandomPoints(numcpts),
        knots = pickKnots(numknots, degree),
    })
end
--]]

-- [[ under-providing control points works
curves:insert(NURBSCurve{
    degree = 3,
    controlPoints = pickNRandomPoints(2),
    knots = pickKnots(6,3),
})
--]]

--[[ unit test equivalent
table{false, 1}:map(function(opt)
    local degree = 3
    local nCtlPts = 11
    local ctlPts = table()
    local yofs = 0   -- opt and .2 or 0
    for i=0,nCtlPts-1 do
        ctlPts:insert{.1 * i - .5, yofs, 0}
    end
    for m=0,degree-2 do
        ctlPts:insert{.5,yofs,0}
    end
    local knots = table()
    for i=0,degree do
        knots:insert(0)
    end
    for i=1,nCtlPts-2 do
        knots:insert(i/(nCtlPts-1))
    end
    for i=0,degree do
        knots:insert(1)
    end
    print('degree',degree)
    print('num control points',nCtlPts,#ctlPts)
    print('num knots',#knots)
    print('knots',unpack(knots))
    local curve = NURBSCurve{
        degree = degree,
        controlPoints = ctlPts,
        knots = knots,
    }   
    curve.optimize = opt
    curves:insert(curve)

    print('front knot value:',curve(curve.knots[1]))
    print('back knot value:',curve(curve.knots[#curve.knots]))
end)
--]]

--[[ test against bezier curve
local bezierCurve = BezierCurve{controlPoints=controlPoints}
curves:insert(bezierCurve)
--]]

local allCurveCpts = table()
for _,curve in ipairs(curves) do
    for _,cpt in ipairs(curve.controlPoints) do
        allCurveCpts:insert(cpt)
    end
end
local colors = table()
for i = 1,#curves do
    local r, g, b = math.random(), math.random(), math.random()
    local l = math.sqrt(r*r + g*g + b*b) 
    if l < 1 then
        r = r / l
        g = g / l
        b = b / l
    end
    colors[i] = {r,g,b}
end

-- globals and debugging.  yup.
debugline = table() 

return class(GLApp, {
    vtxs = allCurveCpts,
    init = function(app, ...)
        app.view.pos[3] = 1
        app.view.zNear = .1
        app.view.zFar = 100
    end,
    draw = function(app)
        for i,curve in ipairs(curves) do
            
            gl.glColor3f(1,0,0)
            gl.glBegin(gl.GL_POINTS)
            for _,cpt in ipairs(curve.controlPoints) do
                gl.glVertex3f(unpack(cpt))
            end
            gl.glEnd()
            gl.glColor3f(unpack(colors[i]))
            gl.glBegin(gl.GL_LINE_STRIP)
            local n = 100
            for j=0,n do
                gl.glVertex3f(unpack(curve(j/n)))
            end
            gl.glEnd() 
        
            if curve.optimize then
                if debugline then
                    io.writefile('indexes.txt', debugline:concat('\n'))
                    debugline = nil
                end
            end
        
        end
    end,
})()
