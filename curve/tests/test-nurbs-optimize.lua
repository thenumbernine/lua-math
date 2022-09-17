local GLApp = require 'glapp'
local vec3 = require 'vec3'
local class = require 'ext.class'
local gl = require 'ffi.OpenGL'
local NURBSCurve = require 'curve.nurbs'
local BezierCurve = require 'curve.bezier'


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
    if n >= 2*(degree+1) then
        for i=1,degree+1 do
            knots:insert(0)
        end
        assert(#knots == degree+1)
        local rampcount = n - 2 * (degree + 1)
        assert(rampcount >= 0)
        for i=1,rampcount do
            knots:insert(i/(rampcount+1))
        end
        assert(n - degree - 1 == rampcount + degree + 1)
        assert(#knots == n - degree - 1) 
        for i=1,degree+1 do
            knots:insert(1)
        end
        assert(n == 2*(degree+1) + rampcount)
        assert(#knots == n)
    else
        for i=1,n do
            knots:insert(i <= n/2 and 0 or 1)
        end
        assert(#knots == n)
    end
    return knots
end

local function pickRandomColor()
    local r, g, b = math.random(), math.random(), math.random()
    local l = math.sqrt(r*r + g*g + b*b) 
    if l < 1 then
        r = r / l
        g = g / l
        b = b / l
    end
    return r,g,b
end

math.randomseed(os.time())
local optimizeMethods = table{0,1}
local totalErrors = optimizeMethods:map(function(optimize) return 0, optimize end)
local totalDegrees = 0 
local numCurves = 100
local evalIters = 500
local minDegree = 1
local maxDegree = 20
local minControlPoints = 2
local maxControlPoints = 20
for i=1,numCurves do
    local degree = math.random(minDegree, maxDegree)
    totalDegrees = totalDegrees + degree
    local numControlPoints = math.random(minControlPoints, maxControlPoints)
    local numKnots = numControlPoints + degree + 1
    
    local controlPoints = pickNRandomPoints(numControlPoints)
    local knots = pickKnots(numKnots, degree)
    
    local optCurves = optimizeMethods:map(function(optimize)
        local curve = NURBSCurve{
            degree = degree,
            controlPoints = controlPoints, 
            knots = knots,
            optimize = optimize
        }
        curve.color = {pickRandomColor()}
        return curve
    end)

    print('degree', degree)
    print('#ctrlpts', #controlPoints)
    print('#knots', #knots)
    print('cpts', controlPoints:map(tostring):concat(' '))
    print('knots', knots:concat(', '))
    local f = io.open('error.txt', 'w')
    for i=0,evalIters do
        local fract = i / evalIters
        f:write(fract..'\t')
        local pa = optCurves[1](fract)
        for k,optimize in ipairs(optimizeMethods) do 
            local pb = optCurves[k](fract)
            local err = (pa - pb):lengthSq()
            if err ~= err then
                print('fract',fract)
                print('pa',pa)
                print('pb',pb)
                print('err',err)
                error('nan with opt method '..optimize)
            end
            if optimize ~= 0 then f:write(err..'\t') end    -- default will always be true
            totalErrors[optimize] = totalErrors[optimize] + err
        end
        f:write('\n')
    end
    f:close()

if totalErrors[1] > 0 then print('FAILED!!!') break end
    curves:append(optCurves)
end
local avgDegree = totalDegrees / numCurves
for _,optimize in ipairs(optimizeMethods) do
    print('method #'..optimize..':')
    print('total error',totalErrors[optimize])
    print('avg error per curve', totalErrors[optimize] / numCurves)
    print('avg error per degree', totalErrors[optimize] / avgDegree)
end
os.exit()

local allCurveCpts = table()
for _,curve in ipairs(curves) do
    for _,cpt in ipairs(curve.controlPoints) do
        allCurveCpts:insert(cpt)
    end
end

local useList
local recompile, list
if useList then
    list = gl.glGenLists(1)
    recompile = true
end
GLApp{
    vtxs = allCurveCpts,
    init = function(app, ...)
        app.view.pos[3] = 1
        app.view.zNear = .1
        app.view.zFar = 100
    end,
    draw = function(app)
        if app.selectedVtxIndex then
            recompile = true
        end
        if not useList or recompile then 
            recompile = false
            if useList then
                list = gl.glGenLists(1)
                gl.glNewList(list, gl.GL_COMPILE_AND_EXECUTE)
            end
            for i,curve in ipairs(curves) do
                
                gl.glColor3f(1,0,0)
                gl.glBegin(gl.GL_POINTS)
                for _,cpt in ipairs(curve.controlPoints) do
                    gl.glVertex3f(unpack(cpt))
                end
                gl.glEnd()
                gl.glColor3f(unpack(curve.color))
                gl.glBegin(gl.GL_LINE_STRIP)
                local n = 100
                for j=0,n do
                    gl.glVertex3f(unpack(curve(j/n)))
                end
                gl.glEnd() 
            end
            if useList then
                gl.glEndList()
            end
        elseif useList then
            gl.glCallList(list)
        end
    end,
}()

