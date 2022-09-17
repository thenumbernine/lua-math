local vec3 = require 'vec3'
local class = require 'ext.class'
local gl = require 'ffi.OpenGL'
local NURBSCurve = require 'curve.nurbs'

local controlPoints = {
    vec3(0,0,0),
    vec3(1,0,0),
    vec3(1,1,0),
    vec3(0,1,0),
}

local nurbsCurve = NURBSCurve{
    degree = 3, 
    controlPoints = controlPoints,
    knots = {0,0,0,0,1,1,1,1},
}

-- show arclength stuff...

local arclengthDetail = 1
for _,func in ipairs{'arclengthEuler', 'arclengthChebyshev'} do
    print('nurbsCurve:'..func..'('..arclengthDetail..') = '..nurbsCurve[func](nurbsCurve, arclengthDetail))
end


