#!/usr/bin/env luajit
local vec3d = require 'vec-ffi.vec3d'
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

return require 'glapp.orbit'():subclass{
    vtxs = curve.controlPoints,
	update = function(self)
        local gl = self.gl
		gl.glColor3f(1,0,0)
        gl.glBegin(gl.GL_POINTS)
        for _,cpt in ipairs(curve.controlPoints) do
            gl.glVertex3f(cpt:unpack())
        end
        gl.glEnd()
        gl.glColor3f(0,1,1)
        gl.glBegin(gl.GL_LINE_STRIP)
        local n = 100
        for j=0,n do
            gl.glVertex3f(unpack(curve(j/n)))
        end
        gl.glEnd() 

        local viewZ = self.view.angle:rotate(vec3d(0,0,1))
        local mousept = self.view.pos + self.mouseRay * vec3d.dot(
			vec3d(curve.controlPoints[1]:unpack()) - self.view.pos,
			-viewZ
		)
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
}():run()
