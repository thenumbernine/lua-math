local GLApp = require 'glapp'
local vec3 = require 'vec.vec3'
local class = require 'ext.class'
local table = require 'ext.table'
local gl = require 'gl'
local BezierCurve = require 'math.curve.bezier'

local function printf(...) 
    print(string.format(...)) 
end

local controlPoints = {
    vec3(0,0,0),
    vec3(1,0,0),
    vec3(1,1,0),
    vec3(0,1,0),
}


local curves = table()
curves:insert(BezierCurve{controlPoints=controlPoints})
curves:insert(BezierCurve{controlPoints=controlPoints})

local allCurveCpts = table()
for _,curve in ipairs(curves) do
    for _,cpt in ipairs(curve.controlPoints) do
        allCurveCpts:insert(cpt)
    end
end
return class(GLApp, {
    vtxs = table():append(curves[1].controlPoints):append(curves[2].controlPoints), 
    draw = function(app)
        for i,curve in ipairs(curves) do
            gl.glColor3f(1,0,0)
            gl.glBegin(gl.GL_POINTS)
            for _,cpt in ipairs(curve.controlPoints) do
                gl.glVertex3f(unpack(cpt))
            end
            gl.glEnd()
            gl.glColor3f(i-1,1,1)
            gl.glBegin(gl.GL_LINE_STRIP)
            local n = 100
            for j=0,n do
                gl.glVertex3f(unpack(curve(j/n)))
            end
            gl.glEnd() 
        end
    
        -- curve distance test ...
        -- sum of, for all points, dist to closest point on other curve <times> step to next point
        -- (this will give you the volume of the shape bounded by the two curves) 
        do
            local sum = 0
            for ref=1,2 do
                local ca, cb
                if ref == 1 then
                    ca, cb = unpack(curves)
                else
                    cb, ca = unpack(curves)
                end
                local n = 100
                local i = 0
                while i < n do
                    local nexti = i + 1
                    local f = i / n
                    local nextf = nexti / n
                    -- point on curve B for this and the next iteration
                    local caf = ca(f)
                    local caNextF = ca(nextf)
                    -- closest point on curve B for this iteration
                    local cbClosestF = cb:closestPoint(caf)
                    local dx = (caNextF - caf):length()  
                    local dc = (cbClosestF - caf):length()
                    sum = sum + dx * dc
                    i = i + 1
                end
            end
            print('total area of separation',sum)
        end
    end,
})()
