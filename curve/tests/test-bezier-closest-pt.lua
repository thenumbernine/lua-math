#!/usr/bin/env luajit
local GLApp = require 'glapp'
local vec3 = require 'vec.vec3'
local class = require 'ext.class'
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


local curve = BezierCurve{controlPoints=controlPoints}

return class(GLApp, {
    vtxs = curve.controlPoints,
    update = function(self)
        gl.glColor3f(1,0,0)
        gl.glBegin(gl.GL_POINTS)
        for _,cpt in ipairs(curve.controlPoints) do
            gl.glVertex3f(unpack(cpt))
        end
        gl.glEnd()
        gl.glColor3f(0,1,1)
        gl.glBegin(gl.GL_LINE_STRIP)
        local n = 100
        for j=0,n do
            gl.glVertex3f(unpack(curve(j/n)))
        end
        gl.glEnd() 

        local viewZ = self.view.angle:rotate(vec3(0,0,1))
        local mousept = self.view.pos + self.mouseRay * vec3.dot(curve.controlPoints[1] - self.view.pos, -viewZ) 
        local cpt = curve:closestPoint(mousept)
        gl.glColor3f(0,1,0)
        gl.glBegin(gl.GL_POINTS)
        gl.glVertex3f(unpack(mousept))
        gl.glEnd()
        gl.glBegin(gl.GL_LINES)
        gl.glVertex3f(unpack(mousept))
        gl.glVertex3f(unpack(cpt))
        gl.glEnd()
    end,
}):run()
